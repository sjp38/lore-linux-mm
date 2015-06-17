Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 55C936B009E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:31:30 -0400 (EDT)
Received: by obbsn1 with SMTP id sn1so31831196obb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:31:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yx4si2601608obb.23.2015.06.17.05.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 05:31:29 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
	<20150617121104.GD25056@dhcp22.suse.cz>
In-Reply-To: <20150617121104.GD25056@dhcp22.suse.cz>
Message-Id: <201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
Date: Wed, 17 Jun 2015 21:31:21 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Hi,
> I was thinking about this and I am more and more convinced that we
> shouldn't care about panic_on_oom=2 configuration for now and go with
> the simplest solution first. I have revisited my original patch and
> replaced delayed work by a timer based on the feedback from Tetsuo.
> 

To me, obsolating panic_on_oom > 0 sounds cleaner.

> I think we can rely on timers. A downside would be that we cannot dump
> the full OOM report from the IRQ context because we rely on task_lock
> which is not IRQ safe. But I do not think we really need it. An OOM
> report will be in the log already most of the time and show_mem will
> tell us the current memory situation.
> 
> What do you think?

We can rely on timers, but we can't rely on global timer.

> +	if (sysctl_panic_on_oom_timeout) {
> +		if (sysctl_panic_on_oom > 1) {
> +			pr_warn("panic_on_oom_timeout is ignored for panic_on_oom=2\n");
> +		} else {
> +			/*
> +			 * Only schedule the delayed panic_on_oom when this is
> +			 * the first OOM triggered. oom_lock will protect us
> +			 * from races
> +			 */
> +			if (atomic_read(&oom_victims))
> +				return;
> +
> +			mod_timer(&panic_on_oom_timer,
> +					jiffies + (sysctl_panic_on_oom_timeout * HZ));
> +			return;
> +		}
> +	}

Since this version uses global panic_on_oom_timer, you cannot handle
OOM race like below.

  (1) p1 in memcg1 calls out_of_memory().
  (2) 5 seconds of timeout is started by p1.
  (3) p1 takes 3 seconds for some reason.
  (4) p2 in memcg2 calls out_of_memory().
  (5) p1 calls unmark_oom_victim() but timer continues.
  (6) p2 takes 2 seconds for some reason.
  (7) 5 seconds of timeout expires despite individual delay was less than
      5 seconds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
