Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 815B66B007E
	for <linux-mm@kvack.org>; Sat,  4 Jun 2016 06:57:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id d191so8930706oig.2
        for <linux-mm@kvack.org>; Sat, 04 Jun 2016 03:57:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f36si4816987otd.59.2016.06.04.03.57.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Jun 2016 03:57:24 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
	<201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
	<20160603122030.GG20676@dhcp22.suse.cz>
	<20160603122209.GH20676@dhcp22.suse.cz>
In-Reply-To: <20160603122209.GH20676@dhcp22.suse.cz>
Message-Id: <201606041957.FBG65129.OOFVFJLSHMFOQt@I-love.SAKURA.ne.jp>
Date: Sat, 4 Jun 2016 19:57:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 03-06-16 14:20:30, Michal Hocko wrote:
> [...]
> > Do no take me wrong but I would rather make sure that the current pile
> > is reviewed and no unintentional side effects are introduced than open
> > yet another can of worms.
> 
> And just to add. You have found many buugs in the previous versions of
> the patch series so I would really appreciate your Acked-by or
> Reviewed-by if you feel confortable with those changes or express your
> concerns.
> 
> Thanks!

I think we can send

"[PATCH 01/10] proc, oom: drop bogus task_lock and mm check",
"[PATCH 02/10] proc, oom: drop bogus sighand lock",
"[PATCH 03/10] proc, oom_adj: extract oom_score_adj setting into a helper"
(with
 	int err = 0;
 
 	task = get_proc_task(file_inode(file));
-	if (!task) {
-		err = -ESRCH;
-		goto out;
-	}
+	if (!task)
+		return -ESRCH;
 
 	mutex_lock(&oom_adj_mutex);
 	if (legacy) {

part from "[PATCH 04/10] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj"
folded into "[PATCH 03/10]"),
"[PATCH 08/10] mm, oom: task_will_free_mem should skip oom_reaped tasks" and
"[RFC PATCH 09/10] mm, oom_reaper: do not attempt to reap a task more than twice"

to linux-next, for these patches do not involve user visible changes.

Regarding "[PATCH 04/10] mm, oom_adj: make sure processes sharing mm have same view of oom_score_adj"
"[PATCH 05/10] mm, oom: skip vforked tasks from being selected" and
"[PATCH 06/10] mm, oom: kill all tasks sharing the mm", I don't want to
involve user visible changes without get-acquainted period, for

  An alternative would be to keep the task alive and skip the oom reaper and
  risk all the weird corner cases where the OOM killer cannot make forward
  progress because the oom victim hung somewhere on the way to exit.

can be avoided by introducing a simple timer (or do equivalent thing using
the OOM reaper by always waking up the OOM reaper).

If we introduce a simple timer (or do equivalent thing using the OOM reaper
by always waking up the OOM reaper), we can remove the "can_oom_reap" variable
in oom_kill_process() and threfore "[RFC PATCH 10/10] mm, oom: hide mm which
is shared with kthread or global init" will become unneeded.

"[PATCH 07/10] mm, oom: fortify task_will_free_mem" will be decided after
we guaranteed forward progress of the most subtle and unlikely situation
which I think we cannot help depending on either timer or the OOM reaper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
