Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B64A6B0526
	for <linux-mm@kvack.org>; Thu, 17 May 2018 14:14:33 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id h70-v6so3414955oib.21
        for <linux-mm@kvack.org>; Thu, 17 May 2018 11:14:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j61-v6si1889422otc.457.2018.05.17.11.14.30
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 11:14:30 -0700 (PDT)
Subject: Re: [PATCH v3 07/12] ACPI / APEI: Make the nmi_fixmap_idx per-ghes to
 allow multiple in_nmi() users
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-8-james.morse@arm.com> <20180505122719.GE3708@pd.tnic>
 <1511cfcc-dcd1-b3c5-01c7-6b6b8fb65b05@arm.com>
 <20180516110348.GA17092@pd.tnic>
 <7c871e15-689c-226d-760d-dd92614de2e9@arm.com>
 <20180517133653.GA27738@pd.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <8a6fa0e4-98c5-6880-1611-f1ab0534bbbc@arm.com>
Date: Thu, 17 May 2018 19:11:21 +0100
MIME-Version: 1.0
In-Reply-To: <20180517133653.GA27738@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tyler Baicar <tbaicar@codeaurora.org>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, Thomas Gleixner <tglx@linutronix.de>

Hi Borislav,

On 17/05/18 14:36, Borislav Petkov wrote:
> On Wed, May 16, 2018 at 03:51:14PM +0100, James Morse wrote:
>> I thought this was safe because its just ghes_copy_tofrom_phys()s access to the
>> fixmap slots that needs mutual exclusion.

and here is where I was wrong: I was only looking at reading the data, we then
dump it in struct ghes assuming it can only be notified on once CPU at a time. Oops.

> For example:

> ghes->estatus from above, before the NMI fired, has gotten some nice
> scribbling over. AFAICT.

Yup, thanks for the example!


> Now, I don't know whether this can happen with the ARM facilities but if
> they're NMI-like, I don't see why not.

NOTIFY_SEA is synchronous so the error has to be something to do with the
instruction that was interrupted. In your example this would mean the APEI
code/data was corrupted, which there is little point trying to handle.

NOTIFY_{SEI, SDEI} on the other hand are asynchronous, so this could happen.


> Which means, that this code is not really reentrant and if should be
> fixed to be callable from different contexts, then it should use private
> buffers and be careful about locking.

... I need to go through this thing again to work out how the firmware-buffers
map on to estatus=>ghes ...


> Oh, and that
> 
> 	if (in_nmi)
> 		lock()
> 	else
> 		lock_irqsave()
> 
> pattern is really yucky. And it is an explosion waiting to happen.

The whole in_nmi()=>other-lock think looks like a hack to make a warning go
away. We could get the notification to take whatever lock is appropriate further
out, but it may mean some code duplication. (I'll put it on my list...)


Thanks,

James
