Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8836B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 13:02:58 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so113072395pad.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 10:02:58 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p85si645466pfj.175.2016.09.08.10.02.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 10:02:55 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v3 08/10] mm, THP: Add can_split_huge_page()
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	<1473266769-2155-9-git-send-email-ying.huang@intel.com>
	<20160908111752.GE17331@node>
Date: Thu, 08 Sep 2016 10:02:55 -0700
In-Reply-To: <20160908111752.GE17331@node> (Kirill A. Shutemov's message of
	"Thu, 8 Sep 2016 14:17:52 +0300")
Message-ID: <87h99q5npc.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Hi, Kirill,

Thanks for your comments!

"Kirill A. Shutemov" <kirill@shutemov.name> writes:
> On Wed, Sep 07, 2016 at 09:46:07AM -0700, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> Separates checking whether we can split the huge page from
>> split_huge_page_to_list() into a function.  This will help to check that
>> before splitting the THP (Transparent Huge Page) really.
>> 
>> This will be used for delaying splitting THP during swapping out.  Where
>> for a THP, we will allocate a swap cluster, add the THP into the swap
>> cache, then split the THP.  To avoid the unnecessary operations for the
>> un-splittable THP, we will check that firstly.
>> 
>> There is no functionality change in this patch.
>> 
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> ---
>>  include/linux/huge_mm.h |  6 ++++++
>>  mm/huge_memory.c        | 13 ++++++++++++-
>>  2 files changed, 18 insertions(+), 1 deletion(-)
>> 
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 9b9f65d..a0073e7 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -94,6 +94,7 @@ extern unsigned long thp_get_unmapped_area(struct file *filp,
>>  extern void prep_transhuge_page(struct page *page);
>>  extern void free_transhuge_page(struct page *page);
>>  
>> +bool can_split_huge_page(struct page *page);
>>  int split_huge_page_to_list(struct page *page, struct list_head *list);
>>  static inline int split_huge_page(struct page *page)
>>  {
>> @@ -176,6 +177,11 @@ static inline void prep_transhuge_page(struct page *page) {}
>>  
>>  #define thp_get_unmapped_area	NULL
>>  
>> +static inline bool
>> +can_split_huge_page(struct page *page)
>> +{
>
> BUILD_BUG() should be appropriate here.

Yes.  Will add it.

>> +	return false;
>> +}

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
