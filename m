Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A462B6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 18:41:18 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so5290613vcb.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 15:41:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5093FA42.50806@redhat.com>
References: <1351679605-4816-1-git-send-email-walken@google.com>
	<1351679605-4816-5-git-send-email-walken@google.com>
	<5093FA42.50806@redhat.com>
Date: Fri, 2 Nov 2012 15:41:17 -0700
Message-ID: <CANN689Gy9izaMwrOfHi2wRcGD8Mi_x_m89YEj7qd4oyuMVCpZA@mail.gmail.com>
Subject: Re: [RFC PATCH 4/6] mm: vm_unmapped_area() lookup function
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, Nov 2, 2012 at 9:52 AM, Rik van Riel <riel@redhat.com> wrote:
> On 10/31/2012 06:33 AM, Michel Lespinasse wrote:
>
>> +/*
>> + * Search for an unmapped address range.
>> + *
>> + * We are looking for a range that:
>> + * - does not intersect with any VMA;
>> + * - is contained within the [low_limit, high_limit[ interval;
>
> bracket is the wrong way around :)

Ah, I meant to indicate the byte at high_limit is not included in the interval.
I think the convention people are used to here would be [low_limit, high_limit)

>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -1494,6 +1494,206 @@ unacct_error:
>>         return error;
>>   }
>>
>> +unsigned long unmapped_area(struct vm_unmapped_area_info *info)
>> +{
>> +       /*
>> +        * We implement the search by looking for an rbtree node that
>> +        * immediately follows a suitable gap. That is,
>> +        * - gap_start = vma->vm_prev->vm_end <= info->high_limit -
>> length;
>> +        * - gap_end   = vma->vm_start        >= info->low_limit  +
>> length;
>> +        * - gap_end - gap_start >= length
>> +        */
>> +
>> +       struct mm_struct *mm = current->mm;
>> +       struct vm_area_struct *vma;
>> +       unsigned long length, low_limit, high_limit, gap_start, gap_end;
>> +
>> +       /* Adjust search length to account for worst case alignment
>> overhead */
>> +       length = info->length + info->align_mask;
>> +       if (length < info->length)
>> +               return -ENOMEM;
>
>
> If we unmap a VMA that is size N and correctly aligned, then
> we may leave a gap of size N.
>
> A subsequent call to mmap should be able to find that gap,
> and use it.
>
> It may make sense to not add the align_mask the first time
> around, and see if the gap that we find already has the
> correct alignment.
>
> If it does not, we can always add the align_mask, and do
> a second search for a hole of N + align_mask:
>
> if (hole not aligned) {
>     length += info->align_mask;
>     goto again;
>
> }

I guess the suggestion is OK in the sense that I can't see a case
where it'd hurt. However, it still won't find all cases where we just
unmapped a region of size N with the correct alignment - it could be
that the first region we find has insufficient alignment, and then the
search with an increased length could fail, even though there exists
an aligned gap (just not the first) of the desired size. So, this is
only a partial solution.

Another suggestion I thought about (but thought it may be overkill)
would be to use an extra field (maybe stored in the lowest bits of
rb_subtree_gap) to indicate the largest *aligned* gap preceding vmas
within a subtree: if the value would be N, there would have to be an
gap of size PAGE_SIZE<<N and aligned to PAGE_SIZE<<N. This still
doesn't solve the general problem, but does help in the case of
wanting to allocate an aligned power-of-2 sized vma.

Unfortunately, I don't think there is an efficient solution to the
general problem, and the partial solutions discussed above (both yours
and mine) don't seem to cover enough cases to warrant the complexity
IMO...

>> @@ -1603,53 +1777,12 @@ arch_get_unmapped_area_topdown(struct file *filp,
>> const unsigned long addr0,
>>                         return addr;
>>         }
>>
> ...
>
>
>> +       info.flags = VM_UNMAPPED_AREA_TOPDOWN;
>> +       info.length = len;
>> +       info.low_limit = 0;
>> +       info.high_limit = mm->mmap_base;
>> +       info.align_mask = 0;
>> +       addr = vm_unmapped_area(&info);
>
> I believe it would be better to set low_limit to PAGE_SIZE.

Noted. I should probably have tried that first as this is the safer option.
(It's one of the things I had noted in my 0/6 email reply: the
original code seems to be inconsistent here as it'd allow allocation
at address 0 on the first loop iteration but fail it on further
iterations)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
