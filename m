Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D32F5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:31:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B4692147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:31:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B4692147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3465A8E0003; Tue, 12 Mar 2019 11:31:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F5758E0002; Tue, 12 Mar 2019 11:31:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E51C8E0003; Tue, 12 Mar 2019 11:31:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB63A8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:31:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id u12so1265367edo.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:31:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=50RHmb3cRzC9p7QpphFlbw66a+tl8H0b2luuX10/YIE=;
        b=Phzcc4/2QGmV/lqe1dTopHiCn+s5rTQxxJ1XZiIVIbOg3tk4arOPmXQAPOP1L7EF0K
         MF3CuxJHLSuAAMFHnXHr7z1igSnmlnIMrg6fX7AgaePmFqPeDaf7igQmE5t0IGu3zCPA
         VFZhrWzgzSn0XQ0mPsYSoqCjee+kfFaz4YUnFg9CI1FvuKMb8aF0P7stmYWQVdG//elI
         tAHvVNXOWnJ1vLvCrfD5sZS3X4XNIJctuudsm5Eao3mLbX1t9OuPe6nGHGDZYuGIbE0D
         jwdAfhwZjwKgAenZnHneZNIGrRcDAiIqvIh147k5gwjR0nQbt3uIPLQCwjZqyiYa5srx
         ynxA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWCwQfD7CGmhJsFFjFK3cH+T01BsTPGA7AAZra7TqwTRniz6kbW
	Xn9sZ2OZfPcrGdjFX/Q8GFszoFsKy7rmkyesxxY7nLyYoBM5jPsZ4a0zbtRwfIl1YHJ+YY1Y8lz
	FKXMfS2ivW/VwCmqbWr7ZaEZ8zBIKWVLWvRJCYgyV/IijJMqwnXjRLoB6Yd1N8Os=
X-Received: by 2002:a17:906:d1d0:: with SMTP id bs16mr25833139ejb.18.1552404703257;
        Tue, 12 Mar 2019 08:31:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXeUi+yYd15NNZ+53BdniNelr2YTUBBdmFq5AXYoER+I++TozICw5ZTQ3Uhc3mNlDbOsoG
X-Received: by 2002:a17:906:d1d0:: with SMTP id bs16mr25833080ejb.18.1552404702227;
        Tue, 12 Mar 2019 08:31:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404702; cv=none;
        d=google.com; s=arc-20160816;
        b=eTd406sYQ3CjEBYp/E8Q4aUtjr7iNU5jV2gbqWWEJYVawoZCdGjWkwKQJnogCFFb//
         0bzbwfxoWVzRB/x2iIe2nDSjbxspCHzb55WWZOdkqSFB+CJEKkIAMy1qLSnu6LPrGOOJ
         M5kywbHKfgfSWgrh2lxMH84MT4toyC1HQuUVOvke00Y6oFdcWXZe7BFkPvLBjPeYrRML
         jsdZCxIXSy25kDSTDszTqALejBk1R2iFWB8sD3ENQYNpjyhIDNrdLTGlKZuV79jPYavF
         yITTJc6+rM18TdONSErEU6et+SZbjmkbVUMIK1GcxUC7Z+q687k6O3UQqNx/pnv5rDB0
         gpzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=50RHmb3cRzC9p7QpphFlbw66a+tl8H0b2luuX10/YIE=;
        b=zugEo9gTmUDhU4q9kT+j9ETGdYOGX4iv6gQhRYxY68dSb6STkBF9YE0SceZ7/ErNjm
         MxzIbVOkKSIVyiWduglCixM3UdnkgGHXuL7YdmXHDVBgH8QMttOBMb4UGTTXjoMkA7ns
         F0Fdu1zhzzhqwBBhoFkdOWqEst0FE6+NZm40HxSCA4WpYNZ5A0+0kT1Xu8VAt0zb7flH
         JeaknAfob/wPmrUm3KC4gU6GKR8YqaCRhmgYX7mNiWcGpcELM/dWsuUoR5SQXy50peEq
         SL4oiijm+zHX9MKN+13xTYzMkjiv2urEGPJ4YmaA0rdukMxHIEWd99vCGXmYRmSELFXp
         AfOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t53si5210586edd.348.2019.03.12.08.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:31:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8EC21B69E;
	Tue, 12 Mar 2019 15:31:41 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:31:40 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190312153140.GU5721@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz>
 <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
 <20190308151327.GU5232@dhcp22.suse.cz>
 <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
 <20190311103012.GB5232@dhcp22.suse.cz>
 <d9b49a08-5d5a-ec4a-7cb7-c268999a9906@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9b49a08-5d5a-ec4a-7cb7-c268999a9906@i-love.sakura.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 23:06:33, Tetsuo Handa wrote:
