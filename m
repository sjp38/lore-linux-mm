Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35089C32756
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFDEB206DF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:58:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFDEB206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C16696B0007; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1616B0008; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A40716B000A; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC676B0008
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:58:12 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j9so4632848pgk.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=2vVjmTu1u/7g3USwCeDyIfIi9R6avyNjneeF6t213Kk=;
        b=rkvIL6LcEH6A8kcNXZKqQVH8Ah4b6VqO6iZO+E4ztoBohZ3h45rV7MKuBW70qKuLF7
         8n8cMDQ7ahBk2stFTP32o6zMMEBYXjYQbGh5EbZRGe0//s/vNl96BP0yrKPCtStmRC1L
         KjJvUKhIrle9wi7tqHmwU/RVUbOPeUAnmHCtaMOkj3U1UgWwbXo76lrCw/Q3W5MxCE6K
         ZkJlHcKFlcnn4eqFnjSOfdihyqIloeBrZiow6hHT2DJsYziygorsOGi6ruWce1yceDo4
         RC7ud8tjW8clLI5b9JvGYuL9SIjDAYJ484e6YJZ0TP6XW6Et3eaKV/NsWW7PcKaj1H6h
         jUDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXiJyxGNModCx8pLJMCI5wy4hOsRM04ViiTuZRlSfcYuTAC24XU
	zEyWhWssGNfBhOIuxVNGmlL6Md8DLmoJExzMhPyiv7qbM/9cBrcWAO++T0tX1thiqXHG5pK5u5A
	6F8dGBiz77UhUNRmYXKGe/Rvn8wBQ/GVTHBfRbxyo+MsBdPiFNp3ttv68NRO0/xodng==
X-Received: by 2002:a63:3009:: with SMTP id w9mr15602329pgw.260.1565308691848;
        Thu, 08 Aug 2019 16:58:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyODSHClpINCawdam1x66TOsgI+2CeXzdz7LkaGCX0vbt5JXv/bRPu8IUfU/CZCULjYijGG
X-Received: by 2002:a63:3009:: with SMTP id w9mr15602232pgw.260.1565308690172;
        Thu, 08 Aug 2019 16:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565308690; cv=none;
        d=google.com; s=arc-20160816;
        b=gzYz/rliVu5IeKujZrgCFYJt9xIfjXAUTiOLpy+tX/0jvvhL0Tf/UN4VojkrTdgwhg
         IBLXz6rlu9CkTmZ+Q9qvARoLMrXh2JpjmMCba3A2XStlbmH50yRir5cfKcQENlNJKNm5
         GXTxuAJwAzqjAIuhBa5VlAUOOXizLqHDZJfWEWauPQbMRcNB3mXHvXj28eI8++pigGQo
         EzUHmiooARCR02ARkXEyK6czNagZ0Fh4gnusJFCv8IBTF153Y+laWjyEsemW4UZr3xG4
         cqAo59GnchT5fSCyrXXK8ooRwXGDz7W9/Hw4XSEUKJMG2AgjcfvHP2PNr7RKlqKhmAa1
         XXIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=2vVjmTu1u/7g3USwCeDyIfIi9R6avyNjneeF6t213Kk=;
        b=nrRVeyQXaH+oOPx66EZXcoJTZS0L++4mH+h1G+Mv9wOnOJguwaiQz+Ti1kueZAw13i
         wlYNgAh5zD0AGI8CB09Lv/MyzufUC2CH2pL6/Sr8j+3uNyqEsGnlhOhSrOfw7qqOHa/A
         fHrT7kMlHlw1LbUZuvMHHkGyjTiHTMQTqyp/lyAgrYAEmlbKMDB6uOwRWz0lT35toAWy
         dDZ1Hlj3eb9o2bKO5UaQyGYpLpizAK6Q/YSJPDC1tfqlclbvBkFVM+ZX19W4wVYvzKzC
         7q5PSxMs+QOT/Xh0lb9FfgrBjgJhtsXg3BFaMsbSJzWXvOArHF/IJY2DjFKlThNRdTiz
         /siA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id x8si30373276plr.252.2019.08.08.16.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TYzn9kn_1565308665;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TYzn9kn_1565308665)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 09 Aug 2019 07:58:07 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	hannes@cmpxchg.org,
	vbabka@suse.cz,
	rientjes@google.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RESEND PATCH 1/2 -mm] mm: account lazy free pages separately
Date: Fri,  9 Aug 2019 07:57:44 +0800
Message-Id: <1565308665-24747-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When doing partial unmap to THP, the pages in the affected range would
be considered to be reclaimable when memory pressure comes in.  And,
such pages would be put on deferred split queue and get minus from the
memory statistics (i.e. /proc/meminfo).

For example, when doing THP split test, /proc/meminfo would show:

Before put on lazy free list:
MemTotal:       45288336 kB
MemFree:        43281376 kB
MemAvailable:   43254048 kB
...
Active(anon):    1096296 kB
Inactive(anon):     8372 kB
...
AnonPages:       1096264 kB
...
AnonHugePages:   1056768 kB

After put on lazy free list:
MemTotal:       45288336 kB
MemFree:        43282612 kB
MemAvailable:   43255284 kB
...
Active(anon):    1094228 kB
Inactive(anon):     8372 kB
...
AnonPages:         49668 kB
...
AnonHugePages:     10240 kB

The THPs confusingly look disappeared although they are still on LRU if
you are not familair the tricks done by kernel.

Accounted the lazy free pages to NR_LAZYFREE, and show them in meminfo
and other places.  With the change the /proc/meminfo would look like:
Before put on lazy free list:
AnonHugePages:   1056768 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
LazyFreePages:         0 kB

