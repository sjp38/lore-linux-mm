Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46A49C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 11:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0189E21908
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 11:26:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0189E21908
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8086C8E0002; Fri,  1 Feb 2019 06:26:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790668E0001; Fri,  1 Feb 2019 06:26:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CF5E8E0002; Fri,  1 Feb 2019 06:26:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8EA8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 06:26:48 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so2676452edr.7
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 03:26:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vOPeSVKYZjPEfWn1mRDOug45s6vioBWQMcMg8bsghSo=;
        b=BjTNpTu8ZNm/X6c0BIU6KQ+CFwhfI0zHYijeDJsftcgWYuUuJAi1M0V6PhRekICZQ/
         NeKzF9AS7O9J07XlLIgmCZ2lMkv5PGRUaCb6+vqXvJw2mCX1a30X0GzyRx6yQo2DefbC
         iuhgHgpjCG+KAMhBx7DHc+MSowdj6W0WoHn1AbAakY7/ijEQQCsV0uh2PF5lf8Iodehh
         0Vk0lPSoxE7q650is09CAtWNZ8seHQbCZ//BvN9kxB3LRYOpZQovLImMLz85jJcAdnbn
         7z7Eq6jzzDSTMHgJmXShbB+FYh3NNcZatBTRJLokC7aQioKkVRwjuD76eS2LpVabM3sv
         xatA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukd077kJH3DQ05/tHUsdWIhyYmUd+HtLTMxjzqh3QxXdYJKOfnd0
	ECMYNRU85xzGNz/yJzsugPi4pk/CFTV67gZsxJRKuUSPNfYIqy7XYsI6fHPfYeXqlPncJnuJO+K
	8WqO42jqUfLsgBmmqKWKxJw+txbiSdf8xhjxas67lGGSuMIgenFKlDVJjXN/GZ6c=
X-Received: by 2002:a17:906:23f1:: with SMTP id j17mr21775599ejg.188.1549020407404;
        Fri, 01 Feb 2019 03:26:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6fkenI3XOoeIjLbSGgZtIxgljLrI8VnIZMj5zb2ErMlzbygniqHRsDGV1i4asjG5hdzqaZ
X-Received: by 2002:a17:906:23f1:: with SMTP id j17mr21775542ejg.188.1549020406243;
        Fri, 01 Feb 2019 03:26:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549020406; cv=none;
        d=google.com; s=arc-20160816;
        b=Rc80lFC//CrVUdN48e3OCwdWxGhRirl8DDd8sJwXwXUpfsYqVvFBBqpDT7n/uGniVD
         Chk0IsxQ/l3d8mQNRka35aN9s6gZZ3kaWHSzzLWuz1ES/ERCkbE88xvL3w7g2Ko009y7
         Q5MoiIQBQnXhUwMIzZAUdl3mh0/DfJKdDwWKGBDQJ3nJcIWeuxDQWh8Ntu/snFBkiODJ
         E6RG7PrK9RKquJ42ymE1P/qHw/VrTE5TErb7ajHuXOviPQcLScycMwGZVVzKiQLlHyR6
         s7cgbXQ+Y9Hc2xWfzhYBzEIeLr63WyimFzwD6UeJpDVeCVxIlI5TrgeyLRemMB2NzjZR
         Djtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vOPeSVKYZjPEfWn1mRDOug45s6vioBWQMcMg8bsghSo=;
        b=p2tYKriLen9jQ99GcIMBIyjsjuTiLqvKTHJMCxS8pcNJMJCUNj3IMF6NoNtRHA5Svw
         7m0V3qI/MxSCRRpVvMSb72hdr1NL2s1l/rOUbxVkoHXGpfyr8OoFNAAlFoFFDiaYxzYN
         RxQlLxiitKq9XfrIObF9wlZEDpxk6pRk0XMJ9arFEppljMyo9dzzWcHft3xqIOx1qXxi
         uWva4ulCnixJama/nR389Pgl8lH4EktEvXlAsJlAPo5jA4CDkLk3qll+t7XrYVuOIiLr
         /t4MWgbm2wIF8UKjU+fN8/A/S5DTms8iIQHMoXE6JulzWvjeS85P7+mLwlteWlc8a2OU
         Tfbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z49si278282edz.233.2019.02.01.03.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 03:26:46 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C361DAEEA;
	Fri,  1 Feb 2019 11:26:45 +0000 (UTC)
Date: Fri, 1 Feb 2019 12:26:44 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Do not allocate duplicate stack variables in
 shrink_page_list()
Message-ID: <20190201112644.GM11599@dhcp22.suse.cz>
References: <154894900030.5211.12104993874109647641.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154894900030.5211.12104993874109647641.stgit@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 18:37:02, Kirill Tkhai wrote:
> On path shrink_inactive_list() ---> shrink_page_list()
> we allocate stack variables for the statistics twice.
> This is completely useless, and this just consumes stack
> much more, then we really need.
> 
> The patch kills duplicate stack variables from shrink_page_list(),
> and this reduce stack usage and object file size significantly:

significantly is a bit of an overstatement for 32B saved...

