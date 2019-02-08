Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 479F9C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D761820823
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 11:45:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D761820823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746BD8E008E; Fri,  8 Feb 2019 06:45:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F7868E008A; Fri,  8 Feb 2019 06:45:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6028E008E; Fri,  8 Feb 2019 06:45:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31B1B8E008A
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 06:45:59 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id i4so3244080qtq.5
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 03:45:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=/sPNyBEkC6KaqUZCXG79A154GznWwCvFfxwiXDILsKQ=;
        b=XThO2PYL7iR9ZAwI4L45PxAaLFD9YQKkGp9oFlGmX0jAVDcc6YfA5KmPcHK5YGvMdA
         +f8bhuvLBtTraMosgY2NAtxYS1JvybyZeJ2OhK4kcH0KxjLW1przRr6mDJI7NNuQZTm4
         y7WSPCuW5v/dz1YZkQXnT3zKRteuccIRCk3kuHBZijtQzNeLx1f13CuAjjSE64pWfdNE
         lXlGfQ+B01HdEtVKd4yjw8dPE2hxkElXyEBhbShSBJ57Imrors6Z05dQHVF5u0NrbMOY
         TT0HMYCRJ3rKsrn4CUgQKxUTuC0ZoUSmoxC64k5dBaHsZLHaIl/pBVlLKc99MfV4fNaW
         4MXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubkvtJ2lOY1qSNoCLYc/vZWK927Y0rUOHq4ND7mZrStxarRkuWc
	H0dVj9QjJ6/fknyJyfCyyBFcoxnoztgDJTQPBD7g+AiW3nXKymetC+rpx7yM8hRpKo6FNB3rbZQ
	eOCYTrFeTV1eip28hp3c1Gd2p0t2cIm+bV8K6kB4Z+i+5AYgT/eyrdUaegPR7vq0QWw==
X-Received: by 2002:aed:306c:: with SMTP id 99mr15487342qte.61.1549626358875;
        Fri, 08 Feb 2019 03:45:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYrx3vyCNeSQIg/ef2oZoecvtwWWX/db5y6j2GRsq6jACxlfVWOoyJge9H13QGBE9wX5hGy
X-Received: by 2002:aed:306c:: with SMTP id 99mr15487306qte.61.1549626358061;
        Fri, 08 Feb 2019 03:45:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549626358; cv=none;
        d=google.com; s=arc-20160816;
        b=XHuuMYZsnSMZB06QVxD6C5LWE3oP5FDAbf+KjWPTmh/2s2KOZwEYrU0wlU2+rUQb+R
         jB1cWBSiN8o0JYxN+r9opoFNuRCeG4E0gqd6fNALACaeQQ5hZEhx8jMefurEKXJCLtIr
         shNqhxW2BOfFx+ajTJAghHMHi4+yC5aJYQASY+BR4aA8H+Xih7nWcD9NxCXDVzXkjTWD
         NSjhSrtnABqzrLPuO78bhV9zHyODv+y32YlqdLpYql00LzxWUcPvrQUcV4NJq/M2qq2O
         xBlrfHmceq5aseFKUHd4o3BICqElIFuZgCbWDvfq8hAmXYoComfBE8pMAiKaloj9mkD5
         WhmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=/sPNyBEkC6KaqUZCXG79A154GznWwCvFfxwiXDILsKQ=;
        b=jl8/6u+lGQ7Z38CRbqAZsqR3iMRVBcsRblExNSTpB581lLd3uZXwUvZo8Iswi8fbBt
         7bWq1/3siPFotMS9Pnerfwjb96iSLvG837pBHlbFv+XNb9rLWTvoKDcRQRexGJgt/C+U
         /xapetLS9kPZb8O7ipFENXmifEceucncSsYsyzwWlaN43Aw3hh8adTnYI/G1773uUIzL
         azM1upLOrH7Yscz63UJqU0U5DSkBGkDu1lXD4ZzZDsx2f0qkcp2+dr5VakWGI6AhUPu6
         zwzp8iZ08G9MV3HgeIdXxfY0tz612ZYLA6m/TYbXOgcfpmbQWE6uYFO5kQ9oFRpcHEtq
         /EDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j25si1227821qtn.303.2019.02.08.03.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 03:45:58 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x18BhwsK082781
	for <linux-mm@kvack.org>; Fri, 8 Feb 2019 06:45:57 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qh854b1rr-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Feb 2019 06:45:57 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 8 Feb 2019 11:45:55 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 8 Feb 2019 11:45:53 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x18BjqlN9109728
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 8 Feb 2019 11:45:52 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 973F9A4040;
	Fri,  8 Feb 2019 11:45:52 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 05412A404D;
	Fri,  8 Feb 2019 11:45:51 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.183])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  8 Feb 2019 11:45:50 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 08 Feb 2019 13:45:50 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-mm@kvack.org,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] memblock: update comments and kernel-doc
