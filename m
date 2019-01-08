Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B018FC43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 00:19:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B6312087F
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 00:19:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="PU2wtqCV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B6312087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E321F8E0048; Mon,  7 Jan 2019 19:19:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE1C88E0038; Mon,  7 Jan 2019 19:19:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD00B8E0048; Mon,  7 Jan 2019 19:19:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DED28E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 19:19:26 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id o132so823308vsd.11
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 16:19:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nyRkMTCT4Q4ldIHAI6MgR4h/O/fY9tefclaP6MuszEk=;
        b=MOIKIFMZcLkfWwEobcBjgMsLR6I3SHAA2IAYK+2f1VOSCtVDJI2Lrdt28N56brEjr8
         kFePrYd0yHjyIhu0lVUEC8r98H9k9H5Ej19i5cYEPhC+J5mxMqkGciyuIVbcZEhO8T5l
         DaXK+XGgqv24Ca0IQ/1TFFTPTZth7qNEsrmS82W32QA/3S6D+YoYOvpEbtCcfuUt+OHm
         +SyyKE20NeSPlwzCct6AsCceNDojdnhkF7vI9417I2ByzCMj6rCxacjvJDj7rXzLaN5t
         vXgKHhmuPhbuFWafvgvngORQzNwBZJw24MPlw9UFkMfzWuybZcHphcOajEn664/+HpGL
         d5bg==
X-Gm-Message-State: AJcUukeEuFE0f/lEYXpoXdqe77C4WVfwxie0E2enr3pxPPO3zkWKyt8D
	zd6Jbyavk/sW/57tlW2v5/tif7wFIpYeT8GlW/VWP7yyCYzQEwUTuH2RigCuMKuxWvUQ8DBacC0
	nGwf7xuCJZpPcmteWzvvhFH9Ef9n7I4VN02VStVuv9Pm/FR9pCt+uKnQZFPkDAJZasX/DTMOeEK
	vlKkm4dhQ+0Xe5DVdv4TH1IaBZke1+k3++I2xNojACXLtXXmhjaN3338bTP4Xl4muKZePH51Pn6
	kDqMN0hCaYZoMSp1uKNcX9goUv2OyZ7TSzhE0B04AvcptAHp+HuQ3UjmfW2CNLQaamfZhwLPvRC
	cXIk9EpN/fkYRzu9D9nCdV1Z60RrN0e1AHo5AygwCOuqq6IlgCNhC+FYcdFbZvrzI9iuKkr6UXt
	7
X-Received: by 2002:a67:5d83:: with SMTP id r125mr2673203vsb.197.1546906766337;
        Mon, 07 Jan 2019 16:19:26 -0800 (PST)
