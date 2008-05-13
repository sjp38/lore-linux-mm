Date: Tue, 13 May 2008 10:32:38 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080513153238.GL19717@sgi.com>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080508003838.GA9878@sgi.com> <200805132206.47655.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200805132206.47655.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <andrea@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 10:06:44PM +1000, Nick Piggin wrote:
> On Thursday 08 May 2008 10:38, Robin Holt wrote:
> > In order to invalidate the remote page table entries, we need to message
> > (uses XPC) to the remote side.  The remote side needs to acquire the
> > importing process's mmap_sem and call zap_page_range().  Between the
> > messaging and the acquiring a sleeping lock, I would argue this will
> > require sleeping locks in the path prior to the mmu_notifier invalidate_*
> > callouts().
> 
> Why do you need to take mmap_sem in order to shoot down pagetables of
> the process? It would be nice if this can just be done without
> sleeping.

We are trying to shoot down page tables of a different process running
on a different instance of Linux running on Numa-link connected portions
of the same machine.

The messaging is clearly going to require sleeping.  Are you suggesting
we need to rework XPC communications to not require sleeping?  I think
that is going to be impossible since the transfer engine requires a
sleeping context.

Additionally, the call to zap_page_range expects to have the mmap_sem
held.  I suppose we could use something other than zap_page_range and
atomically clear the process page tables.  Doing that will not alleviate
the need to sleep for the messaging to the other partitions.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
