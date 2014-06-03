Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8B72D6B0036
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:12:17 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so6508875wiw.9
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:12:15 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id ek1si2511092wib.66.2014.06.03.07.12.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 07:12:09 -0700 (PDT)
Date: Tue, 3 Jun 2014 16:11:38 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: TASK_SIZE for !MMU
Message-ID: <20140603141138.GH16741@pengutronix.de>
References: <20140429100028.GH28564@pengutronix.de>
 <20140602085150.GA31147@pengutronix.de>
 <538DBC3F.9060207@uclinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <538DBC3F.9060207@uclinux.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Ungerer <gerg@uclinux.org>
Cc: Rabin Vincent <rabin@rab.in>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-xtensa@linux-xtensa.org, linux-m32r@ml.linux-m32r.org, linux-c6x-dev@linux-c6x.org, microblaze-uclinux@itee.uq.edu.au, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-m68k@lists.linux-m68k.org, kernel@pengutronix.de, uclinux-dist-devel@blackfin.uclinux.org, Andrew Morton <akpm@linux-foundation.org>, panchaxari <panchaxari.prasannamurthy@linaro.org>, Linus Walleij <linus.walleij@linaro.org>

Hello Greg,

thanks for your reply.

On Tue, Jun 03, 2014 at 10:14:55PM +1000, Greg Ungerer wrote:
> >>I think it would be OK to define TASK_SIZE to 0xffffffff for !MMU.
> >>blackfin, frv and m68k also do this. c6x does define it to 0xFFFFF000 to
> >>leave space for error codes.
> 
> I did that same change for m68k in commit cc24c40 ("m68knommu: remove
> size limit on non-MMU TASK_SIZE"). For similar reasons as you need to
> now.
ok.
 
> >>Thoughts?
> >The problem is that current linus/master (and also next) doesn't boot on
> >my ARM-nommu machine because the user string functions (strnlen_user,
> >strncpy_from_user et al.) refuse to work on strings above TASK_SIZE
> >which in my case also includes the XIP kernel image.
> 
> I seem to recall that we were not considering flash or anything else
> other than RAM when defining that original TASK_SIZE (back many, many
> years ago). Some of the address checks you list above made some sense
> if you had everything in RAM (though only upper bounds are checked).
> The thinking was some checking is better than none I suppose.
What is the actual meaning of TASK_SIZE? The maximal value of a valid
userspace address?

> Setting a hard coded memory size in CONFIG_DRAM_SIZE is not all that
> fantastic either...
Not sure what you mean? Having CONFIG_DRAM_SIZE at all or use it for
boundary checking?

CONFIG_DRAM_SIZE is hardly used apart from defining TASK_SIZE:

 - #define END_MEM (UL(CONFIG_DRAM_BASE) + CONFIG_DRAM_SIZE)
   which is only used to define MODULES_END. Ap
 - Some memory configuration using cp15 registers in
   arch/arm/mm/proc-arm{740,940,946}.S

For the former I'd say better use 0xffffffff, too. For the latter I
wonder if we should just drop CPU_ARM740T, CPU_ARM940T and CPU_ARM946E.
These are only selectable if ARCH_INTEGRATOR and are not selected by
other symbols. As ARCH_INTEGRATOR selects ARM_PATCH_PHYS_VIRT since
commit fe9891454473 (ARM: integrator: Default enable
ARM_PATCH_PHYS_VIRT, AUTO_ZRELADDR) for Linux 3.13 and
ARM_PATCH_PHYS_VIRT depends on MMU the Integrator-noMMU targets are
broken anyhow.

I will prepare a patch series with some cleanups.

Best regards
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
