Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD285C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 990622070B
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 08:04:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 990622070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 455CA6B02DF; Thu, 22 Aug 2019 04:04:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 407436B02E0; Thu, 22 Aug 2019 04:04:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CF0D6B02E1; Thu, 22 Aug 2019 04:04:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0135.hostedemail.com [216.40.44.135])
	by kanga.kvack.org (Postfix) with ESMTP id 04E8D6B02DF
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 04:04:38 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 85B938248AAC
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:04:38 +0000 (UTC)
X-FDA: 75849327036.13.coat76_b5da634b1a4c
X-HE-Tag: coat76_b5da634b1a4c
X-Filterd-Recvd-Size: 9666
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 08:04:37 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5CF99AC1C;
	Thu, 22 Aug 2019 08:04:35 +0000 (UTC)
Date: Thu, 22 Aug 2019 10:04:34 +0200
From: Michal Hocko <mhocko@kernel.org>
To: kirill.shutemov@linux.intel.com, Yang Shi <yang.shi@linux.alibaba.com>
Cc: hannes@cmpxchg.org, vbabka@suse.cz, rientjes@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH -mm] mm: account deferred split THPs into MemAvailable
Message-ID: <20190822080434.GF12785@dhcp22.suse.cz>
References: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566410125-66011-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 22-08-19 01:55:25, Yang Shi wrote:
> Available memory is one of the most important metrics for memory
> pressure.

I would disagree with this statement. It is a rough estimate that tells
how much memory you can allocate before going into a more expensive
reclaim (mostly swapping). Allocating that amount still might result in
direct reclaim induced stalls. I do realize that this is simple metric
that is attractive to use and works in many cases though.

> Currently, the deferred split THPs are not accounted into
> available memory, but they are reclaimable actually, like reclaimable
> slabs.
> 
> And, they seems very common with the common workloads when THP is
> enabled.  A simple run with MariaDB test of mmtest with THP enabled as
> always shows it could generate over fifteen thousand deferred split THPs
> (accumulated around 30G in one hour run, 75% of 40G memory for my VM).
> It looks worth accounting in MemAvailable.

OK, this makes sense. But your above numbers are really worrying.
Accumulating such a large amount of pages that are likely not going to
be used is really bad. They are essentially blocking any higher order
allocations and also push the system towards more memory pressure.

IIUC deferred splitting is mostly a workaround for nasty locking issues
during splitting, right? This is not really an optimization to cache
THPs for reuse or something like that. What is the reason this is not
done from a worker context? At least THPs which would be freed
completely sound like a good candidate for kworker tear down, no?

> Record the number of freeable normal pages of deferred split THPs into
> the second tail page, and account it into KReclaimable.  Although THP
> allocations are not exactly "kernel allocations", once they are unmapped,
> they are in fact kernel-only.  KReclaimable has been accounted into
> MemAvailable.

This sounds reasonable to me.
 
> When the deferred split THPs get split due to memory pressure or freed,
> just decrease by the recorded number.
> 
> With this change when running program which populates 1G address space
> then madvise(MADV_DONTNEED) 511 pages for every THP, /proc/meminfo would
> show the deferred split THPs are accounted properly.
> 
> Populated by before calling madvise(MADV_DONTNEED):
> MemAvailable:   43531960 kB
> AnonPages:       1096660 kB
> KReclaimable:      26156 kB
> AnonHugePages:   1056768 kB
> 
> After calling madvise(MADV_DONTNEED):
> MemAvailable:   44411164 kB
> AnonPages:         50140 kB
> KReclaimable:    1070640 kB
> AnonHugePages:     10240 kB
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Other than the above concern, which is little bit orthogonal, the patch
looks reasonable to me. I might be missing subtle THPisms so I am not
going to ack though.

