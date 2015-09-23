Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE9A6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 09:47:27 -0400 (EDT)
Received: by obbda8 with SMTP id da8so33424877obb.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:47:27 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id ci2si3926054oec.46.2015.09.23.06.47.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 06:47:26 -0700 (PDT)
Received: by oibi136 with SMTP id i136so23898161oib.3
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:47:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923044216.36490.51220.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044216.36490.51220.stgit@dwillia2-desk3.jf.intel.com>
Date: Wed, 23 Sep 2015 15:47:26 +0200
Message-ID: <CAMuHMdXdNn5_gf+fFcV+HS0Wq1RikKYP0+Mn7wv1tqN0vtQqKQ@mail.gmail.com>
Subject: Re: [PATCH 12/15] mm, dax, gpu: convert vm_insert_mixed to __pfn_t,
 introduce _PAGE_DEVMAP
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, David Airlie <airlied@linux.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

Hi Dan,

On Wed, Sep 23, 2015 at 6:42 AM, Dan Williams <dan.j.williams@intel.com> wrote:
> Convert the raw unsigned long 'pfn' argument to __pfn_t for the purpose of
> evaluating the PFN_MAP and PFN_DEV flags.  When both are set the it

s/the it/it/

> triggers _PAGE_DEVMAP to be set in the resulting pte.  This flag will
> later be used in the get_user_pages() path to pin the page mapping,
> dynamically allocated by devm_memremap_pages(), until all the resulting
> pages are released.
>
> There are no functional changes to the gpu drivers as a result of this
> conversion.
>
> This uncovered several architectures with no local definition for
> pfn_pte(), in response __pfn_t_pte() is only defined when an arch
> opts-in by "#define pfn_pte pfn_pte".
>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Airlie <airlied@linux.ie>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

> diff --git a/arch/m68k/include/asm/page_no.h b/arch/m68k/include/asm/page_no.h
> index ef209169579a..930a42f6db44 100644
> --- a/arch/m68k/include/asm/page_no.h
> +++ b/arch/m68k/include/asm/page_no.h
> @@ -34,6 +34,7 @@ extern unsigned long memory_end;
>
>  #define        virt_addr_valid(kaddr)  (((void *)(kaddr) >= (void *)PAGE_OFFSET) && \
>                                 ((void *)(kaddr) < (void *)memory_end))
> +#define __pfn_to_phys(pfn)     PFN_PHYS(pfn)

The above change doesn't match the patch description?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
