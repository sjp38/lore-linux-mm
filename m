Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 67FBE6B0037
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 11:57:11 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id o15so4343076qap.31
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 08:57:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t7si10768515qar.123.2014.01.10.08.57.09
        for <linux-mm@kvack.org>;
        Fri, 10 Jan 2014 08:57:10 -0800 (PST)
Date: Fri, 10 Jan 2014 17:57:05 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: set_pte_at_notify regression
Message-ID: <20140110165705.GE1141@redhat.com>
References: <52D021EE.3020104@ravellosystems.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52D021EE.3020104@ravellosystems.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, Alex Fishman <alex.fishman@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Haggai Eran <haggaie@mellanox.com>

Hi!

On Fri, Jan 10, 2014 at 06:38:06PM +0200, Izik Eidus wrote:
> It look like commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 break the 
> semantic of set_pte_at_notify.
> The change of calling first to mmu_notifier_invalidate_range_start, then 
> to set_pte_at_notify, and then to mmu_notifier_invalidate_range_end
> not only increase the amount of locks kvm have to take and release by 
> factor of 3, but in addition mmu_notifier_invalidate_range_start is zapping
> the pte entry from kvm, so when set_pte_at_notify get called, it doesn`t 
> have any spte to set and it acctuly get called for nothing, the result is
> increasing of vmexits for kvm from both do_wp_page and replace_page, and 
> broken semantic of set_pte_at_notify.

Agreed.

I would suggest to change set_pte_at_notify to return if change_pte
was missing in some mmu notifier attached to this mm, so we can do
something like:

   ptep = page_check_address(page, mm, addr, &ptl, 0);
   [..]
   notify_missing = false;
   if (... ) {
      	entry = ptep_clear_flush(...);
        [..]
	notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
   }
   pte_unmap_unlock(ptep, ptl);
   if (notify_missing)
   	mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);

and drop the range calls. This will provide sleepability and at the
same time it won't screw the ability of change_pte to update sptes (by
leaving those established by the time change_pte runs).

This assuming the mutex are going to stay mutex for anon_vma lock and
i_mmap_mutex as I hope. Otherwise the commit could be as well
reverted, it would be pointless then to try to keep the
invalidate_page call outside the PT lock if all other invalidate_page
calls are inside rmap spinlocks.

I think giving a runtime or compiler option to switch the locks to
spinlocks is just fine, cellphones I think would be better off with
those locks as spinlocks for example, but completely removing the
ability to run those locks as mutex even on server setups, doesn't
look a too attractive development to me. A build option especially
wouldn't be too painful to maintain. So I'd be positive for an update
like above to retain the sleeability feature but without harming
change_pte users like KVM anymore.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
