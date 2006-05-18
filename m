Subject: Re: Query re:  mempolicy for page cache pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0605181105550.20557@schroedinger.engr.sgi.com>
References: <1147974599.5195.96.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0605181105550.20557@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 18 May 2006 15:27:54 -0400
Message-Id: <1147980474.5195.173.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@suse.de>, Steve Longerbeam <stevel@mvista.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-18 at 11:15 -0700, Christoph Lameter wrote:
> On Thu, 18 May 2006, Lee Schermerhorn wrote:
> 
> > Below I've included an overview of a patch set that I've been working
> > on.  I submitted a previous version [then called Page Cache Policy] back
> > ~20Apr.  I started working on this because Christoph seemed to consider
> > this a prerequisite for considering migrate-on-fault/lazy-migration/...
> > Since the previous post, I have addressed comments [from Christoph] and
> > kept the series up to date with the -mm tree.  
> 
> The prequisite for automatic page migration schemes in the kernel is proof 
> that these automatic migrations consistently improve performance. We are 
> still waiting on data showing that this is the case.

So far, all I have is evidence that good locality obtained at process
start up using default policy is broken by internode task migrations.
I have seen this penalty fixed by automatic migration for artificial
benchmarks [McAlpin STREAM] and know that this approached worked well
for TPC-like loads on previous NUMA systems I've worked on.  Currently,
I don't have access to TPC loads in my lab, but we're working on it.

And, if I could get the patches into the mm tree, once basic 
migration settles down so as not to complicate your on-going work, 
then folks could enable them to test the effects on their NUMA systems,
if they are at all concerned about load balancing upsetting previously
established locality.  You know: the open source, community
collaboration
thing.  I guess I thought that's what the mm tree is for.  Not
everything
that gets in there makes it to Linus' tree.

> 
> The particular automatic migration scheme that you proposed relies on 
> allocating pages according to the memory allocation policy. 

Makes emminent sense to me...

> 
> The basic problem is first of all that the memory policies do not
> necessarily describe how the user wants memory to be allocated. The user
> may temporarily switch task policies to get specific allocation patterns.
> So moving memory may misplace memory. We got around that by 
> saying that we need to separately enable migration if a user 
> wants it.

I'm aware of this.  I guess I always considered the temporary
switching of policies to achieve desired locality as a stopgap 
measure because of missing capabilities in the kernel.  

But, I agree that since this is the existing behavior and we don't
want to break user space, that it should be off by default and
enabled when desired.  My latest patch series, which I haven't posted
for obvious reasons, does support per cpuset enabling of 
migrate-on-fault and auto-migration.

> 
> But even then we have the issue that the memory policies cannot 
> describe proper allocation at all since allocation policies are 
> ignored for file backed vmas. And this is the issue you are trying to 
> address.

Right!  For consistency's sake, I guess.  I always looked at it as
the migrate-on-fault was "correcting" page misplacement at original
fault time.  Said with tongue only slightly in cheek ;-).

> 
> I think this is all far to complicated to do in kernel space and still 
> conceptually unclean. I would like to have all automatic migration schemes 
> confined to user space. We will add an API that allows some process
> to migrate pages at will.

We want pages to migrate when the load balancer decides to move the
process
to a new node, away from it's memory.  I suppose internode migration
could also be accidently reuniting a task with its memory footprint,
but the higher the node count, the lower the probability of this.  And,
if we did do some form of page migration on task migration, I think
we'd need to consider the cost of page migration in the decision to
migrate.   I see that previous attempts to consider memory footprint in
internode migration seem to have gone nowhere, tho'.  Probably not worth
it for some nominally numa platforms.  Even for platforms where it
might make sense, tuning the algorithms will, I think, require data
that can best be obtained from testing on multiple platforms.  Just
dreaming, I know...

As far as doing it in user space:  I supposed one could deliver a
notification to the process and have it migrate pages at that point.
Sounds a lot more inefficient than just unmapping pages that have 
default policy as the process returns to user space on the new node
[easy to hook in w/o adding new mechanism] and letting the pages fault
over as they are referenced.  After all, we don't know which pages
will be touched before the next internode migration.  I don't think
that the application itself would have a good idea of this at the 
time of the migration.

And, I think, complication and cleanliness is in the eye of the
beholder.
'Nuf said on that point... ;-)

Lee



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
