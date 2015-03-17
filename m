Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6B46B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 22:23:28 -0400 (EDT)
Received: by qcaz10 with SMTP id z10so62182689qca.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 19:23:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e188si11823164qhc.102.2015.03.16.19.23.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 19:23:27 -0700 (PDT)
Message-ID: <55079005.9000307@redhat.com>
Date: Mon, 16 Mar 2015 22:23:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page_alloc: Call kernel_map_pages in unset_migrateype_isolate
References: <1426530585-11367-1-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1426530585-11367-1-git-send-email-lauraa@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Gioh Kim <gioh.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>

On 03/16/2015 02:29 PM, Laura Abbott wrote:
> Commit 3c605096d315 ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> changed the logic of unset_migratetype_isolate to check the buddy allocator
> and explicitly call __free_pages to merge. The page that is being freed in
> this path never had prep_new_page called so set_page_refcounted is called
> explicitly but there is no call to kernel_map_pages. With the default
> kernel_map_pages this is mostly harmless but if kernel_map_pages does any
> manipulation of the page tables (unmapping or setting pages to read only) this
> may trigger a fault:
> 
>     alloc_contig_range test_pages_isolated(ceb00, ced00) failed
>     Unable to handle kernel paging request at virtual address ffffffc0cec00000
>     pgd = ffffffc045fc4000
>     [ffffffc0cec00000] *pgd=0000000000000000
>     Internal error: Oops: 9600004f [#1] PREEMPT SMP
>     Modules linked in: exfatfs
>     CPU: 1 PID: 23237 Comm: TimedEventQueue Not tainted 3.10.49-gc72ad36-dirty #1
>     task: ffffffc03de52100 ti: ffffffc015388000 task.ti: ffffffc015388000
>     PC is at memset+0xc8/0x1c0
>     LR is at kernel_map_pages+0x1ec/0x244
> 
> Fix this by calling kernel_map_pages to ensure the page is set in the
> page table properly

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
