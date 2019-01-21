Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1854A8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:53:13 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id h11so11058514wrs.2
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:53:13 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id r68si33229027wme.104.2019.01.21.05.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 05:53:11 -0800 (PST)
Date: Mon, 21 Jan 2019 14:53:04 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 18/25] ACPI / APEI: Split ghes_read_estatus() to allow
 a peek at the CPER length
Message-ID: <20190121135304.GI29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-19-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-19-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:06:06PM +0000, James Morse wrote:
> ghes_read_estatus() reads the record address, then the record's
> header, then performs some sanity checks before reading the
> records into the provided estatus buffer.
> 
> To provide this estatus buffer the caller must know the size of the
> records in advance, or always provide a worst-case sized buffer as
> happens today for the non-NMI notifications.
> 
> Add a function to peek at the record's header to find the size. This
> will let the NMI path allocate the right amount of memory before reading
> the records, instead of using the worst-case size, and having to copy
> the records.
> 
> Split ghes_read_estatus() to create __ghes_peek_estatus() which
> returns the address and size of the CPER records.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> 
> Changes since v6:
>  * Additional buf_addr = 0 error handling
>  * Moved checking out of peek-estatus
>  * Reworded an error message so we can tell them apart
> ---
>  drivers/acpi/apei/ghes.c | 59 ++++++++++++++++++++++++++++++++--------
>  1 file changed, 47 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index b70f5fd962cc..07a12aac4c1a 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -277,12 +277,12 @@ static void ghes_copy_tofrom_phys(void *buffer, u64 paddr, u32 len,
>  	}
>  }
>  
> -static int ghes_read_estatus(struct ghes *ghes,
> -			     struct acpi_hest_generic_status *estatus,
> -			     u64 *buf_paddr, int fixmap_idx)
> +/* Read the CPER block and returning its address, and header in estatus. */

s/and /,/

> +static int __ghes_peek_estatus(struct ghes *ghes, int fixmap_idx,
> +			       struct acpi_hest_generic_status *estatus,

Also, we probably should stick to some order of arguments of those
functions for easier code staring, i.e.

	function_name(ghes, estatus, buf_paddr, fixmap_idx)

or so.

> +			       u64 *buf_paddr)
>  {
>  	struct acpi_hest_generic *g = ghes->generic;
> -	u32 len;
>  	int rc;
>  
>  	rc = apei_read(buf_paddr, &g->error_status_address);
> @@ -303,29 +303,64 @@ static int ghes_read_estatus(struct ghes *ghes,
>  		return -ENOENT;
>  	}
>  
> -	rc = -EIO;
> -	len = cper_estatus_len(estatus);
> +	return 0;
> +}
> +
> +/* Check the top-level record header has an appropriate size. */
> +int __ghes_check_estatus(struct ghes *ghes,
> +			 struct acpi_hest_generic_status *estatus)
> +{
> +	u32 len = cper_estatus_len(estatus);
> +	int rc = -EIO;
> +
>  	if (len < sizeof(*estatus))
>  		goto err_read_block;
>  	if (len > ghes->generic->error_block_length)
>  		goto err_read_block;
>  	if (cper_estatus_check_header(estatus))
>  		goto err_read_block;

Please make this chunk more user-friendly, maybe in a separate patch ontop:

/* Check the top-level record header has an appropriate size. */
int __ghes_check_estatus(struct ghes *ghes,
                         struct acpi_hest_generic_status *estatus)
{
        u32 len = cper_estatus_len(estatus);

        if (len < sizeof(*estatus)) {
                pr_warn_ratelimited(FW_WARN GHES_PFX "Truncated error status block!\n");
                return -EIO;
        }

        if (len > ghes->generic->error_block_length) {
                pr_warn_ratelimited(FW_WARN GHES_PFX "Invalid error status block length!\n");
                return -EIO;
        }

        if (cper_estatus_check_header(estatus)) {
                pr_warn_ratelimited(FW_WARN GHES_PFX "Invalid CPER header!\n");
                return -EIO;
        }

        return 0;
}

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
