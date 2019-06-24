Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA62C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:53:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 777E52089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 08:53:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 777E52089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 156668E0007; Mon, 24 Jun 2019 04:53:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E0F78E0002; Mon, 24 Jun 2019 04:53:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F10A48E0007; Mon, 24 Jun 2019 04:53:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89A8E8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 04:53:38 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id s14so2156120ljd.13
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:53:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=u5tS/iA+7+FkYFkOUO0oNR26ml579ZCMCCIENEs9uW8=;
        b=O6caVt2T9/GIHo9QxJm83cv8YXuJScZbkhDGhQodreLDi5U69I/wWQ0+yCg4qZXKQ9
         x7uBkH8xbsncEmsl+6HrgPxT6rb0p20Alf0riyDGPwxBB3cUm/UZjZd4/zNAgF+q2MMm
         xrcsH67xVb01Km0iAMKDYN8uPG/EwHbOO4nZjqgHdJfhTlXmXAiMmBsDuq2n1WjACYAB
         a6yHw783rqmCAFvD3FOvaVTWRh56GhcYyUjkaESY9swk/UIHsVTE2dTNoD9dv5NanVdG
         /c+VRK+oKX4NKtCT3t2wz4ZZb/z2QXE1inGDcJm3jULL94mw7tm5K9bQSZ7HoFpgDj3U
         BKzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVXfhz/J3/h44ajfhps+KbplnecQ0gxx/ECFTN3UY0WjU9/K58B
	rk2+Bn7DDynbBvEjq8Ir3/mFe0eAY89zwz1x1ePLr+viFyYBlxjFA4uOC5R8Q/XLAvWE7Vt0ATi
	X2nhD1IDTFMWpvpaxUZn3TVOfKSutFQmwal4JO0pi8QME07uIXsQyfUSw7CV0Unp7Wg==
X-Received: by 2002:a05:651c:150:: with SMTP id c16mr38469722ljd.193.1561366417816;
        Mon, 24 Jun 2019 01:53:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdiUjwx54xzrCQOEmHBOks73W448mmUbSrPvKrdDyEZIYWoVjuAYSUN9p6tIXrfy6keE6V
X-Received: by 2002:a05:651c:150:: with SMTP id c16mr38469688ljd.193.1561366416913;
        Mon, 24 Jun 2019 01:53:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561366416; cv=none;
        d=google.com; s=arc-20160816;
        b=Lw0V6I9Tfmc46vwUKxzU5yi0H8dFsuTP/5ggWIYjci+qU05Y24o1yjx5pMkWBr5Qf0
         j8Afw33EdwzefWa1FwGFjOjzLMDRUsainDBd5Ma+V4zRYXtWDkMe59Nv5nd2s3wHLRDx
         RxwobxcEIo3B8cBRAnpgr0wPKICsstLeGBmP7EcHdbVBiO1GGxQ41KWExbfTSsVfJAzR
         beMQ3W7YgocSCcyIb0rf0pqHCAup/6rhMo9urhWe4f4gAyMwMGg4K8qSw7RZpoTatese
         QoMjpYAP4g+j5HfDWPyLbiEaRfXmFgStbiex/4IIZPef2tjCLVtCKjjYULYnkcjdswJz
         Rv2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=u5tS/iA+7+FkYFkOUO0oNR26ml579ZCMCCIENEs9uW8=;
        b=l/pUut6yq4YTAdI1pRh9jxpfztO0NBbq5FCRcUSOiHDfNmqfltAngzmo1Nk8kk9kof
         vmU9csa0Uk8dQ90XMQCtEBLHZ4UkWFH96Hdpm8t7TPKpy2ljx/XjJf3Vq6Z4D9YjNkCv
         SQyvbg6FyFwQok8suYTA9zUpIDqTg6DMtbqlDvdkIFSzDmuMOptvh4YLZOdlGdOk6gR0
         j4Xx/D/Vh1R13Cx81X3afCjgzE3I7Tvunc8z2srQq3Ap+6eoExbtSd3HgFjLwXuReoNG
         VmbG28Is1N++6VHGJdjnTSBrB7kogGNQZzL02ooFCQKzsgeRMLz1AoaXoQF+cv4Tb/s/
         v93A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m127si10074069lfa.65.2019.06.24.01.53.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 01:53:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hfKjE-000288-VO; Mon, 24 Jun 2019 11:53:33 +0300
