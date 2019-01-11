Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2FC8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 13:25:28 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so6164017edr.7
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:25:28 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t26si1783871edf.31.2019.01.11.10.25.26
        for <linux-mm@kvack.org>;
        Fri, 11 Jan 2019 10:25:26 -0800 (PST)
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
From: James Morse <james.morse@arm.com>
Message-ID: <32025682-f85a-58ef-7386-7ee23296b944@arm.com>
Date: Fri, 11 Jan 2019 18:25:21 +0000
MIME-Version: 1.0
In-Reply-To: <20190111174532.GI4729@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Tyler Baicar <baicar.tyler@gmail.com>
Cc: Linux ACPI <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi Boris,

On 11/01/2019 17:45, Borislav Petkov wrote:
> On Fri, Jan 11, 2019 at 10:32:23AM -0500, Tyler Baicar wrote:
>> The kernel would have no way of knowing what to do here.
> 
> What do you mean, there's no way of knowing what to do? It needs to
> clear registers so that the next error can get reported properly.
> 
> Or of the status read failed and it doesn't need to do anything, then it
> shouldn't.

I think we're speaking at cross-purposes. If the error-detecting-hardware has
some state, that's firmware's problem to deal with.
What we're dealing with here is the memory we read the error records from.


> Whatever it is, the kernel either needs to do something in the error
> case to clean up, or nothing if the firmware doesn't need anything done
> in the error case; *or* ack the error in the success case.

We ack it in the corrupt-record case too, because we are done with the memory.


> This should all be written down somewhere in that GHES v2
> spec/doc/writeup whatever, explaining what the OS is supposed to do to
> signal the error has been read by the OS.

I think it is. 18.3.2.8 of ACPI v6.2 (search for Generic Hardware Error Source
version 2", then below the table):
* OSPM detects error (via interrupt/exception or polling the block status)
* OSPM copies the error status block
* OSPM clears the block status field of the error status block
* OSPM acknowledges the error via Read Ack register

The ENOENT case is excluded by 'polling the block status'.
Unsurprisingly the spec doesn't consider the case that firmware generates
corrupt records!


Thanks,

James
