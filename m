Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8706B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 06:02:56 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so1507840pbc.20
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 03:02:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id fo3si4452853pbb.76.2014.06.25.03.02.54
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 03:02:54 -0700 (PDT)
Date: Wed, 25 Jun 2014 18:02:13 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [next:master 156/212] fs/binfmt_elf.c:158:18: note: in expansion of
 macro 'min'
Message-ID: <20140625100213.GA1866@localhost>
References: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53aa90d2.Yd3WgTmElIsuiwuV%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   30404ddcb1872c8a571fa0889935ff65677e4c78
commit: aef93cafef35b8830fc973be43f0745f9c16eff4 [156/212] binfmt_elf.c: use get_random_int() to fix entropy depleting
config: make ARCH=mn10300 asb2364_defconfig

All warnings:

   In file included from include/asm-generic/bug.h:13:0,
                    from arch/mn10300/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/thread_info.h:11,
                    from include/asm-generic/preempt.h:4,
                    from arch/mn10300/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:18,
                    from include/linux/spinlock.h:50,
                    from include/linux/seqlock.h:35,
                    from include/linux/time.h:5,
                    from include/linux/stat.h:18,
                    from include/linux/module.h:10,
                    from fs/binfmt_elf.c:12:
   fs/binfmt_elf.c: In function 'get_atrandom_bytes':
   include/linux/kernel.h:713:17: warning: comparison of distinct pointer types lacks a cast
     (void) (&_min1 == &_min2);  \
                    ^
>> fs/binfmt_elf.c:158:18: note: in expansion of macro 'min'
      size_t chunk = min(nbytes, sizeof(random_variable));
                     ^

vim +/min +158 fs/binfmt_elf.c

