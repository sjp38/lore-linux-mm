Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id ECC306B009B
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 20:32:48 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lf10so29775064pab.19
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 17:32:48 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ou2si85987585pbb.214.2015.01.05.17.32.45
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 17:32:47 -0800 (PST)
Date: Tue, 6 Jan 2015 10:32:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/slub: optimize alloc/free fastpath by removing
 preemption on/off
Message-ID: <20150106013247.GC17222@js1304-P5Q-DELUXE>
References: <023701d028c2$dba2cb30$92e86190$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <023701d028c2$dba2cb30$92e86190$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Pekka Enberg' <penberg@kernel.org>, 'David Rientjes' <rientjes@google.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>

On Mon, Jan 05, 2015 at 04:37:35PM +0800, Hillf Danton wrote:
> > 
> > We had to insert a preempt enable/disable in the fastpath a while ago
> > in order to guarantee that tid and kmem_cache_cpu are retrieved on the
> > same cpu. It is the problem only for CONFIG_PREEMPT in which scheduler
> > can move the process to other cpu during retrieving data.
> > 
> > Now, I reach the solution to remove preempt enable/disable in the fastpath.
> > If tid is matched with kmem_cache_cpu's tid after tid and kmem_cache_cpu
> > are retrieved by separate this_cpu operation, it means that they are
> > retrieved on the same cpu. If not matched, we just have to retry it.
> > 
> > With this guarantee, preemption enable/disable isn't need at all even if
> > CONFIG_PREEMPT, so this patch removes it.
> > 
> > I saw roughly 5% win in a fast-path loop over kmem_cache_alloc/free
> > in CONFIG_PREEMPT. (14.821 ns -> 14.049 ns)
> > 
> > Below is the result of Christoph's slab_test reported by
> > Jesper Dangaard Brouer.
> > 
> > * Before
> > 
> >  Single thread testing
> >  =====================
> >  1. Kmalloc: Repeatedly allocate then free test
> >  10000 times kmalloc(8) -> 49 cycles kfree -> 62 cycles
> >  10000 times kmalloc(16) -> 48 cycles kfree -> 64 cycles
> >  10000 times kmalloc(32) -> 53 cycles kfree -> 70 cycles
> >  10000 times kmalloc(64) -> 64 cycles kfree -> 77 cycles
> >  10000 times kmalloc(128) -> 74 cycles kfree -> 84 cycles
> >  10000 times kmalloc(256) -> 84 cycles kfree -> 114 cycles
> >  10000 times kmalloc(512) -> 83 cycles kfree -> 116 cycles
> >  10000 times kmalloc(1024) -> 81 cycles kfree -> 120 cycles
> >  10000 times kmalloc(2048) -> 104 cycles kfree -> 136 cycles
> >  10000 times kmalloc(4096) -> 142 cycles kfree -> 165 cycles
> >  10000 times kmalloc(8192) -> 238 cycles kfree -> 226 cycles
> >  10000 times kmalloc(16384) -> 403 cycles kfree -> 264 cycles
> >  2. Kmalloc: alloc/free test
> >  10000 times kmalloc(8)/kfree -> 68 cycles
> >  10000 times kmalloc(16)/kfree -> 68 cycles
> >  10000 times kmalloc(32)/kfree -> 69 cycles
> >  10000 times kmalloc(64)/kfree -> 68 cycles
> >  10000 times kmalloc(128)/kfree -> 68 cycles
> >  10000 times kmalloc(256)/kfree -> 68 cycles
> >  10000 times kmalloc(512)/kfree -> 74 cycles
> >  10000 times kmalloc(1024)/kfree -> 75 cycles
> >  10000 times kmalloc(2048)/kfree -> 74 cycles
> >  10000 times kmalloc(4096)/kfree -> 74 cycles
> >  10000 times kmalloc(8192)/kfree -> 75 cycles
> >  10000 times kmalloc(16384)/kfree -> 510 cycles
> > 
> > * After
> > 
> >  Single thread testing
> >  =====================
> >  1. Kmalloc: Repeatedly allocate then free test
> >  10000 times kmalloc(8) -> 46 cycles kfree -> 61 cycles
> >  10000 times kmalloc(16) -> 46 cycles kfree -> 63 cycles
> >  10000 times kmalloc(32) -> 49 cycles kfree -> 69 cycles
> >  10000 times kmalloc(64) -> 57 cycles kfree -> 76 cycles
> >  10000 times kmalloc(128) -> 66 cycles kfree -> 83 cycles
> >  10000 times kmalloc(256) -> 84 cycles kfree -> 110 cycles
> >  10000 times kmalloc(512) -> 77 cycles kfree -> 114 cycles
> >  10000 times kmalloc(1024) -> 80 cycles kfree -> 116 cycles
> >  10000 times kmalloc(2048) -> 102 cycles kfree -> 131 cycles
> >  10000 times kmalloc(4096) -> 135 cycles kfree -> 163 cycles
> >  10000 times kmalloc(8192) -> 238 cycles kfree -> 218 cycles
> >  10000 times kmalloc(16384) -> 399 cycles kfree -> 262 cycles
> >  2. Kmalloc: alloc/free test
> >  10000 times kmalloc(8)/kfree -> 65 cycles
> >  10000 times kmalloc(16)/kfree -> 66 cycles
> >  10000 times kmalloc(32)/kfree -> 65 cycles
> >  10000 times kmalloc(64)/kfree -> 66 cycles
> >  10000 times kmalloc(128)/kfree -> 66 cycles
> >  10000 times kmalloc(256)/kfree -> 71 cycles
> >  10000 times kmalloc(512)/kfree -> 72 cycles
> >  10000 times kmalloc(1024)/kfree -> 71 cycles
> >  10000 times kmalloc(2048)/kfree -> 71 cycles
> >  10000 times kmalloc(4096)/kfree -> 71 cycles
> >  10000 times kmalloc(8192)/kfree -> 65 cycles
> >  10000 times kmalloc(16384)/kfree -> 511 cycles
> > 
> > Most of the results are better than before.
> > 
> > Note that this change slightly worses performance in !CONFIG_PREEMPT,
> > roughly 0.3%. Implementing each case separately would help performance,
> > but, since it's so marginal, I didn't do that. This would help
> > maintanance since we have same code for all cases.
> > 
> > Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/slub.c |   26 +++++++++++++-------------
> >  1 file changed, 13 insertions(+), 13 deletions(-)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index fe376fe..0624608 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2398,13 +2398,15 @@ redo:
> >  	 * reading from one cpu area. That does not matter as long
> >  	 * as we end up on the original cpu again when doing the cmpxchg.
> >  	 *
> > -	 * Preemption is disabled for the retrieval of the tid because that
> > -	 * must occur from the current processor. We cannot allow rescheduling
> > -	 * on a different processor between the determination of the pointer
> > -	 * and the retrieval of the tid.
> > +	 * We should guarantee that tid and kmem_cache are retrieved on
> > +	 * the same cpu. It could be different if CONFIG_PREEMPT so we need
> > +	 * to check if it is matched or not.
> >  	 */
> > -	preempt_disable();
> > -	c = this_cpu_ptr(s->cpu_slab);
> > +	do {
> > +		tid = this_cpu_read(s->cpu_slab->tid);
> > +		c = this_cpu_ptr(s->cpu_slab);
> > +	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
> > +	barrier();
> 
> Help maintenance more if barrier is documented in commit message.

Hello,

Okay. Will add some information about this barrier in commit message.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
