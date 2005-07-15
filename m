Date: Thu, 14 Jul 2005 18:39:46 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
Message-ID: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

This patch adds a new proc entry for each process called "numa_policy".

If read this file will output a text string describing the memory policy for the process.
A new policy may be written to "numa_policy" in order to change the memory
policy for the process. The following strings may be written to
/proc/<pid>/numa_policy:

default			-> Reset allocation policy to default
prefer=<node>		-> Prefer allocation on specified node
interleave={nodelist}	-> Interleaved allocation on the given nodes
bind={zonelist}		-> Restrict allocation to the specified zones.

Zones are specified by either only providing the node number or using the
notation zone/name. I.e. 3/normal 1/high 0/dma etc.

Additionally the patch also adds write capability to the "numa_maps". One can write
a VMA address followed by the policy to that file to change the mempolicy of an
individual virtual memory area. i.e.

echo "2aaaaaaab000 bind={0/Normal}" >numa_maps

This is compatible with the output format of numa_maps.

These functions are a core requirement for the ability to manage the memory allocation
of processes dynamically. This may be done by the administrator manually as described
here or one may write a batch process manager that manages the memory on a numa system.

The patch requires my numa_maps patch from Andrew Morton's tree.

Here is an example. We want to reorganize how process  12024 is allocating memory.
We would like to allocate most pages on node 1.  However, we would like the
heap pages to be allocated interleaved on nodes 2 and 3 to allow better throughput.

cd /proc/12024/

echo "prefer=1" >numa_policy

margin:/proc/12024 # cat numa_maps
00000000 prefer=1 MaxRef=0 Pages=0 Mapped=0
2000000000000000 prefer=1 MaxRef=42 Pages=11 Mapped=11 N0=3 N1=2 N2=2 N3=4
2000000000038000 prefer=1 MaxRef=1 Pages=2 Mapped=2 Anon=2 N1=2
2000000000040000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
2000000000058000 prefer=1 MaxRef=42 Pages=59 Mapped=59 N0=14 N1=16 N2=15 N3=14
2000000000260000 prefer=1 MaxRef=0 Pages=0 Mapped=0
2000000000268000 prefer=1 MaxRef=1 Pages=2 Mapped=2 Anon=2 N1=2
2000000000274000 prefer=1 MaxRef=1 Pages=3 Mapped=3 Anon=3 N1=3
2000000000280000 prefer=1 MaxRef=8 Pages=3 Mapped=3 N0=3
2000000000300000 prefer=1 MaxRef=8 Pages=2 Mapped=2 N0=2
2000000000318000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
4000000000000000 prefer=1 MaxRef=6 Pages=2 Mapped=2 N1=2
6000000000004000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
6000000000008000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
60000fff7fffc000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
60000ffffff3c000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
margin:/proc/12024 # cat maps
00000000-00004000 r--p 00000000 00:00 0
2000000000000000-200000000002c000 r-xp 00000000 08:04 516                /lib/ld-2.3.3.so
2000000000038000-2000000000040000 rw-p 00028000 08:04 516                /lib/ld-2.3.3.so
2000000000040000-2000000000044000 rw-p 2000000000040000 00:00 0
2000000000058000-2000000000260000 r-xp 00000000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000260000-2000000000268000 ---p 00208000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000268000-2000000000274000 rw-p 00200000 08:04 54707842           /lib/tls/libc.so.6.1
2000000000274000-2000000000280000 rw-p 2000000000274000 00:00 0
2000000000280000-20000000002b4000 r--p 00000000 08:04 9126923            /usr/lib/locale/en_US.utf8/LC_CTYPE
2000000000300000-2000000000308000 r--s 00000000 08:04 60071467           /usr/lib/gconv/gconv-modules.cache
2000000000318000-2000000000328000 rw-p 2000000000318000 00:00 0
4000000000000000-4000000000008000 r-xp 00000000 08:04 29576399           /sbin/mingetty
6000000000004000-6000000000008000 rw-p 00004000 08:04 29576399           /sbin/mingetty
6000000000008000-600000000002c000 rw-p 6000000000008000 00:00 0          [heap]
60000fff7fffc000-60000fff80000000 rw-p 60000fff7fffc000 00:00 0
60000ffffff3c000-60000ffffff90000 rw-p 60000ffffff3c000 00:00 0          [stack]
a000000000000000-a000000000020000 ---p 00000000 00:00 0                  [vdso]

