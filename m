Date: Tue, 26 Sep 2006 12:58:57 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20060926122445.717c7c11.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0609261242170.22108@attu2.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
 <Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
 <20060926000612.9db145a9.pj@sgi.com> <Pine.LNX.4.64N.0609261049260.11233@attu4.cs.washington.edu>
 <20060926122445.717c7c11.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006, Paul Jackson wrote:

> So what if the average time between zaps is 0.9 seconds instead of 1.0
> seconds?  More realistically, we are talking something like 0.99999
> versus 1.00000 seconds, given that writing a 64 bit word on a 32 bit
> arch offers only a tiny window for lost races.
> 
> Lost races that break things are unacceptable, even in tiny windows.
> 
> But lost races that just slightly nudge an already arbitrary and not
> particularly fussy performance heuristic are not worth a single line
> of code to avoid.
> 

Why is it arbitrary, though?  This is hard-coded into the page allocation 
code as the performance enhancement window for which your code relies 
upon.  If time is the metric to be used to determine when we should go 
back and see if nodes have gained more memory, and I disagree that it is, 
then surely this one second window cannot possibly achieve the most 
efficient results you can squeeze out of your implementation for all 
possible workloads.  In my opinion a more appropriate metric would be when 
we _know_ the amount of free memory in a zone has changed.  And if you're 
seeking a distributed amount of memory among mems as your original post 
specified, then you could even get away with a simple counter and the 
nodemask is zapped after X number of page allocations.  This would _not_ 
be susceptible to race conditions among multiple CPU's on one node.

> > When we free memory from a specific zone, why is it not better to use 
> > zone_to_nid and then zap that _node_ in the nodemask only because we are 
> > guaranteed that the status has changed?
> 
> It might be better.  And it might not.  More likely, it would be an
> immeasurable difference except on custom microbenchmarks designed to
> highlight this difference one way or the other.
> 

If that's the case, then the entire speed-up is broken.  As it stands 
right now you're zapping the _entire_ nodemask every second and going back 
to rechecking all those that you failed to find free memory on in the 
past.  In my suggestion, you're only zapping a node when it is known that 
the free memory has changed (increased) based on a free.  So when my 
process that wants to mlock and allocate tons and tons of pages, you're 
zapping unnecessarily because the _exact_ same nodemask is going to 
reproduce itself but only after unnecessary delay.

> And unless I locked the bit clear, I'd still have to occassionally zap
> the entire nodemask.  Setting or clearing individual bits in a mask opens
> a bigger critical section to races.  Eventually, after loosing enough
> such races, that nodemask would be suitable for donating a little bit of
> entropy to the random number subsystem -- mush.
> 

The only such race conditions that exist are among the CPU's on that 
particular node in this case and the node bit is only zapped when pages 
are freed from a zone on that node.  And since the node bit is only turned 
on when it has been passed by and deemed too full to allocate on, I don't 
see where the race exists.  It's what we want since we aren't sure whether 
the free has allowed us to allocate there again, all we are doing is 
saying that it should be rechecked on the next alloc.

> > Four people on the Cc list to this email, however, still have access to
> > my script.
> 
> Perhaps you could ping them off-list, and see if they are in a position
> to participate.
> 

Done.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
