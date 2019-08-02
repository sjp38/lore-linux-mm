Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC85DC41514
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6548B2173E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:08:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6548B2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCC076B000A; Fri,  2 Aug 2019 11:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7CAB6B000E; Fri,  2 Aug 2019 11:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1B7D6B0010; Fri,  2 Aug 2019 11:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50A0D6B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:08:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so47157685eds.14
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:08:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=n5gWFAm5Uk4kY3aLlXxCy+8L3NlATafIb62I37HexLo=;
        b=rRL0nmEq90XFM7Mc6J2xEtVDfAqolGYAJufjSjlzKTWobUdtQvG7+c/tSsN64T4/lD
         694rPTJN4RFYDI6Ih93KFqNaVq37y5CI/4bTG1kO8KqW93dSytXJr23h9hxxNiymt5sm
         iSao1hRAb7WXY1BfzMM3QpboynEh7uI9EvBcU3HqwRVU+empUAcKvGayui2n686imDEz
         sxR/dwXdpE7CYhmhuJAnh/3i7AO43QUl7eOEA5IlzEoaSmB43O8StZVpB6kkI2vHX/Gp
         fPxRxDyhjV8v7CvgdkOF4b2MZfS1N/g+yjA/v+pbJRPcKtYANxJQzGjkwC0nG/8awK47
         j4hQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
X-Gm-Message-State: APjAAAUBy3aNbVO4paPvMW04DNv1GlMTAlRBpYMBwopIqT0SIap0CcwY
	nW2cfzsDkCVQMgG6Vh0bOUU6W22IMjIfLc42J4cT4muKTRUxC2mgmRDaZZ9A1EmJq0ZUZi0Ze5A
	VLRul3b3ZyoNn8MCNkYb1QutC/u0EWIpkGCuqOBFJ4z4fgqC3IjwUotFB8lbb8gIMLg==
X-Received: by 2002:a50:b34a:: with SMTP id r10mr118921017edd.84.1564758520881;
        Fri, 02 Aug 2019 08:08:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO8Nrs0rC448t05mOQVR9Ic7vldEh+SvGGqNcNBL7HR3xsV/GxJ2N01oB51iAS7ZQlSsyh
X-Received: by 2002:a50:b34a:: with SMTP id r10mr118920928edd.84.1564758520121;
        Fri, 02 Aug 2019 08:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564758520; cv=none;
        d=google.com; s=arc-20160816;
        b=GfN8O6i2V532DVsEMNkMwr/YfaS6CK1Ond5mETzor9ZvkCzqvg/jTF9bEjAjchs28/
         rnNbboresKfCjlbEVJ6s91sg04ayif8yd7TmrSzn/t197YaXIJlddyauONmPE9Kfc62D
         7kyLqjxcMGZY4j+rdBizqn8LBUPwWe3onI5xtn9LO3zxccM7lMDt1QWFIK1kmM67GBH/
         avURMiSsjBoT+XcP5qCFd8FENg6YjVi8hIH+z4TA+gxHG0MbU3i4hbUErwTQcMxD8UiZ
         DSNUh1jA6qoZZPdsZ03Z498JEnkisK8s+VOWunmk20PTXXnil62y5gU1TLpDv4/wCpP8
         heqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=n5gWFAm5Uk4kY3aLlXxCy+8L3NlATafIb62I37HexLo=;
        b=BX/VkjuMe3av78FVsLOlrIm7/VWMoAFi+J1pd2kQb8FCDt355JixXmzSZaAwddNb+9
         L1FcKnQYgoUwbpTKYBTPnGmPr2O4TIe9g75w2kdSDFXfm5MOAXPX2deBLk7i5fVSgP55
         e/kngI10pFvCUgRDjScPSEj+RmEpms3hpgiKiSZTyQKH0VuW/mBg1duSf3BxxQ3HbWVd
         Xe2xFQwwcCd6g34lONVixOfVBxhdQLrd3T7KyPStjV+tnYIgvviVmcPjSewz70bhqOnC
         hv4ANbS7Sia5f3rFnm/8qOg6kftBMw2gYzenK/wxXXIUwB6OYAVrpYmUCIWFgVs1pbqZ
         PWoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ot29si21686201ejb.111.2019.08.02.08.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nborisov@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=nborisov@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 93BA7AF33;
	Fri,  2 Aug 2019 15:08:39 +0000 (UTC)
Subject: Re: [PATCH 03/24] mm: factor shrinker work calculations
To: Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-4-david@fromorbit.com>
From: Nikolay Borisov <nborisov@suse.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nborisov@suse.com; prefer-encrypt=mutual; keydata=
 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
Message-ID: <e07bf57b-a9cb-cb7b-b2be-3ec1b355a184@suse.com>
Date: Fri, 2 Aug 2019 18:08:37 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190801021752.4986-4-david@fromorbit.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 1.08.19 г. 5:17 ч., Dave Chinner wrote:
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

nit: make the return parm definition also uin64_t, also we have u64 types.

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

a comment about the reasoning behind this calculation would be nice.

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

why int and not uint64 ? We can never have negative object count, right?

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
> 

