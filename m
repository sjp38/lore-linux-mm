Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 23BD36B0096
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 20:04:45 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so29927502pad.1
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 17:04:44 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ys3si14832896pac.119.2015.01.05.17.04.42
        for <linux-mm@kvack.org>;
        Mon, 05 Jan 2015 17:04:43 -0800 (PST)
Date: Tue, 6 Jan 2015 10:04:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
Message-ID: <20150106010442.GA17222@js1304-P5Q-DELUXE>
References: <1420421851-3281-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.11.1501050859520.24213@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501050859520.24213@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, Jan 05, 2015 at 09:28:14AM -0600, Christoph Lameter wrote:
> On Mon, 5 Jan 2015, Joonsoo Kim wrote:
> 
> > index 449fc6b..54656f0 100644
> > --- a/mm/slab.c
> > +++ b/mm/slab.c
> > @@ -168,6 +168,41 @@ typedef unsigned short freelist_idx_t;
> >
> >  #define SLAB_OBJ_MAX_NUM ((1 << sizeof(freelist_idx_t) * BITS_PER_BYTE) - 1)
> >
> > +#ifdef CONFIG_PREEMPT
> > +/*
> > + * Calculate the next globally unique transaction for disambiguiation
> > + * during cmpxchg. The transactions start with the cpu number and are then
> > + * incremented by CONFIG_NR_CPUS.
> > + */
> > +#define TID_STEP  roundup_pow_of_two(CONFIG_NR_CPUS)
> > +#else
> > +/*
> > + * No preemption supported therefore also no need to check for
> > + * different cpus.
> > + */
> > +#define TID_STEP 1
> > +#endif
> > +
> > +static inline unsigned long next_tid(unsigned long tid)
> > +{
> > +	return tid + TID_STEP;
> > +}
> > +
> > +static inline unsigned int tid_to_cpu(unsigned long tid)
> > +{
> > +	return tid % TID_STEP;
> > +}
> > +
> > +static inline unsigned long tid_to_event(unsigned long tid)
> > +{
> > +	return tid / TID_STEP;
> > +}
> > +
> > +static inline unsigned int init_tid(int cpu)
> > +{
> > +	return cpu;
> > +}
> > +
> 
> Ok the above stuff needs to go into the common code. Maybe in mm/slab.h?
> And its a significant feature contributed by me so I'd like to have an
> attribution here.

Okay. I will try!

> 
> >  /*
> >   * true if a page was allocated from pfmemalloc reserves for network-based
> >   * swap
> > @@ -187,7 +222,8 @@ static bool pfmemalloc_active __read_mostly;
> >   *
> >   */
> >  struct array_cache {
> > -	unsigned int avail;
> > +	unsigned long avail;
> > +	unsigned long tid;
> >  	unsigned int limit;
> >  	unsigned int batchcount;
> >  	unsigned int touched;
> > @@ -657,7 +693,8 @@ static void start_cpu_timer(int cpu)
> >  	}
> >  }
> 
> This increases the per cpu struct size and should lead to a small
> performance penalty.

Yes, but, it's marginal than improvement of this patchset.
> 
> > -	 */
> > -	if (likely(objp)) {
> > -		STATS_INC_ALLOCHIT(cachep);
> > -		goto out;
> > +	objp = ac->entry[avail - 1];
> > +	if (unlikely(!this_cpu_cmpxchg_double(
> > +		cachep->cpu_cache->avail, cachep->cpu_cache->tid,
> > +		avail, tid,
> > +		avail - 1, next_tid(tid))))
> > +		goto redo;
> 
> 
> Hmm... Ok that looks good.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
