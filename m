Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D613C6B000C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:40:47 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id x23-v6so5731486pln.11
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 15:40:47 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id a1-v6si10452516plp.247.2018.06.29.15.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 15:40:46 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC v3 PATCH 2/5] mm: introduce VM_DEAD flag
Date: Sat, 30 Jun 2018 06:39:42 +0800
Message-Id: <1530311985-31251-3-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

VM_DEAD flag is used to mark a vma is being unmapped, access to this
area will trigger SIGSEGV.

This flag will be used by the optimization for unmapping large address
space (>= 1GB) in the later patch. It is 64 bit only at the moment,
since:
  * we used up vm_flags bit for 32 bit
  * 32 bit machine typically will not have such large mapping

All architectures, which support 64 bit, need check this flag in their
page fault handler. This is implemented in later patches.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mm.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9f..28a3906 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -242,6 +242,12 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
 #endif
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 
+#ifdef CONFIG_64BIT
+#define VM_DEAD			BIT(37)	/* bit only usable on 64 bit kernel */
+#else
+#define VM_DEAD			0
+#endif
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
-- 
1.8.3.1
