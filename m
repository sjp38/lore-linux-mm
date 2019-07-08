Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40694C606CF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:52:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0616216FD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:52:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0616216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FDC58E0037; Mon,  8 Jul 2019 18:52:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2AE628E0032; Mon,  8 Jul 2019 18:52:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19D288E0037; Mon,  8 Jul 2019 18:52:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D62E18E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 18:52:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u1so10396154pgr.13
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 15:52:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=tfEa/2Z8+FBi2plWpY2XxMvtHLQ+mwkexfXFE1HfB8E=;
        b=cZXGZeNevqYKXWTOAjjMLwOI0RCmtry0ZXOrlg6SIbNTcwJAGjpbeN+cHzcz4FTi76
         Q0HWXspGbGlrlfHhlRr87zdolt78VwQH4F0Wj5aSNzS1hHtaCIScKZ+IXP3sLXQ1Rzqv
         /kgeaoyj+aQ+O+YabMDpgeqtNeXsyz3SCbjZIE+tJUjTU2xD4H8FG8s5RDkpm830W3A2
         bjZTsaS+e/b2ZL/w9KqS8FOD89lFrqyIMvhoEI3yLUgubrwMFD7pnganC66YroRjIKmE
         BxkgFQlpfVY0rOXWVKxOZ1u818/BBAdJb+yqjeDN1YNRLiL+rEwgjDJJfnu4ynK4uurb
         f+tA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWo0MxvP/YNI+vwvdI8pQSvTrZEwQFYfxamUo6F3+pC68WHcbZ9
	qvj+O7y9Oyi8aXkSgUaU9TxACbiCq1/lyEhRJfy5nF+MALCVy7jNoCBHEclFlV8AfAEtGCrISzv
	RR5Z4O9uOZbfF9TPG9FyqCuj7IbUlR0Swir3HwwenzqLNeNx+cY2xqHg0pQ6hCVEmwQ==
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr27359565plt.337.1562626361508;
        Mon, 08 Jul 2019 15:52:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy17VEEP3yGogRQCw3YvPF3E21JQ0RCNizesM9Yuuw5B+7GjvlYHBUrLa8+te+ducgzHezN
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr27359482plt.337.1562626360475;
        Mon, 08 Jul 2019 15:52:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562626360; cv=none;
        d=google.com; s=arc-20160816;
        b=XFDbyqzYdt1/Vlh+hvmt1q6m723I09B5wecuDF4qlASBn2lAM83SoloPnVptRGSKq3
         Rj2qYzTbQMaRZey1DyTinBSBcwX+t/UYxw6lwE1L3rcCjodY3ZAeBJQA4TYxDoYbCvKt
         9/wgUYKaDnlVA49jDeExg2wj73310eEzMZhRVAUksun1dr1QRhVXpCcH/y98r3UGmb6c
         V12eQWKIzuos5GpQ2DagmzhHDlxImRWQEuN36m+BOW5vR/OYbHLcqFcBwDuL0xqmTG3u
         gxRdE0bu0CbySoU54sG9RrINNWlDAzIFOe0M+N0aMWMMjmapbIeMDt08b2sXc309uBEh
         0MFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tfEa/2Z8+FBi2plWpY2XxMvtHLQ+mwkexfXFE1HfB8E=;
        b=VrDg0W6Udh2QVJDSaa1XTCrGUQ4578XbTHVVS8SPQyjZhqHfUS0QbVfD9J9WGM6gnm
         jn2XgRQJaaoe8nXBdDaD2oX67Dx81VQPNt/yihv3JQnLmwjHwKEsf8fTc6zAd5bIMj7X
         Gz6jfxEMysWabDMKEumDGPVOGtz1eEvcZAT/ZPkhNVEDuXKwF1aCQxlVOqCl+Y6EdJ1k
         AbNmlYGSLvgFKjeEFlOOSv8grR9NdUzG+XfCU8uVrCpaaIbOT93AmWhKeAKJGA8OVqoR
         fAM92VCWkexaPG/qS/r0VVNWxQllF0bqI2NE/BlYYQpB4WunWLzvISUTXgYhcTnFyU7o
         V9GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id e21si20339631pgh.571.2019.07.08.15.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 15:52:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TWPu3FD_1562626354;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWPu3FD_1562626354)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 09 Jul 2019 06:52:37 +0800
