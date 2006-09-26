Date: Tue, 26 Sep 2006 12:24:45 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20060926122445.717c7c11.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64N.0609261049260.11233@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
	<Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
	<20060926000612.9db145a9.pj@sgi.com>
	<Pine.LNX.4.64N.0609261049260.11233@attu4.cs.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

David wrote:
> This happens to be the case where the smaller time 
> interval would be the most unfortunate.

"most unfortunate" -- that phrase sounds overly dramatic to me.

So what if the average time between zaps is 0.9 seconds instead of 1.0
seconds?  More realistically, we are talking something like 0.99999
versus 1.00000 seconds, given that writing a 64 bit word on a 32 bit
arch offers only a tiny window for lost races.

Lost races that break things are unacceptable, even in tiny windows.

But lost races that just slightly nudge an already arbitrary and not
particularly fussy performance heuristic are not worth a single line
of code to avoid.

> When we free memory from a specific zone, why is it not better to use 
> zone_to_nid and then zap that _node_ in the nodemask only because we are 
> guaranteed that the status has changed?

It might be better.  And it might not.  More likely, it would be an
immeasurable difference except on custom microbenchmarks designed to
highlight this difference one way or the other.

Less code is better, unless there is better reason than this for it.

And unless I locked the bit clear, I'd still have to occassionally zap
the entire nodemask.  Setting or clearing individual bits in a mask opens
a bigger critical section to races.  Eventually, after loosing enough
such races, that nodemask would be suitable for donating a little bit of
entropy to the random number subsystem -- mush.

> Four people on the Cc list to this email, however, still have access to
> my script.

Perhaps you could ping them off-list, and see if they are in a position
to participate.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
