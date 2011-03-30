Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7417C8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 06:08:50 -0400 (EDT)
Received: by qyk30 with SMTP id 30so974269qyk.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 03:08:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	<AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	<1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	<1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	<1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	<AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	<AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
	<1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
Date: Wed, 30 Mar 2011 11:08:48 +0100
Message-ID: <AANLkTim9+kQYSKXRbkOPArJ63jTxvjkFg=AEywr5meNN@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Maxin John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,

> If you for the kmemleak scan (via echo) a few times, do you get more
> leaks?

Yes. I am getting some leaks after the scan.

> The udp_table_init() function looks like it could leak some
> memory but I haven't seen it before. I'm not sure whether this is a
> false positive or a real leak.

As Daniel suggested, this could be a real leak . However, we need to
confirm this.

 udp_table_init() -> alloc_large_system_hash() ->  alloc_pages_exact()
followed by  kmemleak_alloc()

> I think the last line should be more like:

As per your suggestion, I have modified the patch.

Signed-off-by: Maxin B. John <maxin.john@gmail.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
diff --git a/arch/mips/include/asm/cache.h b/arch/mips/include/asm/cache.h
index 650ac9b..b4db69f 100644
--- a/arch/mips/include/asm/cache.h
+++ b/arch/mips/include/asm/cache.h
@@ -17,6 +17,6 @@
 #define SMP_CACHE_SHIFT                L1_CACHE_SHIFT
 #define SMP_CACHE_BYTES                L1_CACHE_BYTES

-#define __read_mostly __attribute__((__section__(".data.read_mostly")))
+#define __read_mostly __attribute__((__section__(".data..read_mostly")))

 #endif /* _ASM_CACHE_H */
diff --git a/arch/mips/kernel/vmlinux.lds.S b/arch/mips/kernel/vmlinux.lds.S
index 832afbb..4f10141 100644
--- a/arch/mips/kernel/vmlinux.lds.S
+++ b/arch/mips/kernel/vmlinux.lds.S
@@ -68,12 +68,14 @@ SECTIONS
        RODATA

        /* writeable */
+       _sdata = .;                  /* Start of data section */
        .data : {       /* Data */
                . = . + DATAOFFSET;             /* for CONFIG_MAPPED_KERNEL */

                INIT_TASK_DATA(PAGE_SIZE)
                NOSAVE_DATA
                CACHELINE_ALIGNED_DATA(1 << CONFIG_MIPS_L1_CACHE_SHIFT)
+               READ_MOSTLY_DATA(1 << CONFIG_MIPS_L1_CACHE_SHIFT)
                DATA_DATA
                CONSTRUCTORS
        }
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index df9234c..5042421 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -398,7 +398,7 @@ config SLUB_STATS
 config DEBUG_KMEMLEAK
        bool "Kernel memory leak detector"
        depends on DEBUG_KERNEL && EXPERIMENTAL && !MEMORY_HOTPLUG && \
-               (X86 || ARM || PPC || S390 || SPARC64 || SUPERH ||
MICROBLAZE || TILE)
+               (X86 || ARM || PPC || MIPS || S390 || SPARC64 ||
SUPERH || MICROBLAZE || TILE)

        select DEBUG_FS if SYSFS
        select STACKTRACE if STACKTRACE_SUPPORT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
