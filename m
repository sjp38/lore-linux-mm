Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 07BFE6B007E
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:55:54 -0500 (EST)
Date: Tue, 24 Nov 2009 16:55:21 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        fweisbec@gmail.com, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi,
        peterz@infradead.org, eduard.munteanu@linux360.ro, tglx@linutronix.de,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <4B0B6E87.10906@cn.fujitsu.com>
References: <4B0B6E87.10906@cn.fujitsu.com>
Subject: [tip:perf/core] perf kmem: Collect cross node allocation statistics
Message-ID: <tip-7d0d39459dab20bf60cac30a1a7d50b286c60cc1@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  7d0d39459dab20bf60cac30a1a7d50b286c60cc1
Gitweb:     http://git.kernel.org/tip/7d0d39459dab20bf60cac30a1a7d50b286c60cc1
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Tue, 24 Nov 2009 13:26:31 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 24 Nov 2009 08:49:50 +0100

perf kmem: Collect cross node allocation statistics

Show cross node memory allocations:

 # ./perf kmem

 SUMMARY
 =======
 ...
 Cross node allocations: 0/3633

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <4B0B6E87.10906@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 tools/perf/builtin-kmem.c |   81 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
index dc86f1e..1ecf3f4 100644
--- a/tools/perf/builtin-kmem.c
+++ b/tools/perf/builtin-kmem.c
@@ -36,6 +36,9 @@ static char			default_sort_order[] = "frag,hit,bytes";
 static char			*cwd;
 static int			cwdlen;
 
+static int			*cpunode_map;
+static int			max_cpu_num;
+
 struct alloc_stat {
 	union {
 		u64	call_site;
@@ -54,12 +57,74 @@ static struct rb_root root_caller_stat;
 static struct rb_root root_caller_sorted;
 
 static unsigned long total_requested, total_allocated;
+static unsigned long nr_allocs, nr_cross_allocs;
 
 struct raw_event_sample {
 	u32 size;
 	char data[0];
 };
 
+#define PATH_SYS_NODE	"/sys/devices/system/node"
+
+static void init_cpunode_map(void)
+{
+	FILE *fp;
+	int i;
+
+	fp = fopen("/sys/devices/system/cpu/kernel_max", "r");
+	if (!fp) {
+		max_cpu_num = 4096;
+		return;
+	}
+
+	if (fscanf(fp, "%d", &max_cpu_num) < 1)
+		die("Failed to read 'kernel_max' from sysfs");
+	max_cpu_num++;
+
+	cpunode_map = calloc(max_cpu_num, sizeof(int));
+	if (!cpunode_map)
+		die("calloc");
+	for (i = 0; i < max_cpu_num; i++)
+		cpunode_map[i] = -1;
+	fclose(fp);
+}
+
+static void setup_cpunode_map(void)
+{
+	struct dirent *dent1, *dent2;
+	DIR *dir1, *dir2;
+	unsigned int cpu, mem;
+	char buf[PATH_MAX];
+
+	init_cpunode_map();
+
+	dir1 = opendir(PATH_SYS_NODE);
+	if (!dir1)
+		return;
+
+	while (true) {
+		dent1 = readdir(dir1);
+		if (!dent1)
+			break;
+
+		if (sscanf(dent1->d_name, "node%u", &mem) < 1)
+			continue;
+
+		snprintf(buf, PATH_MAX, "%s/%s", PATH_SYS_NODE, dent1->d_name);
+		dir2 = opendir(buf);
+		if (!dir2)
+			continue;
+		while (true) {
+			dent2 = readdir(dir2);
+			if (!dent2)
+				break;
+			if (sscanf(dent2->d_name, "cpu%u", &cpu) < 1)
+				continue;
+			cpunode_map[cpu] = mem;
+		}
+	}
+}
+
 static int
 process_comm_event(event_t *event, unsigned long offset, unsigned long head)
 {
@@ -157,15 +222,16 @@ static void insert_caller_stat(unsigned long call_site,
 
 static void process_alloc_event(struct raw_event_sample *raw,
 				struct event *event,
-				int cpu __used,
+				int cpu,
 				u64 timestamp __used,
 				struct thread *thread __used,
-				int node __used)
+				int node)
 {
 	unsigned long call_site;
 	unsigned long ptr;
 	int bytes_req;
 	int bytes_alloc;
+	int node1, node2;
 
 	ptr = raw_field_value(event, "ptr", raw->data);
 	call_site = raw_field_value(event, "call_site", raw->data);
@@ -177,6 +243,14 @@ static void process_alloc_event(struct raw_event_sample *raw,
 
 	total_requested += bytes_req;
 	total_allocated += bytes_alloc;
+
+	if (node) {
+		node1 = cpunode_map[cpu];
+		node2 = raw_field_value(event, "node", raw->data);
+		if (node1 != node2)
+			nr_cross_allocs++;
+	}
+	nr_allocs++;
 }
 
 static void process_free_event(struct raw_event_sample *raw __used,
@@ -359,6 +433,7 @@ static void print_summary(void)
 	       total_allocated - total_requested);
 	printf("Internal fragmentation: %f%%\n",
 	       fragmentation(total_requested, total_allocated));
+	printf("Cross CPU allocations: %lu/%lu\n", nr_cross_allocs, nr_allocs);
 }
 
 static void print_result(void)
@@ -685,6 +760,8 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __used)
 	if (list_empty(&alloc_sort))
 		setup_sorting(&alloc_sort, default_sort_order);
 
+	setup_cpunode_map();
+
 	return __cmd_kmem();
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
