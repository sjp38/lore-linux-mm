Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 776FAC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:32:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C3EA217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 00:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C3EA217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DED7B6B000D; Thu,  4 Apr 2019 20:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9D566B000E; Thu,  4 Apr 2019 20:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F706B026B; Thu,  4 Apr 2019 20:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83CA76B000D
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 20:32:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so2690386pgh.2
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 17:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=kq1gZ1oSWL74k0ayeZ53XFkfMVe0yxXtlQqveMy/Y0s=;
        b=ktGa77mtEh1jxydpHLQ2RW2GH1Qy+uknn6D3ySCRUHR8yOekyy2x4/4E9G63npodod
         HHSksZu76YW+bUU7dZ7t7xDY7HUHgu6mYM0+8y7p2nz7NwllDy1X7i6hiJWAPEZLlcVD
         5DLUFki2mRlxgpcJ0x0U0XeMLonpKdT73W6N5YmHJQLf0KCBH7NItiXskxQQAj/ywThW
         6kAIhAtVYXgOfkA7yFbRcQNsQ9ThcE5WSqoC4ChSbnDOSuOsqFQ6DAmKAPniYg4/Y4eo
         z3hLVTiSyDnaFx+4/45QYKAld4QvCzYnmbfAvAbzUnq/B4gmgWK2p6tj4q/7GoFgMUuK
         u8FQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXiOrRN951THMLgMFjF7PDeNgd2hBI1z33i0XOQ6O70ZYnRbGg0
	RXyggi28jJxlJI8IhTPmjYt0oVsFzYgs6tg3wtYY+9RqJWFybSEZvj+l7T+Q/u8JGJMK4UTDpaS
	PcRr4bWiPGdtdENP84dy6rs41ZzCCv9mrJWHzEvbY2HC/DZvw+zDoaoqhto75DhVH1Q==
X-Received: by 2002:a63:e554:: with SMTP id z20mr8795702pgj.234.1554424348094;
        Thu, 04 Apr 2019 17:32:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaQ60J4vYbDFfJxN+cFiN/TDzrXIXEdP2uQVy5EEdo/eXV2qXhEbT5NNF+/AiUcXjXuC0g
X-Received: by 2002:a63:e554:: with SMTP id z20mr8795603pgj.234.1554424346932;
        Thu, 04 Apr 2019 17:32:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554424346; cv=none;
        d=google.com; s=arc-20160816;
        b=HrFonlNI/HMEAW82pEUMXulM+6z5pjjI3wpdkAH27GLOFdA8AckvqoJ94mS+U+KDg9
         U8KGNcrs4w1TlByduS9xbYOlpXeR5W0QD9KcZhoJ9HQq9h4eXZPkln/pjvdL2qs96uWa
         f4PWzzE2xlrQQPUFalQSjwV/A+RygS62V9XGxD8KceTL8+rgX/ruWegruNEyNnlzH5e5
         9bu5Y0fEmTlHAswT+8GaxZmSlnmIH7YvyLZswKIfMLeAjvVI2eBD/1Xm+A54czi9J9QN
         4EQIbbtZbc6EPsuoPRgMYeWXtGPLlkJN+6YAlbXWGOA4NBPdooo8ueCD6EmHitd2a+KI
         YV5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kq1gZ1oSWL74k0ayeZ53XFkfMVe0yxXtlQqveMy/Y0s=;
        b=CQ6sXPPDjs8yCn51a6LoPci9vOH+NsbY8EDUNyzh5zDqHn7uYEZly25SExMU7pzk6t
         84VTqEWmzHPnT/7uir2T9X+fXHduGdW60+mfIhcVNOJ4o2X0HdVlbmkT4yLz2vcFzJbI
         cGpdUqUscXcFxTb1kNC61vjYlHrjMfy2dpKhYPXEDWVR4pHmp9uW++NMv/VU4ScxoBYB
         TLF9aj4kURTi4dgw/vx4SSFVXA+q6atxtlL8+4R8o5lQke7rsjfc+hUlog7FWTCZ/50T
         8q1FxAPdoGEgLs87QoU2WlZsCX4pCR2x2c4dAz6JpuWL948K04TWR57Mue0L+OzZJVTz
         LAOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id f7si19501172pfa.50.2019.04.04.17.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 17:32:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=17;SR=0;TI=SMTPD_---0TOWDP3r_1554424335;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TOWDP3r_1554424335)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 05 Apr 2019 08:32:20 +0800
