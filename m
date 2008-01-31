Date: Thu, 31 Jan 2008 01:12:58 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [patch 1/6] mmu_notifier: Core code
Message-ID: <20080131001258.GD7185@v2.random>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com> <20080130153749.GN7233@v2.random> <20080130155306.GA13746@sgi.com> <Pine.LNX.4.64.0801301116510.27491@schroedinger.engr.sgi.com> <20080130222035.GX26420@sgi.com> <20080130233803.GB7185@v2.random> <Pine.LNX.4.64.0801301552210.1722@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801301552210.1722@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 03:55:37PM -0800, Christoph Lameter wrote:
> On Thu, 31 Jan 2008, Andrea Arcangeli wrote:
> 
> > > I think Andrea's original concept of the lock in the mmu_notifier_head
> > > structure was the best.  I agree with him that it should be a spinlock
> > > instead of the rw_lock.
> > 
> > BTW, I don't see the scalability concern with huge number of tasks:
> > the lock is still in the mm, down_write(mm->mmap_sem); oneinstruction;
> > up_write(mm->mmap_sem) is always going to scale worse than
> > spin_lock(mm->somethingelse); oneinstruction;
> > spin_unlock(mm->somethinglese).
> 
> If we put it elsewhere in the mm then we increase the size of the memory 
> used in the mm_struct.

Yes, and it will increase of the same amount of RAM that you pretend
everyone to pay even if MMU_NOTIFIER=n after your patch is applied (vs
mine that generated 0 ram utilization increase when
MMU_NOTIFIER=n). And the additional ram will provide not just
self-contained locking but higher scalability too.

I think it's much more important to generate zero ram and CPU overhead
for the embedded (this is something I was very careful to enforce in
all my patches), than to reduce scalability and not having a self
contained locking on full configurations with MMU_NOTIFIER=y.

> Hmmmm.. exit_mmap is only called when the last reference is removed 
> against the mm right? So no tasks are running anymore. No pages are left. 
> Do we need to serialize at all for mmu_notifier_release?

KVM sure doesn't need any locking there.  I thought somebody had to
possibly take a pin on the "mm_count" and pretend to call
mmu_notifier_register at will until mmdrop was finally called, in a
out of order fashion given mmu_notifier_release was implemented like
if the list could change from under it. Note mmdrop != mmput. mmput
and in turn mm_users is the serialization point if you prefer to drop
all locking from _release. Nobody must ever attempt a mmu_notifier_*
after calling mmput for that mm. That should be enough to be
safe. I'm fine either ways...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
