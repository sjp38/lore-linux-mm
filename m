Message-ID: <416C4EEB.4070804@sgi.com>
Date: Tue, 12 Oct 2004 16:38:51 -0500
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: NUMA: Patch for node based swapping
References: <2OwBD-HV-31@gated-at.bofh.it> <2OwUX-Ua-23@gated-at.bofh.it> <m3llebn20a.fsf@averell.firstfloor.org>
In-Reply-To: <m3llebn20a.fsf@averell.firstfloor.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, clameter@sgi.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch is a bad idea and should not be merged into the mainline.

(1)  On bids for large SGI machines, we often see the requirement that
 > 90% of main memory be allocatable to user programs.  If, as suggested,
one were to set the /proc/sys/vm/node_swap to 10%, then any allocation
(e. g. alloction of a page cache page) will kick off kswapd when the
customer has allocated > 90% of storage.  The result is that kswapd will be
more or less constantly running on every node in the system.  Since that
same 90% requirement is often used to size the amount of memory purchased
to run the customers primary application, we have a recipe for providing
poor performance for that principle application.  Aa a result we will
likely end up disabling this feature on those large SGI machines, were it
to end up in one of our kernels.

Setting the node_swap limit to less than 10% would keep this from happening,
of course, but in this case the improvement gained is marginal and likely
not worth the effort.

(2)  In HPC applications, it is not sufficient to get "mostly" local storage.
Quite often such applications "settle in" on a set of nodes and sit there and
compute for an extremely long time.  Any imbalance in execution times between
the threads of such an application (e. g. due to one thread having one or more
pages located on a remote node) results in the entire application being slowed
down (A parallel application often runs only as quickly as its slowest thread.)

The application people running benchmarks for our systems insist on getting
100% of the storage they request as local to be truly backed by local storage.
Getting 98% of that figure is not acceptable.  Because this patch kicks off
kswapd asynchronously from the storage request, the current page being
allocated can still end up being allocated off node.  If one tries to solve 
this problem by setting the threshold lower (say at 20% of main memory), then
when the benchmark allocates 90% of memory we end up back in a situation
described above where any storage allocation will cause kswapd to run.
(Remember that even in an idle system, Linux is constantly scribbling stuff
out to disk -- so there are always allocations going on via way of 
__alloc_pages()>) Even then there is no guarentee that kswapd will be able to 
free up storage quickly enough to keep ahead of allocations.  (The real 
problem, here, of course is that clean page cache pages can fill up the node, 
and cause off node allocations to occur; and we would like to free those instead.)

I have patches that I am currently working on to do the latter instead of
the approach of this patch, and once we get those working I'd prefer to
see those included in the mainline instead of this solution.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
