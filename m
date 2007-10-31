Date: Wed, 31 Oct 2007 19:31:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memory cgroup enhancements take 4 [6/8] add memory.stat
 file
Message-Id: <20071031193136.ac7af748.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071031192213.4f736fac.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Show accounted information of memory cgroup by memory.stat file

Changelog v2->v3
 - make use of mem_cgroup_read_stat() at printing.
Changelog v1->v2
 - dropped Charge/Uncharge entry.

Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

Index: devel-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- devel-2.6.23-mm1.orig/mm/memcontrol.c
+++ devel-2.6.23-mm1/mm/memcontrol.c
@@ -28,6 +28,7 @@
 #include <linux/swap.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
+#include <linux/seq_file.h>
 
 #include <asm/uaccess.h>
 
@@ -823,6 +824,48 @@ static ssize_t mem_force_empty_read(stru
 }
 
 
+static const struct mem_cgroup_stat_desc {
+	const char *msg;
+	u64 unit;
+} mem_cgroup_stat_desc[] = {
+	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+};
+
+static int mem_control_stat_show(struct seq_file *m, void *arg)
+{
+	struct cgroup *cont = m->private;
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cont);
+	struct mem_cgroup_stat *stat = &mem_cont->stat;
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(stat->cpustat[0].count); i++) {
+		s64 val;
+
+		val = mem_cgroup_read_stat(stat,i);
+		val *= mem_cgroup_stat_desc[i].unit;
+		seq_printf(m, "%s %lld\n", mem_cgroup_stat_desc[i].msg, val);
+	}
+	return 0;
+}
+
+static const struct file_operations mem_control_stat_file_operations = {
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int mem_control_stat_open(struct inode *unused, struct file *file)
+{
+	/* XXX __d_cont */
+	struct cgroup *cont = file->f_dentry->d_parent->d_fsdata;
+
+	file->f_op = &mem_control_stat_file_operations;
+	return single_open(file, mem_control_stat_show, cont);
+}
+
+
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -850,6 +893,10 @@ static struct cftype mem_cgroup_files[] 
 		.write = mem_force_empty_write,
 		.read = mem_force_empty_read,
 	},
+	{
+		.name = "stat",
+		.open = mem_control_stat_open,
+	},
 };
 
 static struct mem_cgroup init_mem_cgroup;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
