Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1EE8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:04:40 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id d11so4989109wrq.18
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:04:40 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id m12si358474wmd.167.2018.12.11.09.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:04:39 -0800 (PST)
Date: Tue, 11 Dec 2018 18:04:30 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 06/25] ACPI / APEI: Don't store CPER records physical
 address in struct ghes
Message-ID: <20181211170430.GK27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-7-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-7-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:54PM +0000, James Morse wrote:
> When CPER records are found the address of the records is stashed
> in the struct ghes. Once the records have been processed, this
> address is overwritten with zero so that it won't be processed
> again without being re-populated by firmware.
> 
> This goes wrong if a struct ghes can be processed concurrently,
> as can happen at probe time when an NMI occurs. If the NMI arrives
> on another CPU, the probing CPU may call ghes_clear_estatus() on the
> records before the handler had finished with them.
> Even on the same CPU, once the interrupted handler is resumed, it
> will call ghes_clear_estatus() on the NMIs records, this memory may
> have already been re-used by firmware.
> 
> Avoid this stashing by letting the caller hold the address. A
> later patch will do away with the use of ghes->flags in the
> read/clear code too.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> 
> ---
> Changes since v6:
>  * Moved earlier in the series
>  * Added buf_adder = 0 on all the error paths, and test for it in
>    ghes_estatus_clear() for extra sanity.
> ---
>  drivers/acpi/apei/ghes.c | 40 +++++++++++++++++++++++-----------------
>  include/acpi/ghes.h      |  1 -
>  2 files changed, 23 insertions(+), 18 deletions(-)

...

> @@ -349,17 +350,20 @@ static int ghes_read_estatus(struct ghes *ghes)
>  	if (rc)
>  		pr_warn_ratelimited(FW_WARN GHES_PFX
>  				    "Failed to read error status block!\n");
> +
>  	return rc;
>  }
>  
> -static void ghes_clear_estatus(struct ghes *ghes)
> +static void ghes_clear_estatus(struct ghes *ghes, u64 buf_paddr)
>  {
>  	ghes->estatus->block_status = 0;
>  	if (!(ghes->flags & GHES_TO_CLEAR))
>  		return;
> -	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
> -			      sizeof(ghes->estatus->block_status), 0);
> -	ghes->flags &= ~GHES_TO_CLEAR;

<---- newline here.

> +	if (buf_paddr) {

Also, you can save yourself an indendation level:

	if (!buf_paddr)
		return;

	ghes_copy...

> +		ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
> +				      sizeof(ghes->estatus->block_status), 0);
> +		ghes->flags &= ~GHES_TO_CLEAR;
> +	}
>  }

With that addressed:

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
