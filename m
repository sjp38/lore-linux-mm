Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7F26B026A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 12:38:03 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id g8-v6so6456849wmg.2
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:38:03 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id z7-v6si1323176wrg.391.2018.10.12.09.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 09:38:01 -0700 (PDT)
Date: Fri, 12 Oct 2018 18:37:56 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 10/18] ACPI / APEI: preparatory split of ghes->estatus
Message-ID: <20181012163756.GD580@zn.tnic>
References: <20180921221705.6478-1-james.morse@arm.com>
 <20180921221705.6478-11-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180921221705.6478-11-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

Nitpick:

Subject: Re: [PATCH v6 10/18] ACPI / APEI: preparatory split of ghes->estatus

Pls have an active formulation in your Subject and start it with a capital
letter, i.e., something like:

	"Split ghes->estatus in preparation for... "

On Fri, Sep 21, 2018 at 11:16:57PM +0100, James Morse wrote:
> The NMI-like notifications scribble over ghes->estatus, before
> copying it somewhere else. If this interrupts the ghes_probe() code
> calling ghes_proc() on each struct ghes, the data is corrupted.
> 
> We want the NMI-like notifications to use a queued estatus entry

Pls formulate commit messages in passive voice.

> from the beginning. To that end, break up any use of "ghes->estatus"
> so that all functions take the estatus as an argument.
> 
> This patch is just moving code around, no change in behaviour.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 82 ++++++++++++++++++++++------------------
>  1 file changed, 45 insertions(+), 37 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index adf7fd402813..586689cbc0fd 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -298,7 +298,9 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
>  	}
>  }
>  
> -static int ghes_read_estatus(struct ghes *ghes, int silent, int fixmap_idx)
> +static int ghes_read_estatus(struct ghes *ghes,
> +			     struct acpi_hest_generic_status *estatus,

acpi_hest_generic_status - geez, could this name have been any longer ?!

> +			     int silent, int fixmap_idx)
>  {
>  	struct acpi_hest_generic *g = ghes->generic;
>  	u64 buf_paddr;
> @@ -316,26 +318,26 @@ static int ghes_read_estatus(struct ghes *ghes, int silent, int fixmap_idx)
>  	if (!buf_paddr)
>  		return -ENOENT;
>  
> -	ghes_copy_tofrom_phys(ghes->estatus, buf_paddr,
> -			      sizeof(*ghes->estatus), 1, fixmap_idx);
> -	if (!ghes->estatus->block_status)
> +	ghes_copy_tofrom_phys(estatus, buf_paddr,
> +			      sizeof(*estatus), 1, fixmap_idx);

Yeah, let that line stick out - it is easier to follow the code this
way.

> +	if (!estatus->block_status)
>  		return -ENOENT;
>  
>  	ghes->buffer_paddr = buf_paddr;
>  	ghes->flags |= GHES_TO_CLEAR;
>  
>  	rc = -EIO;
> -	len = cper_estatus_len(ghes->estatus);
> -	if (len < sizeof(*ghes->estatus))
> +	len = cper_estatus_len(estatus);
> +	if (len < sizeof(*estatus))
>  		goto err_read_block;
>  	if (len > ghes->generic->error_block_length)
>  		goto err_read_block;
> -	if (cper_estatus_check_header(ghes->estatus))
> +	if (cper_estatus_check_header(estatus))
>  		goto err_read_block;
> -	ghes_copy_tofrom_phys(ghes->estatus + 1,
> -			      buf_paddr + sizeof(*ghes->estatus),
> -			      len - sizeof(*ghes->estatus), 1, fixmap_idx);
> -	if (cper_estatus_check(ghes->estatus))
> +	ghes_copy_tofrom_phys(estatus + 1,
> +			      buf_paddr + sizeof(*estatus),
> +			      len - sizeof(*estatus), 1, fixmap_idx);
> +	if (cper_estatus_check(estatus))
>  		goto err_read_block;
>  	rc = 0;
>  
> @@ -346,13 +348,15 @@ static int ghes_read_estatus(struct ghes *ghes, int silent, int fixmap_idx)
>  	return rc;
>  }
>  
> -static void ghes_clear_estatus(struct ghes *ghes, int fixmap_idx)
> +static void ghes_clear_estatus(struct ghes *ghes,
> +			       struct acpi_hest_generic_status *estatus,
> +			       int fixmap_idx)
>  {
> -	ghes->estatus->block_status = 0;
> +	estatus->block_status = 0;
>  	if (!(ghes->flags & GHES_TO_CLEAR))
>  		return;

<---- newline here.

> -	ghes_copy_tofrom_phys(ghes->estatus, ghes->buffer_paddr,
> -			      sizeof(ghes->estatus->block_status), 0, fixmap_idx);
> +	ghes_copy_tofrom_phys(estatus, ghes->buffer_paddr,
> +			      sizeof(estatus->block_status), 0, fixmap_idx);
>  	ghes->flags &= ~GHES_TO_CLEAR;
>  }
>  
> @@ -518,9 +522,10 @@ static int ghes_print_estatus(const char *pfx,
>  	return 0;
>  }
>  
> -static void __ghes_panic(struct ghes *ghes)
> +static void __ghes_panic(struct ghes *ghes,
> +			 struct acpi_hest_generic_status *estatus)

Yeah, let that one stick out too. That struct naming needs slimming.

>  {
> -	__ghes_print_estatus(KERN_EMERG, ghes->generic, ghes->estatus);
> +	__ghes_print_estatus(KERN_EMERG, ghes->generic, estatus);
>  
>  	/* reboot to log the error! */
>  	if (!panic_timeout)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