Subject: Re: [RFC PATCH 00/25] Accelerate page migration and use memcg for
 PMEM management
To: ziy@nvidia.com, Dave Hansen <dave.hansen@linux.intel.com>,
 Keith Busch <keith.busch@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
 Michal Hocko <mhocko@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Mel Gorman <mgorman@techsingularity.net>, John Hubbard
 <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>,
 Nitin Gupta <nigupta@nvidia.com>, Javier Cabezas <jcabezas@nvidia.com>,
 David Nellans <dnellans@nvidia.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ef7d952f-a0c2-3947-a5bf-f6694acfdb02@linux.alibaba.com>
Date: Thu, 4 Apr 2019 17:32:15 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/3/19 7:00 PM, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>
> Thanks to Dave Hansen's patches, which make PMEM as part of memory as NUMA nodes.
> How to use PMEM along with normal DRAM remains an open problem. There are
> several patchsets posted on the mailing list, proposing to use page migration to
> move pages between PMEM and DRAM using Linux page replacement policy [1,2,3].
> There are some important problems not addressed in these patches:
> 1. The page migration in Linux does not provide high enough throughput for us to
> fully exploit PMEM or other use cases.
> 2. Linux page replacement is running too infrequent to distinguish hot and cold
> pages.
>
> I am trying to attack the problems with this patch series. This is not a final
> solution, but I would like to gather more feedback and comments from the mailing
> list.
>
> Page migration throughput problem
> ====
>
> For example, in my recent email [4], I gave the page migration throughput numbers
> for different page migrations, none of which can achieve > 2.5GB/s throughput
> (the throughput is measured around kernel functions: migrate_pages() and
> migrate_page_copy()):
>
>                               |  migrate_pages() |    migrate_page_copy()
> migrating single 4KB page:   |  0.312GB/s       |   1.385GB/s
> migrating 512 4KB pages:     |  0.854GB/s       |   1.983GB/s
> migrating single 2MB THP:    |  2.387GB/s       |   2.481GB/s
>
> In reality, microbenchmarks show that Intel PMEM can provide ~65GB/s read
> throughput and ~16GB/s write throughput [5], which are much higher than
> the throughput achieved by Linux page migration.
>
> In addition, it is also desirable to use page migration to move data
> between high-bandwidth memory and DRAM, like IBM Summit, which exposes
> high-performance GPU memories as NUMA nodes [6]. This requires even higher page
> migration throughput.
>
> In this patch series, I propose four different ways of improving page migration
> throughput (mostly on 2MB THP migration):
> 1. multi-threaded page migration: Patch 03 to 06.
> 2. DMA-based (using Intel IOAT DMA) page migration: Patch 07 and 08.
> 3. concurrent (batched) page migration: Patch 09, 10, and 11.
> 4. exchange pages: Patch 12 to 17. (This is a repost of part of [7])
>
> Here are some throughput numbers showing clear throughput improvements on
> a two-socket NUMA machine with two Xeon E5-2650 v3 @ 2.30GHz and a 19.2GB/s
> bandwidth QPI link (the same machine as mentioned in [4]):
>
>                                      |  migrate_pages() |   migrate_page_copy()
> => migrating single 2MB THP         |  2.387GB/s       |   2.481GB/s
>   2-thread single THP migration      |  3.478GB/s       |   3.704GB/s
>   4-thread single THP migration      |  5.474GB/s       |   6.054GB/s
>   8-thread single THP migration      |  7.846GB/s       |   9.029GB/s
> 16-thread single THP migration      |  7.423GB/s       |   8.464GB/s
> 16-ch. DMA single THP migration     |  4.322GB/s       |   4.536GB/s
>
>   2-thread 16-THP migration          |  3.610GB/s       |   3.838GB/s
>   2-thread 16-THP batched migration  |  4.138GB/s       |   4.344GB/s
>   4-thread 16-THP migration          |  6.385GB/s       |   7.031GB/s
>   4-thread 16-THP batched migration  |  7.382GB/s       |   8.072GB/s
>   8-thread 16-THP migration          |  8.039GB/s       |   9.029GB/s
>   8-thread 16-THP batched migration  |  9.023GB/s       |   10.056GB/s
> 16-thread 16-THP migration          |  8.137GB/s       |   9.137GB/s
> 16-thread 16-THP batched migration  |  9.907GB/s       |   11.175GB/s
>
>   1-thread 16-THP exchange           |  4.135GB/s       |   4.225GB/s
>   2-thread 16-THP batched exchange   |  7.061GB/s       |   7.325GB/s
>   4-thread 16-THP batched exchange   |  9.729GB/s       |   10.237GB/s
>   8-thread 16-THP batched exchange   |  9.992GB/s       |   10.533GB/s
> 16-thread 16-THP batched exchange   |  9.520GB/s       |   10.056GB/s
>
> => migrating 512 4KB pages          |  0.854GB/s       |   1.983GB/s
>   1-thread 512-4KB batched exchange  |  1.271GB/s       |   3.433GB/s
>   2-thread 512-4KB batched exchange  |  1.240GB/s       |   3.190GB/s
>   4-thread 512-4KB batched exchange  |  1.255GB/s       |   3.823GB/s
>   8-thread 512-4KB batched exchange  |  1.336GB/s       |   3.921GB/s
> 16-thread 512-4KB batched exchange  |  1.334GB/s       |   3.897GB/s
>
> Concerns were raised on how to avoid CPU resource competition between
> page migration and user applications and have power awareness.
> Daniel Jordan recently posted a multi-threaded ktask patch series could be
> a solution [8].
>
>
> Infrequent page list update problem
> ====
>
> Current page lists are updated by calling shrink_list() when memory pressure
> comes,  which might not be frequent enough to keep track of hot and cold pages.
> Because all pages are on active lists at the first time shrink_list() is called
> and the reference bit on the pages might not reflect the up to date access status
> of these pages. But we also do not want to periodically shrink the global page
> lists, which adds unnecessary overheads to the whole system. So I propose to
> actively shrink page lists on the memcg we are interested in.
>
> Patch 18 to 25 add a new system call to shrink page lists on given application's
> memcg and migrate pages between two NUMA nodes. It isolates the impact from the
> rest of the system. To share DRAM among different applications, Patch 18 and 19
> add per-node memcg size limit, so you can limit the memory usage for particular
> NUMA node(s).

