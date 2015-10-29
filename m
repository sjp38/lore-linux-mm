Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 49DDE82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 05:43:45 -0400 (EDT)
Received: by wmff134 with SMTP id f134so20988288wmf.1
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 02:43:44 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id k8si877908wjq.172.2015.10.29.02.43.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 02:43:43 -0700 (PDT)
Received: by wmeg8 with SMTP id g8so21029392wme.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 02:43:43 -0700 (PDT)
Date: Thu, 29 Oct 2015 11:43:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151029094342.GA29870@node.shutemov.name>
References: <20151021052836.GB6024@bbox>
 <20151021110723.GC10597@node.shutemov.name>
 <20151022000648.GD23631@bbox>
 <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
 <20151022012136.GG23631@bbox>
 <20151022090051.GH23631@bbox>
 <20151029002524.GA12018@node.shutemov.name>
 <20151029075829.GA16099@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151029075829.GA16099@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Oct 29, 2015 at 04:58:29PM +0900, Minchan Kim wrote:
> On Thu, Oct 29, 2015 at 02:25:24AM +0200, Kirill A. Shutemov wrote:
> > On Thu, Oct 22, 2015 at 06:00:51PM +0900, Minchan Kim wrote:
> > > On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> > > > Hello Hugh,
> > > > 
> > > > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > > > 
> > > > > > I added the code to check it and queued it again but I had another oops
> > > > > > in this time but symptom is related to anon_vma, too.
> > > > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > > > to be true.
> > > > > > 
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > > > 
> > > > > That's interesting, that's one I added in my page migration series.
> > > > > Let me think on it, but it could well relate to the one you got before.
> > > > 
> > > > I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> > > > instead of next-20151021 to remove noise from your migration cleanup
> > > > series and will test it again.
> > > > If it is fixed, I will test again with your migration patchset, then.
> > > 
> > > I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
> > > Therefore, there is no patchset from Hugh's migration patch in there.
> > > And I added below debug code with request from Kirill to all test kernels.
> > 
> > It took too long time (and a lot of printk()), but I think I track it down
> > finally.
> >  
> > The patch below seems fixes issue for me. It's not yet properly tested, but
> > looks like it works.
> > 
> > The problem was my wrong assumption on how migration works: I thought that
> > kernel would wait migration to finish on before deconstruction mapping.
> > 
> > But turn out that's not true.
> > 
> > As result if zap_pte_range() races with split_huge_page(), we can end up
> > with page which is not mapped anymore but has _count and _mapcount
> > elevated. The page is on LRU too. So it's still reachable by vmscan and by
> > pfn scanners (Sasha showed few similar traces from compaction too).
> > It's likely that page->mapping in this case would point to freed anon_vma.
> > 
> > BOOM!
> > 
> > The patch modify freeze/unfreeze_page() code to match normal migration
> > entries logic: on setup we remove page from rmap and drop pin, on removing
> > we get pin back and put page on rmap. This way even if migration entry
> > will be removed under us we don't corrupt page's state.
> > 
> > Please, test.
> > 
> 
> kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + your new patch, I tested
> one I sent to you(ie, oops.c + memcg_test.sh)
> 
> page:ffffea00016a0000 count:3 mapcount:0 mapping:ffff88007f49d001 index:0x600001800 compound_mapcount: 0
> flags: 0x4000000000044009(locked|uptodate|head|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(!page_mapcount(page))

The VM_BUG_ON_PAGE() is bogus after the patch. Just drop it.

> page->mem_cgroup:ffff88007f613c00
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:1156!
> invalid opcode: 0000 [#1] SMP 
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Modules linked in:
> CPU: 7 PID: 3312 Comm: oops Not tainted 4.3.0-rc5-mm1-madv-free-no-lazy-thp+ #1573
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff8800b8804ec0 ti: ffff88000005c000 task.ti: ffff88000005c000
> RIP: 0010:[<ffffffff81128223>]  [<ffffffff81128223>] do_page_add_anon_rmap+0x323/0x360
> RSP: 0000:ffff88000005f758  EFLAGS: 00010292
> RAX: 0000000000000021 RBX: ffffea00016a0000 RCX: ffffffff81830db8
> RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffffff821df4d8
> RBP: ffff88000005f780 R08: 0000000000000000 R09: ffff8800000b8be0
> R10: ffffffff8163d7c0 R11: 00000000000001a5 R12: ffff88007e85ddc0
> R13: 0000600001800000 R14: 0000000000000000 R15: ffff88007e85ddc0
> FS:  00007f5cd5fea740(0000) GS:ffff8800bfae0000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000600004c03000 CR3: 000000007f017000 CR4: 00000000000006a0
> Stack:
>  ffff88007f351000 ffff88007f352000 ffffea00016a0000 0000600001800000
>  ffff88007e85ddc0 ffff88000005f790 ffffffff81128278 ffff88000005f800
>  ffffffff81146dbb 00000006000019ff 0000000600001800 0000160000000000
> Call Trace:
>  [<ffffffff81128278>] page_add_anon_rmap+0x18/0x20
>  [<ffffffff81146dbb>] unfreeze_page+0x24b/0x330
>  [<ffffffff8114bb5f>] split_huge_page_to_list+0x3df/0x920
>  [<ffffffff811321cf>] ? scan_swap_map+0x37f/0x550
>  [<ffffffff8112f996>] add_to_swap+0xb6/0x100
>  [<ffffffff81103c87>] shrink_page_list+0x3b7/0xdc0
>  [<ffffffff81104d4c>] shrink_inactive_list+0x18c/0x4b0
>  [<ffffffff811059af>] shrink_lruvec+0x58f/0x730
>  [<ffffffff81105c24>] shrink_zone+0xd4/0x280
>  [<ffffffff81105efd>] do_try_to_free_pages+0x12d/0x3b0
>  [<ffffffff8110635d>] try_to_free_mem_cgroup_pages+0x9d/0x120
>  [<ffffffff8114e2f5>] try_charge+0x175/0x720
>  [<ffffffff812728c3>] ? radix_tree_lookup_slot+0x13/0x30
>  [<ffffffff810efd6e>] ? find_get_entry+0x1e/0xc0
>  [<ffffffff811520c5>] mem_cgroup_try_charge+0x85/0x1d0
>  [<ffffffff8111c4d7>] do_swap_page+0xd7/0x5a0
>  [<ffffffff8111e203>] handle_mm_fault+0x803/0x1000
>  [<ffffffff8106efda>] ? pick_next_task_fair+0x3ba/0x480
>  [<ffffffff8105f8c0>] ? finish_task_switch+0x70/0x260
>  [<ffffffff81033629>] __do_page_fault+0x189/0x400
>  [<ffffffff810338ac>] do_page_fault+0xc/0x10
>  [<ffffffff81428842>] page_fault+0x22/0x30
> 
> 
> 
> 
> > Not-Yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 5e0fe82a0fae..192b50c7526c 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2934,6 +2934,13 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> >  
> >  	smp_wmb(); /* make pte visible before pmd */
> >  	pmd_populate(mm, pmd, pgtable);
> > +
> > +	if (freeze) {
> > +		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> > +			page_remove_rmap(page + i, false);
> > +			put_page(page + i);
> > +		}
> > +	}
> >  }
> >  
> >  void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> > @@ -3079,6 +3086,8 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  		if (pte_soft_dirty(entry))
> >  			swp_pte = pte_swp_mksoft_dirty(swp_pte);
> >  		set_pte_at(vma->vm_mm, address, pte + i, swp_pte);
> > +		page_remove_rmap(page, false);
> > +		put_page(page);
> >  	}
> >  	pte_unmap_unlock(pte, ptl);
> >  }
> > @@ -3117,8 +3126,6 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  		return;
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
> >  	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
> > -		if (!page_mapped(page))
> > -			continue;
> >  		if (!is_swap_pte(pte[i]))
> >  			continue;
> >  
> > @@ -3128,6 +3135,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
> >  		if (migration_entry_to_page(swp_entry) != page)
> >  			continue;
> >  
> > +		get_page(page);
> > +		page_add_anon_rmap(page, vma, address, false);
> > +
> >  		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
> >  		entry = pte_mkdirty(entry);
> >  		if (is_write_migration_entry(swp_entry))
> > -- 
> >  Kirill A. Shutemov
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
