Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 55A7D6B0071
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 11:26:02 -0500 (EST)
Message-ID: <4B59D16A.1060706@redhat.com>
Date: Fri, 22 Jan 2010 11:25:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix multi-process
 server scalability issue
References: <20100121133448.73BD.A69D9226@jp.fujitsu.com> <4B57E442.5060700@redhat.com> <20100122135809.6C11.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100122135809.6C11.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minchan.kim@gmail.com, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/22/2010 01:57 AM, KOSAKI Motohiro wrote:

> [ generally, this patch have too few lock related comment. I think I
>    haven't undestand correct lock rule of this patch. ]

I do not introduce any new locks with this patch, locking the
linked list on each "side" of the anon_vma_link with the lock
on that side - the anon_vma lock for the same_anon_vma list
and the per-mm locks on the vma side of the list.

>> @@ -516,7 +517,8 @@ static int shift_arg_pages(struct vm_area_struct *vma, unsigned long shift)
>>   	/*
>>   	 * cover the whole range: [new_start, old_end)
>>   	 */
>> -	vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL);
>> +	if (vma_adjust(vma, new_start, old_end, vma->vm_pgoff, NULL))
>> +		return -ENOMEM;
>
> shift_arg_pages() have two vma_adjust() call. why don't we need change both?

Because shrinking a VMA cannot fail.  Looking at it some
more, this call cannot fail either because we check that
there is enough space to grow this VMA downward.

>
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 84a524a..44cfb13 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -167,7 +167,7 @@ struct vm_area_struct {
>>   	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
>>   	 * or brk vma (with NULL file) can only be in an anon_vma list.
>>   	 */
>> -	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
>> +	struct list_head anon_vma_chain; /* Serialized by anon_vma->lock */
>>   	struct anon_vma *anon_vma;	/* Serialized by page_table_lock */
>
> Is this comment really correct? for example, following vma->anon_vma_chain
> operation is in place out of anon_vma lock.

> I guess you intend to write /* locked by mmap_sem&  friends */.

You are right. I will fix that comment.

> note: however I don't think "&  friends" is good comment ;-)

No kidding - however this is how mmap.c already serializes
all kinds of things :)

>
>>   	/* Function pointers to deal with this struct. */
>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>> index b019ae6..0d1903a 100644
>> --- a/include/linux/rmap.h
>> +++ b/include/linux/rmap.h
>> @@ -37,7 +37,27 @@ struct anon_vma {
>>   	 * is serialized by a system wide lock only visible to
>>   	 * mm_take_all_locks() (mm_all_locks_mutex).
>>   	 */
>> -	struct list_head head;	/* List of private "related" vmas */
>> +	struct list_head head;	/* Chain of private "related" vmas */
>> +};
>
> Hmm..
> It seems unclear comment. this list head don't linked struct vm_area_struct.
> instead, linked struct anon_vma_chain. so "related vmas" isn't kindly comment.

True, it is a chain that points to the related VMAs.

>
>> +
>> +/*
>> + * The copy-on-write semantics of fork mean that an anon_vma
>> + * can become associated with multiple processes. Furthermore,
>> + * each child process will have its own anon_vma, where new
>> + * pages for that process are instantiated.
>> + *
>> + * This structure allows us to find the anon_vmas associated
>> + * with a VMA, or the VMAs associated with an anon_vma.
>> + * The "same_vma" list contains the anon_vma_chains linking
>> + * all the anon_vmas associated with this VMA.
>> + * The "same_anon_vma" list contains the anon_vma_chains
>> + * which link all the VMAs associated with this anon_vma.
>> + */
>> +struct anon_vma_chain {
>> +	struct vm_area_struct *vma;
>> +	struct anon_vma *anon_vma;
>> +	struct list_head same_vma;	/* locked by mmap_sem&  friends */
>> +	struct list_head same_anon_vma;	/* locked by anon_vma->lock */
>>   };
>
> Probably, This place need more lots comments. struct anon_vma_chain
> makes very complex relationship graph. example or good ascii art is needed.
> especially, fork parent and child have different anon_vma_chain. it
> seems tricky.

