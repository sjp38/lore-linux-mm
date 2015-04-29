Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 275A06B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 04:30:21 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so14539401lab.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 01:30:20 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id yi7si18856591lbb.14.2015.04.29.01.30.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 01:30:18 -0700 (PDT)
Message-ID: <55409696.8010209@yandex-team.ru>
Date: Wed, 29 Apr 2015 11:30:14 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
References: <20150408165920.25007.6869.stgit@buzz>, 	<CAL_JsqKQPtNPfTAiqsKnFuU6e-qozzPgujM=8MHseG75R9cbSA@mail.gmail.com>, 	<552BC6E8.1040400@yandex-team.ru>, 	<CAL_Jsq+vaufZJAchHC1OaV9g18zFfkXyRZ9j5wm0VWosh9i4kQ@mail.gmail.com> <201504290910595113455@inspur.com>
In-Reply-To: <201504290910595113455@inspur.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "songxiumiao@inspur.com" <songxiumiao@inspur.com>, Rob Herring <robherring2@gmail.com>
Cc: Grant Likely <grant.likely@linaro.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, yanxiaofeng <yanxiaofeng@inspur.com>, x86@kernel.org, linux-metag@vger.kernel.org

+x86@kernel.org
+linux-metag@vger.kernel.org

here is proposed fix:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg864009.html

It returns NUMA_NO_NODE from both static-inline (CONFIG_OF=n) and weak
version of of_node_to_nid(). This change might affect few arches which
whave CONFIG_OF=y but doesn't implement of_node_to_nid() (i.e. depends
on default behavior of weak function). It seems this is only metag.

 From mm/ point of view returning NUMA_NO_NODE is a right choice when
code have no idea which numa node should be used -- memory allocation
functions choose current numa node (but they might use any).

