Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2576B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 19:36:44 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so3506295pgp.6
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 16:36:44 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id d191-v6si7238763pga.157.2018.08.09.16.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 16:36:42 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v7 PATCH 3/4] uprobes: make vma_has_uprobes non-static
Date: Fri, 10 Aug 2018 07:36:02 +0800
Message-Id: <1533857763-43527-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1533857763-43527-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, vbabka@suse.cz, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index 0a294e9..caeb26b 100644
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
+static inline bool vma_has_uprobes(struct vm_area_struct *vma, unsigned long start,
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
