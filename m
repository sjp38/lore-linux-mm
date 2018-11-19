Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0276B1B5E
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:46:10 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z68so45877501qkb.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:46:10 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k6si5022295qte.125.2018.11.19.08.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:46:09 -0800 (PST)
Date: Mon, 19 Nov 2018 08:45:54 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 05/13] workqueue, ktask: renice helper threads to
 prevent starvation
Message-ID: <20181119164554.axobolrufu26kfah@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-6-daniel.m.jordan@oracle.com>
 <20181113163400.GK2509588@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181113163400.GK2509588@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz

On Tue, Nov 13, 2018 at 08:34:00AM -0800, Tejun Heo wrote:
> Hello, Daniel.

Hi Tejun, sorry for the delay.  Plumbers...

> On Mon, Nov 05, 2018 at 11:55:50AM -0500, Daniel Jordan wrote:
> >  static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
> > -			     bool from_cancel)
> > +			     struct nice_work *nice_work, int flags)
> >  {
> >  	struct worker *worker = NULL;
> >  	struct worker_pool *pool;
> > @@ -2868,11 +2926,19 @@ static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
> >  	if (pwq) {
> >  		if (unlikely(pwq->pool != pool))
> >  			goto already_gone;
> > +
> > +		/* not yet started, insert linked work before work */
> > +		if (unlikely(flags & WORK_FLUSH_AT_NICE))
> > +			insert_nice_work(pwq, nice_work, work);
> 
> So, I'm not sure this works that well.  e.g. what if the work item is
> waiting for other work items which are at lower priority?  Also, in
> this case, it'd be a lot simpler to simply dequeue the work item and
> execute it synchronously.

Good idea, that is much simpler (and shorter).

So doing it this way, the current task's nice level would be adjusted while
running the work synchronously.

> 
> >  	} else {
> >  		worker = find_worker_executing_work(pool, work);
> >  		if (!worker)
> >  			goto already_gone;
> >  		pwq = worker->current_pwq;
> > +		if (unlikely(flags & WORK_FLUSH_AT_NICE)) {
> > +			set_user_nice(worker->task, nice_work->nice);
> > +			worker->flags |= WORKER_NICED;
> > +		}
> >  	}
> 
> I'm not sure about this.  Can you see whether canceling & executing
> synchronously is enough to address the latency regression?

In my testing, canceling was practically never successful because these are
long running jobs, so by the time the main ktask thread gets around to
flushing/nice'ing the works, worker threads have already started running them.
I had to write a no-op ktask to hit the first path where you suggest
dequeueing.  So adjusting the priority of a running worker seems required to
address the latency issue.

So instead of flush_work_at_nice, how about this?:

void renice_work_sync(work_struct *work, long nice);

If a worker is running the work, renice the worker to 'nice' and wait for it to
finish (what this patch does now), and if the work isn't running, dequeue it
and run in the current thread, again at 'nice'.


Thanks for taking a look.
