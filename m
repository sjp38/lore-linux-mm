Date: Tue, 21 Dec 2004 09:36:31 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [RFC][PATCH 0/10] alternate 4-level page tables patches
In-Reply-To: <20041221093628.GA6231@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412210925370.4112@ppc970.osdl.org>
References: <Pine.LNX.4.44.0412210230500.24496-100000@localhost.localdomain>
 <Pine.LNX.4.58.0412201940270.4112@ppc970.osdl.org>
 <Pine.LNX.4.58.0412201953040.4112@ppc970.osdl.org> <20041221093628.GA6231@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>


On Tue, 21 Dec 2004, Andi Kleen wrote:
> 
> Sorry, but I think that's a very bad approach. If the i386 users
> don't get warnings I will need to spend a lot of time just patching
> behind them. While x86-64 is getting more and more popular most
> hacking still happens on i386.

That's true, but it's not an issue for several reasons:

 - we can easily update just _x86_ to be type-safe (ie add the fourth 
   level to x86 just to get type safety, even if it's folded). That 
   doesn't mean that we have to worry about 20 _other_ architectures, that 
   most developers can't even test.

   Iow, the lack of type-safety is not something forced by the approach. 
   The lack of type safety is an _option_ to allow architectures to not
   have to have a flag-day when everybody needs to switch.

   In fact, the lack of type-safety would allow every single intermediate
   patch to always compile, and work - on all architectures. Which isn't
   true in the current series, and which is a really nice feature, because 
   it means that you really can build up the thing entirely, up to the 
   point where you "turn it on" one architecture at a time.

 - even if we left x86 type-unsafe, the fact is, the things that walk the 
   page tables almost never get changed. I don't remember the last time we 
   really changed things around all that much. So even without x86, it 
   likely wouldn't be a problem.

> Also is the flag day really that bad?

I think that _avoiding_ a flag-day is always good. Also, more importantly,
it looks like this approach allows each patch to be smaller and more 
self-contained, ie we never have the situation where "uhhuh, now it won't 
compile on arch Xxxx for ten patches, until we turn things on". The 
smaller the patches are, the more obvious any problems will be.

Think of it this way: for random architecture X, the four-level page table 
patches really should make _no_ difference until they are enabled. So you 
can do 90% of the work, and be pretty confident that things work. Most 
importantly, if things _don't_ work before the thing has been enabled, 
that's a big clue ;)

And then, the last (small) patch for architecture X actually ends up 
enabling the work. Everybody will be happier with something like that, 
since it makes merging _much_ easier. For example, I'll have zero problems 
at all with merging the infrastructure the day after 2.6.10 is released, 
since I'll know that it won't hurt any of the other architectures, and it 
won't make trouble for anybody.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
