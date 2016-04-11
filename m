Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 51DCC6B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:39:47 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id td3so114770238pab.2
        for <linux-mm@kvack.org>; Sun, 10 Apr 2016 22:39:47 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [125.16.236.3])
        by mx.google.com with ESMTPS id r1si1371063pai.141.2016.04.10.22.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 10 Apr 2016 22:39:46 -0700 (PDT)
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 11 Apr 2016 11:09:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u3B5e1sv22479314
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 11:10:01 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u3BB7q5i021734
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 16:37:55 +0530
Message-ID: <570B3897.6040804@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2016 11:09:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] mm/hugetlb: Protect follow_huge_(pud|pgd) functions
 from race
References: <1460007464-26726-1-git-send-email-khandual@linux.vnet.ibm.com> <1460007464-26726-4-git-send-email-khandual@linux.vnet.ibm.com> <570627C9.5030105@gmail.com>
In-Reply-To: <570627C9.5030105@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: hughd@google.com, dave.hansen@intel.com, aneesh.kumar@linux.vnet.ibm.com, kirill@shutemov.name, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On 04/07/2016 02:56 PM, Balbir Singh wrote:
> 
> On 07/04/16 15:37, Anshuman Khandual wrote:
>> > follow_huge_(pmd|pud|pgd) functions are used to walk the page table and
>> > fetch the page struct during 'follow_page_mask' call. There are possible
>> > race conditions faced by these functions which arise out of simultaneous
>> > calls of move_pages() and freeing of huge pages. This was fixed partly
>> > by the previous commit e66f17ff7177 ("mm/hugetlb: take page table lock
>> > in follow_huge_pmd()") for only PMD based huge pages.
>> > 
>> > After implementing similar logic, functions like follow_huge_(pud|pgd)
>> > are now safe from above mentioned race conditions and also can support
>> > FOLL_GET. Generic version of the function 'follow_huge_addr' has been
>> > left as it is and its upto the architecture to decide on it.
>> > 
>> > Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
>> > ---
>> >  include/linux/mm.h | 33 +++++++++++++++++++++++++++
>> >  mm/hugetlb.c       | 67 ++++++++++++++++++++++++++++++++++++++++++++++--------
>> >  2 files changed, 91 insertions(+), 9 deletions(-)
>> > 
>> > diff --git a/include/linux/mm.h b/include/linux/mm.h
>> > index ffcff53..734182a 100644
>> > --- a/include/linux/mm.h
>> > +++ b/include/linux/mm.h
>> > @@ -1751,6 +1751,19 @@ static inline void pgtable_page_dtor(struct page *page)
>> >  		NULL: pte_offset_kernel(pmd, address))
>> >  
>> >  #if USE_SPLIT_PMD_PTLOCKS
> Do we still use USE_SPLIT_PMD_PTLOCKS? I think its good enough. with pgd's
> we are likely to use the same locks and the split nature may not be really
> split.
> 

Sorry Balbir, did not get what you asked. Can you please elaborate on
this ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
