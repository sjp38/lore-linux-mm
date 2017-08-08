Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D12576B02B4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 12:51:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k190so39615104pge.9
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 09:51:29 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0043.outbound.protection.outlook.com. [104.47.41.43])
        by mx.google.com with ESMTPS id 5si1122499pfo.543.2017.08.08.09.51.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 09:51:28 -0700 (PDT)
Subject: Re: A possible bug: Calling mutex_lock while holding spinlock
From: axie <axie@amd.com>
References: <2d442de2-c5d4-ecce-2345-4f8f34314247@amd.com>
 <20170803153902.71ceaa3b435083fc2e112631@linux-foundation.org>
 <20170804134928.l4klfcnqatni7vsc@black.fi.intel.com>
 <6027ba44-d3ca-9b0b-acdf-f2ec39f01929@amd.com>
Message-ID: <fc466bf4-a658-f343-43f1-7e2f7ecb5d63@amd.com>
Date: Tue, 8 Aug 2017 12:51:15 -0400
MIME-Version: 1.0
In-Reply-To: <6027ba44-d3ca-9b0b-acdf-f2ec39f01929@amd.com>
Content-Type: multipart/alternative;
 boundary="------------7F042AE10785D0944957B1B8"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Deucher <alexander.deucher@amd.com>, "Writer, Tim" <Tim.Writer@amd.com>, linux-mm@kvack.org, "Xie, AlexBin" <AlexBin.Xie@amd.com>

This is a multi-part message in MIME format.
--------------7F042AE10785D0944957B1B8
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Kirill,

Here is the result from the user:"This patch does appear fix the issue."

Thanks,

Alex (Bin) Xie


