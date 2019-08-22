Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2549C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:34:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92EF7233FD
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 15:34:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92EF7233FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C426B0332; Thu, 22 Aug 2019 11:34:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21A516B0333; Thu, 22 Aug 2019 11:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 130CF6B0334; Thu, 22 Aug 2019 11:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0223.hostedemail.com [216.40.44.223])
	by kanga.kvack.org (Postfix) with ESMTP id E6E4E6B0332
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 11:34:05 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 780248248AA4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:34:05 +0000 (UTC)
X-FDA: 75850459650.26.quilt62_679194ab123b
X-HE-Tag: quilt62_679194ab123b
X-Filterd-Recvd-Size: 10814
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com [47.88.44.36])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 15:34:04 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0Ta8nB38_1566488023;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0Ta8nB38_1566488023)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 22 Aug 2019 23:33:46 +0800
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
To: Michal Hocko <mhocko@kernel.org>, kirill.shutemov@linux.intel.com
Cc: hannes@cmpxchg.org, vbabka@suse.cz, rientjes@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190822080434.GF12785@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9e4ba38e-0670-7292-ab3a-38af391598ec@linux.alibaba.com>
Date: Thu, 22 Aug 2019 08:33:40 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190822080434.GF12785@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/22/19 1:04 AM, Michal Hocko wrote:
> On Thu 22-08-19 01:55:25, Yang Shi wrote:
>> Available memory is one of the most important metrics for memory
>> pressure.
> I would disagree with this statement. It is a rough estimate that tells
> how much memory you can allocate before going into a more expensive
> reclaim (mostly swapping). Allocating that amount still might result in
> direct reclaim induced stalls. I do realize that this is simple metric
> that is attractive to use and works in many cases though.

OK, I would rephrase this a little it, say "useful metric".

>
>> Currently, the deferred split THPs are not accounted into
>> available memory, but they are reclaimable actually, like reclaimable
>> slabs.
>>
>> And, they seems very common with the common workloads when THP is
>> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
>> always shows it could generate over fifteen thousand deferred split THPs
>> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
>> It looks worth accounting in MemAvailable.
> OK, this makes sense. But your above numbers are really worrying.
> Accumulating such a large amount of pages that are likely not going to
> be used is really bad. They are essentially blocking any higher order
> allocations and also push the system towards more memory pressure.

That is accumulated number, during the running of the test, some of them 
were freed by shrinker already. IOW, it should not reach that much at 
any given time.

>
> IIUC deferred splitting is mostly a workaround for nasty locking issues
> during splitting, right? This is not really an optimization to cache
> THPs for reuse or something like that. What is the reason this is not
> done from a worker context? At least THPs which would be freed
> completely sound like a good candidate for kworker tear down, no?

Yes, deferred split THP was introduced to avoid locking issues according 
to the document. Memcg awareness would help to trigger the shrinker more 
often.

I think it could be done in a worker context, but when to trigger to 
worker is a subtle problem.

