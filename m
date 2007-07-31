Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6VCwVMH061158
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:58:31 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6VCxIID197604
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:59:19 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6VCtjtj022202
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:55:46 +1000
Message-ID: <46AF314C.7030404@linux.vnet.ibm.com>
Date: Tue, 31 Jul 2007 18:25:40 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [-mm PATCH 6/9] Memory controller add per container LRU and reclaim
 (v4)
References: <20070727201041.31565.14803.sendpatchset@balbir-laptop> <20070731051459.E827E1BF77B@siro.lan>
In-Reply-To: <20070731051459.E827E1BF77B@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, dhaval@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>


YAMAMOTO Takashi wrote:
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
> 
> what prevents another thread from freeing mp here?

mem_cont->lru_lock protects the list and validity of mp.  If we hold
mem_cont->lru_lock for this entire loop, then we preserve the validity
of mp.  However that will be holding up container charge and uncharge.

This entire routing is called with zone->lru_lock held by the caller.
 So within a zone, this routine is serialized.

However page uncharge may race with isolate page.  But will that lead
to any corruption of the list?  We may be holding the lock for too
much time just to be on the safe side.

Please allow us some time to verify whether this is indeed inadequate
locking that will lead to corruption of the list.

Thanks for pointing out this situation.
--Vaidy

>> +		spin_lock(&mem_cont->lru_lock);
>> +		if (mp)
>> +			page = mp->page;
>> +		spin_unlock(&mem_cont->lru_lock);
>> +		if (!mp)
>> +			continue;
> 
> YAMAMOTO Takashi
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
