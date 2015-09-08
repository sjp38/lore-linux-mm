Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5D51D6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:30:12 -0400 (EDT)
Received: by qgx61 with SMTP id 61so90294581qgx.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 11:30:12 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id a51si4792253qge.64.2015.09.08.11.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 11:30:11 -0700 (PDT)
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 8 Sep 2015 14:30:10 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B150138C804A
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 14:30:08 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t88IU8o648562192
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 18:30:08 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t88IU8S1009420
	for <linux-mm@kvack.org>; Tue, 8 Sep 2015 14:30:08 -0400
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH  0/2] Replace nr_node_ids for loop with for_each_node 
Date: Wed,  9 Sep 2015 00:01:45 +0530
Message-Id: <1441737107-23103-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org
Cc: nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, zhong@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, raghavendra.kt@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Many places in the kernel use 'for' loop with nr_node_ids. For the architectures
which supports sparse numa ids, this will result in some unnecessary allocations
for non existing nodes.
(for e.g., numa node numbers such as 0,1,16,17 is common in powerpc.)

So replace the for loop with for_each_node so that allocations happen only for
existing numa nodes.

Please note that, though there are many places where nr_node_ids is used,
current patchset uses for_each_node only for slowpath to avoid find_next_bit
traversal.

Raghavendra K T (2):
  mm: Replace nr_node_ids for loop with for_each_node in list lru
  powerpc:numa Do not allocate bootmem memory for non existing nodes

 arch/powerpc/mm/numa.c |  2 +-
 mm/list_lru.c          | 23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 9 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
