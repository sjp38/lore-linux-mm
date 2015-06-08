Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id BAF3B6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:08:59 -0400 (EDT)
Received: by lbcue7 with SMTP id ue7so81571072lbc.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:08:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev4si5330614wjc.204.2015.06.08.07.08.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 07:08:58 -0700 (PDT)
Date: Mon, 8 Jun 2015 15:08:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] sched, numa: Do not hint for NUMA balancing on VM_MIXEDMAP
 mappings
Message-ID: <20150608140854.GP26425@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jovi Zhangwei <jovi@cloudflare.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Jovi Zhangwei reported the following problem

  Below kernel vm bug can be triggered by tcpdump which mmaped a lot of pages
  with GFP_COMP flag.

  [Mon May 25 05:29:33 2015] page:ffffea0015414000 count:66 mapcount:1 mapping:          (null) index:0x0
  [Mon May 25 05:29:33 2015] flags: 0x20047580004000(head)
  [Mon May 25 05:29:33 2015] page dumped because: VM_BUG_ON_PAGE(compound_order(page) && !PageTransHuge(page))
  [Mon May 25 05:29:33 2015] ------------[ cut here ]------------
  [Mon May 25 05:29:33 2015] kernel BUG at mm/migrate.c:1661!
  [Mon May 25 05:29:33 2015] invalid opcode: 0000 [#1] SMP

In this case it was triggered by running tcpdump but it's not necessary
reproducible on all systems.

  sudo tcpdump -i bond0.100 'tcp port 4242' -c 100000000000 -w 4242.pcap

Compound pages cannot be migrated and it was not expected that such pages
be marked for NUMA balancing. This did not take into account that drivers
such as net/packet/af_packet.c may insert compound pages into userspace
with vm_insert_page. This patch tells the NUMA balancing protection scanner
to skip all VM_MIXEDMAP mappings which avoids the possibility that compound
pages are marked for migration.

Cc: stable@vger.kernel.org
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reported-by: Jovi Zhangwei <jovi@cloudflare.com>
---
 kernel/sched/fair.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index ffeaa4105e48..c2980e8733bc 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2181,7 +2181,7 @@ void task_numa_work(struct callback_head *work)
 	}
 	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
-			is_vm_hugetlb_page(vma)) {
+			is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_MIXEDMAP)) {
 			continue;
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
