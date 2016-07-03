Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB076B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 12:05:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id k78so322931640ioi.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 09:05:01 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z30si1182289ota.64.2016.07.03.09.04.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jul 2016 09:04:59 -0700 (PDT)
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run() failure check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
	<201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
	<20160703124246.GA23902@redhat.com>
In-Reply-To: <20160703124246.GA23902@redhat.com>
Message-Id: <201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
Date: Mon, 4 Jul 2016 01:03:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Oleg Nesterov wrote:
> On 07/03, Tetsuo Handa wrote:
> >
> > If kthread_run() in oom_init() fails due to reasons other than OOM
> > (e.g. no free pid is available), userspace processes won't be able to
> > start as well.
> 
> Why?
> 
> The kernel will boot with or without your change, but
> 
> > Therefore, trying to continue with error message is
> > also pointless.
> 
> Can't understand...
> 
> I think this warning makes sense. And since you removed the oom_reaper_the
> check in wake_oom_reaper(), the kernel will leak every task_struct passed
> to wake_oom_reaper() ?

We are trying to prove that OOM livelock is impossible for CONFIG_MMU=y
kernels (as long as OOM killer is invoked) because the OOM reaper always
gives feedback to the OOM killer, right? Then, preserving code which
continues without OOM reaper no longer makes sense.

In the past discussion, I suggested Michal to use BUG_ON() or panic()
( http://lkml.kernel.org/r/20151127123525.GG2493@dhcp22.suse.cz ). At that
time, we chose continue with pr_err(). If you think that kthread_run()
failure in oom_init() will ever happen, I can change my patch to call
BUG_ON() or panic(). I don't like continuing without OOM reaper.

Anyway, [PATCH 8/8] in this series removes get_task_struct().
Thus, the kernel won't leak every task_struct after all.

> 
> Oleg.
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
