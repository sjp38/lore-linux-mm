Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E252C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34DD120449
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:22:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34DD120449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B75C16B0007; Mon, 29 Apr 2019 08:22:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFCE46B0008; Mon, 29 Apr 2019 08:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EE706B000A; Mon, 29 Apr 2019 08:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4456B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 08:22:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so4739472edi.20
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 05:22:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jUxNE42wbM4/6mW5jZrdyIqGDDXelc9NWJ1DVi6XnSo=;
        b=ZDF1sG9rYQf4m4yBvSxaRAF+tfhI7MdV9q266USMxheqaV3f2Dmkr7yW1xUnEOmVie
         8urP/AVJRRMQcoWQYQaDbdwFmbfAwEj5risXE3St7tYmKUAG8/mvsuKArF2UNXaFyMFp
         oavVlGOEMlHhUr0cONNe6LhOvz3H2aujJJ7vUkDjx+ZqJM2EtszKuz0oqlGJaYEYu0h8
         vMhKSw5tHrFedeLwzBmFpqD8z3JK7XTUtmVP9KDyf2jpD+LUqBgXoVWA5Z2Qr4eN0bk8
         3qCQ1qx8Z5OOhJhVvVRF154d07sy1I40rUEY+fPFtcWO+GBn8E4i+8QhT7X7ZorFjhgn
         jydg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWewgtl7hOlG2KjFCqbmQh7xeNt3NP39Aef8XE0ZlV5gPxCf6fv
	f2i0R9ZKwQPA3DIJn587sGcrdY1Vhp9p5YlldVAnBjVt37E3xquFyuqZ8TUVotfmJew/8tstKPm
	JgbeA2e3O+zlhevSBPDVXvuH6cSxlaQygfEAooqEAGayTtJ1E+HryONHVipYeysY=
X-Received: by 2002:a50:87c7:: with SMTP id 7mr38038994edz.5.1556540539874;
        Mon, 29 Apr 2019 05:22:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzW9+TUJKA0qDGOBKCuGE+pPf4kJclCmcvlBPCI1lFNUHp6RdFVlEQl5wABCAOWgMHTO16E
X-Received: by 2002:a50:87c7:: with SMTP id 7mr38038948edz.5.1556540538978;
        Mon, 29 Apr 2019 05:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556540538; cv=none;
        d=google.com; s=arc-20160816;
        b=hkoPmhxuN5ImNJlmh/oYxXUloVohp6p21FabjRX8tQiFa336F4wziiuBpkjb6wWBBr
         b76P4qheBpYC5/ndop3ZOeBRYESqX0YoyIkk+L928T2858K9J1VqpWiZzeahK8uUZ1cT
         OnpHKVPlUrsdR3877JarCM/u73Ezkk/bHwK0entvu2T6aRiVsOK+If8Jqamdwd8EzKss
         qimcW+Je3by2iIvQwpia5H7+RR0cJMFHDiPdeDO0+CM8XOhHsqeCDsy15kneLkE4BlMD
         ZS0Zg87EBPFwKm6+p11ZK3NfT0F/PC9grPjFBALqfboYvk5YY8ItHADvfZvbicbLXq1j
         oSdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jUxNE42wbM4/6mW5jZrdyIqGDDXelc9NWJ1DVi6XnSo=;
        b=pQIVRQLHXu5Jgk2rF7Hp/tl6a4LB8b/khqCivZ/CDZ7NMDzW+oeVwhU2qTx54+t4M4
         VIj3hnbAPEKta1uibNE4pvuIZ1VYNMtm+/H8tfqFfOm4Namqioc9CqGPJ4boW2ks+2bv
         F/HXPEQOptYIXdC6eyLFcbPndQ/2IkiS4FVsxaXVnFAr6emY6sUrRHSJhsReXqQqC1kn
         PcK9hNEj4SXLlx3OOgxF4T7PV94n6I+eJfV/K3P5hB6XedpQECm+hginXFg2LO/1VFB8
         sgGER8qt8hyA7DpH6Rd/kymtrJXMF56Bb5RCiUnJEILPfvxBAP5n8+u5Hrf0iH+vwDNw
         6bYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5si163693ejj.63.2019.04.29.05.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 05:22:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7349CAE1B;
	Mon, 29 Apr 2019 12:22:18 +0000 (UTC)
Date: Mon, 29 Apr 2019 08:22:14 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
Message-ID: <20190429122214.GK21837@dhcp22.suse.cz>
References: <20190428235613.166330-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190428235613.166330-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 28-04-19 16:56:13, Shakeel Butt wrote:
> The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
> OOM killer will not be triggered and indeed the page alloc does not
> invoke OOM killer for such allocations. However we do trigger memcg
> OOM killer for __GFP_RETRY_MAYFAIL. Fix that.

An example of __GFP_RETRY_MAYFAIL memcg OOM report would be nice. I
thought we haven't been using that flag for memcg allocations yet.
But this is definitely good to have addressed.

> Signed-off-by: Shakeel Butt <shakeelb@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2713b45ec3f0..99eca724ed3b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2294,7 +2294,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned long nr_reclaimed;
>  	bool may_swap = true;
>  	bool drained = false;
> -	bool oomed = false;
>  	enum oom_status oom_status;
>  
>  	if (mem_cgroup_is_root(memcg))
> @@ -2381,7 +2380,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (nr_retries--)
>  		goto retry;
>  
> -	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
> +	if (gfp_mask & __GFP_RETRY_MAYFAIL)
>  		goto nomem;
>  
>  	if (gfp_mask & __GFP_NOFAIL)
> @@ -2400,7 +2399,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	switch (oom_status) {
>  	case OOM_SUCCESS:
>  		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> -		oomed = true;
>  		goto retry;
>  	case OOM_FAILED:
>  		goto force;
> -- 
> 2.21.0.593.g511ec345e18-goog
> 

-- 
Michal Hocko
SUSE Labs

