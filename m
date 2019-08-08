Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57CAFC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18C802187F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 08:18:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18C802187F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9296B0003; Thu,  8 Aug 2019 04:18:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97F2F6B0006; Thu,  8 Aug 2019 04:18:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86DCD6B0007; Thu,  8 Aug 2019 04:18:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 374206B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 04:18:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a15so1082969edv.2
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 01:18:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1/RZFuY4dEutxORgNCTRqqOUgB/zy3HaxiCAb2EJZhQ=;
        b=TmVGBmDhvYgvSxA4nlJKmpK2Tb99VhnHQwO6uooe34Q6rEMfN5i7KKIH1y5lTDXfRR
         eh6L0/aNrBKzZLK/6ogYUSNOP7owEPE5JQpODey78R+SmjSh19v9IqQW+mQYisWYm/ar
         wtfv27cG4M7XNUP+0cTWmvo+ctirHQlipsiK0t/JimbrqSfLdCIApZjiNdfNp+OBAgty
         v+x+ZC4a717KskajzVmRV/d+/mInvBcATmJ9HKCibsNpMOckLmAiOIwyGVnHaLqSbLFc
         y8ydqDobzIUvcLUcP2WZsprXcodJ9pltj2zR/NH11FicE0fxXb47gN54niZXO2LsQE8g
         B+YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAX6ikCfyky8Hb/0L5NXtXfFhZAc61U3DuzwIxmIZQOxhl3anBXi
	Q+6TnifzNvOPS5T1nuvgV4EAXQHzvzd3fCMiih0WD5HAm4o8/TzGflzcLSRx5licu5wJnzRrGyQ
	2aalSjy0eL+Z6yMKPdMhNY7+3iN18x6r9ARINHnbsO1Po5TanOmEV2IdZt96xeIJhlg==
X-Received: by 2002:a17:906:340e:: with SMTP id c14mr12471972ejb.170.1565252309769;
        Thu, 08 Aug 2019 01:18:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUcBR07zH37+I5zlt3hzSn/ZLfM9SisZN2xul8mwTs2FDqEitDWfmBqxHJcEWJPqi+YNJB
X-Received: by 2002:a17:906:340e:: with SMTP id c14mr12471931ejb.170.1565252308967;
        Thu, 08 Aug 2019 01:18:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565252308; cv=none;
        d=google.com; s=arc-20160816;
        b=rvctzX1tbX4K/P0dhYINfkLvdIW9odtLbK+pGt2qrO2Rw1xGkrsnpaypb8/NQ/kX7g
         L4mVecwwFGvaWKOXlX77pgdEWrZKqJMxlik/dbpPMBu3FOGJqQ7kN3BZyjb6Yd/ym3/x
         70U/ioSgagWAavfcFXXDAr11nO5Kc6ie/alGrjAfBqOlgVgVQ5l4n3806nZxgxzcdlbc
         XIy9cJlriUL38yhSdE7+MlXrIHWJMtdqyhn6FsT9C/RBdz0g0JsrXoglwRUxoDF3NZvq
         JsZw9AxuvW2MeSil8GW7wkX5EaD4LPF8CvFfqfHN7edWowpO838i/1BZ4yj40xvaxnt/
         Gf+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1/RZFuY4dEutxORgNCTRqqOUgB/zy3HaxiCAb2EJZhQ=;
        b=BGH7HSBFzYQL7EXkwA+CstHoUe3CRPcF03k+nFBI++BgR+WgiCXAErQPukQ+IBtFhV
         bAujPEvP3p1GRQ+3/c3B/Uidw8JyvrpJFovPQFBXKVITH3aCxTfX882R/lV2UM2pZOML
         iB79V/erHMF2wTPvON7iZTp6k37a2ekjcM9GMiLNPNkf/m/47+iGqXMfoN5q7B01cxF5
         JDkjZUuJdcLwu0XtyEkX4IkbwKNL5BocJPQkKmNjgqtmg08mT0r3KJqMtEoPFSs0Bedd
         B9HxSJiR+uXbM+N/DC4T/ZhcBMns7gJ0Ba3y+9DOukdhnJoaxukx9mFDh4YPsDjHSq6n
         OzIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j24si728812ejx.267.2019.08.08.01.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 01:18:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4FFB3B049;
	Thu,  8 Aug 2019 08:18:28 +0000 (UTC)
