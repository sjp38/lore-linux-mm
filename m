Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6OCFCeR5185670
	for <linux-mm@kvack.org>; Tue, 24 Jul 2007 22:15:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6OCHofW077724
	for <linux-mm@kvack.org>; Tue, 24 Jul 2007 22:17:50 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6OCEHIm024188
	for <linux-mm@kvack.org>; Tue, 24 Jul 2007 22:14:17 +1000
Message-ID: <46A5ED11.4090905@linux.vnet.ibm.com>
Date: Tue, 24 Jul 2007 17:44:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm PATCH 6/8] Memory controller add per container LRU
 and reclaim (v3)
References: <20070720082504.20752.62858.sendpatchset@balbir-laptop> <20070724115100.B7A9B1BF959@siro.lan>
In-Reply-To: <20070724115100.B7A9B1BF959@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, containers@lists.osdl.org, menage@google.com, haveblue@us.ibm.com, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org, ebiederm@xmission.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
> hi,
> 
>> +unsigned long mem_container_isolate_pages(unsigned long nr_to_scan,
>> +					struct list_head *dst,
>> +					unsigned long *scanned, int order,
>> +					int mode, struct zone *z,
>> +					struct mem_container *mem_cont,
>> +					int active)
>> +{
>> +	unsigned long nr_taken = 0;
>> +	struct page *page;
>> +	unsigned long scan;
>> +	LIST_HEAD(mp_list);
>> +	struct list_head *src;
>> +	struct meta_page *mp;
>> +
>> +	if (active)
>> +		src = &mem_cont->active_list;
>> +	else
>> +		src = &mem_cont->inactive_list;
>> +
>> +	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
>> +		mp = list_entry(src->prev, struct meta_page, lru);
>> +		page = mp->page;
>> +
> 
> - is it safe to pick the lists without mem_cont->lru_lock held?
> 
> - what prevents mem_container_uncharge from freeing this meta_page
>  behind us?
> 
> YAMAMOTO Takashi

Hi, YAMAMOTO,

We do take the lru_lock before deleting the page from the list
and in mem_container_move_lists(). But, I guess like you point
out page = mp->page might not be a safe operation. I'll fix
the problem in the next release.

Thanks for the review,
-- 
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
