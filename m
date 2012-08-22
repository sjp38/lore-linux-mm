Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id C0E766B0044
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 23:51:29 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 22 Aug 2012 13:50:16 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7M3gUmA24051772
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 13:42:31 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7M3pK9u030544
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 13:51:20 +1000
Message-ID: <50345735.2000807@linux.vnet.ibm.com>
Date: Wed, 22 Aug 2012 11:51:17 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between secondary
 MMU and host
References: <503358FF.3030009@linux.vnet.ibm.com> <20120821150618.GJ27696@redhat.com>
In-Reply-To: <20120821150618.GJ27696@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 08/21/2012 11:06 PM, Andrea Arcangeli wrote:
> On Tue, Aug 21, 2012 at 05:46:39PM +0800, Xiao Guangrong wrote:
>> There has a bug in set_pte_at_notify which always set the pte to the
>> new page before release the old page in secondary MMU, at this time,
>> the process will access on the new page, but the secondary MMU still
>> access on the old page, the memory is inconsistent between them
>>
>> Below scenario shows the bug more clearly:
>>
>> at the beginning: *p = 0, and p is write-protected by KSM or shared with
>> parent process
>>
>> CPU 0                                       CPU 1
>> write 1 to p to trigger COW,
>> set_pte_at_notify will be called:
>>   *pte = new_page + W; /* The W bit of pte is set */
>>
>>                                      *p = 1; /* pte is valid, so no #PF */
>>
>>                                      return back to secondary MMU, then
>>                                      the secondary MMU read p, but get:
>>                                      *p == 0;
>>
>>                          /*
>>                           * !!!!!!
>>                           * the host has already set p to 1, but the secondary
>>                           * MMU still get the old value 0
>>                           */
>>
>>   call mmu_notifier_change_pte to release
>>   old page in secondary MMU
> 
> The KSM usage of it looks safe because it will only establish readonly
> ptes with it.

Hmm, in KSM code, i found this code in replace_page:

set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));

It is possible to establish a writable pte, no?

> 
> It seems a problem only for do_wp_page. It wasn't safe to setup
> writable ptes with it. I guess we first introduced it for KSM and then
> we added it to do_wp_page too by mistake.
> 
> The race window is really tiny, it's unlikely it has ever triggered,
> however this one seem to be possible so it's slightly more serious
> than the other race you recently found (the previous one in the exit
> path I think it was impossible to trigger with KVM).

Unfortunately, all these bugs are triggered by test cases.

> 
>> We can fix it by release old page first, then set the pte to the new
>> page.
>>
>> Note, the new page will be firstly used in secondary MMU before it is
>> mapped into the page table of the process, but this is safe because it
>> is protected by the page table lock, there is no race to change the pte
>>
>> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>> ---
>>  include/linux/mmu_notifier.h |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
>> index 1d1b1e1..8c7435a 100644
>> --- a/include/linux/mmu_notifier.h
>> +++ b/include/linux/mmu_notifier.h
>> @@ -317,8 +317,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
>>  	unsigned long ___address = __address;				\
>>  	pte_t ___pte = __pte;						\
>>  									\
>> -	set_pte_at(___mm, ___address, __ptep, ___pte);			\
>>  	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
>> +	set_pte_at(___mm, ___address, __ptep, ___pte);			\
>>  })
> 
> If we establish the spte on the new page, what will happen is the same
> race in reverse. The fundamental problem is that the first guy that
> writes to the "newpage" (guest or host) won't fault again and so it
> will fail to serialize against the PT lock.
> 
> CPU0  		    	    	CPU1
> 				oldpage[1] == 0 (both guest & host)
> oldpage[0] = 1
> trigger do_wp_page
> mmu_notifier_change_pte
> spte = newpage + writable
> 				guest does newpage[1] = 1
> 				vmexit
> 				host read oldpage[1] == 0
> pte = newpage + writable (too late)
> 
> I think the fix is to use ptep_clear_flush_notify whenever
> set_pte_at_notify will establish a writable pte/spte. If the pte/spte
> established by set_pte_at_notify/change_pte is readonly we don't need
> to do the ptep_clear_flush_notify instead because when the host will
> write to the page that will fault and serialize against the
> PT lock (set_pte_at_notify must always run under the PT lock of course).
> 
> How about this:
> 
> =====
>>From 160a0b1b2be9bf96c45b30d9423f8196ecebe351 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 21 Aug 2012 16:48:11 +0200
> Subject: [PATCH] mmu_notifier: fix race in set_pte_at_notify usage
> 
> Whenever we establish a writable spte with set_pte_at_notify the
> ptep_clear_flush before it must be a _notify one that clears the spte
> too.
> 
> The fundamental problem is that if the primary MMU that writes to the
> "newpage" won't fault again if the pte established by
> set_pte_at_notify is writable. And so it will fail to serialize
> against the PT lock to wait the set_pte_at_notify to finish
> updating all secondary MMUs before the write hits the newpage.
> 
> CPU0  		    	    	CPU1
> 				oldpage[1] == 0 (all MMUs)
> oldpage[0] = 1
> trigger do_wp_page
> take PT lock
> ptep_clear_flush (secondary MMUs
> still have read access to oldpage)
> mmu_notifier_change_pte
> pte = newpage + writable (primary MMU can write to
> newpage)
> 				host write newpage[1] == 1 (no fault,
> 				failed to serialize against PT lock)
> 				vmenter
> 				guest read oldpage[1] == 0


Why? Why guest can read the old page?

Before you set the pte to be writable, mmu_notifier_change_pte is called
that all old pages have been released.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
