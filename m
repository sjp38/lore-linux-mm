Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6916B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:23:58 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so214789419wic.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 04:23:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ck10si26488441wib.65.2015.07.29.04.23.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 04:23:57 -0700 (PDT)
Date: Wed, 29 Jul 2015 13:23:54 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 13/14] kthread_worker: Add
 set_kthread_worker_user_nice()
Message-ID: <20150729112354.GK2673@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-14-git-send-email-pmladek@suse.com>
 <20150728174058.GF5322@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728174058.GF5322@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-07-28 13:40:58, Tejun Heo wrote:
> On Tue, Jul 28, 2015 at 04:39:30PM +0200, Petr Mladek wrote:
> ...
> > +/*
> > + * set_kthread_worker_user_nice - set scheduling priority for the kthread worker
> > + * @worker: target kthread_worker
> > + * @nice: niceness value
> > + */
> > +void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice)
> > +{
> > +	struct task_struct *task = worker->task;
> > +
> > +	WARN_ON(!task);
> > +	set_user_nice(task, nice);
> > +}
> > +EXPORT_SYMBOL(set_kthread_worker_user_nice);
> 
> kthread_worker is explcitly associated with a single kthread.  Why do
> we want to create explicit wrappers for kthread operations?  This is
> encapsulation for encapsulation's sake.  It doesn't buy us anything at
> all.  Just let the user access the associated kthread and operate on
> it.

My plan is to make the API cleaner and hide struct kthread_worker
definition into kthread.c. It would prevent anyone doing any hacks
with it. BTW, we do the same with struct workqueue_struct.

Another possibility would be to add helper function to get the
associated task struct but this might cause inconsistencies when
the worker is restarted.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
