Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FF458E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:36:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so8145251edm.20
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:36:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si1190555edp.124.2019.01.21.10.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 10:36:15 -0800 (PST)
Date: Mon, 21 Jan 2019 19:36:13 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
Message-ID: <20190121183613.GY4087@dhcp22.suse.cz>
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
 <20190118021650.93222-1-cai@lca.pw>
 <20190121095352.GM4087@dhcp22.suse.cz>
 <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
 <3c4aa744-4a8a-08a6-bc41-ac3a722a0d17@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c4aa744-4a8a-08a6-bc41-ac3a722a0d17@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org

On Mon 21-01-19 12:58:46, Qian Cai wrote:
> 
> 
> On 1/21/19 11:38 AM, Qian Cai wrote:
> > 
> > 
> > On 1/21/19 4:53 AM, Michal Hocko wrote:
> >> On Thu 17-01-19 21:16:50, Qian Cai wrote:
> >>> On an arm64 ThunderX2 server, the first kmemleak scan would crash [1]
> >>> with CONFIG_DEBUG_VM_PGFLAGS=y due to page_to_nid() found a pfn that is
> >>> not directly mapped (MEMBLOCK_NOMAP). Hence, the page->flags is
> >>> uninitialized.
> >>>
> >>> This is due to the commit 9f1eb38e0e11 ("mm, kmemleak: little
> >>> optimization while scanning") starts to use pfn_to_online_page() instead
> >>> of pfn_valid(). However, in the CONFIG_MEMORY_HOTPLUG=y case,
> >>> pfn_to_online_page() does not call memblock_is_map_memory() while
> >>> pfn_valid() does.
> >>
> >> How come there is an online section which has an pfn_valid==F? We do
> >> allocate the full section worth of struct pages so there is a valid
> >> struct page. Is there any hole inside this section?
> > 
> > It has CONFIG_HOLES_IN_ZONE=y.
> 
> Actually, this does not seem have anything to do with holes.
> 
> 68709f45385a arm64: only consider memblocks with NOMAP cleared for linear mapping
> 
> This causes pages marked as nomap being no long reassigned to the new zone in
> memmap_init_zone() by calling __init_single_page().

Thanks for the pointer. This sched some light but I cannot say I would
understand all the details.

> There is an old discussion for this topic.
> https://lkml.org/lkml/2016/11/30/566

Hmm, I see. The documentation is not the best (mea culpa)
 * Return page for the valid pfn only if the page is online. All pfn
 * walkers which rely on the fully initialized page->flags and others
 * should use this rather than pfn_valid && pfn_to_page

This suggests that the pfn is _valid_ when using pfn_to_online_page and
some callers indeed do so. Some of them don't though which is probably
because the later part of the documentation suggests that it should
replace pfn_valid & pfn_to_page. Thinking about this more, I guess we do
not want to put an additional burden on callers and require pfn_valid to
be called as well. This is just error prone and can lead to problems
like this one.

So I agree with your change (modulo the range check) but please make
sure to make all this information to the changelog.

Thanks!
-- 
Michal Hocko
SUSE Labs
