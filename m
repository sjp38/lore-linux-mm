Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7D55C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909472084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 10:30:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909472084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D2DA8E0015; Mon, 11 Mar 2019 06:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380858E0002; Mon, 11 Mar 2019 06:30:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2493C8E0015; Mon, 11 Mar 2019 06:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDA4B8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:30:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h37so1837574eda.7
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 03:30:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HCWgcVwK0ph7rBd+1gFZ/Mz/wTEqZ9ocDtrsL7fpFf8=;
        b=tuTO0o/xupGg/xG6RTMSzQVyajw/vKm6IXzif12XKo34fzaJYLcKjwLkHlZwrKI//w
         MjGc58hoZZszBklZl6jPpfnI/LKki28aIZx7YU7f8ZqZuobldGDglRaP2CaPjyLTVHWf
         FKO8Xjts4QwsMC9ORh/26u3b9RbyOkRvWvfCU6WC3rwECFjsxNIAN2inkg7X75L20PCb
         2wpSOL9Jh3Vd6Cm0BK2ZVKR3IzTXyR5gsoDzRPvHmdyeC1jhM0rJMDo5Xn39T9wCcoQ2
         Fmbc1nT1znNxiMknT67cs/ysoPVYJih0P3iaPxs7k3rKdp6wh6gerzqSnxbvbKCpCmVx
         x2NA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW0W8123SjM/gq0oxSN73a2tEVPMl8n/dfIlpCrA1z6gehunq2D
	/D424mnCBacFKIKRWNJJjTzFeYwgV7reJA/UMyH3YDSBapHr+tz7NacQXNnBTtvEUMBUMPkid0W
	3E46vIHcJEaaWjWGhrnRsc82yNlVuVJLjG0T/0dxzrR9jynAWkkek/tKc7djHylI=
X-Received: by 2002:aa7:d752:: with SMTP id a18mr45023807eds.15.1552300215358;
        Mon, 11 Mar 2019 03:30:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcQpLFdEpZdqLcp6fXobnHgq8qPW78J9qo+CiNqijaH+IK0PlmoM3F5glibihLBWK114tH
X-Received: by 2002:aa7:d752:: with SMTP id a18mr45023733eds.15.1552300214242;
        Mon, 11 Mar 2019 03:30:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552300214; cv=none;
        d=google.com; s=arc-20160816;
        b=ofpBbIvJmm4RZUXoEPXzI3ES4kw/ca21epDo3J4wkkNLbiP54D4QzOXnnHnyP8H7ax
         pvJgwuUHD8opgQD+xnSSvavXR41xmK2slm4oac4xODqbxSvQHm83u8b9gZHwchwnCiqc
         y2KGz6mrgNQHMQ2x/d/q6hRzrC0ojnpB8AS7jqet+sTRcobLgtq0yfUWqa/A/nEkNBY5
         Qm/ZByGlexySW/uquIEjgKXKI6UsRrHKTx0bfbbr+S3UN2vhTEDa+GVvDobYXlUa314H
         zR/EXxkQRPYfd3vIPueug9GQsEmAZtD2CgOofdpMRILQT75/Va7ikZKueE+ch8rDf9Sw
         fguQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HCWgcVwK0ph7rBd+1gFZ/Mz/wTEqZ9ocDtrsL7fpFf8=;
        b=yhO3gi1orcRrVXSy2QsyF37l1oUc7cdIJbPVJK9pxmfJ4GUCllSbYf0R106LZqjI/Y
         hhBfvEve/mJAfyszWPryy4QG2PKmPQznmQY4Xu6+H7q+0pqnxT59ltx9HPiGUhUGAaZZ
         DJNPzW/Av9fGZVD226vla8kaW8Ucv3WyP5a63rERlfY7M8T2X+TjPEWfkWUBiuDTHOMh
         dcmyCkyMLlmHZVm9H14YkA+ouz+dHM3WcN5FrqOW/tPHtYvA/9wdsBEL9klzWoXCwaNJ
         zcfDwwRl5aZV3wzg1b3zQeNpng2/uM9S85HZ4mg3qUQEHzgz/mYtcGrcK81cX8JhQ09u
         hdzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si6645090edd.30.2019.03.11.03.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 03:30:14 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BA185AD4C;
	Mon, 11 Mar 2019 10:30:13 +0000 (UTC)
Date: Mon, 11 Mar 2019 11:30:12 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190311103012.GB5232@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
 <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
 <20190308151327.GU5232@dhcp22.suse.cz>
 <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 09-03-19 15:02:22, Tetsuo Handa wrote:
