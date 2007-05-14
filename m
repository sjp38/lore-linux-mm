Received: by wr-out-0506.google.com with SMTP id 57so1702559wri
        for <linux-mm@kvack.org>; Mon, 14 May 2007 16:37:05 -0700 (PDT)
Message-ID: <b14e81f00705141637t1cc742c1y9badfce02fb02e0e@mail.gmail.com>
Date: Mon, 14 May 2007 19:37:05 -0400
From: "Michael Chang" <thenewme91@gmail.com>
Subject: Re: [ck] Re: [PATCH] mm: swap prefetch more improvements
In-Reply-To: <20070514160123.4b1ab108.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200705141050.55038.kernel@kolivas.org>
	 <20070514150032.d3ef6bb1.akpm@linux-foundation.org>
	 <200705150843.36721.kernel@kolivas.org>
	 <20070514160123.4b1ab108.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Con Kolivas <kernel@kolivas.org>, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 5/14/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 15 May 2007 08:43:35 +1000
> Con Kolivas <kernel@kolivas.org> wrote:
>
> > On Tuesday 15 May 2007 08:00, Andrew Morton wrote:
> > > On Mon, 14 May 2007 10:50:54 +1000
> > >
> > > Con Kolivas <kernel@kolivas.org> wrote:
> > > > akpm, please queue on top of "mm: swap prefetch improvements"
> > > >
> > > > ---
> > > > Failed radix_tree_insert wasn't being handled leaving stale kmem.
> > > >
> > > > The list should be iterated over in the reverse order when prefetching.
> > > >
> > > > Make the yield within kprefetchd stronger through the use of
> > > > cond_resched.
> > >
> > > hm.
> > >
> > > > -         might_sleep();
> > > > -         if (!prefetch_suitable())
> > > > +         /* Yield to anything else running */
> > > > +         if (cond_resched() || !prefetch_suitable())
> > > >                   goto out_unlocked;
> > >
> > > So if cond_resched() happened to schedule away, we terminate this
> > > swap-tricking attempt.  It's not possible to determine the reasons for this
> > > from the code or from the changelog (==bad).
> > >
> > > How come?
> >
> > Hmm I thought the line above that says "yield to anything else running" was
> > explicit enough. The idea is kprefetchd shouldn't run if any other real
> > activity is happening just about anywhere, and a positive cond_resched would
> > indicate likely activity so we just put kprefetchd back to sleep.
>
> I mean, if swap-prefetch is actually useful, then it'll still be useful if
> the machine happens to be doing some computational work.  It's not obvious
> to me that there is linkage between "doing CPU work" and "prefetching is
> presently undesirable".

That may be true, but I believe Con is attempting to err on the side
of caution in saying that swap prefetch should have practically no
negative impact if _anything_ is running. (The whole premise, for now,
anyways, is that swap prefetch should provide... "something for
(almost) nothing", if I'm interpreting this right.)

That said, there are probably some cases (seti) where swap prefetch
during the run of that batch program would help. On the flip side,
there are also some cases where batch processes (various other
seti-like "boinc" apps) which use a good deal of memory, meaning that
performing the prefetch at that time is futile, unhelpful, or
otherwise unwanted.

Would it be better to be less yield-y in this circumstance?

-- 
Michael Chang

Please avoid sending me Word or PowerPoint attachments.
See http://www.gnu.org/philosophy/no-word-attachments.html
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
