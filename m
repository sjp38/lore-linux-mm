Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k78Gdanx021971
	for <linux-mm@kvack.org>; Tue, 8 Aug 2006 11:39:36 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k78GjpDu45137087
	for <linux-mm@kvack.org>; Tue, 8 Aug 2006 09:45:52 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k78GdanB50699928
	for <linux-mm@kvack.org>; Tue, 8 Aug 2006 09:39:36 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GAUcC-0007DI-00
	for <linux-mm@kvack.org>; Tue, 08 Aug 2006 09:39:36 -0700
Date: Tue, 8 Aug 2006 09:39:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] Profiling: Require buffer allocation on the correct node
Message-ID: <Pine.LNX.4.64.0608080938330.27620@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(depends on __GFP_THISNODE being available. See earlier patchset)

Profiling really suffers with off node buffers. Fail if no memory is available
on the nodes. The profiling code is already set up to deal with these 
failures should they occur.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc3-mm2/kernel/profile.c
===================================================================
--- linux-2.6.18-rc3-mm2.orig/kernel/profile.c	2006-07-29 23:15:36.000000000 -0700
+++ linux-2.6.18-rc3-mm2/kernel/profile.c	2006-08-08 09:27:35.592010690 -0700
@@ -309,13 +309,17 @@ static int __devinit profile_cpu_callbac
 		node = cpu_to_node(cpu);
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
-			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+			page = alloc_pages_node(node,
+					GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+					0);
 			if (!page)
 				return NOTIFY_BAD;
 			per_cpu(cpu_profile_hits, cpu)[1] = page_address(page);
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
-			page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+			page = alloc_pages_node(node,
+					GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+					0);
 			if (!page)
 				goto out_free;
 			per_cpu(cpu_profile_hits, cpu)[0] = page_address(page);
@@ -491,12 +495,16 @@ static int __init create_hash_tables(voi
 		int node = cpu_to_node(cpu);
 		struct page *page;
 
-		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = alloc_pages_node(node,
+				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
-		page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
+		page = alloc_pages_node(node,
+				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
+				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[0]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
