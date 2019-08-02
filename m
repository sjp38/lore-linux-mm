Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F91EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:31:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C52732087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:31:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C52732087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63C946B000D; Fri,  2 Aug 2019 11:31:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6134D6B000E; Fri,  2 Aug 2019 11:31:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52A6A6B0010; Fri,  2 Aug 2019 11:31:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 341566B000D
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:31:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id m198so64737470qke.22
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:31:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VbOdaqjppT6RsqnH/4zsfuqtLiXGz0XxiaSxTcRPwYY=;
        b=HhFjBJtfShEQiJVvpEpOV/EGgxr8Lt//T30dx/rGLXa+dI0YWgRdnZMUDuswbcByeT
         4gGWgXdhlVtUPy09qIcPkQ9Pe+qmpLEdGJMmArIVYtpglDrMqLAv9KjBKlAqhPB4KNRn
         z9tBLx8gTBaZNBTBvsNQferuzi3hvRdxjqSiQ7nikodzzjSfUJ/Yyltr2k7HvijeSGBL
         a2DrAn+su1jhFQj0w9iLMcmUYzLXcYV0M2jXrLgOu8xudJiMTBCk+IHfv3Gyyp31RTZn
         uVvYBGuKOqmn91/HPpk3OPOeoMMOMKLJsR+2gTH/mbY13/PKLr70n4SnCFZVKj8dr27L
         YCuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUL8J6Qxi2lru2oOfW5AjXO0NKeV3uA4AfX8VE4G6Obqh3dzA1W
	Qdqg38x3cZegq7bFlK/BDoflwPDnGwskDZTg+VRYM6RntWwgaunwmKjpkCExqMA9SsDAEUfGlwj
	ZTQAOZreZMav5g1jCerROnf/Rxilq/eeJzta0SALwFg/z/LVzKZ45NATq9KW6q26cvw==
X-Received: by 2002:a0c:bd18:: with SMTP id m24mr98818306qvg.118.1564759888916;
        Fri, 02 Aug 2019 08:31:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxR12wFXhN9gYzw1f/QMYyyoEiRRvP+YjPHaA4RLmOnyhiqmemKMhyZJbrbTTeTgMilbzbw
X-Received: by 2002:a0c:bd18:: with SMTP id m24mr98818229qvg.118.1564759888250;
        Fri, 02 Aug 2019 08:31:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564759888; cv=none;
        d=google.com; s=arc-20160816;
        b=YWqVf2xRSXVPGa7d+njLQYCohPrMIA8Z+GKobgZ6aCsAEQEssAEbZvyf+hUb5yaKCU
         OnQLgyBKocTdE2vKIj11+A8NFcW5r59HroT4J3UM9ehqMQQxMTlZT7bEz6OJOclccLOh
         lENbgSi8ZfdAKRrbr16ANPkLyAqaqBcQ/nmZ1UDRxU3lpfgiIV3zx4aRSwIJUOXFg+iy
         jjfmNnsg6xz7sgeBLS5/5z2s5Lokjr745SjBCx+xj+dsQ5Z/bRSNiyxbnIJ+6sElOWHD
         l0+ynn7+Nsxy9lIAsEIZRFKKM0wtlzOJRQE4CWTLcKQZEcHCHIxaETAqCOz0V4/bDi9r
         uxZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VbOdaqjppT6RsqnH/4zsfuqtLiXGz0XxiaSxTcRPwYY=;
        b=mMckF8E8gW+fOEtKB0ADXaLYNnOV+NJAW3/P5UL1CcRPb1ZuNGVOS7B6MziGoRYyHw
         dF3s9G9YlqQiuoL7lvHH+0vMV8Zap5eoRTHUCh/xCXUJLL8oeDmNFCpJXuGh2J2jWJC5
         DYiQvdnP6kOQptgpgvmRM7Q2H/xjaMUN61NsJN0L7Pjq0vGR5xlrjRPKg96j2+qzb5AH
         2492+rCbN8zfPcyY+ZzYzR/DzyZOQkLq0AYidt33XaUddSl+JyVziifZxSFXarKgZivh
         KmvpPfJgjYWLvf1Jut/AxHXE8waZtmaDNZZsZIGi93GwdDO2dLs7OpBFYjetdi/i6XfV
         hC3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si44709337qkj.327.2019.08.02.08.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:31:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 647AE4E927;
	Fri,  2 Aug 2019 15:31:27 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BA1E160635;
	Fri,  2 Aug 2019 15:31:26 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:31:24 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 03/24] mm: factor shrinker work calculations
