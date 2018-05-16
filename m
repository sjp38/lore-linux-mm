Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 412176B033B
	for <linux-mm@kvack.org>; Wed, 16 May 2018 11:38:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f10-v6so689861pln.21
        for <linux-mm@kvack.org>; Wed, 16 May 2018 08:38:21 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s9-v6si2697563plr.477.2018.05.16.08.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 08:38:20 -0700 (PDT)
Subject: Re: [PATCH v3 07/12] ACPI / APEI: Make the nmi_fixmap_idx per-ghes to
 allow multiple in_nmi() users
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-8-james.morse@arm.com> <20180505122719.GE3708@pd.tnic>
 <1511cfcc-dcd1-b3c5-01c7-6b6b8fb65b05@arm.com>
 <20180516110348.GA17092@pd.tnic>
From: Tyler Baicar <tbaicar@codeaurora.org>
Message-ID: <39bde8c5-4dfb-c1b9-02a4-ba467539ea24@codeaurora.org>
Date: Wed, 16 May 2018 11:38:16 -0400
MIME-Version: 1.0
In-Reply-To: <20180516110348.GA17092@pd.tnic>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, Thomas Gleixner <tglx@linutronix.de>

On 5/16/2018 7:05 AM, Borislav Petkov wrote:
> On Tue, May 08, 2018 at 09:45:01AM +0100, James Morse wrote:
>> Alternatively, I can put the fixmap-page and spinlock in some 'struct
>> ghes_notification' that only the NMI-like struct-ghes need. This is just moving
>> the indirection up a level, but it does pair the lock with the thing it locks,
>> and gets rid of assigning spinlock pointers.
> Keeping the lock and what it protects in one place certainly sounds
> better. I guess you could so something like this:
>
> struct ghes_fixmap {
>   union {
>    raw_spinlock_t nmi_lock;
>     spinlock_t lock;
>   };
>   void __iomem *(map)(struct ghes_fixmap *);
> };
>
> and assign the proper ghes_ioremap function to ->map.
>
> The spin_lock_irqsave() call in ghes_copy_tofrom_phys() is kinda
> questionable. Because we should have disabled interrupts so that you can
> do
>
> spin_lock(map->lock);
>
> Except that we do get called with IRQs on and looking at that call of
> ghes_proc() at the end of ghes_probe(), that's a deadlock waiting to
> happen.
>
> And that comes from:
>
>    77b246b32b2c ("acpi: apei: check for pending errors when probing GHES entries")
>
> Tyler, this can't work in any context: imagine the GHES NMI or IRQ or
> the timer fires while that ghes_proc() runs...
>
> What's up?
Hello Boris,

I haven't seen a deadlock from that, but it looks possible. What if the 
ghes_proc() call in ghes_probe()
is moved before the second switch statement? That way it is before the 
NMI/IRQ/poll is setup. At quick
glance I think that should avoid the deadlock and still provide the 
functionality that call was added for. I
can test that out if you all agree.

Thanks,
Tyler

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
