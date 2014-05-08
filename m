Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5836B00E0
	for <linux-mm@kvack.org>; Thu,  8 May 2014 06:17:54 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so2676159pad.30
        for <linux-mm@kvack.org>; Thu, 08 May 2014 03:17:54 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id zp5si303287pac.24.2014.05.08.03.17.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 May 2014 03:17:53 -0700 (PDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0C0043EE1A8
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:17:52 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF7C345DE50
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:17:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CC18C45DE3E
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:17:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B97081DB803F
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:17:51 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 607D71DB8038
	for <linux-mm@kvack.org>; Thu,  8 May 2014 19:17:51 +0900 (JST)
Message-ID: <536B59A1.3000602@jp.fujitsu.com>
Date: Thu, 8 May 2014 19:17:05 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>	<5360C9E7.6010701@jp.fujitsu.com>	<20140430093035.7e7226f2@annuminas.surriel.com>	<20140430134826.GH4357@dhcp22.suse.cz>	<20140430104114.4bdc588e@cuia.bos.redhat.com>	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>	<53614F3C.8020009@redhat.com>	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>	<20140430160218.442863e0@cuia.bos.redhat.com>	<20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org> <20140430164255.7a753a8e@cuia.bos.redhat.com>
In-Reply-To: <20140430164255.7a753a8e@cuia.bos.redhat.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

Hi Rik, 

On Wed, 30 Apr 2014 16:42:55 -0400 Rik van Riel wrote:
> On Wed, 30 Apr 2014 13:13:53 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> This was a consequence of 64->32 truncation and it can't happen any
>> more, can it?
> 
> Andrew, this is cleaner indeed :)
> 
> Masayoshi-san, does the bug still happen with this version, or does
> this fix the problem?

I applied the v5 patch and the divide error did not happen when I ran the test.
Thank you for fixing it!

Thanks,
Masayoshi Mizuma

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
> ---
>   mm/page-writeback.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef41349..a4317da 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -593,14 +593,14 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
>    * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
>    *     => fast response on large errors; small oscillation near setpoint
>    */
> -static inline long long pos_ratio_polynom(unsigned long setpoint,
> +static long long pos_ratio_polynom(unsigned long setpoint,
>   					  unsigned long dirty,
>   					  unsigned long limit)
>   {
>   	long long pos_ratio;
>   	long x;
>   
> -	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> +	x = div64_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>   		    limit - setpoint + 1);
>   	pos_ratio = x;
>   	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
> @@ -842,7 +842,7 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
>   	x_intercept = bdi_setpoint + span;
>   
>   	if (bdi_dirty < x_intercept - span / 4) {
> -		pos_ratio = div_u64(pos_ratio * (x_intercept - bdi_dirty),
> +		pos_ratio = div64_u64(pos_ratio * (x_intercept - bdi_dirty),
>   				    x_intercept - bdi_setpoint + 1);
>   	} else
>   		pos_ratio /= 4;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
