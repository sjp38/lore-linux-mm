Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id D6A096B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 11:04:12 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id e16so1437231lan.2
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 08:04:11 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id y8si3676657lae.133.2014.04.03.08.04.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Apr 2014 08:04:09 -0700 (PDT)
Message-ID: <533D7864.7080907@parallels.com>
Date: Thu, 3 Apr 2014 19:04:04 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2.1] mm: get rid of __GFP_KMEMCG
References: <c50644c5c979fbe21e72cc2751876ceaff6ef495.1396335798.git.vdavydov@parallels.com> <1396419365-351-1-git-send-email-vdavydov@parallels.com> <xr934n2bjuec.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr934n2bjuec.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/03/2014 01:25 AM, Greg Thelen wrote:
> On Tue, Apr 01 2014, Vladimir Davydov <vdavydov@parallels.com> wrote:
>
>> Currently to allocate a page that should be charged to kmemcg (e.g.
>> threadinfo), we pass __GFP_KMEMCG flag to the page allocator. The page
>> allocated is then to be freed by free_memcg_kmem_pages. Apart from
>> looking asymmetrical, this also requires intrusion to the general
>> allocation path. So let's introduce separate functions that will
>> alloc/free pages charged to kmemcg.
>>
>> The new functions are called alloc_kmem_pages and free_kmem_pages. They
>> should be used when the caller actually would like to use kmalloc, but
>> has to fall back to the page allocator for the allocation is large. They
>> only differ from alloc_pages and free_pages in that besides allocating
>> or freeing pages they also charge them to the kmem resource counter of
>> the current memory cgroup.
>>
>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> One comment nit below, otherwise looks good to me.
>
> Acked-by: Greg Thelen <gthelen@google.com>
>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@suse.cz>
>> Cc: Glauber Costa <glommer@gmail.com>
>> Cc: Christoph Lameter <cl@linux-foundation.org>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> ---
>> Changes in v2.1:
>>  - add missing kmalloc_order forward declaration; lacking it caused
>>    compilation breakage with CONFIG_TRACING=n
>>
>>  include/linux/gfp.h             |   10 ++++---
>>  include/linux/memcontrol.h      |    2 +-
>>  include/linux/slab.h            |   11 +-------
>>  include/linux/thread_info.h     |    2 --
>>  include/trace/events/gfpflags.h |    1 -
>>  kernel/fork.c                   |    6 ++---
>>  mm/page_alloc.c                 |   56 ++++++++++++++++++++++++---------------
>>  mm/slab_common.c                |   12 +++++++++
>>  mm/slub.c                       |    6 ++---
>>  9 files changed, 61 insertions(+), 45 deletions(-)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 39b81dc7d01a..d382db71e300 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -31,7 +31,6 @@ struct vm_area_struct;
>>  #define ___GFP_HARDWALL		0x20000u
>>  #define ___GFP_THISNODE		0x40000u
>>  #define ___GFP_RECLAIMABLE	0x80000u
>> -#define ___GFP_KMEMCG		0x100000u
>>  #define ___GFP_NOTRACK		0x200000u
>>  #define ___GFP_NO_KSWAPD	0x400000u
>>  #define ___GFP_OTHER_NODE	0x800000u
>> @@ -91,7 +90,6 @@ struct vm_area_struct;
>>  
>>  #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
>>  #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
>> -#define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
>>  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
>>  
>>  /*
>> @@ -353,6 +351,10 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>>  #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
>>  	alloc_pages_vma(gfp_mask, 0, vma, addr, node)
>>  
>> +extern struct page *alloc_kmem_pages(gfp_t gfp_mask, unsigned int order);
>> +extern struct page *alloc_kmem_pages_node(int nid, gfp_t gfp_mask,
>> +					  unsigned int order);
>> +
>>  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
>>  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
>>  
>> @@ -372,8 +374,8 @@ extern void free_pages(unsigned long addr, unsigned int order);
>>  extern void free_hot_cold_page(struct page *page, int cold);
>>  extern void free_hot_cold_page_list(struct list_head *list, int cold);
>>  
>> -extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
>> -extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
>> +extern void __free_kmem_pages(struct page *page, unsigned int order);
>> +extern void free_kmem_pages(unsigned long addr, unsigned int order);
>>  
>>  #define __free_page(page) __free_pages((page), 0)
>>  #define free_page(addr) free_pages((addr), 0)
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index 29068dd26c3d..13acdb5259f5 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -543,7 +543,7 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
>>  	 * res_counter_charge_nofail, but we hope those allocations are rare,
>>  	 * and won't be worth the trouble.
>>  	 */
> Just a few lines higher in first memcg_kmem_newpage_charge() comment,
> there is a leftover reference to GFP_KMEMCG which should be removed.

Good catch, will resend.

Thank you for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
