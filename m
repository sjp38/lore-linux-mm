Date: Wed, 9 Aug 2006 19:18:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Profiling: Require buffer allocation on the correct node
Message-ID: <Pine.LNX.4.64.0608091914470.5464@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Profiling really suffers with off node buffers. Fail if no memory is available
on the nodes. The profiling code can deal with these failures should
they occur.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/kernel/profile.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/kernel/profile.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3-mm2/kernel/profile.c	2006-08-09 19:17:18.274748071 -0700
@@ -309,13 +309,17 @@ static int __devinit profile_cpu_callbac
 		node = cpu_to_node(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
-			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+			page = alloc_pages_node(node,
+					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					0);
 			if (!page)
 				return NOTIFY_BAD;
 			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
-			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+			page = alloc_pages_node(node,
+					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					0);
 			if (!page)
 				goto out_free;
 			per_cpu(cpu_profile_hits, cpu)[0] = page_address(page);
@@ -491,12 +495,16 @@ static int __init create_hash_tables(voi
 		int node = cpu_to_node(cpu);
 		struct page *page;
 
-		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = alloc_pages_node(node,
+				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
-		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = alloc_pages_node(node,
+				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[0]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
