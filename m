Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 969636B004D
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:01:03 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o820105L026736
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:01:00 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by wpaz1.hot.corp.google.com with ESMTP id o8200wgI008451
	for <linux-mm@kvack.org>; Wed, 1 Sep 2010 17:00:58 -0700
Received: by pvg2 with SMTP id 2so3061285pvg.19
        for <linux-mm@kvack.org>; Wed, 01 Sep 2010 17:00:58 -0700 (PDT)
Date: Wed, 1 Sep 2010 17:00:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/2] oom: use old_mm for oom_disable_count in exec
In-Reply-To: <alpine.DEB.2.00.1009011659020.14215@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1009011659490.14215@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011659020.14215@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

active_mm in the exec() path can be for an unrelated thread, so the 
oom_disable_count logic should use old_mm instead.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/exec.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -752,8 +752,8 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm = mm;
 	tsk->active_mm = mm;
 	activate_mm(active_mm, mm);
-	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
-		atomic_dec(&active_mm->oom_disable_count);
+	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
+		atomic_dec(&old_mm->oom_disable_count);
 		atomic_inc(&tsk->mm->oom_disable_count);
 	}
 	task_unlock(tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