> Stack usage:
> Before: vmscan.c:1122:22:shrink_page_list	648	static
> After:  vmscan.c:1122:22:shrink_page_list	616	static
> 
> Size of vmscan.o:
>          text	   data	    bss	    dec	    hex	filename
> Before: 56866	   4720	    128	  61714	   f112	mm/vmscan.o
> After:  56770	   4720	    128	  61618	   f0b2	mm/vmscan.o
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c |   44 ++++++++++++++------------------------------
>  1 file changed, 14 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index dd9554f5d788..54a389fd91e2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1128,16 +1128,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> -	int pgactivate = 0;
> -	unsigned nr_unqueued_dirty = 0;
> -	unsigned nr_dirty = 0;
> -	unsigned nr_congested = 0;
>  	unsigned nr_reclaimed = 0;
> -	unsigned nr_writeback = 0;
> -	unsigned nr_immediate = 0;
> -	unsigned nr_ref_keep = 0;
> -	unsigned nr_unmap_fail = 0;
>  
> +	memset(stat, 0, sizeof(*stat));
>  	cond_resched();
>  
>  	while (!list_empty(page_list)) {
> @@ -1181,10 +1174,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 */
>  		page_check_dirty_writeback(page, &dirty, &writeback);
>  		if (dirty || writeback)
> -			nr_dirty++;
> +			stat->nr_dirty++;
>  
>  		if (dirty && !writeback)
> -			nr_unqueued_dirty++;
> +			stat->nr_unqueued_dirty++;
>  
>  		/*
>  		 * Treat this page as congested if the underlying BDI is or if
> @@ -1196,7 +1189,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		if (((dirty || writeback) && mapping &&
>  		     inode_write_congested(mapping->host)) ||
>  		    (writeback && PageReclaim(page)))
> -			nr_congested++;
> +			stat->nr_congested++;
>  
>  		/*
>  		 * If a page at the tail of the LRU is under writeback, there
> @@ -1245,7 +1238,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			if (current_is_kswapd() &&
>  			    PageReclaim(page) &&
>  			    test_bit(PGDAT_WRITEBACK, &pgdat->flags)) {
> -				nr_immediate++;
> +				stat->nr_immediate++;
>  				goto activate_locked;
>  
>  			/* Case 2 above */
> @@ -1263,7 +1256,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				 * and it's also appropriate in global reclaim.
>  				 */
>  				SetPageReclaim(page);
> -				nr_writeback++;
> +				stat->nr_writeback++;
>  				goto activate_locked;
>  
>  			/* Case 3 above */
> @@ -1283,7 +1276,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;
>  		case PAGEREF_KEEP:
> -			nr_ref_keep++;
> +			stat->nr_ref_keep++;
>  			goto keep_locked;
>  		case PAGEREF_RECLAIM:
>  		case PAGEREF_RECLAIM_CLEAN:
> @@ -1348,7 +1341,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			if (unlikely(PageTransHuge(page)))
>  				flags |= TTU_SPLIT_HUGE_PMD;
>  			if (!try_to_unmap(page, flags)) {
> -				nr_unmap_fail++;
> +				stat->nr_unmap_fail++;
>  				goto activate_locked;
>  			}
>  		}
> @@ -1496,7 +1489,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		VM_BUG_ON_PAGE(PageActive(page), page);
>  		if (!PageMlocked(page)) {
>  			SetPageActive(page);
> -			pgactivate++;
> +			stat->nr_activate++;
>  			count_memcg_page_event(page, PGACTIVATE);
>  		}
>  keep_locked:
> @@ -1511,18 +1504,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  	free_unref_page_list(&free_pages);
>  
>  	list_splice(&ret_pages, page_list);
> -	count_vm_events(PGACTIVATE, pgactivate);
> -
> -	if (stat) {
> -		stat->nr_dirty = nr_dirty;
> -		stat->nr_congested = nr_congested;
> -		stat->nr_unqueued_dirty = nr_unqueued_dirty;
> -		stat->nr_writeback = nr_writeback;
> -		stat->nr_immediate = nr_immediate;
> -		stat->nr_activate = pgactivate;
> -		stat->nr_ref_keep = nr_ref_keep;
> -		stat->nr_unmap_fail = nr_unmap_fail;
> -	}
> +	count_vm_events(PGACTIVATE, stat->nr_activate);
> +
>  	return nr_reclaimed;
>  }
>  
> @@ -1534,6 +1517,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  		.priority = DEF_PRIORITY,
>  		.may_unmap = 1,
>  	};
> +	struct reclaim_stat dummy_stat;
>  	unsigned long ret;
>  	struct page *page, *next;
>  	LIST_HEAD(clean_pages);
> @@ -1547,7 +1531,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
>  	}
>  
>  	ret = shrink_page_list(&clean_pages, zone->zone_pgdat, &sc,
> -			TTU_IGNORE_ACCESS, NULL, true);
> +			TTU_IGNORE_ACCESS, &dummy_stat, true);
>  	list_splice(&clean_pages, page_list);
>  	mod_node_page_state(zone->zone_pgdat, NR_ISOLATED_FILE, -ret);
>  	return ret;
> @@ -1922,7 +1906,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_scanned;
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_taken;
> -	struct reclaim_stat stat = {};
> +	struct reclaim_stat stat;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> 

-- 
Michal Hocko
SUSE Labs