X-Received: by 2002:a67:5d83:: with SMTP id r125mr2673194vsb.197.1546906765755;
        Mon, 07 Jan 2019 16:19:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546906765; cv=none;
        d=google.com; s=arc-20160816;
        b=BqIzXKz7JyV8oo6S67vxhy9Kr7MMaq2oZ4vL3ctjs4p08/ZGnhkagyu2hruKlSUfSW
         d8nPeOfqla32l3u0BR+6eDUfqwj61ZhO9VURrg+T+OHTx8f8FGwDAQ/YufJb1c1u7HgI
         tl2SMCaPMkaQNljXc4SwkDQXlBqpqUrqFimQ2M37psOLIq06Lkrt1HCM4KUySu33u/JQ
         eurh7T7yGOlWomjpQVZBzuwtfGXWw2m4OrZwXTFmQt7LpAvLGhpjHcBorz/j9+9qhBje
         aJD/g8GLa3nFqTTCuGwm1qmFTtLvvDASev3RRSnGT2x9R3uvS4Cg9+q+phQ7C5pbKEci
         0hKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nyRkMTCT4Q4ldIHAI6MgR4h/O/fY9tefclaP6MuszEk=;
        b=WI+44HYIvqT4whS6F2Wr6QL/G6In0EURuR6hxwwlE8gGRj9vn0Lb1uHjzK+/ytO5OP
         07PYV412p5p0bNRlsdr5HWplrXkxV2WXj6Rs81jtp3ibFqI2l1aVxFCG34WLyx5CLVOd
         tCEbcvXhFknGrrZLDO/tMQgvqDnZGIhKAkTfgqxLZEO5IUWdGIApJWUBuNvZ+jYlFMD9
         O63G9qvWYvQFaopok5pQU2mp9XwrYT7pwS7tJV9kGitQTjwnu+R6h0pP2MTJknQI6XJJ
         sRzVovnP9PrVZKPE3mtg//TX16iUkJTgvpapst1TGCbEKFukh3LCtgjc/lPNvaFsGbYk
         ZmGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PU2wtqCV;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s80sor34568717vsa.27.2019.01.07.16.19.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 16:19:25 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PU2wtqCV;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nyRkMTCT4Q4ldIHAI6MgR4h/O/fY9tefclaP6MuszEk=;
        b=PU2wtqCVk/8/pzWVSwOtSDbyd6FYyy2Zrg5HMWq/5bsQXK4PpMWACun1WiOJrPtU6S
         BF+FNhlNs5/3N3MN4xPGXZUeouPV1g+87XQSCyRZKoK1j9x2BkkUzZ7Lj7kWXP+poxwU
         VtLyIFLw+NbrXg6V09k/l9P/l5x/fj6IlX7uc=
X-Google-Smtp-Source: AFSGD/XDHDTfHDdXoxcYu9w13mzdGe/9N0qzAiimQNgm72kTYLXwPhnxjeWFqizlRBmCNoBFnhF7gw==
X-Received: by 2002:a67:1346:: with SMTP id 67mr22395322vst.31.1546906764830;
        Mon, 07 Jan 2019 16:19:24 -0800 (PST)
Received: from mail-ua1-f52.google.com (mail-ua1-f52.google.com. [209.85.222.52])
        by smtp.gmail.com with ESMTPSA id o9sm19268266vke.46.2019.01.07.16.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 16:19:23 -0800 (PST)
Received: by mail-ua1-f52.google.com with SMTP id z24so731271ual.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 16:19:23 -0800 (PST)
X-Received: by 2002:ab0:470d:: with SMTP id h13mr24710996uac.122.1546906762868;
 Mon, 07 Jan 2019 16:19:22 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690328135.676627.5979130839159447106.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154690328135.676627.5979130839159447106.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 7 Jan 2019 16:19:11 -0800
X-Gmail-Original-Message-ID: <CAGXu5jKGOMHoTf0ixKCr_KFprc1Z6S2f1LYdNgMuHsL2UEm-_Q@mail.gmail.com>
Message-ID:
 <CAGXu5jKGOMHoTf0ixKCr_KFprc1Z6S2f1LYdNgMuHsL2UEm-_Q@mail.gmail.com>
Subject: Re: [PATCH v7 3/3] mm: Maintain randomization of page free lists
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Keith Busch <keith.busch@intel.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Mel Gorman <mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108001911.RE_a5xGk8GUTNl9WdOZ4Lqd_5e2VG4BPueqcgot2n-0@z>

