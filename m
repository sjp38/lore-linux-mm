Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C212F6B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 07:19:52 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x2-v6so187992plv.0
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 04:19:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v190-v6si8615556pgd.668.2018.07.23.04.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 04:19:51 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/4] mm: proc/pid/smaps: factor out mem stats gathering
Date: Mon, 23 Jul 2018 13:19:31 +0200
Message-Id: <20180723111933.15443-3-vbabka@suse.cz>
In-Reply-To: <20180723111933.15443-1-vbabka@suse.cz>
References: <20180723111933.15443-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>, linux-api@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

To prepare for handling /proc/pid/smaps_rollup differently from /proc/pid/smaps
factor out vma mem stats gathering from show_smap() - it will be used by both.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/proc/task_mmu.c | 55 ++++++++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index a3f98ca50981..d2ca88c92d9d 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -702,14 +702,9 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
 }
 #endif /* HUGETLB_PAGE */
 
-#define SEQ_PUT_DEC(str, val) \
-		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
-static int show_smap(struct seq_file *m, void *v)
+static void smap_gather_stats(struct vm_area_struct *vma,
+			     struct mem_size_stats *mss)
 {
-	struct proc_maps_private *priv = m->private;
-	struct vm_area_struct *vma = v;
-	struct mem_size_stats mss_stack;
-	struct mem_size_stats *mss;
 	struct mm_walk smaps_walk = {
 		.pmd_entry = smaps_pte_range,
 #ifdef CONFIG_HUGETLB_PAGE
@@ -717,23 +712,6 @@ static int show_smap(struct seq_file *m, void *v)
 #endif
 		.mm = vma->vm_mm,
 	};
-	int ret = 0;
-	bool rollup_mode;
-	bool last_vma;
-
-	if (priv->rollup) {
-		rollup_mode = true;
-		mss = priv->rollup;
-		if (mss->first) {
-			mss->first_vma_start = vma->vm_start;
-			mss->first = false;
-		}
-		last_vma = !m_next_vma(priv, vma);
-	} else {
-		rollup_mode = false;
-		memset(&mss_stack, 0, sizeof(mss_stack));
-		mss = &mss_stack;
-	}
 
 	smaps_walk.private = mss;
 
@@ -765,6 +743,35 @@ static int show_smap(struct seq_file *m, void *v)
 	walk_page_vma(vma, &smaps_walk);
 	if (vma->vm_flags & VM_LOCKED)
 		mss->pss_locked += mss->pss;
+}
+
+#define SEQ_PUT_DEC(str, val) \
+		seq_put_decimal_ull_width(m, str, (val) >> 10, 8)
+static int show_smap(struct seq_file *m, void *v)
+{
+	struct proc_maps_private *priv = m->private;
+	struct vm_area_struct *vma = v;
+	struct mem_size_stats mss_stack;
+	struct mem_size_stats *mss;
+	int ret = 0;
+	bool rollup_mode;
+	bool last_vma;
+
+	if (priv->rollup) {
+		rollup_mode = true;
+		mss = priv->rollup;
+		if (mss->first) {
+			mss->first_vma_start = vma->vm_start;
+			mss->first = false;
+		}
+		last_vma = !m_next_vma(priv, vma);
+	} else {
+		rollup_mode = false;
+		memset(&mss_stack, 0, sizeof(mss_stack));
+		mss = &mss_stack;
+	}
+
+	smap_gather_stats(vma, mss);
 
 	if (!rollup_mode) {
 		show_map_vma(m, vma);
-- 
2.18.0
