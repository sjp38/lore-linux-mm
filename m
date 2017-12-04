Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F30B36B0038
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 10:24:50 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 73so13365284pfz.11
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 07:24:50 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id i8si10434939pfk.151.2017.12.04.07.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 07:24:49 -0800 (PST)
Subject: Re: stalled MM patches
References: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <d8aafa56-8bc8-e392-68a4-dee57ba7e190@codeaurora.org>
Date: Mon, 4 Dec 2017 20:54:32 +0530
MIME-Version: 1.0
In-Reply-To: <20171130141423.600101bcef07ab2900286865@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexandru Moise <00moses.alexander00@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrey Vagin <avagin@openvz.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, "Artem S. Tashkinov" <t.artem@lycos.com>, Balbir Singh <bsingharora@gmail.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, David Rientjes <rientjes@google.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Glauber Costa <glommer@openvz.org>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Ingo Molnar <mingo@kernel.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Maxim Patlasov <MPatlasov@parallels.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Punit Agrawal <punit.agrawal@arm.com>, Rik van Riel <riel@redhat.com>, Shiraz Hashim <shashim@codeaurora.org>, Tan Xiaojun <tanxiaojun@huawei.com>, Theodore Ts'o <tytso@mit.edu>, Vladimir Davydov <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org

On 12/1/2017 3:44 AM, Andrew Morton wrote:
> I'm sitting on a bunch of patches of varying ages which are stuck for
> various reason.  Can people please take a look some time and assist
> with getting them merged, dropped or fixed?
>
> I'll send them all out in a sec.  I have rough notes (which might be
> obsolete) and additional details can be found by following the Link: in
> the individual patches.
>
> Thanks.
>
> Subject: mm: skip HWPoisoned pages when onlining pages
>
>   mhocko had issues with this one.
>
> Subject: mm/mempolicy: remove redundant check in get_nodes
> Subject: mm/mempolicy: fix the check of nodemask from user
> Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
>
>   Three patch series.  Stuck because vbabka wasn't happy with #3.
>
> Subject: mm: memcontrol: eliminate raw access to stat and event counters
> Subject: mm: memcontrol: implement lruvec stat functions on top of each other
> Subject: mm: memcontrol: fix excessive complexity in memory.stat reporting
>
>   Three patch series.  Stuck because #3 caused fengguang-bot to
>   report "BUG: using __this_cpu_xchg() in preemptible"
>
> Subject: mm/madvise: enable soft offline of HugeTLB pages at PUD level
>
>   Hoping for Kirill review.  I wanted additional code comments (I
>   think).  mhocko nacked it.
>
> Subject: mm: readahead: increase maximum readahead window
>
>   Darrick said he was going to do some testing.
>
> Subject: fs/proc/task_mmu.c: do not show VmExe bigger than total executable virtual memory
>
>   I had some questions, but they were responded to, whcih made my
>   head spin a bit.  I guess I'll push this to Linus but would
>   appreciate additional review.
>
> Subject: mm, hugetlb: remove hugepages_treat_as_movable sysctl
>
>   I'm holding this for additional testing.  I guess I'll merge it in
>   4.16-rc1.
>
> Subject: mm: vmscan: do not pass reclaimed slab to vmpressure
>
>   mhocko asked for a changelog update
>
Michal was of the opinion that we should reconsider how we calculate vmpressure rather than
making this fix. I am okay if this patch is dropped, but I feel it would be better if slab reclaimed
pages are skipped from vmpressure calculation because
1) Adding only reclaimed pages to a model which works on scanned and reclaimed seems like
a wrong thing.
2) As Minchan mentioned, the cost model is different and thus adding slab reclaimed would not
be a right thing to do.

But Michal's question was whether the model would be better if we skip slab reclaimed pages.
I am not sure about this, but at least vmpressure without slab noise gives the pressure on LRU
and we have been using this in deciding the right point to trigger lowmemorykiller kills. And we
have seen that slab noise make the vmpressure value unreliable at least for lowmemorykiller.
But I agree this is just one workload, so I don't have more points in favor of this patch.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
