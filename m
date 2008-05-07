Date: Thu, 8 May 2008 01:39:53 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080507233953.GM8276@duo.random>
References: <6b384bb988786aa78ef0.1210170958@duo.random> <alpine.LFD.1.10.0805071349200.3024@woody.linux-foundation.org> <20080507212650.GA8276@duo.random> <alpine.LFD.1.10.0805071429170.3024@woody.linux-foundation.org> <20080507222205.GC8276@duo.random> <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080507155914.d7790069.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: clameter@sgi.com, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Wed, May 07, 2008 at 03:59:14PM -0700, Andrew Morton wrote:
> 	CPU0:			CPU1:
> 
> 	spin_lock(global_lock)	
> 	spin_lock(a->lock);	spin_lock(b->lock);
				================== mmu_notifier_register()
> 	spin_lock(b->lock);	spin_unlock(b->lock);
> 				spin_lock(a->lock);
> 				spin_unlock(a->lock);
> 
> also OK.

But the problem is that we've to stop the critical section in the
place I marked with "========" while mmu_notifier_register
runs. Otherwise the driver calling mmu_notifier_register won't know if
it's safe to start establishing secondary sptes/tlbs. If the driver
will establish sptes/tlbs with get_user_pages/follow_page the page
could be freed immediately later when zap_page_range starts.

So if CPU1 doesn't take the global_lock before proceeding in
zap_page_range (inside vmtruncate i_mmap_lock that is represented as
b->lock above) we're in trouble.

What we can do is to replace the mm_lock with a
spin_lock(&global_lock) only if all places that takes i_mmap_lock
takes the global lock first and that hurts scalability of the fast
paths that are performance critical like vmtruncate and
anon_vma->lock. Perhaps they're not so performance critical, but
surely much more performant critical than mmu_notifier_register ;).

The idea of polluting various scalable paths like truncate() syscall
in the VM with a global spinlock frightens me, I'd rather return to
invalidate_page() inside the PT lock removing both
invalidate_range_start/end. Then all serialization against the mmu
notifiers will be provided by the PT lock that the secondary mmu page
fault also has to take in get_user_pages (or follow_page). In any case
that is a better solution that won't slowdown the VM when
MMU_NOTIFIER=y even if it's a bit slower for GRU, for KVM performance
is about the same with or without invalidate_range_start/end. I didn't
think anybody could care about how long mmu_notifier_register takes
until it returns compared to all heavyweight operations that happens
to start a VM (not only in the kernel but in the guest too).

Infact if it's security that we worry about here, can put a cap of
_time_ that mmu_notifier_register can take before it fails, and we
fail to start a VM if it takes more than 5sec, that's still fine as
the failure could happen for other reasons too like vmalloc shortage
and we already handle it just fine. This 5sec delay can't possibly happen in
practice anyway in the only interesting scenario, just like the
vmalloc shortage. This is obviously a superior solution than polluting
the VM with an useless global spinlock that will destroy truncate/AIM
on numa.

Anyway Christoph, I uploaded my last version here:

       	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.25/mmu-notifier-v16

(applies and runs fine on 26-rc1)

You're more than welcome to takeover from it, I kind of feel my time
now may be better spent to emulate the mmu-notifier-core with kprobes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
