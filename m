From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: EMM: disable other notifiers before register and unregister
Date: Thu, 3 Apr 2008 17:29:36 +0200
Message-ID: <20080403151908.GB9603@duo.random>
References: <20080401205531.986291575@sgi.com> <20080401205635.793766935@sgi.com> <20080402064952.GF19189@duo.random> <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com> <20080402220148.GV19189@duo.random> <Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com> <20080402221716.GY19189@duo.random> <Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758793AbYDCP3u@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Nick Piggin <npiggin@suse.de>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 06:24:15PM -0700, Christoph Lameter wrote:
> Ok lets forget about the single theaded thing to solve the registration 
> races. As Andrea pointed out this still has ssues with other subscribed 
> subsystems (and also try_to_unmap). We could do something like what 
> stop_machine_run does: First disable all running subsystems before 
> registering a new one.
> 
> Maybe this is a possible solution.

It still doesn't solve this kernel crash.

   CPU0				CPU1
   range_start (mmu notifier chain is empty)
   range_start returns
				mmu_notifier_register
				kvm_emm_stop (how kvm can ever know
				the other cpu is in the middle of the critical section?)
				kvm page fault (kvm thinks mmu_notifier_register serialized)
   zap ptes
   free_page mapped by spte/GRU and not pinned -> crash


There's no way the lowlevel can stop mmu_notifier_register and if
mmu_notifier_register returns, then sptes will be instantiated and
it'll corrupt memory the same way.

The seqlock was fine, what is wrong is the assumption that we can let
the lowlevel driver handle a range_end happening without range_begin
before it. The problem is that by design the lowlevel can't handle a
range_end happening without a range_begin before it. This is the core
kernel crashing problem we have (it's a kernel crashing issue only for
drivers that don't pin the pages, so XPMEM wouldn't crash but still it
would leak memory, which is a more graceful failure than random mm
corruption).

The basic trouble is that sometime range_begin/end critical sections
run outside the mmap_sem (see try_to_unmap_cluster in #v10 or even
try_to_unmap_one only in EMM-V2).

My attempt to fix this once and for all is to walk all vmas of the
"mm" inside mmu_notifier_register and take all anon_vma locks and
i_mmap_locks in virtual address order in a row. It's ok to take those
inside the mmap_sem. Supposedly if anybody will ever take a double
lock it'll do in order too. Then I can dump all the other locking and
remove the seqlock, and the driver is guaranteed there will be a
single call of range_begin followed by a single call of range_end the
whole time and no race could ever happen, and there won't be replied
calls of range_begin that would screwup a recursive semaphore
locking. The patch won't be pretty, I guess I'll vmalloc an array of
pointers to locks to reorder them. It doesn't need to be fast. Also
the locks can't go away from under us while we hold the
down_write(mmap_sem) because the vmas can be altered only with
down_write(mmap_sem) (modulo vm_start/vm_end that can be modified with
only down_read(mmap_sem) + page_table_lock like in growsdown page
faults). So it should be ok to take all those locks inside the
mmap_sem and implement a lock_vm(mm) unlock_vm(mm). I'll think more
about this hammer approach while I try to implement it...
