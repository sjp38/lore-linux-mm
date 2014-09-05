Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 359986B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 22:33:40 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id z6so203943yhz.29
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 19:33:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k29si936346yha.8.2014.09.04.19.33.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 19:33:39 -0700 (PDT)
Message-ID: <540920DB.9000200@oracle.com>
Date: Fri, 05 Sep 2014 10:32:59 +0800
From: Junxiao Bi <junxiao.bi@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com> <20140904092329.GN20473@dastard>
In-Reply-To: <20140904092329.GN20473@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 09/04/2014 05:23 PM, Dave Chinner wrote:
> On Wed, Sep 03, 2014 at 01:54:54PM +0800, Junxiao Bi wrote:
>> commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
>> introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
>> when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
>> run into I/O, like in superblock shrinker.
>>
>> Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
>> Cc: joyce.xue <xuejiufei@huawei.com>
>> Cc: Ming Lei <ming.lei@canonical.com>
>> ---
>>  include/linux/sched.h |    6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index 5c2c885..2fb2c47 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1936,11 +1936,13 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
>>  #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
>>  #define used_math() tsk_used_math(current)
>>  
>> -/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
>> +/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags
>> + * __GFP_FS is also cleared as it implies __GFP_IO.
>> + */
>>  static inline gfp_t memalloc_noio_flags(gfp_t flags)
>>  {
>>  	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
>> -		flags &= ~__GFP_IO;
>> +		flags &= ~(__GFP_IO | __GFP_FS);
>>  	return flags;
>>  }
> 
> You also need to mask all the shrink_control->gfp_mask
> initialisations in mm/vmscan.c. The current code only masks the page
> reclaim gfp_mask, not those that are passed to the shrinkers.
Yes, there are some shrink_control->gfp_mask not masked in vmscan.c in
the following functions. Beside this, all seemed be masked from direct
reclaim path by memalloc_noio_flags().

-reclaim_clean_pages_from_list()
used by alloc_contig_range(), this function is invoked in hugetlb and
cma, for hugetlb, it should be safe as only userspace use it. I am not
sure about the cma.
David & Andrew, may you share your idea about whether cma is affected?

-mem_cgroup_shrink_node_zone()
-try_to_free_mem_cgroup_pages()
These two are used by mem cgroup, as no kernel thread can be assigned
into such cgroup, so i think, no need mask.

-balance_pgdat()
used by kswapd, no need mask.

-shrink_all_memory()
used by hibernate, should be safe with GFP_FS/IO.

Thanks,
Junxiao.
> 
> Cheers,
> 
> Dave.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
