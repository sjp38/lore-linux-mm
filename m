Subject: Re: [PATCH 2.6.17-rc1-mm1 2/6] Migrate-on-fault - check for
	misplaced page
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <1144441382.5198.40.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111109370.878@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 15:28:06 -0400
Message-Id: <1144783687.5160.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-11 at 11:21 -0700, Christoph Lameter wrote:
> On Fri, 7 Apr 2006, Lee Schermerhorn wrote:
> 
> > This patch provides a new function to test whether a page resides
> > on a node that is appropriate for the mempolicy for the vma and
> > address where the page is supposed to be mapped.  This involves
> > looking up the node where the page belongs.  So, the function
> > returns that node so that it may be used to allocated the page
> > without consulting the policy again.  Because interleaved and
> > non-interleaved allocations are accounted differently, the function
> > also returns whether or not the new node came from an interleaved
> > policy, if the page is misplaced.
> 
> The misplaced page function should not consider the vma policy if the page 
> is mapped because the VM does not handle vma policies for file 
> mapped pages yet. This version may be checking for a policy that would
> not be applied to the page for regular allocations.

When you say "mapped" here, you mean a mmap()ed file?  As opposed to
"mapped by a pte" such that page_mapcount(page) != 0, right?  Because if
the mapcount() isn't zero, we won't even look for misplaced pages.  And,
with the V0.2 series, I'm only checking for misplaced pages with
mapcount == 0 in the anon page fault path.  If necessary, I can skip
pages in VMAs that have non-NULL vm_file.  Do we get these in the anon
fault path?

> 
> As I said before: It would be best if memory policy support for file 
> mapped vmas would be implemented before opportunistic and lazy migration 
> went in. Otherwise we will need a lot of exceptions to even implement
> the opportunistic migration in a clean way.

OK.  I won't hook up migrate-on-fault to the file mapped fault path
until this is done.  I'm still not clear on what you have in mind for
policies on file mapped vmas.  Do you want to attach the policies to the
file/inode itself [like for shared memory segments], so that they apply
to all mappers?  

> 
> > Note that for "process interleaving" the destination node depends
> > on the order of access to pages.  I.e., there is no fixed layout
> > for process interleaved pages, as there is for pages interleaved
> > via vma policy.  So, as long as the page resides on a node that
> > exists in the process's interleave set, no migration is indicated.
> > Having said that, we may never need to call this function without
> > a vma, so maybe we can lose that "feature".
> 
> This would radically change if the file backed pages would be allocated 
> properly allocated according to vma policy. Then almost all pages would 
> have a proper node for interleave and the node could be calculated based 
> on the address. Opportunistic migration can destroy carefully laid out 
> interleaving of pages. 

I agree, I think...  However, if the policies are attached directly to
the file itself [I mean the in-memory incarnation in the form of
file/inode structs--not the on disk info], then I don't see why
"migrate-on-fault", opportunistic or otherwise, would do anything
different from normal allocation.  I mean, my intention is that migrate-
on-fault move page [with zero map count] that don't reside where initial
allocation under the current policy would place them.  Thus, I want to
avoid policies, or interpretations of policies, that give different
answers each time you evaluate them.

> 
> Note also that opportunistic migration like this may move a pagecache page 
> out of place that is repeated in used by processes that have
> completely different allocation policies. It may just happen that the 
> processes currently do not map that page.

Do you mean with my current implementation, if I hooked up that fault
path?  Or do you mean when/if file back pages are "properly allocated
according to vma [???] policy"?  Are you're suggesting that proper
behavior is for each mapping process to have a different policy on the
file [in the vma] and whoever brings it into memory gets to choose where
it lands?  In that case, then yes, migrate-on-fault could move the page
if it finds it in the cache with mapcount==0 and misplaced according to
the policy of the faulting task's vma mapping the file.   If, however,
the policies are attached to the underlying file/inode struct, then any
task faulting a page for that file will see the same policy.  If it uses
the file offset to compute interleaving, then it should get the same
answer from any task.  This is how I've seen it implemented in other
systems and so had the "least astonishment" for me.  Others may see it
differently.

> 
> > +//TODO:  can we call this here, in the fault path [with mmap_sem held?]
> > +//       do we want to?  applications and systems that could benefit from
> > +//       migrate-on-fault probably want cpusets as well.
> > +	cpuset_update_task_memory_state();
> > +	pol = get_vma_policy(current, vma, addr);
> 
> You need to use the task policy instead of the vma policy if the page is 
> file backed because vma policies do not apply in that case.

OK, but again, I haven't hooked up migrate-on-fault for file backed
pages yet.  Here, you're saying that if I DID hook it up before fixing
how file back pages are handled, then to be consistent with current
behavior, I should use task policy for file back pages?

How about shmem backed pages?

> 
> > +			/*
> > +			 * allows binding to multiple nodes.
> > +			 * use current page if in zonelist,
> > +			 * else select first allowed node
> > +			 */
> > +			mems = &pol->cpuset_mems_allowed;
> > +			zl = pol->v.zonelist;
> > +			for (i = 0; zl->zones[i]; i++) {
> > +				int nid = zl->zones[i]->zone_pgdat->node_id;
> > +
> > +				if (nid == curnid)
> > +					return 0;
> > +
> > +				if (polnid < 0 &&
> > +//TODO:  is this check necessary?
> > +					node_isset(nid, *mems))
> > +					polnid = nid;
> > +			}
> > +			if (polnid >= 0)
> > +				break;
> 
> Hmm.... Checking for the current node in memory policy? How does this 
> interact with cpuset constraints?

That's why I asked if it's necessary.  If I call
cpuset_update_task_memory_state() above, I think that it rebinds the
tasks policies so that the zone lists have only valid mems.  Having
found a node in the zonelist, do I need to check it again?  I think I
was TRYING to honor the cpuset contraints.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
