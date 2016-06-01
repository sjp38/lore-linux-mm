Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 517A26B0005
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 03:25:52 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so6757723wmf.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:25:52 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id s68si24165394wme.28.2016.06.01.00.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 00:25:51 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id a20so14123950wma.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 00:25:50 -0700 (PDT)
Date: Wed, 1 Jun 2016 09:25:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160601072549.GD26601@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-7-git-send-email-mhocko@kernel.org>
 <201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
 <20160531151019.GN26128@dhcp22.suse.cz>
 <201606010029.AHH64521.SOOQFMJFLOVFHt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606010029.AHH64521.SOOQFMJFLOVFHt@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Wed 01-06-16 00:29:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 01-06-16 00:03:53, Tetsuo Handa wrote:
[...]
> > > How is it guaranteed that task_will_free_mem() == false && oom_victims > 0
> > > shall not lock up the OOM killer?
> > 
> > But this patch is talking about task_will_free_mem == true. Is the
> > description confusing? Should I reword the changelog?
> 
> The situation I'm talking about is
> 
>   (1) out_of_memory() is called.
>   (2) select_bad_process() is called because task_will_free_mem(current) == false.
>   (3) oom_kill_process() is called because select_bad_process() chose a victim.
>   (4) oom_kill_process() sets TIF_MEMDIE on that victim.
>   (5) oom_kill_process() fails to call wake_oom_reaper() because that victim's
>       memory was shared by use_mm() or global init.
>   (6) other !TIF_MEMDIE threads sharing that victim's memory call out_of_memory().
>   (7) select_bad_process() is called because task_will_free_mem(current) == false.
>   (8) oom_scan_process_thread() returns OOM_SCAN_ABORT because it finds TIF_MEMDIE
>       set at (4).
>   (9) other !TIF_MEMDIE threads sharing that victim's memory fail to get TIF_MEMDIE.
>   (10) How other !TIF_MEMDIE threads sharing that victim's memory will release
>        that memory?
> 
> I'm fine with task_will_free_mem(current) == true case. My question is that
> "doesn't this patch break task_will_free_mem(current) == false case when there is
> already TIF_MEMDIE thread" ?

OK, I see your point now. This is certainly possible, albeit unlikely. I
think calling this a regression would be a bit an overstatement. We are
basically replacing one unreliable heuristic by another one which is
more likely to lead to a deterministic behavior.

If you are worried about locking up the oom killer I have another 2
patches on top of this series which should deal with that (one of them
was already posted [1] and another one was drafted in [2]. Both of them
on top of this series should remove the concern of the lockup. I just
wait to post them until this thread settles down.

[1] http://lkml.kernel.org/r/1464276476-25136-1-git-send-email-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20160527133502.GN27686@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
