Date: Thu, 31 Jan 2008 00:38:03 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080130233803.GB7185@v2.random>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com> <20080130153749.GN7233@v2.random> <20080130155306.GA13746@sgi.com> <Pine.LNX.4.64.0801301116510.27491@schroedinger.engr.sgi.com> <20080130222035.GX26420@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130222035.GX26420@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 04:20:35PM -0600, Robin Holt wrote:
> On Wed, Jan 30, 2008 at 11:19:28AM -0800, Christoph Lameter wrote:
> > On Wed, 30 Jan 2008, Jack Steiner wrote:
> > 
> > > Moving to a different lock solves the problem.
> > 
> > Well it gets us back to the issue why we removed the lock. As Robin said 
> > before: If its global then we can have a huge number of tasks contending 
> > for the lock on startup of a process with a large number of ranks. The 
> > reason to go to mmap_sem was that it was placed in the mm_struct and so we 
> > would just have a couple of contentions per mm_struct.
> > 
> > I'll be looking for some other way to do this.
> 
> I think Andrea's original concept of the lock in the mmu_notifier_head
> structure was the best.  I agree with him that it should be a spinlock
> instead of the rw_lock.

BTW, I don't see the scalability concern with huge number of tasks:
the lock is still in the mm, down_write(mm->mmap_sem); oneinstruction;
up_write(mm->mmap_sem) is always going to scale worse than
spin_lock(mm->somethingelse); oneinstruction;
spin_unlock(mm->somethinglese).

Furthermore if we go this route and we don't relay on implicit
serialization of all the mmu notifier users against exit_mmap
(i.e. the mmu notifier user must agree to stop calling
mmu_notifier_register on a mm after the last mmput) the autodisarming
feature will likely have to be removed or it can't possibly be safe to
run mmu_notifier_unregister while mmu_notifier_release runs. With the
auto-disarming feature, there is no way to safely know if
mmu_notifier_unregister has to be called or not. I'm ok with removing
the auto-disarming feature and to have as self-contained-as-possible
locking. Then mmu_notifier_release can just become the
invalidate_all_after and invalidate_all, invalidate_all_before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
