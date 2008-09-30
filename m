From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
Date: Tue, 30 Sep 2008 20:42:25 +1000
References: <20080926173219.885155151@twins.programming.kicks-ass.net> <200809301721.52148.nickpiggin@yahoo.com.au> <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
In-Reply-To: <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809302042.26224.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@elte.hu>, Eric Dumazet <dada1@cosmosbay.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 30 September 2008 18:51, Peter Zijlstra wrote:
> On Tue, 2008-09-30 at 17:21 +1000, Nick Piggin wrote:

> > But these patches look good to me (last time we discussed them I thought
> > there was a race with page truncate, but it looks like you've closed that
> > by holding page lock over the whole operation...)
>
> Just to be sure, I only hold the page lock over the get_futex_key() op,
> and drop it after getting a ref on the futex key.
>
> I then drop the futex key ref after the futex op is complete.

I think that's fine.


> This assumes the futex key ref is suffucient to guarantee whatever is
> needed - which is the point I'm still not quite sure about myself.

It is enough to guarantee enough to function normally I guess. Actually
futex syscalls are interesting in that they logically perform 2 totally
different operations and actually want 2 keys but it manages to mash
them into one (the user address).

They need a futex identifier, on which to wait/wake/etc. For anonymous
futexes, this is basically an arbitrary number which is taken from the
user address (but note that if that address is subsequently mremap()ed
for example, then the futex identifier does not follow the address). For
shared futexes, the pagecache address is used for the futex, which is
derived from the address.

Then they also need a memory address which is the target of the
particular operation requested. This doesn't actually logically have to
be directly related to the futex identifier...

I guess for all practical purposes, this is fine. "if you mremap a live
mutex, you lose" and similar probably doesn't constrain too many people
(although I don't think any of that is actually documented). But anyway,
just to point out that we do already have constraints on how existing
futexes are going to work.


> The futex key ref was used between futex ops, with I assume the intent
> to ensure the futex backing stays valid. However, the key ref only takes
> a ref on either the inode or the mm, neither which avoid the specific
> address of the futex to get unmapped between ops.
>
> So in that respect we're not worse off than before, and any application
> doing: futex_wait(), munmap(), futex_wake() is going to suffer. And as
> far as I understand it get the waiting task stuck in D state for
> ever-more or somesuch.

Yeah, I think you're fine there (the sleep is interruptible, so it should
not be a DoS or anything). Just so long as you always pin things like the
inode correctly while taking a ref on it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
