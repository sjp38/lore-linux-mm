Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33ACA6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 11:18:23 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id j12so284641936ywb.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 08:18:23 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com (prod-mail-xrelay05.akamai.com. [23.79.238.179])
        by mx.google.com with ESMTP id o138si450760ywd.66.2016.08.02.08.18.21
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 08:18:22 -0700 (PDT)
Subject: Re: [memcg:auto-latest 238/243] include/linux/compiler-gcc.h:243:38:
 error: impossible constraint in 'asm'
References: <201607300506.W5FnCSrY%fengguang.wu@intel.com>
 <20160731121125.GA29775@dhcp22.suse.cz>
 <20160801110859.GC13544@dhcp22.suse.cz>
 <35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <57A0B9BC.2000201@akamai.com>
Date: Tue, 2 Aug 2016 11:18:20 -0400
MIME-Version: 1.0
In-Reply-To: <35a0878d-84bd-ad93-8810-23c861ed464e@suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Martin_Li=c5=a1ka?= <mliska@suse.cz>, Michal Hocko <mhocko@suse.cz>, kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>



On 08/01/2016 07:27 AM, Martin Li?ka wrote:
> On 08/01/2016 01:09 PM, Michal Hocko wrote:
>> [CC our gcc guy - I guess he has some theory for this]
>>
>> On Sun 31-07-16 14:11:25, Michal Hocko wrote:
>>> It seems that this has been already reported and Jason has noticed [1] that
>>> the problem is in the disabled optimizations:
>>>
>>> $ grep CRYPTO_DEV_UX500_DEBUG .config
>>> CONFIG_CRYPTO_DEV_UX500_DEBUG=y
>>>
>>> if I disable this particular option the code compiles just fine. I have
>>> no idea what is wrong about the code but it seems to depend on
>>> optimizations enabled which sounds a bit scrary...
>>>
>>> [1] http://www.spinics.net/lists/linux-mm/msg109590.html
>
> Hi.
>
> The difference is that w/o any optimization level, GCC doesn't make %c0 an
> intermediate integer operand [1] (see description of "i" constraint).
>
> If I change "i" to "X" (Any operand whatsoever is allowed.) and "%c0" to "%k0" I get following assembly:
>

hmmm...but the the '__jump_table' section there needs to be known
at build time. For example, the 'r3' field in the table is the
'key' which is used to identify the proper branches when we
go to update the branch directions. So this needs to be fixed
at build time...

Thanks,

-Jason

