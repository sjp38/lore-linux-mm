Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id B643D8E00F9
	for <linux-mm@kvack.org>; Sat, 26 Jan 2019 08:11:11 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id t83so6104403oie.16
        for <linux-mm@kvack.org>; Sat, 26 Jan 2019 05:11:11 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q205si2625807oib.203.2019.01.26.05.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Jan 2019 05:11:10 -0800 (PST)
Subject: [PATCH v2] oom, oom_reaper: do not enqueue same task twice
References: <df806a77-3327-9db5-8be2-976fde1c84e5@gmail.com>
 <20190117122535.njcbqhlmzozdkncw@mikami>
 <1d36b181-cbaf-6694-1a31-2f7f55d15675@gmail.com>
 <96ef6615-a5df-30af-b4dc-417a18ca63f1@gmail.com>
 <1cdbef13-564d-61a6-95f4-579d2cad243d@gmail.com>
 <20190125163731.GJ50184@devbig004.ftw2.facebook.com>
 <a95d004a-4358-7efc-6d21-12aac4411b32@gmail.com>
 <480296c4-ed7a-3265-e84a-298e42a0f1d5@I-love.SAKURA.ne.jp>
 <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
Date: Sat, 26 Jan 2019 22:10:52 +0900
MIME-Version: 1.0
In-Reply-To: <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Arkadiusz_Mi=c5=9bkiewicz?= <a.miskiewicz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On 2019/01/26 20:29, Arkadiusz Miśkiewicz wrote:
> On 26/01/2019 12:09, Tetsuo Handa wrote:
>> Arkadiusz, will you try this patch?
> 
> 
> Works. Several tries and always getting 0 pids.current after ~1s.
> 

Thank you for testing.

I updated this patch to use tsk->signal->oom_mm (a snapshot of
tsk->mm saved by mark_oom_victim(tsk)) rather than raw tsk->mm
so that we don't need to worry about possibility of changing
tsk->mm across multiple wake_oom_reaper(tsk) calls.



>From 9c9e935fc038342c48461aabca666f1b544e32b1 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 26 Jan 2019 21:57:25 +0900
Subject: [PATCH v2] oom, oom_reaper: do not enqueue same task twice

Arkadiusz reported that enabling memcg's group oom killing causes
strange memcg statistics where there is no task in a memcg despite
the number of tasks in that memcg is not 0. It turned out that there
is a bug in wake_oom_reaper() which allows enqueuing same task twice
which makes impossible to decrease the number of tasks in that memcg
due to a refcount leak.

This bug existed since the OOM reaper became invokable from
task_will_free_mem(current) path in out_of_memory() in Linux 4.7,
but memcg's group oom killing made it easier to trigger this bug by
calling wake_oom_reaper() on the same task from one out_of_memory()
request.

Fix this bug using an approach used by commit 855b018325737f76
("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task").
As a side effect of this patch, this patch also avoids enqueuing
multiple threads sharing memory via task_will_free_mem(current) path.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Reported-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Tested-by: Arkadiusz Miśkiewicz <arekm@maven.pl>
Fixes: af8e15cc85a25315 ("oom, oom_reaper: do not enqueue task if it is on the oom_reaper_list head")
---
 mm/oom_kill.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f0e8cd9..057bfee 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -505,14 +505,6 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 	bool ret = true;
 
-	/*
-	 * Tell all users of get_user/copy_from_user etc... that the content
-	 * is no longer stable. No barriers really needed because unmapping
-	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
-	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
-
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
 			continue;
@@ -647,8 +639,13 @@ static int oom_reaper(void *unused)
 
 static void wake_oom_reaper(struct task_struct *tsk)
 {
-	/* tsk is already queued? */
-	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
+	/*
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over a reaped memory.
+	 */
+	if (test_and_set_bit(MMF_UNSTABLE, &tsk->signal->oom_mm->flags))
 		return;
 
 	get_task_struct(tsk);
-- 
1.8.3.1
