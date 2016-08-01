Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E62AF6B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 07:09:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p129so79869103wmp.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 04:09:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p1si15356447wmd.53.2016.08.01.04.09.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 04:09:03 -0700 (PDT)
Date: Mon, 1 Aug 2016 13:09:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [memcg:auto-latest 238/243] include/linux/compiler-gcc.h:243:38:
 error: impossible constraint in 'asm'
Message-ID: <20160801110859.GC13544@dhcp22.suse.cz>
References: <201607300506.W5FnCSrY%fengguang.wu@intel.com>
 <20160731121125.GA29775@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160731121125.GA29775@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Jason Baron <jbaron@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, Martin =?utf-8?B?TGnFoWth?= <mliska@suse.cz>

[CC our gcc guy - I guess he has some theory for this]

On Sun 31-07-16 14:11:25, Michal Hocko wrote:
> It seems that this has been already reported and Jason has noticed [1] that
> the problem is in the disabled optimizations:
> 
> $ grep CRYPTO_DEV_UX500_DEBUG .config
> CONFIG_CRYPTO_DEV_UX500_DEBUG=y
> 
> if I disable this particular option the code compiles just fine. I have
> no idea what is wrong about the code but it seems to depend on
> optimizations enabled which sounds a bit scrary...
> 
> [1] http://www.spinics.net/lists/linux-mm/msg109590.html
> 
> On Sat 30-07-16 05:04:07, Wu Fengguang wrote:
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git auto-latest
> > head:   a7bf930624bb1d3368b71b79c5e3351b5d03aa9f
> > commit: 966a2c66863bb2d984b9b49aee271de502cf8747 [238/243] dynamic_debug: add jump label support
> > config: arm-allmodconfig (attached as .config)
> > compiler: arm-linux-gnueabi-gcc (Debian 5.4.0-6) 5.4.0 20160609
> > reproduce:
> >         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout 966a2c66863bb2d984b9b49aee271de502cf8747
> >         # save the attached .config to linux build tree
> >         make.cross ARCH=arm 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    In file included from include/linux/compiler.h:58:0,
> >                     from include/linux/linkage.h:4,
> >                     from include/linux/kernel.h:6,
> >                     from drivers/crypto/ux500/cryp/cryp_irq.c:11:
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_enable_irq_src':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> > >> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_disable_irq_src':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> > --
> >    In file included from include/linux/compiler.h:58:0,
> >                     from include/linux/err.h:4,
> >                     from include/linux/clk.h:15,
> >                     from drivers/crypto/ux500/cryp/cryp_core.c:12:
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_interrupt_handler':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> > >> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cfg_iv':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cfg_ivs':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'set_key':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cfg_keys':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_get_device_data':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_dma_out_callback':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_set_dma_transfer':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_dma_done':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    arch/arm/include/asm/jump_label.h: In function 'cryp_dma_write':
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> >                                          ^
> >    arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
> >      asm_volatile_goto("1:\n\t"
> >      ^
> >    include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
> >     #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
> > 
> > vim +/asm +243 include/linux/compiler-gcc.h
> > 
> > a744fd17 Rasmus Villemoes 2015-11-05  227   * returning extra information in the low bits (but in that case the
> > a744fd17 Rasmus Villemoes 2015-11-05  228   * compiler should see some alignment anyway, when the return value is
> > a744fd17 Rasmus Villemoes 2015-11-05  229   * massaged by 'flags = ptr & 3; ptr &= ~3;').
> > a744fd17 Rasmus Villemoes 2015-11-05  230   */
> > a744fd17 Rasmus Villemoes 2015-11-05  231  #define __assume_aligned(a, ...) __attribute__((__assume_aligned__(a, ## __VA_ARGS__)))
> > a744fd17 Rasmus Villemoes 2015-11-05  232  #endif
> > a744fd17 Rasmus Villemoes 2015-11-05  233  
> > cb984d10 Joe Perches      2015-06-25  234  /*
> > cb984d10 Joe Perches      2015-06-25  235   * GCC 'asm goto' miscompiles certain code sequences:
> > cb984d10 Joe Perches      2015-06-25  236   *
> > cb984d10 Joe Perches      2015-06-25  237   *   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58670
> > cb984d10 Joe Perches      2015-06-25  238   *
> > cb984d10 Joe Perches      2015-06-25  239   * Work it around via a compiler barrier quirk suggested by Jakub Jelinek.
> > cb984d10 Joe Perches      2015-06-25  240   *
> > cb984d10 Joe Perches      2015-06-25  241   * (asm goto is automatically volatile - the naming reflects this.)
> > cb984d10 Joe Perches      2015-06-25  242   */
> > cb984d10 Joe Perches      2015-06-25 @243  #define asm_volatile_goto(x...)	do { asm goto(x); asm (""); } while (0)
> > cb984d10 Joe Perches      2015-06-25  244  
> > cb984d10 Joe Perches      2015-06-25  245  #ifdef CONFIG_ARCH_USE_BUILTIN_BSWAP
> > cb984d10 Joe Perches      2015-06-25  246  #if GCC_VERSION >= 40400
> > cb984d10 Joe Perches      2015-06-25  247  #define __HAVE_BUILTIN_BSWAP32__
> > cb984d10 Joe Perches      2015-06-25  248  #define __HAVE_BUILTIN_BSWAP64__
> > cb984d10 Joe Perches      2015-06-25  249  #endif
> > 8634de6d Josh Poimboeuf   2016-05-06  250  #if GCC_VERSION >= 40800
> > cb984d10 Joe Perches      2015-06-25  251  #define __HAVE_BUILTIN_BSWAP16__
> > 
> > :::::: The code at line 243 was first introduced by commit
> > :::::: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
> > 
> > :::::: TO: Joe Perches <joe@perches.com>
> > :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
> > 
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 
> 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
