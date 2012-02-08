Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C61BA6B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 06:14:34 -0500 (EST)
Received: by bkty12 with SMTP id y12so455929bkt.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 03:14:33 -0800 (PST)
Message-ID: <4F325916.20901@openvz.org>
Date: Wed, 08 Feb 2012 15:14:30 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC V2] mm: convert rcu_read_lock() to srcu_read_lock(),
 thus allowing to sleep in callbacks
References: <y> <4f2fe67e.e54cb40a.5700.ffff8fdf@mx.google.com> <4F325587.4070605@mellanox.com>
In-Reply-To: <4F325587.4070605@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sagig <sagig@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Oren Duer <oren@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

sagig wrote:
> Hey Konstantin,
> Do you have any comments on V2?

only one, below.

>
> On 2/6/2012 4:40 PM, sagig@mellanox.com wrote:
>> From: Sagi Grimberg<sagig@mellanox.co.il>
>>
>> Now that anon_vma lock and i_mmap_mutex are both sleepable mutex, it is possible to schedule inside invalidation callbacks
>> (such as invalidate_page, invalidate_range_start/end and change_pte) .
>> This is essential for a scheduling HW sync in RDMA drivers which apply on demand paging methods.
>>
>> Signed-off-by: Sagi Grimberg<sagig@mellanox.co.il>
>> ---
>>    changes from V1:
>>    1. converted synchronize_rcu() to synchronize_srcu() to racing candidates (unregister, release)
>>    2. do_mmu_notifier_register: moved init_srcu_struct out of mmap_sem locking.
>>    3. do_mmu_notifier_register: fixed error path.
>>
>>    include/linux/mmu_notifier.h |    3 +++
>>    mm/mmu_notifier.c            |   38 +++++++++++++++++++++++++-------------
>>    2 files changed, 28 insertions(+), 13 deletions(-)
>>
>> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
>> index 1d1b1e1..f3d6f30 100644
>> --- a/include/linux/mmu_notifier.h
>> +++ b/include/linux/mmu_notifier.h

>> @@ -226,8 +233,12 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
>>    out_cleanup:
>>    	if (take_mmap_sem)
>>    		up_write(&mm->mmap_sem);
>> -	/* kfree() does nothing if mmu_notifier_mm is NULL */
>> -	kfree(mmu_notifier_mm);
>> +
>> +	if (mm->mmu_notifier_mm) {
>> +		/* in the case srcu_init failed srcu_cleanup is safe */
>> +		cleanup_srcu_struct(&mm->mmu_notifier_mm->srcu);
>> +		kfree(mmu_notifier_mm);
>> +	}

this seems incorrect. there must be:

if (mmu_notifier_mm) {
	cleanup_srcu_struct(&mmu_notifier_mm->srcu);
	kfree(mmu_notifier_mm);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
