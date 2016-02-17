Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f179.google.com (mail-yk0-f179.google.com [209.85.160.179])
	by kanga.kvack.org (Postfix) with ESMTP id D61F8828E2
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 05:31:02 -0500 (EST)
Received: by mail-yk0-f179.google.com with SMTP id z13so4820206ykd.0
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 02:31:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id u62si244337yba.4.2016.02.17.02.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Feb 2016 02:31:02 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: Fix incorrect proc nr_hugepages value
References: <1455651806-25977-1-git-send-email-vaishali.thakkar@oracle.com>
 <20160217095935.GA15769@node.shutemov.name>
From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Message-ID: <56C44BC0.1000104@oracle.com>
Date: Wed, 17 Feb 2016 16:00:24 +0530
MIME-Version: 1.0
In-Reply-To: <20160217095935.GA15769@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, n-horiguchi@ah.jp.nec.com, mike.kravetz@oracle.com, hillf.zj@alibaba-inc.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, paul.gortmaker@windriver.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wednesday 17 February 2016 03:29 PM, Kirill A. Shutemov wrote:
> On Wed, Feb 17, 2016 at 01:13:26AM +0530, Vaishali Thakkar wrote:
>> Currently incorrect default hugepage pool size is reported by proc
>> nr_hugepages when number of pages for the default huge page size is
>> specified twice.
>>
>> When multiple huge page sizes are supported, /proc/sys/vm/nr_hugepages
>> indicates the current number of pre-allocated huge pages of the default
>> size. Basically /proc/sys/vm/nr_hugepages displays default_hstate->
>> max_huge_pages and after boot time pre-allocation, max_huge_pages should
>> equal the number of pre-allocated pages (nr_hugepages).
>>
>> Test case:
>>
>> Note that this is specific to x86 architecture.
>>
>> Boot the kernel with command line option 'default_hugepagesz=1G
>> hugepages=X hugepagesz=2M hugepages=Y hugepagesz=1G hugepages=Z'. After
>> boot, 'cat /proc/sys/vm/nr_hugepages' and 'sysctl -a | grep hugepages'
>> returns the value X.  However, dmesg output shows that Z huge pages were
>> pre-allocated.
>>
>> So, the root cause of the problem here is that the global variable
>> default_hstate_max_huge_pages is set if a default huge page size is
>> specified (directly or indirectly) on the command line. After the
>> command line processing in hugetlb_init, if default_hstate_max_huge_pages
>> is set, the value is assigned to default_hstae.max_huge_pages. However,
>> default_hstate.max_huge_pages may have already been set based on the
>> number of pre-allocated huge pages of default_hstate size.
>>
>> The solution to this problem is if hstate->max_huge_pages is already set
>> then it should not set as a result of global max_huge_pages value.
>> Basically if the value of the variable hugepages is set multiple times
>> on a command line for a specific supported hugepagesize then proc layer
>> should consider the last specified value.
>>
>> Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>
>> ---
>> The patch contains one line over 80 characters as I think limiting that
>> line to 80 characters makes code look bit ugly. But if anyone is having
>> issue with that then I am fine with limiting it to 80 chracters.
> What about this?
>
> 	if (default_hstate_max_huge_pages && !default_hstate.max_huge_pages)
> 		default_hstate.max_huge_pages =	default_hstate_max_huge_pages;

Yes, it does the same thing. I thought about it. But to me somehow it looks
hard to read. So, personally I don't prefer it.

Do you want me to change this?

>> ---
>>  mm/hugetlb.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index 06ae13e..01f2b48 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2630,8 +2630,10 @@ static int __init hugetlb_init(void)
>>  			hugetlb_add_hstate(HUGETLB_PAGE_ORDER);
>>  	}
>>  	default_hstate_idx = hstate_index(size_to_hstate(default_hstate_size));
>> -	if (default_hstate_max_huge_pages)
>> -		default_hstate.max_huge_pages = default_hstate_max_huge_pages;
>> +	if (default_hstate_max_huge_pages) {
>> +		if (!default_hstate.max_huge_pages)
>> +			default_hstate.max_huge_pages = default_hstate_max_huge_pages;
>> +	}
>>  
>>  	hugetlb_init_hstates();
>>  	gather_bootmem_prealloc();
>> -- 
>> 2.1.4
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Vaishali

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
