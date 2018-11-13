Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5AA36B0008
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 11:34:05 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id c7so31440307qkg.16
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:34:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21sor9868380qkb.15.2018.11.13.08.34.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 08:34:04 -0800 (PST)
Date: Tue, 13 Nov 2018 08:34:00 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v4 05/13] workqueue, ktask: renice helper threads to
 prevent starvation
Message-ID: <20181113163400.GK2509588@devbig004.ftw2.facebook.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-6-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105165558.11698-6-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, vbabka@suse.cz

Hello, Daniel.

On Mon, Nov 05, 2018 at 11:55:50AM -0500, Daniel Jordan wrote:
>  static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
> -			     bool from_cancel)
> +			     struct nice_work *nice_work, int flags)
>  {
>  	struct worker *worker = NULL;
>  	struct worker_pool *pool;
> @@ -2868,11 +2926,19 @@ static bool start_flush_work(struct work_struct *work, struct wq_barrier *barr,
>  	if (pwq) {
>  		if (unlikely(pwq->pool != pool))
>  			goto already_gone;
> +
> +		/* not yet started, insert linked work before work */
> +		if (unlikely(flags & WORK_FLUSH_AT_NICE))
> +			insert_nice_work(pwq, nice_work, work);

So, I'm not sure this works that well.  e.g. what if the work item is
waiting for other work items which are at lower priority?  Also, in
this case, it'd be a lot simpler to simply dequeue the work item and
execute it synchronously.

>  	} else {
>  		worker = find_worker_executing_work(pool, work);
>  		if (!worker)
>  			goto already_gone;
>  		pwq = worker->current_pwq;
> +		if (unlikely(flags & WORK_FLUSH_AT_NICE)) {
> +			set_user_nice(worker->task, nice_work->nice);
> +			worker->flags |= WORKER_NICED;
> +		}
>  	}

I'm not sure about this.  Can you see whether canceling & executing
synchronously is enough to address the latency regression?

Thanks.

-- 
tejun
