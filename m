Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 777BB6B0022
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 03:00:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u15-v6so13126954ita.8
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 00:00:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19-v6sor3848922itb.63.2018.04.02.00.00.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 00:00:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1522636236-12625-6-git-send-email-hejianet@gmail.com>
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com> <1522636236-12625-6-git-send-email-hejianet@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Mon, 2 Apr 2018 09:00:37 +0200
Message-ID: <CAKv+Gu9jSXq7YN68Mk7WV4+aLr=nRtHmuQnHMdM8YhgeA-SYsg@mail.gmail.com>
Subject: Re: [PATCH v5 5/5] mm: page_alloc: reduce unnecessary binary search
 in early_pfn_valid()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

On 2 April 2018 at 04:30, Jia He <hejianet@gmail.com> wrote:
> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
> where possible") optimized the loop in memmap_init_zone(). But there is
> still some room for improvement. E.g. in early_pfn_valid(), if pfn and
> pfn+1 are in the same memblock region, we can record the last returned
> memblock region index and check check pfn++ is still in the same region.
>
> Currently it only improve the performance on arm64 and will have no
> impact on other arches.
>

How much does it improve the performance? And in which cases?

I guess it improves boot time on systems with physical address spaces
that are sparsely populated with DRAM, but you really have to quantify
this if you want other people to care.

> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  include/linux/mmzone.h | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f9c0c46..079f468 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1268,9 +1268,14 @@ static inline int pfn_present(unsigned long pfn)
>  })
>  #else
>  #define pfn_to_nid(pfn)                (0)
> -#endif
> +#endif /*CONFIG_NUMA*/
>
> +#ifdef CONFIG_HAVE_ARCH_PFN_VALID
> +#define early_pfn_valid(pfn) pfn_valid_region(pfn)
> +#else
>  #define early_pfn_valid(pfn)   pfn_valid(pfn)
> +#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
> +
>  void sparse_init(void);
>  #else
>  #define sparse_init()  do {} while (0)
> --
> 2.7.4
>
