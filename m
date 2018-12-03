Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42FAA6B69E0
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 10:47:54 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so6791453ede.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 07:47:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a17-v6si883276ejs.24.2018.12.03.07.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 07:47:52 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB3FiFbI064919
	for <linux-mm@kvack.org>; Mon, 3 Dec 2018 10:47:51 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p56u7tatv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:47:50 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 3 Dec 2018 15:47:44 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 3/6] sh: prefer memblock APIs returning virtual address
Date: Mon,  3 Dec 2018 17:47:12 +0200
In-Reply-To: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
References: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1543852035-26634-4-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Rather than use the memblock_alloc_base that returns a physical address and
then convert this address to the virtual one, use appropriate memblock
function that returns a virtual address.

There is a small functional change in the allocation of then NODE_DATA().
Instead of panicing if the local allocation failed, the non-local
allocation attempt will be made.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/sh/mm/init.c | 18 +++++-------------
 arch/sh/mm/numa.c |  5 ++---
 2 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index c8c13c77..3576b5f 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -192,24 +192,16 @@ void __init page_table_range_init(unsigned long start, unsigned long end,
 void __init allocate_pgdat(unsigned int nid)
 {
 	unsigned long start_pfn, end_pfn;
-#ifdef CONFIG_NEED_MULTIPLE_NODES
-	unsigned long phys;
-#endif
 
 	get_pfn_range_for_nid(nid, &start_pfn, &end_pfn);
 
 #ifdef CONFIG_NEED_MULTIPLE_NODES
-	phys = __memblock_alloc_base(sizeof(struct pglist_data),
-				SMP_CACHE_BYTES, end_pfn << PAGE_SHIFT);
-	/* Retry with all of system memory */
-	if (!phys)
-		phys = __memblock_alloc_base(sizeof(struct pglist_data),
-					SMP_CACHE_BYTES, memblock_end_of_DRAM());
-	if (!phys)
+	NODE_DATA(nid) = memblock_alloc_try_nid_nopanic(
+				sizeof(struct pglist_data),
+				SMP_CACHE_BYTES, MEMBLOCK_LOW_LIMIT,
+				MEMBLOCK_ALLOC_ACCESSIBLE, nid);
+	if (!NODE_DATA(nid))
 		panic("Can't allocate pgdat for node %d\n", nid);
-
-	NODE_DATA(nid) = __va(phys);
-	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
 #endif
 
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
diff --git a/arch/sh/mm/numa.c b/arch/sh/mm/numa.c
index 830e8b3..c4bde61 100644
--- a/arch/sh/mm/numa.c
+++ b/arch/sh/mm/numa.c
@@ -41,9 +41,8 @@ void __init setup_bootmem_node(int nid, unsigned long start, unsigned long end)
 	__add_active_range(nid, start_pfn, end_pfn);
 
 	/* Node-local pgdat */
-	NODE_DATA(nid) = __va(memblock_alloc_base(sizeof(struct pglist_data),
-					     SMP_CACHE_BYTES, end));
-	memset(NODE_DATA(nid), 0, sizeof(struct pglist_data));
+	NODE_DATA(nid) = memblock_alloc_node(sizeof(struct pglist_data),
+					     SMP_CACHE_BYTES, nid);
 
 	NODE_DATA(nid)->node_start_pfn = start_pfn;
 	NODE_DATA(nid)->node_spanned_pages = end_pfn - start_pfn;
-- 
2.7.4
