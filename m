Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 681056B0390
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 03:32:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z109so498022wrb.1
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 00:32:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k193si12009675wmg.134.2017.04.05.00.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 00:32:35 -0700 (PDT)
Date: Wed, 5 Apr 2017 09:32:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] loop: Add PF_LESS_THROTTLE to block/loop device
 thread.
Message-ID: <20170405073233.GD6035@dhcp22.suse.cz>
References: <871staffus.fsf@notabene.neil.brown.name>
 <87wpazh3rl.fsf@notabene.neil.brown.name>
 <20170405071927.GA7258@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405071927.GA7258@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Jens Axboe <axboe@fb.com>, linux-block@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ming Lei <tom.leiming@gmail.com>

On Wed 05-04-17 09:19:27, Michal Hocko wrote:
> On Wed 05-04-17 14:33:50, NeilBrown wrote:
[...]
> > diff --git a/drivers/block/loop.c b/drivers/block/loop.c
> > index 0ecb6461ed81..44b3506fd086 100644
> > --- a/drivers/block/loop.c
> > +++ b/drivers/block/loop.c
> > @@ -852,6 +852,7 @@ static int loop_prepare_queue(struct loop_device *lo)
> >  	if (IS_ERR(lo->worker_task))
> >  		return -ENOMEM;
> >  	set_user_nice(lo->worker_task, MIN_NICE);
> > +	lo->worker_task->flags |= PF_LESS_THROTTLE;
> >  	return 0;
> 
> As mentioned elsewhere, PF flags should be updated only on the current
> task otherwise there is potential rmw race. Is this safe? The code runs
> concurrently with the worker thread.

I believe you need something like this instead
---
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index f347285c67ec..07b2a909e4fb 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -844,10 +844,16 @@ static void loop_unprepare_queue(struct loop_device *lo)
 	kthread_stop(lo->worker_task);
 }
 
+int loop_kthread_worker_fn(void *worker_ptr)
+{
+	current->flags |= PF_LESS_THROTTLE;
+	return kthread_worker_fn(worker_ptr);
+}
+
 static int loop_prepare_queue(struct loop_device *lo)
 {
 	kthread_init_worker(&lo->worker);
-	lo->worker_task = kthread_run(kthread_worker_fn,
+	lo->worker_task = kthread_run(loop_kthread_worker_fn,
 			&lo->worker, "loop%d", lo->lo_number);
 	if (IS_ERR(lo->worker_task))
 		return -ENOMEM;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
