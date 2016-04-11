Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DF8526B0260
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:46:32 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 184so123728990pff.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:46:32 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id vb6si3497409pac.158.2016.04.11.05.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 05:46:32 -0700 (PDT)
Received: by mail-pa0-x22d.google.com with SMTP id bx7so104920660pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:46:32 -0700 (PDT)
Subject: Re: [PATCH 03/10] mm/hugetlb: Protect follow_huge_(pud|pgd) functions
 from race
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1460007464-26726-4-git-send-email-khandual@linux.vnet.ibm.com>
 <570627C9.5030105@gmail.com> <570B3897.6040804@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <570B9C93.5050507@gmail.com>
Date: Mon, 11 Apr 2016 22:46:11 +1000
MIME-Version: 1.0
In-Reply-To: <570B3897.6040804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org



On 11/04/16 15:39, Anshuman Khandual wrote:
> On 04/07/2016 02:56 PM, Balbir Singh wrote:
>>
>> On 07/04/16 15:37, Anshuman Khandual wrote:
>>>> follow_huge_(pmd|pud|pgd) functions are used to walk the page table and
>>>> fetch the page struct during 'follow_page_mask' call. There are possible
>>>> race conditions faced by these functions which arise out of simultaneous
>>>> calls of move_pages() and freeing of huge pages. This was fixed partly
>>>> by the previous commit e66f17ff7177 ("mm/hugetlb: take page table lock
>>>> in follow_huge_pmd()") for only PMD based huge pages.
>>>>
>>>> After implementing similar logic, functions like follow_huge_(pud|pgd)
>>>> are now safe from above mentioned race conditions and also can support
>>>> FOLL_GET. Generic version of the function 'follow_huge_addr' has been
>>>> left as it is and its upto the architecture to decide on it.
>>>>
>>>> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>>>> ---
>>>>  include/linux/mm.h | 33 +++++++++++++++++++++++++++
>>>>  mm/hugetlb.c       | 67 ++++++++++++++++++++++++++++++++++++++++++++++--------
>>>>  2 files changed, 91 insertions(+), 9 deletions(-)
>>>>
>>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>> index ffcff53..734182a 100644
>>>> --- a/include/linux/mm.h
>>>> +++ b/include/linux/mm.h
>>>> @@ -1751,6 +1751,19 @@ static inline void pgtable_page_dtor(struct page *page)
>>>>  		NULL: pte_offset_kernel(pmd, address))
>>>>  
>>>>  #if USE_SPLIT_PMD_PTLOCKS
>> Do we still use USE_SPLIT_PMD_PTLOCKS? I think its good enough. with pgd's
>> we are likely to use the same locks and the split nature may not be really
>> split.
>>
> 
> Sorry Balbir, did not get what you asked. Can you please elaborate on
> this ?
> 

What I meant is that do we need SPLIT_PUD_PTLOCKS for example? I don't think we do

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
