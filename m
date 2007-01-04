Date: Thu, 4 Jan 2007 11:16:42 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [RFC] mbind: Restrict nodes to the currently allowed cpuset
Message-ID: <Pine.LNX.4.64.0701041115220.22710@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Currently one can specify an arbitrary node mask to mbind that includes nodes
not allowed. If that is done with an interleave policy then we will go around
all the nodes. Those outside of the currently allowed cpuset will be redirected
to the border nodes. Interleave will then create imbalances at the borders
of the cpuset.

This patch restricts the nodes to the currently allowed cpuset.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

----

I still wonder if this is the right approach. Could mbind be used to set 
up policies that are larger than the existing cpuset? Or could mbind be 
used to set up a policy and then the cpuset would change?



Index: linux-2.6.19-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.19-mm1.orig/mm/mempolicy.c	2006-12-11 19:00:38.224610647 -0800
+++ linux-2.6.19-mm1/mm/mempolicy.c	2006-12-13 11:13:10.175294067 -0800
@@ -882,6 +882,7 @@ asmlinkage long sys_mbind(unsigned long 
 	int err;
 
 	err = get_nodes(&nodes, nmask, maxnode);
+	nodes_and(nodes, nodes, current->mems_allowed);
 	if (err)
 		return err;
 	return do_mbind(start, len, mode, &nodes, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