After put on lazy free list:
AnonHugePages:     10240 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
LazyFreePages:   1046528 kB

And, this is also the preparation for the following patch to account
lazy free pages to available memory.

Here the lazyfree doesn't count MADV_FREE pages since they are not
actually unmapped until they get reclaimed.  And, they are put on
inactive file LRU, so they have been accounted for available memory.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
I'm not quite sure whether LazyFreePages is a good name or not since "Lazyfree"
is typically referred to MADV_FREE pages.  I could use a more spceific name,
i.e. "DeferredSplitTHP" since it doesn't account MADV_FREE as explained in the
commit log.  But, a more general name would be good for including other type
pages in the future.

 Documentation/filesystems/proc.txt | 12 ++++++++----
 drivers/base/node.c                |  3 +++
 fs/proc/meminfo.c                  |  3 +++
 include/linux/mmzone.h             |  1 +
 mm/huge_memory.c                   |  6 ++++++
 mm/page_alloc.c                    |  2 ++
 mm/vmstat.c                        |  1 +
 7 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 99ca040..8dd09d1 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -917,6 +917,7 @@ HardwareCorrupted:   0 kB
 AnonHugePages:   49152 kB
 ShmemHugePages:      0 kB
 ShmemPmdMapped:      0 kB
+LazyFreePages:       0 kB
 
 
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
@@ -924,12 +925,13 @@ ShmemPmdMapped:      0 kB
      MemFree: The sum of LowFree+HighFree
 MemAvailable: An estimate of how much memory is available for starting new
               applications, without swapping. Calculated from MemFree,
-              SReclaimable, the size of the file LRU lists, and the low
-              watermarks in each zone.
+              SReclaimable, the size of the file LRU lists, LazyFree pages
+              and the low watermarks in each zone.
               The estimate takes into account that the system needs some
               page cache to function well, and that not all reclaimable
-              slab will be reclaimable, due to items being in use. The
-              impact of those factors will vary from system to system.
+              slab and LazyFree pages will be reclaimable, due to items
+              being in use. The impact of those factors will vary from
+              system to system.
      Buffers: Relatively temporary storage for raw disk blocks
               shouldn't get tremendously large (20MB or so)
       Cached: in-memory cache for files read from the disk (the
@@ -967,6 +969,8 @@ AnonHugePages: Non-file backed huge pages mapped into userspace page tables
 ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
               with huge pages
 ShmemPmdMapped: Shared memory mapped into userspace with huge pages
+LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
+               split THP).
 KReclaimable: Kernel allocations that the kernel will attempt to reclaim
               under memory pressure. Includes SReclaimable (below), and other
               direct allocations with a shrinker.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 75b7e6f..9326b4e 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -428,6 +428,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
+		       "Node %d LazyFreePages:	%8lu kB\n"
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
@@ -454,6 +455,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR)
 #endif
+		       ,
+		       nid, K(node_page_state(pgdat, NR_LAZYFREE))
 		       );
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 465ea01..d66491a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -138,6 +138,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
+	show_val_kb(m, "LazyFreePages:  ",
+		    global_node_page_state(NR_LAZYFREE));
+
 #ifdef CONFIG_CMA
 	show_val_kb(m, "CmaTotal:       ", totalcma_pages);
 	show_val_kb(m, "CmaFree:        ",
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d8ec773..4d00b1c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -235,6 +235,7 @@ enum node_stat_item {
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
 	NR_ANON_THPS,
+	NR_LAZYFREE,		/* Lazyfree pages, i.e. deferred split THP */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c9a596e..a20152f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2766,6 +2766,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		if (!list_empty(page_deferred_list(head))) {
 			ds_queue->split_queue_len--;
 			list_del(page_deferred_list(head));
+			__mod_lruvec_page_state(head, NR_LAZYFREE,
+						-HPAGE_PMD_NR);
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
@@ -2815,6 +2817,7 @@ void free_transhuge_page(struct page *page)
 	if (!list_empty(page_deferred_list(page))) {
 		ds_queue->split_queue_len--;
 		list_del(page_deferred_list(page));
+		__mod_lruvec_page_state(page, NR_LAZYFREE, -HPAGE_PMD_NR);
 	}
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 	free_compound_page(page);
@@ -2846,6 +2849,7 @@ void deferred_split_huge_page(struct page *page)
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
+		__mod_lruvec_page_state(page, NR_LAZYFREE, HPAGE_PMD_NR);
 		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
 		ds_queue->split_queue_len++;
 #ifdef CONFIG_MEMCG
@@ -2906,6 +2910,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 			/* We lost race with put_compound_page() */
 			list_del_init(page_deferred_list(page));
 			ds_queue->split_queue_len--;
+			__mod_lruvec_page_state(page, NR_LAZYFREE,
+						-HPAGE_PMD_NR);
 		}
 		if (!--sc->nr_to_scan)
 			break;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1d1c5d3..1f3eba8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5279,6 +5279,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" shmem_pmdmapped: %lukB"
 			" anon_thp: %lukB"
 #endif
+			" lazyfree:%lukB"
 			" writeback_tmp:%lukB"
 			" unstable:%lukB"
 			" all_unreclaimable? %s"
@@ -5301,6 +5302,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 					* HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
 #endif
+			K(node_page_state(pgdat, NR_LAZYFREE)),
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fd7e16c..4f6eed5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1159,6 +1159,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
 	"nr_anon_transparent_hugepages",
+	"nr_lazyfree",
 	"nr_unstable",
 	"nr_vmscan_write",
 	"nr_vmscan_immediate_reclaim",
-- 
1.8.3.1

