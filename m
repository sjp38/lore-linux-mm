From: Marc-Christian Petersen <m.c.p@gmx.net>
Subject: Re: Can I change the kernel memory spliting in linux-2.4.25 + ?
Date: Sun, 5 Dec 2004 17:01:43 +0100
References: <20041204185319.97207.qmail@web53905.mail.yahoo.com>
In-Reply-To: <20041204185319.97207.qmail@web53905.mail.yahoo.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200412051701.44017@WOLK>
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_oDzsBxkC79eX10x"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org
Cc: Fawad Lateef <fawad_lateef@yahoo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--Boundary-00=_oDzsBxkC79eX10x
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Saturday 04 December 2004 19:53, Fawad Lateef wrote:

> Can I change the kernel memory spliting in
> linux-2.4.25 or onwards ??? Actually I want to change
> the kernel ZONE_NORMAL to 2GB from 1GB !!!!

sure you can :p


> How can i do this ??? I won't be able to see any
> option in kernel configuration ...........

because 2.4 does not have such options nor you wrote some in there ;)


> I tried to change the PAGE_OFFSET from 3G to 2G but
> got compilation error ..............
> What I hav to do ???

you may give attached patch a try.

-- 
ciao, Marc

--Boundary-00=_oDzsBxkC79eX10x
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="2.4.25-memsplit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="2.4.25-memsplit.patch"

diff -Naurp linux-2.4.25/Documentation/Configure.help linux-2.4.25-memsplit/Documentation/Configure.help
--- linux-2.4.25/Documentation/Configure.help	2004-12-05 16:54:12.000000000 +0100
+++ linux-2.4.25-memsplit/Documentation/Configure.help	2004-12-05 17:00:41.000000000 +0100
@@ -406,6 +406,40 @@ CONFIG_HIGHMEM64G
   Select this if you have a 32-bit processor and more than 4
   gigabytes of physical RAM.
 
+User address space size
+CONFIG_05GB
+  If you have 4 Gigabytes of physical memory or less, you can change
+  where the kernel maps high memory.
+
+  Typically there will 128 megabytes less "user memory" mapped
+  than the number in the configuration option. Saying that
+  another way, "high memory" will usually start 128 megabytes
+  lower than the configuration option.
+
+  Selecting "05GB" results in a "3.5GB/0.5GB" kernel/user split.
+  On a system with 1 gigabyte of physical memory, you may get 384
+  megabytes of "user memory" and 640 megabytes of "high memory"
+  with this selection.
+
+  Selecting "1GB" results in a "3GB/1GB" kernel/user split.
+  On a system with 1 gigabyte of memory, you may get 896 MB of
+  "user memory" and 128 megabytes of "high memory" with this
+  selection. This is the usual setting.
+
+  Selecting "2GB" results in a "2GB/2GB" kernel/user split.
+  On a system with less than 1.75 gigabytes of physical memory,
+  this option will make it so no memory is mapped as "high".
+
+  Selecting "3GB" results in a "1GB/3GB" kernel/user split.
+
+  Select "1GB" otherwise Win4Lin and valgrind won't work!
+
+  Select "Real-1GB" to allocate even the last 128MB of RAM which
+  are normally mapped as high, but with this option mapped as low
+  without the need for enabling high memory support.
+
+  If unsure, say "1GB".
+
 HIGHMEM I/O support
 CONFIG_HIGHIO
   If you want to be able to do I/O to high memory pages, say Y.
diff -Naurp linux-2.4.25/Rules.make linux-2.4.25-memsplit/Rules.make
--- linux-2.4.25/Rules.make	2004-02-18 14:36:30.000000000 +0100
+++ linux-2.4.25-memsplit/Rules.make	2004-12-05 16:56:55.000000000 +0100
@@ -215,6 +215,7 @@ MODINCL = $(TOPDIR)/include/linux/module
 #
 # Added the SMP separator to stop module accidents between uniprocessor
 # and SMP Intel boxes - AC - from bits by Michael Chastain
+# Added separator for different PAGE_OFFSET memory models - Ingo.
 #
 
 ifdef CONFIG_SMP
@@ -223,6 +224,22 @@ else
 	genksyms_smp_prefix := 
 endif
 
