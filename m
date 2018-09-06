Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2156B7724
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 02:22:57 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id q24-v6so9928155iog.8
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 23:22:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 28-v6si2932436jaq.40.2018.09.05.23.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 23:22:56 -0700 (PDT)
Message-Id: <201809060622.w866MchB056469@www262.sakura.ne.jp>
Subject: Re: [PATCH] =?ISO-2022-JP?B?bW0scGFnZV9hbGxvYzogUEZfV1FfV09SS0VSIHRocmVh?=
 =?ISO-2022-JP?B?ZHMgbXVzdCBzbGVlcCBhdCBzaG91bGRfcmVjbGFpbV9yZXRyeSgpLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 06 Sep 2018 15:22:38 +0900
References: <201809060100.w86100i6060716@www262.sakura.ne.jp> <20180906055742.GL14951@dhcp22.suse.cz>
In-Reply-To: <20180906055742.GL14951@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Michal Hocko wrote:
> > I assert that we should fix af5679fbc669f31f.
> 
> If you can come up with reasonable patch which doesn't complicate the
> code and it is a clear win for both this particular workload as well as
> others then why not.

Why can't we do "at least MMF_OOM_SKIP should be set under the lock to
prevent from races" ?

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b1..e096bb8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3065,7 +3065,9 @@ void exit_mmap(struct mm_struct *mm)
 		 */
 		(void)__oom_reap_task_mm(mm);
 
+		mutex_lock(&oom_lock);
 		set_bit(MMF_OOM_SKIP, &mm->flags);
+		mutex_unlock(&oom_lock);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa53..b2a94c1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -606,7 +606,9 @@ static void oom_reap_task(struct task_struct *tsk)
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
+	mutex_lock(&oom_lock);
 	set_bit(MMF_OOM_SKIP, &mm->flags);
+	mutex_unlock(&oom_lock);		
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
