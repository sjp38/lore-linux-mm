Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f54.google.com (mail-oa0-f54.google.com [209.85.219.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB276B0031
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 07:57:48 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id j17so7698856oag.41
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 04:57:48 -0700 (PDT)
Received: from icp-osb-irony-out4.external.iinet.net.au (icp-osb-irony-out4.external.iinet.net.au. [203.59.1.220])
        by mx.google.com with ESMTP id l9si3974438obu.35.2014.06.04.04.57.46
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 04:57:47 -0700 (PDT)
Message-ID: <538F09B4.8090308@uclinux.org>
Date: Wed, 04 Jun 2014 21:57:40 +1000
From: Greg Ungerer <gerg@uclinux.org>
MIME-Version: 1.0
Subject: Re: TASK_SIZE for !MMU
References: <20140429100028.GH28564@pengutronix.de> <20140602085150.GA31147@pengutronix.de> <538DBC3F.9060207@uclinux.org> <20140603141138.GH16741@pengutronix.de>
In-Reply-To: <20140603141138.GH16741@pengutronix.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Cc: Rabin Vincent <rabin@rab.in>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-m32r@ml.linux-m32r.org, linux-c6x-dev@linux-c6x.org, microblaze-uclinux@itee.uq.edu.au, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-m68k@lists.linux-m68k.org, kernel@pengutronix.de, uclinux-dist-devel@blackfin.uclinux.org, Andrew Morton <akpm@linux-foundation.org>, panchaxari <panchaxari.prasannamurthy@linaro.org>, Linus Walleij <linus.walleij@linaro.org>


Hi Uwe,

On 04/06/14 00:11, Uwe Kleine-Konig wrote:
> On Tue, Jun 03, 2014 at 10:14:55PM +1000, Greg Ungerer wrote:
>>>> I think it would be OK to define TASK_SIZE to 0xffffffff for !MMU.
>>>> blackfin, frv and m68k also do this. c6x does define it to 0xFFFFF000 to
>>>> leave space for error codes.
>>
>> I did that same change for m68k in commit cc24c40 ("m68knommu: remove
>> size limit on non-MMU TASK_SIZE"). For similar reasons as you need to
>> now.
> ok.
>
>>>> Thoughts?
>>> The problem is that current linus/master (and also next) doesn't boot on
>>> my ARM-nommu machine because the user string functions (strnlen_user,
>>> strncpy_from_user et al.) refuse to work on strings above TASK_SIZE
>>> which in my case also includes the XIP kernel image.
>>
>> I seem to recall that we were not considering flash or anything else
>> other than RAM when defining that original TASK_SIZE (back many, many
>> years ago). Some of the address checks you list above made some sense
>> if you had everything in RAM (though only upper bounds are checked).
>> The thinking was some checking is better than none I suppose.
> What is the actual meaning of TASK_SIZE? The maximal value of a valid
> userspace address?

Yes (as Geert pointed out :-)
The limit of virtual userspace addresses.


>> Setting a hard coded memory size in CONFIG_DRAM_SIZE is not all that
>> fantastic either...
> Not sure what you mean? Having CONFIG_DRAM_SIZE at all or use it for
> boundary checking?

Having the DRAM size be a configure time constant. And as you have
found RAM isn't the only place in the physical address space that
code will necessarily access.


> CONFIG_DRAM_SIZE is hardly used apart from defining TASK_SIZE:
>
>   - #define END_MEM (UL(CONFIG_DRAM_BASE) + CONFIG_DRAM_SIZE)
>     which is only used to define MODULES_END. Ap
>   - Some memory configuration using cp15 registers in
>     arch/arm/mm/proc-arm{740,940,946}.S
>
> For the former I'd say better use 0xffffffff, too. For the latter I
> wonder if we should just drop CPU_ARM740T, CPU_ARM940T and CPU_ARM946E.
> These are only selectable if ARCH_INTEGRATOR and are not selected by
> other symbols. As ARCH_INTEGRATOR selects ARM_PATCH_PHYS_VIRT since
> commit fe9891454473 (ARM: integrator: Default enable
> ARM_PATCH_PHYS_VIRT, AUTO_ZRELADDR) for Linux 3.13 and
> ARM_PATCH_PHYS_VIRT depends on MMU the Integrator-noMMU targets are
> broken anyhow.
>
> I will prepare a patch series with some cleanups.

I have no idea how many people would be using those older ARM CPU types.
It was hard to get much interest for them in mainline even years ago.

Regards
Greg



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