> cryp_enable_irq_src:
> 	@ args = 0, pretend = 0, frame = 48
> 	@ frame_needed = 1, uses_anonymous_args = 0
> 	push	{fp, lr}
> 	add	fp, sp, #4
> 	sub	sp, sp, #48
> 	str	r0, [fp, #-48]
> 	str	r1, [fp, #-52]
> 	ldr	r3, .L6
> 	str	r3, [fp, #-20]
> 	mov	r3, #1
> 	strb	r3, [fp, #-21]
> 	ldrb	r3, [fp, #-21]	@ zero_extendqisi2
> 	ldr	r2, [fp, #-20]
> 	add	r3, r2, r3
> 	.syntax divided
> @ 1607 "/home/marxin/Programming/testcases/asm.i" 1
> 	1:
> 	nop
> 	.pushsection __jump_table,  "aw"
> 	.word 1b, .L2, r3 # The operand is the register r3
> 	.popsection
> 	
> 	.arm
> 	.syntax unified
> 	mov	r3, #0
> 	b	.L3
> .L2:
>
> While using -O2 really make %c0 an intermediate operand:
>
> cryp_enable_irq_src:
> 	@ args = 0, pretend = 0, frame = 0
> 	@ frame_needed = 0, uses_anonymous_args = 0
> 	push	{r4, r5, r6, lr}
> 	mov	r5, r0
> 	mov	r4, r1
> 	.syntax divided
> @ 1607 "/home/marxin/Programming/testcases/asm.i" 1
> 	1:
> 	nop
> 	.pushsection __jump_table,  "aw"
> 	.word 1b, .L2, #.LANCHOR0+21  # The operand is the intermediate operand #.LANCHOR0+21
> 	.popsection
>
> Martin
>
> [1] https://gcc.gnu.org/onlinedocs/gcc/Simple-Constraints.html#Simple-Constraints
>
>>>
>>> On Sat 30-07-16 05:04:07, Wu Fengguang wrote:
>>>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git auto-latest
>>>> head:   a7bf930624bb1d3368b71b79c5e3351b5d03aa9f
>>>> commit: 966a2c66863bb2d984b9b49aee271de502cf8747 [238/243] dynamic_debug: add jump label support
>>>> config: arm-allmodconfig (attached as .config)
>>>> compiler: arm-linux-gnueabi-gcc (Debian 5.4.0-6) 5.4.0 20160609
>>>> reproduce:
>>>>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>>>          chmod +x ~/bin/make.cross
>>>>          git checkout 966a2c66863bb2d984b9b49aee271de502cf8747
>>>>          # save the attached .config to linux build tree
>>>>          make.cross ARCH=arm
>>>>
>>>> All errors (new ones prefixed by >>):
>>>>
>>>>     In file included from include/linux/compiler.h:58:0,
>>>>                      from include/linux/linkage.h:4,
>>>>                      from include/linux/kernel.h:6,
>>>>                      from drivers/crypto/ux500/cryp/cryp_irq.c:11:
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_enable_irq_src':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>>> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_disable_irq_src':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>> --
>>>>     In file included from include/linux/compiler.h:58:0,
>>>>                      from include/linux/err.h:4,
>>>>                      from include/linux/clk.h:15,
>>>>                      from drivers/crypto/ux500/cryp/cryp_core.c:12:
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_interrupt_handler':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>>> include/linux/compiler-gcc.h:243:38: error: impossible constraint in 'asm'
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cfg_iv':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cfg_ivs':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'set_key':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cfg_keys':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_get_device_data':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_dma_out_callback':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_set_dma_transfer':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_dma_done':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     arch/arm/include/asm/jump_label.h: In function 'cryp_dma_write':
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>                                           ^
>>>>     arch/arm/include/asm/jump_label.h:13:2: note: in expansion of macro 'asm_volatile_goto'
>>>>       asm_volatile_goto("1:\n\t"
>>>>       ^
>>>>     include/linux/compiler-gcc.h:243:38: warning: asm operand 0 probably doesn't match constraints
>>>>      #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
>>>>
>>>> vim +/asm +243 include/linux/compiler-gcc.h
>>>>
>>>> a744fd17 Rasmus Villemoes 2015-11-05  227   * returning extra information in the low bits (but in that case the
>>>> a744fd17 Rasmus Villemoes 2015-11-05  228   * compiler should see some alignment anyway, when the return value is
>>>> a744fd17 Rasmus Villemoes 2015-11-05  229   * massaged by 'flags = ptr & 3; ptr &= ~3;').
>>>> a744fd17 Rasmus Villemoes 2015-11-05  230   */
>>>> a744fd17 Rasmus Villemoes 2015-11-05  231  #define __assume_aligned(a, ...) __attribute__((__assume_aligned__(a, ## __VA_ARGS__)))
>>>> a744fd17 Rasmus Villemoes 2015-11-05  232  #endif
>>>> a744fd17 Rasmus Villemoes 2015-11-05  233
>>>> cb984d10 Joe Perches      2015-06-25  234  /*
>>>> cb984d10 Joe Perches      2015-06-25  235   * GCC 'asm goto' miscompiles certain code sequences:
>>>> cb984d10 Joe Perches      2015-06-25  236   *
>>>> cb984d10 Joe Perches      2015-06-25  237   *   http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58670
>>>> cb984d10 Joe Perches      2015-06-25  238   *
>>>> cb984d10 Joe Perches      2015-06-25  239   * Work it around via a compiler barrier quirk suggested by Jakub Jelinek.
>>>> cb984d10 Joe Perches      2015-06-25  240   *
>>>> cb984d10 Joe Perches      2015-06-25  241   * (asm goto is automatically volatile - the naming reflects this.)
>>>> cb984d10 Joe Perches      2015-06-25  242   */
>>>> cb984d10 Joe Perches      2015-06-25 @243  #define asm_volatile_goto(x...)	do { asm goto(x); asm (""); } while (0)
>>>> cb984d10 Joe Perches      2015-06-25  244
>>>> cb984d10 Joe Perches      2015-06-25  245  #ifdef CONFIG_ARCH_USE_BUILTIN_BSWAP
>>>> cb984d10 Joe Perches      2015-06-25  246  #if GCC_VERSION >= 40400
>>>> cb984d10 Joe Perches      2015-06-25  247  #define __HAVE_BUILTIN_BSWAP32__
>>>> cb984d10 Joe Perches      2015-06-25  248  #define __HAVE_BUILTIN_BSWAP64__
>>>> cb984d10 Joe Perches      2015-06-25  249  #endif
>>>> 8634de6d Josh Poimboeuf   2016-05-06  250  #if GCC_VERSION >= 40800
>>>> cb984d10 Joe Perches      2015-06-25  251  #define __HAVE_BUILTIN_BSWAP16__
>>>>
>>>> :::::: The code at line 243 was first introduced by commit
>>>> :::::: cb984d101b30eb7478d32df56a0023e4603cba7f compiler-gcc: integrate the various compiler-gcc[345].h files
>>>>
>>>> :::::: TO: Joe Perches <joe@perches.com>
>>>> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>>>>
>>>> ---
>>>> 0-DAY kernel test infrastructure                Open Source Technology Center
>>>> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>>>
>>>
>>>
>>> --
>>> Michal Hocko
>>> SUSE Labs
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
