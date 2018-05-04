Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E80DA6B0010
	for <linux-mm@kvack.org>; Fri,  4 May 2018 09:35:39 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m8-v6so1769880pgq.9
        for <linux-mm@kvack.org>; Fri, 04 May 2018 06:35:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z187-v6si13616329pgd.646.2018.05.04.06.35.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 May 2018 06:35:38 -0700 (PDT)
Date: Fri, 4 May 2018 15:35:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] include/linux/gfp.h: use unsigned int in gfp_zone
Message-ID: <20180504133533.GR4535@dhcp22.suse.cz>
References: <1525416729-108201-1-git-send-email-yehs1@lenovo.com>
 <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1525416729-108201-3-git-send-email-yehs1@lenovo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huaisheng Ye <yehs1@lenovo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net, pasha.tatashin@oracle.com, alexander.levin@verizon.com, hannes@cmpxchg.org, penguin-kernel@I-love.SAKURA.ne.jp, colyli@suse.de, chengnt@lenovo.com, linux-kernel@vger.kernel.org

On Fri 04-05-18 14:52:08, Huaisheng Ye wrote:
> Suggest using unsigned int instead of int for bit within gfp_zone.
> 
> Within function gfp_zone, the value of local variable bit comes from
> formal parameter flags, which's type is gfp_t. Local variable bit
> indicates the number of bits in the right shift for GFP_ZONE_TABLE
> with GFP_ZONES_SHIFT. So, variable bit shall always be unsigned
> integer, it doesn't make sense that forcing it to be a signed integer.
> 
> Current GFP_ZONEMASK is just valid as low four bits, the largest
> value of bit shall be less or equal 0x0F. But in the future, as the
> mask expands to higher bits, there will be a risk of confusion.

I am highly skeptical we will ever grow the number of zones enough
that signed vs. unsigned would matter. So I guess this all boils down to
aesthetic. I do not care either way. The generated code seems the be the
same.

> Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 1a4582b..21551fc 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -401,7 +401,7 @@ static inline bool gfpflags_allow_blocking(const gfp_t gfp_flags)
>  static inline enum zone_type gfp_zone(gfp_t flags)
>  {
>  	enum zone_type z;
> -	int bit = (__force int) (flags & GFP_ZONEMASK);
> +	unsigned int bit = (__force unsigned int) (flags & GFP_ZONEMASK);
>  
>  	z = (GFP_ZONE_TABLE >> (bit * GFP_ZONES_SHIFT)) &
>  					 ((1 << GFP_ZONES_SHIFT) - 1);
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs
