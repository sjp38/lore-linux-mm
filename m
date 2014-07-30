Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 624DA6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 08:30:59 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so1384475pdb.38
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:30:59 -0700 (PDT)
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
        by mx.google.com with ESMTPS id ok8si2241336pbb.181.2014.07.30.05.30.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 05:30:57 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so1382834pdj.36
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:30:57 -0700 (PDT)
Message-ID: <53D8E578.7060303@ozlabs.ru>
Date: Wed, 30 Jul 2014 22:30:48 +1000
From: Alexey Kardashevskiy <aik@ozlabs.ru>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: Add helpers for locked_vm
References: <1406712493-9284-1-git-send-email-aik@ozlabs.ru> <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1406716282.9336.16.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, =?KOI8-R?Q?Jo=22rn_Engel?= <joern@logfs.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Michael Ellerman <michael@ellerman.id.au>

On 07/30/2014 08:31 PM, Davidlohr Bueso wrote:
> On Wed, 2014-07-30 at 19:28 +1000, Alexey Kardashevskiy wrote:
>> This adds 2 helpers to change the locked_vm counter:
>> - try_increase_locked_vm - may fail if new locked_vm value will be greater
>> than the RLIMIT_MEMLOCK limit;
>> - decrease_locked_vm.
>>
>> These will be used by drivers capable of locking memory by userspace
>> request. For example, VFIO can use it to check if it can lock DMA memory
>> or PPC-KVM can use it to check if it can lock memory for TCE tables.
>>
>> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
>> ---
>>  include/linux/mm.h |  3 +++
>>  mm/mlock.c         | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
>>  2 files changed, 52 insertions(+)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index e03dd29..1cb219d 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2113,5 +2113,8 @@ void __init setup_nr_node_ids(void);
>>  static inline void setup_nr_node_ids(void) {}
>>  #endif
>>  
>> +extern long try_increment_locked_vm(long npages);
>> +extern void decrement_locked_vm(long npages);
>> +
>>  #endif /* __KERNEL__ */
>>  #endif /* _LINUX_MM_H */
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index b1eb536..39e4b55 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -864,3 +864,52 @@ void user_shm_unlock(size_t size, struct user_struct *user)
>>  	spin_unlock(&shmlock_user_lock);
>>  	free_uid(user);
>>  }
>> +
>> +/**
>> + * try_increment_locked_vm() - checks if new locked_vm value is going to
>> + * be less than RLIMIT_MEMLOCK and increments it by npages if it is.
>> + *
>> + * @npages: the number of pages to add to locked_vm.
>> + *
>> + * Returns 0 if succeeded or negative value if failed.
>> + */
>> +long try_increment_locked_vm(long npages)
> 
> mlock calls work at an address granularity...
> 
>> +{
>> +	long ret = 0, locked, lock_limit;
>> +
>> +	if (!current || !current->mm)
>> +		return -ESRCH; /* process exited */
> 
> It doesn't strike me that this is the place for this. It would seem that
> it would be the caller's responsibility to make sure of this (and not
> sure how !current can happen...).
> 
>> +
>> +	down_write(&current->mm->mmap_sem);
>> +	locked = current->mm->locked_vm + npages;
>> +	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> 
> nit: please set locked and lock_limit before taking the mmap_sem.
> 
>> +	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
>> +		pr_warn("RLIMIT_MEMLOCK (%ld) exceeded\n",
>> +				rlimit(RLIMIT_MEMLOCK));
>> +		ret = -ENOMEM;
>> +	} else {
> 
> It would be nicer to have it the other way around, leave the #else for
> ENOMEM. It reads better, imho.
> 
>> +		current->mm->locked_vm += npages;
> 
> More importantly just setting locked_vm is not enough. You'll need to
> call do_mlock() here (again, addr granularity ;). This also applies to
> your decrement_locked_vm().

Uff. Bad commit log :(

No, this is not my intention here. Here I only want to increment the counter.

The whole problem is like this: there is VFIO (PCI passthru) and the guest
which gets a real PCI device wants to use some of guest RAM for DMA so we
need to pin this memory. PPC64-pseries specific is:

1. only part of guest RAM can be used for DMA, so called "window", and we
do not know in advance what part of guest RAM has to be pinned; the window
is never guaranteed to have a specific size like "whole guest RAM" and even
if we wanted to pin the entire guest RAM - we cannot do this as we do not
know the guest's RAM size if it is not KVM;

2. we could do this counting and locking in real time but this is not
possible from real mode (MMU off) and will slow things down.

So the trick is we do not let the guest (QEMU in full emulation or KVM,
does not matter here) use VFIO at all if it cannot increment the locked_vm
counter in advance. No locking needs to done at the moment of the guest's
start.




-- 
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
