Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C38AC6B0009
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 10:31:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id d95so3321637oic.22
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 07:31:58 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n38-v6si47719ote.248.2018.03.19.07.31.57
        for <linux-mm@kvack.org>;
        Mon, 19 Mar 2018 07:31:57 -0700 (PDT)
Message-ID: <5AAFC939.3010309@arm.com>
Date: Mon, 19 Mar 2018 14:29:13 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's add/remove
 and notify code
References: <20180215185606.26736-1-james.morse@arm.com> <20180215185606.26736-3-james.morse@arm.com> <20180301150144.GA4215@pd.tnic> <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com> <20180301223529.GA28811@pd.tnic> <5AA02C26.10803@arm.com> <20180308104408.GB21166@pd.tnic>
In-Reply-To: <20180308104408.GB21166@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi Borislav,

On 08/03/18 10:44, Borislav Petkov wrote:
> On Wed, Mar 07, 2018 at 06:15:02PM +0000, James Morse wrote:
>> Today its just x86 and arm64. arm64 doesn't have a hook to do this. I'm happy to
>> add an empty declaration or leave it under an ifdef until someone complains
>> about any behaviour I missed!
> 
> So I did some more staring at the code and I think oops_begin() is
> needed mainly, as you point out, to prevent two oops messages from
> interleaving. And yap, the other stuff with printk() is not true anymore
> because the commit which added oops_begin():
> 
>   81e88fdc432a ("ACPI, APEI, Generic Hardware Error Source POLL/IRQ/NMI notification type support")
> 
> still saw an NMI-unsafe printk. Which is long taken care of now.
> 
> So only the interleaving issue remains.
> 
> Which begs the question: how are you guys preventing the interleaving on
> arm64? Because arch/arm64/kernel/traps.c:200 grabs the die_lock too, so
> interleaving can happen on arm64 too, AFAICT.

die() messages are stopped from interleaving with each other by that die_lock.
panic()s atomic_cmpxchg() then panic_smp_self_stop() means panic() is
first-past-the-post.

So our problem is interleaving of the two. The sequence is roughly:
1. oops_begin(); // I'm going to panic()
2. printk(some stuff);
3. panic();

Everything we print at (2) gets batched up by vprintk_nmi(), and is only printed
from (3) when we call printk_safe_flush_on_panic().

... and now I spot there are two calls to printk_safe_flush_on_panic(), one of
which happens before any smp_send_stop() calls.

This means we can get interleaving with panic() as we flush the printk_safe
buffer before smp_send_stop(), and even if we change that a remote CPU may
refuse to die. (Both x86 and arm64 have timeouts in their smp_send_stop() code).


> And by that logic, you should technically grab that lock here too in
> _in_nmi_notify_one().

I don't think the die_lock really helps here, do we really want to wait for a
remote CPU to finish printing an OOPs about user-space's bad memory accesses,
before we bring the machine down due to this system-wide fatal RAS error? The
presence of firmware-first means we know this error, and any other oops are
unrelated.

Grabbing the die_lock doesn't stop remote CPUs printing messages via a mechanism
other than die()/_in_nmi_notify_one(). I think oops_begin() is just plastering
over a problem. (how come this exclusion isn't done by oops_enter()/oops_exit()?)

Isn't oops_begin() trying to guarantee any messages printk()d by this CPU appear
'with' the subsequent panic()? I can't see any way to stop a remote CPU from
messing this up by printk()ing in a loop with interrupts masked, preventing us
from smp_send_stop()ing it, and making it difficult to take the lock.

I'd like to leave this under the x86-ifdef for now. For arm64 it would be an
APEI specific arch hook to stop the arch code from printing some messages,
meanwhile the rest of the kernel is unaffected. I suspect this sort of thing
really needs support from printk(). (maybe some printk() severity that mutes
other CPUs, or redirects them to the printk_safe buffer).


Thanks,

James
