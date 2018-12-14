Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEB348E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:23:25 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f31so61076edf.17
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 11:23:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s21si121126edq.293.2018.12.14.11.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 11:23:24 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBEJMZGH094310
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:23:22 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2pcja8rvbk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 14:23:22 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Fri, 14 Dec 2018 19:23:20 -0000
Date: Fri, 14 Dec 2018 20:23:15 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
In-Reply-To: <bcd0c49c-e417-ef8b-996f-99ecef540d9c@redhat.com>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
	<20181212172712.34019-2-zaslonko@linux.ibm.com>
	<476a80cb-5524-16c1-6dd5-da5febbd6139@redhat.com>
	<bcd0c49c-e417-ef8b-996f-99ecef540d9c@redhat.com>
MIME-Version: 1.0
Message-Id: <20181214202315.1c685f1e@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Fri, 14 Dec 2018 16:49:14 +0100
David Hildenbrand <david@redhat.com> wrote:

> On 14.12.18 16:22, David Hildenbrand wrote:
> > On 12.12.18 18:27, Mikhail Zaslonko wrote:  
> >> If memory end is not aligned with the sparse memory section boundary, the
> >> mapping of such a section is only partly initialized. This may lead to
> >> VM_BUG_ON due to uninitialized struct page access from
> >> is_mem_section_removable() or test_pages_in_a_zone() function triggered by
> >> memory_hotplug sysfs handlers:
> >>
> >> Here are the the panic examples:
> >>  CONFIG_DEBUG_VM=y
> >>  CONFIG_DEBUG_VM_PGFLAGS=y
> >>
> >>  kernel parameter mem=2050M
> >>  --------------------------
> >>  page:000003d082008000 is uninitialized and poisoned
> >>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >>  Call Trace:
> >>  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
> >>   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
> >>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> >>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> >>   [<00000000003e4194>] seq_read+0x204/0x480
> >>   [<00000000003b53ea>] __vfs_read+0x32/0x178
> >>   [<00000000003b55b2>] vfs_read+0x82/0x138
> >>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> >>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> >>  Last Breaking-Event-Address:
> >>   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
> >>  Kernel panic - not syncing: Fatal exception: panic_on_oops
> >>
> >>  kernel parameter mem=3075M
> >>  --------------------------
> >>  page:000003d08300c000 is uninitialized and poisoned
> >>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> >>  Call Trace:
> >>  ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
> >>   [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
> >>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
> >>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
> >>   [<00000000003e4194>] seq_read+0x204/0x480
> >>   [<00000000003b53ea>] __vfs_read+0x32/0x178
> >>   [<00000000003b55b2>] vfs_read+0x82/0x138
> >>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
> >>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
> >>  Last Breaking-Event-Address:
> >>   [<000000000038596c>] is_mem_section_removable+0xb4/0x190
> >>  Kernel panic - not syncing: Fatal exception: panic_on_oops
> >>
> >> Fix the problem by initializing the last memory section of each zone
> >> in memmap_init_zone() till the very end, even if it goes beyond the zone
> >> end.
> >>
> >> Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
> >> Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> >> Cc: <stable@vger.kernel.org>
> >> ---
> >>  mm/page_alloc.c | 12 ++++++++++++
> >>  1 file changed, 12 insertions(+)
> >>
> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index 2ec9cc407216..e2afdb2dc2c5 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -5542,6 +5542,18 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
> >>  			cond_resched();
> >>  		}
> >>  	}
> >> +#ifdef CONFIG_SPARSEMEM
> >> +	/*
> >> +	 * If the zone does not span the rest of the section then
> >> +	 * we should at least initialize those pages. Otherwise we
> >> +	 * could blow up on a poisoned page in some paths which depend
> >> +	 * on full sections being initialized (e.g. memory hotplug).
> >> +	 */
> >> +	while (end_pfn % PAGES_PER_SECTION) {
> >> +		__init_single_page(pfn_to_page(end_pfn), end_pfn, zone, nid);
> >> +		end_pfn++;  
> > 
> > This page will not be marked as PG_reserved - although it is a physical
> > memory gap. Do we care?
> >   
> 
> Hm, or do we even have any idea what this is (e.g. could it also be
> something not a gap)?

In the "mem=" restriction scenario it would be a gap, and probably fall
into the PG_reserved categorization from your recent patch:
 * - Pages falling into physical memory gaps - not IORESOURCE_SYSRAM. Trying
 *   to read/write these pages might end badly. Don't touch!

Not sure if it could be something else. In theory, if it is possible to have
a scenario where memory zones are not section-aligned, then this
end_pfn % PAGES_PER_SECTION part could be part of another zone. But then it
should not matter if the pages get pre-initialized here, with or w/o
PG_reseved, because they should later be properly initialized in their zone.

So marking them as PG_reserved sounds right, especially in the light of your
current PG_reserved clean-up.

> 
> For physical memory gaps within a section, architectures usually exclude
> that memory from getting passed to e.g. the page allocator by
> memblock_reserve().
> 
> Before handing all free pages to the page allocator, all such reserved
> memblocks will be marked reserved.
> 
> But this here seems to be different. We don't have a previous
> memblock_reserve(), because otherwise these pages would have properly
> been initialized already when marking them reserved.

Not sure how memblock_reserve() and struct page initialization are
related, but at least on s390 there is a memblock_reserve() on the range
in question in setup_arch() -> reserve_memory_end(). However, in this
"mem=" scenario, the range is also removed later with memblock_remove()
in setup_memory_end(), because it is beyond memory_end.
