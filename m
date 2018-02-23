Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10E466B000C
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:24:09 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id a32so4638648otj.5
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:24:09 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o50si983343oth.501.2018.02.23.10.24.07
        for <linux-mm@kvack.org>;
        Fri, 23 Feb 2018 10:24:07 -0800 (PST)
Message-ID: <5A905BAB.2060007@arm.com>
Date: Fri, 23 Feb 2018 18:21:31 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's add/remove
 and notify code
References: <20180215185606.26736-1-james.morse@arm.com>	<20180215185606.26736-3-james.morse@arm.com> <87sh9vzfdn.fsf@e105922-lin.cambridge.arm.com>
In-Reply-To: <87sh9vzfdn.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi Punit,

On 20/02/18 18:26, Punit Agrawal wrote:
> James Morse <james.morse@arm.com> writes:
> 
>> To support asynchronous NMI-like notifications on arm64 we need to use
>> the estatus-queue. These patches refactor it to allow multiple APEI
>> notification types to use it.
>>
>> Refactor the estatus queue's pool grow/shrink code and notification
>> routine from NOTIFY_NMI's handlers. This will allow another notification
>> method to use the estatus queue without duplicating this code.
>>
>> This patch adds rcu_read_lock()/rcu_read_unlock() around the list
>> list_for_each_entry_rcu() walker. These aren't strictly necessary as
>> the whole nmi_enter/nmi_exit() window is a spooky RCU read-side
>> critical section.
>>
>> Keep the oops_begin() call for x86, arm64 doesn't have one of these,
>> and APEI is the only thing outside arch code calling this..
>>
>> The existing ghes_estatus_pool_shrink() is folded into the new
>> ghes_estatus_queue_shrink_pool() as only the queue uses it.
>>
>> _in_nmi_notify_one() is separate from the rcu-list walker for a later
>> caller that doesn't need to walk a list.

>> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
>> index e42b587c509b..d3cc5bd5b496 100644
>> --- a/drivers/acpi/apei/ghes.c
>> +++ b/drivers/acpi/apei/ghes.c
>> @@ -749,6 +749,54 @@ static void __process_error(struct ghes *ghes)
>>  #endif
>>  }
>>  
>> +static int _in_nmi_notify_one(struct ghes *ghes)
>> +{
>> +	int sev;
>> +	int ret = -ENOENT;
> 
> If ret is initialised to 0 ...
> 
>> +
>> +	if (ghes_read_estatus(ghes, 1)) {
>> +		ghes_clear_estatus(ghes);
>> +		return ret;
> 
> and return -ENOENT here...
> 
>> +	} else {
>> +		ret = 0;
>> +	}
> 
> ... then the else block can be dropped.


Good point, this happened because I was trying to keep the same shape as the
existing notify_nmi() code as far as possible.


>> +
>> +	sev = ghes_severity(ghes->estatus->error_severity);
>> +	if (sev >= GHES_SEV_PANIC) {
>> +#ifdef CONFIG_X86
>> +		oops_begin();
>> +#endif
> 
> Can you use IS_ENABLED() here as well?

I didn't think that would build without an empty declaration for arm64, I
assumed it would generate an implicit-declaration-of warning. But, I've tried
it, and evidently today's toolchain does dead-code elimination before generating
implicit-declaration-of warnings...
I'd prefer to leave this (ugly as it is), to avoid warnings on a different
version of the compiler.


Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
