Subject: Re: [PATCH take3] Memoryless nodes:  use "node_memory_map" for
	cpuset mems_allowed validation
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070727004041.GP18510@us.ibm.com>
References: <20070711182219.234782227@sgi.com>
	 <20070711182250.005856256@sgi.com>
	 <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com>
	 <1185309019.5649.69.camel@localhost>  <20070727004041.GP18510@us.ibm.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 10:15:35 -0400
Message-Id: <1185545735.5069.7.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-26 at 17:40 -0700, Nishanth Aravamudan wrote:
> On 24.07.2007 [16:30:19 -0400], Lee Schermerhorn wrote:
> > Memoryless Nodes:  use "node_memory_map" for cpusets - take 3
> > 
> > Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
> > series
> > 
> > take 2:
> > + replaced node_online_map in cpuset_current_mems_allowed()
> >   with node_states[N_MEMORY]
> > + replaced node_online_map in cpuset_init_smp() with
> >   node_states[N_MEMORY]
> > 
> > take 3:
> > + fix up comments and top level cpuset tracking of nodes
> >   with memory [instead of on-line nodes].
> > + maybe I got them all this time?
> > 
> > cpusets try to ensure that any node added to a cpuset's 
> > mems_allowed is on-line and contains memory.  The assumption
> > was that online nodes contained memory.  Thus, it is possible
> > to add memoryless nodes to a cpuset and then add tasks to this
> > cpuset.  This results in continuous series of oom-kill and
> > apparent system hang.
> > 
> > Change cpusets to use node_states[N_MEMORY] [a.k.a.
> > node_memory_map] in place of node_online_map when vetting 
> > memories.  Return error if admin attempts to write a non-empty
> > mems_allowed node mask containing only memoryless-nodes.
> > 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  include/linux/cpuset.h |    2 -
> >  kernel/cpuset.c        |   51 +++++++++++++++++++++++++++++++------------------
> >  2 files changed, 34 insertions(+), 19 deletions(-)
> 
> Small typo fix which prevents build with !CPUSETS.
> 
> ---
> FYI: I noticed that oldconfig on 2.6.23-rc1-mm1 with CPUSETS=y disables
> CPUSETS because of the introduction of CONFIG_CONTAINERS :(
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index f8f4f68..d01b1bc 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -92,7 +92,7 @@ static inline nodemask_t cpuset_mems_allowed(struct task_struct *p)
>  	return node_possible_map;
>  }
>  
> -#define cpuset_current_mems_allowed (node_states[N_MEMORY))
> +#define cpuset_current_mems_allowed (node_states[N_MEMORY])
>  static inline void cpuset_init_current_mems_allowed(void) {}
>  static inline void cpuset_update_task_memory_state(void) {}
>  #define cpuset_nodes_subset_current_mems_allowed(nodes) (1)
> 

Thanks, Nish.  Bob Picco pointed that out to me and I've fixed it in
take4.  Bob is reviewing the patches and should get back to me today if
he has any issues.  I've tested the current patches against 23-rc1-mm1
overnight on the following config and it held up fine.

Configuration:  100% cell local memory, boot with mem=16g [out of 32G
available].  Gave me one memoryless node, and one very small node:

available: 5 nodes (0-4)
node 0 size: 7600 MB
node 0 free: 6647 MB
node 1 size: 8127 MB
node 1 free: 7675 MB
node 2 size: 144 MB
node 2 free: 94 MB
node 3 size: 0 MB
node 3 free: 0 MB
node 4 size: 511 MB
node 4 free: 494 MB

Ran test exerciser [custom workload in Dave Anderson's "usex" program]
in a cpuset containing cpus and memory from nodes 1-3].  Not a lot of
mempolicy testing, but fairly stressful, otherwise.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
