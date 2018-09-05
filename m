Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED176B740D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:37 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w12-v6so9003877oie.12
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u203-v6si1551592oif.354.2018.09.05.09.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:36 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FuYYE022358
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:35 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2magp9day6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:34 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:31 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 14/29] memblock: add align parameter to memblock_alloc_node()
Date: Wed,  5 Sep 2018 18:59:29 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-15-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

With the align parameter memblock_alloc_node() can be used as drop in
replacement for alloc_bootmem_pages_node().

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 include/linux/bootmem.h | 4 ++--
 mm/sparse.c             | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 7d91f0f..3896af2 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -157,9 +157,9 @@ static inline void * __init memblock_alloc_from_nopanic(
 }
 
 static inline void * __init memblock_alloc_node(
-						phys_addr_t size, int nid)
+		phys_addr_t size, phys_addr_t align, int nid)
 {
-	return memblock_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
+	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
 					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 04e97af..509828f 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -68,7 +68,7 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
 	if (slab_is_available())
 		section = kzalloc_node(array_size, GFP_KERNEL, nid);
 	else
-		section = memblock_alloc_node(array_size, nid);
+		section = memblock_alloc_node(array_size, 0, nid);
 
 	return section;
 }
-- 
2.7.4
