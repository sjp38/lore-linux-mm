Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A00E56B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 16:13:56 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so2568039pab.12
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 13:13:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wh9si18092904pac.418.2014.04.30.13.13.55
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 13:13:55 -0700 (PDT)
Date: Wed, 30 Apr 2014 13:13:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm,writeback: fix divide by zero in
 pos_ratio_polynom
Message-Id: <20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>
In-Reply-To: <20140430160218.442863e0@cuia.bos.redhat.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
	<20140430093035.7e7226f2@annuminas.surriel.com>
	<20140430134826.GH4357@dhcp22.suse.cz>
	<20140430104114.4bdc588e@cuia.bos.redhat.com>
	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
	<53614F3C.8020009@redhat.com>
	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>
	<20140430160218.442863e0@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 16:02:18 -0400 Rik van Riel <riel@redhat.com> wrote:

> I believe this should do the trick.
> 
> ---8<---
> 
> Subject: mm,writeback: fix divide by zero in pos_ratio_polynom
> 
> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> working, so we need to actually test the divisor before calling div64.
> 

Changelog is a bit stale.

> ---
>  mm/page-writeback.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index ef41349..37f56bb 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -593,15 +593,20 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
>   * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
>   *     => fast response on large errors; small oscillation near setpoint
>   */
> -static inline long long pos_ratio_polynom(unsigned long setpoint,
> +static long long pos_ratio_polynom(unsigned long setpoint,
>  					  unsigned long dirty,
>  					  unsigned long limit)
>  {
> +	unsigned long divisor;
>  	long long pos_ratio;
>  	long x;
>  
> -	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +	divisor = limit - setpoint;
> +	if (!divisor)
> +		divisor = 1;	/* Avoid div-by-zero */

This was a consequence of 64->32 truncation and it can't happen any
more, can it?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
