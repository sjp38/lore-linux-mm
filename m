Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 17DBD6B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 12:50:44 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id f11so1451978qae.24
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 09:50:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n9si15368735qas.55.2014.01.12.09.50.42
        for <linux-mm@kvack.org>;
        Sun, 12 Jan 2014 09:50:43 -0800 (PST)
Date: Sun, 12 Jan 2014 18:50:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: set_pte_at_notify regression
Message-ID: <20140112175031.GH1141@redhat.com>
References: <52D021EE.3020104@ravellosystems.com>
 <20140110165705.GE1141@redhat.com>
 <52D282DC.6050902@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D282DC.6050902@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Alex Fishman <alex.fishman@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Sun, Jan 12, 2014 at 01:56:12PM +0200, Haggai Eran wrote:
> Hi,
> 
> On 10/01/2014 18:57, Andrea Arcangeli wrote:
> > Hi!
> >
> > On Fri, Jan 10, 2014 at 06:38:06PM +0200, Izik Eidus wrote:
> >> It look like commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 break the 
> >> semantic of set_pte_at_notify.
> >> The change of calling first to mmu_notifier_invalidate_range_start, then 
> >> to set_pte_at_notify, and then to mmu_notifier_invalidate_range_end
> >> not only increase the amount of locks kvm have to take and release by 
> >> factor of 3, but in addition mmu_notifier_invalidate_range_start is zapping
> >> the pte entry from kvm, so when set_pte_at_notify get called, it doesn`t 
> >> have any spte to set and it acctuly get called for nothing, the result is
> >> increasing of vmexits for kvm from both do_wp_page and replace_page, and 
> >> broken semantic of set_pte_at_notify.
> >
> > Agreed.
> >
> > I would suggest to change set_pte_at_notify to return if change_pte
> > was missing in some mmu notifier attached to this mm, so we can do
> > something like:
> >
> >    ptep = page_check_address(page, mm, addr, &ptl, 0);
> >    [..]
> >    notify_missing = false;
> >    if (... ) {
> >       	entry = ptep_clear_flush(...);
> >         [..]
> > 	notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
> >    }
> >    pte_unmap_unlock(ptep, ptl);
> >    if (notify_missing)
> >    	mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
> >
> > and drop the range calls. This will provide sleepability and at the
> > same time it won't screw the ability of change_pte to update sptes (by
> > leaving those established by the time change_pte runs).
> 
> I think it would be better for notifiers that do not support change_pte
> to keep getting both range_start and range_end notifiers. Otherwise, the
> invalidate_page notifier might end up marking the old page as dirty
> after it was already replaced in the primary page table.

Ok but why would that be a problem? If the secondary pagetable mapping
is found dirty, the old page shall be marked dirty as it means it was
modified through the secondary mmu and is on-disk version may need to
be updated before discarding the in-ram copy. What the difference
would be to mark the page dirty in the range_start while the primary
page table is still established, or after?

Here the docs too:

	/*
	 * Before this is invoked any secondary MMU is still ok to
	 * read/write to the page previously pointed to by the Linux
	 * pte because the page hasn't been freed yet and it won't be
	 * freed until this returns. If required set_page_dirty has to
	 * be called internally to this method.
	 */
	void (*invalidate_page)(struct mmu_notifier *mn,
				struct mm_struct *mm,
				unsigned long address);

Why the range_start/end is needed, is only to solve the mess with the
freeing of the page in those cases were we hold no individual
reference on the pages and we do tlb gather freeing.

But in places like ksm merging and do_wp_page we hold a page reference
before we start the primary pagetable updating, until after the mmu
notifier invalidate.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
