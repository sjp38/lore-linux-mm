From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: swap prefetch more improvements
Date: Tue, 15 May 2007 08:43:35 +1000
References: <200705141050.55038.kernel@kolivas.org> <20070514150032.d3ef6bb1.akpm@linux-foundation.org>
In-Reply-To: <20070514150032.d3ef6bb1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705150843.36721.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Tuesday 15 May 2007 08:00, Andrew Morton wrote:
> On Mon, 14 May 2007 10:50:54 +1000
>
> Con Kolivas <kernel@kolivas.org> wrote:
> > akpm, please queue on top of "mm: swap prefetch improvements"
> >
> > ---
> > Failed radix_tree_insert wasn't being handled leaving stale kmem.
> >
> > The list should be iterated over in the reverse order when prefetching.
> >
> > Make the yield within kprefetchd stronger through the use of
> > cond_resched.
>
> hm.
>
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

Hmm I thought the line above that says "yield to anything else running" was 
explicit enough. The idea is kprefetchd shouldn't run if any other real 
activity is happening just about anywhere, and a positive cond_resched would 
indicate likely activity so we just put kprefetchd back to sleep.

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
