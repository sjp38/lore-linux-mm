Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8326A28024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:43:26 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x203so19954124oia.2
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 19:43:26 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u55si4023771otu.2.2016.09.27.19.43.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 19:43:25 -0700 (PDT)
Message-ID: <57EB2D35.4070006@huawei.com>
Date: Wed, 28 Sep 2016 10:38:45 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,ksm: add __GFP_HIGH to the allocation in alloc_stable_node()
References: <1474354484-58233-1-git-send-email-zhongjiang@huawei.com> <20160920140639.2f1ea83784d994699e713c2e@linux-foundation.org>
In-Reply-To: <20160920140639.2f1ea83784d994699e713c2e@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: hughd@google.com, mhocko@suse.cz, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org

On 2016/9/21 5:06, Andrew Morton wrote:
> On Tue, 20 Sep 2016 14:54:44 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> Accoding to HUgh's suggestion, alloc_stable_node() with GFP_KERNEL
>> will cause the hungtask, despite less possiblity.
>>
>> At present, if alloc_stable_node allocate fails, two break_cow may
>> want to allocate a couple of pages, and the issue will come up when
>> free memory is under pressure.
>>
>> we fix it by adding the __GFP_HIGH to GFP. because it grant access to
>> some of meory reserves. it will make progess to make it allocation
>> successful at the utmost.
>>
>> --- a/mm/ksm.c
>> +++ b/mm/ksm.c
>> @@ -299,7 +299,7 @@ static inline void free_rmap_item(struct rmap_item *rmap_item)
>>  
>>  static inline struct stable_node *alloc_stable_node(void)
>>  {
>> -	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL);
>> +	return kmem_cache_alloc(stable_node_cache, GFP_KERNEL | __GFP_HIGH);
>>  }
>>  
>>  static inline void free_stable_node(struct stable_node *stable_node)
> It is very hard for a reader to understand why this __GFP_HIGH is being
> used here, so we should have a code comment explaining the reasoning,
> please.
  ok,  I will add  some code comment later.
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
