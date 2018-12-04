Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DEBD26B6DD2
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:48:30 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so7923072edd.2
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:48:30 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12si677686edf.296.2018.12.04.00.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 00:48:29 -0800 (PST)
Date: Tue, 4 Dec 2018 09:48:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Message-ID: <20181204081801.GA1286@dhcp22.suse.cz>
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181204072116.GA24446@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204072116.GA24446@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue 04-12-18 07:21:16, Naoya Horiguchi wrote:
> On Mon, Dec 03, 2018 at 11:03:09AM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We have received a bug report that an injected MCE about faulty memory
> > prevents memory offline to succeed. The underlying reason is that the
> > HWPoison page has an elevated reference count and the migration keeps
> > failing. There are two problems with that. First of all it is dubious
> > to migrate the poisoned page because we know that accessing that memory
> > is possible to fail. Secondly it doesn't make any sense to migrate a
> > potentially broken content and preserve the memory corruption over to a
> > new location.
> > 
> > Oscar has found out that it is the elevated reference count from
> > memory_failure that is confusing the offlining path. HWPoisoned pages
> > are isolated from the LRU list but __offline_pages might still try to
> > migrate them if there is any preceding migrateable pages in the pfn
> > range. Such a migration would fail due to the reference count but
> > the migration code would put it back on the LRU list. This is quite
> > wrong in itself but it would also make scan_movable_pages stumble over
> > it again without any way out.
> > 
> > This means that the hotremove with hwpoisoned pages has never really
> > worked (without a luck). HWPoisoning really needs a larger surgery
> > but an immediate and backportable fix is to skip over these pages during
> > offlining. Even if they are still mapped for some reason then
> > try_to_unmap should turn those mappings into hwpoison ptes and cause
> > SIGBUS on access. Nobody should be really touching the content of the
> > page so it should be safe to ignore them even when there is a pending
> > reference count.
> > 
> > Debugged-by: Oscar Salvador <osalvador@suse.com>
> > Cc: stable
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > Hi,
> > I am sending this as an RFC now because I am not fully sure I see all
> > the consequences myself yet. This has passed a testing by Oscar but I
> > would highly appreciate a review from Naoya about my assumptions about
> > hwpoisoning. E.g. it is not entirely clear to me whether there is a
> > potential case where the page might be still mapped.
> 
> One potential case is ksm page, for which we give up unmapping and leave
> it unmapped. Rather than that I don't have any idea, but any new type of
> page would be potentially categorized to this class.

Could you be more specific why hwpoison code gives up on ksm pages while
we can safely unmap here?

[...]
> 
> I think this looks OK (no better idea.)
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!

> I wondered why I didn't find this for long, and found that my testing only
> covered the case where PageHWPoison is the first page of memory block.
> scan_movable_pages() considers PageHWPoison as non-movable, so do_migrate_range()
> started with pfn after the PageHWPoison and never tried to migrate it
> (so effectively ignored every PageHWPoison as the above code does.)

Yeah, it seems that the hotremove worked only by chance in presence of
hwpoison pages so far. The specific usecase which triggered this patch
is a heavily memory utilized system with in memory database IIRC. So it
is quite likely that hwpoison pages are punched to otherwise used
memory.

Thanks for the review Naoya!

-- 
Michal Hocko
SUSE Labs
