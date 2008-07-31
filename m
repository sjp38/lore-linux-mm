Date: Thu, 31 Jul 2008 21:03:17 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 007/008](memory hotplug) callback routine for mempolicy
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731210224.2A4F.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch is very incomplete (includes dummy code),
but I would like to show what mempolicy has to do when node is removed.

Basically, user should change policy before removing node
which is used mempolicy. However, user may not know
mempolicy is used due to automatic setting by software.
The kernel must guarantee removed node will be not used.

There is callback when memory offlining, mempolicy can change
each task's policies.

There are some issues.
  - If nodes_weight(pol->v.nodes) will be 0 due to node removing,
    Kernel will not be able to allocate any pages.
    What does kernel should do?  Kill its process?
  - If preffered node is removing, then which node should be next
    preffered node?

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/mempolicy.c |   32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

Index: current/mm/mempolicy.c
===================================================================
--- current.orig/mm/mempolicy.c	2008-07-29 22:17:25.000000000 +0900
+++ current/mm/mempolicy.c	2008-07-29 22:17:29.000000000 +0900
@@ -2345,3 +2345,35 @@ out:
 		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
 	return 0;
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static int mempolicy_mem_offline_callback(void *arg)
+{
+	int offline_node;
+	struct memory_notify *marg = arg;
+
+	offline_node = marg->status_change_nid;
+
+	/*
+	 * If the node still has available memory, we keep policies.
+	 */
+	if (offline_node < 0)
+		return 0;
+
+	/*
+	 * Disable all offline node's bit for each node mask.
+	 */
+	for_each_policy(pol) {
+		switch (pol->mode) {
+		case MPOL_BIND:
+		case MPOL_INTERLEAVE:
+			/* Force disable node bit */
+			node_clear(offline_node, pol->v.nodes);
+			break;
+		case MPOL_PREFFERED:
+			/* TBD */
+		default:
+			break;
+	}
+}
+#endif

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
