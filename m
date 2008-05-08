Date: Fri, 9 May 2008 00:01:06 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508220106.GF2964@duo.random>
References: <20080507233953.GM8276@duo.random> <alpine.LFD.1.10.0805071757520.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071809170.14935@schroedinger.engr.sgi.com> <20080508025652.GW8276@duo.random> <Pine.LNX.4.64.0805072009230.15543@schroedinger.engr.sgi.com> <20080508034133.GY8276@duo.random> <alpine.LFD.1.10.0805072109430.3024@woody.linux-foundation.org> <20080508052019.GA8276@duo.random> <alpine.LFD.1.10.0805080759430.3024@woody.linux-foundation.org> <alpine.LFD.1.10.0805080907420.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805080907420.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2008 at 09:11:33AM -0700, Linus Torvalds wrote:
> Btw, this is an issue only on 32-bit x86, because on 64-bit one we already 
> have the padding due to the alignment of the 64-bit pointers in the 
> list_head (so there's already empty space there).
> 
> On 32-bit, the alignment of list-head is obviously just 32 bits, so right 
> now the structure is "perfectly packed" and doesn't have any empty space. 
> But that's just because the spinlock is unnecessarily big.
> 
> (Of course, if anybody really uses NR_CPUS >= 256 on 32-bit x86, then the 
> structure really will grow. That's a very odd configuration, though, and 
> not one I feel we really need to care about).

I see two ways to implement it:

1) use #ifdef and make it zero overhead for 64bit only without playing
any non obvious trick.

struct anon_vma {
       spinlock_t lock;
#ifdef CONFIG_MMU_NOTIFIER
       int global_mm_lock:1;
#endif

struct address_space {
       spinlock_t	private_lock;
#ifdef CONFIG_MMU_NOTIFIER
       int global_mm_lock:1;
#endif

2) add a:

#define AS_GLOBAL_MM_LOCK   (__GFP_BITS_SHIFT + 2)	/* global_mm_locked */

and use address_space->flags with bitops

And as Andrew pointed me out by PM, for the anon_vma we can use the
LSB of the list.next/prev because the list can't be browsed when the
lock is taken, so taking the lock and then setting the bit and
clearing the bit before unlocking is safe. The LSB will always read 0
even if it's under list_add modification when the global spinlock isn't
taken. And after taking the anon_vma lock we can switch it the LSB
from 0 to 1 without races and the 1 will be protected by the
global spinlock.

The above solution is zero cost for 32bit too, so I prefer it.

So I now agree with you this is a great idea on how to remove sort()
and vmalloc and especially vfree without increasing the VM footprint.

I'll send an update with this for review very shortly and I hope this
goes in so KVM will be able to swap and do many other things very well
starting in 2.6.26.

Thanks a lot,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
