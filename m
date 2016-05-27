Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 948536B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 04:03:22 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so50558823lbb.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:03:22 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id he4si24220487wjb.207.2016.05.27.01.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 01:03:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so11933310wmn.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 01:03:21 -0700 (PDT)
Date: Fri, 27 May 2016 10:03:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no
 external tasks sharing mm
Message-ID: <20160527080319.GD27686@dhcp22.suse.cz>
References: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
 <201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
 <20160526145930.GF23675@dhcp22.suse.cz>
 <201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
 <20160526153532.GG23675@dhcp22.suse.cz>
 <201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
 <20160527064510.GA27686@dhcp22.suse.cz>
 <20160527071507.GC27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160527071507.GC27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 27-05-16 09:15:07, Michal Hocko wrote:
> On Fri 27-05-16 08:45:10, Michal Hocko wrote:
> [...]
> > It is still an operation which is not needed for 99% of situations. So
> > if we do not need it for correctness then I do not think this is worth
> > bothering.
> 
> Since you have pointed out exit_mm vs. __exit_signal race yesterday I
> was thinking how to make the check reliable. Even
> atomic_read(mm->mm_users) > get_nr_threads() is not reliable and we can
> miss other tasks just because the current thread group is mostly past
> exit_mm. So far I couldn't find a way to tweak this around though.

Just for the record I was playing with the following yesterday but I
couldn't convince myself that this is safe and reasonable in the first
place (I do not like it to be honest).
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1685890d424e..db027eca8be5 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -123,6 +123,35 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
 	return t;
 }
 
+bool task_has_external_users(struct task_struct *p)
+{
+	struct mm_struct *mm = NULL;
+	struct task_struct *t;
+	int active_threads = 0;
+	bool ret = true;	/* be pessimistic */
+
+	rcu_read_lock();
+	for_each_thread(p, t) {
+		task_lock(t);
+		if (likely(t->mm)) {
+			active_threads++;
+			if (!mm) {
+				mm = t->mm;
+				atomic_inc(&mm->mm_count);
+			}
+		}
+		task_unlock(t);
+	}
+	rcu_read_unlock();
+
+	if (mm) {
+		if (atomic_read(&mm->mm_users) <= active_threads)
+			ret = false;
+		mmdrop(mm);
+	}
+	return ret;
+}
+
 /*
  * order == -1 means the oom kill is required by sysrq, otherwise only
  * for display purposes.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
