Message-Id: <20080221205525.349180000@menage.corp.google.com>
References: <20080221203518.544461000@menage.corp.google.com>
Date: Thu, 21 Feb 2008 12:35:20 -0800
From: menage@google.com
Subject: [PATCH 2/2] ResCounter: Use read_uint in memory controller
Content-Disposition: inline; filename=memcontrol_use_res_counter_read_uint.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, xemul@openvz.org, balbir@in.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Update the memory controller to use read_uint for its
limit/usage/failcnt control files, calling the new
res_counter_read_uint() function.

Signed-off-by: Paul Menage <menage@google.com>

---
 mm/memcontrol.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

Index: rescounter-2.6.25-rc2-mm1/mm/memcontrol.c
===================================================================
--- rescounter-2.6.25-rc2-mm1.orig/mm/memcontrol.c
+++ rescounter-2.6.25-rc2-mm1/mm/memcontrol.c
@@ -922,13 +922,10 @@ int mem_cgroup_write_strategy(char *buf,
 	return 0;
 }
 
-static ssize_t mem_cgroup_read(struct cgroup *cont,
-			struct cftype *cft, struct file *file,
-			char __user *userbuf, size_t nbytes, loff_t *ppos)
+static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
-	return res_counter_read(&mem_cgroup_from_cont(cont)->res,
-				cft->private, userbuf, nbytes, ppos,
-				NULL);
+	return res_counter_read_uint(&mem_cgroup_from_cont(cont)->res,
+				     cft->private);
 }
 
 static ssize_t mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
@@ -1024,18 +1021,18 @@ static struct cftype mem_cgroup_files[] 
 	{
 		.name = "usage_in_bytes",
 		.private = RES_USAGE,
-		.read = mem_cgroup_read,
+		.read_uint = mem_cgroup_read,
 	},
 	{
 		.name = "limit_in_bytes",
 		.private = RES_LIMIT,
 		.write = mem_cgroup_write,
-		.read = mem_cgroup_read,
+		.read_uint = mem_cgroup_read,
 	},
 	{
 		.name = "failcnt",
 		.private = RES_FAILCNT,
-		.read = mem_cgroup_read,
+		.read_uint = mem_cgroup_read,
 	},
 	{
 		.name = "force_empty",

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
