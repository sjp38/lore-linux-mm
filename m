Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 652FFC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:31:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E058420665
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 09:31:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E058420665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B7506B0010; Thu, 18 Jul 2019 05:31:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5678E6B0266; Thu, 18 Jul 2019 05:31:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47E078E0001; Thu, 18 Jul 2019 05:31:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id D75B26B0010
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 05:31:07 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id t23so2603769lfb.8
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:31:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WuLiywGOIShYm0YDAjCBo505NckwLnW3jPpCRP8xNcY=;
        b=aaXKe2vXqMaGrLEhTKnx0ZQDd7Me3HNNCupjGZDenw0zYSPhW+YniLQ8p7oxL9K1rt
         gzU1XR21n242520mZH9y3YdhAmzZq/UqD41Im0RUXcthbMeUlQEKmwalxTbmjAVznai2
         ijEclmbV22KR+vuHUI4uxqGSiiwk/gMeqtxaIWAfQZVeMwqrhG4Xkt0AnCQVy/ciSuBU
         Z257Tyjx7sOmjfmPsAKvdC8DW+AHD117WUm7hY3mqsZVQOYTNTr7V97+aILwmVI+Infp
         HYTfidEyqk7wimLXlZN7S6BAL84HKkGF946P1UaRqbOXYXgbYgotyPMX/7Z0OFHGKd4z
         pjZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUmuXcbeRnXsScgKjnCNn+l4IBjFb5kEF829zFBoPVkRuRqcdNB
	t8OvMgmv7O0vX3k2c9vCnj/n1ia4n0YAr2L8RzcYVBm9IttCVSEtYiRO6tr7QEp8AX5JcsEgiFl
	RXg0epDE9wLDv4nPp0kxrGqt5Fmor043nBk4/TJs8ePzhWZ4vGNZ8JalO8jlc90bCzA==
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr23862165ljj.34.1563442267137;
        Thu, 18 Jul 2019 02:31:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMlXzkJv32ZI/6ZY4OmMwYrwZATkeDyx/RjqNVAfhBIm5iHXxs69qNnMargHaI3jT6SQQB
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr23862117ljj.34.1563442266084;
        Thu, 18 Jul 2019 02:31:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563442266; cv=none;
        d=google.com; s=arc-20160816;
        b=SHkwPu5DWSVb7m09kA04xiuTEm3DRMw2t9/ITAbow7xYKCNqfMn7pTPDXltAXWgzC8
         gIlQOhfVwIbcbnJNo4Fz/IsQUs3gnjeUrvC9QUwbXqxLwIZXrHsH5++fd2He32NrsPpG
         s7Qjy1rIm3T6CybI5a/ozriqlNWRjWvdkBOfjwXF/HhVqDmFqVQCUdSEJKHH9KzktR0s
         hsGUFfSDb7R9Wtr/ye1ZLPC2rGW5cTJb5uutZGQ/+fNwY0leHWUjbnBvYJDuCXkjdp9o
         j6hiHj2miwU0oxWpHFH8a40brHSVj4JzCPdYMARtMoyWRmIWipa27hn5KDcNGnxuR/nq
         Jj3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WuLiywGOIShYm0YDAjCBo505NckwLnW3jPpCRP8xNcY=;
        b=S3R8ow+i9HCVjqx1lJ6oZ3sQcZHsUPTdTd9zcMfttySpF+PkgQL2Cq784EVZJtD80G
         DudzXNSmUxrW3Rb7UZqTke+H9aa8H+cYZHLDjQ71wpx7CcSJJh0A2p8AwXZOds9UnXtz
         jPKC/U93vasEjtyiBQJDlCaB6qiO3DoiSvb2E73RXyL9cHyhIQ9VvBe/nwKIzZNkVk+u
         ackpe0ZY7Peny2hbOCfb73mUCz0iUr4z9gNub0lSbsFz6Gi3ZytAEg5emCDy7UGCL4SL
         /ZOV88j6Vhd5EcgNKqTUafBeDVDXbkTrBnpiQb6jqimJA0qukUb5Oo3ciedGfREqGFWl
         dgbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l6si18886590lfh.21.2019.07.18.02.31.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 02:31:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1ho2ke-0005VV-9n; Thu, 18 Jul 2019 12:31:00 +0300
Subject: Re: [PATCH] mm: vmscan: check if mem cgroup is disabled or not before
 calling memcg slab shrinker
To: Yang Shi <yang.shi@linux.alibaba.com>, shakeelb@google.com,
 vdavydov.dev@gmail.com, hannes@cmpxchg.org, mhocko@suse.com, guro@fb.com,
 hughd@google.com, cai@lca.pw, kirill.shutemov@linux.intel.com,
 akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <fca59732-cd98-7e44-8c92-49ebafc6f41c@virtuozzo.com>
Date: Thu, 18 Jul 2019 12:30:49 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1563385526-20805-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.07.2019 20:45, Yang Shi wrote:
> Shakeel Butt reported premature oom on kernel with
> "cgroup_disable=memory" since mem_cgroup_is_root() returns false even
> though memcg is actually NULL.  The drop_caches is also broken.
> 
> It is because commit aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab()
> calls in shrink_node()") removed the !memcg check before
> !mem_cgroup_is_root().  And, surprisingly root memcg is allocated even
> though memory cgroup is disabled by kernel boot parameter.
> 
> Add mem_cgroup_disabled() check to make reclaimer work as expected.
> 
> Fixes: aeed1d325d42 ("mm/vmscan.c: generalize shrink_slab() calls in shrink_node()")
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org  4.19+
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Surprise really.

We have mem_cgroup as not early inited, so all of these boundary
cases and checks has to be supported. But it looks like it's not
possible to avoid that in any way.

> ---
>  mm/vmscan.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f8e3dcd..c10dc02 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -684,7 +684,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  	unsigned long ret, freed = 0;
>  	struct shrinker *shrinker;
>  
> -	if (!mem_cgroup_is_root(memcg))
> +	/*
> +	 * The root memcg might be allocated even though memcg is disabled
> +	 * via "cgroup_disable=memory" boot parameter.  This could make
> +	 * mem_cgroup_is_root() return false, then just run memcg slab
> +	 * shrink, but skip global shrink.  This may result in premature
> +	 * oom.
> +	 */
> +	if (!mem_cgroup_disabled() && !mem_cgroup_is_root(memcg))
>  		return shrink_slab_memcg(gfp_mask, nid, memcg, priority);
>  
>  	if (!down_read_trylock(&shrinker_rwsem))
> 

