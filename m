Message-Id: <20080220053239.836363000@menage.corp.google.com>
References: <20080220051544.018684000@menage.corp.google.com>
Date: Tue, 19 Feb 2008 21:15:46 -0800
From: menage@google.com
Subject: [PATCH 2/2] cgroup map files: Use cgroup map for memcontrol stats file
Content-Disposition: inline; filename=memcontrol_use_cgroup_map.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Remove the seq_file boilerplate used to construct the memcontrol stats
map, and instead use the new map representation for cgroup control
files

Signed-off-by: Paul Menage <menage@google.com>

---
 mm/memcontrol.c |   30 ++++++------------------------
 1 file changed, 6 insertions(+), 24 deletions(-)

Index: cgroupmap-2.6.25-rc2-mm1/mm/memcontrol.c
===================================================================
--- cgroupmap-2.6.25-rc2-mm1.orig/mm/memcontrol.c
+++ cgroupmap-2.6.25-rc2-mm1/mm/memcontrol.c
@@ -974,9 +974,9 @@ static const struct mem_cgroup_stat_desc
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
 };
 
-static int mem_control_stat_show(struct seq_file *m, void *arg)
+static int mem_control_stat_show(struct cgroup *cont, struct cftype *cft,
+				 struct cgroup_map_cb *cb)
 {
-	struct cgroup *cont = m->private;
 	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
 	struct mem_cgroup_stat *stat = &mem_cont->stat;
 	int i;
@@ -986,8 +986,7 @@ static int mem_control_stat_show(struct 
 
 		val = mem_cgroup_read_stat(stat, i);
 		val *= mem_cgroup_stat_desc[i].unit;
-		seq_printf(m, "%s %lld\n", mem_cgroup_stat_desc[i].msg,
-				(long long)val);
+		cb->fill(cb, mem_cgroup_stat_desc[i].msg, val);
 	}
 	/* showing # of active pages */
 	{
@@ -997,29 +996,12 @@ static int mem_control_stat_show(struct 
 						MEM_CGROUP_ZSTAT_INACTIVE);
 		active = mem_cgroup_get_all_zonestat(mem_cont,
 						MEM_CGROUP_ZSTAT_ACTIVE);
-		seq_printf(m, "active %ld\n", (active) * PAGE_SIZE);
-		seq_printf(m, "inactive %ld\n", (inactive) * PAGE_SIZE);
+		cb->fill(cb, "active", (active) * PAGE_SIZE);
+		cb->fill(cb, "inactive", (inactive) * PAGE_SIZE);
 	}
 	return 0;
 }
 
-static const struct file_operations mem_control_stat_file_operations = {
-	.read = seq_read,
-	.llseek = seq_lseek,
-	.release = single_release,
-};
-
-static int mem_control_stat_open(struct inode *unused, struct file *file)
-{
-	/* XXX __d_cont */
-	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
-
-	file->f_op = &mem_control_stat_file_operations;
-	return single_open(file, mem_control_stat_show, cont);
-}
-
-
-
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -1044,7 +1026,7 @@ static struct cftype mem_cgroup_files[] 
 	},
 	{
 		.name = "stat",
-		.open = mem_control_stat_open,
+		.read_map = mem_control_stat_show,
 	},
 };
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
