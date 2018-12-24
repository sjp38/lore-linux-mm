Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 217828E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 16:03:44 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n45so16734450qta.5
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 13:03:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s28sor20841840qtb.48.2018.12.24.13.03.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 13:03:43 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH -mmotm] arm64: fix build for MAX_USER_VA_BITS
Date: Mon, 24 Dec 2018 16:03:12 -0500
Message-Id: <20181224210312.56539-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Some code in 9b31cf493ff was lost during merging into the -mmotm tree
for some reasons,

In file included from ./arch/arm64/include/asm/processor.h:46,
                 from ./include/linux/rcupdate.h:43,
                 from ./include/linux/rculist.h:11,
                 from ./include/linux/pid.h:5,
                 from ./include/linux/sched.h:14,
		 from arch/arm64/kernel/asm-offsets.c:22:
./arch/arm64/include/asm/pgtable-hwdef.h:83:30: error:
'MAX_USER_VA_BITS' undeclared here (not in a function); did you mean
'MAX_USER_PRIO'?
 #define PTRS_PER_PGD  (1 << (MAX_USER_VA_BITS - PGDIR_SHIFT))
                              ^~~~~~~~~~~~~~~~
./arch/arm64/include/asm/pgtable.h:442:26: note: in expansion of macro
'PTRS_PER_PGD'
 extern pgd_t init_pg_dir[PTRS_PER_PGD];
                          ^~~~~~~~~~~~

Signed-off-by: Qian Cai <cai@lca.pw>
---
 arch/arm64/include/asm/memory.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index 1df0bb19117f..e1ec947e7c0c 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -67,6 +67,12 @@
 #define KERNEL_START      _text
 #define KERNEL_END        _end
 
+#ifdef CONFIG_ARM64_USER_VA_BITS_52
+#define MAX_USER_VA_BITS	52
+#else
+#define MAX_USER_VA_BITS	VA_BITS
+#endif
+
 /*
  * Generic and tag-based KASAN require 1/8th and 1/16th of the kernel virtual
  * address space for the shadow region respectively. They can bloat the stack
-- 
2.17.2 (Apple Git-113)
