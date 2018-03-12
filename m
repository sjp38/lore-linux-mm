Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 137886B0003
	for <linux-mm@kvack.org>; Mon, 12 Mar 2018 01:57:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v126so309015pgb.0
        for <linux-mm@kvack.org>; Sun, 11 Mar 2018 22:57:20 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o2si4564288pgf.658.2018.03.11.22.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Mar 2018 22:57:18 -0700 (PDT)
Date: Mon, 12 Mar 2018 13:56:30 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH V2] ZBOOT: fix stack protector in compressed boot phase
Message-ID: <201803121309.rL1h1C83%fengguang.wu@intel.com>
References: <1520820258-19225-1-git-send-email-chenhc@lemote.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Content-Disposition: inline
In-Reply-To: <1520820258-19225-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@mips.com>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, stable@vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Huacai,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v4.16-rc5 next-20180309]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Huacai-Chen/ZBOOT-fix-stack-protector-in-compressed-boot-phase/20180312-114651
config: sh-allnoconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sh 

All errors (new ones prefixed by >>):

   arch/sh/boot/compressed/head_32.S: Assembler messages:
>> arch/sh/boot/compressed/head_32.S:79: Error: pcrel too far
>> arch/sh/boot/compressed/head_32.S:80: Error: offset out of range
>> arch/sh/boot/compressed/head_32.S:80: Error: value of 658943 too large for field of 2 bytes at 102

vim +79 arch/sh/boot/compressed/head_32.S

    12	
    13		.global	startup
    14	startup:
    15		/* Load initial status register */
    16		mov.l   init_sr, r1
    17		ldc     r1, sr
    18	
    19		/* Move myself to proper location if necessary */
    20		mova	1f, r0
    21		mov.l	1f, r2
    22		cmp/eq	r2, r0
    23		bt	clear_bss
    24		sub	r0, r2
    25		mov.l	bss_start_addr, r0
    26		mov	#0xffffffe0, r1
    27		and	r1, r0			! align cache line
    28		mov.l	text_start_addr, r3
    29		mov	r0, r1
    30		sub	r2, r1
    31	3:
    32		mov.l	@r1, r4
    33		mov.l	@(4,r1), r5
    34		mov.l	@(8,r1), r6
    35		mov.l	@(12,r1), r7
    36		mov.l	@(16,r1), r8
    37		mov.l	@(20,r1), r9
    38		mov.l	@(24,r1), r10
    39		mov.l	@(28,r1), r11
    40		mov.l	r4, @r0
    41		mov.l	r5, @(4,r0)
    42		mov.l	r6, @(8,r0)
    43		mov.l	r7, @(12,r0)
    44		mov.l	r8, @(16,r0)
    45		mov.l	r9, @(20,r0)
    46		mov.l	r10, @(24,r0)
    47		mov.l	r11, @(28,r0)
    48	#ifdef CONFIG_CPU_SH4
    49		ocbwb	@r0
    50	#endif
    51		cmp/hi	r3, r0
    52		add	#-32, r0
    53		bt/s	3b
    54		 add	#-32, r1
    55		mov.l	2f, r0
    56		jmp	@r0
    57		 nop
    58	
    59		.align 2
    60	1:	.long	1b
    61	2:	.long	clear_bss
    62	text_start_addr:
    63		.long	startup
    64	
    65		/* Clear BSS */
    66	clear_bss:
    67		mov.l	end_addr, r1
    68		mov.l	bss_start_addr, r2
    69		mov	#0, r0
    70	l1:
    71		mov.l	r0, @-r1
    72		cmp/eq	r1,r2
    73		bf	l1
    74	
    75		/* Set the initial pointer. */
    76		mov.l	init_stack_addr, r0
    77		mov.l	@r0, r15
    78	
  > 79		mov.l	__stack_chk_guard, r0
  > 80		mov	#0x000a0dff, r1

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--pf9I7BMVVzbSWLtt
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
EQpyJR6Sh/X/4kJda1lOAAA=

--pf9I7BMVVzbSWLtt--
