Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 522C36B0005
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 04:12:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so10408319wml.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 01:12:02 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 204si1824131wmj.131.2016.08.11.01.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 01:12:01 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so1529224wmg.2
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 01:12:00 -0700 (PDT)
Date: Thu, 11 Aug 2016 10:11:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH/RFC] mm, oom: Fix uninitialized ret in
 task_will_free_mem()
Message-ID: <20160811081158.GB6908@dhcp22.suse.cz>
References: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
 <178c5e9b-b92d-b62b-40a9-ee98b10d6bce@I-love.SAKURA.ne.jp>
 <20160804144649.7ac4727ad0d93097c4055610@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160804144649.7ac4727ad0d93097c4055610@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Geert Uytterhoeven <geert@linux-m68k.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-08-16 14:46:49, Andrew Morton wrote:
> On Thu, 4 Aug 2016 21:28:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
> > > 
> > > Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
> > > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > > ---
> > > Untested. I'm not familiar with the code, hence the default value of
> > > true was deducted from the logic in the loop (return false as soon as
> > > __task_will_free_mem() has returned false).
> > 
> > I think ret = true is correct. Andrew, please send to linux.git.
> 
> task_will_free_mem() is too hard to understand.
> 
> We're examining task "A":
> 
> : 	for_each_process(p) {
> : 		if (!process_shares_mm(p, mm))
> : 			continue;
> : 		if (same_thread_group(task, p))
> : 			continue;
> 
> So here, we've found a process `p' which shares A's mm and which does
> not share A's thread group.
> 
> : 		ret = __task_will_free_mem(p);
> 
> And here we check to see if killing `p' would free up memory.
> 
> : 		if (!ret)
> : 			break;
> 
> If killing `p' will not free memory then give up the scan of all
> processes because <reasons>, and we decide that killing `A' will
> not free memory either, because some other task is holding onto
> A's memory anyway.
> 
> : 	}
> 
> And if no task is found to be sharing A's mm while not sharing A's
> thread group then fall through and decide to kill A.  In which case the
> patch to return `true' is correct.
> 
> Correctish? 

Yes this is more or less correct. task_will_free_mem is a bit misnomer
but I couldn't come up with something better when reworking it and so
I kept the original name. task_will_free_mem basically says that the
task is dying and we hope it will free some memory so it doesn't make
much sense to send it SIGKILL.

> Maybe.  Can we please get some comments in there to
> demystify the decision-making?
 
Does this help?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 908c097c8b47..ce02db7f8661 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -803,8 +803,9 @@ static bool task_will_free_mem(struct task_struct *task)
 		return true;
 
 	/*
-	 * This is really pessimistic but we do not have any reliable way
-	 * to check that external processes share with our mm
+	 * Make sure that all tasks which share the mm with the given tasks
+	 * are dying as well to make sure that a) nobody pins its mm and 
+	 * b) the task is also reapable by the oom reaper.
 	 */
 	rcu_read_lock();
 	for_each_process(p) {

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
