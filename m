Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3C06B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 05:44:24 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n12so2479139wmc.5
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 02:44:24 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id c49si14405279wra.305.2018.03.08.02.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Mar 2018 02:44:22 -0800 (PST)
Date: Thu, 8 Mar 2018 11:44:08 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's
 add/remove and notify code
Message-ID: <20180308104408.GB21166@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-3-james.morse@arm.com>
 <20180301150144.GA4215@pd.tnic>
 <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
 <20180301223529.GA28811@pd.tnic>
 <5AA02C26.10803@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5AA02C26.10803@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: Punit Agrawal <punit.agrawal@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

On Wed, Mar 07, 2018 at 06:15:02PM +0000, James Morse wrote:
> Today its just x86 and arm64. arm64 doesn't have a hook to do this. I'm happy to
> add an empty declaration or leave it under an ifdef until someone complains
> about any behaviour I missed!

So I did some more staring at the code and I think oops_begin() is
needed mainly, as you point out, to prevent two oops messages from
interleaving. And yap, the other stuff with printk() is not true anymore
because the commit which added oops_begin():

  81e88fdc432a ("ACPI, APEI, Generic Hardware Error Source POLL/IRQ/NMI notification type support")

still saw an NMI-unsafe printk. Which is long taken care of now.

So only the interleaving issue remains.

Which begs the question: how are you guys preventing the interleaving on
arm64? Because arch/arm64/kernel/traps.c:200 grabs the die_lock too, so
interleaving can happen on arm64 too, AFAICT.

And by that logic, you should technically grab that lock here too in
_in_nmi_notify_one().

Or?

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
