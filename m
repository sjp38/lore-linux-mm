Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C94F68E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:09:36 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so6213999eda.10
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:09:36 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d2-v6si1293734ejj.210.2019.01.11.10.09.34
        for <linux-mm@kvack.org>;
        Fri, 11 Jan 2019 10:09:34 -0800 (PST)
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
From: James Morse <james.morse@arm.com>
Message-ID: <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
Date: Fri, 11 Jan 2019 18:09:28 +0000
MIME-Version: 1.0
In-Reply-To: <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tyler Baicar <baicar.tyler@gmail.com>, Borislav Petkov <bp@alien8.de>
Cc: Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi guys,

On 11/01/2019 15:32, Tyler Baicar wrote:
> On Fri, Jan 11, 2019 at 7:03 AM Borislav Petkov <bp@alien8.de> wrote:
>> On Thu, Jan 10, 2019 at 04:01:27PM -0500, Tyler Baicar wrote:
>>> On Thu, Jan 10, 2019 at 1:23 PM James Morse <james.morse@arm.com> wrote:
>>>>>>
>>>>>> +    if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
>>>>>
>>>>> Since ghes_ack_error() is always prepended with this check, you could
>>>>> push it down into the function:
>>>>>
>>>>> ghes_ack_error(ghes)
>>>>> ...
>>>>>
>>>>>       if (!is_hest_type_generic_v2(ghes))
>>>>>               return 0;
>>>>>
>>>>> and simplify the two callsites :)
>>>>
>>>> Great idea! ...
>>>>
>>>> .. huh. Turns out for ghes_proc() we discard any errors other than ENOENT from
>>>> ghes_read_estatus() if is_hest_type_generic_v2(). This masks EIO.
>>>>
>>>> Most of the error sources discard the result, the worst thing I can find is
>>>> ghes_irq_func() will return IRQ_HANDLED, instead of IRQ_NONE when we didn't
>>>> really handle the IRQ. They're registered as SHARED, but I don't have an example
>>>> of what goes wrong next.
>>>>
>>>> I think this will also stop the spurious handling code kicking in to shut it up
>>>> if its broken and screaming. Unlikely, but not impossible.

[....]

>>> Looks good to me, I guess there's no harm in acking invalid error status blocks.

Great, I didn't miss something nasty...


>> Err, why?
> 
> If ghes_read_estatus() fails, then either there was no error populated or the
> error status block was invalid.
> If the error status block is invalid, then the kernel doesn't know what happened
> in hardware.

What do we mean by 'hardware' here? We're receiving a corrupt report of
something via memory.
The GHESv2 ack just means we're done with the memory. I think it exists because
the external-agent can't peek into the CPU to see if its returned from the
notification.


> I originally thought this was changing what's acked, but it's just changing the
> return value of ghes_proc() when ghes_read_estatus() returns -EIO.

Sorry, that will be due to my bad description.


>> I don't know what the firmware glue does on ARM but if I'd have to
>> remain logical - which is hard to do with firmware - the proper thing to
>> do would be this:
>>
>>         rc = ghes_read_estatus(ghes, &buf_paddr);
>>         if (rc) {
>>                 ghes_reset_hardware();
> 
> The kernel would have no way of knowing what to do here.

Is there anything wrong with what we do today? We stamp on the records so that
we don't processes them again. (especially if is polled), and we tell firmware
it can re-use this memory.

(I think we should return an error, or print a ratelimited warning for corrupt
records)


>>         }
>>
>>         /* clear estatus and bla bla */
>>
>>         /* Now, I'm in the success case: */
>>          ghes_ack_error();
>>
>>
>> This way, you have the error path clear of something unexpected happened
>> when reading the hardware, obvious and separated. ghes_reset_hardware()
>> clears the registers and does the necessary steps to put the hardware in
>> good state again so that it can report the next error.
>>
>> And the success path simply acks the error and does possibly the same
>> thing. The naming of the functions is important though, to denote what
>> gets called when.

I think this duplicates the record-stamping/acking. If there is anything in that
memory region, the action for processed/copied/ignored-because-its-corrupt is
the same.

We can return on ENOENT out earlier, as nothing needs doing in that case. Its
what the GHES_TO_CLEAR spaghetti is for, we can probably move the ack thing into
ghes_clear_estatus(), that way that thing means 'I'm done with this memory'.

Something like:
-------------------------
rc = ghes_read_estatus();
if (rc == -ENOENT)
	return 0;

if (!rc) {
	ghes_do_proc() and friends;
}

ghes_clear_estatus();

return rc;
-------------------------

We would no longer return errors from the ack code, I suspect that can only
happen for a corrupt gas, which we would have caught earlier as we rely on the
mapping being cached.



Thanks,

James
