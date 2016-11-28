Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21F2F6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:59:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so352503989pgc.5
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:59:20 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 1si38595976pgy.294.2016.11.28.03.59.19
        for <linux-mm@kvack.org>;
        Mon, 28 Nov 2016 03:59:19 -0800 (PST)
Subject: Re: Kernel Panics on Xen ARM64 for Domain0 and Guest
References: <AM5PR0802MB2452C895A95FA378D6F3783D9E8A0@AM5PR0802MB2452.eurprd08.prod.outlook.com>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <420a44c0-f86f-e6ab-44af-93ada7e01b58@arm.com>
Date: Mon, 28 Nov 2016 11:59:15 +0000
MIME-Version: 1.0
In-Reply-To: <AM5PR0802MB2452C895A95FA378D6F3783D9E8A0@AM5PR0802MB2452.eurprd08.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Chen <Wei.Chen@arm.com>, "tj@kernel.org" <tj@kernel.org>, "zijun_hu@htc.com" <zijun_hu@htc.com>
Cc: "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Kaly Xin <Kaly.Xin@arm.com>, Steve Capper <Steve.Capper@arm.com>, Stefano Stabellini <sstabellini@kernel.org>

On 28/11/16 09:38, Wei Chen wrote:
> Hi,

Hi Wei,

> I have found a commit in "PER-CPU MEMORY ALLOCATOR" will panic the
> kernels that are runing on ARM64 Xen (include Domain0 and Guest).
> 
> commit 3ca45a46f8af8c4a92dd8a08eac57787242d5021
> percpu: ensure the requested alignment is power of two

It would have been useful to specify the tree used. In this case,
this commit comes from linux-next.

> 
> If I revert this commit, the Kernels can work properly on ARM64 Xen.
> 
> The following is the log:

Please try to copy the full log as the crash may be a
consequence of another error.

I gave a try and there was a warning ([1]) just before which
lead to the crash afterwards. This is because of the call to
__alloc_percpu in xen_guest_init returns NULL due to:

"illegal size (48) or align (48) for percpu allocation"

I think the best way to fix it is:

diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
index f193414..4986dc0 100644
--- a/arch/arm/xen/enlighten.c
+++ b/arch/arm/xen/enlighten.c
@@ -372,8 +372,7 @@ static int __init xen_guest_init(void)
         * for secondary CPUs as they are brought up.
         * For uniformity we use VCPUOP_register_vcpu_info even on cpu0.
         */
-       xen_vcpu_info = __alloc_percpu(sizeof(struct vcpu_info),
-                                              sizeof(struct vcpu_info));
+       xen_vcpu_info = alloc_percpu(struct vcpu_info);
        if (xen_vcpu_info == NULL)
                return -ENOMEM;
 
I will send proper patch later.

Cheers,

[1] 
[    0.023921] illegal size (48) or align (48) for percpu allocation
[    0.024167] ------------[ cut here ]------------
[    0.024344] WARNING: CPU: 0 PID: 1 at linux/mm/percpu.c:892 pcpu_alloc+0x88/0x6c0
[    0.024584] Modules linked in:
[    0.024708] 
[    0.024804] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.9.0-rc7-next-20161128 #473
[    0.025012] Hardware name: Foundation-v8A (DT)
[    0.025162] task: ffff80003d870000 task.stack: ffff80003d844000
[    0.025351] PC is at pcpu_alloc+0x88/0x6c0
[    0.025490] LR is at pcpu_alloc+0x88/0x6c0
[    0.025624] pc : [<ffff00000818e678>] lr : [<ffff00000818e678>] pstate: 60000045
[    0.025830] sp : ffff80003d847cd0
[    0.025946] x29: ffff80003d847cd0 x28: 0000000000000000 
[    0.026147] x27: 0000000000000000 x26: 0000000000000000 
[    0.026348] x25: 0000000000000000 x24: 0000000000000000 
[    0.026549] x23: 0000000000000000 x22: 00000000024000c0 
[    0.026752] x21: ffff000008e97000 x20: 0000000000000000 
[    0.026953] x19: 0000000000000030 x18: 0000000000000010 
[    0.027155] x17: 0000000000000a3f x16: 00000000deadbeef 
[    0.027357] x15: 0000000000000006 x14: ffff000088f79c3f 
[    0.027573] x13: ffff000008f79c4d x12: 0000000000000041 
[    0.027782] x11: 0000000000000006 x10: 0000000000000042 
[    0.027995] x9 : ffff80003d847a40 x8 : 6f697461636f6c6c 
[    0.028208] x7 : 6120757063726570 x6 : ffff000008f79c84 
[    0.028419] x5 : 0000000000000005 x4 : 0000000000000000 
[    0.028628] x3 : 0000000000000000 x2 : 000000000000017f 
[    0.028840] x1 : ffff80003d870000 x0 : 0000000000000035 
[    0.029056] 
[    0.029152] ---[ end trace 0000000000000000 ]---
[    0.029297] Call trace:
[    0.029403] Exception stack(0xffff80003d847b00 to 0xffff80003d847c30)
[    0.029621] 7b00: 0000000000000030 0001000000000000 ffff80003d847cd0 ffff00000818e678
[    0.029901] 7b20: 0000000000000002 0000000000000004 ffff000008f7c060 0000000000000035
[    0.030153] 7b40: ffff000008f79000 ffff000008c4cd88 ffff80003d847bf0 ffff000008101778
[    0.030402] 7b60: 0000000000000030 0000000000000000 ffff000008e97000 00000000024000c0
[    0.030647] 7b80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.030895] 7ba0: 0000000000000035 ffff80003d870000 000000000000017f 0000000000000000
[    0.031144] 7bc0: 0000000000000000 0000000000000005 ffff000008f79c84 6120757063726570
[    0.031394] 7be0: 6f697461636f6c6c ffff80003d847a40 0000000000000042 0000000000000006
[    0.031643] 7c00: 0000000000000041 ffff000008f79c4d ffff000088f79c3f 0000000000000006
[    0.031877] 7c20: 00000000deadbeef 0000000000000a3f
[    0.032051] [<ffff00000818e678>] pcpu_alloc+0x88/0x6c0
[    0.032229] [<ffff00000818ece8>] __alloc_percpu+0x18/0x20
[    0.032409] [<ffff000008d9606c>] xen_guest_init+0x174/0x2f4
[    0.032591] [<ffff0000080830f8>] do_one_initcall+0x38/0x130
[    0.032783] [<ffff000008d90c34>] kernel_init_freeable+0xe0/0x248
[    0.032995] [<ffff00000899a890>] kernel_init+0x10/0x100
[    0.033172] [<ffff000008082ec0>] ret_from_fork+0x10/0x50

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
