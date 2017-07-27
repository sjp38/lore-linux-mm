Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7D4B6B04C2
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:12:12 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v77so15146652pgb.15
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:12:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j24si11074591pfa.685.2017.07.27.09.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 09:12:11 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RGBE0l143795
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:12:11 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byhfdep5p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:12:10 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 10:12:10 -0600
Subject: Re: [PATCH v3 1/3] mm/hugetlb: Allow arch to override and call the
 weak function
References: <20170727061828.11406-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727152556.s4uw5cuvdf36hodl@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 21:42:04 +0530
MIME-Version: 1.0
In-Reply-To: <20170727152556.s4uw5cuvdf36hodl@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <da6a497b-e65c-b0db-3dab-83aa300a75ca@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



On 07/27/2017 08:55 PM, Liam R. Howlett wrote:
> * Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> [170727 02:18]:
>> For ppc64, we want to call this function when we are not running as guest.
>> Also, if we failed to allocate hugepages, let the user know.
>>
> [...]
>> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>> index bc48ee783dd9..a3a7a7e6339e 100644
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -2083,7 +2083,9 @@ struct page *alloc_huge_page_noerr(struct vm_area_struct *vma,
>>   	return page;
>>   }
>>   
>> -int __weak alloc_bootmem_huge_page(struct hstate *h)
>> +int alloc_bootmem_huge_page(struct hstate *h)
>> +	__attribute__ ((weak, alias("__alloc_bootmem_huge_page")));
>> +int __alloc_bootmem_huge_page(struct hstate *h)
>>   {
>>   	struct huge_bootmem_page *m;
>>   	int nr_nodes, node;
>> @@ -2104,6 +2106,7 @@ int __weak alloc_bootmem_huge_page(struct hstate *h)
>>   			goto found;
>>   		}
>>   	}
>> +	pr_info("Failed to allocate hugepage of size %ld\n", huge_page_size(h));
>>   	return 0;
>>   
>>   found:
> 
> There is already a call to warn the user in the
> hugetlb_hstate_alloc_pages function.  If you look there, you will see
> that the huge_page_size was translated into a more user friendly format
> and the count prior to the failure is included.  What call path are you
> trying to cover?  Also, you may want your print to be a pr_warn since it
> is a failure?
> 

Sorry I missed that in the recent kernel. I wrote the above before the 
mentioned changes was done. I will drop the pr_info from the patch.

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