On 2017-08-04 10:03 AM, axie wrote:
> Hi Kirill,
>
>
> Thanks for the patch. I have sent the patch to the user asking whether 
> he can give it a try.
>
>
> Regards,
>
> Alex (Bin) Xie
>
>
>
> On 2017-08-04 09:49 AM, Kirill A. Shutemov wrote:
>> On Thu, Aug 03, 2017 at 03:39:02PM -0700, Andrew Morton wrote:
>>> (cc Kirill)
>>>
>>> On Thu, 3 Aug 2017 12:35:28 -0400 axie <axie@amd.com> wrote:
>>>
>>>> Hi Andrew,
>>>>
>>>>
>>>> I got a report yesterday with "BUG: sleeping function called from
>>>> invalid context at kernel/locking/mutex.c"
>>>>
>>>> I checked the relevant functions for the issue. Function
>>>> page_vma_mapped_walk did acquire spinlock. Later, in MMU notifier,
>>>> amdgpu_mn_invalidate_page called function mutex_lock, which triggered
>>>> the "bug".
>>>>
>>>> Function page_vma_mapped_walk was introduced recently by you in commit
>>>> c7ab0d2fdc840266b39db94538f74207ec2afbf6 and
>>>> ace71a19cec5eb430207c3269d8a2683f0574306.
>>>>
>>>> Would you advise how to proceed with this bug? Change
>>>> page_vma_mapped_walk not to use spinlock? Or change
>>>> amdgpu_mn_invalidate_page to use spinlock to meet the change, or
>>>> something else?
>>>>
>>> hm, as far as I can tell this was an unintended side-effect of
>>> c7ab0d2fd ("mm: convert try_to_unmap_one() to use
>>> page_vma_mapped_walk()").  Before that patch,
>>> mmu_notifier_invalidate_page() was not called under page_table_lock.
>>> After that patch, mmu_notifier_invalidate_page() is called under
>>> page_table_lock.
>>>
>>> Perhaps Kirill can suggest a fix?
>> Sorry for this.
>>
>> What about the patch below?
>>
>>  From f48dbcdd0ed83dee9a157062b7ca1e2915172678 Mon Sep 17 00:00:00 2001
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Date: Fri, 4 Aug 2017 16:37:26 +0300
>> Subject: [PATCH] rmap: do not call mmu_notifier_invalidate_page() 
>> under ptl
>>
>> MMU notifiers can sleep, but in page_mkclean_one() we call
>> mmu_notifier_invalidate_page() under page table lock.
>>
>> Let's instead use mmu_notifier_invalidate_range() outside
>> page_vma_mapped_walk() loop.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use 
>> page_vma_mapped_walk()")
>> ---
>>   mm/rmap.c | 21 +++++++++++++--------
>>   1 file changed, 13 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index ced14f1af6dc..b4b711a82c01 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -852,10 +852,10 @@ static bool page_mkclean_one(struct page *page, 
>> struct vm_area_struct *vma,
>>           .flags = PVMW_SYNC,
>>       };
>>       int *cleaned = arg;
>> +    bool invalidation_needed = false;
>>         while (page_vma_mapped_walk(&pvmw)) {
>>           int ret = 0;
>> -        address = pvmw.address;
>>           if (pvmw.pte) {
>>               pte_t entry;
>>               pte_t *pte = pvmw.pte;
>> @@ -863,11 +863,11 @@ static bool page_mkclean_one(struct page *page, 
>> struct vm_area_struct *vma,
>>               if (!pte_dirty(*pte) && !pte_write(*pte))
>>                   continue;
>>   -            flush_cache_page(vma, address, pte_pfn(*pte));
>> -            entry = ptep_clear_flush(vma, address, pte);
>> +            flush_cache_page(vma, pvmw.address, pte_pfn(*pte));
>> +            entry = ptep_clear_flush(vma, pvmw.address, pte);
>>               entry = pte_wrprotect(entry);
>>               entry = pte_mkclean(entry);
>> -            set_pte_at(vma->vm_mm, address, pte, entry);
>> +            set_pte_at(vma->vm_mm, pvmw.address, pte, entry);
>>               ret = 1;
>>           } else {
>>   #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
>> @@ -877,11 +877,11 @@ static bool page_mkclean_one(struct page *page, 
>> struct vm_area_struct *vma,
>>               if (!pmd_dirty(*pmd) && !pmd_write(*pmd))
>>                   continue;
>>   -            flush_cache_page(vma, address, page_to_pfn(page));
>> -            entry = pmdp_huge_clear_flush(vma, address, pmd);
>> +            flush_cache_page(vma, pvmw.address, page_to_pfn(page));
>> +            entry = pmdp_huge_clear_flush(vma, pvmw.address, pmd);
>>               entry = pmd_wrprotect(entry);
>>               entry = pmd_mkclean(entry);
>> -            set_pmd_at(vma->vm_mm, address, pmd, entry);
>> +            set_pmd_at(vma->vm_mm, pvmw.address, pmd, entry);
>>               ret = 1;
>>   #else
>>               /* unexpected pmd-mapped page? */
>> @@ -890,11 +890,16 @@ static bool page_mkclean_one(struct page *page, 
>> struct vm_area_struct *vma,
>>           }
>>             if (ret) {
>> -            mmu_notifier_invalidate_page(vma->vm_mm, address);
>>               (*cleaned)++;
>> +            invalidation_needed = true;
>>           }
>>       }
>>   +    if (invalidation_needed) {
>> +        mmu_notifier_invalidate_range(vma->vm_mm, address,
>> +                address + (1UL << compound_order(page)));
>> +    }
>> +
>>       return true;
>>   }
>


--------------7F042AE10785D0944957B1B8
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <p>Hi Kirill,</p>
    <p>Here is the result from the user:"<font size="2"><span
          style="font-size:10pt;">This patch does appear fix the issue."</span></font></p>
    <p><font size="2"><span style="font-size:10pt;">Thanks,</span></font></p>
    <p><font size="2"><span style="font-size:10pt;">Alex (Bin) Xie</span></font></p>
    <br>
    <div class="moz-cite-prefix">On 2017-08-04 10:03 AM, axie wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:6027ba44-d3ca-9b0b-acdf-f2ec39f01929@amd.com">Hi Kirill,
      <br>
      <br>
      <br>
      Thanks for the patch. I have sent the patch to the user asking
      whether he can give it a try.
      <br>
      <br>
      <br>
      Regards,
      <br>
      <br>
      Alex (Bin) Xie
      <br>
      <br>
      <br>
      <br>
      On 2017-08-04 09:49 AM, Kirill A. Shutemov wrote:
      <br>
      <blockquote type="cite">On Thu, Aug 03, 2017 at 03:39:02PM -0700,
        Andrew Morton wrote:
        <br>
        <blockquote type="cite">(cc Kirill)
          <br>
          <br>
          On Thu, 3 Aug 2017 12:35:28 -0400 axie <a class="moz-txt-link-rfc2396E" href="mailto:axie@amd.com">&lt;axie@amd.com&gt;</a>
          wrote:
          <br>
          <br>
          <blockquote type="cite">Hi Andrew,
            <br>
            <br>
            <br>
            I got a report yesterday with "BUG: sleeping function called
            from
            <br>
            invalid context at kernel/locking/mutex.c"
            <br>
            <br>
            I checked the relevant functions for the issue. Function
            <br>
            page_vma_mapped_walk did acquire spinlock. Later, in MMU
            notifier,
            <br>
            amdgpu_mn_invalidate_page called function mutex_lock, which
            triggered
            <br>
            the "bug".
            <br>
            <br>
            Function page_vma_mapped_walk was introduced recently by you
            in commit
            <br>
            c7ab0d2fdc840266b39db94538f74207ec2afbf6 and
            <br>
            ace71a19cec5eb430207c3269d8a2683f0574306.
            <br>
            <br>
            Would you advise how to proceed with this bug? Change
            <br>
            page_vma_mapped_walk not to use spinlock? Or change
            <br>
            amdgpu_mn_invalidate_page to use spinlock to meet the
            change, or
            <br>
            something else?
            <br>
            <br>
          </blockquote>
          hm, as far as I can tell this was an unintended side-effect of
          <br>
          c7ab0d2fd ("mm: convert try_to_unmap_one() to use
          <br>
          page_vma_mapped_walk()").A  Before that patch,
          <br>
          mmu_notifier_invalidate_page() was not called under
          page_table_lock.
          <br>
          After that patch, mmu_notifier_invalidate_page() is called
          under
          <br>
          page_table_lock.
          <br>
          <br>
          Perhaps Kirill can suggest a fix?
          <br>
        </blockquote>
        Sorry for this.
        <br>
        <br>
        What about the patch below?
        <br>
        <br>
        A From f48dbcdd0ed83dee9a157062b7ca1e2915172678 Mon Sep 17
        00:00:00 2001
        <br>
        From: "Kirill A. Shutemov"
        <a class="moz-txt-link-rfc2396E" href="mailto:kirill.shutemov@linux.intel.com">&lt;kirill.shutemov@linux.intel.com&gt;</a>
        <br>
        Date: Fri, 4 Aug 2017 16:37:26 +0300
        <br>
        Subject: [PATCH] rmap: do not call
        mmu_notifier_invalidate_page() under ptl
        <br>
        <br>
        MMU notifiers can sleep, but in page_mkclean_one() we call
        <br>
        mmu_notifier_invalidate_page() under page table lock.
        <br>
        <br>
        Let's instead use mmu_notifier_invalidate_range() outside
        <br>
        page_vma_mapped_walk() loop.
        <br>
        <br>
        Signed-off-by: Kirill A. Shutemov
        <a class="moz-txt-link-rfc2396E" href="mailto:kirill.shutemov@linux.intel.com">&lt;kirill.shutemov@linux.intel.com&gt;</a>
        <br>
        Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use
        page_vma_mapped_walk()")
        <br>
        ---
        <br>
        A  mm/rmap.c | 21 +++++++++++++--------
        <br>
        A  1 file changed, 13 insertions(+), 8 deletions(-)
        <br>
        <br>
        diff --git a/mm/rmap.c b/mm/rmap.c
        <br>
        index ced14f1af6dc..b4b711a82c01 100644
        <br>
        --- a/mm/rmap.c
        <br>
        +++ b/mm/rmap.c
        <br>
        @@ -852,10 +852,10 @@ static bool page_mkclean_one(struct page
        *page, struct vm_area_struct *vma,
        <br>
        A A A A A A A A A  .flags = PVMW_SYNC,
        <br>
        A A A A A  };
        <br>
        A A A A A  int *cleaned = arg;
        <br>
        +A A A  bool invalidation_needed = false;
        <br>
        A  A A A A A  while (page_vma_mapped_walk(&amp;pvmw)) {
        <br>
        A A A A A A A A A  int ret = 0;
        <br>
        -A A A A A A A  address = pvmw.address;
        <br>
        A A A A A A A A A  if (pvmw.pte) {
        <br>
        A A A A A A A A A A A A A  pte_t entry;
        <br>
        A A A A A A A A A A A A A  pte_t *pte = pvmw.pte;
        <br>
        @@ -863,11 +863,11 @@ static bool page_mkclean_one(struct page
        *page, struct vm_area_struct *vma,
        <br>
        A A A A A A A A A A A A A  if (!pte_dirty(*pte) &amp;&amp; !pte_write(*pte))
        <br>
        A A A A A A A A A A A A A A A A A  continue;
        <br>
        A  -A A A A A A A A A A A  flush_cache_page(vma, address, pte_pfn(*pte));
        <br>
        -A A A A A A A A A A A  entry = ptep_clear_flush(vma, address, pte);
        <br>
        +A A A A A A A A A A A  flush_cache_page(vma, pvmw.address, pte_pfn(*pte));
        <br>
        +A A A A A A A A A A A  entry = ptep_clear_flush(vma, pvmw.address, pte);
        <br>
        A A A A A A A A A A A A A  entry = pte_wrprotect(entry);
        <br>
        A A A A A A A A A A A A A  entry = pte_mkclean(entry);
        <br>
        -A A A A A A A A A A A  set_pte_at(vma-&gt;vm_mm, address, pte, entry);
        <br>
        +A A A A A A A A A A A  set_pte_at(vma-&gt;vm_mm, pvmw.address, pte,
        entry);
        <br>
        A A A A A A A A A A A A A  ret = 1;
        <br>
        A A A A A A A A A  } else {
        <br>
        A  #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
        <br>
        @@ -877,11 +877,11 @@ static bool page_mkclean_one(struct page
        *page, struct vm_area_struct *vma,
        <br>
        A A A A A A A A A A A A A  if (!pmd_dirty(*pmd) &amp;&amp; !pmd_write(*pmd))
        <br>
        A A A A A A A A A A A A A A A A A  continue;
        <br>
        A  -A A A A A A A A A A A  flush_cache_page(vma, address,
        page_to_pfn(page));
        <br>
        -A A A A A A A A A A A  entry = pmdp_huge_clear_flush(vma, address, pmd);
        <br>
        +A A A A A A A A A A A  flush_cache_page(vma, pvmw.address,
        page_to_pfn(page));
        <br>
        +A A A A A A A A A A A  entry = pmdp_huge_clear_flush(vma, pvmw.address,
        pmd);
        <br>
        A A A A A A A A A A A A A  entry = pmd_wrprotect(entry);
        <br>
        A A A A A A A A A A A A A  entry = pmd_mkclean(entry);
        <br>
        -A A A A A A A A A A A  set_pmd_at(vma-&gt;vm_mm, address, pmd, entry);
        <br>
        +A A A A A A A A A A A  set_pmd_at(vma-&gt;vm_mm, pvmw.address, pmd,
        entry);
        <br>
        A A A A A A A A A A A A A  ret = 1;
        <br>
        A  #else
        <br>
        A A A A A A A A A A A A A  /* unexpected pmd-mapped page? */
        <br>
        @@ -890,11 +890,16 @@ static bool page_mkclean_one(struct page
        *page, struct vm_area_struct *vma,
        <br>
        A A A A A A A A A  }
        <br>
        A  A A A A A A A A A  if (ret) {
        <br>
        -A A A A A A A A A A A  mmu_notifier_invalidate_page(vma-&gt;vm_mm,
        address);
        <br>
        A A A A A A A A A A A A A  (*cleaned)++;
        <br>
        +A A A A A A A A A A A  invalidation_needed = true;
        <br>
        A A A A A A A A A  }
        <br>
        A A A A A  }
        <br>
        A  +A A A  if (invalidation_needed) {
        <br>
        +A A A A A A A  mmu_notifier_invalidate_range(vma-&gt;vm_mm, address,
        <br>
        +A A A A A A A A A A A A A A A  address + (1UL &lt;&lt; compound_order(page)));
        <br>
        +A A A  }
        <br>
        +
        <br>
        A A A A A  return true;
        <br>
        A  }
        <br>
        A  </blockquote>
      <br>
    </blockquote>
    <br>
  </body>
</html>

--------------7F042AE10785D0944957B1B8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
