Date: Tue, 11 Apr 2006 11:21:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for misplaced
 page
In-Reply-To: <1144441382.5198.40.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
 <1144441382.5198.40.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 7 Apr 2006, Lee Schermerhorn wrote:

> This patch provides a new function to test whether a page resides
> on a node that is appropriate for the mempolicy for the vma and
> address where the page is supposed to be mapped.  This involves
> looking up the node where the page belongs.  So, the function
> returns that node so that it may be used to allocated the page
> without consulting the policy again.  Because interleaved and
> non-interleaved allocations are accounted differently, the function
> also returns whether or not the new node came from an interleaved
> policy, if the page is misplaced.

The misplaced page function should not consider the vma policy if the page 
is mapped because the VM does not handle vma policies for file 
mapped pages yet. This version may be checking for a policy that would
not be applied to the page for regular allocations.

As I said before: It would be best if memory policy support for file 
mapped vmas would be implemented before opportunistic and lazy migration 
went in. Otherwise we will need a lot of exceptions to even implement
the opportunistic migration in a clean way.

> Note that for "process interleaving" the destination node depends
> on the order of access to pages.  I.e., there is no fixed layout
> for process interleaved pages, as there is for pages interleaved
> via vma policy.  So, as long as the page resides on a node that
> exists in the process's interleave set, no migration is indicated.
> Having said that, we may never need to call this function without
> a vma, so maybe we can lose that "feature".

This would radically change if the file backed pages would be allocated 
properly allocated according to vma policy. Then almost all pages would 
have a proper node for interleave and the node could be calculated based 
on the address. Opportunistic migration can destroy carefully laid out 
interleaving of pages. 

Note also that opportunistic migration like this may move a pagecache page 
out of place that is repeated in used by processes that have
completely different allocation policies. It may just happen that the 
processes currently do not map that page.

> +//TODO:  can we call this here, in the fault path [with mmap_sem held?]
> +//       do we want to?  applications and systems that could benefit from
> +//       migrate-on-fault probably want cpusets as well.
> +	cpuset_update_task_memory_state();
> +	pol = get_vma_policy(current, vma, addr);

You need to use the task policy instead of the vma policy if the page is 
file backed because vma policies do not apply in that case.

> +			/*
> +			 * allows binding to multiple nodes.
> +			 * use current page if in zonelist,
> +			 * else select first allowed node
> +			 */
> +			mems = &pol->cpuset_mems_allowed;
> +			zl = pol->v.zonelist;
> +			for (i = 0; zl->zones[i]; i++) {
> +				int nid = zl->zones[i]->zone_pgdat->node_id;
> +
> +				if (nid == curnid)
> +					return 0;
> +
> +				if (polnid < 0 &&
> +//TODO:  is this check necessary?
> +					node_isset(nid, *mems))
> +					polnid = nid;
> +			}
> +			if (polnid >= 0)
> +				break;

Hmm.... Checking for the current node in memory policy? How does this 
interact with cpuset constraints?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