Message-ID: <20190802153124.GC60893@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-4-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-4-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 02 Aug 2019 15:31:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:31PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Start to clean up the shrinker code by factoring out the calculation
> that determines how much work to do. This separates the calculation
> from clamping and other adjustments that are done before the
> shrinker work is run.
> 
> Also convert the calculation for the amount of work to be done to
> use 64 bit logic so we don't have to keep jumping through hoops to
> keep calculations within 32 bits on 32 bit systems.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/vmscan.c | 74 ++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 47 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ae3035fe94bc..b7472953b0e6 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -464,13 +464,45 @@ EXPORT_SYMBOL(unregister_shrinker);
>  
>  #define SHRINK_BATCH 128
>  
> +/*
> + * Calculate the number of new objects to scan this time around. Return
> + * the work to be done. If there are freeable objects, return that number in
> + * @freeable_objects.
> + */
> +static int64_t shrink_scan_count(struct shrink_control *shrinkctl,
> +			    struct shrinker *shrinker, int priority,
> +			    int64_t *freeable_objects)
> +{
> +	uint64_t delta;
> +	uint64_t freeable;
> +
> +	freeable = shrinker->count_objects(shrinker, shrinkctl);
> +	if (freeable == 0 || freeable == SHRINK_EMPTY)
> +		return freeable;
> +
> +	if (shrinker->seeks) {
> +		delta = freeable >> (priority - 2);
> +		do_div(delta, shrinker->seeks);
> +	} else {
> +		/*
> +		 * These objects don't require any IO to create. Trim
> +		 * them aggressively under memory pressure to keep
> +		 * them from causing refetches in the IO caches.
> +		 */
> +		delta = freeable / 2;
> +	}
> +
> +	*freeable_objects = freeable;
> +	return delta > 0 ? delta : 0;

I see Nikolay had some similar comments but FWIW delta is unsigned so
I'm not sure the point of the > 0 check.

Brian

> +}
> +
>  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  				    struct shrinker *shrinker, int priority)
>  {
>  	unsigned long freed = 0;
> -	unsigned long long delta;
>  	long total_scan;
> -	long freeable;
> +	int64_t freeable_objects = 0;
> +	int64_t scan_count;
>  	long nr;
>  	long new_nr;
>  	int nid = shrinkctl->nid;
> @@ -481,9 +513,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>  		nid = 0;
>  
> -	freeable = shrinker->count_objects(shrinker, shrinkctl);
> -	if (freeable == 0 || freeable == SHRINK_EMPTY)
> -		return freeable;
> +	scan_count = shrink_scan_count(shrinkctl, shrinker, priority,
> +					&freeable_objects);
> +	if (scan_count == 0 || scan_count == SHRINK_EMPTY)
> +		return scan_count;
>  
>  	/*
>  	 * copy the current shrinker scan count into a local variable
> @@ -492,25 +525,11 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	 */
>  	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
>  
> -	total_scan = nr;
> -	if (shrinker->seeks) {
> -		delta = freeable >> priority;
> -		delta *= 4;
> -		do_div(delta, shrinker->seeks);
> -	} else {
> -		/*
> -		 * These objects don't require any IO to create. Trim
> -		 * them aggressively under memory pressure to keep
> -		 * them from causing refetches in the IO caches.
> -		 */
> -		delta = freeable / 2;
> -	}
> -
> -	total_scan += delta;
> +	total_scan = nr + scan_count;
>  	if (total_scan < 0) {
>  		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
>  		       shrinker->scan_objects, total_scan);
> -		total_scan = freeable;
> +		total_scan = scan_count;

Why the change from the (now) freeable_objects value to scan_count?

Brian

>  		next_deferred = nr;
>  	} else
>  		next_deferred = total_scan;
> @@ -527,19 +546,20 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	 * Hence only allow the shrinker to scan the entire cache when
>  	 * a large delta change is calculated directly.
>  	 */
> -	if (delta < freeable / 4)
> -		total_scan = min(total_scan, freeable / 2);
> +	if (scan_count < freeable_objects / 4)
> +		total_scan = min_t(long, total_scan, freeable_objects / 2);
>  
>  	/*
>  	 * Avoid risking looping forever due to too large nr value:
>  	 * never try to free more than twice the estimate number of
>  	 * freeable entries.
>  	 */
> -	if (total_scan > freeable * 2)
> -		total_scan = freeable * 2;
> +	if (total_scan > freeable_objects * 2)
> +		total_scan = freeable_objects * 2;
>  
>  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> -				   freeable, delta, total_scan, priority);
> +				   freeable_objects, scan_count,
> +				   total_scan, priority);
>  
>  	/*
>  	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> @@ -564,7 +584,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	 * possible.
>  	 */
>  	while (total_scan >= batch_size ||
> -	       total_scan >= freeable) {
> +	       total_scan >= freeable_objects) {
>  		unsigned long ret;
>  		unsigned long nr_to_scan = min(batch_size, total_scan);
>  
> -- 
> 2.22.0
> 

