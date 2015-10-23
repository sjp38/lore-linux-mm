Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 90AC56B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:14:57 -0400 (EDT)
Received: by wicfv8 with SMTP id fv8so10605886wic.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:14:57 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id jx9si21589904wjb.10.2015.10.22.17.14.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 17:14:56 -0700 (PDT)
Received: by wijp11 with SMTP id p11so55152212wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:14:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1445556044-30322-4-git-send-email-toshi.kani@hpe.com>
References: <1445556044-30322-1-git-send-email-toshi.kani@hpe.com>
	<1445556044-30322-4-git-send-email-toshi.kani@hpe.com>
Date: Thu, 22 Oct 2015 17:14:55 -0700
Message-ID: <CAPcyv4j9iDrUrS1Xt4sTV8KOg6wsb=stp=XzoOLFBtuqWf+0AQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] ACPI/APEI/EINJ: Allow memory error injection to NVDIMM
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Oct 22, 2015 at 4:20 PM, Toshi Kani <toshi.kani@hpe.com> wrote:
> In the case of memory error injection, einj_error_inject() checks
> if a target address is regular RAM.  Change this check to allow
> injecting a memory error to both RAM and NVDIMM so that memory
> errors can be tested on NVDIMM as well.
>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> ---
>  drivers/acpi/apei/einj.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
> index 0431883..696f45a 100644
> --- a/drivers/acpi/apei/einj.c
> +++ b/drivers/acpi/apei/einj.c
> @@ -519,7 +519,7 @@ static int
(u32 type, u32 flags, u64 param1, u64 param2,
>                              u64 param3, u64 param4)
>  {
>         int rc;
> -       unsigned long pfn;
> +       u64 base_addr, size;
>
>         /* If user manually set "flags", make sure it is legal */
>         if (flags && (flags &
> @@ -545,10 +545,14 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
>         /*
>          * Disallow crazy address masks that give BIOS leeway to pick
>          * injection address almost anywhere. Insist on page or
> -        * better granularity and that target address is normal RAM.
> +        * better granularity and that target address is normal RAM or
> +        * NVDIMM.
>          */
> -       pfn = PFN_DOWN(param1 & param2);
> -       if (!page_is_ram(pfn) || ((param2 & PAGE_MASK) != PAGE_MASK))
> +       base_addr = param1 & param2;
> +       size = (~param2) + 1;
> +       if (((!page_is_ram(PFN_DOWN(base_addr))) &&
> +            (region_intersects_pmem(base_addr, size) != REGION_INTERSECTS)) ||
> +           ((param2 & PAGE_MASK) != PAGE_MASK))

Hmm, should we also convert the page_is_ram() call to
region_intersects_ram() so that we check the entire range from
base_addr to base_addr + size?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
