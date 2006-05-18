Date: Thu, 18 May 2006 12:53:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Query re:  mempolicy for page cache pages
In-Reply-To: <1147980474.5195.173.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0605181238090.21509@schroedinger.engr.sgi.com>
References: <1147974599.5195.96.camel@localhost.localdomain>
 <Pine.LNX.4.64.0605181105550.20557@schroedinger.engr.sgi.com>
 <1147980474.5195.173.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 May 2006, Lee Schermerhorn wrote:

> So far, all I have is evidence that good locality obtained at process
> start up using default policy is broken by internode task migrations.

Internode task migrations are tighly controlled by the scheduler and by 
cpusets.

> > The basic problem is first of all that the memory policies do not
> > necessarily describe how the user wants memory to be allocated. The user
> > may temporarily switch task policies to get specific allocation patterns.
> > So moving memory may misplace memory. We got around that by 
> > saying that we need to separately enable migration if a user 
> > wants it.
> 
> I'm aware of this.  I guess I always considered the temporary
> switching of policies to achieve desired locality as a stopgap 
> measure because of missing capabilities in the kernel.  

Policy switching is part of the design for memory policies. It is not
a stopgap measure.

> > But even then we have the issue that the memory policies cannot 
> > describe proper allocation at all since allocation policies are 
> > ignored for file backed vmas. And this is the issue you are trying to 
> > address.
> 
> Right!  For consistency's sake, I guess.  I always looked at it as
> the migrate-on-fault was "correcting" page misplacement at original
> fault time.  Said with tongue only slightly in cheek ;-).

Consistency in the sense that we would use memory policies as 
allocation restrictions. However, they are really placement methods. Only 
MPOL_BIND is truly an allocation restriction.

> We want pages to migrate when the load balancer decides to move the
> process
> to a new node, away from it's memory.  I suppose internode migration

We can do that from user space by a scheduling daemon that may have a 
longer range view of things. Also an execution thread may be temporarily
move to another node and then come back later. We really need a much more 
complex scheduler to take all of this into account and that I would say 
also belongs into user space.

> As far as doing it in user space:  I supposed one could deliver a
> notification to the process and have it migrate pages at that point.

Right.

> Sounds a lot more inefficient than just unmapping pages that have 
> default policy as the process returns to user space on the new node
> [easy to hook in w/o adding new mechanism] and letting the pages fault
> over as they are referenced.  After all, we don't know which pages
> will be touched before the next internode migration.  I don't think
> that the application itself would have a good idea of this at the 
> time of the migration.

There would have to be some interface to the scheduler. We never know
know which pages are going to be touched next and in our experience the 
automatic page migration schemes frequently makes the wrong decisions. You 
need to have a huge number of accesses to an off node page in order to justify 
migrating a single page. All these experiments better live in user space. 
Migration of a single page requires taking numerous locks. True the 
expense rises with deferring the decision to user space but user space can 
have more sophisticated databases on page use. Maybe that will finally get 
us to an automatic page migration scheme that is actually improving system 
performance.

> And, I think, complication and cleanliness is in the eye of the
> beholder.
> 'Nuf said on that point... ;-)

True. But lets keep the kernel as simple as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
