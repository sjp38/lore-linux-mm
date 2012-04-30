Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3D5DF6B0081
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 07:29:18 -0400 (EDT)
Received: by lagz14 with SMTP id z14so2525225lag.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 04:29:16 -0700 (PDT)
Subject: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 30 Apr 2012 15:29:11 +0400
Message-ID: <20120430112910.14137.28935.stgit@zurg>
In-Reply-To: <20120430112903.14137.81692.stgit@zurg>
References: <20120430112903.14137.81692.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

This patch adds line "HWPoinson: <size> kB" into /proc/pid/smaps if
CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.
This may be useful for searching applications which use a broken memory.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andi Kleen <andi@firstfloor.org>
---
 fs/proc/task_mmu.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index b1d9729..3e564f0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -394,6 +394,7 @@ struct mem_size_stats {
 	unsigned long anonymous_thp;
 	unsigned long swap;
 	unsigned long nonlinear;
+	unsigned long hwpoison;
 	u64 pss;
 };
 
@@ -416,6 +417,8 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 			mss->swap += ptent_size;
 		else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
+		else if (is_hwpoison_entry(swpent))
+			mss->hwpoison += ptent_size;
 	} else if (pte_file(ptent)) {
 		if (pte_to_pgoff(ptent) != pgoff)
 			mss->nonlinear += ptent_size;
@@ -430,6 +433,9 @@ static void smaps_pte_entry(pte_t ptent, unsigned long addr,
 	if (page->index != pgoff)
 		mss->nonlinear += ptent_size;
 
+	if (PageHWPoison(page))
+		mss->hwpoison += ptent_size;
+
 	mss->resident += ptent_size;
 	/* Accumulate the size in pages that have been accessed. */
 	if (pte_young(ptent) || PageReferenced(page))
@@ -535,6 +541,10 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		seq_printf(m, "Nonlinear:      %8lu kB\n",
 				mss.nonlinear >> 10);
 
+	if (IS_ENABLED(CONFIG_MEMORY_FAILURE) && mss.hwpoison)
+		seq_printf(m, "HWPoison:       %8lu kB\n",
+				mss.hwpoison >> 10);
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
