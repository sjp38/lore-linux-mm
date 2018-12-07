Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id A31E78E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 12:29:03 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id g11so2131966otp.17
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 09:29:03 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s30si1692249otc.181.2018.12.07.09.29.01
        for <linux-mm@kvack.org>;
        Fri, 07 Dec 2018 09:29:01 -0800 (PST)
Subject: Re: [PATCH V5 5/7] arm64: mm: Prevent mismatched 52-bit VA support
References: <20181206225042.11548-1-steve.capper@arm.com>
 <20181206225042.11548-6-steve.capper@arm.com>
 <81860712-ff5f-5a51-d39e-9db9e3d31a26@arm.com>
 <20181207152529.GB2682@edgewater-inn.cambridge.arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <be06b735-c6b4-1520-73f6-02a3a8e8af45@arm.com>
Date: Fri, 7 Dec 2018 17:28:58 +0000
MIME-Version: 1.0
In-Reply-To: <20181207152529.GB2682@edgewater-inn.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Steve Capper <steve.capper@arm.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, ard.biesheuvel@linaro.org, jcm@redhat.com



On 07/12/2018 15:26, Will Deacon wrote:
> On Fri, Dec 07, 2018 at 10:47:57AM +0000, Suzuki K Poulose wrote:
>> On 12/06/2018 10:50 PM, Steve Capper wrote:
>>> For cases where there is a mismatch in ARMv8.2-LVA support between CPUs
>>> we have to be careful in allowing secondary CPUs to boot if 52-bit
>>> virtual addresses have already been enabled on the boot CPU.
>>>
>>> This patch adds code to the secondary startup path. If the boot CPU has
>>> enabled 52-bit VAs then ID_AA64MMFR2_EL1 is checked to see if the
>>> secondary can also enable 52-bit support. If not, the secondary is
>>> prevented from booting and an error message is displayed indicating why.
>>>
>>> Technically this patch could be implemented using the cpufeature code
>>> when considering 52-bit userspace support. However, we employ low level
>>> checks here as the cpufeature code won't be able to run if we have
>>> mismatched 52-bit kernel va support.
>>>
>>> Signed-off-by: Steve Capper <steve.capper@arm.com>
>>>
>>
>> The patch looks good to me, except for one comment below.
>>
>>> ---
>>>
>>> Patch is new in V5 of the series
>>> ---
>>>    arch/arm64/kernel/head.S | 26 ++++++++++++++++++++++++++
>>>    arch/arm64/kernel/smp.c  |  5 +++++
>>>    2 files changed, 31 insertions(+)
>>>
>>> diff --git a/arch/arm64/kernel/head.S b/arch/arm64/kernel/head.S
>>> index f60081be9a1b..58fcc1edd852 100644
>>> --- a/arch/arm64/kernel/head.S
>>> +++ b/arch/arm64/kernel/head.S
>>> @@ -707,6 +707,7 @@ secondary_startup:
>>>    	/*
>>>    	 * Common entry point for secondary CPUs.
>>>    	 */
>>> +	bl	__cpu_secondary_check52bitva
>>>    	bl	__cpu_setup			// initialise processor
>>>    	adrp	x1, swapper_pg_dir
>>>    	bl	__enable_mmu
>>> @@ -785,6 +786,31 @@ ENTRY(__enable_mmu)
>>>    	ret
>>>    ENDPROC(__enable_mmu)
>>> +ENTRY(__cpu_secondary_check52bitva)
>>> +#ifdef CONFIG_ARM64_52BIT_VA
>>> +	ldr_l	x0, vabits_user
>>> +	cmp	x0, #52
>>> +	b.ne	2f > +
>>> +	mrs_s	x0, SYS_ID_AA64MMFR2_EL1
>>> +	and	x0, x0, #(0xf << ID_AA64MMFR2_LVA_SHIFT)
>>> +	cbnz	x0, 2f
>>> +
>>> +	adr_l	x0, va52mismatch
>>> +	mov	w1, #1
>>> +	strb	w1, [x0]
>>> +	dmb	sy
>>> +	dc	ivac, x0	// Invalidate potentially stale cache line
>>
>> You may have to clear this variable before a CPU is brought up to avoid
>> raising a false error message when another secondary CPU doesn't boot
>> for some other reason (say granule support) after a CPU failed with lack
>> of 52bitva. It is really a crazy corner case.
> 
> Can't we just follow the example set by the EL2 setup in the way that is
> uses __boot_cpu_mode? In that case, we only need one variable and you can
> detect a problem by comparing the two halves.

The only difference here is, the support is bolted at boot CPU time and hence
we need to verify each and every CPU, unlike the __boot_cpu_mode where we
check for mismatch after the SMP CPUs are brought up. If we decide to make
the choice later, something like that could work. The only caveat is the 52bit
kernel VA will have to do something like the above.

Cheers
Suzuki




> 
> Will
> 
