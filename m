Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 61C0C6B0390
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 15:22:16 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q189so75843109pgq.17
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 12:22:16 -0700 (PDT)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id i16si1059485pfi.100.2017.03.27.12.22.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 12:22:15 -0700 (PDT)
Received: by mail-pg0-x22a.google.com with SMTP id g2so48891574pge.3
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 12:22:15 -0700 (PDT)
Date: Mon, 27 Mar 2017 12:22:13 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] mm: fix section name for .data..ro_after_init
Message-ID: <20170327192213.GA129375@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@mellanox.com>, Jakub Kicinski <jakub.kicinski@netronome.com>, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Eddie Kovsky <ewk@edkovsky.org>, linux-kernel@vger.kernel.org

A section name for .data..ro_after_init was added by both:

    commit d07a980c1b8d ("s390: add proper __ro_after_init support")

and

    commit d7c19b066dcf ("mm: kmemleak: scan .data.ro_after_init")

The latter adds incorrect wrapping around the existing s390 section,
and came later. I'd prefer the s390 naming, so this moves the
s390-specific name up to the asm-generic/sections.h and renames the
section as used by kmemleak (and in the future, kernel/extable.c).

Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Eddie Kovsky <ewk@edkovsky.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/s390/include/asm/sections.h  | 1 -
 arch/s390/kernel/vmlinux.lds.S    | 2 --
 include/asm-generic/sections.h    | 6 +++---
 include/asm-generic/vmlinux.lds.h | 4 ++--
 mm/kmemleak.c                     | 2 +-
 5 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/s390/include/asm/sections.h b/arch/s390/include/asm/sections.h
index 5ce29fe100ba..fbd9116eb17b 100644
--- a/arch/s390/include/asm/sections.h
+++ b/arch/s390/include/asm/sections.h
@@ -4,6 +4,5 @@
 #include <asm-generic/sections.h>
 
 extern char _eshared[], _ehead[];
-extern char __start_ro_after_init[], __end_ro_after_init[];
 
 #endif
diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 5ccf95396251..72307f108c40 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -63,11 +63,9 @@ SECTIONS
 
 	. = ALIGN(PAGE_SIZE);
 	__start_ro_after_init = .;
-	__start_data_ro_after_init = .;
 	.data..ro_after_init : {
 		 *(.data..ro_after_init)
 	}
-	__end_data_ro_after_init = .;
 	EXCEPTION_TABLE(16)
 	. = ALIGN(PAGE_SIZE);
 	__end_ro_after_init = .;
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index 4df64a1fc09e..532372c6cf15 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -14,8 +14,8 @@
  * [_sdata, _edata]: contains .data.* sections, may also contain .rodata.*
  *                   and/or .init.* sections.
  * [__start_rodata, __end_rodata]: contains .rodata.* sections
- * [__start_data_ro_after_init, __end_data_ro_after_init]:
- *		     contains data.ro_after_init section
+ * [__start_ro_after_init, __end_ro_after_init]:
+ *		     contains .data..ro_after_init section
  * [__init_begin, __init_end]: contains .init.* sections, but .init.text.*
  *                   may be out of this range on some architectures.
  * [_sinittext, _einittext]: contains .init.text.* sections
@@ -33,7 +33,7 @@ extern char _data[], _sdata[], _edata[];
 extern char __bss_start[], __bss_stop[];
 extern char __init_begin[], __init_end[];
 extern char _sinittext[], _einittext[];
-extern char __start_data_ro_after_init[], __end_data_ro_after_init[];
+extern char __start_ro_after_init[], __end_ro_after_init[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
 extern char __kprobes_text_start[], __kprobes_text_end[];
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index 0968d13b3885..f9f21e2c59f3 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -260,9 +260,9 @@
  */
 #ifndef RO_AFTER_INIT_DATA
 #define RO_AFTER_INIT_DATA						\
-	__start_data_ro_after_init = .;					\
+	__start_ro_after_init = .;					\
 	*(.data..ro_after_init)						\
-	__end_data_ro_after_init = .;
+	__end_ro_after_init = .;
 #endif
 
 /*
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 26c874e90b12..20036d4f9f13 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1416,7 +1416,7 @@ static void kmemleak_scan(void)
 	/* data/bss scanning */
 	scan_large_block(_sdata, _edata);
 	scan_large_block(__bss_start, __bss_stop);
-	scan_large_block(__start_data_ro_after_init, __end_data_ro_after_init);
+	scan_large_block(__start_ro_after_init, __end_ro_after_init);
 
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
