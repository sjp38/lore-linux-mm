Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FEE1C0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:11:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BABC2075B
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 11:11:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BABC2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B938B6B0006; Mon,  5 Aug 2019 07:11:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46436B0007; Mon,  5 Aug 2019 07:11:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A339E6B0008; Mon,  5 Aug 2019 07:11:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 531B86B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 07:11:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so51239222edr.7
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 04:11:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xakpZ1HzlQz+pzEtboHU6mRqhdcLH8I/5bfZJM7Lcr8=;
        b=S7GPFSYmEihxNvMTvfuZUyIluODile5CjZA5j/TXNzyIANhImRfh159HAQRV2ojvv7
         J8Q5fjHaW6mksDGiq4Ots78YmOW0Y5vtPmOZQQxeUfLgceFPRV0EZ8PESjfYSajqbeKy
         k+5clURzceDLJdVqGGn3OZ8cV0vzMU5oxJRL+TYCgujxnlPlnYml6kZC5VgOcAZf1Th/
         FDtRTDp2BW+L7cjmgbaR+81Ltx593Y28qQ3apQfrfIOY9PHVolZx5LPJ0V1H9nGwiNV1
         z3T+nP6t3xTAHFDB876HytVG+HiGW0Z0Ya8GD6OGDMhPiDdOsX+ISbfErtrKWebHlfmT
         dGaw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVH0Hld2gJTsTqq04/WRipUJETEaxXvjqKZpZBgxE+untPuUZSz
	XAxOMln1dPMEHQ2riTtujONLf3QoLp1bzVv551rI5UgQAt0LbYtQuv72p01qGhZvPwkTCsENhHX
	6/43lkmQXnHCOkb95wyCnv6BTMCIqLFmAK+MMm6i55bbvxay6H5Gwl3WNzQZS3mw=
X-Received: by 2002:aa7:da03:: with SMTP id r3mr132146055eds.130.1565003499869;
        Mon, 05 Aug 2019 04:11:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvLL8kWCFXHgfnadziy4wOYf5JnINuk+VjeKtpIi3HDoDFXGIlkP5/SR1ODZ14kAoTiZIP
X-Received: by 2002:aa7:da03:: with SMTP id r3mr132145982eds.130.1565003499018;
        Mon, 05 Aug 2019 04:11:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565003499; cv=none;
        d=google.com; s=arc-20160816;
        b=zyciEPAbCdRBs/6jzJ0SAdyoV0GfCYQ7VtzycLc+dYV86JFhn3O1ubXH4E58lJRB0a
         4SIGQTVjhYIHjLpXnEkXXWezgogAMKvgd3hI7LBCF9THB7bez+l3vDAStF/W2t+8ChXw
         u94fF7t0+O4vvvAfCnKq84tUDFwIAuOmyz6TrqaepYeTwtZirEpxlJYCQh/4jN/5Zp8X
         0apMTdlfGqgjjAd/cDHCiYTAZkznzVWAwH6e8d/bJVxnvF75dcBLNTpoRCCKlsBFDcYT
         nw/u53TOyC5ttwQM8nWxFS/HUlookuE0igukBVGS6xXgHteTFvkisxQZHocjOA8r19mO
         xWjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xakpZ1HzlQz+pzEtboHU6mRqhdcLH8I/5bfZJM7Lcr8=;
        b=ucW7S9ivbQlCnZg/W/Jej44OeBtVdZ4RYZNzkTf6oEzEVoAjncis0d94g98DZx+1Yh
         CpSlskqHCyD2xl1BLc8xOCiQzBsCoHUACVi5lQKlADgwCwYWyWXhsxJURZ9cBWE6B/84
         5K6NIwpgCgENAFrwQ12hHhsXrZKXY9RLSWZHbBjm5Q2ldzBbgbLOUxYeVilMBVjQwUGf
         C7Zs3OdlIQADEkocJ/vLBZykwpIsIRolgJA3Tf5LW613vDikH3StRWLN0eb9xhQi9ZiO
         SKD4mFQIypivX8tMQ2wMH9+zqSp9VjrHtrvWVPRkvBS2t6fJAs9mtkntDMGTJGm9LZW3
         BPxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n21si25596871eju.16.2019.08.05.04.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 04:11:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 735B0AEF3;
	Mon,  5 Aug 2019 11:11:38 +0000 (UTC)
Date: Mon, 5 Aug 2019 13:11:35 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, Hillf Danton <hdanton@sina.com>
Subject: Re: [PATCH v2] mm: memcontrol: switch to rcu protection in
 drain_all_stock()
Message-ID: <20190805111135.GE7597@dhcp22.suse.cz>
References: <20190802192241.3253165-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802192241.3253165-1-guro@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 12:22:41, Roman Gushchin wrote:
> Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
> introduced css_tryget()/css_put() calls in drain_all_stock(),
> which are supposed to protect the target memory cgroup from being
> released during the mem_cgroup_is_descendant() call.
> 
> However, it's not completely safe. In theory, memcg can go away
> between reading stock->cached pointer and calling css_tryget().
> 
> This can happen if drain_all_stock() races with drain_local_stock()
> performed on the remote cpu as a result of a work, scheduled
> by the previous invocation of drain_all_stock().

Maybe I am still missing something but I do not see how 72f0184c8a00
changed the existing race. get_online_cpus doesn't prevent the same race
right? If this is the case then it would be great to clarify that. I
know that you are mostly after clarifying that css_tryget is
insufficient but the above sounds like 72f0184c8a00 has introduced a
regression.

> The race is a bit theoretical and there are few chances to trigger
> it, but the current code looks a bit confusing, so it makes sense
> to fix it anyway. The code looks like as if css_tryget() and
> css_put() are used to protect stocks drainage. It's not necessary
> because stocked pages are holding references to the cached cgroup.
> And it obviously won't work for works, scheduled on other cpus.
> 
> So, let's read the stock->cached pointer and evaluate the memory
> cgroup inside a rcu read section, and get rid of
> css_tryget()/css_put() calls.
> 
> v2: added some explanations to the commit message, no code changes
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Hillf Danton <hdanton@sina.com>

Other than that.
Acked-by: Michal Hocko <mhocko@suse.com>

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

