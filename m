Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id C630F6B005A
	for <linux-mm@kvack.org>; Tue, 27 May 2014 06:44:32 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so8972235pbc.26
        for <linux-mm@kvack.org>; Tue, 27 May 2014 03:44:32 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id sl2si18091384pbc.221.2014.05.27.03.44.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 27 May 2014 03:44:31 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 27 May 2014 16:14:26 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 575103940058
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:14:24 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4RAiuQu1114508
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:14:56 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4RAi6on011179
	for <linux-mm@kvack.org>; Tue, 27 May 2014 16:14:08 +0530
Message-ID: <53846C75.10507@linux.vnet.ibm.com>
Date: Tue, 27 May 2014 16:14:05 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils> <87wqdik4n5.fsf@rustcorp.com.au> <53797511.1050409@linux.vnet.ibm.com> <alpine.LSU.2.11.1405191531150.1317@eggly.anvils> <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org> <20140520004429.E660AE009B@blue.fi.intel.com> <87oaythsvk.fsf@rustcorp.com.au> <20140520102738.7F096E009B@blue.fi.intel.com> <53842FB1.7090909@linux.vnet.ibm.com> <20140527102200.012BBE009B@blue.fi.intel.com>
In-Reply-To: <20140527102200.012BBE009B@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tuesday 27 May 2014 03:51 PM, Kirill A. Shutemov wrote:
> Madhavan Srinivasan wrote:
>> On Tuesday 20 May 2014 03:57 PM, Kirill A. Shutemov wrote:
>>> Rusty Russell wrote:
>>>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>>>>> Andrew Morton wrote:
>>>>>> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>>>>>>
>>>>>>> Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
>>>>>>> the order of the fault-around size in bytes, and fault_around_pages()
>>>>>>> use 1UL << (fault_around_order - PAGE_SHIFT)
>>>>>>
>>>>>> Yes.  And shame on me for missing it (this time!) at review.
>>>>>>
>>>>>> There's still time to fix this.  Patches, please.
>>>>>
>>>>> Here it is. Made at 3.30 AM, build tested only.
>>>>
>>>> Prefer on top of Maddy's patch which makes it always a variable, rather
>>>> than CONFIG_DEBUG_FS.  It's got enough hair as it is.
>>>
>>> Something like this?
>>>
>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>> Date: Tue, 20 May 2014 13:02:03 +0300
>>> Subject: [PATCH] mm: nominate faultaround area in bytes rather then page order
>>>
>>> There are evidences that faultaround feature is less relevant on
>>> architectures with page size bigger then 4k. Which makes sense since
>>> page fault overhead per byte of mapped area should be less there.
>>>
>>> Let's rework the feature to specify faultaround area in bytes instead of
>>> page order. It's 64 kilobytes for now.
>>>
>>> The patch effectively disables faultaround on architectures with
>>> page size >= 64k (like ppc64).
>>>
>>> It's possible that some other size of faultaround area is relevant for a
>>> platform. We can expose `fault_around_bytes' variable to arch-specific
>>> code once such platforms will be found.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> ---
>>>  mm/memory.c | 62 +++++++++++++++++++++++--------------------------------------
>>>  1 file changed, 23 insertions(+), 39 deletions(-)
>>>
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index 037b812a9531..252b319e8cdf 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -3402,63 +3402,47 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>>>  	update_mmu_cache(vma, address, pte);
>>>  }
>>>
>>> -#define FAULT_AROUND_ORDER 4
>>> +static unsigned long fault_around_bytes = 65536;
>>> +
>>> +static inline unsigned long fault_around_pages(void)
>>> +{
>>> +	return rounddown_pow_of_two(fault_around_bytes) / PAGE_SIZE;
>>> +}
>>> +
>>> +static inline unsigned long fault_around_mask(void)
>>> +{
>>> +	return ~(rounddown_pow_of_two(fault_around_bytes) - 1) & PAGE_MASK;
>>> +}
>>>
>>> -#ifdef CONFIG_DEBUG_FS
>>> -static unsigned int fault_around_order = FAULT_AROUND_ORDER;
>>>
>>> -static int fault_around_order_get(void *data, u64 *val)
>>> +#ifdef CONFIG_DEBUG_FS
>>> +static int fault_around_bytes_get(void *data, u64 *val)
>>>  {
>>> -	*val = fault_around_order;
>>> +	*val = fault_around_bytes;
>>>  	return 0;
>>>  }
>>>
>>> -static int fault_around_order_set(void *data, u64 val)
>>> +static int fault_around_bytes_set(void *data, u64 val)
>>>  {
>>
>> Kindly ignore the question if not relevant. Even though we need root
>> access to alter the value, will we be fine with
>> negative value?.
> ppc
> val is u64. or I miss something?
> 

My Bad. What I wanted to check was for all 0xf input and guess we are
fine. Sorry about that.

Regards
Maddy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
