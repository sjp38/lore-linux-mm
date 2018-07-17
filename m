Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 35DE56B0010
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:56:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id s18-v6so672369wmh.0
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:56:37 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u9-v6si1102539wmu.213.2018.07.17.08.56.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jul 2018 08:56:35 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:56:30 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 3/6] bdi: Use refcount_t for reference counting instead
 atomic_t
Message-ID: <20180717155630.5propcebpubol6x3@linutronix.de>
References: <20180703200141.28415-1-bigeasy@linutronix.de>
 <20180703200141.28415-4-bigeasy@linutronix.de>
 <20180716155716.1f7ac43d211133a8cb476637@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180716155716.1f7ac43d211133a8cb476637@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>

On 2018-07-16 15:57:16 [-0700], Andrew Morton wrote:
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -438,10 +438,10 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
> >  	if (new_congested) {
> >  		/* !found and storage for new one already allocated, insert */
> >  		congested = new_congested;
> > -		new_congested = NULL;
> >  		rb_link_node(&congested->rb_node, parent, node);
> >  		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
> > -		goto found;
> > +		spin_unlock_irqrestore(&cgwb_lock, flags);
> > +		return congested;
> >  	}
> >  
> >  	spin_unlock_irqrestore(&cgwb_lock, flags);
> > @@ -451,13 +451,13 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
> >  	if (!new_congested)
> >  		return NULL;
> >  
> > -	atomic_set(&new_congested->refcnt, 0);
> > +	refcount_set(&new_congested->refcnt, 1);
> >  	new_congested->__bdi = bdi;
> >  	new_congested->blkcg_id = blkcg_id;
> >  	goto retry;
> >  
> >  found:
> > -	atomic_inc(&congested->refcnt);
> > +	refcount_inc(&congested->refcnt);
> >  	spin_unlock_irqrestore(&cgwb_lock, flags);
> >  	kfree(new_congested);
> >  	return congested;
> >
> > ...
> >
> 
> I'm not sure that the restructuring of wb_congested_get_create() was
> desirable and it does make the patch harder to review.  But it looks
> OK to me.

By `restructuring' you mean the addition of return statement instead
using the goto label in the first hunk? If so, then you would have

	refcount_set(&new_congested->refcnt, 0);
	refcount_inc(&congested->refcnt);

which is a 0 -> 1 transition and is forbidden by refcount_t. So I had to
avoid this one.

Thank you applying the patches!

You applied the bdi and userns switch from atomic_t to refcount_t.
There were also the patches
  [PATCH 4/6] bdi: Use irqsave variant of refcount_dec_and_lock()
  [PATCH 6/6] userns: Use irqsave variant of refcount_dec_and_lock()

in the series which make use the irqsave version of
refcount_dec_and_lock(). Did you miss them by chance or skipped them on
purpose?

Sebastian
