From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: init notifier if necessary
Date: Sat, 25 Aug 2012 17:47:50 +0800
Message-ID: <16547.8324205198$1345888084@news.gmane.org>
References: <1345819076-12545-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120824145151.b92557cc.akpm@linux-foundation.org>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1T5CyH-0007mE-Re
	for glkm-linux-mm-2@m.gmane.org; Sat, 25 Aug 2012 11:48:02 +0200
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 332956B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:47:57 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sat, 25 Aug 2012 05:47:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 3C4EA38C803B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:47:54 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7P9lsLE148426
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:47:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7P9lr1u005618
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:47:53 -0400
Content-Disposition: inline
In-Reply-To: <20120824145151.b92557cc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>

On Fri, Aug 24, 2012 at 02:51:51PM -0700, Andrew Morton wrote:
>On Fri, 24 Aug 2012 22:37:55 +0800
>Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
>> From: Gavin Shan <shangw@linux.vnet.ibm.com>
>> 
>> While registering MMU notifier, new instance of MMU notifier_mm will
>> be allocated and later free'd if currrent mm_struct's MMU notifier_mm
>> has been initialized. That cause some overhead. The patch tries to
>> eleminate that.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/mmu_notifier.c |   22 +++++++++++-----------
>>  1 files changed, 11 insertions(+), 11 deletions(-)
>> 
>> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
>> index 862b608..fb4067f 100644
>> --- a/mm/mmu_notifier.c
>> +++ b/mm/mmu_notifier.c
>> @@ -192,22 +192,23 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>>  
>>  	BUG_ON(atomic_read(&mm->mm_users) <= 0);
>>  
>> -	ret = -ENOMEM;
>> -	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
>> -	if (unlikely(!mmu_notifier_mm))
>> -		goto out;
>> -
>>  	if (take_mmap_sem)
>>  		down_write(&mm->mmap_sem);
>>  	ret = mm_take_all_locks(mm);
>>  	if (unlikely(ret))
>> -		goto out_cleanup;
>> +		goto out;
>>  
>>  	if (!mm_has_notifiers(mm)) {
>> +		mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
>> +					GFP_ATOMIC);
>
>Why was the code switched to the far weaker GFP_ATOMIC?  We can still
>perform sleeping allocations inside mmap_sem.
>

Yes, we can perform sleeping while allocating memory, but we're holding
the "mmap_sem". GFP_KERNEL possiblly block somebody else who also waits
on mmap_sem for long time even though the case should be rare :-)

Thanks,
Gavin

>> +		if (unlikely(!mmu_notifier_mm)) {
>> +			ret = -ENOMEM;
>> +			goto out_of_mem;
>> +		}
>>  		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
>>  		spin_lock_init(&mmu_notifier_mm->lock);
>> +
>>  		mm->mmu_notifier_mm = mmu_notifier_mm;
>> -		mmu_notifier_mm = NULL;
>>  	}
>>  	atomic_inc(&mm->mm_count);
>>  
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
