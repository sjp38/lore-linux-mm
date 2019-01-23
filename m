Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB9F8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:33:10 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f17so1262491edm.20
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:33:10 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f2-v6si5022824eje.129.2019.01.23.10.33.08
        for <linux-mm@kvack.org>;
        Wed, 23 Jan 2019 10:33:08 -0800 (PST)
Subject: Re: [PATCH v7 20/25] ACPI / APEI: Use separate fixmap pages for arm64
 NMI-like notifications
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-21-james.morse@arm.com>
 <20190121172743.GN29166@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <bee87ef4-60ae-d4a4-2855-159543072fc5@arm.com>
Date: Wed, 23 Jan 2019 18:33:02 +0000
MIME-Version: 1.0
In-Reply-To: <20190121172743.GN29166@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

Hi Boris,

On 21/01/2019 17:27, Borislav Petkov wrote:
> On Mon, Dec 03, 2018 at 06:06:08PM +0000, James Morse wrote:
>> Now that ghes notification helpers provide the fixmap slots and
>> take the lock themselves, multiple NMI-like notifications can
>> be used on arm64.
>>
>> These should be named after their notification method as they can't
>> all be called 'NMI'. x86's NOTIFY_NMI already is, change the SEA
>> fixmap entry to be called FIX_APEI_GHES_SEA.
>>
>> Future patches can add support for FIX_APEI_GHES_SEI and
>> FIX_APEI_GHES_SDEI_{NORMAL,CRITICAL}.
>>
>> Because all of ghes.c builds on both architectures, provide a
>> constant for each fixmap entry that the architecture will never
>> use.

>> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
>> index 849da0d43a21..6cbf9471b2a2 100644
>> --- a/drivers/acpi/apei/ghes.c
>> +++ b/drivers/acpi/apei/ghes.c
>> @@ -85,6 +85,14 @@
>>  	((struct acpi_hest_generic_status *)				\
>>  	 ((struct ghes_estatus_node *)(estatus_node) + 1))
>>  
>> +/* NMI-like notifications vary by architecture. Fill in the fixmap gaps */
>> +#ifndef CONFIG_HAVE_ACPI_APEI_NMI
>> +#define FIX_APEI_GHES_NMI	-1
>> +#endif
>> +#ifndef CONFIG_ACPI_APEI_SEA
>> +#define FIX_APEI_GHES_SEA	-1
> 
> I'm guessing those -1 are going to cause __set_fixmap() to fail, right?

It shouldn't be possible, these are just to give the compiler something int
shaped to work with, until it prunes all the callers.

But for arm64, yes if would fail. -1 shouldn't alias an existing entry, and it
will get caught by:
| BUG_ON(idx <= FIX_HOLE || idx >= __end_of_fixed_addresses);

I wanted BUILD_BUG_ON() here, as any user of these should be optimised out, but
the compiler choked on that.

__end_of_fixed_addresses would be a better arch-agnostic invalid value. It has
to be defined as the last value in the enum for core code's fix_to_virt() to work.


These two look like something left behind from when we had different #ifdeffery.
The users of these two are now behind arch specific #ifdefs that since patch 12
of this series, can't be turned off, so I can remove these.

We do need them for SDEI, as it is relying on IS_ENABLED() and the compiler's
dead code elimination. But the compiler wants that symbol to have the right type
before it gets that far.


|#define FIX_APEI_GHES_SDEI_NORMAL      (BUILD_BUG(), -1)

Was the best I had, but this trips the BUILD_BUG() too early.
With it, x86 BUILD_BUG()s. With just the -1 the path gets pruned out, and there
are no 'sdei' symbols in the object file.

...at this point, I stopped caring!


> I'm wondering if we could catch that situation in ghes_map() already to
> protect ourselves against future changes in the fixmap code...

We already skip registering notifiers if the kconfig option wasn't selected.

We can't catch this at compile time, as the dead-code elimination seems to
happen in multiple passes.

I'll switch the SDEI ones to __end_of_fixed_addresses, as both architectures
BUG() when they see this.


Thanks,

James