+ifdef CONFIG_2GB
+ifdef CONFIG_SMP
+	genksyms_smp_prefix := -p smp_2gig_
+else
+	genksyms_smp_prefix := -p 2gig_
+endif
+endif
+
+ifdef CONFIG_3GB
+ifdef CONFIG_SMP
+	genksyms_smp_prefix := -p smp_3gig_
+else
+	genksyms_smp_prefix := -p 3gig_
+endif
+endif
+
 $(MODINCL)/%.ver: %.c
 	@if [ ! -r $(MODINCL)/$*.stamp -o $(MODINCL)/$*.stamp -ot $< ]; then \
 		echo '$(CC) $(CFLAGS) $(EXTRA_CFLAGS_nostdinc) -E -D__GENKSYMS__ $<'; \
diff -Naurp linux-2.4.25/arch/i386/Makefile linux-2.4.25-memsplit/arch/i386/Makefile
--- linux-2.4.25/arch/i386/Makefile	2003-06-13 16:51:29.000000000 +0200
+++ linux-2.4.25-memsplit/arch/i386/Makefile	2004-12-05 16:56:55.000000000 +0100
@@ -114,6 +114,9 @@ arch/i386/mm: dummy
 
 MAKEBOOT = $(MAKE) -C arch/$(ARCH)/boot
 
+arch/i386/vmlinux.lds: arch/i386/vmlinux.lds.S FORCE
+	$(CPP) -C -P -I$(HPATH) -imacros $(HPATH)/asm-i386/page_offset.h -Ui386 arch/i386/vmlinux.lds.S >arch/i386/vmlinux.lds
+
 vmlinux: arch/i386/vmlinux.lds
 
 FORCE: ;
@@ -150,6 +153,7 @@ archclean:
 	@$(MAKEBOOT) clean
 
 archmrproper:
+	rm -f arch/i386/vmlinux.lds
 
 archdep:
 	@$(MAKEBOOT) dep
diff -Naurp linux-2.4.25/arch/i386/config.in linux-2.4.25-memsplit/arch/i386/config.in
--- linux-2.4.25/arch/i386/config.in	2004-02-18 14:36:30.000000000 +0100
+++ linux-2.4.25-memsplit/arch/i386/config.in	2004-12-05 17:00:40.000000000 +0100
@@ -216,6 +216,18 @@ else
 fi
 if [ "$CONFIG_HIGHMEM64G" = "y" ]; then
    define_bool CONFIG_X86_PAE y
+   choice 'User address space size' \
+	"3GB		CONFIG_1GB \
+	 2GB		CONFIG_2GB \
+	 Real-1GB	CONFIG_1GB_REAL \
+	 1GB		CONFIG_3GB" 3GB
+else
+   choice 'User address space size' \
+	"3GB		CONFIG_1GB \
+	 2GB		CONFIG_2GB \
+	 1GB		CONFIG_3GB \
+	 Real-1GB	CONFIG_1GB_REAL \
+	 3.5GB		CONFIG_05GB" 3GB
 fi
 
 if [ "$CONFIG_HIGHMEM" = "y" ]; then
