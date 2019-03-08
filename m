Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802AAC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:03:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30A5020854
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 11:03:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30A5020854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915BA8E0003; Fri,  8 Mar 2019 06:03:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8749E8E0002; Fri,  8 Mar 2019 06:03:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73D8E8E0003; Fri,  8 Mar 2019 06:03:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1B38E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 06:03:29 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k21so9709462eds.19
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:03:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qceXw9FzYhlcZKwV9L+m4W+Z78q9D0qMiFiQf/9h3JE=;
        b=i1Stqw4iv3yX/BeYrOxttYnugTahvdKgrE4I7KcKDlDUN4TDgnR5ntm6U4zaw1H4uA
         iUrDggRT7i7vKZ1xi8ArLmqoHLDsMwAngPmkwShjS20xx1P+RwykFHfx4OXv70lIbCMi
         vblHT4iwT+HT/Lof1SCxFboEv01J8hLKdrIvwt45+KqfCJll9GlWC5himr6Rinx7tY+y
         JtUp4DjNO3j9nSP26d9X22/1ZsxSkb8F7pMVDk1Z1xUqNWSH8DmYVeG4fybjxxIzGaG1
         W4FMqiPHmfIOoiVbszP7l25vZluCRD07O0A3DjUgIDcuVbLRBOWNbr1/qpNv5yg2vMZP
         +nHg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAViy9kCQWUs8B4eGF38vijJ75rxNMA8OPkgLi0R0MF1WWokTHgR
	uK+np3IoDCdXLq/nbqIcBAiuVnMDO0mpuV37aHE3r8rstyRQSTj1HM5ZF6151V5PQrG3Cley8O/
	duZaQ2PzhjpfLE1RAtGQ02/mN/Z+4K6SnXMjs/k+cvGGIbX/XEJbX8746gC/1Mwg=
X-Received: by 2002:a17:906:f87:: with SMTP id q7mr11421471ejj.237.1552043008655;
        Fri, 08 Mar 2019 03:03:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqzc3k8ZNlR8C4anknIcffRU743Us4SiKBPNBAJja3lRkl4mlrfs/Iufu6v/UQYSjxh675ht
X-Received: by 2002:a17:906:f87:: with SMTP id q7mr11421420ejj.237.1552043007604;
        Fri, 08 Mar 2019 03:03:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552043007; cv=none;
        d=google.com; s=arc-20160816;
        b=eckx3mP4lG/qPhCBCa+bYF5DcwcPyyKF8zFq6NDTDTk0uQ9mxEiYs42pTlfGRPBaa9
         k/E3bPE4Yi0g6bCldh1hYYpBO75kKsH9rjg62R025WpzcikwLTmdvkiMXm5+IvG/S4rP
         +TFibUu8b+lHW7myMczSjZTjRTYoKcVq5TuLvtmryeRigizXEjrZwWS0NC+YBHb1B0ns
         NVmUz0P8TnpNPGT/nX+7mpq3rxX+rIswMJ7Arrq7a0Fx8lig6uOzaBY7mdTsm5Bd1I3A
         MoXz32J4l05KsI78OwaE/N8USpe3YtF10WGhAC7ehnkRHCKtTHtXsw8tfDBt2N1Z3USa
         gQJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qceXw9FzYhlcZKwV9L+m4W+Z78q9D0qMiFiQf/9h3JE=;
        b=xmxvFf946qoRpEy739va+XyHiN+ZiuzHOJCXYwOsIOa2lL4qcmrkafCpz0rGmvboVB
         KzzgyJmOrxTXd8r/BlOmTk7HR4qDGNS78ie/ERuHQms9QodttWyiDEhP+nd81BcOWIWM
         AqfaV97D1+GRGldu1yds+5ZBlPYrH/ZggVWTJ3KPBvLWEd4vW12FevIQQDm1VT3mj3xB
         +ecpFIP10WQuiru/tnwgf4j+q5iidE03svZPjJJeYZ7N11Yv4WU3m174kYm68W3q6mP+
         eDXIu5c8Q7gVzP8O7+oRQntigET/xt4zNLnGYUSZpuMNwCnCyz5Fg95f323Zb2i5jauQ
         tniw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x14si447356edb.209.2019.03.08.03.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 03:03:27 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2448AAFFB;
	Fri,  8 Mar 2019 11:03:26 +0000 (UTC)
Date: Fri, 8 Mar 2019 12:03:25 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
Message-ID: <20190308110325.GF5232@dhcp22.suse.cz>
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 08-03-19 19:22:02, Tetsuo Handa wrote:
> Since we are not allowed to depend on blocking memory allocations when
> oom_lock is already held, teach lockdep to consider that blocking memory
> allocations might wait for oom_lock at as early location as possible, and
> teach lockdep to consider that oom_lock is held by mutex_lock() than by
> mutex_trylock().

I do not understand this. It is quite likely that we will have multiple
allocations hitting this path while somebody else might hold the oom
lock.

What kind of problem does this actually want to prevent? Could you be
more specific please?

> Also, since the OOM killer is disabled until the OOM reaper or exit_mmap()
> sets MMF_OOM_SKIP, teach lockdep to consider that oom_lock is held when
> __oom_reap_task_mm() is called.
> 
> This patch should not cause lockdep splats unless there is somebody doing
> dangerous things (e.g. from OOM notifiers, from the OOM reaper).
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c   |  9 ++++++++-
>  mm/page_alloc.c | 13 +++++++++++++
>  2 files changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3a24848..759aa4e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -513,6 +513,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  	 */
>  	set_bit(MMF_UNSTABLE, &mm->flags);
>  
> +	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>  		if (!can_madv_dontneed_vma(vma))
>  			continue;
> @@ -544,6 +545,7 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
>  			tlb_finish_mmu(&tlb, range.start, range.end);
>  		}
>  	}
> +	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
>  
>  	return ret;
>  }
> @@ -1120,8 +1122,13 @@ void pagefault_out_of_memory(void)
>  	if (mem_cgroup_oom_synchronize(true))
>  		return;
>  
> -	if (!mutex_trylock(&oom_lock))
> +	if (!mutex_trylock(&oom_lock)) {
> +		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
> +		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
>  		return;
> +	}
> +	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
> +	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
>  	out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d0fa5b..25533214 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3793,6 +3793,8 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
> +	mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
> +	mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
>  
>  	/*
>  	 * Go through the zonelist yet one more time, keep very high watermark
> @@ -4651,6 +4653,17 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	fs_reclaim_acquire(gfp_mask);
>  	fs_reclaim_release(gfp_mask);
>  
> +	/*
> +	 * Allocation requests which can call __alloc_pages_may_oom() might
> +	 * fail to bail out due to waiting for oom_lock.
> +	 */
> +	if ((gfp_mask & __GFP_DIRECT_RECLAIM) && !(gfp_mask & __GFP_NORETRY) &&
> +	    (!(gfp_mask & __GFP_RETRY_MAYFAIL) ||
> +	     order <= PAGE_ALLOC_COSTLY_ORDER)) {
> +		mutex_acquire(&oom_lock.dep_map, 0, 0, _THIS_IP_);
> +		mutex_release(&oom_lock.dep_map, 1, _THIS_IP_);
> +	}
> +
>  	might_sleep_if(gfp_mask & __GFP_DIRECT_RECLAIM);
>  
>  	if (should_fail_alloc_page(gfp_mask, order))
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

