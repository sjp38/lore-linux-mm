Date: Wed, 9 Mar 2005 11:09:15 -0600
From: Robin Holt <holt@sgi.com>
Subject: ia64 needs to shake memory from quicklists when there is memory pressure.
Message-ID: <20050309170915.GA1583@lnx-holt.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

I am searching for some direction.  I am in the process of pushing
changes to the ia64 page table cache (quicklist) code.  One result of
the changes is I end up changing the algorithm for freeing pages from
the quicklist being based on a boot-time calculation of a percentage of
total system memory to a percentage of memory free on the node (whole
system for non-numa) at the time the shrink call is made.

Right now, there are two places that the shrink is invoked.  One is
from the tlb_finish_mmu() code which would be immediately after the only
place that items are added to the list.  The other is from cpu_idle which
appears to be a carry over from when x86 code was pulled over to ia64.
The purpose for that appears to have been making the sysctl (which has
been removed) take effect in situations where a cpu is never calling
tlb_finish_mmu().

The "ideal" would be to have a node aware slab cache.  Since that
is probably a long time coming, I was wondering if there would be
any possibility of getting some sort of hook into wakeup_kswapd(),
kswapd(), or balance_pgdat().  Since the quicklists are maintained per
cpu, we would need to perform an smp_call_function_single() for other
cpus on this node.  Is there some mechanism in place already to handle
anything similar to this?  Is there a better way to accomplish this?
Can you offer any suggestions?

Thanks,
Robin Holt

PS:  Some relevant links.
Discuss the shrink issues:
http://marc.theaimsgroup.com/?l=linux-ia64&m=110990848315823&w=2

The code change to do the free.
http://marc.theaimsgroup.com/?l=linux-ia64&m=110978917715909&w=2
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