echo "2xxxx interleave={2,3}" >numa_maps

margin:/proc/12024 # cat numa_maps
00000000 prefer=1 MaxRef=0 Pages=0 Mapped=0
2000000000000000 prefer=1 MaxRef=42 Pages=11 Mapped=11 N0=3 N1=2 N2=2 N3=4
2000000000038000 prefer=1 MaxRef=1 Pages=2 Mapped=2 Anon=2 N1=2
2000000000040000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
2000000000058000 prefer=1 MaxRef=42 Pages=59 Mapped=59 N0=14 N1=16 N2=15 N3=14
2000000000260000 prefer=1 MaxRef=0 Pages=0 Mapped=0
2000000000268000 prefer=1 MaxRef=1 Pages=2 Mapped=2 Anon=2 N1=2
2000000000274000 prefer=1 MaxRef=1 Pages=3 Mapped=3 Anon=3 N1=3
2000000000280000 prefer=1 MaxRef=8 Pages=3 Mapped=3 N0=3
2000000000300000 prefer=1 MaxRef=8 Pages=2 Mapped=2 N0=2
2000000000318000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
4000000000000000 prefer=1 MaxRef=6 Pages=2 Mapped=2 N1=2
6000000000004000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
6000000000008000 interleave={2,3} MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
60000fff7fffc000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1
60000ffffff3c000 prefer=1 MaxRef=1 Pages=1 Mapped=1 Anon=1 N1=1

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc3/fs/proc/base.c
===================================================================
--- linux-2.6.13-rc3.orig/fs/proc/base.c	2005-07-15 00:40:17.000000000 +0000
+++ linux-2.6.13-rc3/fs/proc/base.c	2005-07-15 01:00:26.000000000 +0000
@@ -65,7 +65,10 @@ enum pid_directory_inos {
 	PROC_TGID_STAT,
 	PROC_TGID_STATM,
 	PROC_TGID_MAPS,
+#ifdef CONFIG_NUMA
 	PROC_TGID_NUMA_MAPS,
+	PROC_TGID_NUMA_POLICY,
+#endif
 	PROC_TGID_MOUNTS,
 	PROC_TGID_WCHAN,
 #ifdef CONFIG_SCHEDSTATS
@@ -103,7 +106,10 @@ enum pid_directory_inos {
 	PROC_TID_STAT,
 	PROC_TID_STATM,
 	PROC_TID_MAPS,
+#ifdef CONFIG_NUMA
 	PROC_TID_NUMA_MAPS,
+	PROC_TID_NUMA_POLICY,
+#endif
 	PROC_TID_MOUNTS,
 	PROC_TID_WCHAN,
 #ifdef CONFIG_SCHEDSTATS
@@ -148,6 +154,7 @@ static struct pid_entry tgid_base_stuff[
 	E(PROC_TGID_MAPS,      "maps",    S_IFREG|S_IRUGO),
 #ifdef CONFIG_NUMA
 	E(PROC_TGID_NUMA_MAPS, "numa_maps", S_IFREG|S_IRUGO),
+	E(PROC_TGID_NUMA_POLICY, "numa_policy", S_IFREG|S_IRUGO|S_IWUSR),
 #endif
 	E(PROC_TGID_MEM,       "mem",     S_IFREG|S_IRUSR|S_IWUSR),
 #ifdef CONFIG_SECCOMP
@@ -187,6 +194,7 @@ static struct pid_entry tid_base_stuff[]
 	E(PROC_TID_MAPS,       "maps",    S_IFREG|S_IRUGO),
 #ifdef CONFIG_NUMA
 	E(PROC_TID_NUMA_MAPS,  "numa_maps",    S_IFREG|S_IRUGO),
+	E(PROC_TID_NUMA_POLICY, "numa_policy", S_IFREG|S_IRUGO|S_IWUSR),
 #endif
 	E(PROC_TID_MEM,        "mem",     S_IFREG|S_IRUSR|S_IWUSR),
 #ifdef CONFIG_SECCOMP
@@ -524,24 +532,8 @@ static struct file_operations proc_maps_
 };
 
 #ifdef CONFIG_NUMA
-extern struct seq_operations proc_pid_numa_maps_op;
-static int numa_maps_open(struct inode *inode, struct file *file)
-{
-	struct task_struct *task = proc_task(inode);
-	int ret = seq_open(file, &proc_pid_numa_maps_op);
-	if (!ret) {
-		struct seq_file *m = file->private_data;
-		m->private = task;
-	}
-	return ret;
-}
-
-static struct file_operations proc_numa_maps_operations = {
-	.open		= numa_maps_open,
-	.read		= seq_read,
-	.llseek		= seq_lseek,
-	.release	= seq_release,
-};
+extern struct file_operations proc_numa_maps_operations;
+extern struct file_operations proc_numa_policy_operations;
 #endif
 
 extern struct seq_operations mounts_op;
@@ -1558,6 +1550,10 @@ static struct dentry *proc_pident_lookup
 		case PROC_TGID_NUMA_MAPS:
 			inode->i_fop = &proc_numa_maps_operations;
 			break;
+		case PROC_TID_NUMA_POLICY:
+		case PROC_TGID_NUMA_POLICY:
+			inode->i_fop = &proc_numa_policy_operations;
+			break;
 #endif
 		case PROC_TID_MEM:
 		case PROC_TGID_MEM:
Index: linux-2.6.13-rc3/mm/mempolicy.c
===================================================================
--- linux-2.6.13-rc3.orig/mm/mempolicy.c	2005-07-15 00:40:17.000000000 +0000
+++ linux-2.6.13-rc3/mm/mempolicy.c	2005-07-15 01:01:48.000000000 +0000
@@ -1170,3 +1170,214 @@ void numa_default_policy(void)
 {
 	sys_set_mempolicy(MPOL_DEFAULT, NULL, 0);
 }
+
+/*
+ * Convert a mempolicy into a string.
+ * Returns the number of characters in buffer (if positive)
+ * or an error (negative)
+ */
+int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
+{
+	char *p = buffer;
+	char *e = buffer + maxlen;
+	int first = 1;
+	int node;
+	struct zone **z;
+
+	if (!pol || pol->policy == MPOL_DEFAULT) {
+		strcpy(buffer,"default");
+		return 7;
+	}
+
+	if (pol->policy == MPOL_PREFERRED) {
+		if (e < p + 8 /* fixed string size */ + 4 /* max len of node number */)
+			return -ENOSPC;
+
+		sprintf(p, "prefer=%d", pol->v.preferred_node);
+		return strlen(buffer);
+
+	} else if (pol->policy == MPOL_BIND) {
+
+		if (e < p + 9 + 4)
+			return -ENOSPC;
+
+		p+= sprintf(p, "bind={");
+
+		for (z = pol->v.zonelist->zones; *z ; *z++) {
+			if (!first)
+				*p++ = ',';
+			else
+				first = 0;
+			if (e < p + 2 + 4 + strlen((*z)->name))
+				return -ENOSPC;
+			p += sprintf(p, "%d/%s", (*z)->zone_pgdat->node_id, (*z)->name);
+		}
+
+		*p++ = '}';
+		*p++ = 0;
+		return p-buffer;
+
+	} else if (pol->policy == MPOL_INTERLEAVE) {
+
+		if (e < p + 14 + 4)
+			return -ENOSPC;
+
+		p += sprintf(p, "interleave={");
+
+		for_each_node(node)
+			if (test_bit(node, pol->v.nodes)) {
+				if (!first)
+					*p++ = ',';
+				else
+					first = 0;
+				if (e < p + 2 /* min bytes that follow */ + 4 /* node number */)
+					return -ENOSPC;
+				p += sprintf(p, "%d", node);
+			}
+
+		*p++ = '}';
+		*p++ = 0;
+		return p-buffer;
+	}
+	BUG();
+	return -EFAULT;
+}
+
+/*
+ * Convert a representation of a memory policy from text
+ * form to binary.
+ *
+ * Returns either a memory policy or NULL for error.
+ */
+struct mempolicy *str_to_mpol(char *buffer, char **end)
+{
+	char *p;
+	struct mempolicy *pol;
+	int node;
+	size_t size;
+
+	if (strnicmp(buffer, "default", 7) == 0) {
+
+		*end = buffer + 7;
+		return &default_policy;
+
+	}
+
+	pol = __mpol_copy(&default_policy);
+	if (IS_ERR(pol))
+		return NULL;
+
+	if (strnicmp(buffer, "prefer=", 7) == 0) {
+
+		node = simple_strtoul(buffer + 7, &p, 10);
+		if (node >= MAX_NUMNODES || !node_online(node))
+			goto out;
+
+		pol->policy = MPOL_PREFERRED;
+		pol->v.preferred_node = node;
+
+	} else if (strnicmp(buffer, "interleave={", 12) == 0) {
+
+		pol->policy = MPOL_INTERLEAVE;
+		p = buffer + 12;
+		bitmap_zero(pol->v.nodes, MAX_NUMNODES);
+
+		do {
+			node = simple_strtoul(p, &p, 10);
+
+			/* Check here for cpuset restrictions on nodes */
+			if (node >= MAX_NUMNODES || !node_online(node))
+				goto out;
+			set_bit(node, pol->v.nodes);
+
+		} while (*p++ == ',');
+
+		if (p[-1] != '}' || bitmap_empty(pol->v.nodes, MAX_NUMNODES))
+			goto out;
+
+	} else if (strnicmp(buffer, "bind={", 6) == 0) {
+
+		struct zonelist *zonelist = kmalloc(sizeof(struct zonelist), GFP_KERNEL);
+		struct zone **z = zonelist->zones;
+		struct zonelist *new;
+
+		pol->policy = MPOL_BIND;
+		p = buffer + 6;
+
+		do {
+			pg_data_t *pgdat;
+			struct zone *zone = NULL;
+
+			node = simple_strtoul(p, &p, 10);
+
+			/* Try to find the pgdat for the specified node */
+			for_each_pgdat(pgdat) {
+				if (pgdat->node_id == node) {
+					zone = pgdat->node_zones;
+					break;
+				}
+			}
+			if (!zone || node >= MAX_NUMNODES || !node_online(node))
+				goto bind_out;
+
+			/*
+			 * If there is no zone specified then take the first
+			 * zone. Otherwise we need to look for a matching name
+			 */
+			if (*p == '/') {
+				char *start = ++p;
+				struct zone *q;
+				struct zone *found = NULL;
+
+				/* Find end of the zone name */
+				while (*p && *p != ',' && *p != '}')
+					p++;
+
+				if (start == p)
+					goto bind_out;
+				/*
+				 * Go through the zones in this node and check
+				 * if any have the name we are looking for
+				 */
+				for(q = zone; q < zone + MAX_NR_ZONES; q++) {
+					if (strnicmp(q->name, start, p-start) == 0) {
+						found = q;
+						break;
+					}
+				}
+				zone = found;
+			}
+
+			if (!zone || z > zonelist->zones + MAX_NUMNODES * MAX_NR_ZONES)
+				goto bind_out;
+			*z++ = zone;
+
+		} while (*p++ == ',');
+
+		if (p[-1] != '}') {
+bind_out:
+			kfree(zonelist);
+			goto out;
+		}
+
+		/* Allocate only the necessary elements */
+		*z++ = NULL;
+		size = (z - zonelist->zones) * sizeof(struct zonelist *);
+		new = kmalloc(size, GFP_KERNEL);
+		if (!new)
+			goto out;
+		memcpy(new, zonelist, size);
+		kfree(zonelist);
+
+		pol->v.zonelist = new;
+
+	} else {
+out:
+		__mpol_free(pol);
+		return NULL;
+	}
+
+	*end = p;
+	return pol;
+}
+
Index: linux-2.6.13-rc3/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.13-rc3.orig/fs/proc/task_mmu.c	2005-07-15 00:40:17.000000000 +0000
+++ linux-2.6.13-rc3/fs/proc/task_mmu.c	2005-07-15 01:00:26.000000000 +0000
@@ -286,15 +286,15 @@ static struct numa_maps *get_numa_maps(c
 	return md;
 }
 
+#define MAX_MEMPOL_STRING_SIZE 50
+
 static int show_numa_map(struct seq_file *m, void *v)
 {
 	struct task_struct *task = m->private;
 	struct vm_area_struct *vma = v;
-	struct mempolicy *pol;
 	struct numa_maps *md;
-	struct zone **z;
 	int n;
-	int first;
+	char buffer[MAX_MEMPOL_STRING_SIZE];
 
 	if (!vma->vm_mm)
 		return 0;
@@ -303,46 +303,11 @@ static int show_numa_map(struct seq_file
 	if (!md)
 		return 0;
 
-	seq_printf(m, "%08lx", vma->vm_start);
-	pol = get_vma_policy(task, vma, vma->vm_start);
-	/* Print policy */
-	switch (pol->policy) {
-	case MPOL_PREFERRED:
-		seq_printf(m, " prefer=%d", pol->v.preferred_node);
-		break;
-	case MPOL_BIND:
-		seq_printf(m, " bind={");
-		first = 1;
-		for (z = pol->v.zonelist->zones; *z; z++) {
-
-			if (!first)
-				seq_putc(m, ',');
-			else
-				first = 0;
-			seq_printf(m, "%d/%s", (*z)->zone_pgdat->node_id,
-					(*z)->name);
-		}
-		seq_putc(m, '}');
-		break;
-	case MPOL_INTERLEAVE:
-		seq_printf(m, " interleave={");
-		first = 1;
-		for_each_node(n) {
-			if (test_bit(n, pol->v.nodes)) {
-				if (!first)
-					seq_putc(m,',');
-				else
-					first = 0;
-				seq_printf(m, "%d",n);
-			}
-		}
-		seq_putc(m, '}');
-		break;
-	default:
-		seq_printf(m," default");
-		break;
-	}
-	seq_printf(m, " MaxRef=%lu Pages=%lu Mapped=%lu",
+	if (mpol_to_str(buffer, sizeof(buffer), get_vma_policy(task, vma, vma->vm_start)) <0)
+		return 0;
+
+	seq_printf(m, "%08lx %s MaxRef=%lu Pages=%lu Mapped=%lu",
+			vma->vm_start, buffer,
 			md->mapcount_max, md->pages, md->mapped);
 	if (md->anon)
 		seq_printf(m," Anon=%lu",md->anon);
@@ -364,4 +329,134 @@ struct seq_operations proc_pid_numa_maps
 	.stop	= m_stop,
 	.show	= show_numa_map
 };
+
+/*
+ * Retrieval and setting of the memory policy for a task
+ */
+static ssize_t numa_policy_read(struct file *file, char __user *buf,
+                                size_t count, loff_t *ppos)
+{
+	struct task_struct *task = proc_task(file->f_dentry->d_inode);
+	char buffer[MAX_MEMPOL_STRING_SIZE];	/* Should this really be on the stack ?? */
+	size_t len;
+	loff_t __ppos = *ppos;
+
+	len = mpol_to_str(buffer, MAX_MEMPOL_STRING_SIZE, task->mempolicy);
+	if (__ppos >= len)
+		return 0;
+	if (count > len-__ppos)
+		count = len-__ppos;
+	if (copy_to_user(buf, buffer + __ppos, count))
+		return -EFAULT;
+	*ppos = __ppos + count;
+	return count;
+}
+
+static ssize_t numa_policy_write(struct file *file, const char __user *buf,
+                                size_t count, loff_t *ppos)
+{
+	struct task_struct *task = proc_task(file->f_dentry->d_inode);
+	char buffer[MAX_MEMPOL_STRING_SIZE], *end;
+	struct mempolicy *pol, *old_policy;
+
+	if (!capable(CAP_SYS_RESOURCE))
+		return -EPERM;
+	memset(buffer, 0, MAX_MEMPOL_STRING_SIZE);
+	if (count > MAX_MEMPOL_STRING_SIZE || !task->mm)
+		return -EINVAL;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+
+	pol = str_to_mpol(buffer, &end);
+	if (!pol)
+		return -EINVAL;
+	if (*end == '\n')
+		end++;
+
+	old_policy = task->mempolicy;
+
+
+	if (!mpol_equal(pol, old_policy)) {
+		if (pol->policy == MPOL_DEFAULT)
+			pol = NULL;
+
+		task->mempolicy = pol;
+		mpol_free(old_policy);
+	} else
+		mpol_free(pol);
+
+	return end - buffer;
+}
+
+
+struct file_operations proc_numa_policy_operations = {
+	.read = numa_policy_read,
+	.write = numa_policy_write
+};
+
+static ssize_t numa_vma_policy_write(struct file *file, const char __user *buf,
+                                size_t count, loff_t *ppos)
+{
+	struct task_struct *task = proc_task(file->f_dentry->d_inode);
+	struct vm_area_struct *vma;
+	unsigned long addr;
+	char buffer[MAX_MEMPOL_STRING_SIZE];
+	char *p, *end;
+	struct mempolicy *pol, *old_policy;
+
+	if (!capable(CAP_SYS_RESOURCE))
+		return -EPERM;
+	memset(buffer, 0, MAX_MEMPOL_STRING_SIZE);
+	if (count > MAX_MEMPOL_STRING_SIZE || !task->mm)
+		return -EINVAL;
+	if (copy_from_user(buffer, buf, count))
+		return -EFAULT;
+
+	/* Extract VMA address and find the vma */
+	addr = simple_strtoul(buffer, &p, 16);
+	if (*p++ != ' ')
+		return -EINVAL;
+	vma = find_vma(task->mm, addr);
+	if (!vma || vma->vm_end < addr)
+		return -EINVAL;
+
+	pol = str_to_mpol(p, &end);
+	if (!pol)
+		return -EINVAL;
+	if (*end == '\n')
+		end++;
+
+	old_policy = vma->vm_policy;
+
+	if (!mpol_equal(pol, old_policy)) {
+		if (pol->policy == MPOL_DEFAULT)
+			pol = NULL;
+
+		vma->vm_policy = pol;
+		mpol_free(old_policy);
+	} else
+		mpol_free(pol);
+
+	return end - buffer;
+}
+
+static int numa_maps_open(struct inode *inode, struct file *file)
+{
+	struct task_struct *task = proc_task(inode);
+	int ret = seq_open(file, &proc_pid_numa_maps_op);
+	if (!ret) {
+		struct seq_file *m = file->private_data;
+		m->private = task;
+	}
+	return ret;
+}
+
+struct file_operations proc_numa_maps_operations = {
+	.open		= numa_maps_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+	.write		= numa_vma_policy_write
+};
+
 #endif
Index: linux-2.6.13-rc3/include/linux/mempolicy.h
===================================================================
--- linux-2.6.13-rc3.orig/include/linux/mempolicy.h	2005-07-15 00:40:17.000000000 +0000
+++ linux-2.6.13-rc3/include/linux/mempolicy.h	2005-07-15 01:00:26.000000000 +0000
@@ -156,6 +156,10 @@ struct mempolicy *get_vma_policy(struct 
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 
+/* Conversion functions for /proc interface */
+int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
+struct mempolicy *str_to_mpol(char *buffer, char **end);
+
 #else
 
 struct mempolicy {};
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
