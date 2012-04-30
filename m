Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5931E6B004D
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 07:29:12 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n8so1941883lbj.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:29:11 -0700 (PDT)
Subject: [PATCH RFC 2/3] proc/smaps: show amount of nonlinear ptes in vma
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 30 Apr 2012 15:29:07 +0400
Message-ID: <20120430112907.14137.18910.stgit@zurg>
In-Reply-To: <20120430112903.14137.81692.stgit@zurg>
References: <20120430112903.14137.81692.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>

Currently, nonlinear mappings can not be distinguished from ordinary mappings.
This patch adds into /proc/pid/smaps line "Nonlinear: <size> kB", where size is
amount of nonlinear ptes in vma, this line appears only if VM_NONLINEAR is set.
This information may be useful not only for checkpoint/restore project.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Requested-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/proc/task_mmu.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index acee5fd..b1d9729 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -393,6 +393,7 @@ struct mem_size_stats {
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
 	unsigned long swap;
+	unsigned long nonlinear;
 	u64 pss;
 };
 
@@ -402,6 +403,7 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
+	pgoff_t pgoff = linear_page_index(vma, addr);
 	struct page *page = NULL;
 	int mapcount;
 
@@ -414,6 +416,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 			mss->swap += ptent_size;
 		else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
+	} else if (pte_file(ptent)) {
+		if (pte_to_pgoff(ptent) != pgoff)
+			mss->nonlinear += ptent_size;
 	}
 
 	if (!page)
@@ -422,6 +427,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	if (PageAnon(page))
 		mss->anonymous += ptent_size;
 
+	if (page->index != pgoff)
+		mss->nonlinear += ptent_size;
+
 	mss->resident += ptent_size;
 	/* Accumulate the size in pages that have been accessed. */
 	if (pte_young(ptent) || PageReferenced(page))
@@ -523,6 +531,10 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   (vma->vm_flags & VM_LOCKED) ?
 			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
 
+	if (vma->vm_flags & VM_NONLINEAR)
+		seq_printf(m, "Nonlinear:      %8lu kB\n",
+				mss.nonlinear >> 10);
+
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version = (vma != get_gate_vma(task->mm))
 			? vma->vm_start : 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
