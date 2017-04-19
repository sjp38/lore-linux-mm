Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA0886B03B8
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 04:14:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 68so9565916pgj.23
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 01:14:46 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 63si1679990pgi.231.2017.04.19.01.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 01:14:46 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
References: <20170407064901.25398-1-ying.huang@intel.com>
	<20170418045909.GA11015@bbox>
Date: Wed, 19 Apr 2017 16:14:43 +0800
In-Reply-To: <20170418045909.GA11015@bbox> (Minchan Kim's message of "Tue, 18
	Apr 2017 13:59:09 +0900")
Message-ID: <87y3uwrez0.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Fri, Apr 07, 2017 at 02:49:01PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> To reduce the lock contention of swap_info_struct->lock when freeing
>> swap entry.  The freed swap entries will be collected in a per-CPU
>> buffer firstly, and be really freed later in batch.  During the batch
>> freeing, if the consecutive swap entries in the per-CPU buffer belongs
>> to same swap device, the swap_info_struct->lock needs to be
>> acquired/released only once, so that the lock contention could be
>> reduced greatly.  But if there are multiple swap devices, it is
>> possible that the lock may be unnecessarily released/acquired because
>> the swap entries belong to the same swap device are non-consecutive in
>> the per-CPU buffer.
>> 
>> To solve the issue, the per-CPU buffer is sorted according to the swap
>> device before freeing the swap entries.  Test shows that the time
>> spent by swapcache_free_entries() could be reduced after the patch.
>> 
>> Test the patch via measuring the run time of swap_cache_free_entries()
>> during the exit phase of the applications use much swap space.  The
>> results shows that the average run time of swap_cache_free_entries()
>> reduced about 20% after applying the patch.
>> 
>> Signed-off-by: Huang Ying <ying.huang@intel.com>
>> Acked-by: Tim Chen <tim.c.chen@intel.com>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> 
>> v3:
>> 
>> - Add some comments in code per Rik's suggestion.
>> 
>> v2:
>> 
>> - Avoid sort swap entries if there is only one swap device.
>> ---
>>  mm/swapfile.c | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>> 
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 90054f3c2cdc..f23c56e9be39 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -37,6 +37,7 @@
>>  #include <linux/swapfile.h>
>>  #include <linux/export.h>
>>  #include <linux/swap_slots.h>
>> +#include <linux/sort.h>
>>  
>>  #include <asm/pgtable.h>
>>  #include <asm/tlbflush.h>
>> @@ -1065,6 +1066,13 @@ void swapcache_free(swp_entry_t entry)
>>  	}
>>  }
>>  
>> +static int swp_entry_cmp(const void *ent1, const void *ent2)
>> +{
>> +	const swp_entry_t *e1 = ent1, *e2 = ent2;
>> +
>> +	return (long)(swp_type(*e1) - swp_type(*e2));
>> +}
>> +
>>  void swapcache_free_entries(swp_entry_t *entries, int n)
>>  {
>>  	struct swap_info_struct *p, *prev;
>> @@ -1075,6 +1083,10 @@ void swapcache_free_entries(swp_entry_t *entries, int n)
>>  
>>  	prev = NULL;
>>  	p = NULL;
>> +
>> +	/* Sort swap entries by swap device, so each lock is only taken once. */
>> +	if (nr_swapfiles > 1)
>> +		sort(entries, n, sizeof(entries[0]), swp_entry_cmp, NULL);
>
> Let's think on other cases.
>
> There are two swaps and they are configured by priority so a swap's usage
> would be zero unless other swap used up. In case of that, this sorting
> is pointless.
>
> As well, nr_swapfiles is never decreased so if we enable multiple
> swaps and then disable until a swap is remained, this sorting is
> pointelss, too.
>
> How about lazy sorting approach? IOW, if we found prev != p and,
> then we can sort it.

Yes.  That should be better.  I just don't know whether the added
complexity is necessary, given the array is short and sort is fast.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
