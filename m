Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D09E6B025E
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:31:53 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 93so15576821iol.2
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 23:31:53 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b70si4166814itc.32.2017.09.17.23.31.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 23:31:52 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: softlockup on warn_alloc on
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170915143732.GA8397@cmpxchg.org>
	<201709160023.CAE05229.MQHFSJFOOFOVtL@I-love.SAKURA.ne.jp>
	<20170915184449.GA9859@cmpxchg.org>
	<201709160925.GAC18219.FFVOtHJOQFOSLM@I-love.SAKURA.ne.jp>
	<20170918060524.sut26yl65j2cf3jk@dhcp22.suse.cz>
In-Reply-To: <20170918060524.sut26yl65j2cf3jk@dhcp22.suse.cz>
Message-Id: <201709181531.HGI09326.OFQMFOtVHFJSLO@I-love.SAKURA.ne.jp>
Date: Mon, 18 Sep 2017 15:31:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: hannes@cmpxchg.org, yuwang668899@gmail.com, linux-mm@kvack.org, chenggang.qcg@alibaba-inc.com, yuwang.yuwang@alibaba-inc.com, akpm@linux-foundation.org

Michal Hocko wrote:
> > > The synchronization has worked this way for a long time (trylock
> > > failure assuming progress, but the order/NOFS/zone bailouts from
> > > actually OOM-killing inside the locked section). We should really fix
> > > *that* rather than serializing warn_alloc().
> > > 
> > > For GFP_NOFS, it seems to go back to 9879de7373fc ("mm: page_alloc:
> > > embed OOM killing naturally into allocation slowpath"). Before that we
> > > didn't use to call __alloc_pages_may_oom() for NOFS allocations. So I
> > > still wonder why this only now appears to be causing problems.
> > > 
> > > In any case, converting that trylock to a sleeping lock in this case
> > > makes sense to me. Nobody is blocking under this lock (except that one
> > > schedule_timeout_killable(1) after dispatching a victim) and it's not
> > > obvious to me why we'd need that level of concurrency under OOM.
> > 
> > You can try http://lkml.kernel.org/r/1500202791-5427-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > and http://lkml.kernel.org/r/1503577106-9196-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp together.
> > Then, we can remove mutex_lock(&oom_lock) serialization from __oom_reap_task_mm()
> > which still exists because Andrea's patch was accepted instead of Michal's patch.
> 
> We can safely drop the oom_lock from __oom_reap_task_mm now. Andrea
> didn't want to do it in his patch because that is a separate thing
> logically. But nothing should prefent the removal now that AFAICS.

No! The oom_lock in __oom_reap_task_mm() is still required due to lack of
really last second allocation attempt. If we do really last second
allocation attempt, we can remove the oom_lock from __oom_reap_task_mm().



Enter __alloc_pages_may_oom()              Enter __oom_reap_task_mm()

  Take oom_lock

  Try last get_page_from_freelist()

                                             No "take oom_lock" here

                                             Reap memory

                                             Set MMF_OOM_SKIP

                                             No "release oom_lock" here

                                           Leave __oom_reap_task_mm()

  Enter out_of_memory()

    Enter select_bad_process()

      Enter oom_evaluate_task()

        Check if MMF_OOM_SKIP is already set

      Leave oom_evaluate_task()

    Leave select_bad_process()

    No "really last get_page_from_freelist()" here

    Kill the next victim needlessly

  Leave out_of_memory()

  Release oom_lock

Leave __alloc_pages_may_oom()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
