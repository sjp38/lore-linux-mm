Date: Fri, 15 Jul 2005 16:11:00 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715225635.GM15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
 <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
 <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Andi Kleen wrote:

> > Updating the memory policy is also useful if memory on one node gets 
> > short and you want to redirct allocations to a node that has memory free. 
> 
> If you use MEMBIND just specify all the nodes upfront and it'll
> do the normal fallback in them. 
> 
> If you use PREFERED it'll do that automatically anyways.

No it wont. If you know that you are going to start a process that must 
run on node 3 and know its going to use 2G but there is only 1G free 
then you may want to modify the policy of an existing huge process on 
node 3that is still allocating to go to node 2 that just happens to have 
free space.

> > A batch scheduler may anticipate memory shortages and redirect memory 
> > allocations in order to avoid page migration.
> I think that jobs more belongs to the kernel. After all we don't
> want to move half of our VM into your proprietary scheduler.

Care to tell me which proprietary scheduler you are talking about? I was 
not aware the existance of such a thing. I am particularly surprised that 
this proprietary scheduler exists before we have a working interface.

And you are now going to implement automatic page migration into the 
existing scheduler?

> > I'd rather have that logic in userspace rather than fix up page_migrate 
> > again and again and again. Automatic recalculation of memory policies is 
> > likely an unexpected side effect of the existing page migration code. 
> 
> Only if you migrate again and again.

If you encounter different situation then you may need different address 
translation. F.e. lets say you want to move a process from node 3 and 4 to 
node 5. That wont work with the existing patches. Or you want a process 
running on node 1 to be split to nodes 2 and 3. You want 1G to be moved to 
node 2 and the rest to node 3. Cannot be done with the old page migration.

> > Policies should only change with explicit instructions from user space and 
> > not as a side effect of page migration.
> 
> Well, page migration would be a "explicit instruction from user space" 

Existing page migration does not specify a memory policy it just 
translates it. And its inflexible and unable to handle some common 
situations described above.

> > And curiously with the old page migration code: The only way to change the 
> > a memory policy is by page migration and this is automatically behind your 
> > back.
> 
> mbind can change policy at any time. Just only for the local
> process, as that is the the only one who has enough information
> to really do this.

Which makes mbind useless for the sysadmin and/or batch scheduler in the 
scenarios we are discussing. That is the key reason why we need this patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
