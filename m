Date: Sat, 16 Jul 2005 01:44:02 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-ID: <20050715234402.GN15783@wotan.suse.de>
References: <20050715211210.GI15783@wotan.suse.de> <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com> <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com> <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com> <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com> <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 15, 2005 at 04:11:00PM -0700, Christoph Lameter wrote:
> On Sat, 16 Jul 2005, Andi Kleen wrote:
> 
> > > Updating the memory policy is also useful if memory on one node gets 
> > > short and you want to redirct allocations to a node that has memory free. 
> > 
> > If you use MEMBIND just specify all the nodes upfront and it'll
> > do the normal fallback in them. 
> > 
> > If you use PREFERED it'll do that automatically anyways.
> 
> No it wont. If you know that you are going to start a process that must 
> run on node 3 and know its going to use 2G but there is only 1G free 
> then you may want to modify the policy of an existing huge process on 
> node 3that is still allocating to go to node 2 that just happens to have 
> free space.

I think you should leave that to the kernel.

> > > A batch scheduler may anticipate memory shortages and redirect memory 
> > > allocations in order to avoid page migration.
> > I think that jobs more belongs to the kernel. After all we don't
> > want to move half of our VM into your proprietary scheduler.
> 
> Care to tell me which proprietary scheduler you are talking about? I was 

That SGI batch scheduler with its incredibly long specification
list you guys seem to want to mess up all interfaces
for. If I can download source to it please supply an URL. 

> And you are now going to implement automatic page migration into the 
> existing scheduler?

Hmm? You mean the kernel CPU scheduler? Nobody is planning to add
page migration to that.
> 
> > > I'd rather have that logic in userspace rather than fix up page_migrate 
> > > again and again and again. Automatic recalculation of memory policies is 
> > > likely an unexpected side effect of the existing page migration code. 
> > 
> > Only if you migrate again and again.
> 
> If you encounter different situation then you may need different address 
> translation. F.e. lets say you want to move a process from node 3 and 4 to 
> node 5. That wont work with the existing patches. Or you want a process 
> running on node 1 to be split to nodes 2 and 3. You want 1G to be moved to 
> node 2 and the rest to node 3. Cannot be done with the old page migration.

Ok, let's review it slowly. Why would you want to move 1GB
of a existing process and another GB to different nodes?  

There are two goals: either best memory latency (local memory) or best 
memory bandwidth (interleaved memory).   

Considering you want to optimize for latency: 
- It doesn't make sense here because your external agent doesn't know 
which thread is using the first GB and which thread is using the last 2GBs.
Most likely they use malloc and everything is pretty much mixed up.
That is information only the code knows or the kernel indirectly from its 
first touch policy. But you need it otherwise you violate local 
memory policy for one thread or another. 

In short blocks of memory are useless here because they have no 
relationship to what the code actually does. 

If you want to optimize for bandwidth: 

- Similar problem applies.  First GB and last GB of memory has no
relationship to how the memory is interleaved.

So it doesn't make much sense to work on smaller pieces 
than processes here. Files are corner cases, but they can
be already handled with some existing patches to mbind.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
