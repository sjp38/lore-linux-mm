Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 652EC6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 02:52:52 -0500 (EST)
Received: by mail-ee0-f45.google.com with SMTP id b15so1226662eek.18
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 23:52:51 -0800 (PST)
Received: from eu1sys200aog118.obsmtp.com (eu1sys200aog118.obsmtp.com [207.126.144.145])
        by mx.google.com with SMTP id 3si204408eeq.122.2014.01.15.23.52.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 23:52:32 -0800 (PST)
Message-ID: <52D78FB6.4020102@mellanox.com>
Date: Thu, 16 Jan 2014 09:52:22 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: set_pte_at_notify regression
References: <52D021EE.3020104@ravellosystems.com> <20140110165705.GE1141@redhat.com> <52D282DC.6050902@mellanox.com> <20140112175031.GH1141@redhat.com>
In-Reply-To: <20140112175031.GH1141@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Alex Fishman <alex.fishman@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On 12/01/2014 19:50, Andrea Arcangeli wrote:
> On Sun, Jan 12, 2014 at 01:56:12PM +0200, Haggai Eran wrote:
>> Hi,
>>
>> On 10/01/2014 18:57, Andrea Arcangeli wrote:
>>> Hi!
>>>
>>> On Fri, Jan 10, 2014 at 06:38:06PM +0200, Izik Eidus wrote:
>>>> It look like commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 break the 
>>>> semantic of set_pte_at_notify.
>>>> The change of calling first to mmu_notifier_invalidate_range_start, then 
>>>> to set_pte_at_notify, and then to mmu_notifier_invalidate_range_end
>>>> not only increase the amount of locks kvm have to take and release by 
>>>> factor of 3, but in addition mmu_notifier_invalidate_range_start is zapping
>>>> the pte entry from kvm, so when set_pte_at_notify get called, it doesn`t 
>>>> have any spte to set and it acctuly get called for nothing, the result is
>>>> increasing of vmexits for kvm from both do_wp_page and replace_page, and 
>>>> broken semantic of set_pte_at_notify.
>>>
>>> Agreed.
>>>
>>> I would suggest to change set_pte_at_notify to return if change_pte
>>> was missing in some mmu notifier attached to this mm, so we can do
>>> something like:
>>>
>>>    ptep = page_check_address(page, mm, addr, &ptl, 0);
>>>    [..]
>>>    notify_missing = false;
>>>    if (... ) {
>>>       	entry = ptep_clear_flush(...);
>>>         [..]
>>> 	notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
>>>    }
>>>    pte_unmap_unlock(ptep, ptl);
>>>    if (notify_missing)
>>>    	mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
>>>
>>> and drop the range calls. This will provide sleepability and at the
>>> same time it won't screw the ability of change_pte to update sptes (by
>>> leaving those established by the time change_pte runs).
>>
>> I think it would be better for notifiers that do not support change_pte
>> to keep getting both range_start and range_end notifiers. Otherwise, the
>> invalidate_page notifier might end up marking the old page as dirty
>> after it was already replaced in the primary page table.
> 
> Ok but why would that be a problem? If the secondary pagetable mapping
> is found dirty, the old page shall be marked dirty as it means it was
> modified through the secondary mmu and is on-disk version may need to
> be updated before discarding the in-ram copy. What the difference
> would be to mark the page dirty in the range_start while the primary
> page table is still established, or after?
> 
> ...
> 
> But in places like ksm merging and do_wp_page we hold a page reference
> before we start the primary pagetable updating, until after the mmu
> notifier invalidate.

Right. I missed that page locking.

Another possible issue is with reads from the secondary page table.
Given a read-only page, suppose one host thread writes to that page, and
performs COW, but before it calls the
mmu_notifier_invalidate_page_if_missing_change_pte function another host
thread writes to the same page (this time without a page fault). Then we
have a valid entry in the secondary page table to a stale page, and
someone may read stale data from there.

Do you agree?

Thanks,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