diff -Naurp linux-2.4.25/arch/i386/vmlinux.lds linux-2.4.25-memsplit/arch/i386/vmlinux.lds
--- linux-2.4.25/arch/i386/vmlinux.lds	2002-02-25 20:37:53.000000000 +0100
+++ linux-2.4.25-memsplit/arch/i386/vmlinux.lds	1970-01-01 01:00:00.000000000 +0100
@@ -1,82 +0,0 @@
-/* ld script to make i386 Linux kernel
- * Written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>;
- */
-OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
-OUTPUT_ARCH(i386)
-ENTRY(_start)
-SECTIONS
-{
-  . = 0xC0000000 + 0x100000;
-  _text = .;			/* Text and read-only data */
-  .text : {
-	*(.text)
-	*(.fixup)
-	*(.gnu.warning)
-	} = 0x9090
-
-  _etext = .;			/* End of text section */
-
-  .rodata : { *(.rodata) *(.rodata.*) }
-  .kstrtab : { *(.kstrtab) }
-
-  . = ALIGN(16);		/* Exception table */
-  __start___ex_table = .;
-  __ex_table : { *(__ex_table) }
-  __stop___ex_table = .;
-
-  __start___ksymtab = .;	/* Kernel symbol table */
-  __ksymtab : { *(__ksymtab) }
-  __stop___ksymtab = .;
-
-  .data : {			/* Data */
-	*(.data)
-	CONSTRUCTORS
-	}
-
-  _edata = .;			/* End of data section */
-
-  . = ALIGN(8192);		/* init_task */
-  .data.init_task : { *(.data.init_task) }
-
-  . = ALIGN(4096);		/* Init code and data */
-  __init_begin = .;
-  .text.init : { *(.text.init) }
-  .data.init : { *(.data.init) }
-  . = ALIGN(16);
-  __setup_start = .;
-  .setup.init : { *(.setup.init) }
-  __setup_end = .;
-  __initcall_start = .;
-  .initcall.init : { *(.initcall.init) }
-  __initcall_end = .;
-  . = ALIGN(4096);
-  __init_end = .;
-
-  . = ALIGN(4096);
-  .data.page_aligned : { *(.data.idt) }
-
-  . = ALIGN(32);
-  .data.cacheline_aligned : { *(.data.cacheline_aligned) }
-
-  __bss_start = .;		/* BSS */
-  .bss : {
-	*(.bss)
-	}
-  _end = . ;
-
-  /* Sections to be discarded */
-  /DISCARD/ : {
-	*(.text.exit)
-	*(.data.exit)
-	*(.exitcall.exit)
-	}
-
-  /* Stabs debugging sections.  */
-  .stab 0 : { *(.stab) }
-  .stabstr 0 : { *(.stabstr) }
-  .stab.excl 0 : { *(.stab.excl) }
-  .stab.exclstr 0 : { *(.stab.exclstr) }
-  .stab.index 0 : { *(.stab.index) }
-  .stab.indexstr 0 : { *(.stab.indexstr) }
-  .comment 0 : { *(.comment) }
-}
diff -Naurp linux-2.4.25/arch/i386/vmlinux.lds.S linux-2.4.25-memsplit/arch/i386/vmlinux.lds.S
--- linux-2.4.25/arch/i386/vmlinux.lds.S	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.4.25-memsplit/arch/i386/vmlinux.lds.S	2004-12-05 16:56:55.000000000 +0100
@@ -0,0 +1,82 @@
+/* ld script to make i386 Linux kernel
+ * Written by Martin Mares <mj@atrey.karlin.mff.cuni.cz>;
+ */
+OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
+OUTPUT_ARCH(i386)
+ENTRY(_start)
+SECTIONS
+{
+  . = PAGE_OFFSET_RAW + 0x100000;
+  _text = .;			/* Text and read-only data */
+  .text : {
+	*(.text)
+	*(.fixup)
+	*(.gnu.warning)
+	} = 0x9090
+
+  _etext = .;			/* End of text section */
+
+  .rodata : { *(.rodata) *(.rodata.*) }
+  .kstrtab : { *(.kstrtab) }
+
+  . = ALIGN(16);		/* Exception table */
+  __start___ex_table = .;
+  __ex_table : { *(__ex_table) }
+  __stop___ex_table = .;
+
+  __start___ksymtab = .;	/* Kernel symbol table */
+  __ksymtab : { *(__ksymtab) }
+  __stop___ksymtab = .;
+
+  .data : {			/* Data */
+	*(.data)
+	CONSTRUCTORS
+	}
+
+  _edata = .;			/* End of data section */
+
+  . = ALIGN(8192);		/* init_task */
+  .data.init_task : { *(.data.init_task) }
+
+  . = ALIGN(4096);		/* Init code and data */
+  __init_begin = .;
+  .text.init : { *(.text.init) }
+  .data.init : { *(.data.init) }
+  . = ALIGN(16);
+  __setup_start = .;
+  .setup.init : { *(.setup.init) }
+  __setup_end = .;
+  __initcall_start = .;
+  .initcall.init : { *(.initcall.init) }
+  __initcall_end = .;
+  . = ALIGN(4096);
+  __init_end = .;
+
+  . = ALIGN(4096);
+  .data.page_aligned : { *(.data.idt) }
+
+  . = ALIGN(32);
+  .data.cacheline_aligned : { *(.data.cacheline_aligned) }
+
+  __bss_start = .;		/* BSS */
+  .bss : {
+	*(.bss)
+	}
+  _end = . ;
+
+  /* Sections to be discarded */
+  /DISCARD/ : {
+	*(.text.exit)
+	*(.data.exit)
+	*(.exitcall.exit)
+	}
+
+  /* Stabs debugging sections.  */
+  .stab 0 : { *(.stab) }
+  .stabstr 0 : { *(.stabstr) }
+  .stab.excl 0 : { *(.stab.excl) }
+  .stab.exclstr 0 : { *(.stab.exclstr) }
+  .stab.index 0 : { *(.stab.index) }
+  .stab.indexstr 0 : { *(.stab.indexstr) }
+  .comment 0 : { *(.comment) }
+}
diff -Naurp linux-2.4.25/include/asm-i386/page.h linux-2.4.25-memsplit/include/asm-i386/page.h
--- linux-2.4.25/include/asm-i386/page.h	2002-08-03 02:39:45.000000000 +0200
+++ linux-2.4.25-memsplit/include/asm-i386/page.h	2004-12-05 16:56:55.000000000 +0100
@@ -78,7 +78,9 @@ typedef struct { unsigned long pgprot; }
  * and CONFIG_HIGHMEM64G options in the kernel configuration.
  */
 
