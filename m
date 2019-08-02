Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B4EC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:34:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C92C2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C92C2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C54996B000E; Fri,  2 Aug 2019 11:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C05BE6B0010; Fri,  2 Aug 2019 11:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1B046B0266; Fri,  2 Aug 2019 11:34:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9027F6B000E
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:34:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so68324832qtp.1
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:34:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QSoDQP6C0ulJm/JyqeR0nhLTWnmKZYLgfDNarj/XzJo=;
        b=AjxGEOlDMAqbPDMn77mpeZrWMLPEtIPhNSoN4KAqKnvEAkVMGBM8G1lf9WaMClS3Is
         uq1KRidoVMAqaG5KVL1uj3qRoGdRji3YBT7SzuDJ7iZ2eFhMY4noVyoYRC7ptHu3TDM4
         +ipK2kviZWXwA9bsW85RHW9Z7kQiTV1rd+SG0TAvF+9V1Y/SuQTVe7XUtMllZ3YsUOro
         jDEyrn2WlLRRxWDjQHugxonvahJv8J8/eVEHAPXD1VOlfGBP6VsRjJul/mZsqneIv32T
         t/sBRfeuye0fs0IEp8WJ7IdkLWhpi8AGhGaDZnQ8SQH4URbNZ7Wjee1MTVzRKSQ0yy12
         tP1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUT/9r0ijji92MZkKwI08KIYM9OAgHGxfIrAfE41fkb4KmfXFvI
	mXyK+P9mopkKC8YgyPgp98/pmLkeqQ7ojNEyJYe3sQRM2DGoEoKWNET4J9Ram5xvpNu1mvkjXPC
	q8F3HqSrsJMxp2sjjemS6GeHyB+TgkPsBzsQmNjID4E6G9KR+zJKkxEIPphw2g9hCFw==
X-Received: by 2002:a37:5d87:: with SMTP id r129mr57906134qkb.388.1564760045310;
        Fri, 02 Aug 2019 08:34:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzp/99YIJ9J9tnPRd4NE1FZM9ZD3q8wcts2kMAVXtXjzcnbDTLfsSwRfVdlhsK+0vKst9wA
X-Received: by 2002:a37:5d87:: with SMTP id r129mr57906056qkb.388.1564760044375;
        Fri, 02 Aug 2019 08:34:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564760044; cv=none;
        d=google.com; s=arc-20160816;
        b=b8EIXUq/4WLbWv/VI2q8rnmiMYOxSkIeklPedOMfl1TML3t+aAOCKejp3YGK5E2e1K
         6hRKDz10qJKZCRrDif6e5QIDGCivVJle/xZo6wAQ+jjX2moN8hwF04EqB7S4+GWG0nvG
         A7Xd6oYSSchTEXayufYn3BbyRlCFZnB76Rf8Iv30luJTJLzA/wkvd1lee+dE41JD3QYW
         Y+WoFS4H0tL7ctaUKnAWdBrg4TzPA0cQROAnyp16bNFoknpnG9QaVmp/s4NjWKMMOns7
         +Ynwpp3MJnh+/VFriTd3TzkCWY1QYoh4aYOAINJd/IEvL1ST4wTwQAONaSy1OyTnW96b
         CkLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QSoDQP6C0ulJm/JyqeR0nhLTWnmKZYLgfDNarj/XzJo=;
        b=LWFh5uDumJTfgYPbtmT31ehyE0TVtRrvZvHwdnapvWd6X2kMX+1CVXtEhnvXXLUkQ0
         yZ2sQWSmKh55LpU20uuJovDJI4/md5B59PAAv+ZsdyKcxToXSDwXbK7zmOMGxq0hIsSv
         MTI9jDRCNurxiDEslUROQUcMYqMoZjcVpU60NoY2XElqOpt5MH3mho0VZLsXyIcet776
         DQK42cCBGBx1SRfxVeC+LEmWvjPQjq8koEEO51NChHdeuvPW/e+uh6Bu0osAXfqp+ykf
         hrW1B553Cl5uhoPx99+wkeNNCutzQlFZk0Gr2PfCzmX0wrOUKejROp4na98Xz8vsxZSn
         nMOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si42942304qke.126.2019.08.02.08.34.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:34:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 940DE309DEF3;
	Fri,  2 Aug 2019 15:34:03 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 012C219C6A;
	Fri,  2 Aug 2019 15:34:02 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:34:01 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 04/24] shrinker: defer work only to kswapd
