Subject: Re: [patch 1/6] mmu_notifier: Core code
References: <20080215064859.384203497@sgi.com>
	<20080215064932.371510599@sgi.com>
From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 18 Feb 2008 14:33:32 -0800
In-Reply-To: <20080215064932.371510599@sgi.com> (Christoph Lameter's message of "Thu, 14 Feb 2008 22:49:00 -0800")
Message-ID: <adawsp1hp37.fsf@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

It seems that we've come up with two reasonable cases where it makes
sense to use these notifiers for InfiniBand/RDMA:

First, the ability to safely to DMA to/from userspace memory with the
memory regions mlock()ed but the pages not pinned.  In this case the
notifiers here would seem to suit us well:

 > +	void (*invalidate_range_begin)(struct mmu_notifier *mn,
 > +				 struct mm_struct *mm,
 > +				 unsigned long start, unsigned long end,
 > +				 int atomic);
 > +
 > +	void (*invalidate_range_end)(struct mmu_notifier *mn,
 > +				 struct mm_struct *mm,
 > +				 unsigned long start, unsigned long end,
 > +				 int atomic);

If I understand correctly, the IB stack would have to get the hardware
driver to shoot down translation entries and suspend access to the
region when an invalidate_range_begin notifier is called, and wait for
the invalidate_range_end notifier to repopulate the adapter
translation tables.  This will probably work OK as long as the
interval between the invalidate_range_begin and invalidate_range_end
calls is not "too long."

Also, using this effectively requires us to figure out how we want to
mlock() regions that are going to be used for RDMA.  We could require
userspace to do it, but it's not clear to me that we're safe in the
case where userspace decides not to... what happens if some pages get
swapped out after the invalidate_range_begin notifier?

The second case where some form of notifiers are useful is for
userspace to know when a memory registration is still valid, ie Pete
Wyckoff's work:

    http://www.osc.edu/~pw/papers/wyckoff-memreg-ccgrid05.pdf
    http://www.osc.edu/~pw/dreg/

however these MMU notifiers seem orthogonal to that: the registration
cache is concerned with address spaces, not page mapping, and hence
the existing vma operations seem to be a better fit.

 - R.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