Date: Fri,  8 Feb 2019 13:45:47 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19020811-0028-0000-0000-000003462BE3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020811-0029-0000-0000-00002404400E
Message-Id: <1549626347-25461-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902080086
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

* Remove comments mentioning bootmem
* Extend "DOC: memblock overview"
* Add kernel-doc comments for several more functions

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---

The patch is against the current -mm tree which seems the best route for it
as well :)

 mm/memblock.c | 60 ++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 43 insertions(+), 17 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index f87d3ae..900c95b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -69,8 +69,19 @@
  * :c:func:`memblock_set_node`. The :c:func:`memblock_add_node`
  * performs such an assignment directly.
  *
- * Once memblock is setup the memory can be allocated using either
- * memblock or bootmem APIs.
+ * Once memblock is setup the memory can be allocated using one of the
+ * API variants:
+ *
+ * * :c:func:`memblock_phys_alloc*` - these functions return the
+ *   **physical** address of the allocated memory
+ * * :c:func:`memblock_alloc*` - these functions return the **virtual**
+ *   address of the allocated memory.
+ *
+ * Note, that both API variants use implict assumptions about allowed
+ * memory ranges and the fallback methods. Consult the documentation
+ * of :c:func:`memblock_alloc_internal` and
+ * :c:func:`memblock_alloc_range_nid` functions for more elaboarte
+ * description.
  *
  * As the system boot progresses, the architecture specific
  * :c:func:`mem_init` function frees all the memory to the buddy page
@@ -428,17 +439,7 @@ static int __init_memblock memblock_double_array(struct memblock_type *type,
 	else
 		in_slab = &memblock_reserved_in_slab;
 
-	/* Try to find some space for it.
-	 *
-	 * WARNING: We assume that either slab_is_available() and we use it or
-	 * we use MEMBLOCK for allocations. That means that this is unsafe to
-	 * use when bootmem is currently active (unless bootmem itself is
-	 * implemented on top of MEMBLOCK which isn't the case yet)
-	 *
-	 * This should however not be an issue for now, as we currently only
-	 * call into MEMBLOCK while it's still active, or much later when slab
-	 * is active for memory hotplug operations
-	 */
+	/* Try to find some space for it */
 	if (use_slab) {
 		new_array = kmalloc(new_size, GFP_KERNEL);
 		addr = new_array ? __pa(new_array) : 0;
@@ -982,7 +983,7 @@ static bool should_skip_region(struct memblock_region *m, int nid, int flags)
 }
 
 /**
- * __next__mem_range - next function for for_each_free_mem_range() etc.
+ * __next_mem_range - next function for for_each_free_mem_range() etc.
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
  * @flags: pick from blocks based on memory attributes
@@ -1392,6 +1393,18 @@ static phys_addr_t __init memblock_alloc_range_nid(phys_addr_t size,
 	return found;
 }
 
+/**
+ * memblock_phys_alloc_range - allocate a memory block inside specified range
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @start: the lower bound of the memory region to allocate (physical address)
+ * @end: the upper bound of the memory region to allocate (physical address)
+ *
+ * Allocate @size bytes in the between @start and @end.
+ *
+ * Return: physical address of the allocated memory block on success,
+ * %0 on failure.
+ */
 phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
 					     phys_addr_t align,
 					     phys_addr_t start,
@@ -1400,6 +1413,19 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
 	return memblock_alloc_range_nid(size, align, start, end, NUMA_NO_NODE);
 }
 
+/**
+ * memblock_phys_alloc_range - allocate a memory block from specified MUMA node
+ * @size: size of memory block to be allocated in bytes
+ * @align: alignment of the region and block's size
+ * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
+ *
+ * Allocates memory block from the specified NUMA node. If the node
+ * has no available memory, attempts to allocated from any node in the
+ * system.
+ *
+ * Return: physical address of the allocated memory block on success,
+ * %0 on failure.
+ */
 phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
 	return memblock_alloc_range_nid(size, align, 0,
@@ -1526,13 +1552,13 @@ void * __init memblock_alloc_try_nid(
 }
 
 /**
- * __memblock_free_late - free bootmem block pages directly to buddy allocator
+ * __memblock_free_late - free pages directly to buddy allocator
  * @base: phys starting address of the  boot memory block
  * @size: size of the boot memory block in bytes
  *
- * This is only useful when the bootmem allocator has already been torn
+ * This is only useful when the memblock allocator has already been torn
  * down, but we are still initializing the system.  Pages are released directly
- * to the buddy allocator, no bootmem metadata is updated because it is gone.
+ * to the buddy allocator.
  */
 void __init __memblock_free_late(phys_addr_t base, phys_addr_t size)
 {
-- 
2.7.4

