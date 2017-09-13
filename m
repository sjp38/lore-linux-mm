Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6F76B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 12:56:39 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so1149434pgb.3
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 09:56:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b6si9416932pgc.227.2017.09.13.09.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 09:56:37 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8DGtMSm025549
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 12:56:36 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cy39yhghm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 12:56:36 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 13 Sep 2017 17:56:34 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 04/20] mm: VMA sequence count
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1504894024-2750-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170913115354.GA7756@jagdpanzerIV.localdomain>
Date: Wed, 13 Sep 2017 18:56:25 +0200
MIME-Version: 1.0
In-Reply-To: <20170913115354.GA7756@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hi Sergey,

On 13/09/2017 13:53, Sergey Senozhatsky wrote:
> Hi,
> 
> On (09/08/17 20:06), Laurent Dufour wrote:
> [..]
>> @@ -903,6 +910,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  		mm->map_count--;
>>  		mpol_put(vma_policy(next));
>>  		kmem_cache_free(vm_area_cachep, next);
>> +		write_seqcount_end(&next->vm_sequence);
>>  		/*
>>  		 * In mprotect's case 6 (see comments on vma_merge),
>>  		 * we must remove another next too. It would clutter
>> @@ -932,11 +940,14 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  		if (remove_next == 2) {
>>  			remove_next = 1;
>>  			end = next->vm_end;
>> +			write_seqcount_end(&vma->vm_sequence);
>>  			goto again;
>> -		}
>> -		else if (next)
>> +		} else if (next) {
>> +			if (next != vma)
>> +				write_seqcount_begin_nested(&next->vm_sequence,
>> +							    SINGLE_DEPTH_NESTING);
>>  			vma_gap_update(next);
>> -		else {
>> +		} else {
>>  			/*
>>  			 * If remove_next == 2 we obviously can't
>>  			 * reach this path.
>> @@ -962,6 +973,10 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
>>  	if (insert && file)
>>  		uprobe_mmap(insert);
>>  
>> +	if (next && next != vma)
>> +		write_seqcount_end(&next->vm_sequence);
>> +	write_seqcount_end(&vma->vm_sequence);
> 
> 
> ok, so what I got on my box is:
> 
> vm_munmap()  -> down_write_killable(&mm->mmap_sem)
>  do_munmap()
>   __split_vma()
>    __vma_adjust()  -> write_seqcount_begin(&vma->vm_sequence)
>                    -> write_seqcount_begin_nested(&next->vm_sequence, SINGLE_DEPTH_NESTING)
> 
> so this gives 3 dependencies  ->mmap_sem   ->   ->vm_seq
>                               ->vm_seq     ->   ->vm_seq/1
>                               ->mmap_sem   ->   ->vm_seq/1
> 
> 
> SyS_mremap() -> down_write_killable(&current->mm->mmap_sem)
>  move_vma()   -> write_seqcount_begin(&vma->vm_sequence)
>               -> write_seqcount_begin_nested(&new_vma->vm_sequence, SINGLE_DEPTH_NESTING);
>   move_page_tables()
>    __pte_alloc()
>     pte_alloc_one()
>      __alloc_pages_nodemask()
>       fs_reclaim_acquire()
> 
> 
> I think here we have prepare_alloc_pages() call, that does
> 
>         -> fs_reclaim_acquire(gfp_mask)
>         -> fs_reclaim_release(gfp_mask)
> 
> so that adds one more dependency  ->mmap_sem   ->   ->vm_seq    ->   fs_reclaim
>                                   ->mmap_sem   ->   ->vm_seq/1  ->   fs_reclaim
> 
> 
> now, under memory pressure we hit the slow path and perform direct
> reclaim. direct reclaim is done under fs_reclaim lock, so we end up
> with the following call chain
> 
> __alloc_pages_nodemask()
>  __alloc_pages_slowpath()
>   __perform_reclaim()       ->   fs_reclaim_acquire(gfp_mask);
>    try_to_free_pages()
>     shrink_node()
>      shrink_active_list()
>       rmap_walk_file()      ->   i_mmap_lock_read(mapping);
> 
> 
> and this break the existing dependency. since we now take the leaf lock
> (fs_reclaim) first and the the root lock (->mmap_sem).

Thanks for looking at this.
I'm sorry, I should have miss something.

My understanding is that there are 2 chains of locks:
 1. from __vma_adjust() mmap_sem -> i_mmap_rwsem -> vm_seq
 2. from move_vmap() mmap_sem -> vm_seq -> fs_reclaim
 2. from __alloc_pages_nodemask() fs_reclaim -> i_mmap_rwsem

So the solution would be to have in __vma_adjust()
 mmap_sem -> vm_seq -> i_mmap_rwsem

But this will raised the following dependency from  unmap_mapping_range()
unmap_mapping_range() 		-> i_mmap_rwsem
 unmap_mapping_range_tree()
  unmap_mapping_range_vma()
   zap_page_range_single()
    unmap_single_vma()
     unmap_page_range()	 	-> vm_seq

And there is no way to get rid of it easily as in unmap_mapping_range()
there is no VMA identified yet.

That's being said I can't see any clear way to get lock dependency cleaned
here.
Furthermore, this is not clear to me how a deadlock could happen as vm_seq
is a sequence lock, and there is no way to get blocked here.

Cheers,
Laurent.

> 
> well, seems to be the case.
> 
> 	-ss
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
