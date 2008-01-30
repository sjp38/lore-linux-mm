Date: Wed, 30 Jan 2008 15:55:37 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
In-Reply-To: <20080130233803.GB7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801301552210.1722@schroedinger.engr.sgi.com>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com>
 <20080130153749.GN7233@v2.random> <20080130155306.GA13746@sgi.com>
 <Pine.LNX.4.64.0801301116510.27491@schroedinger.engr.sgi.com>
 <20080130222035.GX26420@sgi.com> <20080130233803.GB7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Andrea Arcangeli wrote:

> > I think Andrea's original concept of the lock in the mmu_notifier_head
> > structure was the best.  I agree with him that it should be a spinlock
> > instead of the rw_lock.
> 
> BTW, I don't see the scalability concern with huge number of tasks:
> the lock is still in the mm, down_write(mm->mmap_sem); oneinstruction;
> up_write(mm->mmap_sem) is always going to scale worse than
> spin_lock(mm->somethingelse); oneinstruction;
> spin_unlock(mm->somethinglese).

If we put it elsewhere in the mm then we increase the size of the memory 
used in the mm_struct.

> Furthermore if we go this route and we don't relay on implicit
> serialization of all the mmu notifier users against exit_mmap
> (i.e. the mmu notifier user must agree to stop calling
> mmu_notifier_register on a mm after the last mmput) the autodisarming
> feature will likely have to be removed or it can't possibly be safe to
> run mmu_notifier_unregister while mmu_notifier_release runs. With the
> auto-disarming feature, there is no way to safely know if
> mmu_notifier_unregister has to be called or not. I'm ok with removing
> the auto-disarming feature and to have as self-contained-as-possible
> locking. Then mmu_notifier_release can just become the
> invalidate_all_after and invalidate_all, invalidate_all_before.

Hmmmm.. exit_mmap is only called when the last reference is removed 
against the mm right? So no tasks are running anymore. No pages are left. 
Do we need to serialize at all for mmu_notifier_release?

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
