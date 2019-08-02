Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84505C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 535B3204EC
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:04:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 535B3204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBE976B0003; Fri,  2 Aug 2019 04:04:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6F256B0005; Fri,  2 Aug 2019 04:04:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B37516B0006; Fri,  2 Aug 2019 04:04:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67D7A6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:04:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e9so35324436edv.18
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:04:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GzgavPDmr1YH+SAbYAJisL8XwF8kA2z+zzKaQtF2nFQ=;
        b=IdD7xrBktKMX32MBBqxrZnFFHWnXRuPRO91q6PZq77t8h5Bc6yLHfKhzZThCCwHerm
         SOKX/5mRN7tQBh1KY7/wHrKdF9gXWHUNABNWGCJqGjwqfyUfGTBWMEzOsVlaFk71r8mb
         0o/ycO/NxMxBdF4rmyrrjr5JLjZXcGsa7JcatzDF1IUXWgmgmFhrEzk21p+0ctnpMYKE
         y9QJzelofR6Wug8qO5TP3nmC/uLG2hELnygOxL7zMAmZpiItIJFuVqhHROOzu/+2vvO5
         VxBtFSCTUvm+A3zJfy2R4cqKdVehmlI8JhxfN4xA213+KHuQ3zJcB4TYo79iq4crHyUh
         bX2g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVlL+vaVuvFP7oEVsOgN2dQot9O9moWMQ9kogTr2zVMRrAUeTNk
	GnjoyrEtNtrnSB6B6I6/tJneQ9uxQpbo2q4uskaFXotOZZw7cqmoLPHTY8VE9VscseGgGWH8MZC
	A+8XkoSCY1b6ap4WaY/6eWHIZcCNjdUYbKWXCCuYtzNDLbnp7m+QJ3tvnBIxlA0g=
X-Received: by 2002:a50:b6c7:: with SMTP id f7mr115500395ede.275.1564733065996;
        Fri, 02 Aug 2019 01:04:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM2QGZzTi1Mz9/toYKKSfuFIw0ai3H3sr2tZazHODvKUVZl9wLoZmnrThS4irspcpReaSg
X-Received: by 2002:a50:b6c7:: with SMTP id f7mr115500345ede.275.1564733065331;
        Fri, 02 Aug 2019 01:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564733065; cv=none;
        d=google.com; s=arc-20160816;
        b=saK2lIdvVo6wHHPYz3nOi0cQKZ4vZjOkzQ7i74i6lFOa+OEpP4jEmbZ5HNy8VDf+/Q
         7NmDaapu6iTezGufo4uAANGLeZ69bOgWJG2oEzyM0D3yVm06PJydHi7dGuTUxLCh1/F6
         WsmJ0df9V3FWfkKMjwK4I86Z70THorSCfVH0vHtCeLeCQKVimLTJPfvR1LX7rmI/04Cn
         habS2zu/v+fr9b6U6lNIpNetCafL44R2bPsV4ECCj8XJogB9cahSNjg3t6//AjYLfXDQ
         PI+CvBgQIDN7zQyfaVOkjEgW0oqLiMhwsoDuu4tRU3TnG5lQq5Qt2U6Ow5DXqWjnSo2X
         cmtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GzgavPDmr1YH+SAbYAJisL8XwF8kA2z+zzKaQtF2nFQ=;
        b=E6+y7+G86EtmFHf7pQDeYqeCkRpkofZmpuQcxSyvP9DZ67LpHvn3a5vtUDyNYhQFQv
         xy6FEvZ3m+eRR+zCZfu5B7I/2Wp8ycUB+nsHEx0WROusbjppfn4AD8VfLKDkTLZj1OTv
         AlSxuWmWkFGxnLHNattrN+1KFW2H7qBtArp7u6kMdXkJlIw7i98u0O33E4+krT4QSw64
         VjA75EF+sp1Q3bxQJhDKbxo5P+B9KKrAlQchXQ6/3B3y+AtCdxY8lL0VQ8xBfOLsEjRx
         vfOtqog1uMVZpB+yzpdvIMbBTbxS3ebde2b8dQ0QEtyhL4rD838w3kWdXHTwemfjc+hX
         staw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q10si22218623ejn.365.2019.08.02.01.04.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 01:04:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C636EAE35;
	Fri,  2 Aug 2019 08:04:24 +0000 (UTC)
Date: Fri, 2 Aug 2019 10:04:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Message-ID: <20190802080422.GA6461@dhcp22.suse.cz>
References: <20190801233513.137917-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190801233513.137917-1-guro@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 01-08-19 16:35:13, Roman Gushchin wrote:
> Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
> introduced css_tryget()/css_put() calls in drain_all_stock(),
> which are supposed to protect the target memory cgroup from being
> released during the mem_cgroup_is_descendant() call.
> 
> However, it's not completely safe. In theory, memcg can go away
> between reading stock->cached pointer and calling css_tryget().

I have to remember how is this whole thing supposed to work, it's been
some time since I've looked into that.

> So, let's read the stock->cached pointer and evaluate the memory
> cgroup inside a rcu read section, and get rid of
> css_tryget()/css_put() calls.

Could you be more specific why does RCU help here?

> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c | 17 +++++++++--------
>  1 file changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5c7b9facb0eb..d856b64426b7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2235,21 +2235,22 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>  		struct mem_cgroup *memcg;
> +		bool flush = false;
>  
> +		rcu_read_lock();
>  		memcg = stock->cached;
> -		if (!memcg || !stock->nr_pages || !css_tryget(&memcg->css))
> -			continue;
> -		if (!mem_cgroup_is_descendant(memcg, root_memcg)) {
> -			css_put(&memcg->css);
> -			continue;
> -		}
> -		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
> +		if (memcg && stock->nr_pages &&
> +		    mem_cgroup_is_descendant(memcg, root_memcg))
> +			flush = true;
> +		rcu_read_unlock();
> +
> +		if (flush &&
> +		    !test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
>  			if (cpu == curcpu)
>  				drain_local_stock(&stock->work);
>  			else
>  				schedule_work_on(cpu, &stock->work);
>  		}
> -		css_put(&memcg->css);
>  	}
>  	put_cpu();
>  	mutex_unlock(&percpu_charge_mutex);
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

