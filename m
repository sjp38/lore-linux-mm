Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 01A946B0269
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 14:50:36 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d22-v6so924634pfn.3
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 11:50:35 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id d9-v6si20206719pgo.470.2018.08.15.11.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 11:50:34 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v8 PATCH 2/5] uprobes: introduce has_uprobes helper
Date: Thu, 16 Aug 2018 02:49:47 +0800
Message-Id: <1534358990-85530-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1534358990-85530-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We need check if mm or vma has uprobes in the following patch to check
if a vma could be unmapped with holding read mmap_sem. The checks and
pre-conditions used by uprobe_munmap() look just suitable for this
purpose.

Extracting those checks into a helper function, has_uprobes().

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/uprobes.h |  7 +++++++
 kernel/events/uprobes.c | 23 ++++++++++++++++-------
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 0a294e9..418764e 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -149,6 +149,8 @@ struct uprobes_state {
 extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
 extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
 					 void *src, unsigned long len);
+extern bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
+			unsigned long end);
 #else /* !CONFIG_UPROBES */
 struct uprobes_state {
 };
@@ -203,5 +205,10 @@ static inline void uprobe_copy_process(struct task_struct *t, unsigned long flag
 static inline void uprobe_clear_state(struct mm_struct *mm)
 {
 }
+static inline bool has_uprobes(struct vm_area_struct *vma, unsigned long start,
+			       unsgined long end)
+{
+	return false;
+}
 #endif /* !CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index aed1ba5..568481c 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1114,22 +1114,31 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	return !!n;
 }
 
-/*
- * Called in context of a munmap of a vma.
- */
-void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+bool
+has_uprobes(struct vm_area_struct *vma, unsigned long start, unsigned long end)
 {
 	if (no_uprobe_events() || !valid_vma(vma, false))
-		return;
+		return false;
 
 	if (!atomic_read(&vma->vm_mm->mm_users)) /* called by mmput() ? */
-		return;
+		return false;
 
 	if (!test_bit(MMF_HAS_UPROBES, &vma->vm_mm->flags) ||
 	     test_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags))
-		return;
+		return false;
 
 	if (vma_has_uprobes(vma, start, end))
+		return true;
+
+	return false;
+}
+
+/*
+ * Called in context of a munmap of a vma.
+ */
+void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+{
+	if (has_uprobes(vma, start, end))
 		set_bit(MMF_RECALC_UPROBES, &vma->vm_mm->flags);
 }
 
-- 
1.8.3.1
