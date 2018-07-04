Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8286B0003
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 10:36:50 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c23-v6so3858189oiy.3
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 07:36:50 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d187-v6si1284010oib.199.2018.07.04.07.36.48
        for <linux-mm@kvack.org>;
        Wed, 04 Jul 2018 07:36:49 -0700 (PDT)
Date: Wed, 4 Jul 2018 15:37:28 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v5 00/20] APEI in_nmi() rework and arm64 SDEI wire-up
Message-ID: <20180704143727.GI4828@arm.com>
References: <20180626170116.25825-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626170116.25825-1-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

Hi James,

On Tue, Jun 26, 2018 at 06:00:56PM +0100, James Morse wrote:
> The aim of this series is to wire arm64's SDEI into APEI.
> 
> On arm64 we have three APEI notifications that are NMI-like, and
> in the unlikely event that all three are supported by a platform,
> they can interrupt each other.
> The GHES driver shouldn't have to deal with this, so this series aims
> to make it re-entrant.
> 
> To do that, we refactor the estatus queue to allow multiple notifications
> to use it, then convert NOTIFY_SEA to always be described as NMI-like,
> and to use the estatus queue.
> 
> From here we push the locking and fixmap choices out to the notification
> functions, and remove the use of per-ghes estatus and flags. This removes
> the in_nmi() 'timebomb' in ghes_copy_tofrom_phys().
> 
> Things get sticky when an NMI notification needs to know how big the
> CPER records might be, before reading it. This series splits
> ghes_estatus_read() to let us peek at the buffer. A side effect of this
> is the 20byte header will get read twice. (how does it work today? it
> reads the records into a per-ghes worst-case sized buffer, allocates
> the correct size and copies the records. in_nmi() use of this per-ghes
> buffer needs eliminating).
> 
> One alternative was to trust firmware's 'max raw data length' and use
> that to allocate 'enough' memory. We don't use this value today, so its
> probably wrong on some sytem somewhere.
> 
> Since v4 patches 5,8-15 are new, otherwise changes are noted in the patch.

The little bits touching arch/arm64/ all look fine to me here, but it looks
like other patches need review separately and ultimately I suspect you're
going to route it via some other tree.

Let me know if you need me to help with anything.

Will
