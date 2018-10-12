Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9326B0007
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:14:46 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id j17-v6so6030847wrm.11
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 10:14:46 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id j138-v6si1695570wmf.195.2018.10.12.10.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 10:14:45 -0700 (PDT)
Date: Fri, 12 Oct 2018 19:14:39 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 13/18] ACPI / APEI: Don't update struct ghes' flags in
 read/clear estatus
Message-ID: <20181012171439.GF580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-14-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-14-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Sep 21, 2018 at 11:17:00PM +0100, James Morse wrote:
> ghes_read_estatus() sets a flag in struct ghes if the buffer of
> CPER records needs to be cleared once the records have been
> processed. This global flags value is a problem if a struct ghes
> can be processed concurrently, as happens at probe time if an
> NMI arrives for the same error source.
> 
> The GHES_TO_CLEAR flags was only set at the same time as
> buffer_paddr, which is now owned by the caller and passed to
> ghes_clear_estatus(). Use this as the flag.
> 
> A non-zero buf_paddr returned by ghes_read_estatus() means
> ghes_clear_estatus() will clear this address. ghes_read_estatus()
> already checks for a read of error_status_address being zero,
> so we can never get CPER records written at zero.
> 
> After this ghes_clear_estatus() no longer needs the struct ghes.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 26 ++++++++++++--------------
>  include/acpi/ghes.h      |  1 -
>  2 files changed, 12 insertions(+), 15 deletions(-)

Nice.

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
