Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0B396B0006
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:40:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so5700442plf.18
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:40:44 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id t1-v6si9195915pgn.42.2018.06.29.15.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 15:40:43 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v3 PATCH 1/5] uprobes: make vma_has_uprobes non-static
Date: Sat, 30 Jun 2018 06:39:41 +0800
Message-Id: <1530311985-31251-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

vma_has_uprobes() will be used in the following patch to check if a vma
could be unmapped with holding read mmap_sem, but it is static. So, make
it non-static to use outside uprobe.

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Jiri Olsa <jolsa@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/uprobes.h | 7 +++++++
 kernel/events/uprobes.c | 2 +-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 0a294e9..7f1fb8c 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -149,6 +149,8 @@ struct uprobes_state {
 extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
 extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
 					 void *src, unsigned long len);
+extern bool vma_has_uprobes(struct vm_area_struct *vma, unsigned long start,
+			    unsigned long end);
 #else /* !CONFIG_UPROBES */
 struct uprobes_state {
 };
@@ -203,5 +205,10 @@ static inline void uprobe_copy_process(struct task_struct *t, unsigned long flag
 static inline void uprobe_clear_state(struct mm_struct *mm)
 {
 }
+static inline bool vma_has_uprobes(struct vm_area_struct *vma, unsigned long,
+				   unsigned long end)
+{
+	return false;
+}
 #endif /* !CONFIG_UPROBES */
 #endif	/* _LINUX_UPROBES_H */
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ccc579a..4880c46 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1095,7 +1095,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	return 0;
 }
 
-static bool
+bool
 vma_has_uprobes(struct vm_area_struct *vma, unsigned long start, unsigned long end)
 {
 	loff_t min, max;
-- 
1.8.3.1
