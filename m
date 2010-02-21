Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D64D06B008A
	for <linux-mm@kvack.org>; Sun, 21 Feb 2010 09:18:43 -0500 (EST)
Message-Id: <20100221141756.002607087@redhat.com>
Date: Sun, 21 Feb 2010 15:10:29 +0100
From: aarcange@redhat.com
Subject: [patch 20/36] add pmd_huge_pte to mm_struct
References: <20100221141009.581909647@redhat.com>
Content-Disposition: inline; filename=pmd_huge_pte
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

This increase the size of the mm struct a bit but it is needed to preallocate
one pte for each hugepage so that split_huge_page will not require a fail path.
Guarantee of success is a fundamental property of split_huge_page to avoid
decrasing swapping reliability and to avoid adding -ENOMEM fail paths that
would otherwise force the hugepage-unaware VM code to learn rolling back in the
middle of its pte mangling operations (if something we need it to learn
handling pmd_trans_huge natively rather being capable of rollback). When
split_huge_page runs a pte is needed to succeed the split, to map the newly
splitted regular pages with a regular pte.  This way all existing VM code
remains backwards compatible by just adding a split_huge_page* one liner. The
memory waste of those preallocated ptes is negligible and so it is worth it.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -291,6 +291,9 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -498,6 +498,9 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(mm->pmd_huge_pte);
+#endif
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -638,6 +641,10 @@ struct mm_struct *dup_mm(struct task_str
 	mm->token_priority = 0;
 	mm->last_interval = 0;
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	mm->pmd_huge_pte = NULL;
+#endif
+
 	if (!mm_init(mm, tsk))
 		goto fail_nomem;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
