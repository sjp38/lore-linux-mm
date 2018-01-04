Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 81145280256
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 07:29:05 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id e70so813895wmc.6
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 04:29:05 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [146.0.238.70])
        by mx.google.com with ESMTPS id k40si2477306wrf.22.2018.01.04.04.29.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Jan 2018 04:29:03 -0800 (PST)
Date: Thu, 4 Jan 2018 13:28:59 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509
 certs
In-Reply-To: <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1801041320360.1771@nanos>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180104003303.GA1654@trogon.sfo.coreos.systems> <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
 <CAD3Vwcptxyf+QJO7snZs_-MHGV3ARmLeaFVR49jKM=6MAGMk7Q@mail.gmail.com> <CALCETrW8NxLd4v_U_g8JyW5XdVXWhM_MZOUn05J8VTuWOwkj-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable <stable@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Garnier <thgarnie@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>

On Wed, 3 Jan 2018, Andy Lutomirski wrote:
> On Wed, Jan 3, 2018 at 8:35 PM, Benjamin Gilbert
> <benjamin.gilbert@coreos.com> wrote:
> > On Wed, Jan 03, 2018 at 04:37:53PM -0800, Andy Lutomirski wrote:
> >> Maybe try rebuilding a bad kernel with free_ldt_pgtables() modified
> >> to do nothing, and the read /sys/kernel/debug/page_tables/current (or
> >> current_kernel, or whatever it's called).  The problem may be obvious.
> >
> > current_kernel attached.  I have not seen any crashes with
> > free_ldt_pgtables() stubbed out.
> 
> I haven't reproduced it, but I think I see what's wrong.  KASLR sets
> vaddr_end to a totally bogus value.  It should be no larger than
> LDT_BASE_ADDR.  I suspect that your vmemmap is getting randomized into
> the LDT range.  If it weren't for that, it could just as easily land
> in the cpu_entry_area range.  This will need fixing in all versions
> that aren't still called KAISER.
> 
> Our memory map code is utter shite.  This kind of bug should not be
> possible without a giant warning at boot that something is screwed up.

You're right it's utter shite and the KASLR folks who added this insanity
of making vaddr_end depend on a gazillion of config options and not
documenting it in mm.txt or elsewhere where it's obvious to find should
really sit back and think hard about their half baken 'security' features.

Just look at the insanity of comment above the vaddr_end ifdef maze.

Benjamin, can you test the patch below please?

Thanks,

	tglx

8<--------------
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -12,8 +12,9 @@ ffffea0000000000 - ffffeaffffffffff (=40
 ... unused hole ...
 ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
 ... unused hole ...
-fffffe0000000000 - fffffe7fffffffff (=39 bits) LDT remap for PTI
-fffffe8000000000 - fffffeffffffffff (=39 bits) cpu_entry_area mapping
+				    vaddr_end for KASLR 
+fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
+fffffe8000000000 - fffffeffffffffff (=39 bits) LDT remap for PTI
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
 ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
@@ -37,7 +38,9 @@ ffd4000000000000 - ffd5ffffffffffff (=49
 ... unused hole ...
 ffdf000000000000 - fffffc0000000000 (=53 bits) kasan shadow memory (8PB)
 ... unused hole ...
-fffffe8000000000 - fffffeffffffffff (=39 bits) cpu_entry_area mapping
+				    vaddr_end for KASLR 
+fffffe0000000000 - fffffe7fffffffff (=39 bits) cpu_entry_area mapping
+... unused hole ...
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
 ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -88,7 +88,7 @@ typedef struct { pteval_t pte; } pte_t;
 # define VMALLOC_SIZE_TB	_AC(32, UL)
 # define __VMALLOC_BASE		_AC(0xffffc90000000000, UL)
 # define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
-# define LDT_PGD_ENTRY		_AC(-4, UL)
+# define LDT_PGD_ENTRY		_AC(-3, UL)
 # define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 #endif
 
@@ -110,7 +110,7 @@ typedef struct { pteval_t pte; } pte_t;
 #define ESPFIX_PGD_ENTRY	_AC(-2, UL)
 #define ESPFIX_BASE_ADDR	(ESPFIX_PGD_ENTRY << P4D_SHIFT)
 
-#define CPU_ENTRY_AREA_PGD	_AC(-3, UL)
+#define CPU_ENTRY_AREA_PGD	_AC(-4, UL)
 #define CPU_ENTRY_AREA_BASE	(CPU_ENTRY_AREA_PGD << P4D_SHIFT)
 
 #define EFI_VA_START		( -4 * (_AC(1, UL) << 30))
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -34,25 +34,14 @@
 #define TB_SHIFT 40
 
 /*
- * Virtual address start and end range for randomization. The end changes base
- * on configuration to have the highest amount of space for randomization.
- * It increases the possible random position for each randomized region.
+ * Virtual address start and end range for randomization.
  *
- * You need to add an if/def entry if you introduce a new memory region
- * compatible with KASLR. Your entry must be in logical order with memory
- * layout. For example, ESPFIX is before EFI because its virtual address is
- * before. You also need to add a BUILD_BUG_ON() in kernel_randomize_memory() to
- * ensure that this order is correct and won't be changed.
+ * The end address could depend on more configuration options to make the
+ * highest amount of space for randomization available, but that's too hard
+ * to keep straight.
  */
 static const unsigned long vaddr_start = __PAGE_OFFSET_BASE;
-
-#if defined(CONFIG_X86_ESPFIX64)
-static const unsigned long vaddr_end = ESPFIX_BASE_ADDR;
-#elif defined(CONFIG_EFI)
-static const unsigned long vaddr_end = EFI_VA_END;
-#else
-static const unsigned long vaddr_end = __START_KERNEL_map;
-#endif
+static const unsigned long vaddr_end = CPU_ENTRY_AREA_BASE;
 
 /* Default values */
 unsigned long page_offset_base = __PAGE_OFFSET_BASE;
@@ -101,15 +90,11 @@ void __init kernel_randomize_memory(void
 	unsigned long remain_entropy;
 
 	/*
-	 * All these BUILD_BUG_ON checks ensures the memory layout is
-	 * consistent with the vaddr_start/vaddr_end variables.
+	 * These BUILD_BUG_ON checks ensure the memory layout is consistent
+	 * with the vaddr_start/vaddr_end variables. These checks are
+	 * limited....
 	 */
 	BUILD_BUG_ON(vaddr_start >= vaddr_end);
-	BUILD_BUG_ON(IS_ENABLED(CONFIG_X86_ESPFIX64) &&
-		     vaddr_end >= EFI_VA_END);
-	BUILD_BUG_ON((IS_ENABLED(CONFIG_X86_ESPFIX64) ||
-		      IS_ENABLED(CONFIG_EFI)) &&
-		     vaddr_end >= __START_KERNEL_map);
 	BUILD_BUG_ON(vaddr_end > __START_KERNEL_map);
 
 	if (!kaslr_memory_enabled())

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
