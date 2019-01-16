Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 029238E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:46:01 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w28so5156679qkj.22
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:46:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w11si4841616qvf.141.2019.01.16.05.45.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:46:00 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0GDeZax042599
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:45:59 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q23ekemj2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:45:59 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 16 Jan 2019 13:45:56 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 16/21] mm/percpu: add checks for the return value of memblock_alloc*()
Date: Wed, 16 Jan 2019 15:44:16 +0200
In-Reply-To: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
References: <1547646261-32535-1-git-send-email-rppt@linux.ibm.com>
Message-Id: <1547646261-32535-17-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport <rppt@linux.ibm.com>

Add panic() calls if memblock_alloc() returns NULL.

The panic() format duplicates the one used by memblock itself and in order
to avoid explosion with long parameters list replace open coded allocation
size calculations with a local variable.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/percpu.c | 73 +++++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 56 insertions(+), 17 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index db86282..5998b03 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1086,6 +1086,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	struct pcpu_chunk *chunk;
 	unsigned long aligned_addr, lcm_align;
 	int start_offset, offset_bits, region_size, region_bits;
+	size_t alloc_size;
 
 	/* region calculations */
 	aligned_addr = tmp_addr & PAGE_MASK;
@@ -1101,9 +1102,12 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	region_size = ALIGN(start_offset + map_size, lcm_align);
 
 	/* allocate chunk */
-	chunk = memblock_alloc(sizeof(struct pcpu_chunk) +
-			       BITS_TO_LONGS(region_size >> PAGE_SHIFT),
-			       SMP_CACHE_BYTES);
+	alloc_size = sizeof(struct pcpu_chunk) +
+		BITS_TO_LONGS(region_size >> PAGE_SHIFT);
+	chunk = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
 
 	INIT_LIST_HEAD(&chunk->list);
 
@@ -1114,12 +1118,25 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
 	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->alloc_map = memblock_alloc(BITS_TO_LONGS(region_bits) * sizeof(chunk->alloc_map[0]),
-					  SMP_CACHE_BYTES);
-	chunk->bound_map = memblock_alloc(BITS_TO_LONGS(region_bits + 1) * sizeof(chunk->bound_map[0]),
-					  SMP_CACHE_BYTES);
-	chunk->md_blocks = memblock_alloc(pcpu_chunk_nr_blocks(chunk) * sizeof(chunk->md_blocks[0]),
-					  SMP_CACHE_BYTES);
+	alloc_size = BITS_TO_LONGS(region_bits) * sizeof(chunk->alloc_map[0]);
+	chunk->alloc_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->alloc_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size =
+		BITS_TO_LONGS(region_bits + 1) * sizeof(chunk->bound_map[0]);
+	chunk->bound_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->bound_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = pcpu_chunk_nr_blocks(chunk) * sizeof(chunk->md_blocks[0]);
+	chunk->md_blocks = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!chunk->md_blocks)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
 	pcpu_init_md_blocks(chunk);
 
 	/* manage populated page bitmap */
@@ -2044,6 +2061,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	int group, unit, i;
 	int map_size;
 	unsigned long tmp_addr;
+	size_t alloc_size;
 
 #define PCPU_SETUP_BUG_ON(cond)	do {					\
 	if (unlikely(cond)) {						\
@@ -2075,14 +2093,29 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-	group_offsets = memblock_alloc(ai->nr_groups * sizeof(group_offsets[0]),
-				       SMP_CACHE_BYTES);
-	group_sizes = memblock_alloc(ai->nr_groups * sizeof(group_sizes[0]),
-				     SMP_CACHE_BYTES);
-	unit_map = memblock_alloc(nr_cpu_ids * sizeof(unit_map[0]),
-				  SMP_CACHE_BYTES);
-	unit_off = memblock_alloc(nr_cpu_ids * sizeof(unit_off[0]),
-				  SMP_CACHE_BYTES);
+	alloc_size = ai->nr_groups * sizeof(group_offsets[0]);
+	group_offsets = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!group_offsets)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = ai->nr_groups * sizeof(group_sizes[0]);
+	group_sizes = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!group_sizes)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = nr_cpu_ids * sizeof(unit_map[0]);
+	unit_map = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!unit_map)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
+
+	alloc_size = nr_cpu_ids * sizeof(unit_off[0]);
+	unit_off = memblock_alloc(alloc_size, SMP_CACHE_BYTES);
+	if (!unit_off)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      alloc_size);
 
 	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		unit_map[cpu] = UINT_MAX;
@@ -2148,6 +2181,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
 	pcpu_slot = memblock_alloc(pcpu_nr_slots * sizeof(pcpu_slot[0]),
 				   SMP_CACHE_BYTES);
+	if (!pcpu_slot)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      pcpu_nr_slots * sizeof(pcpu_slot[0]));
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
 
@@ -2602,6 +2638,9 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	pages_size = PFN_ALIGN(unit_pages * num_possible_cpus() *
 			       sizeof(pages[0]));
 	pages = memblock_alloc(pages_size, SMP_CACHE_BYTES);
+	if (!pages)
+		panic("%s: Failed to allocate %zu bytes\n", __func__,
+		      pages_size);
 
 	/* allocate pages */
 	j = 0;
-- 
2.7.4
