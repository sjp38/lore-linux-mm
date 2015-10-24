Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f54.google.com (mail-lf0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id B1BD86B0038
	for <linux-mm@kvack.org>; Sat, 24 Oct 2015 10:55:32 -0400 (EDT)
Received: by lfaz124 with SMTP id z124so109924073lfa.1
        for <linux-mm@kvack.org>; Sat, 24 Oct 2015 07:55:31 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id b8si6217466lfe.160.2015.10.24.07.55.30
        for <linux-mm@kvack.org>;
        Sat, 24 Oct 2015 07:55:30 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v2 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
Date: Sat, 24 Oct 2015 17:24:17 +0200
Message-ID: <5400324.7jYW1gKQ6y@vostro.rjw.lan>
In-Reply-To: <1445626439-8424-4-git-send-email-toshi.kani@hpe.com>
References: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com> <1445626439-8424-4-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>

On Friday, October 23, 2015 12:53:59 PM Toshi Kani wrote:
> In the case of memory error injection, einj_error_inject() checks
> if a target address is regular RAM.  Update this check to add a call
> to region_intersects_pmem() to verify if a target address range is
> NVDIMM.  This allows injecting a memory error to both RAM and NVDIMM
> for testing.
> 
> Also, the current RAM check, page_is_ram(), is replaced with
> region_intersects_ram() so that it can verify a target address
> range with the requested size.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>

This is fine by me, but adding RAS maintainers Tony and Boris.

Thanks,
Rafael


> ---
>  drivers/acpi/apei/einj.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
> index 0431883..ab55bbe 100644
> --- a/drivers/acpi/apei/einj.c
> +++ b/drivers/acpi/apei/einj.c
> @@ -519,7 +519,7 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
>  			     u64 param3, u64 param4)
>  {
>  	int rc;
> -	unsigned long pfn;
> +	u64 base_addr, size;
>  
>  	/* If user manually set "flags", make sure it is legal */
>  	if (flags && (flags &
> @@ -545,10 +545,14 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
>  	/*
>  	 * Disallow crazy address masks that give BIOS leeway to pick
>  	 * injection address almost anywhere. Insist on page or
> -	 * better granularity and that target address is normal RAM.
> +	 * better granularity and that target address is normal RAM or
> +	 * NVDIMM.
>  	 */
> -	pfn = PFN_DOWN(param1 & param2);
> -	if (!page_is_ram(pfn) || ((param2 & PAGE_MASK) != PAGE_MASK))
> +	base_addr = param1 & param2;
> +	size = (~param2) + 1;
> +	if (((region_intersects_ram(base_addr, size) != REGION_INTERSECTS) &&
> +	     (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)) ||
> +	    ((param2 & PAGE_MASK) != PAGE_MASK))
>  		return -EINVAL;
>  
>  inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
