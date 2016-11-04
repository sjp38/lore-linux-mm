Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B16076B0346
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 11:43:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l124so19562784wml.4
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:43:14 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id fa19si15799072wjc.225.2016.11.04.08.43.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 08:43:13 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id a197so59068583wmd.0
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 08:43:13 -0700 (PDT)
From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH] mm: kmemleak: scan .data.ro_after_init
Date: Fri,  4 Nov 2016 15:42:53 +0000
Message-Id: <1478274173-15218-1-git-send-email-jakub.kicinski@netronome.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Johannes Berg <johannes@sipsolutions.net>, Jakub Kicinski <jakub.kicinski@netronome.com>

Limit number of kmemleak's false positives by including
.data.ro_after_init in memory scanning.  To achieve this we need to add
symbols for start and end of the section to the linker scripts.

The problem has been uncovered by commit 56989f6d8568 ("genetlink: mark
families as __ro_after_init").

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
Since the RFC I dropped the use of VMLINUX_SYMBOL().  Please advise if it
should be added back.
---
 arch/s390/kernel/vmlinux.lds.S    | 2 ++
 include/asm-generic/sections.h    | 3 +++
 include/asm-generic/vmlinux.lds.h | 5 ++++-
 mm/kmemleak.c                     | 1 +
 4 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 000e6e91f6a0..3667d20e997f 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -62,9 +62,11 @@ SECTIONS
 
 	. = ALIGN(PAGE_SIZE);
 	__start_ro_after_init = .;
+	__start_data_ro_after_init = .;
 	.data..ro_after_init : {
 		 *(.data..ro_after_init)
 	}
+	__end_data_ro_after_init = .;
 	EXCEPTION_TABLE(16)
 	. = ALIGN(PAGE_SIZE);
 	__end_ro_after_init = .;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index af0254c09424..4df64a1fc09e 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -14,6 +14,8 @@
  * [_sdata, _edata]: contains .data.* sections, may also contain .rodata.*
  *                   and/or .init.* sections.
  * [__start_rodata, __end_rodata]: contains .rodata.* sections
+ * [__start_data_ro_after_init, __end_data_ro_after_init]:
+ *		     contains data.ro_after_init section
  * [__init_begin, __init_end]: contains .init.* sections, but .init.text.*
  *                   may be out of this range on some architectures.
  * [_sinittext, _einittext]: contains .init.text.* sections
@@ -31,6 +33,7 @@
 extern char __bss_start[], __bss_stop[];
 extern char __init_begin[], __init_end[];
 extern char _sinittext[], _einittext[];
+extern char __start_data_ro_after_init[], __end_data_ro_after_init[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
 extern char __kprobes_text_start[], __kprobes_text_end[];
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 30747960bc54..31e1d639abed 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -259,7 +259,10 @@
  * own by defining an empty RO_AFTER_INIT_DATA.
  */
 #ifndef RO_AFTER_INIT_DATA
-#define RO_AFTER_INIT_DATA *(.data..ro_after_init)
+#define RO_AFTER_INIT_DATA						\
+	__start_data_ro_after_init = .;					\
+	*(.data..ro_after_init)						\
+	__end_data_ro_after_init = .;
 #endif
 
 /*
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index e5355a5b423f..d1380ed93fdf 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1414,6 +1414,7 @@ static void kmemleak_scan(void)
 	/* data/bss scanning */
 	scan_large_block(_sdata, _edata);
 	scan_large_block(__bss_start, __bss_stop);
+	scan_large_block(__start_data_ro_after_init, __end_data_ro_after_init);
 
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
