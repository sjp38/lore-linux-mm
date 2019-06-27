Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABC27C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 17:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62EE7205F4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 17:12:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62EE7205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A7656B0006; Thu, 27 Jun 2019 13:12:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F24C18E0003; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC33E8E0002; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A64BD6B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 13:12:16 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so1782989plr.19
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:12:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=h5h261F8UaW2xl19ae9LBYH0kBQZlMzdN6RmczOt2QI=;
        b=qei3wQMwuzGNa/FgvX3Fr4a8r23TbP7wabc7LAA9k9VGB0t/KBOkivP5BAh5vR2cKH
         n+QsxuaiLDC9goqYH8pOoN0vAh5Y+MlqwWC62vpLMVcIHjbhUtsd+x5hk3hbtU84BrVm
         4cIbFB/vX33gMroXOzXvXbanYrpO4c0mmlln+i5punpkOZ78nufWNf8IQAGoLJOTj3VM
         e/Txt1iHewR+4Vr1Lb1OMuF31t3tpU22kXxaONAtYzfxRe0lhal47FcNwYSyLupKeQWK
         YsBD4GfjWoudkiRkSuwrnvYZsfKOPRtH5HARrDPs1nrzrzIbtwS+UhO70Ac7GeQDTDvI
         jkww==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVwotpFFGcwOu/3HliRykL5Sa/Bt5vkFmC/tNX+yRjp1teklwSc
	F3wulqukh+6fBEhVqzTbJYOFiMvA61y83l2hQ5UUewMkc4qdLZ+g5QGZhSeKir2dAZ9Cf7laQRc
	hl0RXj8jZkRiQSzmE/lYhno1hwCMIYE7JczWp5E5/z9q2lCaQQGhY6nG15EaOTCNq9w==
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr7151124pjo.97.1561655536305;
        Thu, 27 Jun 2019 10:12:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZMy0RqkJ9OhlXVdpR3r53CaeskCLss8ZnWS4kEm0zv/fGC/zbcAEdVdy6zzF9/TE/Bg3r
X-Received: by 2002:a17:90a:8c92:: with SMTP id b18mr7150987pjo.97.1561655534692;
        Thu, 27 Jun 2019 10:12:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561655534; cv=none;
        d=google.com; s=arc-20160816;
        b=yANW8ICNEEffBDrFLT3fke/Qr2PwV4ggAdHnhtzxoAVm88XpAVQpM/YJ0/wfNrgEn9
         KM8cE8V7H041FyDA2MI3rGWpxNCdKbVN1sjsRP/AXvqxOY0F8y6HnTTRXX9tHu2f1gLU
         A2qcSgMT+nstbbfnejMzYahPHSLK+1cGDYOTErkFKSam0O5j1oYYe+HCbeKPkqTzJSv9
         1N2HtP+JuCmDifs2XPWqAR8ncukia8N6azDEnjCFx/iSnzbBFzDftOiUEnMmIongm04Y
         D+3yl+kOA0MwdFpw9pQEu12pOWfV1d2gbkdWOvgNDhPrAfcc86/MacvGq2T5mWUSJA4I
         fnoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=h5h261F8UaW2xl19ae9LBYH0kBQZlMzdN6RmczOt2QI=;
        b=irYR8jES3wBKKkRSFEtgBtsvkNsHO1OtgZXRszlZzwWVLLr8Z/bAWPrcvvyd36W8Fi
         b+ZYLsikIZUwSqqRZAgP31dfjhYLvJ+4CTrW98eRS1/F62j+lhEsCGoLpRypD3gibIOg
         dTK3wypEsgHV8An4Pvu85/uIbUeBtAf8xjPFkMo69QV0tR8q+enDx7PnyIuqlIe77ciV
         BTPJH/QU9QWYv638ozLNStPH4K/ihnyMiaKfgNRBy+MTWK/VO3IXyRIBIXoYT8ndHAwI
         PNxRvH3ISkYhFKxyZ9e0mkhcPTEFh1k+dYyFuBFLIoYZy5AZPHIohFo7cDLg3UADodGS
         ToiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id m68si140706pfb.75.2019.06.27.10.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 10:12:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TVMmS7H_1561655524;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVMmS7H_1561655524)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 28 Jun 2019 01:12:12 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: rientjes@google.com,
	kirill.shutemov@linux.intel.com,
	mhocko@suse.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/2 -mm] mm: account lazy free pages separately
Date: Fri, 28 Jun 2019 01:12:03 +0800
Message-Id: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
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