^1da177e Linus Torvalds      2005-04-16    6   * "UNIX SYSTEM V RELEASE 4 Programmers Guide: Ansi C and Programming Support
^1da177e Linus Torvalds      2005-04-16    7   * Tools".
^1da177e Linus Torvalds      2005-04-16    8   *
^1da177e Linus Torvalds      2005-04-16    9   * Copyright 1993, 1994: Eric Youngdale (ericy@cais.com).
^1da177e Linus Torvalds      2005-04-16   10   */
^1da177e Linus Torvalds      2005-04-16   11  
^1da177e Linus Torvalds      2005-04-16  @12  #include <linux/module.h>
^1da177e Linus Torvalds      2005-04-16   13  #include <linux/kernel.h>
^1da177e Linus Torvalds      2005-04-16   14  #include <linux/fs.h>
^1da177e Linus Torvalds      2005-04-16   15  #include <linux/mm.h>
^1da177e Linus Torvalds      2005-04-16   16  #include <linux/mman.h>
^1da177e Linus Torvalds      2005-04-16   17  #include <linux/errno.h>
^1da177e Linus Torvalds      2005-04-16   18  #include <linux/signal.h>
^1da177e Linus Torvalds      2005-04-16   19  #include <linux/binfmts.h>
^1da177e Linus Torvalds      2005-04-16   20  #include <linux/string.h>
^1da177e Linus Torvalds      2005-04-16   21  #include <linux/file.h>
^1da177e Linus Torvalds      2005-04-16   22  #include <linux/slab.h>
^1da177e Linus Torvalds      2005-04-16   23  #include <linux/personality.h>
^1da177e Linus Torvalds      2005-04-16   24  #include <linux/elfcore.h>
^1da177e Linus Torvalds      2005-04-16   25  #include <linux/init.h>
^1da177e Linus Torvalds      2005-04-16   26  #include <linux/highuid.h>
^1da177e Linus Torvalds      2005-04-16   27  #include <linux/compiler.h>
^1da177e Linus Torvalds      2005-04-16   28  #include <linux/highmem.h>
^1da177e Linus Torvalds      2005-04-16   29  #include <linux/pagemap.h>
2aa362c4 Denys Vlasenko      2012-10-04   30  #include <linux/vmalloc.h>
^1da177e Linus Torvalds      2005-04-16   31  #include <linux/security.h>
^1da177e Linus Torvalds      2005-04-16   32  #include <linux/random.h>
f4e5cc2c Jesper Juhl         2006-06-23   33  #include <linux/elf.h>
7e80d0d0 Alexey Dobriyan     2007-05-08   34  #include <linux/utsname.h>
088e7af7 Daisuke HATAYAMA    2010-03-05   35  #include <linux/coredump.h>
6fac4829 Frederic Weisbecker 2012-11-13   36  #include <linux/sched.h>
^1da177e Linus Torvalds      2005-04-16   37  #include <asm/uaccess.h>
^1da177e Linus Torvalds      2005-04-16   38  #include <asm/param.h>
^1da177e Linus Torvalds      2005-04-16   39  #include <asm/page.h>
^1da177e Linus Torvalds      2005-04-16   40  
2aa362c4 Denys Vlasenko      2012-10-04   41  #ifndef user_long_t
2aa362c4 Denys Vlasenko      2012-10-04   42  #define user_long_t long
2aa362c4 Denys Vlasenko      2012-10-04   43  #endif
49ae4d4b Denys Vlasenko      2012-10-04   44  #ifndef user_siginfo_t
49ae4d4b Denys Vlasenko      2012-10-04   45  #define user_siginfo_t siginfo_t
49ae4d4b Denys Vlasenko      2012-10-04   46  #endif
49ae4d4b Denys Vlasenko      2012-10-04   47  
71613c3b Al Viro             2012-10-20   48  static int load_elf_binary(struct linux_binprm *bprm);
bb1ad820 Andrew Morton       2008-01-30   49  static unsigned long elf_map(struct file *, unsigned long, struct elf_phdr *,
bb1ad820 Andrew Morton       2008-01-30   50  				int, int, unsigned long);
^1da177e Linus Torvalds      2005-04-16   51  
69369a70 Josh Triplett       2014-04-03   52  #ifdef CONFIG_USELIB
69369a70 Josh Triplett       2014-04-03   53  static int load_elf_library(struct file *);
69369a70 Josh Triplett       2014-04-03   54  #else
69369a70 Josh Triplett       2014-04-03   55  #define load_elf_library NULL
69369a70 Josh Triplett       2014-04-03   56  #endif
69369a70 Josh Triplett       2014-04-03   57  
^1da177e Linus Torvalds      2005-04-16   58  /*
^1da177e Linus Torvalds      2005-04-16   59   * If we don't support core dumping, then supply a NULL so we
^1da177e Linus Torvalds      2005-04-16   60   * don't even try.
^1da177e Linus Torvalds      2005-04-16   61   */
698ba7b5 Christoph Hellwig   2009-12-15   62  #ifdef CONFIG_ELF_CORE
f6151dfe Masami Hiramatsu    2009-12-17   63  static int elf_core_dump(struct coredump_params *cprm);
^1da177e Linus Torvalds      2005-04-16   64  #else
^1da177e Linus Torvalds      2005-04-16   65  #define elf_core_dump	NULL
^1da177e Linus Torvalds      2005-04-16   66  #endif
^1da177e Linus Torvalds      2005-04-16   67  
^1da177e Linus Torvalds      2005-04-16   68  #if ELF_EXEC_PAGESIZE > PAGE_SIZE
f4e5cc2c Jesper Juhl         2006-06-23   69  #define ELF_MIN_ALIGN	ELF_EXEC_PAGESIZE
^1da177e Linus Torvalds      2005-04-16   70  #else
f4e5cc2c Jesper Juhl         2006-06-23   71  #define ELF_MIN_ALIGN	PAGE_SIZE
^1da177e Linus Torvalds      2005-04-16   72  #endif
^1da177e Linus Torvalds      2005-04-16   73  
^1da177e Linus Torvalds      2005-04-16   74  #ifndef ELF_CORE_EFLAGS
^1da177e Linus Torvalds      2005-04-16   75  #define ELF_CORE_EFLAGS	0
^1da177e Linus Torvalds      2005-04-16   76  #endif
^1da177e Linus Torvalds      2005-04-16   77  
^1da177e Linus Torvalds      2005-04-16   78  #define ELF_PAGESTART(_v) ((_v) & ~(unsigned long)(ELF_MIN_ALIGN-1))
^1da177e Linus Torvalds      2005-04-16   79  #define ELF_PAGEOFFSET(_v) ((_v) & (ELF_MIN_ALIGN-1))
^1da177e Linus Torvalds      2005-04-16   80  #define ELF_PAGEALIGN(_v) (((_v) + ELF_MIN_ALIGN - 1) & ~(ELF_MIN_ALIGN - 1))
^1da177e Linus Torvalds      2005-04-16   81  
^1da177e Linus Torvalds      2005-04-16   82  static struct linux_binfmt elf_format = {
f670d0ec Mikael Pettersson   2011-01-12   83  	.module		= THIS_MODULE,
f670d0ec Mikael Pettersson   2011-01-12   84  	.load_binary	= load_elf_binary,
f670d0ec Mikael Pettersson   2011-01-12   85  	.load_shlib	= load_elf_library,
f670d0ec Mikael Pettersson   2011-01-12   86  	.core_dump	= elf_core_dump,
f670d0ec Mikael Pettersson   2011-01-12   87  	.min_coredump	= ELF_EXEC_PAGESIZE,
^1da177e Linus Torvalds      2005-04-16   88  };
^1da177e Linus Torvalds      2005-04-16   89  
d4e3cc38 Andrew Morton       2007-07-21   90  #define BAD_ADDR(x) ((unsigned long)(x) >= TASK_SIZE)
^1da177e Linus Torvalds      2005-04-16   91  
^1da177e Linus Torvalds      2005-04-16   92  static int set_brk(unsigned long start, unsigned long end)
^1da177e Linus Torvalds      2005-04-16   93  {
^1da177e Linus Torvalds      2005-04-16   94  	start = ELF_PAGEALIGN(start);
^1da177e Linus Torvalds      2005-04-16   95  	end = ELF_PAGEALIGN(end);
^1da177e Linus Torvalds      2005-04-16   96  	if (end > start) {
^1da177e Linus Torvalds      2005-04-16   97  		unsigned long addr;
e4eb1ff6 Linus Torvalds      2012-04-20   98  		addr = vm_brk(start, end - start);
^1da177e Linus Torvalds      2005-04-16   99  		if (BAD_ADDR(addr))
^1da177e Linus Torvalds      2005-04-16  100  			return addr;
^1da177e Linus Torvalds      2005-04-16  101  	}
^1da177e Linus Torvalds      2005-04-16  102  	current->mm->start_brk = current->mm->brk = end;
^1da177e Linus Torvalds      2005-04-16  103  	return 0;
^1da177e Linus Torvalds      2005-04-16  104  }
^1da177e Linus Torvalds      2005-04-16  105  
^1da177e Linus Torvalds      2005-04-16  106  /* We need to explicitly zero any fractional pages
^1da177e Linus Torvalds      2005-04-16  107     after the data section (i.e. bss).  This would
^1da177e Linus Torvalds      2005-04-16  108     contain the junk from the file that should not
f4e5cc2c Jesper Juhl         2006-06-23  109     be in memory
f4e5cc2c Jesper Juhl         2006-06-23  110   */
^1da177e Linus Torvalds      2005-04-16  111  static int padzero(unsigned long elf_bss)
^1da177e Linus Torvalds      2005-04-16  112  {
^1da177e Linus Torvalds      2005-04-16  113  	unsigned long nbyte;
^1da177e Linus Torvalds      2005-04-16  114  
^1da177e Linus Torvalds      2005-04-16  115  	nbyte = ELF_PAGEOFFSET(elf_bss);
^1da177e Linus Torvalds      2005-04-16  116  	if (nbyte) {
^1da177e Linus Torvalds      2005-04-16  117  		nbyte = ELF_MIN_ALIGN - nbyte;
^1da177e Linus Torvalds      2005-04-16  118  		if (clear_user((void __user *) elf_bss, nbyte))
^1da177e Linus Torvalds      2005-04-16  119  			return -EFAULT;
^1da177e Linus Torvalds      2005-04-16  120  	}
^1da177e Linus Torvalds      2005-04-16  121  	return 0;
^1da177e Linus Torvalds      2005-04-16  122  }
^1da177e Linus Torvalds      2005-04-16  123  
09c6dd3c Ohad Ben-Cohen      2008-02-03  124  /* Let's use some macros to make this stack manipulation a little clearer */
^1da177e Linus Torvalds      2005-04-16  125  #ifdef CONFIG_STACK_GROWSUP
^1da177e Linus Torvalds      2005-04-16  126  #define STACK_ADD(sp, items) ((elf_addr_t __user *)(sp) + (items))
^1da177e Linus Torvalds      2005-04-16  127  #define STACK_ROUND(sp, items) \
^1da177e Linus Torvalds      2005-04-16  128  	((15 + (unsigned long) ((sp) + (items))) &~ 15UL)
f4e5cc2c Jesper Juhl         2006-06-23  129  #define STACK_ALLOC(sp, len) ({ \
f4e5cc2c Jesper Juhl         2006-06-23  130  	elf_addr_t __user *old_sp = (elf_addr_t __user *)sp; sp += len; \
f4e5cc2c Jesper Juhl         2006-06-23  131  	old_sp; })
^1da177e Linus Torvalds      2005-04-16  132  #else
^1da177e Linus Torvalds      2005-04-16  133  #define STACK_ADD(sp, items) ((elf_addr_t __user *)(sp) - (items))
^1da177e Linus Torvalds      2005-04-16  134  #define STACK_ROUND(sp, items) \
^1da177e Linus Torvalds      2005-04-16  135  	(((unsigned long) (sp - items)) &~ 15UL)
^1da177e Linus Torvalds      2005-04-16  136  #define STACK_ALLOC(sp, len) ({ sp -= len ; sp; })
^1da177e Linus Torvalds      2005-04-16  137  #endif
^1da177e Linus Torvalds      2005-04-16  138  
483fad1c Nathan Lynch        2008-07-22  139  #ifndef ELF_BASE_PLATFORM
483fad1c Nathan Lynch        2008-07-22  140  /*
483fad1c Nathan Lynch        2008-07-22  141   * AT_BASE_PLATFORM indicates the "real" hardware/microarchitecture.
483fad1c Nathan Lynch        2008-07-22  142   * If the arch defines ELF_BASE_PLATFORM (in asm/elf.h), the value
483fad1c Nathan Lynch        2008-07-22  143   * will be copied to the user stack in the same manner as AT_PLATFORM.
483fad1c Nathan Lynch        2008-07-22  144   */
483fad1c Nathan Lynch        2008-07-22  145  #define ELF_BASE_PLATFORM NULL
483fad1c Nathan Lynch        2008-07-22  146  #endif
483fad1c Nathan Lynch        2008-07-22  147  
aef93caf Jeff Liu            2014-06-20  148  /*
aef93caf Jeff Liu            2014-06-20  149   * Use get_random_int() to implement AT_RANDOM while avoiding depletion
aef93caf Jeff Liu            2014-06-20  150   * of the entropy pool.
aef93caf Jeff Liu            2014-06-20  151   */
aef93caf Jeff Liu            2014-06-20  152  static void get_atrandom_bytes(unsigned char *buf, size_t nbytes)
aef93caf Jeff Liu            2014-06-20  153  {
aef93caf Jeff Liu            2014-06-20  154  	unsigned char *p = buf;
aef93caf Jeff Liu            2014-06-20  155  
aef93caf Jeff Liu            2014-06-20  156  	while (nbytes) {
aef93caf Jeff Liu            2014-06-20  157  		unsigned int random_variable;
aef93caf Jeff Liu            2014-06-20 @158  		size_t chunk = min(nbytes, sizeof(random_variable));
aef93caf Jeff Liu            2014-06-20  159  
aef93caf Jeff Liu            2014-06-20  160  		random_variable = get_random_int();
aef93caf Jeff Liu            2014-06-20  161  		memcpy(p, &random_variable, chunk);

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