Subject: Re: [PATCH 1/2 -mm] mm: account lazy free pages separately
To: rientjes@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com,
 hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <60eb1dbd-b320-ce9b-34f5-bc2e8b6d660b@linux.alibaba.com>
Date: Mon, 8 Jul 2019 15:52:29 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi guys,


Any comment on this series?


Thanks,

Yang



On 6/27/19 10:12 AM, Yang Shi wrote:
> When doing partial unmap to THP, the pages in the affected range would
> be considered to be reclaimable when memory pressure comes in.  And,
> such pages would be put on deferred split queue and get minus from the
> memory statistics (i.e. /proc/meminfo).
>
> For example, when doing THP split test, /proc/meminfo would show:
>
> Before put on lazy free list:
> MemTotal:       45288336 kB
> MemFree:        43281376 kB
> MemAvailable:   43254048 kB
> ...
> Active(anon):    1096296 kB
> Inactive(anon):     8372 kB
> ...
> AnonPages:       1096264 kB
> ...
> AnonHugePages:   1056768 kB
>
> After put on lazy free list:
> MemTotal:       45288336 kB
> MemFree:        43282612 kB
> MemAvailable:   43255284 kB
> ...
> Active(anon):    1094228 kB
> Inactive(anon):     8372 kB
> ...
> AnonPages:         49668 kB
> ...
> AnonHugePages:     10240 kB
>
> The THPs confusingly look disappeared although they are still on LRU if
> you are not familair the tricks done by kernel.
>
> Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
> and other places.  With the change the /proc/meminfo would look like:
> Before put on lazy free list:
> AnonHugePages:   1056768 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> LazyFreePages:         0 kB
>
> After put on lazy free list:
> AnonHugePages:     10240 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> LazyFreePages:   1046528 kB
>
> And, this is also the preparation for the following patch to account
> lazy free pages to available memory.
>
> Here the lazyfree doesn't count MADV_FREE pages since they are not
> actually unmapped until they get reclaimed.  And, they are put on
> inactive file LRU, so they have been accounted for available memory.
>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> I'm not quite sure whether LazyFreePages is a good name or not since "Lazyfree"
> is typically referred to MADV_FREE pages.  I could use a more spceific name,
> i.e. "DeferredSplitTHP" since it doesn't account MADV_FREE as explained in the
> commit log.  But, a more general name would be good for including other type
> pages in the future.
>
> And, I'm also not sure if it is a good idea to show this in memcg stat or not.
>
>   Documentation/filesystems/proc.txt | 12 ++++++++----
>   drivers/base/node.c                |  3 +++
>   fs/proc/meminfo.c                  |  3 +++
>   include/linux/mmzone.h             |  1 +
>   mm/huge_memory.c                   |  8 ++++++++
>   mm/page_alloc.c                    |  2 ++
>   mm/vmstat.c                        |  1 +
>   7 files changed, 26 insertions(+), 4 deletions(-)
>
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 66cad5c..851ddfd 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -895,6 +895,7 @@ HardwareCorrupted:   0 kB
>   AnonHugePages:   49152 kB
>   ShmemHugePages:      0 kB
>   ShmemPmdMapped:      0 kB
> +LazyFreePages:       0 kB
>   
>   
>       MemTotal: Total usable ram (i.e. physical ram minus a few reserved
> @@ -902,12 +903,13 @@ ShmemPmdMapped:      0 kB
>        MemFree: The sum of LowFree+HighFree
>   MemAvailable: An estimate of how much memory is available for starting new
>                 applications, without swapping. Calculated from MemFree,
> -              SReclaimable, the size of the file LRU lists, and the low
> -              watermarks in each zone.
> +              SReclaimable, the size of the file LRU lists, LazyFree pages
> +              and the low watermarks in each zone.
>                 The estimate takes into account that the system needs some
>                 page cache to function well, and that not all reclaimable
> -              slab will be reclaimable, due to items being in use. The
> -              impact of those factors will vary from system to system.
> +              slab and LazyFree pages will be reclaimable, due to items
> +              being in use. The impact of those factors will vary from
> +              system to system.
>        Buffers: Relatively temporary storage for raw disk blocks
>                 shouldn't get tremendously large (20MB or so)
>         Cached: in-memory cache for files read from the disk (the
> @@ -945,6 +947,8 @@ AnonHugePages: Non-file backed huge pages mapped into userspace page tables
>   ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
>                 with huge pages
>   ShmemPmdMapped: Shared memory mapped into userspace with huge pages
> +LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
> +               split THP).
>   KReclaimable: Kernel allocations that the kernel will attempt to reclaim
>                 under memory pressure. Includes SReclaimable (below), and other
>                 direct allocations with a shrinker.
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 8598fcb..ef701aa 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -427,6 +427,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>   		       "Node %d ShmemHugePages: %8lu kB\n"
>   		       "Node %d ShmemPmdMapped: %8lu kB\n"
>   #endif
> +		       "Node %d LazyFreePages:	%8lu kB\n"
>   			,
>   		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
>   		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
> @@ -453,6 +454,8 @@ static ssize_t node_read_meminfo(struct device *dev,
>   		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
>   				       HPAGE_PMD_NR)
>   #endif
> +		       ,
> +		       nid, K(node_page_state(pgdat, NR_LAZYFREE))
>   		       );
>   	n += hugetlb_report_node_meminfo(nid, buf + n);
>   	return n;
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 568d90e..b02ebd0 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -138,6 +138,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>   		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
>   #endif
>   
> +	show_val_kb(m, "LazyFreePages:  ",
> +		    global_node_page_state(NR_LAZYFREE));
> +
>   #ifdef CONFIG_CMA
>   	show_val_kb(m, "CmaTotal:       ", totalcma_pages);
>   	show_val_kb(m, "CmaFree:        ",
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 7799166..523ea86 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -235,6 +235,7 @@ enum node_stat_item {
>   	NR_SHMEM_THPS,
>   	NR_SHMEM_PMDMAPPED,
>   	NR_ANON_THPS,
> +	NR_LAZYFREE,		/* Lazyfree pages, i.e. deferred split THP */
>   	NR_UNSTABLE_NFS,	/* NFS unstable pages */
>   	NR_VMSCAN_WRITE,
>   	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4f20273..78806c7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2757,6 +2757,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
>   		if (!list_empty(page_deferred_list(head))) {
>   			ds_queue->split_queue_len--;
>   			list_del(page_deferred_list(head));
> +			__mod_node_page_state(NODE_DATA(page_to_nid(head)),
> +					NR_LAZYFREE, -HPAGE_PMD_NR);
>   		}
>   		if (mapping)
>   			__dec_node_page_state(page, NR_SHMEM_THPS);
> @@ -2806,6 +2808,8 @@ void free_transhuge_page(struct page *page)
>   	if (!list_empty(page_deferred_list(page))) {
>   		ds_queue->split_queue_len--;
>   		list_del(page_deferred_list(page));
> +		__mod_node_page_state(NODE_DATA(page_to_nid(page)),
> +				NR_LAZYFREE, -HPAGE_PMD_NR);
>   	}
>   	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
>   	free_compound_page(page);
> @@ -2822,6 +2826,8 @@ void deferred_split_huge_page(struct page *page)
>   	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
>   	if (list_empty(page_deferred_list(page))) {
>   		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
> +		__mod_node_page_state(NODE_DATA(page_to_nid(page)),
> +				NR_LAZYFREE, HPAGE_PMD_NR);
>   		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
>   		ds_queue->split_queue_len++;
>   		if (memcg)
> @@ -2873,6 +2879,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
>   			/* We lost race with put_compound_page() */
>   			list_del_init(page_deferred_list(page));
>   			ds_queue->split_queue_len--;
> +			__mod_node_page_state(NODE_DATA(page_to_nid(page)),
> +					NR_LAZYFREE, -HPAGE_PMD_NR);
>   		}
>   		if (!--sc->nr_to_scan)
>   			break;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7f27f4e..cab50e8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5210,6 +5210,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>   			" shmem_pmdmapped: %lukB"
>   			" anon_thp: %lukB"
>   #endif
> +			" lazyfree:%lukB"
>   			" writeback_tmp:%lukB"
>   			" unstable:%lukB"
>   			" all_unreclaimable? %s"
> @@ -5232,6 +5233,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>   					* HPAGE_PMD_NR),
>   			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
>   #endif
> +			K(node_page_state(pgdat, NR_LAZYFREE)),
>   			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>   			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
>   			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index a7d4933..87703f2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1158,6 +1158,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
>   	"nr_shmem_hugepages",
>   	"nr_shmem_pmdmapped",
>   	"nr_anon_transparent_hugepages",
> +	"nr_lazyfree",
>   	"nr_unstable",
>   	"nr_vmscan_write",
>   	"nr_vmscan_immediate_reclaim",

