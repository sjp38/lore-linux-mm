Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 81D306B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 18:39:40 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id kq14so920535pab.8
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:39:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ic8si14492016pad.423.2014.04.29.15.39.39
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 15:39:39 -0700 (PDT)
Date: Tue, 29 Apr 2014 15:39:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm,writeback: fix divide by zero in pos_ratio_polynom
Message-Id: <20140429153936.49a2710c0c2bba4d233032f2@linux-foundation.org>
In-Reply-To: <20140429151910.53f740ef@annuminas.surriel.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, mhocko@suse.cz, fengguang.wu@intel.com, mpatlasov@parallels.com

On Tue, 29 Apr 2014 15:19:10 -0400 Rik van Riel <riel@redhat.com> wrote:

> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> working, so we need to actually test the divisor before calling div64.
> 
> ...
>
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -597,11 +597,16 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>  					  unsigned long dirty,
>  					  unsigned long limit)
>  {
> +	unsigned int divisor;

I'm thinking this would be better as a ulong so I don't have to worry
my pretty head over truncation things?

>  	long long pos_ratio;
>  	long x;
>  
> +	divisor = limit - setpoint;
> +	if (!divisor)
> +		divisor = 1;
> +
>  	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +		    divisor);
>  	pos_ratio = x;
>  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>  	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;

--- a/mm/page-writeback.c~mm-page-writebackc-fix-divide-by-zero-in-pos_ratio_polynom-fix
+++ a/mm/page-writeback.c
@@ -597,13 +597,13 @@ static inline long long pos_ratio_polyno
 					  unsigned long dirty,
 					  unsigned long limit)
 {
-	unsigned int divisor;
+	unsigned long divisor;
 	long long pos_ratio;
 	long x;
 
 	divisor = limit - setpoint;
 	if (!divisor)
-		divisor = 1;
+		divisor = 1;	/* Avoid div-by-zero */
 
 	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
 		    divisor);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
