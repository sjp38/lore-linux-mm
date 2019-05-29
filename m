Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18C9EC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:38:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C420623AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:38:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C420623AB3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32C206B000E; Wed, 29 May 2019 11:38:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DC9F6B0010; Wed, 29 May 2019 11:38:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CBAE6B0266; Wed, 29 May 2019 11:38:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0C5A6B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 11:38:40 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so3999348edm.7
        for <linux-mm@kvack.org>; Wed, 29 May 2019 08:38:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4TQBgESvWIyC2qv4jAqQ8/XfYwZ1mN0/SAx+fIQikaw=;
        b=dN0ECoDbLJdVBhYXO9MfhDzQlchoZjGoTY5taYgxuLlnjLu+z8K0BLSASLjZddy9+0
         wJ57uuN/d+kuybqJrzeVBUwi6l8aq2+6m8dt2eIIifo1ec+B2twcSM06cihfzJl9srvs
         s3178Txw+VZtMCFBuPcxxlt16dNba/rVY3bOVA2GPes1zds45aj/2mMU9hkzOUPo+cru
         qTkS2jlFCXD9fFl1/jnbTA34NMleimbEzVGWXbv0BPh8CwY68VO2eV9PX/o4uUIjGV22
         kYP17mkuPrPTGOrf7RqUJH5fET0S4uhThWPHtrVWj4EUpMbO6Y42rw2VaW4SwJCHaqXG
         Vx6w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXinuQcKYTULFUS5uquSS5XcmRoR0RGGoSoHCZfoRKZnAlffLMT
	zcEnKjMXrpnoGoShR13sCZvXiSJg8Pf7yGiN5wzda4osJqEih/poSfNpDNi3NpCxnoPbQqsNinO
	vpYHuWlkrrVIT5XxqGhCuwhhQZr8bIOuFjXa/ZRjNUyb4Dd2F4Wigstug2Stnpdg=
X-Received: by 2002:aa7:d9cb:: with SMTP id v11mr136106474eds.159.1559144320268;
        Wed, 29 May 2019 08:38:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztdhYXuSvDyrsvc+oduzkVdcM7RqKikRqUALYauoFXnzMspNVDwoGhsJpXMIavizMFGLdU
X-Received: by 2002:aa7:d9cb:: with SMTP id v11mr136106372eds.159.1559144319202;
        Wed, 29 May 2019 08:38:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559144319; cv=none;
        d=google.com; s=arc-20160816;
        b=QJptxeUT/yifgnTIMOQADGxYDFT6FsRK3chziwxyZlvYINzrci9umoqSfP0e5LBQjV
         pgL+l3T5OiGfRdnlyrcjIW5S/kOYMfJwOmFeCuit5jpNMvboOAe5+e7gTlnKDNTp3oHs
         O2rIKbLzS871mTOi2H1zu/zGEPIoVupoGlrxqOELUZi5OuCBEfqKjhqoW+WAiupveuKG
         7KCvCCVs2oLes0H7acM1NhgXDVz0c0eC/9cS2gmBl+qgT9ZQ3ciGt8VscOLytLZBX397
         XmzdSqj1KvA5LH2dprQJVcfcC6kMo1eGGJm29gX4JhKmdpGOdBsTJfPO/15OZ8x34ZDX
         xRrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4TQBgESvWIyC2qv4jAqQ8/XfYwZ1mN0/SAx+fIQikaw=;
        b=zKuctRObCUFTkSCJAkEDmh8t8F0R6ZHmFhwZTDDuGx1tDXhc4jOoYmhlIyyc5edljH
         XoqfhKGIme1/BSmfO3OSZRIk5vkqEFcKLx0z1xVN1M90HB+xtN1Lyps8MnLvj3/VWXra
         ZB/5Yx+jFSG2PffiPWC1MJ4f6m7YGLg4onCnxrZyilHD+KdAb8DbEugX931ybhouJld8
         TO4CFLKacsvNXKOHjo4H5tUeP7xG2l8hqQIzbCtgaDoJelt8lJT3ywwScJs8seHF0vMW
         JLYV07ltRL89A+D5H8R1JqVOk6JUJgCu7/WDTZ847hHQ90LRIUWfXgJpjGySOi1o6rKf
         ORXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si3123902ejv.3.2019.05.29.08.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 08:38:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3677AC50;
	Wed, 29 May 2019 15:38:38 +0000 (UTC)
Date: Wed, 29 May 2019 17:38:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix recent_rotated history
Message-ID: <20190529153836.GF18589@dhcp22.suse.cz>
References: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 19:09:02, Kirill Tkhai wrote:
> Johannes pointed that after commit 886cf1901db9
> we lost all zone_reclaim_stat::recent_rotated
> history. This commit fixes that.
> 
> Fixes: 886cf1901db9 "mm: move recent_rotated pages calculation to shrink_inactive_list()"
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

I didn't get to review the original bug series but this one looks
obviously correct.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e873eca6..1d49329a4d7d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1953,8 +1953,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (global_reclaim(sc))
>  		__count_vm_events(item, nr_reclaimed);
>  	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
> -	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
> -	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
> +	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
> +	reclaim_stat->recent_rotated[1] += stat.nr_activate[1];
>  
>  	move_pages_to_lru(lruvec, &page_list);
>  
> 

-- 
Michal Hocko
SUSE Labs

