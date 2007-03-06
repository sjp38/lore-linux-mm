Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l26BaDuj026904
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:36:15 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l26BN7kx034286
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:23:10 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l26BJZCJ025294
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:19:35 +1100
Message-ID: <45ED4E40.3010404@linux.vnet.ibm.com>
Date: Tue, 06 Mar 2007 16:49:28 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3][RFC] Containers: Pagecache controller reclaim
References: <45ED251C.2010400@linux.vnet.ibm.com> <45ED266E.7040107@linux.vnet.ibm.com> <5d4poyvfdq.fsf@Hurtta06k.keh.iki.fi>
In-Reply-To: <5d4poyvfdq.fsf@Hurtta06k.keh.iki.fi>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kari Hurtta <hurtta+gmane@siilo.fmi.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Kari Hurtta wrote:
> Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> writes
> in gmane.linux.kernel,gmane.linux.kernel.mm:
> 
>> --- linux-2.6.20.orig/mm/pagecache_acct.c
>> +++ linux-2.6.20/mm/pagecache_acct.c
>> @@ -29,6 +29,7 @@
>>  #include <linux/uaccess.h>
>>  #include <asm/div64.h>
>>  #include <linux/pagecache_acct.h>
>> +#include <linux/memcontrol.h>
>>
>>  /*
>>   * Convert unit from pages to kilobytes
>> @@ -337,12 +338,20 @@ int pagecache_acct_cont_overlimit(struct
>>  		return 0;
>>  }
>>
>> -extern unsigned long shrink_all_pagecache_memory(unsigned long nr_pages);
>> +extern unsigned long shrink_container_memory(unsigned int memory_type,
>> +				unsigned long nr_pages, void *container);
>>
>>  int pagecache_acct_shrink_used(unsigned long nr_pages)
>>  {
>>  	unsigned long ret = 0;
>>  	atomic_inc(&reclaim_count);
>> +
>> +	/* Don't call reclaim for each page above limit */
>> +	if (nr_pages > NR_PAGES_RECLAIM_THRESHOLD) {
>> +		ret += shrink_container_memory(
>> +				RECLAIM_PAGECACHE_MEMORY, nr_pages, NULL);
>> +	}
>> +
>>  	return 0;
>>  }
>>
> 
> 'ret' is not used ?

I have been setting watch points and tracing the value of ret.
Basically that is used while debugging.  I have not removed it since
this is an RFC post and we would go through many cleanups cycles.

I will remember to remove it in the next version or verify that the
compiler does remove 'ret' :)

--Vaidy

> / Kari Hurtta
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
