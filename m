Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id DCEE26B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 11:06:17 -0400 (EDT)
Received: by qkap81 with SMTP id p81so30277185qka.2
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 08:06:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f73si13026170qkh.55.2015.09.19.08.06.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 08:06:17 -0700 (PDT)
Date: Sat, 19 Sep 2015 17:03:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: can't oom-kill zap the victim's memory?
Message-ID: <20150919150316.GB31952@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/17, Kyle Walker wrote:
>
> Currently, the oom killer will attempt to kill a process that is in
> TASK_UNINTERRUPTIBLE state. For tasks in this state for an exceptional
> period of time, such as processes writing to a frozen filesystem during
> a lengthy backup operation, this can result in a deadlock condition as
> related processes memory access will stall within the page fault
> handler.

And there are other potential reasons for deadlock.

Stupid idea. Can't we help the memory hog to free its memory? This is
orthogonal to other improvements we can do.

Please don't tell me the patch below is ugly, incomplete and suboptimal
in many ways, I know ;) I am not sure it is even correct. Just to explain
what I mean.

Perhaps oom_unmap_func() should only zap the anonymous vmas... and there
are a lot of other details which should be discussed if this can make any
sense.

Oleg.
---

--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -493,6 +493,26 @@ void oom_killer_enable(void)
 	up_write(&oom_sem);
 }
 
+static struct mm_struct *oom_unmap_mm;
+
+static void oom_unmap_func(struct work_struct *work)
+{
+	struct mm_struct *mm = xchg(&oom_unmap_mm, NULL);
+
+	if (!atomic_inc_not_zero(&mm->mm_users))
+		return;
+
+	// If this is not safe we can do use_mm() + unuse_mm()
+	down_read(&mm->mmap_sem);
+	if (mm->mmap)
+		zap_page_range(mm->mmap, 0, TASK_SIZE, NULL);
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
+	mmdrop(mm);
+}
+static DECLARE_WORK(oom_unmap_work, oom_unmap_func);
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 /*
  * Must be called while holding a reference to p, which will be released upon
@@ -570,8 +590,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		victim = p;
 	}
 
-	/* mm cannot safely be dereferenced after task_unlock(victim) */
 	mm = victim->mm;
+	atomic_inc(&mm->mm_count);
 	mark_tsk_oom_victim(victim);
 	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
 		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
@@ -604,6 +624,10 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	rcu_read_unlock();
 
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	if (cmpxchg(&oom_unmap_mm, NULL, mm))
+		mmdrop(mm);
+	else
+		queue_work(system_unbound_wq, &oom_unmap_work);
 	put_task_struct(victim);
 }
 #undef K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
