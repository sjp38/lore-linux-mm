Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3823C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:27:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A323D2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:27:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A323D2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 333626B0003; Fri,  2 Aug 2019 11:27:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E3246B0005; Fri,  2 Aug 2019 11:27:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F97B6B0006; Fri,  2 Aug 2019 11:27:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0265F6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:27:14 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z13so64854375qka.15
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:27:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9g3fuW1kieIBwJn6JvepgsC8QM8o+MRbtjySYxaxCsQ=;
        b=Ki3Nbh60MXy7Pl9haQXYYbYemox8nuTKepTjw6VKhQqjByUUvwjvl+aohivPLEQi0i
         ckJOMEzA3IoVz4+APCuoToE5TQjX436Uemxt03byNFuTMQfbMhcYDX0JTIkqp6VYGPHo
         1EJSL/ceH7+UwV/F5VatW8cEK/x0tfWheFixcchwcpJSFS/noT6qS+EhxQVIKY/My992
         sn5lfD/nLE7iF77nNl3PigNA247AnsxMBcKyK/tiwjEV6XVdSPQeCLHfLejaDqgKveur
         ieLxKkXbYTE80V2QTzH6z2Lus/V7QtIehpkCYwzo/BGsm8BnamFAjh51Pi86rH+cAdmm
         7Ijw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXbI6yMgg/FHyrIP7lxxtY0f96A1n5hkOUjAZmI1HL7YPNba0je
	uMRcY3B39RjWsrRJLXpAKYKaFYJH1J/g7a2AdQri6WoPd3fKSqPafI9a7H49PPxVvs2lIQvJVOS
	c7PEiG9w22mjdUzPCENH8/9Pi7NuoxPz07uU5a6kSYCqEdrFYW2XCJnEyGsrsXkFRcg==
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr97516361qtj.176.1564759633770;
        Fri, 02 Aug 2019 08:27:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtxYn/BlqmOfwlob24EvcoBvSGlDIoN51E7GtR64hM6Wyf7uNztrD31mjzcMCvbVmbjqFm
X-Received: by 2002:ac8:1ba9:: with SMTP id z38mr97516309qtj.176.1564759633075;
        Fri, 02 Aug 2019 08:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564759633; cv=none;
        d=google.com; s=arc-20160816;
        b=nIvyfQEApyk9SWW9Xs7O4uWVzhqyOn6R9iETUDpMVptlM/JUMxFwwIqppWbE2bWUM+
         /HWzQWNu3Z0kmjt2vX3HmgYBC0kUSqmQwdfihTsIlW96+7rUyPeQZCY08BkwHIYCAC38
         AKNrOVvrxs6CNvlYWOwKEmXYQQjYe9KDuLLBcp1mGRmvZaW6MPoY2pu7q2ewqXeZrWB+
         VcYLAw9xkPcBqp1HJHJIZSPZahcbmVAM4NPZD34CEjd5/KFWDVURuWLr7HrdblavyBQT
         /Zd8jwyiU5fNSgB477EbY2L9Ze00dmdf/uoct5LF2YlEoNELB9bYzyCDk5EYc4dPbyHf
         ZZRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9g3fuW1kieIBwJn6JvepgsC8QM8o+MRbtjySYxaxCsQ=;
        b=PSCsrjwjYBbPlaX1izTVrNGGidWqIDiSZ5KUWapnzNFLNQk1ID2J533B6Bd4+PNF61
         PrNemI1BkwxpCxBMr5wQ/EPxvkhiOZOZPsB8/CpfN87C83IgcpxiUXWr3sai6kinefxl
         uIAwKckdys77P0VwdeK3a+LRTP9S5R9k4DOHH2NzAcC0xrGCf05S6yf+q0QYw1SXFin9
         Uo+pgqdkT5sLAhob5zEobUPkXdtZ3tBIEkMcnf2+0FGcaCOR1xHVyYTGz3iu6bc0EMy0
         3UVmXF6o+MNwOzGKamquY3z7s5buHGOERwweEQF3SU/vuFQQR2x9INqJV9wb9nIsyUV8
         Ajvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i16si46702535qta.372.2019.08.02.08.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 08:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bfoster@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bfoster@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 26D163082137;
	Fri,  2 Aug 2019 15:27:12 +0000 (UTC)
Received: from bfoster (dhcp-41-2.bos.redhat.com [10.18.41.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 98BF05D9D3;
	Fri,  2 Aug 2019 15:27:11 +0000 (UTC)
Date: Fri, 2 Aug 2019 11:27:09 -0400
From: Brian Foster <bfoster@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 01/24] mm: directed shrinker work deferral
Message-ID: <20190802152709.GA60893@bfoster>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-2-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801021752.4986-2-david@fromorbit.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 02 Aug 2019 15:27:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 12:17:29PM +1000, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Introduce a mechanism for ->count_objects() to indicate to the
> shrinker infrastructure that the reclaim context will not allow
> scanning work to be done and so the work it decides is necessary
> needs to be deferred.
> 
> This simplifies the code by separating out the accounting of
> deferred work from the actual doing of the work, and allows better
> decisions to be made by the shrinekr control logic on what action it
> can take.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  include/linux/shrinker.h | 7 +++++++
>  mm/vmscan.c              | 8 ++++++++
>  2 files changed, 15 insertions(+)
> 
> diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
> index 9443cafd1969..af78c475fc32 100644
> --- a/include/linux/shrinker.h
> +++ b/include/linux/shrinker.h
> @@ -31,6 +31,13 @@ struct shrink_control {
>  
>  	/* current memcg being shrunk (for memcg aware shrinkers) */
>  	struct mem_cgroup *memcg;
> +
> +	/*
> +	 * set by ->count_objects if reclaim context prevents reclaim from
> +	 * occurring. This allows the shrinker to immediately defer all the
> +	 * work and not even attempt to scan the cache.
> +	 */
> +	bool will_defer;

Functionality wise this seems fairly straightforward. FWIW, I find the
'will_defer' name a little confusing because it implies to me that the
shrinker is telling the caller about something it would do if called as
opposed to explicitly telling the caller to defer. I'd just call it
'defer' I guess, but that's just my .02. ;P

>  };
>  
>  #define SHRINK_STOP (~0UL)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 44df66a98f2a..ae3035fe94bc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -541,6 +541,13 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
>  				   freeable, delta, total_scan, priority);
>  
> +	/*
> +	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
> +	 * defer the work to a context that can scan the cache.
> +	 */
> +	if (shrinkctl->will_defer)
> +		goto done;
> +

Who's responsible for clearing the flag? Perhaps we should do so here
once it's acted upon since we don't call into the shrinker again?

Note that I see this structure is reinitialized on every iteration in
the caller, but there already is the SHRINK_EMPTY case where we call
back into do_shrink_slab(). Granted the deferred state likely hasn't
changed, but the fact that we'd call back into the count callback to set
it again implies the logic could be a bit more explicit, particularly if
this will eventually be used for more dynamic shrinker state that might
change call to call (i.e., object dirty state, etc.).

BTW, do we need to care about the ->nr_cached_objects() call from the
generic superblock shrinker (super_cache_scan())?

Brian

>  	/*
>  	 * Normally, we should not scan less than batch_size objects in one
>  	 * pass to avoid too frequent shrinker calls, but if the slab has less
> @@ -575,6 +582,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  		cond_resched();
>  	}
>  
> +done:
>  	if (next_deferred >= scanned)
>  		next_deferred -= scanned;
>  	else
> -- 
> 2.22.0
> 

