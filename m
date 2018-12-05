Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 354A06B744E
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:29:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so9812451edb.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:29:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k7si2360460edb.132.2018.12.05.04.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:29:20 -0800 (PST)
Date: Wed, 5 Dec 2018 13:29:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
Message-ID: <20181205122918.GL1286@dhcp22.suse.cz>
References: <20181203100309.14784-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203100309.14784-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Oscar Salvador <OSalvador@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon 03-12-18 11:03:09, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> We have received a bug report that an injected MCE about faulty memory
> prevents memory offline to succeed. The underlying reason is that the
> HWPoison page has an elevated reference count and the migration keeps
> failing. There are two problems with that. First of all it is dubious
> to migrate the poisoned page because we know that accessing that memory
> is possible to fail. Secondly it doesn't make any sense to migrate a
> potentially broken content and preserve the memory corruption over to a
> new location.
> 
> Oscar has found out that it is the elevated reference count from
> memory_failure that is confusing the offlining path. HWPoisoned pages
> are isolated from the LRU list but __offline_pages might still try to
> migrate them if there is any preceding migrateable pages in the pfn
> range. Such a migration would fail due to the reference count but
> the migration code would put it back on the LRU list. This is quite
> wrong in itself but it would also make scan_movable_pages stumble over
> it again without any way out.
> 
> This means that the hotremove with hwpoisoned pages has never really
> worked (without a luck). HWPoisoning really needs a larger surgery
> but an immediate and backportable fix is to skip over these pages during
> offlining. Even if they are still mapped for some reason then
> try_to_unmap should turn those mappings into hwpoison ptes and cause
> SIGBUS on access. Nobody should be really touching the content of the
> page so it should be safe to ignore them even when there is a pending
> reference count.

After some more thinking I am not really sure the above reasoning is
still true with the current upstream kernel. Maybe I just managed to
confuse myself so please hold off on this patch for now. Testing by
Oscar has shown this patch is helping but the changelog might need to be
updated.
-- 
Michal Hocko
SUSE Labs
