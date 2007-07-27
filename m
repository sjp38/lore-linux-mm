From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:44:14 -0400
Message-Id: <20070727194414.18614.6347.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 09/14] Memoryless node: Allow profiling data to fall back to other nodes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 09/14] Memoryless node: Allow profiling data to fall back to other nodes

Processors on memoryless nodes must be able to fall back to remote nodes
in order to get a profiling buffer. This may lead to excessive NUMA traffic
but I think we should allow this rather than failing.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

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
