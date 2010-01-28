Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0749A6B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 08:25:07 -0500 (EST)
Date: Thu, 28 Jan 2010 07:25:03 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100128132503.GJ6616@sgi.com>
References: <20100125174556.GA23003@sgi.com>
 <20100125190052.GF5756@random.random>
 <20100125211033.GA24272@sgi.com>
 <20100125211615.GH5756@random.random>
 <20100126212904.GE6653@sgi.com>
 <20100126213853.GY30452@random.random>
 <20100128031841.GG6616@sgi.com>
 <20100128034943.GH6616@sgi.com>
 <20100128100327.GF24242@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100128100327.GF24242@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Jack Steiner <steiner@sgi.com>, cl@linux-foundation.org, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 28, 2010 at 11:03:27AM +0100, Andrea Arcangeli wrote:
> On Wed, Jan 27, 2010 at 09:49:44PM -0600, Robin Holt wrote:
> > > I think that with the SRCU patch, we have enough.  Is that true or have
> > > I missed something?
> > 
> > I wasn't quite complete in my previous email.  Your srcu patch
> > plus Jack's patch to move the tlb_gather_mmu to after the
> > mmu_notifier_invalidate_range_start().
> 
> My pmdp_clear_flush_notify with transparent hugepage will give some
> trouble because it's using mmu_notifier_invalidate_range_start to
> provide backwards compatible API to mmu notifier users like GRU that
> may be mapping physical hugepages with 4k secondary tlb mappings
> (which have to be all invalidated not only the first one). So that
> would still require the full series as it's like if the rmap code
> would be using mmu_notifier_invalidate_range_start. But we can
> probably get away by forcing all mmu notifier methods to provide a
> mmu_notifier_invalidate_hugepage.

The GRU is using a hardware TLB of 2MB page size when the
is_vm_hugetlb_page() indicates it is a 2MB vma.  From my reading of it,
your callout to mmu_notifier_invalidate_page() will work for gru and I
think it will work for XPMEM as well, but I am not certain of that yet.
I am certain that it can be made to work for XPMEM.  I think using the
range callouts are actually worse because now we are mixing the conceptual
uses of page and range.

> But in addition to srcu surely you also need i_mmap_lock_to_sem for
> unmap_mapping_range_vma taking i_mmap_lock, basically you missed
> truncate. Which then in cascade requires free_pgtables,

I must be missing something key here.  I thought unmap_mapping_range_vma
would percolate down to calling mmu_notifier_invalidate_page() which
xpmem can sleep in.  Based upon that assumption, I don't see the
need for the other patches.

> rwsem-contended, unmap_vmas (the latter are for the tlb gather
> required to be in atomic context to avoid scheduling to other cpus
> while holding the tlb gather).
> 
> So you only avoid the need of anon-vma switching to rwsem (because
> there's no range-vmtruncate but only rmap uses it on a page-by-page
> basis with mmu_notifier_invalidate_page). So at that point IMHO you
> can as well add a CONFIG_MMU_NOTIFIER_SLEEPABLE and allow scheduling
> everywhere in mmu notifier IMHO, but if you prefer to avoid changing
> anon_vma lock to rwsem and add refcounting that is ok with me too. I
> just think it'd be cleaner to switch them all to sleepable code if we
> have to provide for it and most of the work on the i_mmap_lock side is
> mandatory anyway.

I don't see the mandatory part here.  Maybe it is your broken english
combined with my ignorance, but I do not see what the statement
"i_mmap_lock side is mandatory" is based upon.  It looks to me like
everywhere that is calling an mmu_notifier_invalidate_* while holding
the i_mmap_lock is calling mmu_notifier_invalidate_page().  That is
currently safe for sleeping as far as XPMEM is concerned.  Is there a
place that is calling mmu_notifier_invalidate_range_*() while holding
the i_mmap_lock which I have missed?

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
