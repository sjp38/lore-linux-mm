Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18FDC6B0253
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 12:38:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v13so31924927pgq.1
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 09:38:20 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id f19si1547259plr.246.2017.10.06.09.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 09:38:18 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
 <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
 <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <ff7e0d92-0f12-46fa-dbc7-79c556ffb7c2@alibaba-inc.com>
Date: Sat, 07 Oct 2017 00:37:55 +0800
MIME-Version: 1.0
In-Reply-To: <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/6/17 2:37 AM, Michal Hocko wrote:
> On Thu 05-10-17 05:29:10, Yang Shi wrote:
>> Kernel may panic when oom happens without killable process sometimes it
>> is caused by huge unreclaimable slabs used by kernel.
>>
>> Although kdump could help debug such problem, however, kdump is not
>> available on all architectures and it might be malfunction sometime.
>> And, since kernel already panic it is worthy capturing such information
>> in dmesg to aid touble shooting.
>>
>> Print out unreclaimable slab info (used size and total size) which
>> actual memory usage is not zero (num_objs * size != 0) when
>> unreclaimable slabs amount is greater than total user memory (LRU
>> pages).
>>
>> The output looks like:
>>
>> Unreclaimable slab info:
>> Name                      Used          Total
>> rpc_buffers               31KB         31KB
>> rpc_tasks                  7KB          7KB
>> ebitmap_node            1964KB       1964KB
>> avtab_node              5024KB       5024KB
>> xfs_buf                 1402KB       1402KB
>> xfs_ili                  134KB        134KB
>> xfs_efi_item             115KB        115KB
>> xfs_efd_item             115KB        115KB
>> xfs_buf_item             134KB        134KB
>> xfs_log_item_desc        342KB        342KB
>> xfs_trans               1412KB       1412KB
>> xfs_ifork                212KB        212KB
> 
> OK this looks better. The naming is not the greatest but I will not
> nitpick on this. I have one question though
> 
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
> [...]
>> +void dump_unreclaimable_slab(void)
>> +{
>> +	struct kmem_cache *s, *s2;
>> +	struct slabinfo sinfo;
>> +
>> +	/*
>> +	 * Here acquiring slab_mutex is risky since we don't prefer to get
>> +	 * sleep in oom path. But, without mutex hold, it may introduce a
>> +	 * risk of crash.
>> +	 * Use mutex_trylock to protect the list traverse, dump nothing
>> +	 * without acquiring the mutex.
>> +	 */
>> +	if (!mutex_trylock(&slab_mutex)) {
>> +		pr_warn("excessive unreclaimable slab but cannot dump stats\n");
>> +		return;
>> +	}
>> +
>> +	pr_info("Unreclaimable slab info:\n");
>> +	pr_info("Name                      Used          Total\n");
>> +
>> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
>> +			continue;
>> +
>> +		memset(&sinfo, 0, sizeof(sinfo));
> 
> why do you zero out the structure. All the fields you are printing are
> filled out in get_slabinfo.

No special reason, just wipe out the potential stale data on the stack.

Yang

> 
>> +		get_slabinfo(s, &sinfo);
>> +
>> +		if (sinfo.num_objs > 0)
>> +			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
>> +				(sinfo.active_objs * s->size) / 1024,
>> +				(sinfo.num_objs * s->size) / 1024);
>> +	}
>> +	mutex_unlock(&slab_mutex);
>> +}
>> +
>>   #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>>   void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>>   {
>> -- 
>> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