Message-ID: <20190802153400.GD60893@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-5-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-5-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 02 Aug 2019 15:34:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:32PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Right now deferred work is picked up by whatever GFP_KERNEL context
> reclaimer that wins the race to empty the node's deferred work
> counter. However, if there are lots of direct reclaimers, that
> work might be continually picked up by contexts taht can't do any
> work and so the opportunities to do the work are missed by contexts
> that could do them.
> 
> A further problem with the current code is that the deferred work
> can be picked up by a random direct reclaimer, resulting in that
> specific process having to do all the deferred reclaim work and
> hence can take extremely long latencies if the reclaim work blocks
> regularly. This is not good for direct reclaim fairness or for
> minimising long tail latency events.
> 
> To avoid these problems, simply limit deferred work to kswapd
> contexts. We know kswapd is a context that can always do reclaim
> work, and hence deferring work to kswapd allows the deferred work to
> be done in the background and not adversely affect any specific
> process context doing direct reclaim.
> 
> The advantage of this is that amount of work to be done in direct
> reclaim is now bound and predictable - it is entirely based on
> the cache's freeable objects and the reclaim priority. hence all
> direct reclaimers running at the same time should be doing
> relatively equal amounts of work, thereby reducing the incidence of
> long tail latencies due to uneven reclaim workloads.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/vmscan.c | 93 ++++++++++++++++++++++++++++-------------------------
>  1 file changed, 50 insertions(+), 43 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b7472953b0e6..c583b4efb9bf 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -500,15 +500,15 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  				    struct shrinker *shrinker, int priority)
>  {
>  	unsigned long freed = 0;
> -	long total_scan;
>  	int64_t freeable_objects = 0;
>  	int64_t scan_count;
> -	long nr;
> +	int64_t scanned_objects = 0;
> +	int64_t next_deferred = 0;
> +	int64_t deferred_count = 0;
>  	long new_nr;
>  	int nid = shrinkctl->nid;
>  	long batch_size = shrinker->batch ? shrinker->batch
>  					  : SHRINK_BATCH;
> -	long scanned = 0, next_deferred;
>  
>  	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
>  		nid = 0;
> @@ -519,47 +519,53 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  		return scan_count;
>  
>  	/*
> -	 * copy the current shrinker scan count into a local variable
> -	 * and zero it so that other concurrent shrinker invocations
> -	 * don't also do this scanning work.
> +	 * If kswapd, we take all the deferred work and do it here. We don't let
> +	 * direct reclaim do this, because then it means some poor sod is going
> +	 * to have to do somebody else's GFP_NOFS reclaim, and it hides the real
> +	 * amount of reclaim work from concurrent kswapd operations. Hence we do
> +	 * the work in the wrong place, at the wrong time, and it's largely
> +	 * unpredictable.
> +	 *
> +	 * By doing the deferred work only in kswapd, we can schedule the work
> +	 * according the the reclaim priority - low priority reclaim will do
> +	 * less deferred work, hence we'll do more of the deferred work the more
> +	 * desperate we become for free memory. This avoids the need for needing
> +	 * to specifically avoid deferred work windup as low amount os memory
> +	 * pressure won't excessive trim caches anymore.
>  	 */
> -	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> +	if (current_is_kswapd()) {
> +		int64_t	deferred_scan;
>  
> -	total_scan = nr + scan_count;
> -	if (total_scan < 0) {
> -		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
> -		       shrinker->scan_objects, total_scan);
> -		total_scan = scan_count;
> -		next_deferred = nr;
> -	} else
> -		next_deferred = total_scan;
> +		deferred_count = atomic64_xchg(&shrinker->nr_deferred[nid], 0);
>  
> -	/*
> -	 * We need to avoid excessive windup on filesystem shrinkers
> -	 * due to large numbers of GFP_NOFS allocations causing the
> -	 * shrinkers to return -1 all the time. This results in a large
> -	 * nr being built up so when a shrink that can do some work
> -	 * comes along it empties the entire cache due to nr >>>
> -	 * freeable. This is bad for sustaining a working set in
> -	 * memory.
> -	 *
> -	 * Hence only allow the shrinker to scan the entire cache when
> -	 * a large delta change is calculated directly.
> -	 */
> -	if (scan_count < freeable_objects / 4)
> -		total_scan = min_t(long, total_scan, freeable_objects / 2);
> +		/* we want to scan 5-10% of the deferred work here at minimum */
> +		deferred_scan = deferred_count;
> +		if (priority)
> +			do_div(deferred_scan, priority);
> +		scan_count += deferred_scan;
> +
> +		/*
> +		 * If there is more deferred work than the number of freeable
> +		 * items in the cache, limit the amount of work we will carry
> +		 * over to the next kswapd run on this cache. This prevents
> +		 * deferred work windup.
> +		 */
> +		if (deferred_count > freeable_objects * 2)
> +			deferred_count = freeable_objects * 2;
> +

Hmm, what's the purpose of this check? Is this not handled once the
deferred count is absorbed into scan_count (where we apply the same
logic a few lines below)? Perhaps the latter prevents too much scanning
in a single call into the shrinker whereas this check prevents kswapd
from getting too far behind?

> +	}
>  
>  	/*
>  	 * Avoid risking looping forever due to too large nr value:
>  	 * never try to free more than twice the estimate number of
>  	 * freeable entries.
>  	 */
> -	if (total_scan > freeable_objects * 2)
> -		total_scan = freeable_objects * 2;
> +	if (scan_count > freeable_objects * 2)
> +		scan_count = freeable_objects * 2;
>  
> -	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
> +	trace_mm_shrink_slab_start(shrinker, shrinkctl, deferred_count,
>  				   freeable_objects, scan_count,
> -				   total_scan, priority);
> +				   scan_count, priority);
>  
>  	/*
>  	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> @@ -583,10 +589,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	 * scanning at high prio and therefore should try to reclaim as much as
>  	 * possible.
>  	 */
> -	while (total_scan >= batch_size ||
> -	       total_scan >= freeable_objects) {
> +	while (scan_count >= batch_size ||
> +	       scan_count >= freeable_objects) {
>  		unsigned long ret;
> -		unsigned long nr_to_scan = min(batch_size, total_scan);
> +		unsigned long nr_to_scan = min_t(long, batch_size, scan_count);
>  
>  		shrinkctl->nr_to_scan = nr_to_scan;
>  		shrinkctl->nr_scanned = nr_to_scan;
> @@ -596,17 +602,17 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  		freed += ret;
>  
>  		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
> -		total_scan -= shrinkctl->nr_scanned;
> -		scanned += shrinkctl->nr_scanned;
> +		scan_count -= shrinkctl->nr_scanned;
> +		scanned_objects += shrinkctl->nr_scanned;
>  
>  		cond_resched();
>  	}
>  
>  done:
> -	if (next_deferred >= scanned)
> -		next_deferred -= scanned;
> -	else
> -		next_deferred = 0;
> +	if (deferred_count)
> +		next_deferred = deferred_count - scanned_objects;
> +	else if (scan_count > 0)
> +		next_deferred = scan_count;

I was wondering why we dropped the >= scanned_objects check, but I see
that next_deferred is signed and we check for next_deferred > 0 below.
What is odd is that so is scan_count, yet we check > 0 here for
assignment to the same variable. Can we be a little more consistent here
one way or the other?

Brian

>  	/*
>  	 * move the unused scan count back into the shrinker in a
>  	 * manner that handles concurrent updates. If we exhausted the
> @@ -618,7 +624,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	else
>  		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
>  
> -	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
> +	trace_mm_shrink_slab_end(shrinker, nid, freed, deferred_count, new_nr,
> +					scan_count);
>  	return freed;
>  }
>  
> -- 
> 2.22.0
> 