And, I'm also not sure if it is a good idea to show this in memcg stat or not.

 Documentation/filesystems/proc.txt | 12 ++++++++----
 drivers/base/node.c                |  3 +++
 fs/proc/meminfo.c                  |  3 +++
 include/linux/mmzone.h             |  1 +
 mm/huge_memory.c                   |  8 ++++++++
 mm/page_alloc.c                    |  2 ++
 mm/vmstat.c                        |  1 +
 7 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 66cad5c..851ddfd 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -895,6 +895,7 @@ HardwareCorrupted:   0 kB
 AnonHugePages:   49152 kB
 ShmemHugePages:      0 kB
 ShmemPmdMapped:      0 kB
+LazyFreePages:       0 kB
 
 
     MemTotal: Total usable ram (i.e. physical ram minus a few reserved
@@ -902,12 +903,13 @@ ShmemPmdMapped:      0 kB
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
@@ -945,6 +947,8 @@ AnonHugePages: Non-file backed huge pages mapped into userspace page tables
 ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
               with huge pages
 ShmemPmdMapped: Shared memory mapped into userspace with huge pages
+LazyFreePages: Cleanly freeable pages under memory pressure (i.e. deferred
+               split THP).
 KReclaimable: Kernel allocations that the kernel will attempt to reclaim
               under memory pressure. Includes SReclaimable (below), and other
               direct allocations with a shrinker.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcb..ef701aa 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -427,6 +427,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
+		       "Node %d LazyFreePages:	%8lu kB\n"
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
@@ -453,6 +454,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR)
 #endif
+		       ,
+		       nid, K(node_page_state(pgdat, NR_LAZYFREE))
 		       );
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 568d90e..b02ebd0 100644
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
index 7799166..523ea86 100644
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
index 4f20273..78806c7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2757,6 +2757,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		if (!list_empty(page_deferred_list(head))) {
 			ds_queue->split_queue_len--;
 			list_del(page_deferred_list(head));
+			__mod_node_page_state(NODE_DATA(page_to_nid(head)),
+					NR_LAZYFREE, -HPAGE_PMD_NR);
 		}
 		if (mapping)
 			__dec_node_page_state(page, NR_SHMEM_THPS);
@@ -2806,6 +2808,8 @@ void free_transhuge_page(struct page *page)
 	if (!list_empty(page_deferred_list(page))) {
 		ds_queue->split_queue_len--;
 		list_del(page_deferred_list(page));
+		__mod_node_page_state(NODE_DATA(page_to_nid(page)),
+				NR_LAZYFREE, -HPAGE_PMD_NR);
 	}
 	spin_unlock_irqrestore(&ds_queue->split_queue_lock, flags);
 	free_compound_page(page);
@@ -2822,6 +2826,8 @@ void deferred_split_huge_page(struct page *page)
 	spin_lock_irqsave(&ds_queue->split_queue_lock, flags);
 	if (list_empty(page_deferred_list(page))) {
 		count_vm_event(THP_DEFERRED_SPLIT_PAGE);
+		__mod_node_page_state(NODE_DATA(page_to_nid(page)),
+				NR_LAZYFREE, HPAGE_PMD_NR);
 		list_add_tail(page_deferred_list(page), &ds_queue->split_queue);
 		ds_queue->split_queue_len++;
 		if (memcg)
@@ -2873,6 +2879,8 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
 			/* We lost race with put_compound_page() */
 			list_del_init(page_deferred_list(page));
 			ds_queue->split_queue_len--;
+			__mod_node_page_state(NODE_DATA(page_to_nid(page)),
+					NR_LAZYFREE, -HPAGE_PMD_NR);
 		}
 		if (!--sc->nr_to_scan)
 			break;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7f27f4e..cab50e8 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5210,6 +5210,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" shmem_pmdmapped: %lukB"
 			" anon_thp: %lukB"
 #endif
+			" lazyfree:%lukB"
 			" writeback_tmp:%lukB"
 			" unstable:%lukB"
 			" all_unreclaimable? %s"
@@ -5232,6 +5233,7 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 					* HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
 #endif
+			K(node_page_state(pgdat, NR_LAZYFREE)),
 			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
diff --git a/mm/vmstat.c b/mm/vmstat.c
index a7d4933..87703f2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1158,6 +1158,7 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
 	"nr_anon_transparent_hugepages",
+	"nr_lazyfree",
 	"nr_unstable",
 	"nr_vmscan_write",
 	"nr_vmscan_immediate_reclaim",
-- 
1.8.3.1

