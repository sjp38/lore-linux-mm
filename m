Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3C26B7AD4
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 11:17:37 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id 62so383180otr.14
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 08:17:37 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g5si285911otn.228.2018.12.06.08.17.36
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 08:17:36 -0800 (PST)
Date: Thu, 6 Dec 2018 16:17:30 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v7 14/25] arm64: KVM/mm: Move SEA handling behind a
 single 'claim' interface
Message-ID: <20181206161730.GM54495@arrakis.emea.arm.com>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-15-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-15-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, Rafael Wysocki <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Fan Wu <wufan@codeaurora.org>, Xie XiuQi <xiexiuqi@huawei.com>, Marc Zyngier <marc.zyngier@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Dongjiu Geng <gengdongjiu@huawei.com>, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, Len Brown <lenb@kernel.org>

On Mon, Dec 03, 2018 at 06:06:02PM +0000, James Morse wrote:
> To split up APEIs in_nmi() path, the caller needs to always be
> in_nmi(). Add a helper to do the work and claim the notification.
> 
> When KVM or the arch code takes an exception that might be a RAS
> notification, it asks the APEI firmware-first code whether it wants
> to claim the exception. A future kernel-first mechanism may be queried
> afterwards, and claim the notification, otherwise we fall through
> to the existing default behaviour.
> 
> The NOTIFY_SEA code was merged before considering multiple, possibly
> interacting, NMI-like notifications and the need to consider kernel
> first in the future. Make the 'claiming' behaviour explicit.
> 
> Restructuring the APEI code to allow multiple NMI-like notifications
> means any notification that might interrupt interrupts-masked
> code must always be wrapped in nmi_enter()/nmi_exit(). This will
> allow APEI to use in_nmi() to use the right fixmap entries.
> 
> Mask SError over this window to prevent an asynchronous RAS error
> arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> Acked-by: Marc Zyngier <marc.zyngier@arm.com>
> Tested-by: Tyler Baicar <tbaicar@codeaurora.org>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
