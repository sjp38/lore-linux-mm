Date: Wed, 14 May 2008 11:27:14 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
In-Reply-To: <Pine.LNX.4.64.0805141053350.15490@schroedinger.engr.sgi.com>
Message-ID: <alpine.LFD.1.10.0805141114410.3019@woody.linux-foundation.org>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080508003838.GA9878@sgi.com> <200805132206.47655.nickpiggin@yahoo.com.au> <20080513153238.GL19717@sgi.com> <20080514041122.GE24516@wotan.suse.de>
 <20080514112625.GY9878@sgi.com> <alpine.LFD.1.10.0805140807400.3019@woody.linux-foundation.org> <Pine.LNX.4.64.0805141053350.15490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>


On Wed, 14 May 2008, Christoph Lameter wrote:
> 
> The problem is that the code in rmap.c try_to_umap() and friends loops 
> over reverse maps after taking a spinlock. The mm_struct is only known 
> after the rmap has been acccessed. This means *inside* the spinlock.

So you queue them. That's what we do with things like the dirty bit. We 
need to hold various spinlocks to look up pages, but then we can't 
actually call the filesystem with the spinlock held.

Converting a spinlock to a waiting lock for things like that is simply not 
acceptable. You have to work with the system.

Yeah, there's only a single bit worth of information on whether a page is 
dirty or not, so "queueing" that information is trivial (it's just the 
return value from "page_mkclean_file()". Some things are harder than 
others, and I suspect you need some kind of "gather" structure to queue up 
all the vma's that can be affected.

But it sounds like for the case of rmap, the approach of:

 - the page lock is the higher-level "sleeping lock" (which makes sense, 
   since this is very close to an IO event, and that is what the page lock 
   is generally used for)

   But hey, it could be anything else - maybe you have some other even 
   bigger lock to allow you to handle lots of pages in one go.

 - with that lock held, you do the whole rmap dance (which requires 
   spinlocks) and gather up the vma's and the struct mm's involved. 

 - outside the spinlocks you then do whatever it is you need to do.

This doesn't sound all that different from TLB shoot-down in SMP, and the 
"mmu_gather" structure. Now, admittedly we can do the TLB shoot-down while 
holding the spinlocks, but if we couldn't that's how we'd still do it: 
it would get more involved (because we'd need to guarantee that the gather 
can hold *all* the pages - right now we can just flush in the middle if we 
need to), but it wouldn't be all that fundamentally different.

And no, I really haven't even wanted to look at what XPMEM really needs to 
do, so maybe the above thing doesn't work for you, and you have other 
issues. I'm just pointing you in a general direction, not trying to say 
"this is exactly how to get there". 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
