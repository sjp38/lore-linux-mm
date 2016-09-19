Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1631A6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:45:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id mi5so308865324pab.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 07:45:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k65si5997617pfg.73.2016.09.19.07.45.41
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 07:45:41 -0700 (PDT)
Date: Mon, 19 Sep 2016 15:45:42 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC] Arm64 boot fail with numa enable in BIOS
Message-ID: <20160919144542.GK9005@arm.com>
References: <7618d76d-bfa8-d8aa-59aa-06f9d90c1a98@huawei.com>
 <20160919140709.GA17464@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919140709.GA17464@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, thunder.leizhen@huawei.com

On Mon, Sep 19, 2016 at 03:07:19PM +0100, Mark Rutland wrote:
> [adding LAKML, arm64 maintainers]

I've also looped in Euler ThunderTown, since (a) he's at Huawei and is
assumedly testing this stuff and (b) he has a fairly big NUMA patch
series doing the rounds (some of which I've queued).

> On Mon, Sep 19, 2016 at 09:05:26PM +0800, Yisheng Xie wrote:
> In future, please make sure to Cc LAKML along with relevant parties when
> sending arm64 patches/queries.
> 
> For everyone newly Cc'd, the original message (with attachments) can be
> found at:
> 
> http://lkml.kernel.org/r/7618d76d-bfa8-d8aa-59aa-06f9d90c1a98@huawei.com
> 
> > When I enable NUMA in BIOS for arm64, it failed to boot on v4.8-rc4-162-g071e31e.
> 
> That commit ID doesn't seem to be in mainline (I can't find it in my
> local tree). Which tree are you using? Do you have local patches
> applied?

That commit is in mainline:

  http://git.kernel.org/linus/071e31e

It would be nice to know if the problem also exists on the arm64
for-next/core branch.

Will


