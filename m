Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A7BCC6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 14:36:08 -0400 (EDT)
Message-ID: <4C07F5EC.20600@cray.com>
Date: Thu, 3 Jun 2010 11:35:24 -0700
From: Doug Doan <dougd@cray.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: call mmu notifiers on hugepage cow
References: <4BFED954.8060807@cray.com>	<20100601231600.3b3bf499.akpm@linux-foundation.org>	<4C06E5A6.6@cray.com>	<20100602163346.b8f8b8a4.akpm@linux-foundation.org>	<4C07E800.5010701@cray.com> <20100603111125.8cd6a787.akpm@linux-foundation.org>
In-Reply-To: <20100603111125.8cd6a787.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "rientjes@google.com" <rientjes@google.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 06/03/2010 11:11 AM, Andrew Morton wrote:
> On Thu, 3 Jun 2010 10:36:00 -0700
> Doug Doan<dougd@cray.com>  wrote:
>
>>> Well, specifically it means that
>>> mmu_notifier_invalidate_range_start/end() implemetnations can no longer
>>> take page_table_lock or any lock which nests outside page_table_lock.
>>> That lessens flexibility.
>>>
>>> As the other mmu_notifier_invalidate_range_start/end() callsite in this
>>> function carefully nested those calls outside page_table_lock, perhaps
>>> that was thought to be a significant thing.
>>
>> Here's my rationale: for the normal page case, the invalidation call is done
>> inside a page_table_lock,
>
> It is?  Where does that happen?

handle_pte_fault() acquires the lock before calling do_wp_page():

         ptl = pte_lockptr(mm, pmd);
         spin_lock(ptl);
         if (unlikely(!pte_same(*pte, entry)))
                 goto unlock;
         if (flags & FAULT_FLAG_WRITE) {
                 if (!pte_write(entry))
                         return do_wp_page(mm, vma, address,
                                         pte, pmd, ptl, entry);
                 entry = pte_mkdirty(entry);
         }

do_wp_page() calls set_pte_at_notify(), which either calls 
mmu_notifier_change_pte() or mmu_notifier_invalidate_page().

>
>> so the same should also be done in the huge page case.
>> Does it really make sense to call invalidation on one hugepage and have another
>> call invalidate the same hugepage while the first call is still not finished?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
