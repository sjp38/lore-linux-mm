Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB29E6B000C
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 19:35:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y26-v6so9299632pfn.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 16:35:04 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id h1-v6si12472180pfb.70.2018.06.18.16.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 16:35:03 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v2 PATCH 1/2] uprobes: make vma_has_uprobes non-static
Date: Tue, 19 Jun 2018 07:34:15 +0800
Message-Id: <1529364856-49589-2-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org
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
index 1725b90..bd46b7a 100644
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
