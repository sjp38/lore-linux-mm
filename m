Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D73D8E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 14:15:25 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id e141so6669102oig.11
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 11:15:25 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s192si5022164ois.124.2018.12.10.11.15.23
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 11:15:23 -0800 (PST)
From: James Morse <james.morse@arm.com>
Subject: Re: [PATCH v7 22/25] ACPI / APEI: Kick the memory_failure() queue for
 synchronous errors
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-23-james.morse@arm.com>
 <9d153a07-aa7a-6e0c-3bd3-994a66f9639a@huawei.com>
Message-ID: <5c775aa9-ea57-dea7-6083-c1e3fc160b29@arm.com>
Date: Mon, 10 Dec 2018 19:15:13 +0000
MIME-Version: 1.0
In-Reply-To: <9d153a07-aa7a-6e0c-3bd3-994a66f9639a@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: Borislav Petkov <bp@alien8.de>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Fan Wu <wufan@codeaurora.org>, Wang Xiongfeng <wangxiongfeng2@huawei.com>

Hi Xie XiuQi,

On 05/12/2018 02:02, Xie XiuQi wrote:
> On 2018/12/4 2:06, James Morse wrote:
>> memory_failure() offlines or repairs pages of memory that have been
>> discovered to be corrupt. These may be detected by an external
>> component, (e.g. the memory controller), and notified via an IRQ.
>> In this case the work is queued as not all of memory_failure()s work
>> can happen in IRQ context.
>>
>> If the error was detected as a result of user-space accessing a
>> corrupt memory location the CPU may take an abort instead. On arm64
>> this is a 'synchronous external abort', and on a firmware first
>> system it is replayed using NOTIFY_SEA.
>>
>> This notification has NMI like properties, (it can interrupt
>> IRQ-masked code), so the memory_failure() work is queued. If we
>> return to user-space before the queued memory_failure() work is
>> processed, we will take the fault again. This loop may cause platform
>> firmware to exceed some threshold and reboot when Linux could have
>> recovered from this error.
>>
>> If a ghes notification type indicates that it may be triggered again
>> when we return to user-space, use the task-work and notify-resume
>> hooks to kick the relevant memory_failure() queue before returning


>> @@ -407,7 +447,22 @@ static void ghes_handle_memory_failure(struct acpi_hest_generic_data *gdata, int
>>  
>>  	if (flags != -1)
>>  		memory_failure_queue(pfn, flags);
> 
> We may need to take MF_ACTION_REQUIRED flags for memory_failure() in SEA condition.

Hmmm, I'd forgotten about the extra flags. They're only used by x86's
do_machine_check(), which knows more about what is going on. I agree we do know
it should be a 'MF_ACTION_REQUIRED' for Synchronous-external-abort, but I'd
really like all the notifications to behave in the same way as we can't change
which notification firmware uses.
(This ghes_is_synchronous() affects when memory_failure() runs, not what it does.)

What happens if we miss MF_ACTION_REQUIRED? Surely the page still gets unmapped
as its PG_Poisoned, an AO signal may be pending, but if user-space touches the
page it will get an AR signal. Is this just about removing an extra AO signal to
user-space?

If we do need this, I'd like to pick it up from the CPER records, as x86's
NOTIFY_NMI looks like it covers both AO/AR cases. (as does NOTIFY_SDEI). The
Master/Target abort or Invalid-address types in the memory-error-section CPER
records look like the best bet.


> And there is no return value check for memory_failure() in memory_failure_work_func(),
> I'm not sure whether we need to check the return value.

What would we do if it fails? The reasons look fairly broad, -EBUSY can mean
"(page) still referenced by [..] users", 'thp split failed' or 'page already
poisoned'. I don't think the behaviour or return-codes are consistent enough to use.


> If the recovery fails here, we need to take other actions, such as force to send a SIGBUS signal.

We don't do this today. If it fixes some mis-behaviour, and we can key it from
something in the CPER records then I'm all ears!


Thanks,

James
