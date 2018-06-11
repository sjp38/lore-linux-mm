Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3956B02B9
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:51:50 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h18-v6so4616604wmb.8
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:51:50 -0700 (PDT)
Received: from mx0b-00190b01.pphosted.com (mx0b-00190b01.pphosted.com. [2620:100:9005:57f::1])
        by mx.google.com with ESMTPS id k74-v6si6261458wmd.165.2018.06.11.07.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 07:51:49 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
Date: Mon, 11 Jun 2018 10:51:44 -0400
MIME-Version: 1.0
In-Reply-To: <20180611072005.GC13364@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net

On 06/11/2018 03:20 AM, Michal Hocko wrote:
> [CCing linux-api - please make sure to CC this mailing list anytime you
>  are touching user visible apis]
> 
> On Fri 08-06-18 14:56:52, Jason Baron wrote:
>> In order to free memory that is marked MLOCK_ONFAULT, the memory region
>> needs to be first unlocked, before calling MADV_DONTNEED. And if the region
>> is to be reused as MLOCK_ONFAULT, we require another call to mlock2() with
>> the MLOCK_ONFAULT flag.
>>
>> Let's simplify freeing memory that is set MLOCK_ONFAULT, by allowing
>> MADV_DONTNEED to work directly for memory that is set MLOCK_ONFAULT.
> 
> I do not understand the point here. How is MLOCK_ONFAULT any different
> from the regular mlock here? If you want to free mlocked memory then
> fine but the behavior should be consistent. MLOCK_ONFAULT is just a way
> to say that we do not want to pre-populate the mlocked area and do that
> lazily on the page fault time. madvise should make any difference here.
>

The difference for me is after the page has been freed, MLOCK_ONFAULT
will re-populate the range if its accessed again. Whereas with regular
mlock I don't think it will because its normally done at mlock() or
mmap() time. In any case, the state of a region being locked with
regular mlock and pages not present does not currently exist, whereas it
does for MLOCK_ONFAULT, so it seems more natural to do it only for
MLOCK_ONFAULT. Finally, the use-case we had for this, didn't need
regular mlock().

> That being said we do not allow MADV_DONTNEED on VM_LOCKED since ever. I
> do not really see why but this would be a user visible change. Can we do
> that? What was the original motivation for exclusion?
> 

I'm not sure precisely for regular mlock. But for MLOCK_ONFAULT I did
ask the original author, Eric Munson (added to the 'cc) about allowing
MADV_DONTNEED, and iirc, he thought it made sense for MLOCK_ONFAULT.

Thanks,

-Jason


> [keeping the rest of email for linux-api]
> 
>> The
>> locked memory limits, tracked by mm->locked_vm do not need to be adjusted
>> in this case, since they were charged to the entire region when
>> MLOCK_ONFAULT was initially set.
>>
>> Further, I don't think allowing MADV_FREE for MLOCK_ONFAULT regions makes
>> sense, since the point of MLOCK_ONFAULT is for userspace to know when pages
>> are locked in memory and thus to know when page faults will occur.
>>
>> Signed-off-by: Jason Baron <jbaron@akamai.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> ---
>>  mm/internal.h | 18 ++++++++++++++++++
>>  mm/madvise.c  |  4 ++--
>>  mm/oom_kill.c |  2 +-
>>  3 files changed, 21 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/internal.h b/mm/internal.h
>> index 9e3654d..16c0041 100644
>> --- a/mm/internal.h
>> +++ b/mm/internal.h
>> @@ -15,6 +15,7 @@
>>  #include <linux/mm.h>
>>  #include <linux/pagemap.h>
>>  #include <linux/tracepoint-defs.h>
>> +#include <uapi/asm-generic/mman-common.h>
>>  
>>  /*
>>   * The set of flags that only affect watermark checking and reclaim
>> @@ -45,9 +46,26 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>  
>>  static inline bool can_madv_dontneed_vma(struct vm_area_struct *vma)
>>  {
>> +	return !(((vma->vm_flags & (VM_LOCKED|VM_LOCKONFAULT)) == VM_LOCKED) ||
>> +		 (vma->vm_flags & (VM_HUGETLB|VM_PFNMAP)));
>> +}
>> +
>> +static inline bool can_madv_free_vma(struct vm_area_struct *vma)
>> +{
>>  	return !(vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP));
>>  }
>>  
>> +static inline bool can_madv_dontneed_or_free_vma(struct vm_area_struct *vma,
>> +						 int behavior)
>> +{
>> +	if (behavior == MADV_DONTNEED)
>> +		return can_madv_dontneed_vma(vma);
>> +	else if (behavior == MADV_FREE)
>> +		return can_madv_free_vma(vma);
>> +	else
>> +		return 0;
>> +}
>> +
>>  void unmap_page_range(struct mmu_gather *tlb,
>>  			     struct vm_area_struct *vma,
>>  			     unsigned long addr, unsigned long end,
>> diff --git a/mm/madvise.c b/mm/madvise.c
>> index 4d3c922..61ff306 100644
>> --- a/mm/madvise.c
>> +++ b/mm/madvise.c
>> @@ -517,7 +517,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
>>  				  int behavior)
>>  {
>>  	*prev = vma;
>> -	if (!can_madv_dontneed_vma(vma))
>> +	if (!can_madv_dontneed_or_free_vma(vma, behavior))
>>  		return -EINVAL;
>>  
>>  	if (!userfaultfd_remove(vma, start, end)) {
>> @@ -539,7 +539,7 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
>>  			 */
>>  			return -ENOMEM;
>>  		}
>> -		if (!can_madv_dontneed_vma(vma))
>> +		if (!can_madv_dontneed_or_free_vma(vma, behavior))
>>  			return -EINVAL;
>>  		if (end > vma->vm_end) {
>>  			/*
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 8ba6cb8..9817d15 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -492,7 +492,7 @@ void __oom_reap_task_mm(struct mm_struct *mm)
>>  	set_bit(MMF_UNSTABLE, &mm->flags);
>>  
>>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>> -		if (!can_madv_dontneed_vma(vma))
>> +		if (!can_madv_free_vma(vma))
>>  			continue;
>>  
>>  		/*
>> -- 
>> 2.7.4
>>
> 
