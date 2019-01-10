Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 84F2E8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:23:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e12so4789985edd.16
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 10:23:03 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x55si3735583eda.76.2019.01.10.10.23.01
        for <linux-mm@kvack.org>;
        Thu, 10 Jan 2019 10:23:01 -0800 (PST)
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
Date: Thu, 10 Jan 2019 18:22:56 +0000
MIME-Version: 1.0
In-Reply-To: <20181211183634.GO27375@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>, baicar.tyler@gmail.com

Hi Boris,

(CC: +Tyler)

On 11/12/2018 18:36, Borislav Petkov wrote:
> On Mon, Dec 03, 2018 at 06:05:58PM +0000, James Morse wrote:
>> ACPI has a GHESv2 which is used on hardware reduced platforms to
>> explicitly acknowledge that the memory for CPER records has been
>> consumed. This lets an external agent know it can re-use this
>> memory for something else.
>>
>> Previously notify_nmi and the estatus queue didn't do this as
>> they were never used on hardware reduced platforms. Once we move
>> notify_sea over to use the estatus queue, it may become necessary.
>>
>> Add the call. This is safe for use in NMI context as the
>> read_ack_register is pre-mapped by ghes_new() before the
>> ghes can be added to an RCU list, and then found by the
>> notification handler.

>> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
>> index 366dbdd41ef3..15d94373ba72 100644
>> --- a/drivers/acpi/apei/ghes.c
>> +++ b/drivers/acpi/apei/ghes.c
>> @@ -926,6 +926,10 @@ static int _in_nmi_notify_one(struct ghes *ghes)
>>  	__process_error(ghes);
>>  	ghes_clear_estatus(ghes, buf_paddr);
>>  
>> +	if (is_hest_type_generic_v2(ghes) && ghes_ack_error(ghes->generic_v2))
> 
> Since ghes_ack_error() is always prepended with this check, you could
> push it down into the function:
> 
> ghes_ack_error(ghes)
> ...
> 
> 	if (!is_hest_type_generic_v2(ghes))
> 		return 0;
> 
> and simplify the two callsites :)

Great idea! ...

.. huh. Turns out for ghes_proc() we discard any errors other than ENOENT from
ghes_read_estatus() if is_hest_type_generic_v2(). This masks EIO.

Most of the error sources discard the result, the worst thing I can find is
ghes_irq_func() will return IRQ_HANDLED, instead of IRQ_NONE when we didn't
really handle the IRQ. They're registered as SHARED, but I don't have an example
of what goes wrong next.

I think this will also stop the spurious handling code kicking in to shut it up
if its broken and screaming. Unlikely, but not impossible.

Fixed in a prior patch, with Boris' suggestion, ghes_proc()s tail ends up look
like this:
----------------------%<----------------------
diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 0321d9420b1e..8d1f9930b159 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -700,18 +708,11 @@ static int ghes_proc(struct ghes *ghes)

 out:
        ghes_clear_estatus(ghes, buf_paddr);
+       if (rc != -ENOENT)
+               rc_ack = ghes_ack_error(ghes);

-       if (rc == -ENOENT)
-               return rc;
-
-       /*
-        * GHESv2 type HEST entries introduce support for error acknowledgment,
-        * so only acknowledge the error if this support is present.
-        */
-       if (is_hest_type_generic_v2(ghes))
-               return ghes_ack_error(ghes->generic_v2);
-
-       return rc;
+       /* If rc and rc_ack failed, return the first one */
+       return rc ? rc : rc_ack;
 }
----------------------%<----------------------


Thanks,

James
