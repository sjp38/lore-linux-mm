Date: Sat, 16 Jul 2005 18:55:13 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050716163030.0147b6ba.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0507161842090.26674@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
 <20050716020141.GO15783@wotan.suse.de> <20050716163030.0147b6ba.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Paul Jackson wrote:

> On the other hand, I hear him saying we can't do it, because the
> locking cannot be safely handled.

That should have been brought up earlier because the page migration 
patches by Ray always modified the policy and Andi agreed to that.

We can certainly find a way to provide proper locking for policy changes 
if there are concerns. The most trivial would to require atomic 
modifications via cmpxchg.

However, there is a fundamental issue with the application and the one who 
manages the process from the outside making changed to the policy.
 
Currently only the application can make these changes which avoids locking
issues but also restricts the usefulness of these policies since they then
cannot be used from the outside to manage the memory allocation behavior
of a process. 

If both are making changes then the outside controller may find that 
memory allocation policy suddenly changes and an application already using
libnuma may experience unexpected changes in memory policy. However, 
libnuma/numactl is used when memory areas are setup to define how the 
system should treat these memory areas. The outside management always
works with the settings already established by the application and 
modifies those. So in practice there will be little change of 
interference.

> There is also one confusion that I sometimes succumb to, reading these
> replies - between memory policies to control future allocations and
> memory policies to relocate already allocated memory.
> 
> I think between the numa calls (mbind, set_mempolicy) and cpusets,
> we have a decent array of mechanisms to control future allocations.
> The full set of features required may not be complete, but the
> framework seems to be in place, and the majority of what features we
> will need are supported now.

Correct. We could implement the changing of policies via an extension of 
the existing libnuma. That could be easily done as far as I can tell. If 
that is done then the patch that I proposed is no longer necessary. But 
then libnuma needs to also be extended to

1. Allow the discovery of the memory policies of each vma for each process 
in a system. Otherwise intelligent decisions about page migration cannot 
be made and we end up with the kernel guessing which vma's to migrate and 
we cannot control migration of the text segments separately from the data 
segment etc.

2. Add a function call to migrate pages in a particular vma to another 
node. I.e.

sys_page_migrate(pid, address, from-node, to_node, nr-pages)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
