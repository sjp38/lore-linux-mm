Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 887B46B00A0
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 21:25:07 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id r2so4191426igi.1
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 18:25:07 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0099.hostedemail.com. [216.40.44.99])
        by mx.google.com with ESMTP id oo2si6322683igb.7.2015.01.05.18.25.05
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 18:25:06 -0800 (PST)
Date: Mon, 5 Jan 2015 21:25:02 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
Message-ID: <20150105212502.1bdc4f67@gandalf.local.home>
In-Reply-To: <20150106013247.GC17222@js1304-P5Q-DELUXE>
References: <023701d028c2$dba2cb30$92e86190$@alibaba-inc.com>
	<20150106013247.GC17222@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 'Jesper Dangaard Brouer' <brouer@redhat.com>

On Tue, 6 Jan 2015 10:32:47 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:


> > > +++ b/mm/slub.c
> > > @@ -2398,13 +2398,15 @@ redo:
> > >  	 * reading from one cpu area. That does not matter as long
> > >  	 * as we end up on the original cpu again when doing the cmpxchg.
> > >  	 *
> > > -	 * Preemption is disabled for the retrieval of the tid because that
> > > -	 * must occur from the current processor. We cannot allow rescheduling
> > > -	 * on a different processor between the determination of the pointer
> > > -	 * and the retrieval of the tid.
> > > +	 * We should guarantee that tid and kmem_cache are retrieved on
> > > +	 * the same cpu. It could be different if CONFIG_PREEMPT so we need
> > > +	 * to check if it is matched or not.
> > >  	 */
> > > -	preempt_disable();
> > > -	c = this_cpu_ptr(s->cpu_slab);
> > > +	do {
> > > +		tid = this_cpu_read(s->cpu_slab->tid);
> > > +		c = this_cpu_ptr(s->cpu_slab);
> > > +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> > > +	barrier();
> > 
> > Help maintenance more if barrier is documented in commit message.
> 
> Hello,
> 
> Okay. Will add some information about this barrier in commit message.

A comment in the commit message is useless. Adding a small comment
above the barrier() call itself would be much more useful.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
