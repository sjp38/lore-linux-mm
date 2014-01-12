Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4F51E6B0031
	for <linux-mm@kvack.org>; Sun, 12 Jan 2014 06:56:21 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id e53so574980eek.11
        for <linux-mm@kvack.org>; Sun, 12 Jan 2014 03:56:20 -0800 (PST)
Received: from eu1sys200aog124.obsmtp.com (eu1sys200aog124.obsmtp.com [207.126.144.157])
        by mx.google.com with SMTP id j47si22207197eeo.95.2014.01.12.03.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 12 Jan 2014 03:56:20 -0800 (PST)
Message-ID: <52D282DC.6050902@mellanox.com>
Date: Sun, 12 Jan 2014 13:56:12 +0200
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: set_pte_at_notify regression
References: <52D021EE.3020104@ravellosystems.com> <20140110165705.GE1141@redhat.com>
In-Reply-To: <20140110165705.GE1141@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Izik Eidus <izik.eidus@ravellosystems.com>, linux-mm@kvack.org, kvm@vger.kernel.org, Alex Fishman <alex.fishman@ravellosystems.com>, Mike Rapoport <mike.rapoport@ravellosystems.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

Hi,

On 10/01/2014 18:57, Andrea Arcangeli wrote:
> Hi!
>
> On Fri, Jan 10, 2014 at 06:38:06PM +0200, Izik Eidus wrote:
>> It look like commit 6bdb913f0a70a4dfb7f066fb15e2d6f960701d00 break the 
>> semantic of set_pte_at_notify.
>> The change of calling first to mmu_notifier_invalidate_range_start, then 
>> to set_pte_at_notify, and then to mmu_notifier_invalidate_range_end
>> not only increase the amount of locks kvm have to take and release by 
>> factor of 3, but in addition mmu_notifier_invalidate_range_start is zapping
>> the pte entry from kvm, so when set_pte_at_notify get called, it doesn`t 
>> have any spte to set and it acctuly get called for nothing, the result is
>> increasing of vmexits for kvm from both do_wp_page and replace_page, and 
>> broken semantic of set_pte_at_notify.
>
> Agreed.
>
> I would suggest to change set_pte_at_notify to return if change_pte
> was missing in some mmu notifier attached to this mm, so we can do
> something like:
>
>    ptep = page_check_address(page, mm, addr, &ptl, 0);
>    [..]
>    notify_missing = false;
>    if (... ) {
>       	entry = ptep_clear_flush(...);
>         [..]
> 	notify_missing = set_pte_at_notify(mm, addr, ptep, entry);
>    }
>    pte_unmap_unlock(ptep, ptl);
>    if (notify_missing)
>    	mmu_notifier_invalidate_page_if_missing_change_pte(mm, addr);
>
> and drop the range calls. This will provide sleepability and at the
> same time it won't screw the ability of change_pte to update sptes (by
> leaving those established by the time change_pte runs).

I think it would be better for notifiers that do not support change_pte
to keep getting both range_start and range_end notifiers. Otherwise, the
invalidate_page notifier might end up marking the old page as dirty
after it was already replaced in the primary page table.

Perhaps we can have a flag in the mmu_notifier, similar to the
notify_missing returned value here, that determines in these cases
whether to call the invalidate_range_start/end pair, or just the
set_pte_at_notify.

Thanks,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
