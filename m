Subject: Re: [patch 00/19] VM pageout scalability improvements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080102224144.885671949@redhat.com>
References: <20080102224144.885671949@redhat.com>
Content-Type: text/plain
Date: Thu, 03 Jan 2008 11:52:08 -0500
Message-Id: <1199379128.5295.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-01-02 at 17:41 -0500, linux-kernel@vger.kernelporg wrote:
> On large memory systems, the VM can spend way too much time scanning
> through pages that it cannot (or should not) evict from memory. Not
> only does it use up CPU time, but it also provokes lock contention
> and can leave large systems under memory presure in a catatonic state.
> 
> Against 2.6.24-rc6-mm1
> 
> This patch series improves VM scalability by:
> 
> 1) making the locking a little more scalable
> 
> 2) putting filesystem backed, swap backed and non-reclaimable pages
>    onto their own LRUs, so the system only scans the pages that it
>    can/should evict from memory
> 
> 3) switching to SEQ replacement for the anonymous LRUs, so the
>    number of pages that need to be scanned when the system
>    starts swapping is bound to a reasonable number
> 
> The noreclaim patches come verbatim from Lee Schermerhorn and
> Nick Piggin.  I have made a few small fixes to them and left out
> the bits that are no longer needed with split file/anon lists.
> 
> The exception is "Scan noreclaim list for reclaimable pages",
> which should not be needed but could be a useful debugging tool.

Note that patch 14/19 [SHM_LOCK/UNLOCK handling] depends on the
infrastructure introduced by the "Scan noreclaim list for reclaimable
pages" patch.  When SHM_UNLOCKing a shm segment, we call a new
scan_mapping_noreclaim_page() function to check all of the pages in the
segment for reclaimability.  There might be other reasons for the pages
to be non-reclaimable...

So, we can't merge 14/19 as is w/o some of patch 12.  We can probably
eliminate the sysctl and per node sysfs attributes to force a scan.
But, as Rik says, this has been useful for debugging--e.g., periodically
forcing a full rescan while running a stress load.

Also, I should point out that the full noreclaim series includes a
couple of other patches NOT posted here by Rik:

1) treat swap backed pages as nonreclaimable when no swap space is
available.  This addresses a problem we've seen in real life, with
vmscan spending a lot of time trying to reclaim anon/shmem/tmpfs/...
pages only to find that there is no swap space--add_to_swap() fails.
Maybe not a problem with Rik's new anon page handling.  We'll see.  If
we did want to add this filter, we'll need a way to bring back pages
from the noreclaim list that are there only for lack of swap space when
space is added or becomes available.

2) treat anon pages with "excessively long" anon_vma lists as
nonreclaimable.   "excessively long" here is a sysctl tunable parameter.
This also addresses problems we've seen with benchmarks and stress
tests--all cpus spinning on some anon_vma lock.  In "real life", we've
seen this behavior with file backed pages--spinning on the
i_mmap_lock--running Oracle workloads with user counts in the few
thousands.  Again, something we may not need with Rik's vmscan rework.
If we did want to do this, we'd probably want to address file backed
pages and add support to bring the pages back from the noreclaim list
when the number of "mappers" drops below the threshold.  My current
patch leaves anon pages as non-reclaimable until they're freed, or
manually scanned via the mechanism introduced by patch 12.

Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
