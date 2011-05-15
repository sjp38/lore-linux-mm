Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 842B690010D
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:59 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 9/9] proc: allocate storage for numa_maps statistics once
Date: Sun, 15 May 2011 18:20:29 -0400
Message-Id: <1305498029-11677-10-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

In show_numa_map() we collect statistics into a numa_maps structure.
Since the number of NUMA nodes can be very large, this structure is not
a candidate for stack allocation.

Instead of going thru a kmalloc()+kfree() cycle each time show_numa_map()
is invoked, perform the allocation just once when /proc/pid/numa_maps is
opened.

Performing the allocation when numa_maps is opened, and thus before a
reference to the target tasks mm is taken, eliminates a potential
stalemate condition in the oom-killer as originally described by Hugh
Dickins:

  ... imagine what happens if the system is out of memory, and the mm
  we're looking at is selected for killing by the OOM killer: while
  we wait in __get_free_page for more memory, no memory is freed
  from the selected mm because it cannot reach exit_mmap while we hold
  that reference.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 fs/proc/task_mmu.c |   36 +++++++++++++++++++++++++++---------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index fbe5ed9..cccc102 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -872,6 +872,11 @@ struct numa_maps {
 	unsigned long node[MAX_NUMNODES];
 };
 
+struct numa_maps_private {
+	struct proc_maps_private proc_maps;
+	struct numa_maps md;
+};
+
 static void gather_stats(struct page *page, struct numa_maps *md, int pte_dirty)
 {
 	int count = page_mapcount(page);
@@ -964,9 +969,10 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
  */
 static int show_numa_map(struct seq_file *m, void *v)
 {
-	struct proc_maps_private *priv = m->private;
+	struct numa_maps_private *numa_priv = m->private;
+	struct proc_maps_private *proc_priv = &numa_priv->proc_maps;
 	struct vm_area_struct *vma = v;
-	struct numa_maps *md;
+	struct numa_maps *md = &numa_priv->md;
 	struct file *file = vma->vm_file;
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_walk walk = {};
@@ -977,9 +983,8 @@ static int show_numa_map(struct seq_file *m, void *v)
 	if (!mm)
 		return 0;
 
-	md = kzalloc(sizeof(struct numa_maps), GFP_KERNEL);
-	if (!md)
-		return 0;
+	/* Ensure we start with an empty set of numa_maps statistics. */
+	memset(md, 0, sizeof(*md));
 
 	md->vma = vma;
 
@@ -988,7 +993,7 @@ static int show_numa_map(struct seq_file *m, void *v)
 	walk.private = md;
 	walk.mm = mm;
 
-	pol = get_vma_policy(priv->task, vma, vma->vm_start);
+	pol = get_vma_policy(proc_priv->task, vma, vma->vm_start);
 	mpol_to_str(buffer, sizeof(buffer), pol, 0);
 	mpol_cond_put(pol);
 
@@ -1035,12 +1040,12 @@ static int show_numa_map(struct seq_file *m, void *v)
 			seq_printf(m, " N%d=%lu", n, md->node[n]);
 out:
 	seq_putc(m, '\n');
-	kfree(md);
 
 	if (m->count < m->size)
-		m->version = (vma != priv->tail_vma) ? vma->vm_start : 0;
+		m->version = (vma != proc_priv->tail_vma) ? vma->vm_start : 0;
 	return 0;
 }
+
 static const struct seq_operations proc_pid_numa_maps_op = {
         .start  = m_start,
         .next   = m_next,
@@ -1050,7 +1055,20 @@ static const struct seq_operations proc_pid_numa_maps_op = {
 
 static int numa_maps_open(struct inode *inode, struct file *file)
 {
-	return do_maps_open(inode, file, &proc_pid_numa_maps_op);
+	struct numa_maps_private *priv;
+	int ret = -ENOMEM;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (priv) {
+		priv->proc_maps.pid = proc_pid(inode);
+		ret = seq_open(file, &proc_pid_numa_maps_op);
+		if (!ret) {
+			struct seq_file *m = file->private_data;
+			m->private = priv;
+		} else {
+			kfree(priv);
+		}
+	}
+	return ret;
 }
 
 const struct file_operations proc_numa_maps_operations = {
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
