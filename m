Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9086B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 02:05:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x6so9067774pfx.16
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 23:05:43 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id r9si9920373pfh.311.2018.03.18.23.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 18 Mar 2018 23:05:42 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 3/5] powerpc/mm/32: Use page_is_ram to check for RAM
In-Reply-To: <20180222121516.23415-4-j.neuschaefer@gmx.net>
References: <20180222121516.23415-1-j.neuschaefer@gmx.net> <20180222121516.23415-4-j.neuschaefer@gmx.net>
Date: Mon, 19 Mar 2018 17:05:34 +1100
Message-ID: <874llcha6p.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan =?utf-8?Q?Neusch=C3=A4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>, Christophe LEROY <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Balbir Singh <bsingharora@gmail.com>, Guenter Roeck <linux@roeck-us.net>

Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net> writes:

> Signed-off-by: Jonathan Neusch=C3=A4fer <j.neuschaefer@gmx.net>
> ---
>  arch/powerpc/mm/pgtable_32.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/arch/powerpc/mm/pgtable_32.c b/arch/powerpc/mm/pgtable_32.c
> index d35d9ad3c1cd..d54e1a9c1c99 100644
> --- a/arch/powerpc/mm/pgtable_32.c
> +++ b/arch/powerpc/mm/pgtable_32.c
> @@ -145,9 +145,8 @@ __ioremap_caller(phys_addr_t addr, unsigned long size=
, unsigned long flags,
>  #ifndef CONFIG_CRASH_DUMP
>  	/*
>  	 * Don't allow anybody to remap normal RAM that we're using.
> -	 * mem_init() sets high_memory so only do the check after that.
>  	 */
> -	if (slab_is_available() && (p < virt_to_phys(high_memory)) &&
> +	if (page_is_ram(__phys_to_pfn(p)) &&
>  	    !(__allow_ioremap_reserved && memblock_is_region_reserved(p, size))=
) {
>  		printk("__ioremap(): phys addr 0x%llx is RAM lr %ps\n",
>  		       (unsigned long long)p, __builtin_return_address(0));


This is killing my p5020ds (Freescale e5500) unfortunately:

  smp: Bringing up secondary CPUs ...
  __ioremap(): phys addr 0x7fef5000 is RAM lr smp_85xx_kick_cpu
  Unable to handle kernel paging request for data at address 0x00000000
  Faulting instruction address: 0xc0029080
  Oops: Kernel access of bad area, sig: 11 [#1]
  BE SMP NR_CPUS=3D24 CoreNet Generic
  Modules linked in:
  CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.16.0-rc4-gcc-4.6.3-00076-g853=
19478bdb4 #86
  NIP:  c0029080 LR: c0029020 CTR: 00000001
  REGS: e804bd40 TRAP: 0300   Not tainted  (4.16.0-rc4-gcc-4.6.3-00076-g853=
19478bdb4)
  MSR:  00021002 <CE,ME>  CR: 24ad4e22  XER: 00000000
  DEAR: 00000000 ESR: 00000000=20
  GPR00: c0029020 e804bdf0 e8050000 00000000 00021002 0000004d 00000000 c0a=
aaeed=20
  GPR08: 00000000 00000000 00000000 2d57d000 22adbe84 00000000 c0002630 000=
00000=20
  GPR16: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 c0a=
8b4a4=20
  GPR24: 00000001 00000000 00000000 00029002 00000000 00000001 00000001 000=
00001=20
  NIP [c0029080] smp_85xx_kick_cpu+0x100/0x2c0
  LR [c0029020] smp_85xx_kick_cpu+0xa0/0x2c0
  Call Trace:
  [e804bdf0] [c0029020] smp_85xx_kick_cpu+0xa0/0x2c0 (unreliable)
  [e804be30] [c0011194] __cpu_up+0xb4/0x1c0
  [e804be60] [c002f16c] bringup_cpu+0x2c/0xf0
  [e804be80] [c002ec9c] cpuhp_invoke_callback+0x12c/0x310
  [e804beb0] [c002fdd8] cpu_up+0x108/0x230
  [e804bee0] [c09f7438] smp_init+0x84/0x104
  [e804bf00] [c09e9acc] kernel_init_freeable+0xc4/0x228
  [e804bf30] [c0002644] kernel_init+0x14/0x110
  [e804bf40] [c000f3b0] ret_from_kernel_thread+0x5c/0x64
  Instruction dump:
  57990032 3b1c0057 7f19c050 7f3acb78 5718d1be 2e180000 41920024 7f29cb78=20
  7f0903a6 60000000 60000000 60000000 <7c0048ac> 39290040 4200fff8 7c0004ac=
=20
  random: get_random_bytes called from init_oops_id+0x5c/0x70 with crng_ini=
t=3D0
  ---[ end trace c3807aa91cf16cd8 ]---


The obvious fix of changing the test in smp_85xx_start_cpu() didn't
work, I get a different oops:

  Unable to handle kernel paging request for data at address 0x3fef5140
  Faulting instruction address: 0xc00290a0
  Oops: Kernel access of bad area, sig: 11 [#1]
  BE SMP NR_CPUS=3D24 CoreNet Generic
  Modules linked in:
  CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.16.0-rc4-gcc-4.6.3-00076-g853=
19478bdb4-dirty #90
  NIP:  c00290a0 LR: c0029040 CTR: 00000001
  REGS: e804bd50 TRAP: 0300   Not tainted  (4.16.0-rc4-gcc-4.6.3-00076-g853=
19478bdb4-dirty)
  MSR:  00021002 <CE,ME>  CR: 24a24e22  XER: 00000000
  DEAR: 3fef5140 ESR: 00000000=20
  GPR00: c0029040 e804be00 e8050000 00000023 00021002 0000004e 00000000 c0a=
aaed3=20
  GPR08: 00000000 3fef5140 00000000 2d57d000 22a2be84 00000000 c0002630 000=
00000=20
  GPR16: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 c0a=
8b4a4=20
  GPR24: 00000004 00000001 3fef5140 3fef5140 00029002 3fef5140 00000001 000=
00001=20
  NIP [c00290a0] smp_85xx_kick_cpu+0x120/0x2e0
  LR [c0029040] smp_85xx_kick_cpu+0xc0/0x2e0
  Call Trace:
  [e804be00] [c0029040] smp_85xx_kick_cpu+0xc0/0x2e0 (unreliable)
  [e804be30] [c0011194] __cpu_up+0xb4/0x1c0
  [e804be60] [c002f18c] bringup_cpu+0x2c/0xf0
  [e804be80] [c002ecbc] cpuhp_invoke_callback+0x12c/0x310
  [e804beb0] [c002fdf8] cpu_up+0x108/0x230
  [e804bee0] [c09f7438] smp_init+0x84/0x104
  [e804bf00] [c09e9acc] kernel_init_freeable+0xc4/0x228
  [e804bf30] [c0002644] kernel_init+0x14/0x110
  [e804bf40] [c000f3b0] ret_from_kernel_thread+0x5c/0x64
  Instruction dump:
  7c0903a6 4e800421 57ba0032 3b3d0057 7f3ac850 7f5bd378 5739d1be 2e190000=20
  4192001c 7f49d378 7f2903a6 60000000 <7c0048ac> 39290040 4200fff8 7c0004ac=
=20
  random: get_random_bytes called from init_oops_id+0x5c/0x70 with crng_ini=
t=3D0
  ---[ end trace 950df40ee04f2d5e ]---


So that will require a bit more debugging.

cheers
