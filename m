Date: Mon, 14 Mar 2005 10:40:51 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: ia64 needs to shake memory from quicklists when there is memory pressure.
Message-ID: <20050314164051.GB9117@lnx-holt.americas.sgi.com>
References: <20050309170915.GA1583@lnx-holt.americas.sgi.com> <20050309113227.3501fb76.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050309113227.3501fb76.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Robin Holt <holt@sgi.com>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 09, 2005 at 11:32:27AM -0800, Andrew Morton wrote:
> Robin Holt <holt@sgi.com> wrote:
> >
> > Andrew,
> > 
> > I am searching for some direction.  I am in the process of pushing
> > changes to the ia64 page table cache (quicklist) code.  One result of
> > the changes is I end up changing the algorithm for freeing pages from
> > the quicklist being based on a boot-time calculation of a percentage of
> > total system memory to a percentage of memory free on the node (whole
> > system for non-numa) at the time the shrink call is made.
> > 
> > Right now, there are two places that the shrink is invoked.  One is
> > from the tlb_finish_mmu() code which would be immediately after the only
> > place that items are added to the list.  The other is from cpu_idle which
> > appears to be a carry over from when x86 code was pulled over to ia64.
> > The purpose for that appears to have been making the sysctl (which has
> > been removed) take effect in situations where a cpu is never calling
> > tlb_finish_mmu().
> > 
> > The "ideal" would be to have a node aware slab cache.  Since that
> > is probably a long time coming, I was wondering if there would be
> > any possibility of getting some sort of hook into wakeup_kswapd(),
> > kswapd(), or balance_pgdat().  Since the quicklists are maintained per
> > cpu, we would need to perform an smp_call_function_single() for other
> > cpus on this node.  Is there some mechanism in place already to handle
> > anything similar to this?  Is there a better way to accomplish this?
> > Can you offer any suggestions?
> > 
> 
> Suggest you hook into the existing set_shrinker() API.
> 
> Then, in the shrinker callback, perform reclaim of the calling CPU's
> node's pages.
> 
> Try to return the right numbers from the shrinker callback so that
> shrink_slab() will keep this cache balanced wrt all the other ones which it
> is managing.

I wedged a shrinker in which simply does a smp_call_function() to invoke
the cache shrinker.  I did modify the shrinker function to return the
number of pages freed, but am currently doing nothing with it as this
will require a spinlock/atomic operation and am not ready to take that
performance hit.  The one issue I have is we lose information about
which nodes to shake memory from and therefore end up calling the function
for every node in the system.  This appears very heavy handed.

I put this kernel on a machine and ran over the weekend with no issues.
Unfortunately, I do not have any test loads which are really causing much
flushing.  Most of the tests result in adequate calls to tlb_finish_mmu()
to keep the page tables in check.  Over the weekend, there were only 4
times when the smp_call_function() returned any pages and that turned out
to be only 16 pages from each call.  I can not give you percentages,
because the int counter I was using appears to have overflowed.

I am really not convinced this is a problem which needs to be fixed.
The code was written this way for i386, carried to ia64, and operated in
both environments without issue for that length of time.  The callout
from cpu_idle() was essentially a freebie and provided a means for the
sysctl to take effect.


Thanks
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
