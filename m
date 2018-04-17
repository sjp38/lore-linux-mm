Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD1C6B005A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 11:10:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c56so968887wrc.5
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 08:10:56 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id 33si3969282wrr.175.2018.04.17.08.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 08:10:54 -0700 (PDT)
Date: Tue, 17 Apr 2018 17:10:18 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180417151018.GE20840@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com>
 <20180301150144.GA4215@pd.tnic>
 <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
 <20180301223529.GA28811@pd.tnic>
 <5AA02C26.10803@arm.com>
 <20180308104408.GB21166@pd.tnic>
 <5AAFC939.3010309@arm.com>
 <20180327172510.GB32184@pd.tnic>
 <d15ba145-479c-ffde-14ad-ab7170d0f06e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <d15ba145-479c-ffde-14ad-ab7170d0f06e@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

On Wed, Mar 28, 2018 at 05:30:55PM +0100, James Morse wrote:
> -----------------%<-----------------
>     ACPI / APEI: don't wait to serialise with oops messages when panic()ing
> 
>     oops_begin() exists to group printk() messages with the oops message
>     printed by die(). To reach this caller we know that platform firmware
>     took this error first, then notified the OS via NMI with a 'panic'
>     severity.
> 
>     Don't wait for another CPU to release the die-lock before we can
>     panic(), our only goal is to print this fatal error and panic().
> 
>     This code is always called in_nmi(), and since 42a0bb3f7138 ("printk/nmi:
>     generic solution for safe printk in NMI"), it has been safe to call
>     printk() from this context. Messages are batched in a per-cpu buffer
>     and printed via irq-work, or a call back from panic().
> 
>     Signed-off-by: James Morse <james.morse@arm.com>
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index 22f6ea5b9ad5..f348e6540960 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -34,7 +34,6 @@
>  #include <linux/interrupt.h>
>  #include <linux/timer.h>
>  #include <linux/cper.h>
> -#include <linux/kdebug.h>
>  #include <linux/platform_device.h>
>  #include <linux/mutex.h>
>  #include <linux/ratelimit.h>
> @@ -736,9 +735,6 @@ static int _in_nmi_notify_one(struct ghes *ghes)
> 
>         sev = ghes_severity(ghes->estatus->error_severity);
>         if (sev >= GHES_SEV_PANIC) {
> -#ifdef CONFIG_X86
> -               oops_begin();
> -#endif
>                 ghes_print_queued_estatus();
>                 __ghes_panic(ghes);
>         }
> -----------------%<-----------------

Acked-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
