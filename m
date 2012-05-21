Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 1E8736B00F5
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:30:29 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 May 2012 14:30:27 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id A7844C90058
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:30:22 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4LKUPRm127604
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:30:25 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4M21Hjq012509
	for <linux-mm@kvack.org>; Mon, 21 May 2012 22:01:18 -0400
Subject: [RFC][PATCH 2/2] sparsemem: fix boot when SECTIONS_PER_ROOT is not power-of-2
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 May 2012 13:30:24 -0700
References: <20120521203022.F7FCE507@kernel>
In-Reply-To: <20120521203022.F7FCE507@kernel>
Message-Id: <20120521203024.5526C347@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


I was getting some interesting oopses at boot after adding a
field to 'struct mem_section'.  I tracked it down to
__nr_to_section().  In my case, SECTIONS_PER_ROOT got set to
73, which leads to an interesting bitmask:

	#define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))
	...
	#define SECTION_ROOT_MASK      (SECTIONS_PER_ROOT - 1)

We only use SECTION_ROOT_MASK in one place.  If we replace it
with some modulo arithmetic, it compiles down to the same thing
for power-of-2 SECTIONS_PER_ROOT values, but it also actually
*works* instead of just failing to boot at some random point
for the other case.

This also adds some requisite comments in the structure for
future hapless kernel developers, plus a bonus WARN_ON_ONCE()
just in case they miss the big fat comment.

Granted, this patch is not fixing a bug that anyone will really
hit in practice, but it will surely save future developers a
headache or two, plus it removes a #define!

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/mmzone.h |    9 +++++++--
 linux-2.6.git-dave/mm/sparse.c            |    5 +++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff -puN include/linux/mmzone.h~sparsemem-fix-boot-when-SECTIONS_PER_ROOT-is-not-power_of_2 include/linux/mmzone.h
--- linux-2.6.git/include/linux/mmzone.h~sparsemem-fix-boot-when-SECTIONS_PER_ROOT-is-not-power_of_2	2012-05-21 13:29:43.777274223 -0700
+++ linux-2.6.git-dave/include/linux/mmzone.h	2012-05-21 13:29:43.789274356 -0700
@@ -1018,6 +1018,12 @@ struct mem_section {
 	struct page_cgroup *page_cgroup;
 	unsigned long pad;
 #endif
+	/*
+	 * WARNING: Do not put any fields here that could cause
+	 * this structure to become a non-power-of-2 size.
+	 * Operations like pfn_to_page() will end up doing
+	 * division in hot paths for CONFIG_SPARSEMEM_EXTREME.
+	 */
 };
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
@@ -1028,7 +1034,6 @@ struct mem_section {
 
 #define SECTION_NR_TO_ROOT(sec)	((sec) / SECTIONS_PER_ROOT)
 #define NR_SECTION_ROOTS	DIV_ROUND_UP(NR_MEM_SECTIONS, SECTIONS_PER_ROOT)
-#define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
 extern struct mem_section *mem_section[NR_SECTION_ROOTS];
@@ -1040,7 +1045,7 @@ static inline struct mem_section *__nr_t
 {
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
 		return NULL;
-	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
+	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr % SECTIONS_PER_ROOT];
 }
 extern int __section_nr(struct mem_section* ms);
 extern unsigned long usemap_size(void);
diff -puN mm/sparse.c~sparsemem-fix-boot-when-SECTIONS_PER_ROOT-is-not-power_of_2 mm/sparse.c
--- linux-2.6.git/mm/sparse.c~sparsemem-fix-boot-when-SECTIONS_PER_ROOT-is-not-power_of_2	2012-05-21 13:29:43.781274268 -0700
+++ linux-2.6.git-dave/mm/sparse.c	2012-05-21 13:29:43.789274356 -0700
@@ -63,6 +63,11 @@ static struct mem_section noinline __ini
 	unsigned long array_size = SECTIONS_PER_ROOT *
 				   sizeof(struct mem_section);
 
+	/*
+	 * See note in 'struct mem_section' definition
+	 */
+	WARN_ON_ONCE(!is_power_of_2(sizeof(struct mem_section)));
+
 	if (slab_is_available()) {
 		if (node_state(nid, N_HIGH_MEMORY))
 			section = kmalloc_node(array_size, GFP_KERNEL, nid);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