> ---
>  Documentation/filesystems/proc.txt |  4 ++--
>  include/linux/huge_mm.h            |  7 +++++--
>  include/linux/mm_types.h           |  3 ++-
>  mm/huge_memory.c                   | 13 ++++++++++++-
>  mm/rmap.c                          |  4 ++--
>  5 files changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 99ca040..93fc183 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -968,8 +968,8 @@ ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
>                with huge pages
>  ShmemPmdMapped: Shared memory mapped into userspace with huge pages
>  KReclaimable: Kernel allocations that the kernel will attempt to reclaim
> -              under memory pressure. Includes SReclaimable (below), and other
> -              direct allocations with a shrinker.
> +              under memory pressure. Includes SReclaimable (below), deferred
> +              split THPs, and other direct allocations with a shrinker.
>          Slab: in-kernel data structures cache
>  SReclaimable: Part of Slab, that might be reclaimed, such as caches
>    SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 61c9ffd..c194630 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -162,7 +162,7 @@ static inline int split_huge_page(struct page *page)
>  {
>  	return split_huge_page_to_list(page, NULL);
>  }
> -void deferred_split_huge_page(struct page *page);
> +void deferred_split_huge_page(struct page *page, unsigned int nr);
>  
>  void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long address, bool freeze, struct page *page);
> @@ -324,7 +324,10 @@ static inline int split_huge_page(struct page *page)
>  {
>  	return 0;
>  }
> -static inline void deferred_split_huge_page(struct page *page) {}
> +static inline void deferred_split_huge_page(struct page *page, unsigned int nr)
> +{
> +}
> +
>  #define split_huge_pmd(__vma, __pmd, __address)	\
>  	do { } while (0)
>  
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 156640c..17e0fc5 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -138,7 +138,8 @@ struct page {
>  		};
>  		struct {	/* Second tail page of compound page */
>  			unsigned long _compound_pad_1;	/* compound_head */
> -			unsigned long _compound_pad_2;
> +			/* Freeable normal pages for deferred split shrinker */
> +			unsigned long nr_freeable;
>  			/* For both global and memcg */
>  			struct list_head deferred_list;
>  		};
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c9a596e..e04ac4d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -524,6 +524,7 @@ void prep_transhuge_page(struct page *page)
>  
>  	INIT_LIST_HEAD(page_deferred_list(page));
>  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
> +	page[2].nr_freeable = 0;
>  }
>  
>  static unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long len,
> @@ -2766,6 +2767,10 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>  		if (!list_empty(page_deferred_list(head))) {
>  			ds_queue->split_queue_len--;
>  			list_del(page_deferred_list(head));
> +			__mod_node_page_state(page_pgdat(page),
> +					NR_KERNEL_MISC_RECLAIMABLE,
> +					-head[2].nr_freeable);
> +			head[2].nr_freeable = 0;
>  		}
>  		if (mapping)
>  			__dec_node_page_state(page, NR_SHMEM_THPS);
> @@ -2816,11 +2821,14 @@ void free_transhuge_page(struct page *page)
>  		ds_queue->split_queue_len--;
>  		list_del(page_deferred_list(page));
>  	}
> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
> +			      -page[2].nr_freeable);
> +	page[2].nr_freeable = 0;
>  	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>  	free_compound_page(page);
>  }
>  
> -void deferred_split_huge_page(struct page *page)
> +void deferred_split_huge_page(struct page *page, unsigned int nr)
>  {
>  	struct deferred_split *ds_queue = get_deferred_split_queue(page);
>  #ifdef CONFIG_MEMCG
> @@ -2844,6 +2852,9 @@ void deferred_split_huge_page(struct page *page)
>  		return;
>  
>  	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
> +	page[2].nr_freeable += nr;
> +	__mod_node_page_state(page_pgdat(page), NR_KERNEL_MISC_RECLAIMABLE,
> +			      nr);
>  	if (list_empty(page_deferred_list(page))) {
>  		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
>  		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2a..6008fab 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1286,7 +1286,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
>  
>  	if (nr) {
>  		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
> -		deferred_split_huge_page(page);
> +		deferred_split_huge_page(page, nr);
>  	}
>  }
>  
> @@ -1320,7 +1320,7 @@ void page_remove_rmap(struct page *page, bool compound)
>  		clear_page_mlock(page);
>  
>  	if (PageTransCompound(page))
> -		deferred_split_huge_page(compound_head(page));
> +		deferred_split_huge_page(compound_head(page), 1);
>  
>  	/*
>  	 * It would be tidy to reset the PageAnon mapping here,
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

