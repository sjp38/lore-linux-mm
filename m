Date: Fri, 15 Sep 2006 10:51:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table
In-Reply-To: <Pine.LNX.4.64.0609151010520.7975@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0609151050470.8355@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
 <1158180795.9141.158.camel@localhost.localdomain>
 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
 <1158184047.9141.164.camel@localhost.localdomain> <450AAA83.3040905@shadowen.org>
 <Pine.LNX.4.64.0609151010520.7975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Optimize section_to_node_table so that it fits in a cacheline

We change the type of the elements in the section to node table
to u8 if we have less than 256 nodes in the system. That way
we can have up to 128 sections in one cacheline which is all
that is necessary for some 32 bit NUMA platforms like NUMAQ to
keep section_to_node_table in a single cacheline and thus
make page_to_zone as fast or faster than before.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/sparse.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/sparse.c	2006-09-15 12:43:12.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/sparse.c	2006-09-15 12:50:20.857430106 -0500
@@ -30,7 +30,11 @@ EXPORT_SYMBOL(mem_section);
  * do a lookup in the section_to_node_table in order to find which
  * node the page belongs to.
  */
-static int section_to_node_table[NR_MEM_SECTIONS];
+#if MAX_NUMNODES <= 256
+static u8 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
+#else
+static u16 section_to_node_table[NR_MEM_SECTIONS] __cacheline_aligned;
+#endif
 
 extern unsigned long page_to_nid(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
