Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 833F06B0254
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 13:26:59 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so56575934pac.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 10:26:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fm10si15058622pab.152.2015.09.18.10.26.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 10:26:58 -0700 (PDT)
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150917192204.GA2728@redhat.com>
	<alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
	<20150918162423.GA18136@redhat.com>
In-Reply-To: <20150918162423.GA18136@redhat.com>
Message-Id: <201509190139.GJH48908.QMSFJLFtOHOVFO@I-love.SAKURA.ne.jp>
Date: Sat, 19 Sep 2015 01:39:53 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com, cl@linux.com
Cc: kwalker@redhat.com, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Oleg Nesterov wrote:
> To simplify the discussion lets ignore PF_FROZEN, this is another issue.
> 
> I am not sure this change is enough, we need to ensure that
> select_bad_process() won't pick the same task (or its sub-thread) again.

SysRq-f is sometimes unusable because it continues choosing the same thread.
oom_kill_process() should not choose a thread which already has TIF_MEMDIE.
I think we need to rewrite oom_kill_process().

> 
> And perhaps something like
> 
> 	wait_event_timeout(oom_victims_wait, !oom_victims,
> 				configurable_timeout);
> 
> before select_bad_process() makes sense?

I think you should not sleep for long with oom_lock mutex held.
http://marc.info/?l=linux-mm&m=143031212312459

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
