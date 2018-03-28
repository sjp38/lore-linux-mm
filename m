Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 403186B0005
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:33:00 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u16-v6so1612555oiv.10
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:33:00 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p20-v6si1213851otf.437.2018.03.28.09.32.57
        for <linux-mm@kvack.org>;
        Wed, 28 Mar 2018 09:32:58 -0700 (PDT)
Subject: Re: [PATCH v2 05/11] arm64: KVM/mm: Move SEA handling behind a single
 'claim' interface
References: <20180322181445.23298-1-james.morse@arm.com>
 <20180322181445.23298-6-james.morse@arm.com>
 <08744114-27c0-dc8c-0943-df3dcb80f4a6@arm.com>
From: James Morse <james.morse@arm.com>
Message-ID: <b9f16902-1aed-bcbb-3e13-d852c766baef@arm.com>
Date: Wed, 28 Mar 2018 17:30:07 +0100
MIME-Version: 1.0
In-Reply-To: <08744114-27c0-dc8c-0943-df3dcb80f4a6@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

Hi Marc,

On 26/03/18 18:49, Marc Zyngier wrote:
> On 22/03/18 18:14, James Morse wrote:
>> To ensure APEI always takes the same locks when processing a notification
>> we need the nmi-like callers to always call APEI in_nmi(). Add a helper
>> to do the work and claim the notification.
>>
>> When KVM or the arch code takes an exception that might be a RAS
>> notification, it asks the APEI firmware-first code whether it wants
>> to claim the exception. We can then go on to see if (a future)
>> kernel-first mechanism wants to claim the notification, before
>> falling through to the existing default behaviour.
>>
>> The NOTIFY_SEA code was merged before we had multiple, possibly
>> interacting, NMI-like notifications and the need to consider kernel
>> first in the future. Make the 'claiming' behaviour explicit.
>>
>> As we're restructuring the APEI code to allow multiple NMI-like
>> notifications, any notification that might interrupt interrupts-masked
>> code must always be wrapped in nmi_enter()/nmi_exit(). This allows APEI
>> to use in_nmi() to choose between the raw/regular spinlock routines.
>>
>> We mask SError over this window to prevent an asynchronous RAS error
>> arriving and tripping 'nmi_enter()'s BUG_ON(in_nmi()).

>> diff --git a/arch/arm64/include/asm/kvm_ras.h b/arch/arm64/include/asm/kvm_ras.h
>> index 5f72b07b7912..9d52bc333110 100644
>> --- a/arch/arm64/include/asm/kvm_ras.h
>> +++ b/arch/arm64/include/asm/kvm_ras.h
>> @@ -4,8 +4,26 @@
>>  #ifndef __ARM64_KVM_RAS_H__
>>  #define __ARM64_KVM_RAS_H__
>>  
>> +#include <linux/acpi.h>
>> +#include <linux/errno.h>
>>  #include <linux/types.h>
>>  
>> -int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr);
>> +#include <asm/acpi.h>
>> +
>> +/*
>> + * Was this synchronous external abort a RAS notification?
>> + * Returns '0' for errors handled by some RAS subsystem, or -ENOENT.
>> + *
>> + * Call with irqs unmaksed.

Self-Nit: unmasked.

>> + */
>> +static inline int kvm_handle_guest_sea(phys_addr_t addr, unsigned int esr)
>> +{
>> +	int ret = -ENOENT;
>> +
>> +	if (IS_ENABLED(CONFIG_ACPI_APEI_SEA))
>> +		ret = apei_claim_sea(NULL);
> 
> Nit: it is a bit odd to see this "IS_ENABLED(CONFIG_ACPI_APEI_SEA)"
> check both in this function and in the only other function this calls
> (apei_claim_sea). Could this somehow be improved by having a dummy
> apei_claim_sea if CONFIG_ACPI_APEI doesn't exist?

Good point. Your suggestion also avoids more #ifdefs in the C file, which is
what I was trying to avoid.


>> +
>> +	return ret;
>> +}
>>  
>>  #endif /* __ARM64_KVM_RAS_H__ */


> Otherwise:
> 
> Acked-by: Marc Zyngier <marc.zyngier@arm.com>

Thanks!


James
