Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2A11D6B0036
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 03:39:21 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so2312909lbg.35
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 00:39:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id h8si680930lam.242.2014.03.27.00.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Mar 2014 00:39:19 -0700 (PDT)
Message-ID: <5333D5A6.8090409@parallels.com>
Date: Thu, 27 Mar 2014 11:39:18 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 3/4] fork: charge threadinfo to memcg explicitly
References: <cover.1395846845.git.vdavydov@parallels.com> <8f98a5160b9e17947cbb25e91944f332679b9c9c.1395846845.git.vdavydov@parallels.com> <20140326220050.GC22656@dhcp22.suse.cz>
In-Reply-To: <20140326220050.GC22656@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 03/27/2014 02:00 AM, Michal Hocko wrote:
> On Wed 26-03-14 19:28:06, Vladimir Davydov wrote:
>> We have only a few places where we actually want to charge kmem so
>> instead of intruding into the general page allocation path with
>> __GFP_KMEMCG it's better to explictly charge kmem there. All kmem
>> charges will be easier to follow that way.
>>
>> This is a step toward removing __GFP_KMEMCG. It makes fork charge task
>> threadinfo pages explicitly instead of passing __GFP_KMEMCG to
>> alloc_pages.
> Looks good from a quick glance. I would also remove
> THREADINFO_GFP_ACCOUNTED in this patch.

To do so,  I'd have to remove __GFP_KMEMCG check from
memcg_kmem_newpage_charge, which is better to do in the next patch,
which removes __GFP_KMEMCG everywhere, IMO.

Thanks.

>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Glauber Costa <glommer@gmail.com>
>> ---
>>  kernel/fork.c |   13 ++++++++++---
>>  1 file changed, 10 insertions(+), 3 deletions(-)
>>
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index f4b09bc15f3a..8209780cf732 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -150,15 +150,22 @@ void __weak arch_release_thread_info(struct thread_info *ti)
>>  static struct thread_info *alloc_thread_info_node(struct task_struct *tsk,
>>  						  int node)
>>  {
>> -	struct page *page = alloc_pages_node(node, THREADINFO_GFP_ACCOUNTED,
>> -					     THREAD_SIZE_ORDER);
>> +	struct page *page;
>> +	struct mem_cgroup *memcg = NULL;
>>  
>> +	if (!memcg_kmem_newpage_charge(THREADINFO_GFP_ACCOUNTED, &memcg,
>> +				       THREAD_SIZE_ORDER))
>> +		return NULL;
>> +	page = alloc_pages_node(node, THREADINFO_GFP, THREAD_SIZE_ORDER);
>> +	memcg_kmem_commit_charge(page, memcg, THREAD_SIZE_ORDER);
>>  	return page ? page_address(page) : NULL;
>>  }
>>  
>>  static inline void free_thread_info(struct thread_info *ti)
>>  {
>> -	free_memcg_kmem_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>> +	if (ti)
>> +		memcg_kmem_uncharge_pages(virt_to_page(ti), THREAD_SIZE_ORDER);
>> +	free_pages((unsigned long)ti, THREAD_SIZE_ORDER);
>>  }
>>  # else
>>  static struct kmem_cache *thread_info_cache;
>> -- 
>> 1.7.10.4
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
