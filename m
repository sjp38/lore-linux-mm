Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 748136B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 17:55:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s63so334729437ioi.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 14:55:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r186si786771oia.51.2016.07.03.14.55.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jul 2016 14:55:01 -0700 (PDT)
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run() failure check.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
	<201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
	<20160703124246.GA23902@redhat.com>
	<201607040103.DEB48914.HQFFJFOOOVtSLM@I-love.SAKURA.ne.jp>
	<20160703171022.GA31065@redhat.com>
In-Reply-To: <20160703171022.GA31065@redhat.com>
Message-Id: <201607040653.DJB81254.FFOOSHFOQMtJLV@I-love.SAKURA.ne.jp>
Date: Mon, 4 Jul 2016 06:53:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: oleg@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Oleg Nesterov wrote:
> On 07/04, Tetsuo Handa wrote:
> >
> > Oleg Nesterov wrote:
> > > On 07/03, Tetsuo Handa wrote:
> > > >
> > > > If kthread_run() in oom_init() fails due to reasons other than OOM
> > > > (e.g. no free pid is available), userspace processes won't be able to
> > > > start as well.
> > >
> > > Why?
> > >
> > > The kernel will boot with or without your change, but
> > >
> > > > Therefore, trying to continue with error message is
> > > > also pointless.
> > >
> > > Can't understand...
> > >
> > > I think this warning makes sense. And since you removed the oom_reaper_the
> > > check in wake_oom_reaper(), the kernel will leak every task_struct passed
> > > to wake_oom_reaper() ?
> >
> > We are trying to prove that OOM livelock is impossible for CONFIG_MMU=y
> > kernels (as long as OOM killer is invoked) because the OOM reaper always
> > gives feedback to the OOM killer, right? Then, preserving code which
> > continues without OOM reaper no longer makes sense.
> >
> > In the past discussion, I suggested Michal to use BUG_ON() or panic()
> > ( http://lkml.kernel.org/r/20151127123525.GG2493@dhcp22.suse.cz ). At that
> > time, we chose continue with pr_err(). If you think that kthread_run()
> > failure in oom_init() will ever happen, I can change my patch to call
> > BUG_ON() or panic(). I don't like continuing without OOM reaper.
> 
> And probably this makes sense, but
> 
> > Anyway, [PATCH 8/8] in this series removes get_task_struct().
> > Thus, the kernel won't leak every task_struct after all.
> 
> which I can't read yet. I am still trying to clone linux-net, currently
> my internet connection is very slow.
> 
> Anyway, this means that this 1/1 patch depends on 8/8, but 0/8 says
> 
> 	[PATCH 1/8] can be sent to current linux.git as a clean up.
> 
> IOW, this patch doesn't look correct without other changes?

If you think that global init can successfully start after kthread_run()
in oom_init() failed.

Here is an updated patch.

> 
> Oleg.
> 
> 

>From 977b0f4368a7ca07af7e519aa8795e7b2ee653d0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 4 Jul 2016 06:40:05 +0900
Subject: [PATCH 1/8] mm,oom_reaper: Don't boot without OOM reaper kernel thread.

We are trying to prove that OOM livelock is impossible for CONFIG_MMU=y
kernels (as long as OOM killer is invoked) because the OOM reaper always
gives feedback to the OOM killer. Therefore, preserving code which
continues without OOM reaper no longer makes sense.

Since oom_init() is called before OOM-killable userspace processes are
started, the system will panic if out_of_memory() is called before
oom_init() returns. Therefore, oom_reaper_th == NULL check in
wake_oom_reaper() is pointless.

If kthread_run() in oom_init() fails due to reasons other than
out_of_memory(), userspace processes won't be able to start as well.
Therefore, trying to continue with error message is also pointless.
But in case something unexpected occurred, let's explicitly add
BUG_ON() check.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 7d0a275..079ce96 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -447,7 +447,6 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
  * OOM Reaper kernel thread which tries to reap the memory used by the OOM
  * victim (if that is possible) to help the OOM killer to move on.
  */
-static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
@@ -629,9 +628,6 @@ static int oom_reaper(void *unused)
 
 void wake_oom_reaper(struct task_struct *tsk)
 {
-	if (!oom_reaper_th)
-		return;
-
 	/* tsk is already queued? */
 	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
 		return;
@@ -647,12 +643,9 @@ void wake_oom_reaper(struct task_struct *tsk)
 
 static int __init oom_init(void)
 {
-	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
-	if (IS_ERR(oom_reaper_th)) {
-		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
-				PTR_ERR(oom_reaper_th));
-		oom_reaper_th = NULL;
-	}
+	struct task_struct *p = kthread_run(oom_reaper, NULL, "oom_reaper");
+
+	BUG_ON(IS_ERR(p));
 	return 0;
 }
 subsys_initcall(oom_init)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
