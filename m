Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CE1796B007E
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:15 -0500 (EST)
Message-Id: <20100309194314.804779809@redhat.com>
Date: Tue, 09 Mar 2010 20:39:21 +0100
From: aarcange@redhat.com
Subject: [patch 20/35] add pmd_huge_pte to mm_struct
References: <20100309193901.207868642@redhat.com>
Content-Disposition: inline; filename=pmd_huge_pte
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>
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
 include/linux/mm_types.h |    3 +++
 kernel/fork.c            |    7 +++++++
 2 files changed, 10 insertions(+)

--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -310,6 +310,9 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+#endif
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -502,6 +502,9 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(mm->pmd_huge_pte);
+#endif
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -642,6 +645,10 @@ struct mm_struct *dup_mm(struct task_str
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
