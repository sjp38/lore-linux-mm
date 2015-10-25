Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5E86D6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 06:45:18 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so79644794wic.0
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 03:45:18 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [78.46.96.112])
        by mx.google.com with ESMTP id w8si25136742wjy.23.2015.10.25.03.45.17
        for <linux-mm@kvack.org>;
        Sun, 25 Oct 2015 03:45:17 -0700 (PDT)
Date: Sun, 25 Oct 2015 11:45:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 3/3] ACPI/APEI/EINJ: Allow memory error injection to
 NVDIMM
Message-ID: <20151025104512.GC6084@nazgul.tnic>
References: <1445626439-8424-1-git-send-email-toshi.kani@hpe.com>
 <1445626439-8424-4-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1445626439-8424-4-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, dan.j.williams@intel.com, rjw@rjwysocki.net, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 23, 2015 at 12:53:59PM -0600, Toshi Kani wrote:
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
> ---
>  drivers/acpi/apei/einj.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)

...

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

Just a minor nitpick: please separate assignments from the if-statement
here with a \n.

> +	if (((region_intersects_ram(base_addr, size) != REGION_INTERSECTS) &&
> +	     (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)) ||
> +	    ((param2 & PAGE_MASK) != PAGE_MASK))
>  		return -EINVAL;
>  
>  inject:

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
