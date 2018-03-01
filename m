Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 401EA6B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 13:07:04 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id x85so3468103oix.8
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 10:07:04 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w50si1421948ota.161.2018.03.01.10.07.02
        for <linux-mm@kvack.org>;
        Thu, 01 Mar 2018 10:07:02 -0800 (PST)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH 02/11] ACPI / APEI: Generalise the estatus queue's add/remove and notify code
References: <20180215185606.26736-1-james.morse@arm.com>
	<20180215185606.26736-3-james.morse@arm.com>
	<20180301150144.GA4215@pd.tnic>
Date: Thu, 01 Mar 2018 18:06:59 +0000
In-Reply-To: <20180301150144.GA4215@pd.tnic> (Borislav Petkov's message of
	"Thu, 1 Mar 2018 16:01:44 +0100")
Message-ID: <87sh9jbrgc.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: James Morse <james.morse@arm.com>, linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>

Hi Borislav,

Borislav Petkov <bp@alien8.de> writes:

> On Thu, Feb 15, 2018 at 06:55:57PM +0000, James Morse wrote:
>> Keep the oops_begin() call for x86,
>
> That oops_begin() in generic code is such a layering violation, grrr.
>
>> arm64 doesn't have one of these,
>> and APEI is the only thing outside arch code calling this..
>
> So looking at:
>
> arch/arm/kernel/traps.c:die()
>
> it does call oops_begin() ... oops_end() just like the x86 version of
> die().

You're looking at support for the 32-bit ARM systems. The 64-bit support
lives in arch/arm64 and the die() there doesn't contain an
oops_begin()/oops_end(). But the lack of oops_begin() on arm64 doesn't
really matter here.

>
> I'm wondering if we could move the code to do die() in a prepatch? My
> assumption is that all the arches should have die()... A quick grep does
> show a bunch of other arches having die()...

One issue I see with calling die() is that it is defined in different
includes across various architectures, (e.g., include/asm/kdebug.h for
x86, include/asm/system_misc.h in arm64, etc.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
