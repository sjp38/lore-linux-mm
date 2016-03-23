Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A341A6B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 00:02:56 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id 4so7318747pfd.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 21:02:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u64si1207389pfa.100.2016.03.22.21.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 21:02:55 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm/hugetlb: Introduce hugetlb_bad_size
References: <1458640843-13483-1-git-send-email-vaishali.thakkar@oracle.com>
 <alpine.DEB.2.10.1603230819100.16296@hxeon>
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Message-ID: <56F2154F.4090505@oracle.com>
Date: Wed, 23 Mar 2016 09:32:23 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1603230819100.16296@hxeon>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeongJae Park <sj38.park@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Michal Hocko <mhocko@suse.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Dave Hansen <dave.hansen@linux.intel.com>



On Wednesday 23 March 2016 04:57 AM, SeongJae Park wrote:
> Hello Vaishali,
>
>
> The patch looks good to me.  However, I have few trivial questions.
>
> On Tue, 22 Mar 2016, Vaishali Thakkar wrote:
>
>> When any unsupported hugepage size is specified, 'hugepagesz=' and
>> 'hugepages=' should be ignored during command line parsing until any
>> supported hugepage size is found. But currently incorrect number of
>> hugepages are allocated when unsupported size is specified as it fails
>> to ignore the 'hugepages=' command.
>>
>> Test case:
>>
>> Note that this is specific to x86 architecture.
>>
>> Boot the kernel with command line option 'hugepagesz=256M hugepages=X'.
>> After boot, dmesg output shows that X number of hugepages of the size 2M
>> is pre-allocated instead of 0.
>>
>> So, to handle such command line options, introduce new routine
>> hugetlb_bad_size. The routine hugetlb_bad_size sets the global variable
>> parsed_valid_hugepagesz. We are using parsed_valid_hugepagesz to save the
>> state when unsupported hugepagesize is found so that we can ignore the
>> 'hugepages=' parameters after that and then reset the variable when
>> supported hugepage size is found.
>>
>> The routine hugetlb_bad_size can be called while setting 'hugepagesz='
>> parameter in an architecture specific code.
>>
>> Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
>> Cc: Mike Kravetz <mike.kravetz@oracle.com>
>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>> Cc: Hillf Danton <hillf.zj@alibaba-inc.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
>> Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> ---
>> The patch is having 2 checkpatch.pl warnings. I have just followed
>> the current code to maintain consistency. If we decide to silent
>> these warnings then may be we should silent those warnings as well.
>> I am fine with any option whichever works best for everyone else.
>> ---
>> include/linux/hugetlb.h |  1 +
>> mm/hugetlb.c            | 14 +++++++++++++-
>> 2 files changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
>> index 7d953c2..e44c578 100644
>> --- a/include/linux/hugetlb.h
>> +++ b/include/linux/hugetlb.h
>> @@ -338,6 +338,7 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
>> /* arch callback */
>> int __init alloc_bootmem_huge_page(struct hstate *h);
>>
>> +void __init hugetlb_bad_size(void);
>> void __init hugetlb_add_hstate(unsigned order);
>> struct hstate *size_to_hstate(unsigned long size);
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 06058ea..44fae6a 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -51,6 +51,7 @@ __initdata LIST_HEAD(huge_boot_pages);
>> static struct hstate * __initdata parsed_hstate;
>> static unsigned long __initdata default_hstate_max_huge_pages;
>> static unsigned long __initdata default_hstate_size;
>> +static bool __initdata parsed_valid_hugepagesz = true;
>>
>> /*
>>  * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
>> @@ -2659,6 +2660,11 @@ static int __init hugetlb_init(void)
>> subsys_initcall(hugetlb_init);
>>
>> /* Should be called on processing a hugepagesz=... option */
>> +void __init hugetlb_bad_size(void)
>> +{
>> +    parsed_valid_hugepagesz = false;
>> +}
>> +
>> void __init hugetlb_add_hstate(unsigned int order)
>> {
>>     struct hstate *h;
>> @@ -2691,11 +2697,17 @@ static int __init hugetlb_nrpages_setup(char *s)
>>     unsigned long *mhp;
>>     static unsigned long *last_mhp;
>>
>> +    if (!parsed_valid_hugepagesz) {
>> +        pr_warn("hugepages = %s preceded by "
>> +            "an unsupported hugepagesz, ignoring\n", s);
>
> How about concatenating the format string?  `CodingStyle` now suggests to
> _never_ break every user-visible strings.
>

As I said above, I just followed the pattern of the current code to maintain the
consistency. Probably a separate change would be good for solving all those
warnings. :)

>> +        parsed_valid_hugepagesz = true;
>> +        return 1;
>> +    }
>>     /*
>>      * !hugetlb_max_hstate means we haven't parsed a hugepagesz= parameter yet,
>>      * so this hugepages= parameter goes to the "default hstate".
>>      */
>> -    if (!hugetlb_max_hstate)
>> +    else if (!hugetlb_max_hstate)
>
> Because the upper `if` statement will do `return`, above change looks not
> significantly necessary.  Is this intended?
>

I think above change is necessary for the cases like "hugepages=X" because in that
case the X hugepages of the default size [like 2M for x86] should be allocated.

>>         mhp = &default_hstate_max_huge_pages;
>>     else
>>         mhp = &parsed_hstate->max_huge_pages;
>> -- 
>> 2.1.4
>>
>> -- 
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>

-- 
Vaishali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
