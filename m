Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4BE8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:36:45 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t2so1257484edb.22
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:36:45 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i21si997568edg.324.2019.01.23.10.36.43
        for <linux-mm@kvack.org>;
        Wed, 23 Jan 2019 10:36:43 -0800 (PST)
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <20190111174532.GI4729@zn.tnic>
 <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
 <20190111195800.GA11723@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <18138b57-51ba-c99c-5b8d-b263fb964714@arm.com>
Date: Wed, 23 Jan 2019 18:36:38 +0000
MIME-Version: 1.0
In-Reply-To: <20190111195800.GA11723@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Tyler Baicar <baicar.tyler@gmail.com>, Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi Boris,

On 11/01/2019 19:58, Borislav Petkov wrote:
> On Fri, Jan 11, 2019 at 06:25:21PM +0000, James Morse wrote:
>> We ack it in the corrupt-record case too, because we are done with the
>> memory.
> 
> Ok, so the only thing that we need to do unconditionally is ACK in order
> to free the memory. Or is there an exception to that set of steps in
> error handling?

Do you consider ENOENT an error? We don't ack in that case as the memory wasn't
in use.

For the other cases its because the records are bogus, but we still
unconditionally tell firmware we're done with them.


>> I think it is. 18.3.2.8 of ACPI v6.2 (search for Generic Hardware Error Source
>> version 2", then below the table):
>> * OSPM detects error (via interrupt/exception or polling the block status)
>> * OSPM copies the error status block
>> * OSPM clears the block status field of the error status block
>> * OSPM acknowledges the error via Read Ack register
>>
>> The ENOENT case is excluded by 'polling the block status'.
> 
> Ok, so we signal the absence of an error record with ENOENT.
> 
>         if (!buf_paddr)
>                 return -ENOENT;
> 
> Can that even happen?

Yes, for NOTIFY_POLLED its the norm. For the IRQ flavours that walk a list of
GHES, all but one of them will return ENOENT.


> Also, in that case, what would happen if we ACK the error anyway? We'd
> confuse the firmware?

No idea.

> I sure hope firmware is prepared for spurious ACKs :)

We could try it and see. It depends if firmware shares ack locations between
multiple GHES. We could ack an empty GHES, and it removes the records of one we
haven't looked at yet.


>> Unsurprisingly the spec doesn't consider the case that firmware generates
>> corrupt records!
> 
> You mean the EIO case?

Yup,

> Not surprised at all. But we do not report that record so all good.



Thanks,

James
