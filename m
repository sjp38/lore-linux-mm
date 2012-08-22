Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id EF3B06B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 02:04:09 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 22 Aug 2012 16:03:09 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7M63imj20447374
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 16:03:45 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7M63iIE012909
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 16:03:44 +1000
Message-ID: <5034763D.60508@linux.vnet.ibm.com>
Date: Wed, 22 Aug 2012 14:03:41 +0800
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
> 
> It seems a problem only for do_wp_page. It wasn't safe to setup
> writable ptes with it. I guess we first introduced it for KSM and then
> we added it to do_wp_page too by mistake.
> 
> The race window is really tiny, it's unlikely it has ever triggered,
> however this one seem to be possible so it's slightly more serious
> than the other race you recently found (the previous one in the exit
> path I think it was impossible to trigger with KVM).
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

We always do ptep_clear_flush before set_pte_at_notify(),
at this point, we have done:
  pte = 0 and flush all tlbs

> mmu_notifier_change_pte
> spte = newpage + writable
> 				guest does newpage[1] = 1
> 				vmexit
> 				host read oldpage[1] == 0

                  It can not happen, at this point pte = 0, host can not
		  access oldpage anymore, host read can generate #PF, it
                  will be blocked on page table lock until CPU 0 release the lock.

> pte = newpage + writable (too late)
> 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
