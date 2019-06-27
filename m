Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13833C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:07:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC27720659
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:07:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC27720659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45CD18E0003; Thu, 27 Jun 2019 11:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C5C8E0002; Thu, 27 Jun 2019 11:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D6A68E0003; Thu, 27 Jun 2019 11:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D63038E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:07:50 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so6182077edm.21
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:07:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1oAkjpg9aVJSyJn0Eyp93Kug3VG0Z+z5+QjEpUPJhaM=;
        b=o1htgnmkam+MWBFJCSEd7RcNj3SGiuTgGSuigMxsN8VMIxUkCSayxFC4vdAZ+n33GS
         119wUFS0E6z8sS7mPR0V23iAiSMAx8EZlP4vt5wDh98H0K1NqPBmrQp+ReXkyJNw1uWi
         4C10viZsF5bghd37WXvj+EMjjx7A32CHEntOQUR/nwIwqbvGCUa1OHaWCC9lxH8usFgP
         tsWzEfP+uG6HXbdKRcyJ2pNlgvXnZ+Pxi+ESeDa0GnaybwCWBFYkRuJLaJlSBa7P2gxI
         UZVflmU44GTJC1Dr8RrSLahOcIg9wxAKfrkwepYzKI+oQ4xI5Vf61Khk3CioyTd3iRgP
         CidA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVWH/uTyjpMMqiYAc/1M2J0APY4E8PG5NcFmVzi+n7X99a029x4
	isJPqc0ZQCL3Wyi5xzcfOA00fw2rE3HYb81sahf2DOn9yH4vGqPoesLZxertEGIwKJTJTQo7ms/
	kgGtgnBOmL5j0gtg94au1Mzid3nmq6c9lMPPwsLBj1VepcYP2+D665kWHTEFycVM=
X-Received: by 2002:a50:95b0:: with SMTP id w45mr4987591eda.12.1561648070420;
        Thu, 27 Jun 2019 08:07:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCtHzHIQFBT2TNk44wYK033z36/OvH4G5GzVf7+i4iaJcwDhzFPXeAJKkHWrWUIZzt9ehv
X-Received: by 2002:a50:95b0:: with SMTP id w45mr4987435eda.12.1561648069231;
        Thu, 27 Jun 2019 08:07:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561648069; cv=none;
        d=google.com; s=arc-20160816;
        b=f3vCebquCs8AmlWRAN/qEg/0CmOux9YPWBuh7PZ0t0Lr9wjIgVd0TvbFcf38zgdJal
         hsvXaE3PDcfHQBQsUe9gbmDSEgv93P868nPBPnYDSQNQ0vr9fwqBwUxDAtegGSZCIZ9E
         FGxKf9+4gEJ/Z7pZTSvJkuO47tP0tZBcSIFW329aDPasb6CK6/daKi6XvPkmpkjE8W8e
         r7daBI14kktEcUdS165RPJ+KFQC2ep8+Grb4LpgtGQwr3xwlmLkSwZxp1GXdCLF28RLH
         yR/q/O6XeM9haPViTsdoMKcV/xTfCUuMJtWFmnM5TlXD2CCdI98ZNgtW3JmJwQBpdgtb
         MvCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1oAkjpg9aVJSyJn0Eyp93Kug3VG0Z+z5+QjEpUPJhaM=;
        b=p+UQIzsTCWeC5bLeX9DuYKzqub2v5Uc1QwRSBp3n3P1QqjS4oRy++xRvBF+AD+BXNL
         VtF8B7+H0kECCRz2x2VSxEFX2DUfGN3l2qnI2ejkkGEAP9HW8u5Og/dqNibKpqehGQw7
         10ElyCCOexQ2en7tZevvtHfqu9nykZMf14WgpC7C1HEhDlxvOkWcj+h8SakWwU5g88G0
         rB3poMCfCwHFx78R/LTHhklPvr3/RQhOYzgbTRMQOppmJGiSmzQiWFX/6UZv6XYGiOft
         kAIt3uh3hy5NlxjVN/YwXMSjY60rLcJ0b5dyRJPN3xC9EFgoP15QVn7zTHy/tUR1RfoO
         VzJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si2187081eds.342.2019.06.27.08.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 08:07:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5F70CAC37;
	Thu, 27 Jun 2019 15:07:48 +0000 (UTC)
Date: Thu, 27 Jun 2019 17:07:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/2] mm, memcontrol: Add memcg_iterate_all()
Message-ID: <20190627150746.GD5303@dhcp22.suse.cz>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-2-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624174219.25513-2-longman@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 24-06-19 13:42:18, Waiman Long wrote:
> Add a memcg_iterate_all() function for iterating all the available
> memory cgroups and call the given callback function for each of the
> memory cgruops.

Why is a trivial wrapper any better than open coded usage of the
iterator?

> Signed-off-by: Waiman Long <longman@redhat.com>
> ---
>  include/linux/memcontrol.h |  3 +++
>  mm/memcontrol.c            | 13 +++++++++++++
>  2 files changed, 16 insertions(+)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1dcb763bb610..0e31418e5a47 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -1268,6 +1268,9 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
>  struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
>  void memcg_kmem_put_cache(struct kmem_cache *cachep);
>  
> +extern void memcg_iterate_all(void (*callback)(struct mem_cgroup *memcg,
> +					       void *arg), void *arg);
> +
>  #ifdef CONFIG_MEMCG_KMEM
>  int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
>  void __memcg_kmem_uncharge(struct page *page, int order);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba9138a4a1de..c1c4706f7696 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -443,6 +443,19 @@ static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
>  static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
>  #endif /* CONFIG_MEMCG_KMEM */
>  
> +/*
> + * Iterate all the memory cgroups and call the given callback function
> + * for each of the memory cgroups.
> + */
> +void memcg_iterate_all(void (*callback)(struct mem_cgroup *memcg, void *arg),
> +		       void *arg)
> +{
> +	struct mem_cgroup *memcg;
> +
> +	for_each_mem_cgroup(memcg)
> +		callback(memcg, arg);
> +}
> +
>  /**
>   * mem_cgroup_css_from_page - css of the memcg associated with a page
>   * @page: page of interest
> -- 
> 2.18.1

-- 
Michal Hocko
SUSE Labs

