Received: by rv-out-0708.google.com with SMTP id f25so4696494rvb.26
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 04:15:16 -0700 (PDT)
Message-ID: <86802c440807280415j5605822brb8836412a5c95825@mail.gmail.com>
Date: Mon, 28 Jul 2008 04:15:16 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: + mm-remove-find_max_pfn_with_active_regions.patch added to -mm tree
In-Reply-To: <20080728091655.GC7965@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200807280313.m6S3DHDk017400@imap1.linux-foundation.org>
	 <20080728091655.GC7965@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 28, 2008 at 2:16 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On (27/07/08 20:13), akpm@linux-foundation.org didst pronounce:
>>
>> The patch titled
>>      mm: remove find_max_pfn_with_active_regions
>> has been added to the -mm tree.  Its filename is
>>      mm-remove-find_max_pfn_with_active_regions.patch
>>
>> Before you just go and hit "reply", please:
>>    a) Consider who else should be cc'ed
>>    b) Prefer to cc a suitable mailing list as well
>>    c) Ideally: find the original patch on the mailing list and do a
>>       reply-to-all to that, adding suitable additional cc's
>>
>> *** Remember to use Documentation/SubmitChecklist when testing your code ***
>>
>> See http://www.zip.com.au/~akpm/linux/patches/stuff/added-to-mm.txt to find
>> out what to do about this
>>
>> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmotm/
>>
>> ------------------------------------------------------
>> Subject: mm: remove find_max_pfn_with_active_regions
>> From: Yinghai Lu <yhlu.kernel@gmail.com>
>>
>> It has no user now
>>
>> Also print out info about adding/removing active regions.
>>
>> Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
>> Cc: Mel Gorman <mel@csn.ul.ie>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  include/linux/mm.h |    1 -
>>  mm/page_alloc.c    |   22 ++--------------------
>>  2 files changed, 2 insertions(+), 21 deletions(-)
>>
>> diff -puN include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions include/linux/mm.h
>> --- a/include/linux/mm.h~mm-remove-find_max_pfn_with_active_regions
>> +++ a/include/linux/mm.h
>> @@ -1041,7 +1041,6 @@ extern unsigned long absent_pages_in_ran
>>  extern void get_pfn_range_for_nid(unsigned int nid,
>>                       unsigned long *start_pfn, unsigned long *end_pfn);
>>  extern unsigned long find_min_pfn_with_active_regions(void);
>> -extern unsigned long find_max_pfn_with_active_regions(void);
>>  extern void free_bootmem_with_active_regions(int nid,
>>                                               unsigned long max_low_pfn);
>>  typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
>> diff -puN mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions mm/page_alloc.c
>> --- a/mm/page_alloc.c~mm-remove-find_max_pfn_with_active_regions
>> +++ a/mm/page_alloc.c
>> @@ -3572,8 +3572,7 @@ void __init add_active_range(unsigned in
>>  {
>>       int i;
>>
>> -     mminit_dprintk(MMINIT_TRACE, "memory_register",
>> -                     "Entering add_active_range(%d, %#lx, %#lx) "
>> +     printk(KERN_INFO "Adding active range (%d, %#lx, %#lx) "
>>                       "%d entries of %d used\n",
>>                       nid, start_pfn, end_pfn,
>>                       nr_nodemap_entries, MAX_ACTIVE_REGIONS);
>
> Why are the mminit_dprintk() calls being converted to printk(KERN_INFO)?  On
> some machines, this will be very noisy. For example, some POWER configurations
> will print out one line for every 16MB of memory with this patch.

I don't know, on x86 esp the first node, that is some informative.
or change that back to printk(KERN_DEBUG) ?

hope the user put debug on command_line to get enough info.

otherwise without "mminit_loglevel=" will get that debug info.

>
>> @@ -3635,7 +3634,7 @@ void __init remove_active_range(unsigned
>>       int i, j;
>>       int removed = 0;
>>
>> -     printk(KERN_DEBUG "remove_active_range (%d, %lu, %lu)\n",
>> +     printk(KERN_INFO "Removing active range (%d, %#lx, %#lx)\n",
>>                         nid, start_pfn, end_pfn);
>>
>
> This call is a lot rarer but I still don't see why it is being moved to
> KERN_INFO. If anything, that should have been another mminit_printk() call
> and one I obviously missed.
use by 32bit x86 only.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
