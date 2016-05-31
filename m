Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 934C26B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:29:57 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id h5so39928853ioh.1
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:29:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w197si19850922oif.145.2016.05.31.08.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 08:29:56 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
	<1464613556-16708-7-git-send-email-mhocko@kernel.org>
	<201606010003.CAH18706.LFHOFVOJtQOSFM@I-love.SAKURA.ne.jp>
	<20160531151019.GN26128@dhcp22.suse.cz>
In-Reply-To: <20160531151019.GN26128@dhcp22.suse.cz>
Message-Id: <201606010029.AHH64521.SOOQFMJFLOVFHt@I-love.SAKURA.ne.jp>
Date: Wed, 1 Jun 2016 00:29:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> On Wed 01-06-16 00:03:53, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > task_will_free_mem is rather weak. It doesn't really tell whether
> > > the task has chance to drop its mm. 98748bd72200 ("oom: consider
> > > multi-threaded tasks in task_will_free_mem") made a first step
> > > into making it more robust for multi-threaded applications so now we
> > > know that the whole process is going down and probably drop the mm.
> > > 
> > > This patch builds on top for more complex scenarios where mm is shared
> > > between different processes - CLONE_VM without CLONE_THREAD resp
> > > CLONE_SIGHAND, or in kernel use_mm().
> > > 
> > > Make sure that all processes sharing the mm are killed or exiting. This
> > > will allow us to replace try_oom_reaper by wake_oom_reaper. Therefore
> > > all paths which bypass the oom killer are now reapable and so they
> > > shouldn't lock up the oom killer.
> > 
> > Really? The can_oom_reap variable was not removed before this patch.
> > It means that oom_kill_process() might fail to call wake_oom_reaper()
> > while setting TIF_MEMDIE to one of threads using that mm_struct.
> > If use_mm() or global init keeps that mm_struct not OOM reapable, other
> > threads sharing that mm_struct will get task_will_free_mem() == false,
> > won't it?
> > 
> > How is it guaranteed that task_will_free_mem() == false && oom_victims > 0
> > shall not lock up the OOM killer?
> 
> But this patch is talking about task_will_free_mem == true. Is the
> description confusing? Should I reword the changelog?

The situation I'm talking about is

  (1) out_of_memory() is called.
  (2) select_bad_process() is called because task_will_free_mem(current) == false.
  (3) oom_kill_process() is called because select_bad_process() chose a victim.
  (4) oom_kill_process() sets TIF_MEMDIE on that victim.
  (5) oom_kill_process() fails to call wake_oom_reaper() because that victim's
      memory was shared by use_mm() or global init.
  (6) other !TIF_MEMDIE threads sharing that victim's memory call out_of_memory().
  (7) select_bad_process() is called because task_will_free_mem(current) == false.
  (8) oom_scan_process_thread() returns OOM_SCAN_ABORT because it finds TIF_MEMDIE
      set at (4).
  (9) other !TIF_MEMDIE threads sharing that victim's memory fail to get TIF_MEMDIE.
  (10) How other !TIF_MEMDIE threads sharing that victim's memory will release
       that memory?

I'm fine with task_will_free_mem(current) == true case. My question is that
"doesn't this patch break task_will_free_mem(current) == false case when there is
already TIF_MEMDIE thread" ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