> On 2019/03/08 20:58, Michal Hocko wrote:
> > OK, that makes sense to me. I cannot judge the implementation because I
> > am not really familiar with lockdep machinery. Could you explain how it
> > doesn't trigger for all other allocations?
> 
> This is same with why fs_reclaim_acquire()/fs_reclaim_release() doesn't trigger
> for all other allocations. Any allocation request which might involve __GFP_FS
> reclaim passes "struct lockdep_map __fs_reclaim_map", and lockdep records it.

Yes, exactly. NOFS handling made me go and ask. It uses some nasty hacks
on a dedicated lockdep_map and it was not really clear to me whether
reusing oom_lock's one is always safe.

> > Also why it is not sufficient to add the lockdep annotation prior to the
> > trylock in __alloc_pages_may_oom?
> 
> This is same with why fs_reclaim_acquire()/fs_reclaim_release() is called from
> prepare_alloc_pages(). If an allocation request which might involve __GFP_FS
> __perform_reclaim() succeeded before actually calling __perform_reclaim(), we
> fail to pass "struct lockdep_map __fs_reclaim_map" (which makes it difficult to
> check whether there is possibility of deadlock). Likewise, if an allocation
> request which might call __alloc_pages_may_oom() succeeded before actually
> calling __alloc_pages_may_oom(), we fail to pass oom_lock.lockdep_map (which
> makes it difficult to check whether there is possibility of deadlock).

OK, makes sense to me.

> Strictly speaking, there is
> 
> 	if (tsk_is_oom_victim(current) &&
> 	    (alloc_flags == ALLOC_OOM ||
> 	     (gfp_mask & __GFP_NOMEMALLOC)))
> 		goto nopage;
> 
> case where failing to hold oom_lock at __alloc_pages_may_oom() does not
> cause a problem. But I think that we should not check tsk_is_oom_victim()
> at prepare_alloc_pages().

Yes, I would just preffer the check to be as simple as possible. There
shouldn't be any real reason to put all those conditions in and it would
increase the maintenance burden because anytime we reconsider those oom
rules this would have to be in sync. If the allocation is sleepable then
we should warn because such an allocation is dubious at best.

> > It would be also great to pull it out of the code flow and hide it
> > behind a helper static inline. Something like
> > lockdep_track_oom_alloc_reentrant or a like.
> 
> OK. Here is v2 patch.
> 
> >From ec8d0accf15b4566c065ca8c63a4e1185f0a0c78 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 9 Mar 2019 09:55:08 +0900
> Subject: [PATCH v2] mm,oom: Teach lockdep about oom_lock.
> 
> Since a thread which succeeded to hold oom_lock must not involve blocking
> memory allocations, teach lockdep to consider that blocking memory
> allocations might wait for oom_lock at as early location as possible, and
> teach lockdep to consider that oom_lock is held by mutex_lock() than by
> mutex_trylock().

This is still really hard to understand. Especially the last part of the
sentence. The lockdep will know that the lock is held even when going
via trylock. I guess you meant to say that
	mutex_lock(oom_lock)
	  allocation
	    mutex_trylock(oom_lock)
is not caught by the lockdep, right?

> Also, since the OOM killer is disabled until the OOM reaper or exit_mmap()
> sets MMF_OOM_SKIP, teach lockdep to consider that oom_lock is held when
> __oom_reap_task_mm() is called.

It would be good to mention that the oom reaper acts as a guarantee of a
forward progress and as such it cannot depend on any memory allocation
and that is why this context is marked. This would be easier to
understand IMHO.

> This patch should not cause lockdep splats unless there is somebody doing
> dangerous things (e.g. from OOM notifiers, from the OOM reaper).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h | 16 ++++++++++++++++
>  mm/oom_kill.c       |  9 ++++++++-
>  mm/page_alloc.c     |  5 +++++
>  3 files changed, 29 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index d079920..8544c23 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -56,6 +56,22 @@ struct oom_control {
>  
>  extern struct mutex oom_lock;
>  
> +static inline void oom_reclaim_acquire(gfp_t gfp_mask, unsigned int order)
> +{
> +	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !(gfp_mask & __GFP_NORETRY) &&
> +	    (!(gfp_mask & __GFP_RETRY_MAYFAIL) ||
> +	     order <= PAGE_ALLOC_COSTLY_ORDER))
> +		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
> +}

that being said why not only make this

	if (gfp_mask & __GFP_DIRECT_RECLAIM)
		mutex_acquire(....)
-- 
Michal Hocko
SUSE Labs

