Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DCDEC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:05:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBA4120652
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 12:05:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBA4120652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58F466B0010; Fri, 12 Apr 2019 08:05:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53EDD6B026A; Fri, 12 Apr 2019 08:05:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E836B026B; Fri, 12 Apr 2019 08:05:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8B9B6B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:05:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e6so4809438edi.20
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 05:05:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tnlxznqfsNJaL8OX6t6A7tNjfke803rK2SM0fxijTLE=;
        b=a9q2ni+6Fg140gnSwvtw48RbgZnJ2JTEtf/KYdsfGgKOljWju9DtT7jrSm6IpXJI8a
         DNtxhKcXIiYhOa1sLdGGkfHZApIWGXRnsgExKOJ/eseWazA/Um3PUZt5ebM7a7ZF+TTP
         kU1wxweq31Xsi5S1io5aK0A4bJPklYyvPSnA9iP6OhO85CAOAxk+HT3yW/4MYS7W6G8u
         m0T4lACmNzO2kXYYc+BVnA47xdMeVgVhHtleKVL90AlRpzL+j9U+9+mUVgOyY9613+lp
         hx9LmKFSloMafA34ug7nsjvkdmQFaTT0FQugMXFfCN7s2Yq+MwgY7J93mHA0nQnmZYM7
         4L8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAXIZ9SA/rnJlo+UbHENLaR5dasVG1zXn+SYVqdPPHNd93jjKjgO
	FcdnTdtZxv0D76bM4f1s2k0bP4ZXmZhtOWh/v2yy7ZIk7FUw5yU9JDCAd+dla9Vix6sqaalZhmL
	fDafaoYCfW6XWuwlkSkk6+392Hi1W7iHm2hhxJzcJuqDPsP6h+byMcaCmBPr41q89QQ==
X-Received: by 2002:a17:906:828b:: with SMTP id h11mr30265202ejx.1.1555070707485;
        Fri, 12 Apr 2019 05:05:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnxoS61IjhqgVVlVTg08l2rAynytUZh3D1ZKNUWB5q+XsD1yxZFFZb4btvnbL4er/sEs1d
X-Received: by 2002:a17:906:828b:: with SMTP id h11mr30265150ejx.1.1555070706529;
        Fri, 12 Apr 2019 05:05:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555070706; cv=none;
        d=google.com; s=arc-20160816;
        b=LXiuvofg5e7VFN7kjn/yvyRNoVURvu7xrxymG2FzAg7rLs3iY9gzt5D7DlhLravSs/
         v11QmOvvhHG1DEOTQcVzK3ozxuC1xFMRyBuRGNKDQQHow/A0oo1aCk7OFVGiF51WZo/t
         7gcCGn0rbIVNiCouBdjr2A5tie7z+V60bxiClY8sGheidLTVmNG221g9O+vl87UIGFbf
         o2i5myZSx8ox6/Zu/qMi4CUHrtKNe1rhkma4sCZRTyATI+X+xGWcget+4EcITXO+xEEi
         e8yXVHarW5fLUjUtmE72eZlRJNb0K78wcTHQ0b+7WO7T2ULtlQNzUHJX+7i+qMKCBapM
         IR0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tnlxznqfsNJaL8OX6t6A7tNjfke803rK2SM0fxijTLE=;
        b=QJPEzpVjKE0tozlEjs6bYQnWrNUHSOqlEDnIzKaq86pc3qa7NSAWOnk+UBQc/Czh/C
         MvdHP8zcFGNcHbCM5MPeNCtesweVHkw64R+32UFJR3mCs2R+mPyrHhGmQ9yx04WrwS00
         KqIayCUVl93EOGeUrDUJPKiVOngEkHQTJPtbsOv+XcuV71NAAvP1A69lWdQn0ezduxQx
         JRXN9+KfGww1EO70T1ysm4w2ra3nMl0gNK0QhFSKjqaws7/q/pCjLU0gq9QiZd3Yyms5
         CozCxYhLy8i6heBugo2Esc+XR0aFkWP9ilwBKyobyPs5M6FbEeZz5UqXPWhnH7IgxKDA
         5GmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h10si4896997edv.8.2019.04.12.05.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 05:05:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 98CCAAC89;
	Fri, 12 Apr 2019 12:05:05 +0000 (UTC)
Date: Fri, 12 Apr 2019 14:05:04 +0200
From: Michal Hocko <mhocko@suse.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>,
	akpm@linux-foundation.org, hannes@cmpxchg.org, dave@stgolabs.net,
	linux-mm@kvack.org
Subject: Re: [PATCH v2] mm: Simplify shrink_inactive_list()
Message-ID: <20190412120504.GD5223@dhcp22.suse.cz>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
 <20190412113131.GB5223@dhcp22.suse.cz>
 <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ac7242c-54d3-cd44-2cd9-5d5c746e2690@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 14:33:27, Kirill Tkhai wrote:
> On 12.04.2019 14:31, Michal Hocko wrote:
> > On Fri 12-04-19 13:55:59, Kirill Tkhai wrote:
> >> This merges together duplicating patterns of code.
> > 
> > OK, this looks better than the previous version
> > 
> >> Also, replace count_memcg_events() with its
> >> irq-careless namesake.
> > 
> > Why?
> 
> Since interrupts are already disabled, and there is
> no a sense to disable them twice.

right and changelog could have mentioned that...

> >> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Anyway, forgot to add
Acked-by: Michal Hocko <mhocko@suse.com>

> >>
> >> v2: Introduce local variable.
> >> ---
> >>  mm/vmscan.c |   31 +++++++++----------------------
> >>  1 file changed, 9 insertions(+), 22 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 836b28913bd7..d96efff59a11 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >>  	unsigned long nr_taken;
> >>  	struct reclaim_stat stat;
> >>  	int file = is_file_lru(lru);
> >> +	enum vm_event_item item;
> >>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> >>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> >>  	bool stalled = false;
> >> @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
> >>  	reclaim_stat->recent_scanned[file] += nr_taken;
> >>  
> >> -	if (current_is_kswapd()) {
> >> -		if (global_reclaim(sc))
> >> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> >> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
> >> -				   nr_scanned);
> >> -	} else {
> >> -		if (global_reclaim(sc))
> >> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> >> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
> >> -				   nr_scanned);
> >> -	}
> >> +	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
> >> +	if (global_reclaim(sc))
> >> +		__count_vm_events(item, nr_scanned);
> >> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
> >>  	spin_unlock_irq(&pgdat->lru_lock);
> >>  
> >>  	if (nr_taken == 0)
> >> @@ -1955,17 +1949,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >>  
> >>  	spin_lock_irq(&pgdat->lru_lock);
> >>  
> >> -	if (current_is_kswapd()) {
> >> -		if (global_reclaim(sc))
> >> -			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
> >> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
> >> -				   nr_reclaimed);
> >> -	} else {
> >> -		if (global_reclaim(sc))
> >> -			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
> >> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
> >> -				   nr_reclaimed);
> >> -	}
> >> +	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
> >> +	if (global_reclaim(sc))
> >> +		__count_vm_events(item, nr_reclaimed);
> >> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
> >>  	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
> >>  	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
> >>  
> > 
> 

-- 
Michal Hocko
SUSE Labs