This sounds a little bit confusing to me. Is it totally user's decision 
about when to call the syscall to shrink page lists? But, how would user 
know when is a good timing? Could you please elaborate the usecase?

Thanks,
Yang

>
>
> Patch structure
> ====
> 1. multi-threaded page migration: Patch 01 to 06.
> 2. DMA-based (using Intel IOAT DMA) page migration: Patch 07 and 08.
> 3. concurrent (batched) page migration: Patch 09, 10, and 11.
> 4. exchange pages: Patch 12 to 17. (This is a repost of part of [7])
> 5. per-node size limit in memcg: Patch 18 and 19.
> 6. actively shrink page lists and perform page migration in given memcg: Patch 20 to 25.
>
>
> Any comment is welcome.
>
> [1]: https://lore.kernel.org/linux-mm/20181226131446.330864849@intel.com/
> [2]: https://lore.kernel.org/linux-mm/20190321200157.29678-1-keith.busch@intel.com/
> [3]: https://lore.kernel.org/linux-mm/1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com/
> [4]: https://lore.kernel.org/linux-mm/6A903D34-A293-4056-B135-6FA227DE1828@nvidia.com/
> [5]: https://www.storagereview.com/supermicro_superserver_with_intel_optane_dc_persistent_memory_first_look_review
> [6]: https://www.ibm.com/thought-leadership/summit-supercomputer/
> [7]: https://lore.kernel.org/linux-mm/20190215220856.29749-1-zi.yan@sent.com/
> [8]: https://lore.kernel.org/linux-mm/20181105165558.11698-1-daniel.m.jordan@oracle.com/
>
> Zi Yan (25):
>    mm: migrate: Change migrate_mode to support combination migration
>      modes.
>    mm: migrate: Add mode parameter to support future page copy routines.
>    mm: migrate: Add a multi-threaded page migration function.
>    mm: migrate: Add copy_page_multithread into migrate_pages.
>    mm: migrate: Add vm.accel_page_copy in sysfs to control page copy
>      acceleration.
>    mm: migrate: Make the number of copy threads adjustable via sysctl.
>    mm: migrate: Add copy_page_dma to use DMA Engine to copy pages.
>    mm: migrate: Add copy_page_dma into migrate_page_copy.
>    mm: migrate: Add copy_page_lists_dma_always to support copy a list of
>         pages.
>    mm: migrate: copy_page_lists_mt() to copy a page list using
>      multi-threads.
>    mm: migrate: Add concurrent page migration into move_pages syscall.
>    exchange pages: new page migration mechanism: exchange_pages()
>    exchange pages: add multi-threaded exchange pages.
>    exchange pages: concurrent exchange pages.
>    exchange pages: exchange anonymous page and file-backed page.
>    exchange page: Add THP exchange support.
>    exchange page: Add exchange_page() syscall.
>    memcg: Add per node memory usage&max stats in memcg.
>    mempolicy: add MPOL_F_MEMCG flag, enforcing memcg memory limit.
>    memory manage: Add memory manage syscall.
>    mm: move update_lru_sizes() to mm_inline.h for broader use.
>    memory manage: active/inactive page list manipulation in memcg.
>    memory manage: page migration based page manipulation between NUMA
>      nodes.
>    memory manage: limit migration batch size.
>    memory manage: use exchange pages to memory manage to improve
>      throughput.
>
>   arch/x86/entry/syscalls/syscall_64.tbl |    2 +
>   fs/aio.c                               |   12 +-
>   fs/f2fs/data.c                         |    6 +-
>   fs/hugetlbfs/inode.c                   |    4 +-
>   fs/iomap.c                             |    4 +-
>   fs/ubifs/file.c                        |    4 +-
>   include/linux/cgroup-defs.h            |    1 +
>   include/linux/exchange.h               |   27 +
>   include/linux/highmem.h                |    3 +
>   include/linux/ksm.h                    |    4 +
>   include/linux/memcontrol.h             |   67 ++
>   include/linux/migrate.h                |   12 +-
>   include/linux/migrate_mode.h           |    8 +
>   include/linux/mm_inline.h              |   21 +
>   include/linux/sched/coredump.h         |    1 +
>   include/linux/sched/sysctl.h           |    3 +
>   include/linux/syscalls.h               |   10 +
>   include/uapi/linux/mempolicy.h         |    9 +-
>   kernel/sysctl.c                        |   47 +
>   mm/Makefile                            |    5 +
>   mm/balloon_compaction.c                |    2 +-
>   mm/compaction.c                        |   22 +-
>   mm/copy_page.c                         |  708 +++++++++++++++
>   mm/exchange.c                          | 1560 ++++++++++++++++++++++++++++++++
>   mm/exchange_page.c                     |  228 +++++
>   mm/internal.h                          |  113 +++
>   mm/ksm.c                               |   35 +
>   mm/memcontrol.c                        |   80 ++
>   mm/memory_manage.c                     |  649 +++++++++++++
>   mm/mempolicy.c                         |   38 +-
>   mm/migrate.c                           |  621 ++++++++++++-
>   mm/vmscan.c                            |  115 +--
>   mm/zsmalloc.c                          |    2 +-
>   33 files changed, 4261 insertions(+), 162 deletions(-)
>   create mode 100644 include/linux/exchange.h
>   create mode 100644 mm/copy_page.c
>   create mode 100644 mm/exchange.c
>   create mode 100644 mm/exchange_page.c
>   create mode 100644 mm/memory_manage.c
>
> --
> 2.7.4

