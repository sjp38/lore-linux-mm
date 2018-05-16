Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 190BF6B0342
	for <linux-mm@kvack.org>; Wed, 16 May 2018 12:49:13 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k13-v6so944500oiw.3
        for <linux-mm@kvack.org>; Wed, 16 May 2018 09:49:13 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f15-v6si1079544otj.28.2018.05.16.09.49.11
        for <linux-mm@kvack.org>;
        Wed, 16 May 2018 09:49:11 -0700 (PDT)
Subject: Re: [PATCH v4 00/12] APEI in_nmi() rework and arm64 SDEI wire-up
References: <20180516162829.14348-1-james.morse@arm.com>
From: James Morse <james.morse@arm.com>
Message-ID: <15bfc50c-c789-bd79-7495-d040a354d306@arm.com>
Date: Wed, 16 May 2018 17:46:04 +0100
MIME-Version: 1.0
In-Reply-To: <20180516162829.14348-1-james.morse@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org
Cc: kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On 16/05/18 17:28, James Morse wrote:
> The aim of this series is to wire arm64's SDEI into APEI.

... and I missed the 'l' from the beginning of the well know inux-mm@kvack.org
mailing list. I won't increase the spam by resending, please fix it when
pointing out my other mistakes!

Thanks,

James


> Since v3 the NMI fixmap entries and locks have moved into their own
> structure. This moves the indirection up from the 'lock', which should
> be more acceptable to polite society.
> Changes are noted in each patch.
> 
> This touches a few trees, so I'm not sure how best it should be merged.
> Patches 11 and 12 are reducing a race that is made worse by patch 4, I'd
> like them to arrive together, even though patch 11 doesn't depend on anything
> else in the series. A partial merge of this would  be 1-3 and 11.

[...]

> Patch 11 makes the reschedule to memory_failure() run as soon as possible.

[...]

> James Morse (12):
>   ACPI / APEI: Move the estatus queue code up, and under its own ifdef
>   ACPI / APEI: Generalise the estatus queue's add/remove and notify code
>   ACPI / APEI: don't wait to serialise with oops messages when
>     panic()ing
>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
>   ACPI / APEI: Make the nmi_fixmap_idx per-ghes to allow multiple
>     in_nmi() users
>   ACPI / APEI: Split fixmap pages for arm64 NMI-like notifications
>   firmware: arm_sdei: Add ACPI GHES registration helper
>   ACPI / APEI: Add support for the SDEI GHES Notification type
>   mm/memory-failure: increase queued recovery work's priority
>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
> 
>  arch/arm/include/asm/kvm_ras.h       |  14 +
>  arch/arm/include/asm/system_misc.h   |   5 -
>  arch/arm64/include/asm/acpi.h        |   4 +
>  arch/arm64/include/asm/daifflags.h   |   1 +
>  arch/arm64/include/asm/fixmap.h      |   8 +-
>  arch/arm64/include/asm/kvm_ras.h     |  24 ++
>  arch/arm64/include/asm/system_misc.h |   2 -
>  arch/arm64/kernel/acpi.c             |  49 ++++
>  arch/arm64/mm/fault.c                |  30 +-
>  drivers/acpi/apei/ghes.c             | 518 ++++++++++++++++++++---------------
>  drivers/firmware/arm_sdei.c          |  67 +++++
>  include/acpi/ghes.h                  |  17 ++
>  include/linux/arm_sdei.h             |   8 +
>  mm/memory-failure.c                  |  11 +-
>  virt/kvm/arm/mmu.c                   |   4 +-
>  15 files changed, 503 insertions(+), 259 deletions(-)
>  create mode 100644 arch/arm/include/asm/kvm_ras.h
>  create mode 100644 arch/arm64/include/asm/kvm_ras.h
> 
