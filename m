Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAB56B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 13:04:11 -0400 (EDT)
Received: by layy10 with SMTP id y10so70876220lay.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 10:04:10 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id tl5si9298995lbb.96.2015.04.08.10.04.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 10:04:09 -0700 (PDT)
Message-ID: <55255F84.6060608@yandex-team.ru>
Date: Wed, 08 Apr 2015 20:04:04 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
References: <20150408165920.25007.6869.stgit@buzz>
In-Reply-To: <20150408165920.25007.6869.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grant Likely <grant.likely@linaro.org>, devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>, linux-kernel@vger.kernel.org
Cc: sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
> Node 0 might be offline as well as any other numa node,
> in this case kernel cannot handle memory allocation and crashes.

Example:

[    0.027133] ------------[ cut here ]------------
[    0.027938] kernel BUG at include/linux/gfp.h:322!
[    0.028000] invalid opcode: 0000 [#1] SMP
[    0.028000] Modules linked in:
[    0.028000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc7 #12
[    0.028000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 
04/01/2014
[    0.028000] task: ffff88007d3f8000 ti: ffff88007d3dc000 task.ti: 
ffff88007d3dc000
[    0.028000] RIP: 0010:[<ffffffff8118574c>]  [<ffffffff8118574c>] 
new_slab+0x30c/0x3c0
[    0.028000] RSP: 0000:ffff88007d3dfc28  EFLAGS: 00010246
[    0.028000] RAX: 0000000000000000 RBX: ffff88007d001800 RCX: 
0000000000000001
[    0.028000] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
00000000002012d0
[    0.028000] RBP: ffff88007d3dfc58 R08: 0000000000000000 R09: 
0000000000000000
[    0.028000] R10: 0000000000000001 R11: ffff88007d02fe40 R12: 
00000000000000d0
[    0.028000] R13: 00000000000000c0 R14: 0000000000000015 R15: 
0000000000000000
[    0.028000] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) 
knlGS:0000000000000000
[    0.028000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    0.028000] CR2: 00000000ffffffff CR3: 0000000001e0e000 CR4: 
00000000000006f0
[    0.028000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[    0.028000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 
0000000000000400
[    0.028000] Stack:
[    0.028000]  0000000000000000 ffff88007fc175d0 ffffea0001f40bc0 
00000000000000c0
[    0.028000]  ffff88007d001800 00000000000080d0 ffff88007d3dfd48 
ffffffff8192da27
[    0.028000]  000000000000000d ffffffff81e27038 0000000000000000 
0000000000000000
[    0.028000] Call Trace:
[    0.028000]  [<ffffffff8192da27>] __slab_alloc+0x3df/0x55d
[    0.028000]  [<ffffffff8109a92b>] ? __lock_acquire+0xc1b/0x1f40
[    0.028000]  [<ffffffff810b1f2c>] ? __irq_domain_add+0x3c/0xe0
[    0.028000]  [<ffffffff810998f5>] ? trace_hardirqs_on_caller+0x105/0x1d0
[    0.028000]  [<ffffffff813631ab>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[    0.028000]  [<ffffffff811890ab>] __kmalloc_node+0xab/0x210
[    0.028000]  [<ffffffff810394df>] ? ioapic_read_entry+0x1f/0x50
[    0.028000]  [<ffffffff810b1f2c>] ? __irq_domain_add+0x3c/0xe0
[    0.028000]  [<ffffffff810b1f2c>] __irq_domain_add+0x3c/0xe0
[    0.028000]  [<ffffffff81039e0e>] mp_irqdomain_create+0x9e/0x120
[    0.028000]  [<ffffffff81f22d49>] setup_IO_APIC+0x6b/0x798
[    0.028000]  [<ffffffff810398a5>] ? clear_IO_APIC+0x45/0x70
[    0.028000]  [<ffffffff81f21f01>] apic_bsp_setup+0x87/0x96
[    0.028000]  [<ffffffff81f1fdb4>] native_smp_prepare_cpus+0x237/0x275
[    0.028000]  [<ffffffff81f131b7>] kernel_init_freeable+0x120/0x265
[    0.028000]  [<ffffffff819271f9>] ? kernel_init+0x9/0xf0
[    0.028000]  [<ffffffff819271f0>] ? rest_init+0x130/0x130
[    0.028000]  [<ffffffff819271f9>] kernel_init+0x9/0xf0
[    0.028000]  [<ffffffff8193b958>] ret_from_fork+0x58/0x90
[    0.028000]  [<ffffffff819271f0>] ? rest_init+0x130/0x130
[    0.028000] Code: 6b b6 ff ff 49 89 c5 e9 ce fd ff ff 31 c0 90 e9 74 
ff ff ff 49 c7 04 04 00 00 00 00 e9 05 ff ff ff 4c 89 e7 ff d0 e9 d9 fe 
ff ff <0f> 0b 4c 8b 73 38 44 89 e7 81 cf 00 00 20 00 4c 89 f6 48 c1 ee
[    0.028000] RIP  [<ffffffff8118574c>] new_slab+0x30c/0x3c0
[    0.028000]  RSP <ffff88007d3dfc28>
[    0.028039] ---[ end trace f03690e70d7e4be6 ]---


>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: 0c3f061c195c ("of: implement of_node_to_nid as a weak function")
> ---
>   drivers/of/base.c  |    2 +-
>   include/linux/of.h |    5 ++++-
>   2 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/of/base.c b/drivers/of/base.c
> index 8f165b112e03..51f4bd16e613 100644
> --- a/drivers/of/base.c
> +++ b/drivers/of/base.c
> @@ -89,7 +89,7 @@ EXPORT_SYMBOL(of_n_size_cells);
>   #ifdef CONFIG_NUMA
>   int __weak of_node_to_nid(struct device_node *np)
>   {
> -	return numa_node_id();
> +	return NUMA_NO_NODE;
>   }
>   #endif
>
> diff --git a/include/linux/of.h b/include/linux/of.h
> index dfde07e77a63..78a04ee85a9c 100644
> --- a/include/linux/of.h
> +++ b/include/linux/of.h
> @@ -623,7 +623,10 @@ static inline const char *of_prop_next_string(struct property *prop,
>   #if defined(CONFIG_OF) && defined(CONFIG_NUMA)
>   extern int of_node_to_nid(struct device_node *np);
>   #else
> -static inline int of_node_to_nid(struct device_node *device) { return 0; }
> +static inline int of_node_to_nid(struct device_node *device)
> +{
> +	return NUMA_NO_NODE;
> +}
>   #endif
>
>   static inline struct device_node *of_find_matching_node(
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
