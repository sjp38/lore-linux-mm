Date: Mon, 23 Jun 2008 10:54:00 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
	pte and _count=2?
Message-ID: <20080623155400.GH10123@sgi.com>
References: <20080618164158.GC10062@sgi.com> <200806190329.30622.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806181944080.4968@blonde.site> <200806191307.04499.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0806191154270.7324@blonde.site> <20080619133809.GC10123@sgi.com> <Pine.LNX.4.64.0806191441040.25832@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806191441040.25832@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 19, 2008 at 02:49:50PM +0100, Hugh Dickins wrote:
> On Thu, 19 Jun 2008, Robin Holt wrote:
> > On Thu, Jun 19, 2008 at 12:09:15PM +0100, Hugh Dickins wrote:
> > > 
> > > (I assume Robin is not forking, we do know that causes this kind
> > > of problem, but he didn't mention any forking so I assume not.)
> > 
> > There has been a fork long before this mapping was created.  There was a
> > hole at this location and the mapping gets established and pages populated
> > following all ranks of the MPI job getting initialized.
> 
> There's usually been a fork somewhen in the past!  That's no problem.
> 
> The fork problem comes when someone has done a get_user_pages to break
> all the COWs, then another thread does a fork which writeprotects and
> raises page_mapcount, so the next write from userspace breaks COW again
> and writes to a different page from that which the kernel is holding.
> 
> That one kept on coming up, but I've not heard of it again since we
> added madvise MADV_DONTFORK so apps could exclude such parts of the
> address space from copy_page_range.

I finally tracked this down.  I think it is a problem specific to XPMEM
on the SLES10 kernel and will not be a problem once Andrea's mmu_notifier
is in the kernel.  It is a problem, as far as I can tell, specific to
the way XPMEM works.

I will open a SuSE bugzilla to work the issue directly with them.

Prior to the transition event, we have a page of memory that was
pre-faulted by a process.  The process has exported (via XPMEM) a
window of its own address space.  A remote process has attached and
touched the page of memory.  The fault will call into XPMEM which does
the get_user_pages.

At this point, both processes have a writable PTE entry to the same
page and XPMEM has one additional reference count (_count) on the page
acquired via get_user_pages().

Memory pressure causes swap_page to get called.  It clears the two
process's page table entries, returns the _count values, etc.  The only
thing that remains different from normal at this point is XPMEM retains
a reference.

Both processes then read-fault the page which results in readable PTEs
being installed.

The failure point comes when either process write faults the page.
At that point, a COW is initiated and now the two processes are looking
at seperate pages.

The scenario would be different in the case of mmu_notifiers.
The notifier callout when the readable PTE was being replaced with a
writable PTE would result in the remote page table getting cleared and
XPMEM releasing the _count.


All that said, I think the race we discussed earlier in the thread is
a legitimate one and believe Hugh's fix is correct.

Thank you for all your patience,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
