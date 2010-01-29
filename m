Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 733A16B0047
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 18:58:18 -0500 (EST)
Message-ID: <4B6375EC.6080006@redhat.com>
Date: Fri, 29 Jan 2010 18:57:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] change anon_vma linking to fix multi-process server
 scalability issue
References: <20100128002000.2bf5e365@annuminas.surriel.com> <20100129151423.8b71b88e.akpm@linux-foundation.org>
In-Reply-To: <20100129151423.8b71b88e.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/29/2010 06:14 PM, Andrew Morton wrote:

>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -96,7 +96,11 @@ extern unsigned int kobjsize(const void *objp);
>>   #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
>>   #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
>>   #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
>> +#ifdef CONFIG_MMU
>> +#define VM_LOCK_RMAP	0x01000000	/* Do not follow this rmap (mmu mmap) */
>> +#else
>>   #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
>> +#endif
>
> What's the locking for vma_area_struct.vm_flags?  It's somewhat
> unobvious what that is, and whether the code here observes it.

I believe the mmap_sem protects everything in the VMAs,
including the VMA flags.

>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -167,7 +167,7 @@ struct vm_area_struct {
>>   	 * can only be in the i_mmap tree.  An anonymous MAP_PRIVATE, stack
>>   	 * or brk vma (with NULL file) can only be in an anon_vma list.
>>   	 */
>> -	struct list_head anon_vma_node;	/* Serialized by anon_vma->lock */
>> +	struct list_head anon_vma_chain; /* Serialized by mmap_sem&  friends */
>
> Can we be a bit more explicit than "and friends"?

I believe this is either the mmap_sem for write, or
the mmap_sem for read, plus the mm->page_table_lock.

I guess the comment should be something like

	/* Serialized by mmap_sem and page_table_lock */

>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -328,15 +328,17 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>>   		if (!tmp)
>>   			goto fail_nomem;
>>   		*tmp = *mpnt;
>> +		INIT_LIST_HEAD(&tmp->anon_vma_chain);
>>   		pol = mpol_dup(vma_policy(mpnt));
>>   		retval = PTR_ERR(pol);
>>   		if (IS_ERR(pol))
>>   			goto fail_nomem_policy;
>>   		vma_set_policy(tmp, pol);
>> +		if (anon_vma_fork(tmp, mpnt))
>> +			goto fail_nomem_anon_vma_fork;
>
> Didn't we just leak `pol'?

Yes we did.  I missed a line of code there!

>> @@ -542,6 +541,29 @@ again:			remove_next = 1 + (end>  next->vm_end);
>>   		}
>>   	}
>>
>> +	/*
>> +	 * When changing only vma->vm_end, we don't really need
>> +	 * anon_vma lock.
>> +	 */
>> +	if (vma->anon_vma&&  (insert || importer || start != vma->vm_start))
>> +		anon_vma = vma->anon_vma;
>> +	if (anon_vma) {
>> +		/*
>> +		 * Easily overlooked: when mprotect shifts the boundary,
>> +		 * make sure the expanding vma has anon_vma set if the
>> +		 * shrinking vma had, to cover any anon pages imported.
>> +		 */
>> +		if (importer&&  !importer->anon_vma) {
>> +			/* Block reverse map lookups until things are set up. */
>
> Here, it'd be nice to explain the _reason_ for doing this.

Looking at it some more, I believe we should be able to do without
this code.

Worst case we end up with the rmap code being unable to find some
pages because the VMA state is inconsistent, but that should be
fine - same result as not trying the lookup in the first place.

Want me to send a patch to remove this logic, in addition to the
patch that fixes the problems you pointed out above?

>> @@ -1868,11 +1893,14 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>>
>>   	pol = mpol_dup(vma_policy(vma));
>>   	if (IS_ERR(pol)) {
>> -		kmem_cache_free(vm_area_cachep, new);
>> -		return PTR_ERR(pol);
>> +		err = PTR_ERR(pol);
>> +		goto out_free_vma;
>>   	}
>>   	vma_set_policy(new, pol);
>>
>> +	if (anon_vma_clone(new, vma))
>> +		goto out_free_mpol;
>
> The handling of `err' in this function is a bit tricksy.  It's correct,
> but not obviously so and we might break it in the future.  One way to
> address that would be to sprinkle `err = -ENOMEM' everywhere and
> wouldn't be very nice.  Ho hum.

Indeed.  I can't think of a nice way to improve this...

>>   	if (new->vm_file) {
>>   		get_file(new->vm_file);
>>   		if (vma->vm_flags&  VM_EXECUTABLE)
>> @@ -1883,12 +1911,28 @@ static int __split_vma(struct mm_struct * mm, struct vm_area_struct * vma,
>>   		new->vm_ops->open(new);
>>
>>   	if (new_below)
>> -		vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
>> +		err = vma_adjust(vma, addr, vma->vm_end, vma->vm_pgoff +
>>   			((addr - new->vm_start)>>  PAGE_SHIFT), new);
>>   	else
>> -		vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
>> +		err = vma_adjust(vma, vma->vm_start, addr, vma->vm_pgoff, new);
>>
>> -	return 0;
>> +	/* Success. */
>> +	if (!err)
>> +		return 0;
>> +
>> +	/* Clean everything up if vma_adjust failed. */
>> +	new->vm_ops->close(new);
>> +	if (new->vm_file) {
>> +		if (vma->vm_flags&  VM_EXECUTABLE)
>> +			removed_exe_file_vma(mm);
>> +		fput(new->vm_file);
>> +	}
>
> Did the above path get tested?

No, I just audited the code very carefully to make sure that
vma_adjust will only return an error before anything related
to the VMAs has been changed.

If such an error happens, all the code above gets undone in
the opposite order from which it happened originally.

>> +	/*
>> +	 * First, attach the new VMA to the parent VMA's anon_vmas,
>> +	 * so rmap can find non-COWed pages in child processes.
>> +	 */
>> +	if (anon_vma_clone(vma, pvma))
>> +		return -ENOMEM;
>> +
>> +	/* Then add our own anon_vma. */
>> +	anon_vma = anon_vma_alloc();
>> +	if (!anon_vma)
>> +		goto out_error;
>> +	avc = anon_vma_chain_alloc();
>> +	if (!avc)
>> +		goto out_error_free_anon_vma;
>
> The error paths here don't undo the results of anon_vma_clone().  I
> guess all those anon_vma_chains get unlinked and freed later on?
> free/exit()?

If anon_vma_clone fails, it cleans up its own mess by calling
unlink_anon_vmas on the VMA.

>> @@ -192,6 +280,9 @@ void __init anon_vma_init(void)
>>   {
>>   	anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
>>   			0, SLAB_DESTROY_BY_RCU|SLAB_PANIC, anon_vma_ctor);
>> +	anon_vma_chain_cachep = kmem_cache_create("anon_vma_chain",
>> +			sizeof(struct anon_vma_chain), 0,
>> +			SLAB_PANIC, NULL);
>
> Could use KMEM_CACHE() here.

I'll add that to the cleanup patch.

> Trivial touchups:

I'll put my cleanup patches on top of your trivial touchups.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
