Date: Fri, 15 Jul 2005 15:49:33 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050715223756.GL15783@wotan.suse.de>
Message-ID: <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507142152400.2139@schroedinger.engr.sgi.com>
 <20050714230501.4a9df11e.pj@sgi.com> <Pine.LNX.4.62.0507150901500.8556@schroedinger.engr.sgi.com>
 <20050715140437.7399921f.pj@sgi.com> <20050715211210.GI15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151413360.11563@schroedinger.engr.sgi.com>
 <20050715214700.GJ15783@wotan.suse.de> <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Andi Kleen wrote:

> > 1. Updating the memory policy is something that can be useful in other 
> >    settings as well so it need to be separate. The patch we are discussing
> 
> Not for external processes except in the narrow special case
> of migrating everything. External processes shouldn' t
> know about virtual addresses of other people.

Updating the memory policy is also useful if memory on one node gets 
short and you want to redirct allocations to a node that has memory free. 

A batch scheduler may anticipate memory shortages and redirect memory 
allocations in order to avoid page migration.

> > 3. Memory policy translations better be done in user space. The batch
> >    scheduler /sysadmin knows which node has what pages so it can easily 
> >    develop page movement scheme that is optimal for the process.
> 
> I don't think the existing policies are complex enough to make
> this useful. The mapping for page migration for all of 
> them is quite straight forward.

I'd rather have that logic in userspace rather than fix up page_migrate 
again and again and again. Automatic recalculation of memory policies is 
likely an unexpected side effect of the existing page migration code. 

Policies should only change with explicit instructions from user space and 
not as a side effect of page migration.

And curiously with the old page migration code: The only way to change the 
a memory policy is by page migration and this is automatically behind your 
back.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
