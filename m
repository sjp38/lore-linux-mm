Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9776D6B00AE
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 03:27:25 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so30638511pab.30
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 00:27:25 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id n3si58979167pap.106.2015.01.06.00.27.22
        for <linux-mm@kvack.org>;
        Tue, 06 Jan 2015 00:27:24 -0800 (PST)
Date: Tue, 6 Jan 2015 17:27:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
Message-ID: <20150106082723.GC18346@js1304-P5Q-DELUXE>
References: <023701d028c2$dba2cb30$92e86190$@alibaba-inc.com>
 <20150106013247.GC17222@js1304-P5Q-DELUXE>
 <20150105212502.1bdc4f67@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150105212502.1bdc4f67@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 'Jesper Dangaard Brouer' <brouer@redhat.com>

On Mon, Jan 05, 2015 at 09:25:02PM -0500, Steven Rostedt wrote:
> On Tue, 6 Jan 2015 10:32:47 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> 
> > > > +++ b/mm/slub.c
> > > > @@ -2398,13 +2398,15 @@ redo:
> > > >  	 * reading from one cpu area. That does not matter as long
> > > >  	 * as we end up on the original cpu again when doing the cmpxchg.
> > > >  	 *
> > > > -	 * Preemption is disabled for the retrieval of the tid because that
> > > > -	 * must occur from the current processor. We cannot allow rescheduling
> > > > -	 * on a different processor between the determination of the pointer
> > > > -	 * and the retrieval of the tid.
> > > > +	 * We should guarantee that tid and kmem_cache are retrieved on
> > > > +	 * the same cpu. It could be different if CONFIG_PREEMPT so we need
> > > > +	 * to check if it is matched or not.
> > > >  	 */
> > > > -	preempt_disable();
> > > > -	c = this_cpu_ptr(s->cpu_slab);
> > > > +	do {
> > > > +		tid = this_cpu_read(s->cpu_slab->tid);
> > > > +		c = this_cpu_ptr(s->cpu_slab);
> > > > +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> > > > +	barrier();
> > > 
> > > Help maintenance more if barrier is documented in commit message.
> > 
> > Hello,
> > 
> > Okay. Will add some information about this barrier in commit message.
> 
> A comment in the commit message is useless. Adding a small comment
> above the barrier() call itself would be much more useful.

Okay. Will do.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
