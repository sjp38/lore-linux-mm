Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 86A9B6B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 04:04:19 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id mc6so976048lab.1
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 01:04:18 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id tv3si9498732lbb.7.2014.04.30.01.04.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Apr 2014 01:04:17 -0700 (PDT)
Message-ID: <5360AE74.7050100@parallels.com>
Date: Wed, 30 Apr 2014 12:04:04 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
References: <20140429151910.53f740ef@annuminas.surriel.com>
In-Reply-To: <20140429151910.53f740ef@annuminas.surriel.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, sandeen@redhat.com, akpm@linux-foundation.org, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com

Hi Rik!

On 04/29/2014 11:19 PM, Rik van Riel wrote:
> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> working, so we need to actually test the divisor before calling div64.

The patch looks correct, but I'm afraid it can hide an actual bug in a 
caller of pos_ratio_polynom(). The latter is not intended for setpoint > 
limit. All callers take pains to ensure that setpoint <= limit. Look, 
for example, at global_dirty_limits():

 >     if (background >= dirty)
 >        background = dirty / 2;

If you ever encountered "limit - setpoint + 1" equal zero, it may be 
worthy to investigate how you came to setpoint greater than limit.

Thanks,
Maxim

>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: stable@vger.kernel.org
> ---
>   mm/page-writeback.c | 7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef41349..2682516 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>   					  unsigned long dirty,
>   					  unsigned long limit)
>   {
> +	unsigned int divisor;
>   	long long pos_ratio;
>   	long x;
>   
> +	divisor = limit - setpoint;
> +	if (!divisor)
> +		divisor = 1;
> +
>   	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +		    divisor);
>   	pos_ratio = x;
>   	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>   	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
