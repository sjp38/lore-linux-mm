Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C7FDE82F64
	for <linux-mm@kvack.org>; Wed, 28 Oct 2015 20:25:27 -0400 (EDT)
Received: by wmeg8 with SMTP id g8so15084649wme.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:25:27 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id at5si55214414wjc.111.2015.10.28.17.25.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Oct 2015 17:25:26 -0700 (PDT)
Received: by wmeg8 with SMTP id g8so15084474wme.1
        for <linux-mm@kvack.org>; Wed, 28 Oct 2015 17:25:26 -0700 (PDT)
Date: Thu, 29 Oct 2015 02:25:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151029002524.GA12018@node.shutemov.name>
References: <20151021052836.GB6024@bbox>
 <20151021110723.GC10597@node.shutemov.name>
 <20151022000648.GD23631@bbox>
 <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
 <20151022012136.GG23631@bbox>
 <20151022090051.GH23631@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022090051.GH23631@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Oct 22, 2015 at 06:00:51PM +0900, Minchan Kim wrote:
> On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> > Hello Hugh,
> > 
> > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > 
> > > > I added the code to check it and queued it again but I had another oops
> > > > in this time but symptom is related to anon_vma, too.
> > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > to be true.
> > > > 
> > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > 
> > > That's interesting, that's one I added in my page migration series.
> > > Let me think on it, but it could well relate to the one you got before.
> > 
> > I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> > instead of next-20151021 to remove noise from your migration cleanup
> > series and will test it again.
> > If it is fixed, I will test again with your migration patchset, then.
> 
> I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
> Therefore, there is no patchset from Hugh's migration patch in there.
> And I added below debug code with request from Kirill to all test kernels.

It took too long time (and a lot of printk()), but I think I track it down
finally.
 
The patch below seems fixes issue for me. It's not yet properly tested, but
looks like it works.

The problem was my wrong assumption on how migration works: I thought that
kernel would wait migration to finish on before deconstruction mapping.

But turn out that's not true.

As result if zap_pte_range() races with split_huge_page(), we can end up
with page which is not mapped anymore but has _count and _mapcount
elevated. The page is on LRU too. So it's still reachable by vmscan and by
pfn scanners (Sasha showed few similar traces from compaction too).
It's likely that page->mapping in this case would point to freed anon_vma.

BOOM!

The patch modify freeze/unfreeze_page() code to match normal migration
entries logic: on setup we remove page from rmap and drop pin, on removing
we get pin back and put page on rmap. This way even if migration entry
will be removed under us we don't corrupt page's state.

Please, test.

Not-Yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5e0fe82a0fae..192b50c7526c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2934,6 +2934,13 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
+
+	if (freeze) {
+		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
+			page_remove_rmap(page + i, false);
+			put_page(page + i);
+		}
+	}
 }
 
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
@@ -3079,6 +3086,8 @@ static void freeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		if (pte_soft_dirty(entry))
 			swp_pte = pte_swp_mksoft_dirty(swp_pte);
 		set_pte_at(vma->vm_mm, address, pte + i, swp_pte);
+		page_remove_rmap(page, false);
+		put_page(page);
 	}
 	pte_unmap_unlock(pte, ptl);
 }
@@ -3117,8 +3126,6 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		return;
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, address, &ptl);
 	for (i = 0; i < HPAGE_PMD_NR; i++, address += PAGE_SIZE, page++) {
-		if (!page_mapped(page))
-			continue;
 		if (!is_swap_pte(pte[i]))
 			continue;
 
@@ -3128,6 +3135,9 @@ static void unfreeze_page_vma(struct vm_area_struct *vma, struct page *page,
 		if (migration_entry_to_page(swp_entry) != page)
 			continue;
 
+		get_page(page);
+		page_add_anon_rmap(page, vma, address, false);
+
 		entry = pte_mkold(mk_pte(page, vma->vm_page_prot));
 		entry = pte_mkdirty(entry);
 		if (is_write_migration_entry(swp_entry))
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
