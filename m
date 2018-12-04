Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4964B6B6E05
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:35:52 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so7851975edb.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:35:52 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14-v6si1134846ejf.152.2018.12.04.01.35.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 01:35:50 -0800 (PST)
Date: Tue, 4 Dec 2018 10:35:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Message-ID: <20181204093549.GE1286@dhcp22.suse.cz>
References: <20181203100309.14784-1-mhocko@kernel.org>
 <20181204072116.GA24446@hori1.linux.bs1.fc.nec.co.jp>
 <20181204081801.GA1286@dhcp22.suse.cz>
 <20181204091104.GA3788@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204091104.GA3788@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Oscar Salvador <OSalvador@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue 04-12-18 09:11:05, Naoya Horiguchi wrote:
> On Tue, Dec 04, 2018 at 09:48:26AM +0100, Michal Hocko wrote:
> > On Tue 04-12-18 07:21:16, Naoya Horiguchi wrote:
> > > On Mon, Dec 03, 2018 at 11:03:09AM +0100, Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > We have received a bug report that an injected MCE about faulty memory
> > > > prevents memory offline to succeed. The underlying reason is that the
> > > > HWPoison page has an elevated reference count and the migration keeps
> > > > failing. There are two problems with that. First of all it is dubious
> > > > to migrate the poisoned page because we know that accessing that memory
> > > > is possible to fail. Secondly it doesn't make any sense to migrate a
> > > > potentially broken content and preserve the memory corruption over to a
> > > > new location.
> > > > 
> > > > Oscar has found out that it is the elevated reference count from
> > > > memory_failure that is confusing the offlining path. HWPoisoned pages
> > > > are isolated from the LRU list but __offline_pages might still try to
> > > > migrate them if there is any preceding migrateable pages in the pfn
> > > > range. Such a migration would fail due to the reference count but
> > > > the migration code would put it back on the LRU list. This is quite
> > > > wrong in itself but it would also make scan_movable_pages stumble over
> > > > it again without any way out.
> > > > 
> > > > This means that the hotremove with hwpoisoned pages has never really
> > > > worked (without a luck). HWPoisoning really needs a larger surgery
> > > > but an immediate and backportable fix is to skip over these pages during
> > > > offlining. Even if they are still mapped for some reason then
> > > > try_to_unmap should turn those mappings into hwpoison ptes and cause
> > > > SIGBUS on access. Nobody should be really touching the content of the
> > > > page so it should be safe to ignore them even when there is a pending
> > > > reference count.
> > > > 
> > > > Debugged-by: Oscar Salvador <osalvador@suse.com>
> > > > Cc: stable
> > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > > ---
> > > > Hi,
> > > > I am sending this as an RFC now because I am not fully sure I see all
> > > > the consequences myself yet. This has passed a testing by Oscar but I
> > > > would highly appreciate a review from Naoya about my assumptions about
> > > > hwpoisoning. E.g. it is not entirely clear to me whether there is a
> > > > potential case where the page might be still mapped.
> > > 
> > > One potential case is ksm page, for which we give up unmapping and leave
> > > it unmapped. Rather than that I don't have any idea, but any new type of
> > > page would be potentially categorized to this class.
> > 
> > Could you be more specific why hwpoison code gives up on ksm pages while
> > we can safely unmap here?
> 
> Actually no big reason. Ksm pages never dominate memory, so we simply didn't
> have strong motivation to save the pages.

OK, so the unmapping is safe. I will drop a comment. Does this look good
to you?
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 08c576d5a633..ef5d42759aa2 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1370,7 +1370,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 		/*
 		 * HWPoison pages have elevated reference counts so the migration would
 		 * fail on them. It also doesn't make any sense to migrate them in the
-		 * first place. Still try to unmap such a page in case it is still mapped.
+		 * first place. Still try to unmap such a page in case it is still mapped
+		 * (e.g. current hwpoison implementation doesn't unmap KSM pages but keep
+		 * the unmap as the catch all safety net).
 		 */
 		if (PageHWPoison(page)) {
 			if (page_mapped(page))
-- 
Michal Hocko
SUSE Labs
