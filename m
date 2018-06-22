Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF1596B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 02:12:03 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id a9-v6so3217278otl.21
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 23:12:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x10-v6sor2621614otd.68.2018.06.21.23.12.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 23:12:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1529647683-14531-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1529647683-14531-1-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 21 Jun 2018 23:12:01 -0700
Message-ID: <CAPcyv4hpdvGRi+=psT47ePB6QigJW2JEq-zhbVXsTHb14pWfUQ@mail.gmail.com>
Subject: Re: [PATCH v1] mm: initialize struct page for reserved pages in ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>

On Thu, Jun 21, 2018 at 11:08 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Reading /proc/kpageflags for pfns allocated by pmem namespace triggers
> kernel panic with a message like "BUG: unable to handle kernel paging
> request at fffffffffffffffe".
>
> The first few pages (controlled by altmap passed to memmap_init_zone())
> in the ZONE_DEVICE can skip struct page initialization, which causes
> the reported issue.
>
> This patch simply adds some initialization code for them.
>
> Fixes: 4b94ffdc4163 ("x86, mm: introduce vmem_altmap to augment vmemmap_populate()")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/page_alloc.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
>
> diff --git v4.17-mmotm-2018-06-07-16-59/mm/page_alloc.c v4.17-mmotm-2018-06-07-16-59_patched/mm/page_alloc.c
> index 1772513..0b36afe 100644
> --- v4.17-mmotm-2018-06-07-16-59/mm/page_alloc.c
> +++ v4.17-mmotm-2018-06-07-16-59_patched/mm/page_alloc.c
> @@ -5574,8 +5574,16 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
>          * Honor reservation requested by the driver for this ZONE_DEVICE
>          * memory
>          */
> -       if (altmap && start_pfn == altmap->base_pfn)
> +       if (altmap && start_pfn == altmap->base_pfn) {
> +               unsigned long i;
> +
> +               for (i = 0; i < altmap->reserve; i++) {
> +                       page = pfn_to_page(start_pfn + i);
> +                       __init_single_page(page, start_pfn + i, zone, nid);
> +                       SetPageReserved(page);
> +               }
>                 start_pfn += altmap->reserve;
> +       }

No, unfortunately this will clobber metadata that lives in that
reserved area, see __nvdimm_setup_pfn().
