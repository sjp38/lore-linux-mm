Date: Mon, 23 Jun 2008 14:12:29 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080623191229.GH10062@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com> <Pine.LNX.4.64.0806191441040.25832@blonde.site> <20080623191135.GG10062@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080623191135.GG10062@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ooops, this was a draft I meant to throw away.  Please ignore.

Sorry for the confusion,
Robin

On Mon, Jun 23, 2008 at 02:11:35PM -0500, Robin Holt wrote:
> On Thu, Jun 19, 2008 at 02:49:50PM +0100, Hugh Dickins wrote:
> > On Thu, 19 Jun 2008, Robin Holt wrote:
> > > On Thu, Jun 19, 2008 at 12:09:15PM +0100, Hugh Dickins wrote:
> > > > 
> > > > (I assume Robin is not forking, we do know that causes this kind
> > > > of problem, but he didn't mention any forking so I assume not.)
> > > 
> > > There has been a fork long before this mapping was created.  There was a
> > > hole at this location and the mapping gets established and pages populated
> > > following all ranks of the MPI job getting initialized.
> > 
> > There's usually been a fork somewhen in the past!  That's no problem.
> > 
> > The fork problem comes when someone has done a get_user_pages to break
> > all the COWs, then another thread does a fork which writeprotects and
> > raises page_mapcount, so the next write from userspace breaks COW again
> > and writes to a different page from that which the kernel is holding.
> > 
> > That one kept on coming up, but I've not heard of it again since we
> > added madvise MADV_DONTFORK so apps could exclude such parts of the
> > address space from copy_page_range.
> 
> I think you still have a hole.  Here is what I _think_ I was actually
> running into.  A range of memory was exported with xpmem.  This is on
> a sles10 kernel which has no mmu_notifier equivalent functionality.
> The exporting process has write faulted a range of addresses which
> it plans on using for a functionality validation test which verifies
> its results.
> 
> The address range is then imported by the other MPI ranks (128 ranks
> total) and pages are faulted in.
> 
> At this time, the system comes under severe memory pressure.  The swap
> code makes a swap entry and replaces both process's PTE with the swap
> entry.  XPMEM is holding an extra reference (_count) on the page.
> 
> The imported now faults the page again (either read or write, does not
> matter, merely that it faults first).  After that, the exporter read
> faults the address and then write faults.  The read followed by write
> seems to be the key.  At that point, the _count and _mapcount are both
> elevated to the point where the page will be COW'd.
> 
> To verify that it was _something_ like this, I had inserted a BUG_ON when
> we return from get_user_pages() to verify the _mapcount is 1 or greater
> and the _count is 2 or greater.  Additionally, I walked the process page
> tables at this point and verified pte_write was true.
> 
> I also added a page flag (just a kludge to verify).  When XPMEM exports
> the page, I set the page flag.  In can_share_swap_page, I made the return
> (count == 1) && test_bit(27, &page->flags);
> 
> I clearly messed something up, but it does indicate I am finally in
> the right neighborhood.  The test program completes with success.
> I definitely messed up the clearing of bit 27 because the machine will
> no longer launch new executables after the job completes.  If I reboot,
> I can rerun the job to successful completion again.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
