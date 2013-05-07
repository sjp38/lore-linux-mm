Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 6D8E16B00DC
	for <linux-mm@kvack.org>; Mon,  6 May 2013 23:28:23 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 7 May 2013 08:52:59 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id F07861258023
	for <linux-mm@kvack.org>; Tue,  7 May 2013 09:00:01 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r473S8Ad5177722
	for <linux-mm@kvack.org>; Tue, 7 May 2013 08:58:08 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r473SFBE015214
	for <linux-mm@kvack.org>; Tue, 7 May 2013 13:28:15 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/THP: Don't use HPAGE_SHIFT in transparent hugepage code
In-Reply-To: <20130506222719.GA23653@shutemov.name>
References: <1367873552-12904-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130506222719.GA23653@shutemov.name>
Date: Tue, 07 May 2013 08:58:13 +0530
Message-ID: <87wqrbzcxe.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Tue, May 07, 2013 at 02:22:32AM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> For architectures like powerpc that support multiple explicit hugepage
>> sizes, HPAGE_SHIFT indicate the default explicit hugepage shift. For
>> THP to work the hugepage size should be same as PMD_SIZE. So use
>> PMD_SHIFT directly. So move the define outside CONFIG_TRANSPARENT_HUGEPAGE
>> #ifdef because we want to use these defines in generic code with
>> if (pmd_trans_huge()) conditional.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  include/linux/huge_mm.h | 10 +++-------
>>  1 file changed, 3 insertions(+), 7 deletions(-)
>> 
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 528454c..cc276d2 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -58,12 +58,11 @@ extern pmd_t *page_check_address_pmd(struct page *page,
>>  
>>  #define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
>>  #define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
>> +#define HPAGE_PMD_SHIFT PMD_SHIFT
>
> What about:
>
> #ifndef HPAGE_PMD_SHIFT
> #define HPAGE_PMD_SHIFT HPAGE_SHIFT
> #endif
>
> And define HPAGE_PMD_SHIFT in arch code if HPAGE_SHIFT is not
> suitable?


That would work for me provided the BUILD_BUG_ON is also taken care.
But is there a reason why we want to do that ? Will any value other
than PMD_SHIFT work ?

The below patch shows how we want to use these. To avoid those
BUILD_BUG_ON I ended up doing HUGE_PAGE_SIZE and HUGE_PAGE_MASK

https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-April/105631.html

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
