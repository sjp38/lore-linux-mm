Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4796B0007
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:33:46 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id g13-v6so1718644otk.5
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:33:46 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p188-v6si1124222oic.263.2018.03.28.09.33.44
        for <linux-mm@kvack.org>;
        Wed, 28 Mar 2018 09:33:45 -0700 (PDT)
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com> <20180301150144.GA4215@pd.tnic>
 <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
 <20180301223529.GA28811@pd.tnic> <5AA02C26.10803@arm.com>
 <20180308104408.GB21166@pd.tnic> <5AAFC939.3010309@arm.com>
 <20180327172510.GB32184@pd.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <d15ba145-479c-ffde-14ad-ab7170d0f06e@arm.com>
Date: Wed, 28 Mar 2018 17:30:55 +0100
MIME-Version: 1.0
In-Reply-To: <20180327172510.GB32184@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi Borislav,

On 27/03/18 18:25, Borislav Petkov wrote:
> On Mon, Mar 19, 2018 at 02:29:13PM +0000, James Morse wrote:
>> I don't think the die_lock really helps here, do we really want to wait for a
>> remote CPU to finish printing an OOPs about user-space's bad memory accesses,
>> before we bring the machine down due to this system-wide fatal RAS error? The
>> presence of firmware-first means we know this error, and any other oops are
>> unrelated.
> 
> Hmm, now that you put it this way...

>> I'd like to leave this under the x86-ifdef for now. For arm64 it would be an
>> APEI specific arch hook to stop the arch code from printing some messages,
> 
> ... I'm thinking we should ignore the whole serializing of oopses and
> really dump that hw error ASAP. If it really is a fatal error, our main
> and only goal is to get it out as fast as possible so that it has the
> highest chance to appear on some screen or logging facility and thus the
> system can be serviced successfully.
> 
> And the other oopses have lower prio.

> Hmmm?

Yes, I agree. With firmware-first we know that errors the firmware takes first,
then notifies by NMI causing us to panic() must be a higher priority than
another oops.

I'll add a patch[0] to v3 making this argument and removing the #ifdef'd
oops_begin().


Thanks,

James


[0]
-----------------%<-----------------
    ACPI / APEI: don't wait to serialise with oops messages when panic()ing

    oops_begin() exists to group printk() messages with the oops message
    printed by die(). To reach this caller we know that platform firmware
    took this error first, then notified the OS via NMI with a 'panic'
    severity.

    Don't wait for another CPU to release the die-lock before we can
    panic(), our only goal is to print this fatal error and panic().

    This code is always called in_nmi(), and since 42a0bb3f7138 ("printk/nmi:
    generic solution for safe printk in NMI"), it has been safe to call
    printk() from this context. Messages are batched in a per-cpu buffer
    and printed via irq-work, or a call back from panic().

    Signed-off-by: James Morse <james.morse@arm.com>

diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
index 22f6ea5b9ad5..f348e6540960 100644
--- a/drivers/acpi/apei/ghes.c
+++ b/drivers/acpi/apei/ghes.c
@@ -34,7 +34,6 @@
 #include <linux/interrupt.h>
 #include <linux/timer.h>
 #include <linux/cper.h>
-#include <linux/kdebug.h>
 #include <linux/platform_device.h>
 #include <linux/mutex.h>
 #include <linux/ratelimit.h>
@@ -736,9 +735,6 @@ static int _in_nmi_notify_one(struct ghes *ghes)

        sev = ghes_severity(ghes->estatus->error_severity);
        if (sev >= GHES_SEV_PANIC) {
-#ifdef CONFIG_X86
-               oops_begin();
-#endif
                ghes_print_queued_estatus();
                __ghes_panic(ghes);
        }
-----------------%<-----------------