I guess I'll have to draw up some ascii art...

>> +static inline void anon_vma_merge(struct vm_area_struct *vma,
>> +				  struct vm_area_struct *next)
>> +{
>> +	BUG_ON(vma->anon_vma != next->anon_vma);
>> +	unlink_anon_vmas(next);
>> +}
>> +
>
> Probably VM_BUG_ON is enough?

OK.

>> @@ -792,11 +809,13 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
>>   				is_mergeable_anon_vma(prev->anon_vma,
>>   						      next->anon_vma)) {
>>   							/* cases 1, 6 */
>> -			vma_adjust(prev, prev->vm_start,
>> +			err = vma_adjust(prev, prev->vm_start,
>>   				next->vm_end, prev->vm_pgoff, NULL);
>>   		} else					/* cases 2, 5, 7 */
>> -			vma_adjust(prev, prev->vm_start,
>> +			err = vma_adjust(prev, prev->vm_start,
>>   				end, prev->vm_pgoff, NULL);
>> +		if (err)
>> +			return NULL;
>>   		return prev;
>>   	}
>
> Currently, the callers of vma_merge() assume vma_merge doesn't failure.
> IOW, they don't think return NULL is failure.
>
> Probably we need to change all callers too.

Are you sure?  To me it looks like vma_merge returns NULL when it
fails to do a merge, leaving the VMAs alone as a result.

What am I missing?

>> @@ -2454,7 +2506,8 @@ int mm_take_all_locks(struct mm_struct *mm)
>>   		if (signal_pending(current))
>>   			goto out_unlock;
>>   		if (vma->anon_vma)
>> -			vm_lock_anon_vma(mm, vma->anon_vma);
>> +			list_for_each_entry(avc,&vma->anon_vma_chain, same_vma)
>> +				vm_lock_anon_vma(mm, avc->anon_vma);
>>   	}
>
> This function is not protected by mmap_sem. but anon_vma_chain->same_vma
> iteration need to mmap_sem if your commnet is correct.

The comment above mm_take_all_locks says:

  * The caller must take the mmap_sem in write mode before calling
  * mm_take_all_locks(). The caller isn't allowed to release the
  * mmap_sem until mm_drop_all_locks() returns.

>> @@ -188,10 +276,21 @@ static void anon_vma_ctor(void *data)
>>   	INIT_LIST_HEAD(&anon_vma->head);
>>   }
>
>
>>   void __init anon_vma_init(void)
>>   {
>>   	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
>>   			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
>> +	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
>> +			sizeof(struct anon_vma_chain), 0,
>> +			SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_chain_ctor);
>>   }
>
> Why do we need SLAB_DESTROY_BY_RCU?
> anon_vma's one is required by page migration. (Oops, It should be commented, I think)
> but which code require anon_vma_chain's one?

I just copied that code over - I guess we don't need that flag
and I'll remove it.

>>   /*
>> @@ -240,6 +339,14 @@ vma_address(struct page *page, struct vm_area_struct *vma)
>>   		/* page should be within @vma mapping range */
>>   		return -EFAULT;
>>   	}
>> +	if (unlikely(vma->vm_flags&  VM_LOCK_RMAP))
>> +		/*
>> +		 * This VMA is being unlinked or not yet linked into the
>> +		 * VMA tree.  Do not try to follow this rmap.  This race
>> +		 * condition can result in page_referenced ignoring a
>> +		 * reference or try_to_unmap failing to unmap a page.
>> +		 */
>> +		return -EFAULT;
>>   	return address;
>>   }
>
> In this place, the task have anon_vma->lock, but don't have mmap_sem.
> But, VM_LOCK_RMAP changing point (i.e. vma_adjust()) is protected by mmap_sem.
>
> IOW, "if (vma->vm_flags&  VM_LOCK_RMAP)" return unstable value. Why can we use
> unstable value as "lock"?

That's a good question.  I will have to think about it some more.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
