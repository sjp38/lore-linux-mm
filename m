Date: Tue, 30 Sep 2008 12:39:24 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
Message-ID: <20080930103924.GG7557@elte.hu>
References: <20080926173219.885155151@twins.programming.kicks-ass.net> <20080927161712.GA1525@elte.hu> <200809301721.52148.nickpiggin@yahoo.com.au> <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Tue, 2008-09-30 at 17:21 +1000, Nick Piggin wrote:
> > On Sunday 28 September 2008 02:17, Ingo Molnar wrote:
> > > * Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > > > Since get_user_pages_fast() made it in, I thought to give this another
> > > > try. Lightly tested by disabling the private futexes and running some
> > > > java proglets.
> > >
> > > hm, very interesting. Since this is an important futex usecase i started
> > > testing it in tip/core/futexes:
> > >
> > >  cd33272: futex: cleanup fshared
> > >  a135356: futex: use fast_gup()
> > >  39ce77b: futex: reduce mmap_sem usage
> > >  0d7a336: futex: rely on get_user_pages() for shared futexes
> > >
> > > Nick, it would be nice to get an Acked-by/Reviewed-by from you, before
> > > we think about whether it should go upstream.
> > 
> > Yeah, these all look pretty good. It's nice to get rid of mmap sem here.
> > 
> > Which reminds me, we need to put a might_lock mmap_sem into
> > get_user_pages_fast...
> 
> Yeah..
> 
> > But these patches look good to me (last time we discussed them I thought
> > there was a race with page truncate, but it looks like you've closed that
> > by holding page lock over the whole operation...)
> 
> Just to be sure, I only hold the page lock over the get_futex_key() op,
> and drop it after getting a ref on the futex key.
> 
> I then drop the futex key ref after the futex op is complete.
> 
> This assumes the futex key ref is suffucient to guarantee whatever is
> needed - which is the point I'm still not quite sure about myself.
> 
> The futex key ref was used between futex ops, with I assume the intent
> to ensure the futex backing stays valid. However, the key ref only takes
> a ref on either the inode or the mm, neither which avoid the specific
> address of the futex to get unmapped between ops.
> 
> So in that respect we're not worse off than before, and any application
> doing: futex_wait(), munmap(), futex_wake() is going to suffer. And as
> far as I understand it get the waiting task stuck in D state for
> ever-more or somesuch.
> 
> By now not holding the mmap_sem over the full futex op, but only over
> the get_futex_key(), that munmap() race gets larger and the actual futex
> could disappear while we're working on it, but in all cases I looked at
> that will make the futex op return -EFAULT, so we should be good there.
> 
> Gah, now that I look at it, it looks like I made get_futex_key()
> asymetric wrt private futexes, they don't take a ref on the key, but
> then do drop one... ouch.. Patch below.
> 
> > Nice work, Peter.
> 
> Thanks!
> 
> > BTW. what kinds of things use inter-process futexes as of now?
> 
> On a regular modern Linux system, not much. But I've been told there are
> applications out there that do indeed make heavy use of them - as
> they're part of POSIX etc.. blah blah :-)
> 
> Also some legacy stuff that's stuck on an ancient glibc (but somehow did
> manage to upgrade the kernel) might benefit.
> 
> 
> ---
> Subject: futex: fixup get_futex_key() for private futexes
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> With the get_user_pages_fast() patches we made get_futex_key() obtain a
> reference on the returned key, but failed to do so for private futexes.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

applied to tip/core/futexes, thanks Peter!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
