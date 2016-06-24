Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55C9C6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 15:12:12 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d2so64407006qkg.0
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 12:12:12 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id p6si5957813qtb.49.2016.06.24.12.12.10
        for <linux-mm@kvack.org>;
        Fri, 24 Jun 2016 12:12:11 -0700 (PDT)
Subject: Re: [mel:mm-vmscan-node-lru-v8r12 185/295]
 arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro
 'asm_volatile_goto'
References: <201606250046.lpbX7Fys%fengguang.wu@intel.com>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <576D8609.50305@akamai.com>
Date: Fri, 24 Jun 2016 15:12:09 -0400
MIME-Version: 1.0
In-Reply-To: <201606250046.lpbX7Fys%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, rth@redhat.com

Hi,

On 06/24/2016 12:00 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mel/linux mm-vmscan-node-lru-v8r12
> head:   572d76872348caf13577b82f35e4f1869fd79681
> commit: 6a8bfa2685fa2969d95b16470c846175c0ded7a4 [185/295] dynamic_debug: add jump label support
> config: arm-allyesconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 6a8bfa2685fa2969d95b16470c846175c0ded7a4
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    In file included from include/linux/compiler.h:60:0,
>                     from include/linux/linkage.h:4,
>                     from include/linux/kernel.h:6,
>                     from drivers/crypto/ux500/cryp/cryp_irq.c:11:
>    arch/arm/include/asm/jump_label.h: In function 'cryp_enable_irq_src':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>


In drivers/crypto/ux500/cryp/Makefile, there is an explicit setting to
disable gcc optimizations:

ifdef CONFIG_CRYPTO_DEV_UX500_DEBUG
CFLAGS_cryp_core.o := -DDEBUG -O0
CFLAGS_cryp.o := -DDEBUG -O0
CFLAGS_cryp_irq.o := -DDEBUG -O0
endif

If I change those to -O1 or -O2, it seems to build fine, strange...I was
able to reproduce this with gcc 4.9.0 as well.

Thanks,

-Jason

                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>>> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cryp_disable_irq_src':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
> --
>    In file included from include/linux/compiler.h:60:0,
>                     from include/linux/err.h:4,
>                     from include/linux/clk.h:15,
>                     from drivers/crypto/ux500/cryp/cryp_core.c:12:
>    arch/arm/include/asm/jump_label.h: In function 'cryp_interrupt_handler':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>>> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cfg_iv':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cfg_ivs':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'set_key':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cfg_keys':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cryp_get_device_data':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cryp_dma_out_callback':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>    arch/arm/include/asm/jump_label.h: In function 'cryp_set_dma_transfer':
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
>>> include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>                                          ^
>>> arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>      asm_volatile_goto("1:\n\t"
>      ^
> 
> vim +/asm_volatile_goto +13 arch/arm/include/asm/jump_label.h
> 
> 09f05d85 Rabin Vincent   2012-02-18   1  #ifndef _ASM_ARM_JUMP_LABEL_H
> 09f05d85 Rabin Vincent   2012-02-18   2  #define _ASM_ARM_JUMP_LABEL_H
> 09f05d85 Rabin Vincent   2012-02-18   3  
> 55dd0df7 Anton Blanchard 2015-04-09   4  #ifndef __ASSEMBLY__
> 09f05d85 Rabin Vincent   2012-02-18   5  
> 09f05d85 Rabin Vincent   2012-02-18   6  #include <linux/types.h>
> 11276d53 Peter Zijlstra  2015-07-24   7  #include <asm/unified.h>
> 09f05d85 Rabin Vincent   2012-02-18   8  
> 09f05d85 Rabin Vincent   2012-02-18   9  #define JUMP_LABEL_NOP_SIZE 4
> 09f05d85 Rabin Vincent   2012-02-18  10  
> 11276d53 Peter Zijlstra  2015-07-24  11  static __always_inline bool arch_static_branch(struct static_key *key, bool branch)
> 11276d53 Peter Zijlstra  2015-07-24  12  {
> 11276d53 Peter Zijlstra  2015-07-24 @13  	asm_volatile_goto("1:\n\t"
> 11276d53 Peter Zijlstra  2015-07-24  14  		 WASM(nop) "\n\t"
> 11276d53 Peter Zijlstra  2015-07-24  15  		 ".pushsection __jump_table,  \"aw\"\n\t"
> 11276d53 Peter Zijlstra  2015-07-24  16  		 ".word 1b, %l[l_yes], %c0\n\t"
> 11276d53 Peter Zijlstra  2015-07-24  17  		 ".popsection\n\t"
> 11276d53 Peter Zijlstra  2015-07-24  18  		 : :  "i" (&((char *)key)[branch]) :  : l_yes);
> 11276d53 Peter Zijlstra  2015-07-24  19  
> 11276d53 Peter Zijlstra  2015-07-24  20  	return false;
> 11276d53 Peter Zijlstra  2015-07-24  21  l_yes:
> 
> :::::: The code at line 13 was first introduced by commit
> :::::: 11276d5306b8e5b438a36bbff855fe792d7eaa61 locking/static_keys: Add a new static_key interface
> 
> :::::: TO: Peter Zijlstra <peterz@infradead.org>
> :::::: CC: Ingo Molnar <mingo@kernel.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