Date: Thu, 8 Aug 2019 10:18:27 +0200
From: Michal Hocko <mhocko@suse.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Message-ID: <20190808081827.GB18351@dhcp22.suse.cz>
References: <20190807191627.GA3008@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190807191627.GA3008@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 07-08-19 19:16:32, Jason Gunthorpe wrote:
> Many users of the mmu_notifier invalidate_range callbacks maintain
> locking/counters/etc on a paired basis and have long expected that
> invalidate_range start/end are always paired.
> 
> The recent change to add non-blocking notifiers breaks this assumption
> when multiple notifiers are present in the list as an EAGAIN return from a
> later notifier causes all earlier notifiers to get their
> invalidate_range_end() skipped.
> 
> During the development of non-blocking each user was audited to be sure
> they can skip their invalidate_range_end() if their start returns -EAGAIN,
> so the only place that has a problem is when there are multiple
> subscriptions.
> 
> Due to the RCU locking we can't reliably generate a subset of the linked
> list representing the notifiers already called, and generate an
> invalidate_range_end() pairing.
> 
> Rather than design an elaborate fix, for now, just block non-blocking
> requests early on if there are multiple subscriptions.

Which means that the oom path cannot really release any memory for
ranges covered by these notifiers which is really unfortunate because
that might cover a lot of memory. Especially when the particular range
might not be tracked at all, right?

So I cannot really say I am happy with this much. People will simply
start complaining that the OOM killer has killed more victims because
the first one hasn't really released its memory during the tear down.

If a different fix is indeed too elaborate then make sure to let users
known that there is a restriction in place and dump something useful
into the kernel log.

> Fixes: 93065ac753e4 ("mm, oom: distinguish blockable mode for mmu notifiers")
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  include/linux/mmu_notifier.h |  1 +
>  mm/mmu_notifier.c            | 15 +++++++++++++++
>  2 files changed, 16 insertions(+)
> 
> HCH suggested to make the locking common so we don't need to have an
> invalidate_range_end, but that is a longer journey.
> 
> Here is a simpler stop-gap for this bug. What do you think Michal?
> I don't have a good way to test this flow ..

Testing is quite simple if you have any blocking notifiers at hand.
Simple trigger an OOM condition, mark a process which uses notifier to
be a prime oom candidate by
echo 1000 > /proc/<pid>/oom_score_adj

and see how it behaves.

> This lightly clashes with the other mmu notififer series I just sent,
> so it should go to either -rc or hmm.git
> 
> Thanks,
> Jason
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index b6c004bd9f6ad9..170fa2c65d659c 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -53,6 +53,7 @@ struct mmu_notifier_mm {
>  	struct hlist_head list;
>  	/* to serialize the list modifications and hlist_unhashed */
>  	spinlock_t lock;
> +	bool multiple_subscriptions;
>  };
>  
>  #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index b5670620aea0fc..4e56f75c560242 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -171,6 +171,19 @@ int __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
>  	int ret = 0;
>  	int id;
>  
> +	/*
> +	 * If there is more than one notififer subscribed to this mm then we
> +	 * cannot support the EAGAIN return. invalidate_range_start/end() must
> +	 * always be paired unless start returns -EAGAIN. When we return
> +	 * -EAGAIN from here the caller will skip all invalidate_range_end()
> +	 * calls. However, if there is more than one notififer then some
> +	 * notifiers may have had a successful invalidate_range_start() -
> +	 * causing imbalance when the end is skipped.
> +	 */
> +	if (!mmu_notifier_range_blockable(range) &&
> +	    range->mm->mmu_notifier_mm->multiple_subscriptions)
> +		return -EAGAIN;
> +
>  	id = srcu_read_lock(&srcu);
>  	hlist_for_each_entry_rcu(mn, &range->mm->mmu_notifier_mm->list, hlist) {
>  		if (mn->ops->invalidate_range_start) {
> @@ -274,6 +287,8 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>  	 * thanks to mm_take_all_locks().
>  	 */
>  	spin_lock(&mm->mmu_notifier_mm->lock);
> +	mm->mmu_notifier_mm->multiple_subscriptions =
> +		!hlist_empty(&mm->mmu_notifier_mm->list);
>  	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
>  	spin_unlock(&mm->mmu_notifier_mm->lock);
>  
> -- 
> 2.22.0
> 

-- 
Michal Hocko
SUSE Labs

