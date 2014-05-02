Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id E1A636B0038
	for <linux-mm@kvack.org>; Fri,  2 May 2014 05:16:45 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so1788351eek.7
        for <linux-mm@kvack.org>; Fri, 02 May 2014 02:16:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z2si1051590eeo.214.2014.05.02.02.16.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 02:16:44 -0700 (PDT)
Date: Fri, 2 May 2014 11:16:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v5] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-ID: <20140502091641.GB3446@dhcp22.suse.cz>
References: <5360C9E7.6010701@jp.fujitsu.com>
 <20140430093035.7e7226f2@annuminas.surriel.com>
 <20140430134826.GH4357@dhcp22.suse.cz>
 <20140430104114.4bdc588e@cuia.bos.redhat.com>
 <20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
 <53614F3C.8020009@redhat.com>
 <20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>
 <20140430160218.442863e0@cuia.bos.redhat.com>
 <20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>
 <20140430164255.7a753a8e@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430164255.7a753a8e@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed 30-04-14 16:42:55, Rik van Riel wrote:
> On Wed, 30 Apr 2014 13:13:53 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > This was a consequence of 64->32 truncation and it can't happen any
> > more, can it?
> 
> Andrew, this is cleaner indeed :)
> 
> Masayoshi-san, does the bug still happen with this version, or does
> this fix the problem?
> 
> ---8<---
> 
> Subject: mm,writeback: fix divide by zero in pos_ratio_polynom
> 
> It is possible for "limit - setpoint + 1" to equal zero, after
> getting truncated to a 32 bit variable, and resulting in a divide
> by zero error.
> 
> Using the fully 64 bit divide functions avoids this problem.
> 
> Also uninline pos_ratio_polynom, at Andrew's request.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>

This looks much better.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/page-writeback.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef41349..a4317da 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -593,14 +593,14 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
>   * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
>   *     => fast response on large errors; small oscillation near setpoint
>   */
> -static inline long long pos_ratio_polynom(unsigned long setpoint,
> +static long long pos_ratio_polynom(unsigned long setpoint,
>  					  unsigned long dirty,
>  					  unsigned long limit)
>  {
>  	long long pos_ratio;
>  	long x;
>  
> -	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> +	x = div64_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>  		    limit - setpoint + 1);
>  	pos_ratio = x;
>  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> @@ -842,7 +842,7 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
>  	x_intercept = bdi_setpoint + span;
>  
>  	if (bdi_dirty < x_intercept - span / 4) {
> -		pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
> +		pos_ratio = div64_u64(pos_ratio * (x_intercept - bdi_dirty),
>  				    x_intercept - bdi_setpoint + 1);
>  	} else
>  		pos_ratio /= 4;
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
