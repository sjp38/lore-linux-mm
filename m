Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9C66B6B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 00:00:34 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so84068348pab.2
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 21:00:34 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id pr9si22809997pbc.59.2015.10.11.21.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Oct 2015 21:00:33 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so17663375pab.1
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 21:00:33 -0700 (PDT)
From: yalin wang <yalin.wang2010@gmail.com>
Subject: [RFC] arm: add __initbss section attribute
Date: Mon, 12 Oct 2015 11:59:16 +0800
Message-Id: <1444622356-8263-1-git-send-email-yalin.wang2010@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, arnd@arndb.de, ard.biesheuvel@linaro.org, will.deacon@arm.com, nico@linaro.org, keescook@chromium.org, yalin.wang2010@gmail.com, catalin.marinas@arm.com, victor.kamensky@linaro.org, msalter@redhat.com, vladimir.murzin@arm.com, ggdavisiv@gmail.com, paul.gortmaker@windriver.com, mingo@kernel.org, rusty@rustcorp.com.au, mcgrof@suse.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mhocko@suse.com, jack@suse.cz, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

This attribute can make init data to be into .initbss section,
this will make the data to be NO_BITS in vmlinux, can shrink the
Image file size, and speed up the boot up time.

Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
---
 arch/arm/kernel/vmlinux.lds.S     |  2 +-
 arch/arm/mm/init.c                |  1 +
 include/asm-generic/sections.h    |  1 +
 include/asm-generic/vmlinux.lds.h | 11 ++++++++++-
 include/linux/init.h              |  1 +
 include/linux/mm.h                |  4 +++-
 6 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index 8b60fde..ad6d740 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -330,7 +330,7 @@ SECTIONS
 	}
 #endif
 
-	BSS_SECTION(0, 0, 0)
+	BSS_SECTION(0, 0, 0, 0)
 	_end = .;
 
 	STABS_DEBUG
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 8a63b4c..50b881e 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -722,6 +722,7 @@ void free_initmem(void)
 	free_tcmmem();
 
 	poison_init_mem(__init_begin, __init_end - __init_begin);
+	poison_init_mem(__initbss_start, __initbss_start - __initbss_end);
 	if (!machine_is_integrator() && !machine_is_cintegrator())
 		free_initmem_default(-1);
 }
diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
index b58fd66..a63ebe9 100644
--- a/include/asm-generic/sections.h
+++ b/include/asm-generic/sections.h
@@ -29,6 +29,7 @@ extern char _text[], _stext[], _etext[];
 extern char _data[], _sdata[], _edata[];
 extern char __bss_start[], __bss_stop[];
 extern char __init_begin[], __init_end[];
+extern char __initbss_start[], __initbss_end[];
 extern char _sinittext[], _einittext[];
 extern char _end[];
 extern char __per_cpu_load[], __per_cpu_start[], __per_cpu_end[];
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index c4bd0e2..b3db62d 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -574,6 +574,14 @@
 		*(COMMON)						\
 	}
 
+#define INITBSS(initbss_align)						\
+	. = ALIGN(initbss_align);					\
+	.initbss : AT(ADDR(.initbss) - LOAD_OFFSET) {			\
+		VMLINUX_SYMBOL(__initbss_start) = .;			\
+		*(.bss.init.data)					\
+		VMLINUX_SYMBOL(__initbss_end) = .;			\
+	}
+
 /*
  * DWARF debug sections.
  * Symbols in the DWARF debugging sections are relative to
@@ -831,10 +839,11 @@
 		INIT_RAM_FS						\
 	}
 
-#define BSS_SECTION(sbss_align, bss_align, stop_align)			\
+#define BSS_SECTION(sbss_align, bss_align, initbss_align, stop_align)			\
 	. = ALIGN(sbss_align);						\
 	VMLINUX_SYMBOL(__bss_start) = .;				\
 	SBSS(sbss_align)						\
 	BSS(bss_align)							\
+	INITBSS(initbss_align)						\
 	. = ALIGN(stop_align);						\
 	VMLINUX_SYMBOL(__bss_stop) = .;
diff --git a/include/linux/init.h b/include/linux/init.h
index b449f37..f2960b2 100644
--- a/include/linux/init.h
+++ b/include/linux/init.h
@@ -41,6 +41,7 @@
    discard it in modules) */
 #define __init		__section(.init.text) __cold notrace
 #define __initdata	__section(.init.data)
+#define __initbss	__section(.bss.init.data)
 #define __initconst	__constsection(.init.rodata)
 #define __exitdata	__section(.exit.data)
 #define __exit_call	__used __section(.exitcall.exit)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d30eea3..1f266f7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -21,6 +21,7 @@
 #include <linux/resource.h>
 #include <linux/page_ext.h>
 #include <linux/err.h>
+#include <asm/sections.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -1722,10 +1723,11 @@ static inline void mark_page_reserved(struct page *page)
  */
 static inline unsigned long free_initmem_default(int poison)
 {
-	extern char __init_begin[], __init_end[];
 
 	return free_reserved_area(&__init_begin, &__init_end,
 				  poison, "unused kernel");
+	return free_reserved_area(&__initbss_start, &__initbss_end,
+				  poison, "unused kernel");
 }
 
 static inline unsigned long get_num_physpages(void)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
