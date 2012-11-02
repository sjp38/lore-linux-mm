Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3BBE76B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 12:52:32 -0400 (EDT)
Message-ID: <5093FA42.50806@redhat.com>
Date: Fri, 02 Nov 2012 12:52:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/6] mm: vm_unmapped_area() lookup function
References: <1351679605-4816-1-git-send-email-walken@google.com> <1351679605-4816-5-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-5-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 10/31/2012 06:33 AM, Michel Lespinasse wrote:

> +/*
> + * Search for an unmapped address range.
> + *
> + * We are looking for a range that:
> + * - does not intersect with any VMA;
> + * - is contained within the [low_limit, high_limit[ interval;
                                                       ^
bracket is the wrong way around :)

> + * - is at least the desired size.
> + * - satisfies (begin_addr & align_mask) == (align_offset & align_mask)
> + */
> +static inline unsigned long
> +vm_unmapped_area(struct vm_unmapped_area_info *info)
> +{
> +	if (!(info->flags & VM_UNMAPPED_AREA_TOPDOWN))
> +		return unmapped_area(info);
> +	else
> +		return unmapped_area_topdown(info);
> +}

I like how you pass all the info in the struct. That solves
some of the problems I was trying to deal with when I implemented
something similar.

> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1494,6 +1494,206 @@ unacct_error:
>   	return error;
>   }
>
> +unsigned long unmapped_area(struct vm_unmapped_area_info *info)
> +{
> +	/*
> +	 * We implement the search by looking for an rbtree node that
> +	 * immediately follows a suitable gap. That is,
> +	 * - gap_start = vma->vm_prev->vm_end <= info->high_limit - length;
> +	 * - gap_end   = vma->vm_start        >= info->low_limit  + length;
> +	 * - gap_end - gap_start >= length
> +	 */
> +
> +	struct mm_struct *mm = current->mm;
> +	struct vm_area_struct *vma;
> +	unsigned long length, low_limit, high_limit, gap_start, gap_end;
> +
> +	/* Adjust search length to account for worst case alignment overhead */
> +	length = info->length + info->align_mask;
> +	if (length < info->length)
> +		return -ENOMEM;

If we unmap a VMA that is size N and correctly aligned, then
we may leave a gap of size N.

A subsequent call to mmap should be able to find that gap,
and use it.

It may make sense to not add the align_mask the first time
around, and see if the gap that we find already has the
correct alignment.

If it does not, we can always add the align_mask, and do
a second search for a hole of N + align_mask:

if (hole not aligned) {
     length += info->align_mask;
     goto again;
}

> @@ -1603,53 +1777,12 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>   			return addr;
>   	}
>
...

> +	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
> +	info.length = len;
> +	info.low_limit = 0;
> +	info.high_limit = mm->mmap_base;
> +	info.align_mask = 0;
> +	addr = vm_unmapped_area(&info);

I believe it would be better to set low_limit to PAGE_SIZE.

Otherwise we can return 0, which is indistinguishable from a null
pointer.  Keeping address 0 unmapped provides the security benefit
that code that can be made to address null pointers causes a crash,
instead of a potential privilege escalation.

The rest of the patch looks good.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
