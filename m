Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id F2BD86B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 01:00:52 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1298341dad.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 22:00:52 -0700 (PDT)
Message-ID: <5077A3F7.6010407@gmail.com>
Date: Fri, 12 Oct 2012 13:00:39 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/10] thp: implement splitting pmd for huge zero page
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com> <1349191172-28855-8-git-send-email-kirill.shutemov@linux.intel.com> <50778D39.1000102@gmail.com> <20121012041305.GA16854@shutemov.name>
In-Reply-To: <20121012041305.GA16854@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On 10/12/2012 12:13 PM, Kirill A. Shutemov wrote:
> On Fri, Oct 12, 2012 at 11:23:37AM +0800, Ni zhan Chen wrote:
>> On 10/02/2012 11:19 PM, Kirill A. Shutemov wrote:
>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>
>>> We can't split huge zero page itself, but we can split the pmd which
>>> points to it.
>>>
>>> On splitting the pmd we create a table with all ptes set to normal zero
>>> page.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
>>> ---
>>>   mm/huge_memory.c |   32 ++++++++++++++++++++++++++++++++
>>>   1 files changed, 32 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 95032d3..3f1c59c 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -1600,6 +1600,7 @@ int split_huge_page(struct page *page)
>>>   	struct anon_vma *anon_vma;
>>>   	int ret = 1;
>>> +	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
>>>   	BUG_ON(!PageAnon(page));
>>>   	anon_vma = page_lock_anon_vma(page);
>>>   	if (!anon_vma)
>>> @@ -2503,6 +2504,32 @@ static int khugepaged(void *none)
>>>   	return 0;
>>>   }
>>> +static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
>>> +		unsigned long haddr, pmd_t *pmd)
>>> +{
>>> +	pgtable_t pgtable;
>>> +	pmd_t _pmd;
>>> +	int i;
>>> +
>>> +	pmdp_clear_flush_notify(vma, haddr, pmd);
>> why I can't find function pmdp_clear_flush_notify in kernel source
>> code? Do you mean pmdp_clear_flush_young_notify or something like
>> that?
> It was changed recently. See commit
> 2ec74c3 mm: move all mmu notifier invocations to be done outside the PT lock

Oh, thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
