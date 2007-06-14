Message-Id: <20070614075335.931082418@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:34 -0700
From: clameter@sgi.com
Subject: [RFC 08/13] Memoryless node: Allow profiling data to fall back to other nodes
Content-Disposition: inline; filename=nodeless_profile
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Processors on memoryless nodes must be able to fall back to remote nodes
in order to get a profiling buffer. This may lead to excessive NUMA traffic
but I think we should allow this rather than failing.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/kernel/profile.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/kernel/profile.c	2007-06-13 23:36:42.000000000 -0700
+++ linux-2.6.22-rc4-mm2/kernel/profile.c	2007-06-13 23:36:55.000000000 -0700
@@ -346,7 +346,7 @@ static int __devinit profile_cpu_callbac
 		per_cpu(cpu_profile_flip, cpu) = 0;
 		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
 			page = alloc_pages_node(node,
-					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
 				return NOTIFY_BAD;
@@ -354,7 +354,7 @@ static int __devinit profile_cpu_callbac
 		}
 		if (!per_cpu(cpu_profile_hits, cpu)[0]) {
 			page = alloc_pages_node(node,
-					GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+					GFP_KERNEL | __GFP_ZERO,
 					0);
 			if (!page)
 				goto out_free;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
