Message-Id: <20080305080000.270536000@menage.corp.google.com>
References: <20080305075237.608599000@menage.corp.google.com>
Date: Tue, 04 Mar 2008 23:52:38 -0800
From: menage@google.com
Subject: [PATCH 1/2] Cpuset hardwall flag:  Switch cpusets to use the bulk cgroup_add_files() API
Content-Disposition: inline; filename=cpuset_add_files.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This change tidies up the cpusets control file definitions, and
reduces the amount of boilerplate required to add/change control files
in the future.

Signed-off-by: Paul Menage <menage@google.com>

---
 kernel/cpuset.c |  149 +++++++++++++++++++++++++-------------------------------
 1 file changed, 68 insertions(+), 81 deletions(-)

Index: hardwall-2.6.25-rc3-mm1/kernel/cpuset.c
===================================================================
--- hardwall-2.6.25-rc3-mm1.orig/kernel/cpuset.c
+++ hardwall-2.6.25-rc3-mm1/kernel/cpuset.c
@@ -1397,46 +1397,69 @@ static u64 cpuset_read_u64(struct cgroup
  * for the common functions, 'private' gives the type of file
  */
 
-static struct cftype cft_cpus = {
-	.name = "cpus",
-	.read = cpuset_common_file_read,
-	.write = cpuset_common_file_write,
-	.private = FILE_CPULIST,
-};
-
-static struct cftype cft_mems = {
-	.name = "mems",
-	.read = cpuset_common_file_read,
-	.write = cpuset_common_file_write,
-	.private = FILE_MEMLIST,
-};
-
-static struct cftype cft_cpu_exclusive = {
-	.name = "cpu_exclusive",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_CPU_EXCLUSIVE,
-};
-
-static struct cftype cft_mem_exclusive = {
-	.name = "mem_exclusive",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_MEM_EXCLUSIVE,
-};
-
-static struct cftype cft_sched_load_balance = {
-	.name = "sched_load_balance",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_SCHED_LOAD_BALANCE,
-};
-
-static struct cftype cft_memory_migrate = {
-	.name = "memory_migrate",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_MEMORY_MIGRATE,
+static struct cftype files[] = {
+	{
+		.name = "cpus",
+		.read = cpuset_common_file_read,
+		.write = cpuset_common_file_write,
+		.private = FILE_CPULIST,
+	},
+
+	{
+		.name = "mems",
+		.read = cpuset_common_file_read,
+		.write = cpuset_common_file_write,
+		.private = FILE_MEMLIST,
+	},
+
+	{
+		.name = "cpu_exclusive",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_CPU_EXCLUSIVE,
+	},
+
+	{
+		.name = "mem_exclusive",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_MEM_EXCLUSIVE,
+	},
+
+	{
+		.name = "sched_load_balance",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_SCHED_LOAD_BALANCE,
+	},
+
+	{
+		.name = "memory_migrate",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_MEMORY_MIGRATE,
+	},
+
+	{
+		.name = "memory_pressure",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_MEMORY_PRESSURE,
+	},
+
+	{
+		.name = "memory_spread_page",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_SPREAD_PAGE,
+	},
+
+	{
+		.name = "memory_spread_slab",
+		.read_u64 = cpuset_read_u64,
+		.write_u64 = cpuset_write_u64,
+		.private = FILE_SPREAD_SLAB,
+	},
 };
 
 static struct cftype cft_memory_pressure_enabled = {
@@ -1446,54 +1469,18 @@ static struct cftype cft_memory_pressure
 	.private = FILE_MEMORY_PRESSURE_ENABLED,
 };
 
-static struct cftype cft_memory_pressure = {
-	.name = "memory_pressure",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_MEMORY_PRESSURE,
-};
-
-static struct cftype cft_spread_page = {
-	.name = "memory_spread_page",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_SPREAD_PAGE,
-};
-
-static struct cftype cft_spread_slab = {
-	.name = "memory_spread_slab",
-	.read_u64 = cpuset_read_u64,
-	.write_u64 = cpuset_write_u64,
-	.private = FILE_SPREAD_SLAB,
-};
-
 static int cpuset_populate(struct cgroup_subsys *ss, struct cgroup *cont)
 {
 	int err;
 
-	if ((err = cgroup_add_file(cont, ss, &cft_cpus)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_mems)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_cpu_exclusive)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_mem_exclusive)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_memory_migrate)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_sched_load_balance)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_memory_pressure)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_spread_page)) < 0)
-		return err;
-	if ((err = cgroup_add_file(cont, ss, &cft_spread_slab)) < 0)
+	err = cgroup_add_files(cont, ss, files, ARRAY_SIZE(files));
+	if (err)
 		return err;
 	/* memory_pressure_enabled is in root cpuset only */
-	if (err == 0 && !cont->parent)
+	if (!cont->parent)
 		err = cgroup_add_file(cont, ss,
-					 &cft_memory_pressure_enabled);
-	return 0;
+				      &cft_memory_pressure_enabled);
+	return err;
 }
 
 /*

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
