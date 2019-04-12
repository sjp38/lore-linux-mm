Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C3C8C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:31:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C5D2084D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 11:31:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C5D2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 646F96B000C; Fri, 12 Apr 2019 07:31:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A53D6B0010; Fri, 12 Apr 2019 07:31:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4710A6B026B; Fri, 12 Apr 2019 07:31:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA5856B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:31:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g9so786310edr.0
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 04:31:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3OcSXVtN9FiWlg0V2OxNwDAYZ1By1NVkqwaMI3I28bA=;
        b=mZg98iGdS3cnkWaHcQ/SYMYqHlbqy5dyq5qboQ1A8l4dC78mQg5IgPD/x+alRKWTsT
         QDiOIKQZHmVY98QZROYeyiIS1dqjvZqJi5mConnG37wTWLM0rBxEEHrK4xay8e65IN6S
         8wvM4JCcu2MuMXWDIzDJtE/zRl4UM7t1ptr6Cypo+WcOJ5ooK5OptNAXqSh94UddNY/x
         azrztbqusHdZsIPJi4BSUq3eisT1xxMW9eyLKb0cL0+Zd4ouJwoezALderb8WeClUq07
         i4SCJi5q4kPL/3SQnoozlZ6G7sV5nMPcavyBQkxJ5eGR8hNdiv/xNjVLbuBZZp7MbR+z
         mOhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWYEtHmAAExTvTbQNpjo6bGrzdr2INqQWOHbwL/P9brGUOQtCaf
	un1htqn9iun1oo/wmKlWJLxG57vrxowPFl7/1yaIfeigcBV9DJKR8e+NVa7tngqZxE1NUgDtFu+
	LKyQPBcL0ehAJBPfNqJTMtWWHCVpyHR7VlzUE8MQKbvSy9rE/Xe0zgXskvCwwHMHrig==
X-Received: by 2002:a17:906:6d16:: with SMTP id m22mr8264718ejr.8.1555068694497;
        Fri, 12 Apr 2019 04:31:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8JzLHV0tvB9+qk2A+KrPR+/P/JC+5JfQB5Uh7kCwZU0IXeFqdTW6M5cjB5yTncJkOK/r6
X-Received: by 2002:a17:906:6d16:: with SMTP id m22mr8264669ejr.8.1555068693566;
        Fri, 12 Apr 2019 04:31:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555068693; cv=none;
        d=google.com; s=arc-20160816;
        b=fnqwAqrN5wgVvgmBciIj1WTCx0x4SUpifTaLS8bHSg1ULygxtfiykVlaaOZmV5Yx+h
         qzVcs9GtuDuSqmk2Y9QrpfJp9/T12htdYVQbQS2Na+xVLVz3nTVSfdEyrv6p4GUGV5Jq
         tpoyxW+8xPK+vRLVL6kZ1didpp068u0dXZkGX9815gKdnlRdzCTfFiW5PadF4jyvGAOF
         WhAco2Ea1EBljYd9Gk9zVkW+XKO14P1KDPtj9JpxyrVAvAjQkQngMOxPYlLGcWNsFYaC
         pZzxG06TTecZoxj51IY+BGOU0+rUF/CRCNMtIlaCOjxGcD9AxwtAgZJSOHovERxxMn4Y
         +n3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3OcSXVtN9FiWlg0V2OxNwDAYZ1By1NVkqwaMI3I28bA=;
        b=q01xI9Onuur8NI+jsrX9X9dPiug7aYBiAPqxukifIIVkNsmG1pYmBGtw9W8/5Rokbm
         q8aAUMIts86pWKFHW0ny2p3eSwPIg9nL/pd1klcY/fy9r4NdANn59bj/pbJ/hYsSJvTy
         VvZQJtX7VgUcl8q9wGqNjiSR/p/P/oOV5DlmbagpNcDfMVEO33uQ0OAHhamTEe6JRIvc
         zNiZS84xHpTDJa2otyzjcZC4A4sPFtYro16Y4/U3+ObAJEag6nfiowGwpQvAstJLrd75
         xiIc6ShR7O+PVomB/BHpwTQJDLxo5eg054qPAhTA/ju1plImnyEAyJKsWUH69fwVei54
         hfcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4si549334edr.182.2019.04.12.04.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 04:31:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE9B6AB76;
	Fri, 12 Apr 2019 11:31:32 +0000 (UTC)
Date: Fri, 12 Apr 2019 13:31:31 +0200
From: Michal Hocko <mhocko@suse.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Baoquan He <bhe@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>,
	akpm@linux-foundation.org, hannes@cmpxchg.org, dave@stgolabs.net,
	linux-mm@kvack.org
Subject: Re: [PATCH v2] mm: Simplify shrink_inactive_list()
Message-ID: <20190412113131.GB5223@dhcp22.suse.cz>
References: <155490878845.17489.11907324308110282086.stgit@localhost.localdomain>
 <20190411221310.sz5jtsb563wlaj3v@ca-dmjordan1.us.oracle.com>
 <20190412000547.GB3856@localhost.localdomain>
 <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26e570cd-dbee-575c-3a23-ff8798de77dc@virtuozzo.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 12-04-19 13:55:59, Kirill Tkhai wrote:
> This merges together duplicating patterns of code.

OK, this looks better than the previous version

> Also, replace count_memcg_events() with its
> irq-careless namesake.

Why?

> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> v2: Introduce local variable.
> ---
>  mm/vmscan.c |   31 +++++++++----------------------
>  1 file changed, 9 insertions(+), 22 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 836b28913bd7..d96efff59a11 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1907,6 +1907,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_taken;
>  	struct reclaim_stat stat;
>  	int file = is_file_lru(lru);
> +	enum vm_event_item item;
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	bool stalled = false;
> @@ -1934,17 +1935,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
> -	if (current_is_kswapd()) {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_KSWAPD,
> -				   nr_scanned);
> -	} else {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSCAN_DIRECT, nr_scanned);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSCAN_DIRECT,
> -				   nr_scanned);
> -	}
> +	item = current_is_kswapd() ? PGSCAN_KSWAPD : PGSCAN_DIRECT;
> +	if (global_reclaim(sc))
> +		__count_vm_events(item, nr_scanned);
> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_scanned);
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
>  	if (nr_taken == 0)
> @@ -1955,17 +1949,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	spin_lock_irq(&pgdat->lru_lock);
>  
> -	if (current_is_kswapd()) {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSTEAL_KSWAPD, nr_reclaimed);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_KSWAPD,
> -				   nr_reclaimed);
> -	} else {
> -		if (global_reclaim(sc))
> -			__count_vm_events(PGSTEAL_DIRECT, nr_reclaimed);
> -		count_memcg_events(lruvec_memcg(lruvec), PGSTEAL_DIRECT,
> -				   nr_reclaimed);
> -	}
> +	item = current_is_kswapd() ? PGSTEAL_KSWAPD : PGSTEAL_DIRECT;
> +	if (global_reclaim(sc))
> +		__count_vm_events(item, nr_reclaimed);
> +	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
>  	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
>  	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
>  

-- 
Michal Hocko
SUSE Labs

