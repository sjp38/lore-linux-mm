Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8906B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 20:29:09 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so257422540pfb.6
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:29:09 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id j24si21556897pfk.32.2017.01.24.17.29.07
        for <linux-mm@kvack.org>;
        Tue, 24 Jan 2017 17:29:08 -0800 (PST)
Date: Wed, 25 Jan 2017 10:29:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: extend zero pages to same element pages for zram
Message-ID: <20170125012905.GA17937@bbox>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
 <1484296195-99771-1-git-send-email-zhouxianrong@huawei.com>
 <20170121084338.GA405@jagdpanzerIV.localdomain>
 <84073d07-6939-b22d-8bda-4fa2a9127555@huawei.com>
 <20170123025826.GA24581@js1304-P5Q-DELUXE>
 <20170123040347.GA2327@jagdpanzerIV.localdomain>
 <20170123062716.GF24581@js1304-P5Q-DELUXE>
 <20170123071339.GD2327@jagdpanzerIV.localdomain>
 <20170123074054.GA12782@bbox>
 <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1ac33960-b523-1c58-b2de-8f6ddb3a5219@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong <zhouxianrong@huawei.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

Hi zhouxianrong,

On Tue, Jan 24, 2017 at 03:58:02PM +0800, zhouxianrong wrote:
> @@ -161,15 +161,55 @@ static bool page_zero_filled(void *ptr)
>  {
>  	unsigned int pos;
>  	unsigned long *page;
> +	static unsigned long total;
> +	static unsigned long zero;
> +	static unsigned long pattern_char;
> +	static unsigned long pattern_short;
> +	static unsigned long pattern_int;
> +	static unsigned long pattern_long;
> +	unsigned char *p_char;
> +	unsigned short *p_short;
> +	unsigned int *p_int;
> +	bool retval = false;
> +
> +	++total;
> 
>  	page = (unsigned long *)ptr;
> 
> -	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
> -		if (page[pos])
> -			return false;
> +	for (pos = 0; pos < PAGE_SIZE / sizeof(unsigned long) - 1; ++pos) {
> +	       if (page[pos] != page[pos + 1])
> +	                return false;
>  	}
> 
> -	return true;
> +	p_char = (unsigned char *)ptr;
> +	p_short = (unsigned short *)ptr;
> +	p_int = (unsigned int *)ptr;
> +
> +	if (page[0] == 0) {
> +		++zero;
> +		retval = true;
> +	} else if (p_char[0] == p_char[1] &&
> +		       p_char[1] == p_char[2] &&
> +		       p_char[2] == p_char[3] &&
> +		       p_char[3] == p_char[4] &&
> +		       p_char[4] == p_char[5] &&
> +		       p_char[5] == p_char[6] &&
> +		       p_char[6] == p_char[7])
> +		++pattern_char;
> +	else if (p_short[0] == p_short[1] &&
> +		       p_short[1] == p_short[2] &&
> +		       p_short[2] == p_short[3])
> +		++pattern_short;
> +	else if (p_int[0] == p_int[1] &&
> +		       p_int[1] == p_int[2])
> +		++pattern_int;
> +	else {
> +		++pattern_long;
> +	}
> +
> +	pr_err("%lld %lld %lld %lld %lld %lld\n", zero, pattern_char, pattern_short, pattern_int, pattern_long, total);
> +
> +	return retval;
>  }
> 
> the result as listed below:
> 
> zero    pattern_char   pattern_short   pattern_int   pattern_long   total      (unit)
> 162989  14454          3534            23516         2769           3294399    (page)
> 

so, int covers 93%. As considering non-zero dedup hit ratio is low, I think *int* is
enough if memset is really fast. So, I'd like to go with 'int' if Sergey doesn't mind.

Please include the number in description and resend patch, zhouxianrong. :)

Thanks.

> statistics for the result:
> 
>          pattern zero  pattern char  pattern short  pattern int  pattern long
> AVERAGE  0.745696298   0.085937175   0.015957701    0.131874915  0.020533911
> STDEV    0.035623777   0.016892402   0.004454534    0.021657123  0.019420072
> MAX      0.973813421   0.222222222   0.021409518    0.211812245  0.176512625
> MIN      0.645431905   0.004634398   0              0            0
> 
> 
> On 2017/1/23 15:40, Minchan Kim wrote:
> >On Mon, Jan 23, 2017 at 04:13:39PM +0900, Sergey Senozhatsky wrote:
> >>On (01/23/17 15:27), Joonsoo Kim wrote:
> >>>Hello,
> >>>
> >>>Think about following case in 64 bits kernel.
> >>>
> >>>If value pattern in the page is like as following, we cannot detect
> >>>the same page with 'unsigned int' element.
> >>>
> >>>AAAAAAAABBBBBBBBAAAAAAAABBBBBBBB...
> >>>
> >>>4 bytes is 0xAAAAAAAA and next 4 bytes is 0xBBBBBBBB and so on.
> >>
> >>yep, that's exactly the case that I though would be broken
> >>with a 4-bytes pattern matching. so my conlusion was that
> >>for 4 byte pattern we would have working detection anyway,
> >>for 8 bytes patterns we might have some extra matching.
> >>not sure if it matters that much though.
> >
> >It would be better for deduplication as pattern coverage is bigger
> >and we cannot guess all of patterns now so it would be never ending
> >story(i.e., someone claims 16bytes pattern matching would be better).
> >So, I want to make that path fast rather than increasing dedup ratio
> >if memset is really fast rather than open-looping. So in future,
> >if we can prove bigger pattern can increase dedup ratio a lot, then,
> >we could consider to extend it at the cost of make that path slow.
> >
> >In summary, zhouxianrong, please test pattern as Joonsoo asked.
> >So if there are not much benefit with 'long', let's go to the
> >'int' with memset. And Please resend patch if anyone dosn't oppose
> >strongly by the time.
> >
> >Thanks.
> >
> >
> >.
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
