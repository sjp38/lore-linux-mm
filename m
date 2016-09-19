Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id A0C6B6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 13:41:50 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cg13so3542419pac.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:41:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o3si237698pav.101.2016.09.19.10.41.49
        for <linux-mm@kvack.org>;
        Mon, 19 Sep 2016 10:41:49 -0700 (PDT)
Message-ID: <57E02349.10703@arm.com>
Date: Mon, 19 Sep 2016 18:41:29 +0100
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Arm64 boot fail with numa enable in BIOS
References: <7618d76d-bfa8-d8aa-59aa-06f9d90c1a98@huawei.com> <20160919140709.GA17464@leverpostej>
In-Reply-To: <20160919140709.GA17464@leverpostej>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, catalin.marinas@arm.com

On 19/09/16 15:07, Mark Rutland wrote:
> On Mon, Sep 19, 2016 at 09:05:26PM +0800, Yisheng Xie wrote:
>> For the crash log, it seems caused by error number of cpumask.
>> Any ideas about it?

> Much earlier in your log, there was a (non-fatal) warning, as below. Do
> you see this without NUMA/SRAT enabled in your FW?

>> [    0.297337] Detected PIPT I-cache on CPU1
>> [    0.297347] GICv3: CPU1: found redistributor 10001 region 1:0x000000004d140000
>> [    0.297356] CPU1: Booted secondary processor [410fd082]
>> [    0.297375] ------------[ cut here ]------------
>> [    0.320390] WARNING: CPU: 1 PID: 0 at ./include/linux/cpumask.h:121 gic_raise_softirq+0x128/0x17c
>> [    0.329356] Modules linked in:
>> [    0.332434] 
>> [    0.333932] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.8.0-rc4-00163-g803ea3a #21
>> [    0.341581] Hardware name: Hisilicon Hi1616 Evaluation Board (DT)
>> [    0.347735] task: ffff8013e9dd0000 task.stack: ffff8013e9dcc000
>> [    0.353714] PC is at gic_raise_softirq+0x128/0x17c
>> [    0.358550] LR is at gic_raise_softirq+0xa0/0x17c

I've seen this first trace when built with DEBUG_PER_CPU_MAPS. My version of
this trace[0] was just noise due to gic_compute_target_list() and
gic_raise_softirq() sharing an iterator.

This patch silenced it for me:
https://lkml.org/lkml/2016/9/19/623

Yours may be a different problem with the same symptom.


Thanks,

James


[0] gicv3 trace when built with DEBUG_PER_CPU_MAPS
[    3.077738] GICv3: CPU1: found redistributor 1 region 0:0x000000002f120000
[    3.077943] CPU1: Booted secondary processor [410fd0f0]
[    3.078542] ------------[ cut here ]------------
[    3.078746] WARNING: CPU: 1 PID: 0 at ../include/linux/cpumask.h:121
gic_raise_softirq+0x12c/0x170
[    3.078812] Modules linked in:
[    3.078869]
[    3.078930] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.8.0-rc5+ #5188
[    3.078994] Hardware name: Foundation-v8A (DT)
[    3.079059] task: ffff80087a1a0080 task.stack: ffff80087a19c000
[    3.079145] PC is at gic_raise_softirq+0x12c/0x170
[    3.079226] LR is at gic_raise_softirq+0xa4/0x170


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