On Mon, Jan 7, 2019 at 3:34 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> When freeing a page with an order >= shuffle_page_order randomly select
> the front or back of the list for insertion.
>
> While the mm tries to defragment physical pages into huge pages this can
> tend to make the page allocator more predictable over time. Inject the
> front-back randomness to preserve the initial randomness established by
> shuffle_free_memory() when the kernel was booted.
>
> The overhead of this manipulation is constrained by only being applied
> for MAX_ORDER sized pages by default.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  include/linux/mmzone.h  |   10 ++++++++++
>  include/linux/shuffle.h |   12 ++++++++++++
>  mm/page_alloc.c         |   11 +++++++++--
>  mm/shuffle.c            |   16 ++++++++++++++++
>  4 files changed, 47 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b78a45e0b11c..c15f7f703be0 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -98,6 +98,8 @@ extern int page_group_by_mobility_disabled;
>  struct free_area {
>         struct list_head        free_list[MIGRATE_TYPES];
>         unsigned long           nr_free;
> +       u64                     rand;
> +       u8                      rand_bits;
>  };
>
>  /* Used for pages not on another list */
> @@ -116,6 +118,14 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
>         area->nr_free++;
>  }
>
> +#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
> +/* Used to preserve page allocation order entropy */
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +               int migratetype);
> +#else
> +#define add_to_free_area_random add_to_free_area
> +#endif
> +
>  /* Used for pages which are on another list */
>  static inline void move_to_free_area(struct page *page, struct free_area *area,
>                              int migratetype)
> diff --git a/include/linux/shuffle.h b/include/linux/shuffle.h
> index d109161f4a62..85b7f5f32867 100644
> --- a/include/linux/shuffle.h
> +++ b/include/linux/shuffle.h
> @@ -30,6 +30,13 @@ static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
>                 return;
>         __shuffle_zone(z, start_pfn, end_pfn);
>  }
> +
> +static inline bool is_shuffle_order(int order)
> +{
> +       if (!static_branch_unlikely(&page_alloc_shuffle_key))
> +                return false;
> +       return order >= CONFIG_SHUFFLE_PAGE_ORDER;
> +}
>  #else
>  static inline void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
>                 unsigned long end_pfn)
> @@ -44,5 +51,10 @@ static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
>  static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
>  {
>  }
> +
> +static inline bool is_shuffle_order(int order)
> +{
> +       return false;
> +}
>  #endif
>  #endif /* _MM_SHUFFLE_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0b4791a2dd43..f3a859b66d70 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -43,6 +43,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/memremap.h>
>  #include <linux/stop_machine.h>
> +#include <linux/random.h>
>  #include <linux/sort.h>
>  #include <linux/pfn.h>
>  #include <linux/backing-dev.h>
> @@ -889,7 +890,8 @@ static inline void __free_one_page(struct page *page,
>          * so it's less likely to be used soon and more likely to be merged
>          * as a higher order page
>          */
> -       if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
> +       if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
> +                       && !is_shuffle_order(order)) {
>                 struct page *higher_page, *higher_buddy;
>                 combined_pfn = buddy_pfn & pfn;
>                 higher_page = page + (combined_pfn - pfn);
> @@ -903,7 +905,12 @@ static inline void __free_one_page(struct page *page,
>                 }
>         }
>
> -       add_to_free_area(page, &zone->free_area[order], migratetype);
> +       if (is_shuffle_order(order))
> +               add_to_free_area_random(page, &zone->free_area[order],
> +                               migratetype);
> +       else
> +               add_to_free_area(page, &zone->free_area[order], migratetype);
> +
>  }
>
>  /*
> diff --git a/mm/shuffle.c b/mm/shuffle.c
> index 07961ff41a03..4cadf51c9b40 100644
> --- a/mm/shuffle.c
> +++ b/mm/shuffle.c
> @@ -213,3 +213,19 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
>         for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>                 shuffle_zone(z, start_pfn, end_pfn);
>  }
> +
> +void add_to_free_area_random(struct page *page, struct free_area *area,
> +               int migratetype)
> +{
> +       if (area->rand_bits == 0) {
> +               area->rand_bits = 64;
> +               area->rand = get_random_u64();
> +       }
> +
> +       if (area->rand & 1)
> +               add_to_free_area(page, area, migratetype);
> +       else
> +               add_to_free_area_tail(page, area, migratetype);
> +       area->rand_bits--;
> +       area->rand >>= 1;
> +}
>


-- 
Kees Cook