[...]
> >From 250bbe28bc3e9946992d960bb90a351a896a543b Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 12 Mar 2019 22:58:41 +0900
> Subject: [PATCH v3] mm,oom: Teach lockdep about oom_lock.
> 
> Since a thread which succeeded to hold oom_lock must not involve blocking
> memory allocations, teach lockdep to consider that blocking memory
> allocations might wait for oom_lock at as early location as possible.
>
> Lockdep can't detect possibility of deadlock when mutex_trylock(&oom_lock)
> failed, for we assume that somebody else is still able to make a forward
> progress. Thus, teach lockdep to consider that mutex_trylock(&oom_lock) as
> mutex_lock(&oom_lock).
> 
> Since the OOM killer is disabled when __oom_reap_task_mm() is in progress,
> a thread which is calling __oom_reap_task_mm() must not involve blocking
> memory allocations. Thus, teach lockdep about that.
> 
> This patch should not cause lockdep splats unless there is somebody doing
> dangerous things (e.g. from OOM notifiers, from the OOM reaper).

This is obviously subjective but I find this still really hard to
understand.  What about
"
OOM killer path which holds oom_lock is not allowed to invoke any
blocking allocation because this might lead to a deadlock because any
forward progress is blocked because __alloc_pages_may_oom always bail
out on the trylock and the current lockdep implementation doesn't
recognize that as a potential deadlock. Teach the lockdep infrastructure
about this dependency and warn as early in the allocation path as
possible.

The implementation basically mimics GFP_NOFS/GFP_NOIO lockdep
implementation except that oom_lock dependency map is used directly.

Please note that oom_reaper guarantees a forward progress in case the
oom victim cannot exit on its own and as such it cannot depend on any
blocking allocation as well. Therefore mark its execution as if it was
holding the oom_lock as well.
"
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h | 12 ++++++++++++
>  mm/oom_kill.c       | 28 +++++++++++++++++++++++++++-
>  mm/page_alloc.c     | 16 ++++++++++++++++
>  3 files changed, 55 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index d079920..04aa46b 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -56,6 +56,18 @@ struct oom_control {
>  
>  extern struct mutex oom_lock;
>  
> +static inline void oom_reclaim_acquire(gfp_t gfp_mask)
> +{
> +	if (gfp_mask & __GFP_DIRECT_RECLAIM)
> +		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
> +}
> +
> +static inline void oom_reclaim_release(gfp_t gfp_mask)
> +{
> +	if (gfp_mask & __GFP_DIRECT_RECLAIM)
> +		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
> +}
> +
>  static inline void set_current_oom_origin(void)
>  {
>  	current->signal->oom_flag_origin = true;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3a24848..6f53bb6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -513,6 +513,14 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  	 */
>  	set_bit(MMF_UNSTABLE, &mm->flags);
>  
> +	/*
> +	 * Since this function acts as a guarantee of a forward progress,
> +	 * current thread is not allowed to involve (even indirectly via
> +	 * dependency) __GFP_DIRECT_RECLAIM && !__GFP_NORETRY allocation from

As already pointed out in the previous email, the less specific about
gfp flags you are the better longterm. I would stick with a "blocking
allocation"

> +	 * this function, for such allocation will have to wait for this
> +	 * function to complete when __alloc_pages_may_oom() is called.
> +	 */
> +	oom_reclaim_acquire(GFP_KERNEL);
>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>  		if (!can_madv_dontneed_vma(vma))
>  			continue;
> @@ -544,6 +552,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  			tlb_finish_mmu(&tlb, range.start, range.end);
>  		}
>  	}
> +	oom_reclaim_release(GFP_KERNEL);
>  
>  	return ret;
>  }
> @@ -1120,8 +1129,25 @@ void pagefault_out_of_memory(void)
>  	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  
> -	if (!mutex_trylock(&oom_lock))
> +	if (!mutex_trylock(&oom_lock)) {
> +		/*
> +		 * This corresponds to prepare_alloc_pages(). Lockdep will
> +		 * complain if e.g. OOM notifier for global OOM by error
> +		 * triggered pagefault OOM path.
> +		 */
> +		oom_reclaim_acquire(GFP_KERNEL);
> +		oom_reclaim_release(GFP_KERNEL);
>  		return;
> +	}
> +	/*
> +	 * Teach lockdep to consider that current thread is not allowed to
> +	 * involve (even indirectly via dependency) __GFP_DIRECT_RECLAIM &&
> +	 * !__GFP_NORETRY allocation from this function, for such allocation
> +	 * will have to wait for completion of this function when
> +	 * __alloc_pages_may_oom() is called.
> +	 */
> +	oom_reclaim_release(GFP_KERNEL);
> +	oom_reclaim_acquire(GFP_KERNEL);

This part is not really clear to me. Why do you release&acquire when
mutex_trylock just acquire the lock? If this is really needed then this
should be put into the comment.

>  	out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  }

-- 
Michal Hocko
SUSE Labs

