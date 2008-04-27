Date: Sun, 27 Apr 2008 14:27:27 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080427122727.GO9514@duo.random>
References: <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080426131734.GB19717@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 26, 2008 at 08:17:34AM -0500, Robin Holt wrote:
> the first four sets.  The fifth is the oversubscription test which trips
> my xpmem bug.  This is as good as the v12 runs from before.

Now that mmu-notifier-core #v14 seems finished and hopefully will
appear in 2.6.26 ;), I started exercising more the kvm-mmu-notifier
code with the full patchset applied and not only with
mmu-notifier-core. I soon found the full patchset has a swap deadlock
bug. Then I tried without using kvm (so with mmu notifier disarmed)
and I could still reproduce the crashes. After grabbing a few stack
traces I tracked it down to a bug in the i_mmap_lock->i_mmap_sem
conversion. If you oversubscription means swapping, you should retest
with this applied on #v14 i_mmap_sem patch as it would eventually
deadlock with all tasks allocating memory in D state without this. Now
the full patchset is as rock solid as with only mmu-notifier-core
applied. It's swapping 2G memhog on top of a 3G VM with 2G of ram for
the last hours without a problem. Everything is working great with KVM
at least.

Talking about post 2.6.26: the refcount with rcu in the anon-vma
conversion seems unnecessary and may explain part of the AIM slowdown
too. The rest looks ok and probably we should switch the code to a
compile-time decision between rwlock and rwsem (so obsoleting the
current spinlock).

diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1008,7 +1008,7 @@ static int try_to_unmap_file(struct page
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	up_write(&mapping->i_mmap_sem);
+	up_read(&mapping->i_mmap_sem);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
