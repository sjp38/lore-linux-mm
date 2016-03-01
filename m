Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEE06B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 07:42:17 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p65so31690177wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:42:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z200si2533261wmc.57.2016.03.01.04.42.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 04:42:16 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH 1/1] mm: thp: Set THP defrag by default to madvise and add
 a stall-free defrag option
References: <1456503359-4910-1-git-send-email-mgorman@techsingularity.net>
Message-ID: <56D58E1E.5090708@suse.cz>
Date: Tue, 1 Mar 2016 13:42:06 +0100
MIME-Version: 1.0
In-Reply-To: <1456503359-4910-1-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 02/26/2016 05:15 PM, Mel Gorman wrote:
> Changelog since v1
> o Default defrag to madvise instead of never
> o Introduce "defer" defrag option to wake kswapd/kcompact if THP is unavailable
> o Restore "always" to historical behaviour
> o Update documentation
>
> THP defrag is enabled by default to direct reclaim/compact but not wake
> kswapd in the event of a THP allocation failure. The problem is that THP
> allocation requests potentially enter reclaim/compaction. This potentially
> incurs a severe stall that is not guaranteed to be offset by reduced TLB
> misses. While there has been considerable effort to reduce the impact
> of reclaim/compaction, it is still a high cost and workloads that should
> fit in memory fail to do so. Specifically, a simple anon/file streaming
> workload will enter direct reclaim on NUMA at least even though the working
> set size is 80% of RAM. It's been years and it's time to throw in the towel.
>
> First, this patch defines THP defrag as follows;
>
> madvise: A failed allocation will direct reclaim/compact if the application requests it
> never:   Neither reclaim/compact nor wake kswapd
> defer:   A failed allocation will wake kswapd/kcompactd
> always:  A failed allocation will direct reclaim/compact (historical behaviour)
> khugepaged defrag will enter direct/reclaim but not wake kswapd.
>
> Next it sets the default defrag option to be "madvise" to only enter direct
> reclaim/compaction for applications that specifically requested it.
>
> Lastly, it removes a check from the page allocator slowpath that is related
> to __GFP_THISNODE to allow "defer" to work. The callers that really cares are
> slub/slab and they are updated accordingly. The slab one may be surprising
> because it also corrects a comment as kswapd was never woken up by that path.

It would be also nice if we could remove the is_thp_gfp_mask() checks one day. 
They try to make direct reclaim/compaction for THP less intrusive, but maybe 
could be removed now that the stalls are limited otherwise. But that's out of 
scope here.

[...]

> diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> index 8a282687ee06..a19b173cbc57 100644
> --- a/Documentation/vm/transhuge.txt
> +++ b/Documentation/vm/transhuge.txt
> @@ -113,9 +113,26 @@ guaranteed, but it may be more likely in case the allocation is for a
>   MADV_HUGEPAGE region.
>
>   echo always >/sys/kernel/mm/transparent_hugepage/defrag
> +echo defer >/sys/kernel/mm/transparent_hugepage/defrag
>   echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
>   echo never >/sys/kernel/mm/transparent_hugepage/defrag
>
> +"always" means that an application requesting THP will stall on allocation
> +failure and directly reclaim pages and compact memory in an effort to
> +allocate a THP immediately. This may be desirable for virtual machines
> +that benefit heavily from THP use and are willing to delay the VM start
> +to utilise them.
> +
> +"defer" means that an application will wake kswapd in the background
> +to reclaim pages and wake kcompact to compact memory so that THP is
> +available in the near future. It's the responsibility of khugepaged
> +to then install the THP pages later.
> +
> +"madvise" will enter direct reclaim like "always" but only for regions
> +that are have used madvise(). This is the default behaviour.

"madvise(MADV_HUGEPAGE)" perhaps?

[...]

> @@ -277,17 +273,23 @@ static ssize_t double_flag_store(struct kobject *kobj,
>   static ssize_t enabled_show(struct kobject *kobj,
>   			    struct kobj_attribute *attr, char *buf)
>   {
> -	return double_flag_show(kobj, attr, buf,
> -				TRANSPARENT_HUGEPAGE_FLAG,
> -				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> +	if (test_bit(TRANSPARENT_HUGEPAGE_FLAG, &transparent_hugepage_flags)) {
> +		VM_BUG_ON(test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags));
> +		return sprintf(buf, "[always] madvise never\n");
> +	} else if (test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "always [madvise] never\n");
> +	else
> +		return sprintf(buf, "always madvise [never]\n");

Somewhat ugly wrt consistent usage of { }, due to the VM_BUG_ON(), which I would 
just drop. Also I wonder if some racy read vs write of the file can trigger the 
BUG_ON? Or are the kobject accesses synchronized at a higher level?

>   }
> +
>   static ssize_t enabled_store(struct kobject *kobj,
>   			     struct kobj_attribute *attr,
>   			     const char *buf, size_t count)
>   {
>   	ssize_t ret;
>
> -	ret = double_flag_store(kobj, attr, buf, count,
> +	ret = triple_flag_store(kobj, attr, buf, count,
> +				TRANSPARENT_HUGEPAGE_FLAG,
>   				TRANSPARENT_HUGEPAGE_FLAG,
>   				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);

So this makes "echo defer > enabled" behave just like "echo always"? For 
userspace interface that becomes a fixed ABI, I would prefer to be more careful 
with unintended aliases like this. Maybe pass something like "-1" that 
triple_flag_store() would check in the "defer" case and return -EINVAL?

> @@ -345,16 +347,23 @@ static ssize_t single_flag_store(struct kobject *kobj,
>   static ssize_t defrag_show(struct kobject *kobj,
>   			   struct kobj_attribute *attr, char *buf)
>   {
> -	return double_flag_show(kobj, attr, buf,
> -				TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> -				TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "[always] defer madvise never\n");
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "always [defer] madvise never\n");
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +		return sprintf(buf, "always defer [madvise] never\n");
> +	else
> +		return sprintf(buf, "always defer madvise [never]\n");
> +
>   }
>   static ssize_t defrag_store(struct kobject *kobj,
>   			    struct kobj_attribute *attr,
>   			    const char *buf, size_t count)
>   {
> -	return double_flag_store(kobj, attr, buf, count,
> -				 TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> +	return triple_flag_store(kobj, attr, buf, count,
> +				 TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> +				 TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
>   				 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
>   }
>   static struct kobj_attribute defrag_attr =
> @@ -784,9 +793,30 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>   	return 0;
>   }
>
> -static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
> +/*
> + * If THP is set to always then directly reclaim/compact as necessary
> + * If set to defer then do no reclaim and defer to khugepaged
> + * If set to madvise and the VMA is flagged then directly reclaim/compact
> + */
> +static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
> +{
> +	gfp_t reclaim_flags = 0;
> +
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags) &&
> +	    (vma->vm_flags & VM_HUGEPAGE))
> +		reclaim_flags = __GFP_DIRECT_RECLAIM;
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> +		reclaim_flags = __GFP_KSWAPD_RECLAIM;
> +	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
> +		reclaim_flags = __GFP_DIRECT_RECLAIM;

Hmm, here's a trick question. What if I wanted direct reclaim for madvise() 
vma's and kswapd/kcompactd for others? Right now there's no such option, right? 
And expressing that with different values for a single tunable becomes ugly...

(For completeness, somebody could want kswapd/kcompactd defrag only for 
madvise() but that's arguably not much useful)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