>
>> Record the number of freeable normal pages of deferred split THPs into
>> the second tail page, and account it into KReclaimable.  Although THP
>> allocations are not exactly "kernel allocations", once they are unmapped,
>> they are in fact kernel-only.  KReclaimable has been accounted into
>> MemAvailable.
> This sounds reasonable to me.
>   
>> When the deferred split THPs get split due to memory pressure or freed,
>> just decrease by the recorded number.
>>
>> With this change when running program which populates 1G address space
>> then madvise(MADV_DONTNEED) 511 pages for every THP, /proc/meminfo would
>> show the deferred split THPs are accounted properly.
>>
>> Populated by before calling madvise(MADV_DONTNEED):
>> MemAvailable:   43531960 kB
>> AnonPages:       1096660 kB
>> KReclaimable:      26156 kB
>> AnonHugePages:   1056768 kB
>>
>> After calling madvise(MADV_DONTNEED):
>> MemAvailable:   44411164 kB
>> AnonPages:         50140 kB
>> KReclaimable:    1070640 kB
>> AnonHugePages:     10240 kB
>>
>> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Other than the above concern, which is little bit orthogonal, the patch
> looks reasonable to me. I might be missing subtle THPisms so I am not
> going to ack though.
>
>> ---
>>   Documentation/filesystems/proc.txt |  4 ++--
>>   include/linux/huge_mm.h            |  7 +++++--
>>   include/linux/mm_types.h           |  3 ++-
>>   mm/huge_memory.c                   | 13 ++++++++++++-
>>   mm/rmap.c                          |  4 ++--
>>   5 files changed, 23 insertions(+), 8 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index 99ca040..93fc183 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -968,8 +968,8 @@ ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
>>                 with huge pages
>>   ShmemPmdMapped: Shared memory mapped into userspace with huge pages
>>   KReclaimable: Kernel allocations that the kernel will attempt to reclaim
>> -              under memory pressure. Includes SReclaimable (below), and other
>> -              direct allocations with a shrinker.
>> +              under memory pressure. Includes SReclaimable (below), deferred
>> +              split THPs, and other direct allocations with a shrinker.
>>           Slab: in-kernel data structures cache
>>   SReclaimable: Part of Slab, that might be reclaimed, such as caches
>>     SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
>> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> index 61c9ffd..c194630 100644
>> --- a/include/linux/huge_mm.h
>> +++ b/include/linux/huge_mm.h
>> @@ -162,7 +162,7 @@ static inline int split_huge_page(struct page *page)
>>   {
>>   	return split_huge_page_to_list(page, NULL);
>>   }
>> -void deferred_split_huge_page(struct page *page);
>> +void deferred_split_huge_page(struct page *page, unsigned int nr);
>>   
>>   void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>>   		unsigned long address, bool freeze, struct page *page);
>> @@ -324,7 +324,10 @@ static inline int split_huge_page(struct page *page)
>>   {
>>   	return 0;
>>   }
>> -static inline void deferred_split_huge_page(struct page *page) {}
>> +static inline void deferred_split_huge_page(struct page *page, unsigned int nr)
>> +{
>> +}
>> +
>>   #define split_huge_pmd(__vma, __pmd, __address)	\
>>   	do { } while (0)
>>   
>> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
>> index 156640c..17e0fc5 100644
>> --- a/include/linux/mm_types.h
>> +++ b/include/linux/mm_types.h
>> @@ -138,7 +138,8 @@ struct page {
>>   		};
>>   		struct {	/* Second tail page of compound page */
>>   			unsigned long _compound_pad_1;	/* compound_head */
>> -			unsigned long _compound_pad_2;
>> +			/* Freeable normal pages for deferred split shrinker */
>> +			unsigned long nr_freeable;
>>   			/* For both global and memcg */
>>   			struct list_head deferred_list;
>>   		};
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index c9a596e..e04ac4d 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -524,6 +524,7 @@ void prep_transhuge_page(struct page *page)
>>   
>>   	INIT_LIST_HEAD(page_deferred_list(page));
>>   	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
>> +	page[2].nr_freeable = 0;
>>   }
>>   
>>   static unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
>> @@ -2766,6 +2767,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>>   		if (!list_empty(page_deferred_list(head))) {
>>   			ds_queue->split_queue_len--;
>>   			list_del(page_deferred_list(head));
>> +			__mod_node_page_state(page_pgdat(page),
>> +					NR_KERNEL_MISC_RECLAIMABLE,
>> +					-head[2].nr_freeable);
>> +			head[2].nr_freeable = 0;
>>   		}
>>   		if (mapping)
>>   			__dec_node_page_state(page, NR_SHMEM_THPS);
>> @@ -2816,11 +2821,14 @@ void free_transhuge_page(struct page *page)
>>   		ds_queue->split_queue_len--;
>>   		list_del(page_deferred_list(page));
>>   	}
>> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
>> +			      -page[2].nr_freeable);
>> +	page[2].nr_freeable = 0;
>>   	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>>   	free_compound_page(page);
>>   }
>>   
>> -void deferred_split_huge_page(struct page *page)
>> +void deferred_split_huge_page(struct page *page, unsigned int nr)
>>   {
>>   	struct deferred_split *ds_queue = get_deferred_split_queue(page);
>>   #ifdef CONFIG_MEMCG
>> @@ -2844,6 +2852,9 @@ void deferred_split_huge_page(struct page *page)
>>   		return;
>>   
>>   	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>> +	page[2].nr_freeable += nr;
>> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
>> +			      nr);
>>   	if (list_empty(page_deferred_list(page))) {
>>   		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
>>   		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index e5dfe2a..6008fab 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1286,7 +1286,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
>>   
>>   	if (nr) {
>>   		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
>> -		deferred_split_huge_page(page);
>> +		deferred_split_huge_page(page, nr);
>>   	}
>>   }
>>   
>> @@ -1320,7 +1320,7 @@ void page_remove_rmap(struct page *page, bool compound)
>>   		clear_page_mlock(page);
>>   
>>   	if (PageTransCompound(page))
>> -		deferred_split_huge_page(compound_head(page));
>> +		deferred_split_huge_page(compound_head(page), 1);
>>   
>>   	/*
>>   	 * It would be tidy to reset the PageAnon mapping here,
>> -- 
>> 1.8.3.1


