Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7E72D6B0255
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 22:08:06 -0400 (EDT)
Received: by oibi136 with SMTP id i136so87592596oib.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 19:08:06 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id b1si8126386oey.10.2015.09.14.19.08.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Sep 2015 19:08:05 -0700 (PDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 14 Sep 2015 20:08:05 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A04B119D8040
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 19:58:57 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8F27t6E39518214
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 19:08:03 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8F27U9p011648
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 20:07:30 -0600
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH V2  0/2] Replace nr_node_ids for loop with for_each_node 
Date: Tue, 15 Sep 2015 07:38:35 +0530
Message-Id: <1442282917-16893-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org
Cc: nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, raghavendra.kt@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Many places in the kernel use 'for' loop with nr_node_ids. For the architectures
which supports sparse numa ids, this will result in some unnecessary allocations
for non existing nodes.
(for e.g., numa node numbers such as 0,1,16,17 is common in powerpc.)

So replace the for loop with for_each_node so that allocations happen only for
existing numa nodes.

Please note that, though there are many places where nr_node_ids is used,
current patchset uses for_each_node only for slowpath to avoid find_next_bit
traversal.

Changes in V2:
  - Take memcg_aware check outside for_each loop (Vldimir)
  - Add comment that node 0 should always be present (Vladimir)

Raghavendra K T (2):
  mm: Replace nr_node_ids for loop with for_each_node in list lru
  powerpc:numa Do not allocate bootmem memory for non existing nodes

 arch/powerpc/mm/numa.c |  2 +-
 mm/list_lru.c          | 34 +++++++++++++++++++++++-----------
 2 files changed, 24 insertions(+), 12 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
