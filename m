Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id F12526B0292
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 19:09:28 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m4so5286527qke.6
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 16:09:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x189sor1004594qka.16.2017.08.28.16.09.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 28 Aug 2017 16:09:28 -0700 (PDT)
Date: Mon, 28 Aug 2017 16:09:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170828230924.GG491396@devbig577.frc2.facebook.com>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <201708290715.FEI21383.HSFOQtJOMVOFFL@I-love.SAKURA.ne.jp>
 <20170828230256.GF491396@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170828230256.GF491396@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

Hey, again.

On Mon, Aug 28, 2017 at 04:02:56PM -0700, Tejun Heo wrote:
> Hmm... all these is mostly because workqueue lost the "ignore
> concurrency management" flag a while back while converting WQ_HIGHPRI
> to mean high nice priority instead of the top of the queue w/o
> concurrency management.  Resurrecting that shouldn't be too difficult.
> I'll get back to you soon.

Can you please try this patch and see how the work item behaves w/
WQ_HIGHPRI set?  It disables concurrency mgmt for highpri work items
which makes sense anyway.

Thanks.

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index ca937b0..14b6bce 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -2021,7 +2021,7 @@ __acquires(&pool->lock)
 {
 	struct pool_workqueue *pwq = get_work_pwq(work);
 	struct worker_pool *pool = worker->pool;
-	bool cpu_intensive = pwq->wq->flags & WQ_CPU_INTENSIVE;
+	bool cpu_intensive = pwq->wq->flags & (WQ_CPU_INTENSIVE | WQ_HIGHPRI);
 	int work_color;
 	struct worker *collision;
 #ifdef CONFIG_LOCKDEP


-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
