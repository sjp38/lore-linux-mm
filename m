Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33E2E6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 13:17:43 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id n2so1590777oig.22
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 10:17:43 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v62si5342300otb.416.2018.03.07.10.17.42
        for <linux-mm@kvack.org>;
        Wed, 07 Mar 2018 10:17:42 -0800 (PST)
Message-ID: <5AA02C26.10803@arm.com>
Date: Wed, 07 Mar 2018 18:15:02 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's add/remove
 and notify code
References: <20180215185606.26736-1-james.morse@arm.com> <20180215185606.26736-3-james.morse@arm.com> <20180301150144.GA4215@pd.tnic> <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com> <20180301223529.GA28811@pd.tnic>
In-Reply-To: <20180301223529.GA28811@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Punit Agrawal <punit.agrawal@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi Borislav, Punit,

On 01/03/18 22:35, Borislav Petkov wrote:
> On Thu, Mar 01, 2018 at 06:06:59PM +0000, Punit Agrawal wrote:
>> The 64-bit support lives in arch/arm64 and the die() there doesn't
>> contain an oops_begin()/oops_end(). But the lack of oops_begin() on
>> arm64 doesn't really matter here.

>> One issue I see with calling die() is that it is defined in different
>> includes across various architectures, (e.g., include/asm/kdebug.h for
>> x86, include/asm/system_misc.h in arm64, etc.)
> 
> I don't think that's insurmountable.

I don't think die() helps us, its not quite the same as oops_begin()/panic(),
which means we're interpreting the APEI notification's severity differently,
depending on when we took it.


> The more important question is, can we do the same set of calls when
> panic severity on all architectures which support APEI or should we have
> arch-specific ghes_panic() callbacks or so.

I think the purpose of this oops_begin() is to ensure two CPUs calling
oops_begin() at the same time don't have their traces interleaved, unblanks the
screen and 'busts' any spinlocks printk() may need (console etc).

This code is called in_nmi(), printk() now supports this so it doesn't need its
locks busting.
When called in_nmi(), printk batches the messages into its per-cpu
printk_safe_seq_buf, which in our case is dumped by panic() using
printk_safe_flush_on_panic(). So provided we call panic(), the in_nmi() messages
from ghes.c are already batched, and printed behind panic()'s atomic_cmpxchg()
exclusion thing.

If your arm64 system has one of these futuristic 'screens', they get unblanked
when panic() calls console_verbose() and bust_spinlocks(1).


> As it is now, it would turn into a mess if we start with the ifdeffery
> and the different requirements architectures might have...

Today its just x86 and arm64. arm64 doesn't have a hook to do this. I'm happy to
add an empty declaration or leave it under an ifdef until someone complains
about any behaviour I missed!


Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
