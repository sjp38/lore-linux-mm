From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 06 Dec 2007 16:20:53 -0500
Message-Id: <20071206212053.6279.27183.sendpatchset@localhost>
In-Reply-To: <20071206212047.6279.10881.sendpatchset@localhost>
References: <20071206212047.6279.10881.sendpatchset@localhost>
Subject: [PATCH/RFC 1/8] Mem Policy: Write lock mmap_sem while changing task mempolicy
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, ak@suse.de, mel@skynet.ie, eric.whitney@hp.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

PATCH/RFC 01/08 Mem Policy: Write lock mmap_sem while changing task mempolicy

Against:  2.6.24-rc2-mm1

A read of /proc/<pid>/numa_maps holds the target task's mmap_sem
for read while examining each vma's mempolicy.  A vma's mempolicy
can fall back to the task's policy.  However, the task could be
changing it's task policy and free the one that the show_numa_maps()
is examining.

To prevent this, grab the mmap_sem for write when updating task
mempolicy.   Pointed out to me by Christoph Lameter and extracted
and reworked from Christoph's alternative mempol reference counting
patch.

This is analogous to the way that do_mbind() and do_get_mempolicy()
prevent races between task's sharing an mm_struct [a.k.a. threads]
setting and querying a mempolicy for a particular address.

Note:  this is necessary, but not sufficient, to allow us to stop
taking an extra reference on "other task's mempolicy" in get_vma_policy.
Subsequent patches will complete this update, allowing us to simplify
the tests for whether we need to unref a mempolicy at various points
in the code.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
[needs Christoph's sign-off if he agrees]

 mm/mempolicy.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

Index: linux-2.6.24-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.24-rc4-mm1.orig/mm/mempolicy.c	2007-12-05 11:54:20.000000000 -0500
+++ linux-2.6.24-rc4-mm1/mm/mempolicy.c	2007-12-05 11:54:22.000000000 -0500
@@ -450,17 +450,30 @@ static void mpol_set_task_struct_flag(vo
 static long do_set_mempolicy(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *new;
+	struct mm_struct *mm = current->mm;
 
 	if (contextualize_policy(mode, nodes))
 		return -EINVAL;
 	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
+
+	/*
+	 * prevent changing our mempolicy while show_numa_maps()
+	 * is using it.
+	 * Note:  do_set_mempolicy() can be called at init time
+	 * with no 'mm'.
+	 */
+	if (mm)
+		down_write(&mm->mmap_sem);
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->policy == MPOL_INTERLEAVE)
 		current->il_next = first_node(new->v.nodes);
+	if (mm)
+		up_write(&mm->mmap_sem);
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
