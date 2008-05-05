Date: Mon, 5 May 2008 11:21:13 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-ID: <20080505162113.GA18761@sgi.com>
References: <patchbomb.1209740703@duo.random> <1489529e7b53d3f2dab8.1209740704@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489529e7b53d3f2dab8.1209740704@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2008 at 05:05:04PM +0200, Andrea Arcangeli wrote:
> # HG changeset patch
> # User Andrea Arcangeli <andrea@qumranet.com>
> # Date 1209740175 -7200
> # Node ID 1489529e7b53d3f2dab8431372aa4850ec821caa
> # Parent  5026689a3bc323a26d33ad882c34c4c9c9a3ecd8
> mmu-notifier-core
 


I upgraded to the latest mmu notifier patch & hit a deadlock. (Sorry -
I should have seen this  earlier but I haven't tracked the last couple
of patches).

The GRU does the registration/deregistration of mmu notifiers from mmap/munmap.
At this point, the mmap_sem is already held writeable. I hit a deadlock
in mm_lock.

A quick fix would be to do one of the following:

	- move the mmap_sem locking to the caller of the [de]registration routines.
	  Since the first/last thing done in mm_lock/mm_unlock is to
	  acquire/release mmap_sem, this change does not cause major changes.

	- add a flag to mmu_notifier_[un]register routines to indicate
	  if mmap_sem is already locked.


I've temporarily deleted the mm_lock locking of mmap_sem and am continuing to
test. More later....


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
