Date: Thu, 26 Oct 2006 13:33:05 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH 2/3] Create compat_sys_migrate_pages
Message-Id: <20061026133305.b0db54e6.sfr@canb.auug.org.au>
In-Reply-To: <20061026132659.2ff90dd1.sfr@canb.auug.org.au>
References: <20061026132659.2ff90dd1.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, paulus@samba.org, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is needed on bigendian 64bit architectures. The obvious way to do
this (taking the other compat_ routines in this file as examples) is to
use compat_alloc_user_space and copy the bitmasks back there, however you
cannot call compat_alloc_user_space twice for a single system call and
this method saves two copies of the bitmasks.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 mm/mempolicy.c |  107 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 93 insertions(+), 14 deletions(-)

Maybe the other compat routines in here should be converted to use
compat_get_nodes as well.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 617fb31..65c0281 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -854,6 +854,58 @@ static int get_nodes(nodemask_t *nodes,
 	return 0;
 }
 
+#ifdef CONFIG_COMPAT
+static int compat_get_nodes(nodemask_t *nodes,
+		const compat_ulong_t __user *nmask, unsigned long maxnode)
+{
+	unsigned long k;
+	unsigned long nlongs;
+	unsigned long nbits = maxnode - 1;
+	compat_ulong_t endmask;
+
+	if (maxnode == 0)
+		return -EINVAL;
+	nodes_clear(*nodes);
+	if (nbits == 0 || !nmask)
+		return 0;
+	if (nbits > PAGE_SIZE * BITS_PER_BYTE)
+		return -EINVAL;
+
+	nlongs = BITS_TO_COMPAT_LONGS(nbits);
+	if ((nbits % BITS_PER_COMPAT_LONG) == 0)
+		endmask = (compat_ulong_t)~0;
+	else
+		endmask = ((compat_ulong_t)1 <<
+				(nbits % BITS_PER_COMPAT_LONG)) - 1;
+
+	/* When the user specified more nodes than supported just check
+	   if the non supported part is all zero. */
+	if (nbits > MAX_NUMNODES) {
+		if (nlongs > PAGE_SIZE / sizeof(compat_ulong_t))
+			return -EINVAL;
+		for (k = BITS_TO_COMPAT_LONGS(MAX_NUMNODES); k < nlongs; k++) {
+			compat_ulong_t t;
+
+			if (get_user(t, nmask + k))
+				return -EFAULT;
+			if (k == (nlongs - 1)) {
+				if (t & endmask)
+					return -EINVAL;
+			} else if (t)
+				return -EINVAL;
+		}
+		nbits = MAX_NUMNODES;
+		endmask = ~0;
+	}
+
+	if (compat_get_bitmap(nodes_addr(*nodes), nmask, nbits))
+		return -EFAULT;
+	if (nbits % BITS_PER_COMPAT_LONG)
+		nodes_addr(*nodes)[BITS_TO_COMPAT_LONGS(nbits) - 1] &= endmask;
+	return 0;
+}
+#endif /* CONFIG_COMPAT */
+
 /* Copy a kernel node mask to user space */
 static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 			      nodemask_t *nodes)
@@ -900,25 +952,13 @@ asmlinkage long sys_set_mempolicy(int mo
 	return do_set_mempolicy(mode, &nodes);
 }
 
-asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
-		const unsigned long __user *old_nodes,
-		const unsigned long __user *new_nodes)
+static long internal_migrate_pages(pid_t pid, nodemask_t *old, nodemask_t *new)
 {
 	struct mm_struct *mm;
 	struct task_struct *task;
-	nodemask_t old;
-	nodemask_t new;
 	nodemask_t task_nodes;
 	int err;
 
-	err = get_nodes(&old, old_nodes, maxnode);
-	if (err)
-		return err;
-
-	err = get_nodes(&new, new_nodes, maxnode);
-	if (err)
-		return err;
-
 	/* Find the mm_struct */
 	read_lock(&tasklist_lock);
 	task = pid ? find_task_by_pid(pid) : current;
@@ -963,6 +1003,25 @@ out:
 	return err;
 }
 
+asmlinkage long sys_migrate_pages(pid_t pid, unsigned long maxnode,
+		const unsigned long __user *old_nodes,
+		const unsigned long __user *new_nodes)
+{
+	nodemask_t old;
+	nodemask_t new;
+	int err;
+
+	err = get_nodes(&old, old_nodes, maxnode);
+	if (err)
+		return err;
+
+	err = get_nodes(&new, new_nodes, maxnode);
+	if (err)
+		return err;
+
+	return internal_migrate_pages(pid, old, new);
+}
+
 
 /* Retrieve NUMA policy */
 asmlinkage long sys_get_mempolicy(int __user *policy,
@@ -1067,7 +1126,27 @@ asmlinkage long compat_sys_mbind(compat_
 	return sys_mbind(start, len, mode, nm, nr_bits+1, flags);
 }
 
-#endif
+asmlinkage long compat_sys_migrate_pages(compat_pid_t pid,
+			compat_ulong_t maxnode,
+			const compat_ulong_t __user *old_nodes,
+			const compat_ulong_t __user *new_nodes)
+{
+	nodemask_t old;
+	nodemask_t new;
+	int err;
+
+	err = get_nodes(&old, old_nodes, maxnode);
+	if (err)
+		return err;
+
+	err = get_nodes(&new, new_nodes, maxnode);
+	if (err)
+		return err;
+
+	return internal_migrate_pages(pid, old, new);
+}
+
+#endif /* CONFIG_COMPAT */
 
 /* Return effective policy for a VMA */
 static struct mempolicy * get_vma_policy(struct task_struct *task,
-- 
1.4.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
