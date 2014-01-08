Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id C744C6B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 08:42:22 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so691985eek.38
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 05:42:22 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id r9si93294608eeo.212.2014.01.08.05.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jan 2014 05:42:21 -0800 (PST)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Wed, 8 Jan 2014 13:42:19 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 5E9F817D805F
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 13:42:26 +0000 (GMT)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s08Dg4ae59375770
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 13:42:05 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s08DgETx009943
	for <linux-mm@kvack.org>; Wed, 8 Jan 2014 06:42:16 -0700
Date: Wed, 8 Jan 2014 14:42:13 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem
Message-ID: <20140108144213.4c1995b2@lilie>
In-Reply-To: <52CCCF24.4080300@huawei.com>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389107774-54978-3-git-send-email-phacht@linux.vnet.ibm.com>
	<52CCCF24.4080300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, tj@kernel.org, toshi.kani@hp.com

Am Wed, 8 Jan 2014 12:08:04 +0800
schrieb Jianguo Wu <wujianguo@huawei.com>:

> For some archs, like arm64, would use memblock.memory after system
> booting, so we can not simply released to the buddy allocator, maybe
> need !defined(CONFIG_ARCH_DISCARD_MEMBLOCK).

Oh, I see. I have added some ifdefs to prevent memblock.memory from
being freed when CONFIG_ARCH_DISCARD_MEMBLOCK is not set.

Here is a replacement for the patch.

Kind regards

Philipp

=46rom aca95bcb9d79388b68bf18e7bae4353259b6758f Mon Sep 17 00:00:00 2001
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Date: Thu, 19 Dec 2013 15:53:46 +0100
Subject: [PATCH 2/2] mm: free memblock.memory in free_all_bootmem

When calling free_all_bootmem() the free areas under memblock's
control are released to the buddy allocator. Additionally the
reserved list is freed if it was reallocated by memblock.
The same should apply for the memory list.

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 include/linux/memblock.h |  1 +
 mm/memblock.c            | 16 ++++++++++++++++
 mm/nobootmem.c           | 10 +++++++++-
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 77c60e5..d174922 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -52,6 +52,7 @@ phys_addr_t memblock_find_in_range_node(phys_addr_t start=
, phys_addr_t end,
 phys_addr_t memblock_find_in_range(phys_addr_t start, phys_addr_t end,
 				   phys_addr_t size, phys_addr_t align);
 phys_addr_t get_allocated_memblock_reserved_regions_info(phys_addr_t *addr=
);
+phys_addr_t get_allocated_memblock_memory_regions_info(phys_addr_t *addr);
 void memblock_allow_resize(void);
 int memblock_add_node(phys_addr_t base, phys_addr_t size, int nid);
 int memblock_add(phys_addr_t base, phys_addr_t size);
diff --git a/mm/memblock.c b/mm/memblock.c
index 53e477b..a78b2e9 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -271,6 +271,22 @@ phys_addr_t __init_memblock get_allocated_memblock_res=
erved_regions_info(
 			  memblock.reserved.max);
 }
=20
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
+phys_addr_t __init_memblock get_allocated_memblock_memory_regions_info(
+					phys_addr_t *addr)
+{
+	if (memblock.memory.regions =3D=3D memblock_memory_init_regions)
+		return 0;
+
+	*addr =3D __pa(memblock.memory.regions);
+
+	return PAGE_ALIGN(sizeof(struct memblock_region) *
+			  memblock.memory.max);
+}
+
+#endif
+
 /**
  * memblock_double_array - double the size of the memblock regions array
  * @type: memblock type of the regions array being doubled
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 3a7e14d..63ff3f6 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -122,11 +122,19 @@ static unsigned long __init free_low_memory_core_earl=
y(void)
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count +=3D __free_memory_core(start, end);
=20
-	/* free range that is used for reserved array if we allocate it */
+	/* Free memblock.reserved array if it was allocated */
 	size =3D get_allocated_memblock_reserved_regions_info(&start);
 	if (size)
 		count +=3D __free_memory_core(start, start + size);
=20
+#ifdef CONFIG_ARCH_DISCARD_MEMBLOCK
+
+	/* Free memblock.memory array if it was allocated */
+	size =3D get_allocated_memblock_memory_regions_info(&start);
+	if (size)
+		count +=3D __free_memory_core(start, start + size);
+#endif
+
 	return count;
 }
=20
--=20
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