Subject: Re: [PATCH 2/2] mm/vmscan: calculate reclaimed slab caches in all
 reclaim paths
To: Yafang Shao <laoar.shao@gmail.com>, akpm@linux-foundation.org,
 mhocko@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com,
 mgorman@techsingularity.net
Cc: linux-mm@kvack.org
References: <1561112086-6169-1-git-send-email-laoar.shao@gmail.com>
 <1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <d919ea73-daea-8a77-da0a-d1dc6089fd92@virtuozzo.com>
Date: Mon, 24 Jun 2019 11:53:31 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <1561112086-6169-3-git-send-email-laoar.shao@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 21.06.2019 13:14, Yafang Shao wrote:
> There're six different reclaim paths by now,
> - kswapd reclaim path
> - node reclaim path
> - hibernate preallocate memory reclaim path
> - direct reclaim path
> - memcg reclaim path
> - memcg softlimit reclaim path
> 
> The slab caches reclaimed in these paths are only calculated in the above
> three paths.
> 
> There're some drawbacks if we don't calculate the reclaimed slab caches.
> - The sc->nr_reclaimed isn't correct if there're some slab caches
>   relcaimed in this path.
> - The slab caches may be reclaimed thoroughly if there're lots of
>   reclaimable slab caches and few page caches.
>   Let's take an easy example for this case.
>   If one memcg is full of slab caches and the limit of it is 512M, in
>   other words there're approximately 512M slab caches in this memcg.
>   Then the limit of the memcg is reached and the memcg reclaim begins,
>   and then in this memcg reclaim path it will continuesly reclaim the
>   slab caches until the sc->priority drops to 0.
>   After this reclaim stops, you will find there're few slab caches left,
>   which is less than 20M in my test case.
>   While after this patch applied the number is greater than 300M and
>   the sc->priority only drops to 3.
> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/vmscan.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 18a66e5..d6c3fc8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3164,11 +3164,13 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  	if (throttle_direct_reclaim(sc.gfp_mask, zonelist, nodemask))
>  		return 1;
>  
> +	current->reclaim_state = &sc.reclaim_state;
>  	trace_mm_vmscan_direct_reclaim_begin(order, sc.gfp_mask);
>  
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
>  
>  	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
> +	current->reclaim_state = NULL;

Shouldn't we remove reclaim_state assignment from __perform_reclaim() after this?
  
>  	return nr_reclaimed;
>  }
> @@ -3191,6 +3193,7 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>  	};
>  	unsigned long lru_pages;
>  
> +	current->reclaim_state = &sc.reclaim_state;
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>  
> @@ -3212,7 +3215,9 @@ unsigned long mem_cgroup_shrink_node(struct mem_cgroup *memcg,
>  					cgroup_ino(memcg->css.cgroup),
>  					sc.nr_reclaimed);
>  
> +	current->reclaim_state = NULL;
>  	*nr_scanned = sc.nr_scanned;
> +
>  	return sc.nr_reclaimed;
>  }
>  
> @@ -3239,6 +3244,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  		.may_shrinkslab = 1,
>  	};
>  
> +	current->reclaim_state = &sc.reclaim_state;
>  	/*
>  	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim doesn't
>  	 * take care of from where we get pages. So the node where we start the
> @@ -3263,6 +3269,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	trace_mm_vmscan_memcg_reclaim_end(
>  				cgroup_ino(memcg->css.cgroup),
>  				nr_reclaimed);
> +	current->reclaim_state = NULL;
>  
>  	return nr_reclaimed;
>  }
> 

