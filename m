Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 714C36B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 04:39:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so6510283wmz.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 01:39:10 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id lz8si25388204wjb.35.2016.06.06.01.39.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 01:39:09 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id n184so80607109wmn.1
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 01:39:09 -0700 (PDT)
Date: Mon, 6 Jun 2016 10:39:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
Message-ID: <20160606083907.GF11895@dhcp22.suse.cz>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
 <201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
 <20160603122030.GG20676@dhcp22.suse.cz>
 <20160603122209.GH20676@dhcp22.suse.cz>
 <201606041957.FBG65129.OOFVFJLSHMFOQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606041957.FBG65129.OOFVFJLSHMFOQt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Sat 04-06-16 19:57:14, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 03-06-16 14:20:30, Michal Hocko wrote:
> > [...]
> > > Do no take me wrong but I would rather make sure that the current pile
> > > is reviewed and no unintentional side effects are introduced than open
> > > yet another can of worms.
> > 
> > And just to add. You have found many buugs in the previous versions of
> > the patch series so I would really appreciate your Acked-by or
> > Reviewed-by if you feel confortable with those changes or express your
> > concerns.
> > 
> > Thanks!
> 
> I think we can send
> 
> "[PATCH 01/10] proc, oom: drop bogus task_lock and mm check",
> "[PATCH 02/10] proc, oom: drop bogus sighand lock",
> "[PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into a helper"
> (with
>  	int err = 0;
>  
>  	task = get_proc_task(file_inode(file));
> -	if (!task) {
> -		err = -ESRCH;
> -		goto out;
> -	}
> +	if (!task)
> +		return -ESRCH;
>  
>  	mutex_lock(&oom_adj_mutex);
>  	if (legacy) {

OK

> 
> part from "[PATCH 04/10] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj"
> folded into "[PATCH 03/10]"),
> "[PATCH 08/10] mm, oom: task_will_free_mem should skip oom_reaped tasks" and
> "[RFC PATCH 09/10] mm, oom_reaper: do not attempt to reap a task more than twice"
> 
> to linux-next, for these patches do not involve user visible changes.
> 
> Regarding "[PATCH 04/10] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj"
> "[PATCH 05/10] mm, oom: skip vforked tasks from being selected" and
> "[PATCH 06/10] mm, oom: kill all tasks sharing the mm", I don't want to
> involve user visible changes without get-acquainted period, for

I am trying to be really verbose in the system log when doing changes
which have user visible effects so I assume we will hear back from those
who might be affected. We can handle that when it happens. I have still
haven't heard even remotly sensible usage of oom_score_adj that would be
inconsistent between tasks sharing the memory.

If you really hate this change you can go and nack the patch but I would
really like to hear about at least sensible theoretical use case to
justify the nack. But I feel we are spending way too much time on
something that even might be not used by anybody.
 
>   An alternative would be to keep the task alive and skip the oom reaper and
>   risk all the weird corner cases where the OOM killer cannot make forward
>   progress because the oom victim hung somewhere on the way to exit.
> 
> can be avoided by introducing a simple timer (or do equivalent thing using
> the OOM reaper by always waking up the OOM reaper).

invoking the oom reaper just to find out what we know already and it is
unlikely to change after oom_kill_process just doesn't make much sense.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
