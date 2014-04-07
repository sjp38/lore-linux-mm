From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: BUG in do_huge_pmd_wp_page
Date: Mon, 7 Apr 2014 17:48:35 +0300
Message-ID: <20140407144835.GA17774@node.dhcp.inet.fi>
References: <51559150.3040407@oracle.com>
 <515D882E.6040001@oracle.com>
 <533F09F0.1050206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <533F09F0.1050206@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Fri, Apr 04, 2014 at 03:37:20PM -0400, Sasha Levin wrote:
> And another ping exactly a year later :)

I think we could "fix" this false positive with the patch below
(untested), but it's ugly and doesn't add much value.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6ac89e9f82ef..65ac113037e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1053,6 +1053,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long haddr;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	pmd_t entry;
 
 	ptl = pmd_lockptr(mm, pmd);
 	VM_BUG_ON(!vma->anon_vma);
@@ -1115,42 +1116,45 @@ alloc:
 
 	count_vm_event(THP_FAULT_ALLOC);
 
+	mmun_start = haddr;
+	mmun_end   = haddr + HPAGE_PMD_SIZE;
+	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
+
+	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
+		spin_lock(ptl);
+		if (unlikely(!pmd_same(*pmd, orig_pmd)))
+			goto out_race;
+	}
+
 	if (!page)
 		clear_huge_page(new_page, haddr, HPAGE_PMD_NR);
 	else
 		copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
 	__SetPageUptodate(new_page);
 
-	mmun_start = haddr;
-	mmun_end   = haddr + HPAGE_PMD_SIZE;
-	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
-
-	spin_lock(ptl);
+	if (!IS_ENABLED(CONFIG_DEBUG_PAGEALLOC)) {
+		spin_lock(ptl);
+		if (unlikely(!pmd_same(*pmd, orig_pmd)))
+			goto out_race;
+	}
 	if (page)
 		put_page(page);
-	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
-		spin_unlock(ptl);
-		mem_cgroup_uncharge_page(new_page);
-		put_page(new_page);
-		goto out_mn;
+
+	entry = mk_huge_pmd(new_page, vma->vm_page_prot);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	pmdp_clear_flush(vma, haddr, pmd);
+	page_add_new_anon_rmap(new_page, vma, haddr);
+	set_pmd_at(mm, haddr, pmd, entry);
+	update_mmu_cache_pmd(vma, address, pmd);
+	if (!page) {
+		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+		put_huge_zero_page();
 	} else {
-		pmd_t entry;
-		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
-		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
-		pmdp_clear_flush(vma, haddr, pmd);
-		page_add_new_anon_rmap(new_page, vma, haddr);
-		set_pmd_at(mm, haddr, pmd, entry);
-		update_mmu_cache_pmd(vma, address, pmd);
-		if (!page) {
-			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
-			put_huge_zero_page();
-		} else {
-			VM_BUG_ON_PAGE(!PageHead(page), page);
-			page_remove_rmap(page);
-			put_page(page);
-		}
-		ret |= VM_FAULT_WRITE;
+		VM_BUG_ON_PAGE(!PageHead(page), page);
+		page_remove_rmap(page);
+		put_page(page);
 	}
+	ret |= VM_FAULT_WRITE;
 	spin_unlock(ptl);
 out_mn:
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
@@ -1159,6 +1163,13 @@ out:
 out_unlock:
 	spin_unlock(ptl);
 	return ret;
+out_race:
+	spin_unlock(ptl);
+	if (page)
+		put_page(page);
+	mem_cgroup_uncharge_page(new_page);
+	put_page(new_page);
+	goto out_mn;
 }
 
 struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
-- 
 Kirill A. Shutemov
