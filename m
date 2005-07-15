Date: Fri, 15 Jul 2005 16:56:34 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715234402.GN15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
References: <20050715211210.GI15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
 <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Andi Kleen wrote:

> > If you encounter different situation then you may need different address 
> > translation. F.e. lets say you want to move a process from node 3 and 4 to 
> > node 5. That wont work with the existing patches. Or you want a process 
> > running on node 1 to be split to nodes 2 and 3. You want 1G to be moved to 
> > node 2 and the rest to node 3. Cannot be done with the old page migration.
> 
> Ok, let's review it slowly. Why would you want to move 1GB
> of a existing process and another GB to different nodes?  
 
Many reasons: One is to optimize access: Interleave. Or there just happens
to be space on these nodes and one needs the space on this node for 
something else.

> Considering you want to optimize for latency: 
> - It doesn't make sense here because your external agent doesn't know 
> which thread is using the first GB and which thread is using the last 2GBs.
> Most likely they use malloc and everything is pretty much mixed up.
> That is information only the code knows or the kernel indirectly from its 
> first touch policy. But you need it otherwise you violate local 
> memory policy for one thread or another. 
> 
> In short blocks of memory are useless here because they have no 
> relationship to what the code actually does. 
> 
> If you want to optimize for bandwidth: 
> 
> - Similar problem applies.  First GB and last GB of memory has no
> relationship to how the memory is interleaved.
> 
> So it doesn't make much sense to work on smaller pieces 
> than processes here. Files are corner cases, but they can
> be already handled with some existing patches to mbind.

You are prescribing now how things have to be done. This is not manual 
page migration anymore. Manual page migration would allow control over 
memory locations of a process.

Lets say I want neither of the above. I just need to run a process on a 
certain node because there is disk storage attached to that node and the 
other processes need to get out of the way for the next 30 minutes.

One always needs control over what is migrated. Ideally one would be able 
to specify that only the vma containing the huge amount of sparsely 
accessed data is to be migrated if memory becomes tight but the process 
continues to run on the same node. The stack and text segments and 
libraries should stay on the node.

On the other hand if the process is migrated to another one node by 
the scheduler then one may want to migrate the text segment and the 
stack but leave the 6G vma containing data vma where it originally was.

It all boils down to the following:

Are you willing to allow us to control memory placement? Or will it be 
automatically? If automatically then maybe you need to get rid of libnuma 
and numactl and put it all in the scheduler. Otherwise please full control 
and not some half-way measures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
