Subject: Re: [PATCH] mm: swap prefetch more improvements
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070514150032.d3ef6bb1.akpm@linux-foundation.org>
References: <200705141050.55038.kernel@kolivas.org>
	 <20070514150032.d3ef6bb1.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 15 May 2007 11:58:01 +0200
Message-Id: <1179223081.6810.133.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Con Kolivas <kernel@kolivas.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 15:00 -0700, Andrew Morton wrote:
> On Mon, 14 May 2007 10:50:54 +1000
> Con Kolivas <kernel@kolivas.org> wrote:
> 
> > akpm, please queue on top of "mm: swap prefetch improvements"
> > 
> > ---
> > Failed radix_tree_insert wasn't being handled leaving stale kmem.
> > 
> > The list should be iterated over in the reverse order when prefetching.
> > 
> > Make the yield within kprefetchd stronger through the use of cond_resched.
> 
> hm.
> 
> > 
> > -		might_sleep();
> > -		if (!prefetch_suitable())
> > +		/* Yield to anything else running */
> > +		if (cond_resched() || !prefetch_suitable())
> >  			goto out_unlocked;
> 
> So if cond_resched() happened to schedule away, we terminate this
> swap-tricking attempt.  It's not possible to determine the reasons for this
> from the code or from the changelog (==bad).
> 
> How come?

I think Con meant need_resched(). That would indicate someone else wants
to use the CPU and and has higher priority than kprefetchd.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
