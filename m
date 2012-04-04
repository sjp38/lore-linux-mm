Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 60F6A6B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 00:43:32 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so475334bkw.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 21:43:30 -0700 (PDT)
Message-ID: <4F7BD16F.2010903@openvz.org>
Date: Wed, 04 Apr 2012 08:43:27 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [x86 PAT PATCH 1/2] x86, pat: remove the dependency on 'vm_pgoff'
 in track/untrack pfn vma routines
References: <20120331170947.7773.46399.stgit@zurg>  <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>  <1333413969-30761-2-git-send-email-suresh.b.siddha@intel.com>  <4F7A8C94.3040708@openvz.org> <1333495881.12400.19.camel@sbsiddha-desk.sc.intel.com>
In-Reply-To: <1333495881.12400.19.camel@sbsiddha-desk.sc.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

Suresh Siddha wrote:
> On Tue, 2012-04-03 at 09:37 +0400, Konstantin Khlebnikov wrote:
>> Suresh Siddha wrote:
>>> 'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
>>> for the pfn range. No need to depend on 'vm_pgoff'
>>>
>>> Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
>>> is non-zero or can use follow_phys() to get the starting value of the pfn
>>> range.
>>>
>>> Also the non zero 'size' argument can be used instead of recomputing
>>> it from vma.
>>>
>>> This cleanup also prepares the ground for the track/untrack pfn vma routines
>>> to take over the ownership of setting PAT specific vm_flag in the 'vma'.
>>>
>>> Signed-off-by: Suresh Siddha<suresh.b.siddha@intel.com>
>>> Cc: Venkatesh Pallipadi<venki@google.com>
>>> Cc: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> ---
>>>    arch/x86/mm/pat.c |   30 +++++++++++++++++-------------
>>>    1 files changed, 17 insertions(+), 13 deletions(-)
>>>
>>> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
>>> index f6ff57b..617f42b 100644
>>> --- a/arch/x86/mm/pat.c
>>> +++ b/arch/x86/mm/pat.c
>>> @@ -693,14 +693,10 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
>>>    			unsigned long pfn, unsigned long size)
>>>    {
>>>    	unsigned long flags;
>>> -	resource_size_t paddr;
>>> -	unsigned long vma_size = vma->vm_end - vma->vm_start;
>>>
>>> -	if (is_linear_pfn_mapping(vma)) {
>>> -		/* reserve the whole chunk starting from vm_pgoff */
>>> -		paddr = (resource_size_t)vma->vm_pgoff<<   PAGE_SHIFT;
>>> -		return reserve_pfn_range(paddr, vma_size, prot, 0);
>>> -	}
>>> +	/* reserve the whole chunk starting from pfn */
>>> +	if (is_linear_pfn_mapping(vma))
>>> +		return reserve_pfn_range(pfn, size, prot, 0);
>>
>> you mix here pfn and paddr: old code passes paddr as first argument of reserve_pfn_range().
>
> oops. That was my oversight. I updated the two patches to address this.
> Also I cleared VM_PAT flag as part of the untrack_pfn_vma(), so that the
> use cases (like the i915 case) which just evict the pfn's (by using
> unmap_mapping_range) with out actually removing the vma will do the
> free_pfn_range() only when it is required.
>
> Attached (to this e-mail) are the -v2 versions of the PAT patches. I
> tested these on my SNB laptop.

Ok, I'll send them as part of updated patchset.

>
> thanks,
> suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
