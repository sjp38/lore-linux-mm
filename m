Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83EA46B0006
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:50:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n23-v6so4391994otl.2
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:50:44 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e23-v6si1083681oth.133.2018.10.03.10.50.43
        for <linux-mm@kvack.org>;
        Wed, 03 Oct 2018 10:50:43 -0700 (PDT)
Subject: Re: [PATCH v6 05/18] ACPI / APEI: Make estatus queue a Kconfig symbol
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-6-james.morse@arm.com> <20181001175956.GF7269@zn.tnic>
From: James Morse <james.morse@arm.com>
Message-ID: <a562d7c4-2e74-3a18-7fb0-ba8f40d2dce4@arm.com>
Date: Wed, 3 Oct 2018 18:50:36 +0100
MIME-Version: 1.0
In-Reply-To: <20181001175956.GF7269@zn.tnic>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

Hi Boris,

On 01/10/18 18:59, Borislav Petkov wrote:
> On Fri, Sep 21, 2018 at 11:16:52PM +0100, James Morse wrote:
>> Now that there are two users of the estatus queue, and likely to be more,
>> make it a Kconfig symbol selected by the appropriate notification. We
>> can move the ARCH_HAVE_NMI_SAFE_CMPXCHG checks in here too.
> 
> Ok, question: why do we need to complicate things at all? I mean, why do
> we even need a Kconfig symbol?

Before patch 4, this was behind CONFIG_HAVE_ACPI_APEI_NMI, (so it made use of an
existing kconfig symbol), and there was only one user x86:NMI.

The ACPI spec has four ~NMI notifications, so far the support for these in Linux
has been selectable separately. If you build the kernel without any of them then
this code would be unused, and generate warnings because all those users are
behind #ifdef too.


> This code is being used by two arches now so why not simply build it in
> unconditionally and be done with it. The couple of KB saved are simply
> not worth the effort, especially if it is going to end up being enabled
> on 99% of the setups...

I'm all in favour of letting the compiler work it out, but the existing ghes
code has #ifdef/#else all over the place. This is 'keeping the style'.
I assumed it was done this way to support an older compiler on x86, (I see that
jumped from 3.2 to 4.6 with commit cafa0010cd51)

We could strip the lot away to a few IS_ENABLED() in ghes_probe() and the
memory_failure()/AER calls if you'd prefer.


Thanks,

James
