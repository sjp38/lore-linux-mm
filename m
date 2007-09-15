Date: Fri, 14 Sep 2007 17:07:00 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH/RFC 0/14] Page Reclaim Scalability
In-Reply-To: <1189807345.5826.27.camel@lappy>
Message-ID: <alpine.LFD.0.999.0709141653430.16478@woody.linux-foundation.org>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <1189804264.5826.5.camel@lappy>  <alpine.LFD.0.999.0709141422110.16478@woody.linux-foundation.org>
 <1189807345.5826.27.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


On Sat, 15 Sep 2007, Peter Zijlstra wrote:
> 
> When looking at the locking hierarchy as presented in rmap.c these two
> locks are the first non sleeper locks (and from a quick look at the code
> there are no IRQ troubles either), so changing them to a sleeping lock
> is quite doable - if that turns out to have advantages over rwlock_t in
> this case.

Well, I don't really think that read-write sleeper locks are any better 
than read-write spinlocks. They are even *more* expensive, and the only 
advantage of the sleeper lock is if it allows you to do other things. 
Which I don't think is the case here (nor do we necessarily *want* to make 
the VM have more sleeping situations)

So when it comes to anon_vma lock and i_mmap_lock, maybe rwlocks are fine. 
They do have some latency advantages if writers are really comparatively 
rare and the critical region is bigger. And I could imagine that under 
load it does get big, and the locking overhead is not a big deal.

That said - we *do* actually have things like 

	cond_resched_lock(&mapping->i_mmap_lock);

which at least to me tends to imply that maybe a sleeping lock really 
might be the right thing, since latency has been a problem for these 
things. It's certainly a sign of *something*.

> > So if you actually look for scalability to lots of CPU's, I think you'd 
> > want RCU.
> 
> Certainly, although that might take a little more than a trivial change.

Yeah, I can imagine..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
