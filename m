Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 0CF4A6B00E9
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 14:09:24 -0400 (EDT)
Message-ID: <4FE3598B.2070209@redhat.com>
Date: Thu, 21 Jun 2012 13:27:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 2/7] mm: get unmapped area from VMA tree
References: <1340057126-31143-1-git-send-email-riel@redhat.com> <1340057126-31143-3-git-send-email-riel@redhat.com> <20120621161651.GD3953@csn.ul.ie>
In-Reply-To: <20120621161651.GD3953@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/21/2012 12:16 PM, Mel Gorman wrote:
> On Mon, Jun 18, 2012 at 06:05:21PM -0400, Rik van Riel wrote:
>> From: Rik van Riel<riel@surriel.com>
>>
>> Change the generic implementations of arch_get_unmapped_area(_topdown)
>> to use the free space info in the VMA rbtree. This makes it possible
>> to find free address space in O(log(N)) complexity.
>>
>> For bottom-up allocations, we pick the lowest hole that is large
>> enough for our allocation. For topdown allocations, we pick the
>> highest hole of sufficient size.
>>
>> For topdown allocations, we need to keep track of the highest
>> mapped VMA address, because it might be below mm->mmap_base,
>> and we only keep track of free space to the left of each VMA
>> in the VMA tree.  It is tempting to try and keep track of
>> the free space to the right of each VMA when running in
>> topdown mode, but that gets us into trouble when running on
>> x86, where a process can switch direction in the middle of
>> execve.
>>
>> We have to leave the mm->free_area_cache and mm->largest_hole_size
>> in place for now, because the architecture specific versions still
>> use those.
>>
>
> Stick them under a config ARCH_USES_GENERIC_GET_UNMAPPED?

I cannot do that yet, because hugetlbfs still
uses its own get_unmapped_area.

Once Andi Kleen's "[PATCH] MM: Support more
pagesizes for MAP_HUGETLB/SHM_HUGETLB" patch is
in, I can get rid of the separate get_unmapped_area
functions for hugetlbfs.

> Worth mentioning in the changelog that the reduced search time means that
> we no longer need free_area_cache and instead do a search from the root
> RB node every time.

Will do.

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
> With a name like highest_vma I would expect it to be a struct
> vm_area_struct. Name it highest_mapped_addr or something.

I went with the name Johannes came up with,
highest_vm_end :)

>> +static unsigned long node_free_hole(struct rb_node *node)
>> +{
>> +	struct vm_area_struct *vma;
>> +
>> +	if (!node)
>> +		return 0;
>> +
>> +	vma = container_of(node, struct vm_area_struct, vm_rb);
>
> What's wrong with using rb_to_vma?

Absolutely nothing.  I just wrote this function before
I realized I would end up using container_of way too
much and created the rb_to_vma helper.

Fixed now. Thank you for spotting this one.

> return node ? rb_to_vma(node)->free_gap : 0;
>
>> +	return vma->free_gap;
>> +}
>
> function calls it free_hole but vma calls it free_gap. Pick one or
> replace the function with an inlined one-liner.

I am now using free_gap everywhere.  Thanks for
pointing out this inconsistency.

>> @@ -1456,13 +1477,29 @@ unacct_error:
>>    * This function "knows" that -ENOMEM has the bits set.
>>    */
>>   #ifndef HAVE_ARCH_UNMAPPED_AREA
>> +struct rb_node *continue_next_right(struct rb_node *node)
>> +{
>
> I get the very strong impression that you were translating a lot of notes
> and diagrams into code because you appear to be immune to commenting :)
>
> This is not returning the next right node because to me that means you
> are walking down the tree. Here you are walking "up" the tree finding a
> node to the right
>
> /*
>   * find_next_right_uncle - Find the an "uncle" node to the "right"
>   *
>   * An "uncle" node is a sibling node of your parent and this function
>   * returns an uncle to the right. Given the following basic tree, the
>   * node U is an uncle of node C. P is C's parent and G is C's grandparent
>   *
>   *
>   *                G
>   *               / \
>   *              P   U
>   *               \
>   *                C
>   * This is necessary when searching
>   * for a larger gap in the address space.
>   */
>
> MUWUHAhaha, watch as I destroy your attempts to reduce line count in
> your diffstat.

Better yet, you have convinced me to add an additional
patch to the series, because this code is useful to have
in the generic augmented rbtree code.

Surely there must be other augmented rbtree users that
want to find something in the tree based on the augmented
data, ie. not using the sort key as the primary search
criterium.

>> +		unsigned long vma_start;
>> +		int found_here = 0;
>> +
>
> bool.

Consider it done.

>> +		vma = container_of(rb_node, struct vm_area_struct, vm_rb);
>>
>
> rb_to_vma

Got it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
