Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 424156B0392
	for <linux-mm@kvack.org>; Thu, 17 May 2018 02:39:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id f6-v6so1369398pgs.13
        for <linux-mm@kvack.org>; Wed, 16 May 2018 23:39:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5-v6si3576228pgu.341.2018.05.16.23.39.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 23:39:37 -0700 (PDT)
Subject: Re: [PATCH v2] mm: save two stranding bit in gfp_mask
References: <20180516211439.177440-1-shakeelb@google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8201ac0e-a12f-6e3a-b5b1-497c2519ac06@suse.cz>
Date: Thu, 17 May 2018 08:39:34 +0200
MIME-Version: 1.0
In-Reply-To: <20180516211439.177440-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 05/16/2018 11:14 PM, Shakeel Butt wrote:
> ___GFP_COLD and ___GFP_OTHER_NODE were removed but their bits were
> stranded. Fill the gaps by moving the existing gfp masks around.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Michal Hocko <mhocko@suse.com>

Yeah that's much smaller, thanks.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> Changelog since v1:
> - Moved couple of gfp masks instead of sliding all.
> 
>  include/linux/gfp.h | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 1a4582b44d32..036846fc00a6 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -24,6 +24,7 @@ struct vm_area_struct;
>  #define ___GFP_HIGH		0x20u
>  #define ___GFP_IO		0x40u
>  #define ___GFP_FS		0x80u
> +#define ___GFP_WRITE		0x100u
>  #define ___GFP_NOWARN		0x200u
>  #define ___GFP_RETRY_MAYFAIL	0x400u
>  #define ___GFP_NOFAIL		0x800u
> @@ -36,11 +37,10 @@ struct vm_area_struct;
>  #define ___GFP_THISNODE		0x40000u
>  #define ___GFP_ATOMIC		0x80000u
>  #define ___GFP_ACCOUNT		0x100000u
> -#define ___GFP_DIRECT_RECLAIM	0x400000u
> -#define ___GFP_WRITE		0x800000u
> -#define ___GFP_KSWAPD_RECLAIM	0x1000000u
> +#define ___GFP_DIRECT_RECLAIM	0x200000u
> +#define ___GFP_KSWAPD_RECLAIM	0x400000u
>  #ifdef CONFIG_LOCKDEP
> -#define ___GFP_NOLOCKDEP	0x2000000u
> +#define ___GFP_NOLOCKDEP	0x800000u
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> @@ -205,7 +205,7 @@ struct vm_area_struct;
>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>  
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
> +#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /*
> 