On 29.04.2015 04:11, songxiumiao@inspur.com wrote:
> When we test the cpu and memory hotplug feature in the server with x86
> architecture and kernel4.0-rc4,we met the similar problem.
>
> The situation is that when memory in node0 is offline,the system is down
> during booting.
>
> Following is the bug information:
> [    0.335176] BUG: unable to handle kernel paging request at
> 0000000000001b08
> [    0.342164] IP: [<ffffffff81182587>] __alloc_pages_nodemask+0xb7/0x940
> [    0.348706] PGD 0
> [    0.350735] Oops: 0000 [#1] SMP
> [ 0.353993] Modules linked in:
> [    0.357063] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc4 #1
> [    0.363232] Hardware name: Inspur TS860/TS860, BIOS TS860_2.0.0
> 2015/03/24
> [    0.370095] task: ffff88085b1e0000 ti: ffff88085b1e8000 task.ti:
> ffff88085b1e8000
> [    0.377564] RIP: 0010:[<ffffffff81182587>]  [<ffffffff81182587>]
> __alloc_pages_nodemask+0xb7/0x940
> [    0.386524] RSP: 0000:ffff88085b1ebac8  EFLAGS: 00010246
> [    0.391828] RAX: 0000000000001b00 RBX: 0000000000000010 RCX:
> 0000000000000000
> [    0.398953] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> 00000000002052d0
> [    0.406075] RBP: ffff88085b1ebbb8 R08: ffff88085b13fec0 R09:
> 000000005b13fe01
> [    0.413198] R10: ffff88085e807300 R11: ffffffff810d4bc1 R12:
> 000000000001002a
> [    0.420321] R13: 00000000002052d0 R14: 0000000000000001 R15:
> 00000000000040d0
> [    0.427446] FS: 0000000000000000(0000) GS:ffff88085ee00000(0000)
> knlGS:0000000000000000
> [    0.435522] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [    0.441259] CR2: 0000000000001b08 CR3: 00000000019ae000 CR4:
> 00000000001406f0
> [    0.448382] Stack:
> [ 0.450392]  ffff88085b1e0000 0000000000000400 ffff88085b1effff
> ffff88085b1ebb68
> [    0.457846]  000000000000007b ffff88085b12d140 ffff88085b249000
> 000000000000007b
> [ 0.465298]  ffff88085b1ebb28 ffffffff81af2900 0000000000000000
> 002052d05b12d140
> [    0.472750] Call Trace:
> [    0.475206]  [<ffffffff811d27b3>] ? deactivate_slab+0x383/0x400
> [    0.481123] [<ffffffff811d3947>] new_slab+0xa7/0x460
> [ 0.486174]  [<ffffffff816789e5>] __slab_alloc+0x310/0x470
> [    0.491655] [<ffffffff8105304f>] ? dmar_msi_set_affinity+0x8f/0xc0
> [    0.497921] [<ffffffff810d4bc1>] ? __irq_domain_add+0x41/0x100
> [ 0.503838]  [<ffffffff810d0fee>] ? irq_do_set_affinity+0x5e/0x70
> [    0.509920] [<ffffffff811d571d>] __kmalloc_node+0xad/0x2e0
> [ 0.515483]  [<ffffffff810d4bc1>] ? __irq_domain_add+0x41/0x100
> [    0.521392] [<ffffffff810d4bc1>] __irq_domain_add+0x41/0x100
> [ 0.527133]  [<ffffffff8105102e>] mp_irqdomain_create+0x9e/0x120
> [    0.533140] [<ffffffff81b2fb14>] setup_IO_APIC+0x64/0x1be
> [ 0.538622]  [<ffffffff81b2e226>] apic_bsp_setup+0xa2/0xae
> [    0.544099] [<ffffffff81b2bc70>] native_smp_prepare_cpus+0x267/0x2b2
> [    0.550531] [<ffffffff81b1927b>] kernel_init_freeable+0xf2/0x253
> [    0.556625] [<ffffffff8166b960>] ? rest_init+0x80/0x80
> [ 0.561845]  [<ffffffff8166b96e>] kernel_init+0xe/0xf0
> [    0.566979] [<ffffffff81681bd8>] ret_from_fork+0x58/0x90
> [ 0.572374]  [<ffffffff8166b960>] ? rest_init+0x80/0x80
> [    0.577591] Code: 30 97 00 89 45 bc 83 e1 0f b8 22 01 32 01 01 c9 d3
> f8 83 e0 03 89 9d 6c ff ff ff 83 e3 10 89 45 c0 0f 85 6d 01 00 00 48 8b
> 45 88 <48> 83 78 08 00 0f 84 51 01 00 00 b8 01 00 00 00 44 89 f1 d3 e0
> [    0.597537] RIP [<ffffffff81182587>] __alloc_pages_nodemask+0xb7/0x940
> [    0.604158]  RSP <ffff88085b1ebac8>
> [    0.607643] CR2: 0000000000001b08
> [    0.610962] ---[ end trace 0a600c0841386992 ]---
> [    0.615573] Kernel panic - not syncing: Fatal exception
> [    0.620792] ---[ end Kernel panic - not syncing: Fatal exception
> *From:* Rob Herring <mailto:robherring2@gmail.com>
> *Date:* 2015-04-14 00:49
> *To:* Konstantin Khlebnikov <mailto:khlebnikov@yandex-team.ru>
> *CC:* Grant Likely <mailto:grant.likely@linaro.org>;
> devicetree@vger.kernel.org <mailto:devicetree@vger.kernel.org>; Rob
> Herring <mailto:robh+dt@kernel.org>; linux-kernel@vger.kernel.org
> <mailto:linux-kernel@vger.kernel.org>; sparclinux@vger.kernel.org
> <mailto:sparclinux@vger.kernel.org>; linux-mm@kvack.org
> <mailto:linux-mm@kvack.org>; linuxppc-dev
> <mailto:linuxppc-dev@lists.ozlabs.org>
> *Subject:* Re: [PATCH] of: return NUMA_NO_NODE from fallback
> of_node_to_nid()
> On Mon, Apr 13, 2015 at 8:38 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>  > On 13.04.2015 16:22, Rob Herring wrote:
>  >>
>  >> On Wed, Apr 8, 2015 at 11:59 AM, Konstantin Khlebnikov
>  >> <khlebnikov@yandex-team.ru> wrote:
>  >>>
>  >>> Node 0 might be offline as well as any other numa node,
>  >>> in this case kernel cannot handle memory allocation and crashes.
>  >>>
>  >>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>  >>> Fixes: 0c3f061c195c ("of: implement of_node_to_nid as a weak function")
>  >>> ---
>  >>>   drivers/of/base.c  |    2 +-
>  >>>   include/linux/of.h |    5 ++++-
>  >>>   2 files changed, 5 insertions(+), 2 deletions(-)
>  >>>
>  >>> diff --git a/drivers/of/base.c b/drivers/of/base.c
>  >>> index 8f165b112e03..51f4bd16e613 100644
>  >>> --- a/drivers/of/base.c
>  >>> +++ b/drivers/of/base.c
>  >>> @@ -89,7 +89,7 @@ EXPORT_SYMBOL(of_n_size_cells);
>  >>>   #ifdef CONFIG_NUMA
>  >>>   int __weak of_node_to_nid(struct device_node *np)
>  >>>   {
>  >>> -       return numa_node_id();
>  >>> +       return NUMA_NO_NODE;
>  >>
>  >>
>  >> This is going to break any NUMA machine that enables OF and expects
>  >> the weak function to work.
>  >
>  >
>  > Why? NUMA_NO_NODE == -1 -- this's standard "no-affinity" signal.
>  > As I see powerpc/sparc versions of of_node_to_nid returns -1 if they
>  > cannot find out which node should be used.
> Ah, I was thinking those platforms were relying on the default
> implementation. I guess any real NUMA support is going to need to
> override this function. The arm64 patch series does that as well. We
> need to be sure this change is correct for metag which appears to be
> the only other OF enabled platform with NUMA support.
> In that case, then there is little reason to keep the inline and we
> can just always enable the weak function (with your change). It is
> slightly less optimal, but the few callers hardly appear to be hot
> paths.
> Rob
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
