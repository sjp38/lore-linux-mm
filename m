Date: Tue, 26 Sep 2006 11:17:18 -0700 (PDT)
From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
In-Reply-To: <20060926000612.9db145a9.pj@sgi.com>
Message-ID: <Pine.LNX.4.64N.0609261049260.11233@attu4.cs.washington.edu>
References: <20060925091452.14277.9236.sendpatchset@v0>
 <Pine.LNX.4.64N.0609252214590.14826@attu4.cs.washington.edu>
 <20060926000612.9db145a9.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Sep 2006, Paul Jackson wrote:

> The goal is not to preserve a 1*HZ delay.  I just pulled that delay out
> of some unspeakable place.
> 
> Roughly I wanted to throttle the rate of wasteful scans of already full
> zones to some rate that was infrequent enough to solve our performance
> problem, while still fast enough that no one would ever seriously
> notice the subtle transient changes in memory placement behaviour.
> 

Absolutely, I'm sure we'll see a performance enhancement with the 
get_page_from_freelist speedup even though I cannot run benchmarks myself.
Since one second was chosen as the time interval between zaps, however, 
that will not always be the case if there's mangling and one CPU on the 
node will be zapping it prematurely when the system is being stressed for 
page allocation.  This happens to be the case where the smaller time 
interval would be the most unfortunate.  Obviously a second is a long time 
to constantly be allocating more and more pages, so I guess what bothers 
me is that we're zapping information that we have no reason to not believe 
is still accurate.

> Eh ... why not?  Sure, it's dirt simple.  But in this case, fancier
> control of this interval seems like it risks spending more effort than
> it would save, with almost no discernable advantage to the user.
> 

Because when we're stressing the system for more and more memory for a 
particular task regardless of whether it's starting or not, we're 
constantly allocating pages and zapping the nodemask about every second 
even though the status of each node could not have changed.  Those hints 
should not be zapped and rather preserved because we have not freed any 
pages over the same time interval and not because an arbitrary clock tick 
came around.

When we free memory from a specific zone, why is it not better to use 
zone_to_nid and then zap that _node_ in the nodemask only because we are 
guaranteed that the status has changed?

> > I would really like to 
> > run benchmarks on this implementation as I have done for the others but I 
> > no longer have access to a 64-bit machine. 
> 
> Odd ...  Do you expect that situation to be remedied anytime soon?
> 
> I'd like to see the results of your rerunning your benchmark.
> 

I no longer have access to a 64-bit machine or my benchmarking script so 
unless they have relaxed the kernel hacking policies for undergrads back 
at my school, I doubt I can contribute in performing benchmarks.  Four 
people on the Cc list to this email, however, still have access to my 
script.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
