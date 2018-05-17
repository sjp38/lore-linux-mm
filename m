Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A85A6B04EA
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:37:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 44-v6so3110060wrt.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:37:30 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id g73-v6si4309870wrd.396.2018.05.17.06.37.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 06:37:29 -0700 (PDT)
Date: Thu, 17 May 2018 15:36:53 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 07/12] ACPI / APEI: Make the nmi_fixmap_idx per-ghes
 to allow multiple in_nmi() users
Message-ID: <20180517133653.GA27738@pd.tnic>
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-8-james.morse@arm.com>
 <20180505122719.GE3708@pd.tnic>
 <1511cfcc-dcd1-b3c5-01c7-6b6b8fb65b05@arm.com>
 <20180516110348.GA17092@pd.tnic>
 <7c871e15-689c-226d-760d-dd92614de2e9@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <7c871e15-689c-226d-760d-dd92614de2e9@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Tyler Baicar <tbaicar@codeaurora.org>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com, Thomas Gleixner <tglx@linutronix.de>

On Wed, May 16, 2018 at 03:51:14PM +0100, James Morse wrote:
> The first two overload existing architectural behavior, the third improves all
> this with a third standard option. Its the standard story!

:-)

> I thought this was safe because its just ghes_copy_tofrom_phys()s access to the
> fixmap slots that needs mutual exclusion.
>
> Polled and all the IRQ flavours are kept apart by the spin_lock_irqsave(), and
> the NMIs have their own fixmap entry. (This is fine until there is more than
> once source of NMI)

For example:

ghes_probe()

	switch (generic->notify.type) {

	...

        case ACPI_HEST_NOTIFY_NMI:
		ghes_nmi_add(ghes);
	}

	...

	ghes_proc();
	  ghes_read_estatus();
		 spin_lock_irqsave(&ghes_ioremap_lock_irq, flags);

		 memcpy...

	-> NMI

		ghes_notify_nmi();
		 ghes_read_estatus();
		 ..
		   if (in_nmi) {
			   raw_spin_lock(&ghes_ioremap_lock_nmi);

		...
	<- NMI

ghes->estatus from above, before the NMI fired, has gotten some nice
scribbling over. AFAICT.

Now, I don't know whether this can happen with the ARM facilities but if
they're NMI-like, I don't see why not.

Which means, that this code is not really reentrant and if should be
fixed to be callable from different contexts, then it should use private
buffers and be careful about locking.

Oh, and that

	if (in_nmi)
		lock()
	else
		lock_irqsave()

pattern is really yucky. And it is an explosion waiting to happen.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
