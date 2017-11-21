Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19AE96B0261
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:09:45 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v8so7001079wrd.21
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 17:09:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id n21si1015095edn.262.2017.11.20.17.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 17:09:43 -0800 (PST)
Subject: Re: [PATCH v2] mm: show total hugetlb memory consumption in
 /proc/meminfo
References: <20171115231409.12131-1-guro@fb.com>
 <20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a63311cd-5e29-951a-dcac-a96ddbc2662b@oracle.com>
Date: Mon, 20 Nov 2017 17:09:30 -0800
MIME-Version: 1.0
In-Reply-To: <20171120165110.587918bf75ffecb8144da66c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On 11/20/2017 04:51 PM, Andrew Morton wrote:
> On Wed, 15 Nov 2017 23:14:09 +0000 Roman Gushchin <guro@fb.com> wrote:
> 
>> Currently we display some hugepage statistics (total, free, etc)
>> in /proc/meminfo, but only for default hugepage size (e.g. 2Mb).
>>
>> If hugepages of different sizes are used (like 2Mb and 1Gb on x86-64),
>> /proc/meminfo output can be confusing, as non-default sized hugepages
>> are not reflected at all, and there are no signs that they are
>> existing and consuming system memory.
>>
>> To solve this problem, let's display the total amount of memory,
>> consumed by hugetlb pages of all sized (both free and used).
>> Let's call it "Hugetlb", and display size in kB to match generic
>> /proc/meminfo style.
>>
>> For example, (1024 2Mb pages and 2 1Gb pages are pre-allocated):
>>   $ cat /proc/meminfo
>>   MemTotal:        8168984 kB
>>   MemFree:         3789276 kB
>>   <...>
>>   CmaFree:               0 kB
>>   HugePages_Total:    1024
>>   HugePages_Free:     1024
>>   HugePages_Rsvd:        0
>>   HugePages_Surp:        0
>>   Hugepagesize:       2048 kB
>>   Hugetlb:         4194304 kB
>>   DirectMap4k:       32632 kB
>>   DirectMap2M:     4161536 kB
>>   DirectMap1G:     6291456 kB
>>
>> Also, this patch updates corresponding docs to reflect
>> Hugetlb entry meaning and difference between Hugetlb and
>> HugePages_Total * Hugepagesize.
>>
>> ...
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2973,20 +2973,32 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
>>  
>>  void hugetlb_report_meminfo(struct seq_file *m)
>>  {
>> -	struct hstate *h = &default_hstate;
>> +	struct hstate *h;
>> +	unsigned long total = 0;
>> +
>>  	if (!hugepages_supported())
>>  		return;
>> -	seq_printf(m,
>> -			"HugePages_Total:   %5lu\n"
>> -			"HugePages_Free:    %5lu\n"
>> -			"HugePages_Rsvd:    %5lu\n"
>> -			"HugePages_Surp:    %5lu\n"
>> -			"Hugepagesize:   %8lu kB\n",
>> -			h->nr_huge_pages,
>> -			h->free_huge_pages,
>> -			h->resv_huge_pages,
>> -			h->surplus_huge_pages,
>> -			1UL << (huge_page_order(h) + PAGE_SHIFT - 10));
>> +
>> +	for_each_hstate(h) {
>> +		unsigned long count = h->nr_huge_pages;
>> +
>> +		total += (PAGE_SIZE << huge_page_order(h)) * count;
>> +
>> +		if (h == &default_hstate)
> 
> I'm not understanding this test.  Are we assuming that default_hstate
> always refers to the highest-index hstate?  If so why, and is that
> valid?

Actually default_hstate is defined as:

#define default_hstate (hstates[default_hstate_idx])

default_hstate_idx is set during hugetlb_init based upon default_hstate_size
which defaults to HPAGE_SIZE.  However, it can be overridden by the kernel
command line argument "default_hugepagesz=<size>".

By definition and history /proc/meminfo lists information on the default
huge page size.  This code is looping through all hstates to get the total
memory consumed by hugetlb pages for the new "Hugetlb" field.  When it gets
to the default huge page size, it prints the historic fields.

Hope that helps,
-- 
Mike Kravetz

> 
>> +			seq_printf(m,
>> +				   "HugePages_Total:   %5lu\n"
>> +				   "HugePages_Free:    %5lu\n"
>> +				   "HugePages_Rsvd:    %5lu\n"
>> +				   "HugePages_Surp:    %5lu\n"
>> +				   "Hugepagesize:   %8lu kB\n",
>> +				   count,
>> +				   h->free_huge_pages,
>> +				   h->resv_huge_pages,
>> +				   h->surplus_huge_pages,
>> +				   (PAGE_SIZE << huge_page_order(h)) / 1024);
>> +	}
>> +
>> +	seq_printf(m, "Hugetlb:        %8lu kB\n", total / 1024);
>>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
