Date: Fri, 14 Jan 2005 23:51:59 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050114225159.GO8709@dualathlon.random>
References: <20050114213207.GK8709@dualathlon.random> <20050114222210.51725.qmail@web14324.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050114222210.51725.qmail@web14324.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Hugh Dickins <hugh@veritas.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2005 at 02:22:10PM -0800, Kanoj Sarcar wrote:
> handled. No? (Btw, I did not look at i_size_write() in
> the case of !CONFIG_SMP and CONFIG_PREEMPT, there
> might need to be some barriers put in there, not
> sure).

i_size_write is inode->i_size = i_size in common code terms, that's the
64bit case, and it's the one with the weaker semantics (in turn it's the
only one we can consider in terms of common code correctness). So it has
no barriers at all (nor cpu barriers, nor compiler barriers).

> But, based on what you said, yes, I believe an
> smp_wmb() is required _after_
> atomic_inc(truncate_count) in unmap_mapping_range() to
> ensure that the write happens before  it does the TLB
> shootdown. Right?

The smp_wmb() I mean should be put _before_ the truncate_count incrase.
It is mean to avoid the i_size_write to pass the truncate_count
increase (which can happen with spin_lock having inclusive semantics).

The order we must enforce at the cpu level to be correct is this: first
we set i_size, then we increase truncate_count to restart the page
fault, and finally we zap the ptes (and the zap starts by reading the
old contents set by the page fault). And it must be enforced with cpu
and compiler memory barries.

It seems you're right that we need an additional smp_mb() (not just
smp_wmb(), because the pte shootdown does reads first) even after the
truncate_count increase, but I thought the locking inside
unmap_mapping_range_list would avoid us to do that, sounds like it's not
the case.

I can only see the page_table_lock in there, so in theory the
truncate_write could enter the page_table_lock critical section on ia64.

So I guess we need both an explicit smp_wmb() before atomic_inc (to
serialize with i_size_write on ia64 which is 64bit and doesn't have any
implcit locking there) and smp_mb() after atomic_inc to fix this on ia64
too. But it really should be a smp_mb__after_atomic_inc kind of thing,
or we'll bite on x86 performance (in theory even the smp_wmb should be a
smp_wmb__before_atomic_inc, though smp_wmb is zerocost on x86 so it has
less impact ... ;).

As said in practice x86 and x86-64 are already rock solid with 2.6.10,
because atomic_add is an implicit smp_mb() before and after the
atomic_inc there.

> I am sure there might be other ways to clean up this
> code. Some documentation could not hurt, it could save
> everyone's head hurting when they look at this code!

Indeed.

> Btw, do all callers of vmtruncate() guarantee they do
> not concurrently invoke vmtruncate() on the same file?
> Seems like they could be stepping on each other while
> updating i_size ...

i_sem for that (and i_truncate_sem in 2.4), no problem.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
