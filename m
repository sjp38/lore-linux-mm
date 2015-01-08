Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id B5F756B0032
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 02:44:41 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so10163907pab.7
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 23:44:41 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ol6si7104043pbb.116.2015.01.07.23.44.38
        for <linux-mm@kvack.org>;
        Wed, 07 Jan 2015 23:44:40 -0800 (PST)
Date: Thu, 8 Jan 2015 16:44:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
Message-ID: <20150108074447.GA25453@js1304-P5Q-DELUXE>
References: <1420421765-3209-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1420513392.24290.2.camel@stgolabs.net>
 <20150106080948.GA18346@js1304-P5Q-DELUXE>
 <1420563737.24290.7.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1420563737.24290.7.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, rostedt@goodmis.org, Thomas Gleixner <tglx@linutronix.de>

On Tue, Jan 06, 2015 at 09:02:17AM -0800, Davidlohr Bueso wrote:
> On Tue, 2015-01-06 at 17:09 +0900, Joonsoo Kim wrote:
> > On Mon, Jan 05, 2015 at 07:03:12PM -0800, Davidlohr Bueso wrote:
> > > On Mon, 2015-01-05 at 10:36 +0900, Joonsoo Kim wrote:
> > > > -	preempt_disable();
> > > > -	c = this_cpu_ptr(s->cpu_slab);
> > > > +	do {
> > > > +		tid = this_cpu_read(s->cpu_slab->tid);
> > > > +		c = this_cpu_ptr(s->cpu_slab);
> > > > +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> > > > +	barrier();
> > > 
> > > I don't see the compiler reodering the object/page stores below, since c
> > > is updated in the loop anyway. Is this really necessary (same goes for
> > > slab_free)? The generated code by gcc 4.8 looks correct without it.
> > > Additionally, the implied barriers for preemption control aren't really
> > > the same semantics used here (if that is actually the reason why you are
> > > using them).
> > 
> > Hello,
> > 
> > I'd like to use tid as a pivot so it should be fetched before fetching
> > anything on c. Is it impossible even if !CONFIG_PREEMPT without
> > barrier()?
> 
> You'd need a smp_wmb() in between tid and c in the loop then, which
> looks quite unpleasant. All in all disabling preemption isn't really
> that expensive, and you should redo your performance number if you go
> this way.

This barrier() is not for read/write synchronization between cpus.
All read/write operation to cpu_slab would happen on correct cpu in
successful case. What I'd need to guarantee here is to prevent
reordering between fetching operation for correctness of algorithm. In
this case, barrier() seems enough to me. Am I wrong?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