> I take it that by "enable NUMA in BIOS", you mean exposing SRAT to the
> OS?
> 
> > For the crash log, it seems caused by error number of cpumask.
> > Any ideas about it?
> 
> Much earlier in your log, there was a (non-fatal) warning, as below. Do
> you see this without NUMA/SRAT enabled in your FW? I don't see how the
> SRAT should affect the secondaries we try to bring online.
> 
> Given your MPIDRs have Aff2 bits set, I wonder if we've conflated a
> logical ID with a physical ID somewhere, and it just so happens that the
> NUMA code is more likely to poke something based on that.
> 
> Can you modify the warning in cpumask.h to dump the bad CPU number? That
> would make it fairly clear if that's the case.
> 
> Thanks,
> Mark.
> 
> > [    0.297337] Detected PIPT I-cache on CPU1
> > [    0.297347] GICv3: CPU1: found redistributor 10001 region 1:0x000000004d140000
> > [    0.297356] CPU1: Booted secondary processor [410fd082]
> > [    0.297375] ------------[ cut here ]------------
> > [    0.320390] WARNING: CPU: 1 PID: 0 at ./include/linux/cpumask.h:121 gic_raise_softirq+0x128/0x17c
> > [    0.329356] Modules linked in:
> > [    0.332434] 
> > [    0.333932] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.8.0-rc4-00163-g803ea3a #21
> > [    0.341581] Hardware name: Hisilicon Hi1616 Evaluation Board (DT)
> > [    0.347735] task: ffff8013e9dd0000 task.stack: ffff8013e9dcc000
> > [    0.353714] PC is at gic_raise_softirq+0x128/0x17c
> > [    0.358550] LR is at gic_raise_softirq+0xa0/0x17c
> > [    0.363298] pc : [<ffff00000838c124>] lr : [<ffff00000838c09c>] pstate: 200001c5
> > [    0.370770] sp : ffff8013e9dcfde0
> > [    0.374112] x29: ffff8013e9dcfde0 x28: 0000000000000000 
> > [    0.379476] x27: 000000000083207c x26: ffff000008ca5d70 
> > [    0.384841] x25: 0000000100000001 x24: ffff000008d63ff3 
> > [    0.390205] x23: 0000000000000000 x22: ffff000008cb0000 
> > [    0.395569] x21: ffff00000884edb0 x20: 0000000000000001 
> > [    0.400933] x19: 0000000100000000 x18: 0000000000000000 
> > [    0.406298] x17: 0000000000000000 x16: 0000000003010066 
> > [    0.411661] x15: ffff000008ca8000 x14: 0000000000000013 
> > [    0.417025] x13: 0000000000000000 x12: 0000000000000013 
> > [    0.422389] x11: 0000000000000013 x10: 0000000002e92aa7 
> > [    0.427754] x9 : 0000000000000000 x8 : ffff8413eb6ca668 
> > [    0.433118] x7 : ffff8413eb6ca690 x6 : 0000000000000000 
> > [    0.438482] x5 : fffffffffffffffe x4 : 0000000000000000 
> > [    0.443845] x3 : 0000000000000040 x2 : 0000000000000041 
> > [    0.449209] x1 : 0000000000000000 x0 : 0000000000000001 
> > [    0.454573] 
> > [    0.456069] ---[ end trace b58e70f3295a8cd7 ]---
> > [    0.460730] Call trace:
> > [    0.463193] Exception stack(0xffff8013e9dcfc10 to 0xffff8013e9dcfd40)
> > [    0.469699] fc00:                                   0000000100000000 0001000000000000
> > [    0.477611] fc20: ffff8013e9dcfde0 ffff00000838c124 ffff000008d72228 ffff8013e9dcff70
> > [    0.485524] fc40: ffff000008d72608 ffff000008ab02a4 0000000000000000 0000000000000000
> > [    0.493436] fc60: 0000000000000000 3464313430303030 0000000000000000 0000000000000000
> > [    0.501348] fc80: ffff8013e9dcfc90 ffff00000836e678 ffff8013e9dcfca0 ffff00000836e910
> > [    0.509259] fca0: ffff8013e9dcfd30 ffff00000836ec10 0000000000000001 0000000000000000
> > [    0.517171] fcc0: 0000000000000041 0000000000000040 0000000000000000 fffffffffffffffe
> > [    0.525083] fce0: 0000000000000000 ffff8413eb6ca690 ffff8413eb6ca668 0000000000000000
> > [    0.532995] fd00: 0000000002e92aa7 0000000000000013 0000000000000013 0000000000000000
> > [    0.540907] fd20: 0000000000000013 ffff000008ca8000 0000000003010066 0000000000000000
> > [    0.548819] [<ffff00000838c124>] gic_raise_softirq+0x128/0x17c
> > [    0.554713] [<ffff00000808e1f4>] smp_send_reschedule+0x34/0x3c
> > [    0.560605] [<ffff0000080ddf18>] resched_curr+0x40/0x5c
> > [    0.565881] [<ffff0000080de650>] check_preempt_curr+0x58/0xa0
> > [    0.571685] [<ffff0000080de6b0>] ttwu_do_wakeup+0x18/0x80
> > [    0.577136] [<ffff0000080de790>] ttwu_do_activate+0x78/0x88
> > [    0.582763] [<ffff0000080df5cc>] try_to_wake_up+0x1f8/0x300
> > [    0.588390] [<ffff0000080df79c>] default_wake_function+0x10/0x18
> > [    0.594458] [<ffff0000080f3210>] __wake_up_common+0x5c/0x9c
> > [    0.600085] [<ffff0000080f3264>] __wake_up_locked+0x14/0x1c
> > [    0.605712] [<ffff0000080f3e10>] complete+0x40/0x5c
> > [    0.610635] [<ffff00000808dba8>] secondary_start_kernel+0x148/0x1a8
> > [    0.616965] [<00000000000831a8>] 0x831a8
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
