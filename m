Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80374C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:36:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5233C2084D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:36:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5233C2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3E888E0002; Tue, 18 Jun 2019 08:36:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC7438E0001; Tue, 18 Jun 2019 08:36:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDDD28E0002; Tue, 18 Jun 2019 08:36:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 861CD8E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:36:42 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so21118259eda.3
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:36:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=W6N5Bxp5jwkmii8RbEXEIF52QI8WowiUcz2r8rYw+6I=;
        b=DpmWwLEqc9d4Sw+lFKIwz5BIvhjFxj5XxCPHJJrUOiKS5H/LCjIuyw15iz9CSgcki8
         VQIhp86l82GpLP+fI22oe3nyboPSEw76pLc0yD7TIkiAs2rtL12YLg76FeEe5M5jbs8e
         zLefBvDpJFKEhjuEkPGmBbbwvnoS/3yNmKp98u+JXm70DTy3eedhv5bN0cCxilxmGOUq
         /BIq6LkcENuAkZID3Z5lL1lXHKQWDszmgpazoVM/b6DzRbrZJZzIVCGwpnGBax7YySQE
         KyZOvHYUyUzqfgZ1yMBw+BmIcLCy/17Fr/tN9js/HDC4LhbDvr2JcSqSh32KjzShRxk4
         rC5Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUDgaPfGe/te0bGnafRyJBqsH4mdngKllcDNLNifJHrkjfw00+r
	9YkzBcG8KaT1oOn9w10mG281bHGzY+qPcDBj24DPCRXe6xxU+ZFYQRXxOnzqcEfKXtz2k/a/D4C
	qYu6TO3ppt1MVAs3YJxGVgKNCw5PAU1iVz1DskfD4uHjScPXOhfg8kImypcoGRcc=
X-Received: by 2002:a50:97ac:: with SMTP id e41mr68370506edb.27.1560861402106;
        Tue, 18 Jun 2019 05:36:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC5A5zBIFvu402Y2RJAy7q0zuscD2w16kJrXzOJ6k+NDjgzEVFqeTQPIl/lmZCHKdi2Cgg
X-Received: by 2002:a50:97ac:: with SMTP id e41mr68370446edb.27.1560861401425;
        Tue, 18 Jun 2019 05:36:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560861401; cv=none;
        d=google.com; s=arc-20160816;
        b=PaEWWSNwSb5GhZH9oMNdkvWhx8fQTBktOTXz8myzdx2DgOGap0YLDwvLzd8oCfcKt1
         2Fnb4AlXKmhkqnMAgXmsiKcLLZIZzaffw7jqAVgL3j7Y4YpwSRzefaMgvB5+XJJHrchv
         kB+aACXCXvO0imwa8F05BnlCAUNB6DO+lu65CQu8JqKy5FN/uZgcjkgH2v+c35xzajRt
         hr9zt1Rk/OuAtyZBYPnKUUxu46DE/AhnkICb8OVe0dlwlOQ6L7uAoCsV3Rd07Toh0gS1
         QtRW6ZZFE1JK22i5FhzR1ikcnlDr8f2z3Wl2ylkazRsT5THq/v9UiicqBBR/0pP8wAfc
         45cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=W6N5Bxp5jwkmii8RbEXEIF52QI8WowiUcz2r8rYw+6I=;
        b=aMsjOTO9eZfTLexyucF5a3dB+cLlMZtufPLEQiFDtC/Cii+Wm8fdGRdtCTisw7ANee
         70rc1FzrvFMsVgqcA3QL9fuMu+t7SE/aLZi3oLU6VHvJueFGry8SdRI9FAp0eX+cgRVj
         /pGnjiI5T+DFp4zb4jV785w4OmetSkufWRuMeefEZSFTGBnadpQRlslQwDykCbbuK2Y0
         PseO2NuukMLzFGtEyTdLNVf1dfoWZ2orwiE90BkwsnaR7iEHLb3jzUiE4kKf1NolD6Kh
         ovtS4Y2iqwAZ2ArvkVooHxOCjQk736s9PrFxmKIXBJFIsPYWadfOyrPSxr5t6WAMPjoA
         mc5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x17si8158837ejf.274.2019.06.18.05.36.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 05:36:41 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 10907AD0B;
	Tue, 18 Jun 2019 12:36:41 +0000 (UTC)
Date: Tue, 18 Jun 2019 14:36:39 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] mm: memcontrol: Remove task_in_mem_cgroup().
Message-ID: <20190618123639.GF3318@dhcp22.suse.cz>
References: <1560852154-14218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560852154-14218-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 18-06-19 19:02:34, Tetsuo Handa wrote:
> oom_unkillable_task() no longer calls task_in_mem_cgroup().

This was indeed the last caller of this function which got me surprised.
Let's fold this into the refactoring patch.

Thanks!

> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: David Rientjes <rientjes@google.com>
> ---
>  include/linux/memcontrol.h |  7 -------
>  mm/memcontrol.c            | 26 --------------------------
>  2 files changed, 33 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1dcb763..dcc5785 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -392,7 +392,6 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
>  
>  struct lruvec *mem_cgroup_page_lruvec(struct page *, struct pglist_data *);
>  
> -bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
>  struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  
>  struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm);
> @@ -870,12 +869,6 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
>  	return true;
>  }
>  
> -static inline bool task_in_mem_cgroup(struct task_struct *task,
> -				      const struct mem_cgroup *memcg)
> -{
> -	return true;
> -}
> -
>  static inline struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
>  {
>  	return NULL;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b09ff45..0b17c77 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1255,32 +1255,6 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
>  		*lru_size += nr_pages;
>  }
>  
> -bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
> -{
> -	struct mem_cgroup *task_memcg;
> -	struct task_struct *p;
> -	bool ret;
> -
> -	p = find_lock_task_mm(task);
> -	if (p) {
> -		task_memcg = get_mem_cgroup_from_mm(p->mm);
> -		task_unlock(p);
> -	} else {
> -		/*
> -		 * All threads may have already detached their mm's, but the oom
> -		 * killer still needs to detect if they have already been oom
> -		 * killed to prevent needlessly killing additional tasks.
> -		 */
> -		rcu_read_lock();
> -		task_memcg = mem_cgroup_from_task(task);
> -		css_get(&task_memcg->css);
> -		rcu_read_unlock();
> -	}
> -	ret = mem_cgroup_is_descendant(task_memcg, memcg);
> -	css_put(&task_memcg->css);
> -	return ret;
> -}
> -
>  /**
>   * mem_cgroup_margin - calculate chargeable space of a memory cgroup
>   * @memcg: the memory cgroup
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

