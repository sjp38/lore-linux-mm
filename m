Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 308826B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 15:00:09 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so2075422pde.22
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 12:00:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ho7si17896598pad.233.2014.04.30.12.00.04
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 12:00:04 -0700 (PDT)
Date: Wed, 30 Apr 2014 12:00:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm,writeback: fix divide by zero in
 pos_ratio_polynom
Message-Id: <20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
In-Reply-To: <20140430104114.4bdc588e@cuia.bos.redhat.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
	<20140430093035.7e7226f2@annuminas.surriel.com>
	<20140430134826.GH4357@dhcp22.suse.cz>
	<20140430104114.4bdc588e@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 10:41:14 -0400 Rik van Riel <riel@redhat.com> wrote:

> It is possible for "limit - setpoint + 1" to equal zero, leading to a
> divide by zero error. Blindly adding 1 to "limit - setpoint" is not
> working, so we need to actually test the divisor before calling div64.
> 
> ...
>
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -598,10 +598,15 @@ static inline long long pos_ratio_polynom(unsigned long setpoint,
>  					  unsigned long limit)
>  {
>  	long long pos_ratio;
> +	long divisor;
>  	long x;
>  
> +	divisor = limit - setpoint;
> +	if (!(s32)divisor)
> +		divisor = 1;	/* Avoid div-by-zero */
> +
>  	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
> -		    limit - setpoint + 1);
> +		    (s32)divisor);

Doesn't this just paper over the bug one time in four billion?  The
other 3999999999 times, pos_ratio_polynom() returns an incorect result?

If it is indeed the case that pos_ratio_polynom() callers are
legitimately passing a setpoint which is more than 2^32 less than limit
then it would be better to handle that input correctly.

Writing a new suite of div functions sounds overkillish.  At some loss
of precision could we do something like

	if (divisor > 2^32) {
		divisor >>= log2(divisor) - 32;
		dividend >>= log2(divisor) - 32;
	}
	x = div(dividend, divisor);

?

And let's uninline the sorry thing while we're in there ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
