Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id CB0216B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 02:34:15 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id fp4so49019231obb.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 23:34:15 -0700 (PDT)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id l67si964081otc.228.2016.03.29.23.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 23:34:14 -0700 (PDT)
Received: by mail-ob0-x230.google.com with SMTP id m7so47839471obh.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 23:34:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
References: <1459313022-11750-1-git-send-email-chanho.min@lge.com>
Date: Tue, 29 Mar 2016 23:34:14 -0700
Message-ID: <CAPcyv4gqKZUh8_oE=J2xv2ZX78v3PKdHa1qmQP-FDMbt1iEAZQ@mail.gmail.com>
Subject: Re: [PATCH] mm/highmem: simplify is_highmem()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Min <chanho.min@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Gunho Lee <gunho.lee@lge.com>

On Tue, Mar 29, 2016 at 9:43 PM, Chanho Min <chanho.min@lge.com> wrote:
> The is_highmem() is can be simplified by use of is_highmem_idx().
> This patch removes redundant code and will make it easier to maintain
> if the zone policy is changed or a new zone is added.
>
> Signed-off-by: Chanho Min <chanho.min@lge.com>
> ---
>  include/linux/mmzone.h |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index e23a9e7..9ac90c3 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -817,10 +817,7 @@ static inline int is_highmem_idx(enum zone_type idx)
>  static inline int is_highmem(struct zone *zone)
>  {
>  #ifdef CONFIG_HIGHMEM
> -       int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> -       return zone_off == ZONE_HIGHMEM * sizeof(*zone) ||
> -              (zone_off == ZONE_MOVABLE * sizeof(*zone) &&
> -               zone_movable_is_highmem());
> +       return is_highmem_idx(zone_idx(zone));
>  #else
>         return 0;
>  #endif

Yup, looks like a straightforward replacement of open coded versions
of the same routines.

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
