Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 432416B0005
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 18:57:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z142so258374920qkb.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 15:57:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 124si2470836qkk.34.2016.06.23.15.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 15:57:28 -0700 (PDT)
Date: Fri, 24 Jun 2016 00:58:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Message-ID: <20160623225809.GB17186@redhat.com>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, mhocko@suse.com, vdavydov@virtuozzo.com, rientjes@google.com

On 06/24, Tetsuo Handa wrote:
>
> On CONFIG_MMU=n kernels, nothing
> will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
> by error set to a mm-less thread group leader.

and btw this needs more cleanups imo. I mean, the fact we pass task_struct
to wake_oom_reaper() looks, well, strange. But this is off-topic right now.

> @@ -839,9 +839,19 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	if (task_will_free_mem(p)) {
> -		mark_oom_victim(p);
> -		wake_oom_reaper(p);
> -		put_task_struct(p);
> +		p = find_lock_task_mm(victim);
> +		if (!p) {

Well, this doesn't really matter... but imo

		victim = find_lock_task_mm(p);
		if (!victim) {

will look much more readable, and this way we won't depend on the
early "victim = p" initialization at the start.

> +			put_task_struct(victim);
> +			return;
> +		} else if (victim != p) {
> +			get_task_struct(p);
> +			put_task_struct(victim);
> +			victim = p;
> +		}

Tetsuo but this is horrible ;)

At least this needs a comment to explain _why_. Because this looks
"obviously unnecessary"; exit_oom_victim() does find_lock_task_mm()
too and "p" can exit right after we drop task_lock(). Not to mention
that task_will_free_mem() called find_lock_task_mm() right before
that, so this is sub-optimal in any case.

IOW, this should explain that we only need this for mark_oom_victim(),
and only if CONFIG_MMU=n. And this leads to other questions:

	- Why we can livelock in this case? This should be documented
	  too imo,

	  I have to admit I don't understand why. But yes, yes, sorry,
	  I ignored a lot of emails in this area :/

	- Why mark_oom_victim() can't check ->mm != NULL itself?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
