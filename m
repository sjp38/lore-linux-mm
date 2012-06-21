Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 4AEFE6B00CD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 09:17:59 -0400 (EDT)
Message-ID: <4FE31ED7.4000305@redhat.com>
Date: Thu, 21 Jun 2012 09:17:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
References: <1340057126-31143-1-git-send-email-riel@redhat.com> <1340057126-31143-3-git-send-email-riel@redhat.com> <20120621090157.GG27816@cmpxchg.org>
In-Reply-To: <20120621090157.GG27816@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/21/2012 05:01 AM, Johannes Weiner wrote:

>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index bf56d66..8ccb4e1 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -307,6 +307,7 @@ struct mm_struct {
>>   	unsigned long task_size;		/* size of task vm space */
>>   	unsigned long cached_hole_size; 	/* if non-zero, the largest hole below free_area_cache */
>>   	unsigned long free_area_cache;		/* first hole of size cached_hole_size or larger */
>> +	unsigned long highest_vma;		/* highest vma end address */
>
> It's not clear from the name that this is an end address.  Would
> highest_vm_end be better?

Good idea.  Will fix.

>> +	/* Find the left-most free area of sufficient size. */
>> +	for (addr = 0, rb_node = mm->mm_rb.rb_node; rb_node; ) {
>> +		unsigned long vma_start;
>> +		int found_here = 0;
>> +
>> +		vma = rb_to_vma(rb_node);
>> +
>> +		if (vma->vm_start>  len) {
>
> vmas can abut, and vma->vm_end == vma->vm_next->vm_start.  Should this
> be>=?

We do not want to mmap at address 0.

>> +		/* Go left if it looks promising. */
>> +		if (node_free_hole(rb_node->rb_left)>= len&&
>> +					vma->vm_start - len>= lower_limit) {
>> +			rb_node = rb_node->rb_left;
>> +			continue;
>
> If we already are at a vma whose start has a lower address than the
> overall length, does it make sense to check for a left hole?
> I.e. shouldn't this be inside the if (vma->vm_start>  len) block?

I am trying to preserve the same fragmentation
semantics as the current code, so we do not
get any regressions in that area.

>> +	/*
>> +	 * There is not enough space to the left of any VMA.
>> +	 * Check the far right-hand side of the VMA tree.
>> +	 */
>> +	rb_node = mm->mm_rb.rb_node;
>> +	while (rb_node->rb_right)
>> +		rb_node = rb_node->rb_right;
>> +	vma = rb_to_vma(rb_node);
>> +	addr = vma->vm_end;
>
> Unless I missed something, we only reach here when
> continue_next_right(rb_node) above returned NULL.  And if it does, the
> rb_node it was passed was the right-most node in the tree, so we could
> do something like

We break out of the large while() loop once rb_node
is NULL, due to falling off the end of the tree.

> 	} else if (!addr) {
> 		struct rb_node *rb_right = continue_next_right(rb_node);
> 		if (!rb_right)
> 			break;
> 		rb_node = rb_right;
> 		continue;
> 	}
>
> above and then save the lookup after the loop.

That might work, but I expect the situation to be rare
enough that I would rather pick the more readable option.

> Also, dereferencing mm->mm_rb.rb_node unconditionally after the loop
> assumes that the tree always contains at least one vma.  Is this
> guaranteed for all architectures?

When a process is execve'd, a stack VMA is set up.
This means every process has at least one VMA by the
time we can get to this code.

>> -fail:
>> -	/*
>> -	 * if hint left us with no space for the requested
>> -	 * mapping then try again:
>> -	 *
>> -	 * Note: this is different with the case of bottomup
>> -	 * which does the fully line-search, but we use find_vma
>> -	 * here that causes some holes skipped.
>> -	 */
>> -	if (start_addr != mm->mmap_base) {
>> -		mm->free_area_cache = mm->mmap_base;
>> -		mm->cached_hole_size = 0;
>> -		goto try_again;
>> +		if (!found_here&&  node_free_hole(rb_node->rb_left)>= len) {
>> +			/* Last known hole is to the right of this subtree. */
>
> "to the left"

Thanks, will fix.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
