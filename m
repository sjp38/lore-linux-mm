From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:21:11 -0500
Message-Id: <20071206212111.6279.37757.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 4/8] Mem Policy: Document {set|get}_policy() vm_ops APIs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, eric.whitney@hp.com, clameter@sgi.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

PATCH/RFC 04/08 Mem Policy:  Document {set|get}_policy() vm_ops APIs

Against: 2.6.24-rc2-mm1

Document mempolicy return value reference semantics assumed by
the rest of the mempolicy code for the set_ and get_policy vm_ops
in <linux/mm.h>--where the prototypes are defined--to inform any
future mempolicy vm_op writers what the rest of the subsystem
expects of them.

Note:  An alternative, suggested by Christoph Lameter:  we could
define get_policy() to add an extra ref to any non-null mempolicy
returned.  get_vma_policy() could then inform its caller--e.g., via
an addtional argument point to a 'needs_unref' variable--that the
policy needs unref [mpol_free()] after use.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/mm.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-10-29 13:20:52.000000000 -0400
+++ Linux/include/linux/mm.h	2007-10-29 13:25:33.000000000 -0400
@@ -173,7 +173,25 @@ struct vm_operations_struct {
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct page *page);
 #ifdef CONFIG_NUMA
+	/*
+	 * set_policy() op must add a reference to any non-NULL @new mempolicy
+	 * to hold the policy upon return.  Caller should pass NULL @new to
+	 * remove a policy and fall back to surrounding context--i.e. do not
+	 * install a MPOL_DEFAULT policy, nor the task or system default
+	 * mempolicy.
+	 */
 	int (*set_policy)(struct vm_area_struct *vma, struct mempolicy *new);
+
+	/*
+	 * get_policy() op must add reference [mpol_get()] to any policy at
+	 * (vma,addr) marked as MPOL_SHARED.  The shared policy infrastructure
+	 * in mm/mempolicy.c will do this automatically.
+	 * get_policy() must NOT add a ref if the policy at (vma,addr) is not
+	 * marked as MPOL_SHARED. vma policies are protected by the mmap_sem.
+	 * If no [shared/vma] mempolicy exists at the addr, get_policy() op
+	 * must return NULL--i.e., do not "fallback" to task or system default
+	 * policy.
+	 */
 	struct mempolicy *(*get_policy)(struct vm_area_struct *vma,
 					unsigned long addr);
 	int (*migrate)(struct vm_area_struct *vma, const nodemask_t *from,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