-#define __PAGE_OFFSET		(0xC0000000)
+#include <asm/page_offset.h>
+
+#define __PAGE_OFFSET		(PAGE_OFFSET_RAW)
 
 /*
  * This much address space is reserved for vmalloc() and iomap()
diff -Naurp linux-2.4.25/include/asm-i386/page_offset.h linux-2.4.25-memsplit/include/asm-i386/page_offset.h
--- linux-2.4.25/include/asm-i386/page_offset.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.4.25-memsplit/include/asm-i386/page_offset.h	2004-12-05 17:00:40.000000000 +0100
@@ -0,0 +1,12 @@
+#include <linux/config.h>
+#ifdef CONFIG_05GB
+# define PAGE_OFFSET_RAW	0xE0000000
+#elif defined(CONFIG_1GB)
+# define PAGE_OFFSET_RAW	0xC0000000
+#elif defined(CONFIG_1GB_REAL)
+# define PAGE_OFFSET_RAW	0xB0000000
+#elif defined(CONFIG_2GB)
+# define PAGE_OFFSET_RAW	0x80000000
+#elif defined(CONFIG_3GB)
+# define PAGE_OFFSET_RAW	0x40000000
+#endif
diff -Naurp linux-2.4.25/include/asm-i386/processor.h linux-2.4.25-memsplit/include/asm-i386/processor.h
--- linux-2.4.25/include/asm-i386/processor.h	2004-02-18 14:36:32.000000000 +0100
+++ linux-2.4.25-memsplit/include/asm-i386/processor.h	2004-12-05 16:56:55.000000000 +0100
@@ -264,7 +264,11 @@ extern unsigned int mca_pentium_flag;
 /* This decides where the kernel will search for a free chunk of vm
  * space during mmap's.
  */
+#ifndef CONFIG_05GB
 #define TASK_UNMAPPED_BASE	(TASK_SIZE / 3)
+#else
+#define TASK_UNMAPPED_BASE	(TASK_SIZE / 16)
+#endif
 
 /*
  * Size of io_bitmap in longwords: 32 is ports 0-0x3ff.
diff -Naurp linux-2.4.25/mm/memory.c linux-2.4.25-memsplit/mm/memory.c
--- linux-2.4.25/mm/memory.c	2003-11-28 19:26:21.000000000 +0100
+++ linux-2.4.25-memsplit/mm/memory.c	2004-12-05 16:56:55.000000000 +0100
@@ -108,8 +108,7 @@ static inline void free_one_pmd(pmd_t * 
 
 static inline void free_one_pgd(pgd_t * dir)
 {
-	int j;
-	pmd_t * pmd;
+	pmd_t * pmd, * md, * emd;
 
 	if (pgd_none(*dir))
 		return;
@@ -120,9 +119,23 @@ static inline void free_one_pgd(pgd_t * 
 	}
 	pmd = pmd_offset(dir, 0);
 	pgd_clear(dir);
-	for (j = 0; j < PTRS_PER_PMD ; j++) {
-		prefetchw(pmd+j+(PREFETCH_STRIDE/16));
-		free_one_pmd(pmd+j);
+
+	/*
+	 * Beware if changing the loop below.  It once used int j,
+	 *	for (j = 0; j < PTRS_PER_PMD; j++)
+	 *		free_one_pmd(pmd+j);
+	 * but some older i386 compilers (e.g. egcs-2.91.66, gcc-2.95.3)
+	 * terminated the loop with a _signed_ address comparison
+	 * using "jle", when configured for HIGHMEM64GB (X86_PAE).
+	 * If also configured for 3GB of kernel virtual address space,
+	 * if page at physical 0x3ffff000 virtual 0x7ffff000 is used as
+	 * a pmd, when that mm exits the loop goes on to free "entries"
+	 * found at 0x80000000 onwards.  The loop below compiles instead
+	 * to be terminated by unsigned address comparison using "jb".
+	 */
+	for (md = pmd, emd = pmd + PTRS_PER_PMD; md < emd; md++) {
+		prefetchw(md+(PREFETCH_STRIDE/16));
+		free_one_pmd(md);
 	}
 	pmd_free(pmd);
 }

--Boundary-00=_oDzsBxkC79eX10x--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
