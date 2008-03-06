Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m26J1r8j018024
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 14:01:53 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m26J1a09107202
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 12:01:37 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m26J1Zrw022741
	for <linux-mm@kvack.org>; Thu, 6 Mar 2008 12:01:36 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 00:29:52 +0530
Message-Id: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
Subject: [PATCH] Add cgroup support for enabling controllers at boot time
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Paul Menage <menage@google.com>

The effects of cgroup_disable=foo are:

- foo doesn't show up in /proc/cgroups
- foo isn't auto-mounted if you mount all cgroups in a single hierarchy
- foo isn't visible as an individually mountable subsystem

As a result there will only ever be one call to foo->create(), at init
time; all processes will stay in this group, and the group will never
be mounted on a visible hierarchy. Any additional effects (e.g. not
allocating metadata) are up to the foo subsystem.

This doesn't handle early_init subsystems (their "disabled" bit isn't
set be, but it could easily be extended to do so if any of the early_init
systems wanted it - I think it would just involve some nastier parameter
processing since it would occur before the command-line argument parser
had been run.

[Balbir added Documentation/kernel-parameters updates]

Signed-off-by: Paul Menage <menage@google.com>
Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/kernel-parameters.txt |    4 ++++
 include/linux/cgroup.h              |    1 +
 kernel/cgroup.c                     |   27 +++++++++++++++++++++++++--
 3 files changed, 30 insertions(+), 2 deletions(-)

diff -puN include/linux/cgroup.h~cgroup_disable include/linux/cgroup.h
--- linux-2.6.25-rc4/include/linux/cgroup.h~cgroup_disable	2008-03-06 12:19:38.000000000 +0530
+++ linux-2.6.25-rc4-balbir/include/linux/cgroup.h	2008-03-06 12:19:38.000000000 +0530
@@ -256,6 +256,7 @@ struct cgroup_subsys {
 	void (*bind)(struct cgroup_subsys *ss, struct cgroup *root);
 	int subsys_id;
 	int active;
+	int disabled;
 	int early_init;
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
diff -puN kernel/cgroup.c~cgroup_disable kernel/cgroup.c
--- linux-2.6.25-rc4/kernel/cgroup.c~cgroup_disable	2008-03-06 12:19:38.000000000 +0530
+++ linux-2.6.25-rc4-balbir/kernel/cgroup.c	2008-03-06 12:19:38.000000000 +0530
@@ -782,7 +782,14 @@ static int parse_cgroupfs_options(char *
 		if (!*token)
 			return -EINVAL;
 		if (!strcmp(token, "all")) {
-			opts->subsys_bits = (1 << CGROUP_SUBSYS_COUNT) - 1;
+			/* Add all non-disabled subsystems */
+			int i;
+			opts->subsys_bits = 0;
+			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+				struct cgroup_subsys *ss = subsys[i];
+				if (!ss->disabled)
+					opts->subsys_bits |= 1ul << i;
+			}
 		} else if (!strcmp(token, "noprefix")) {
 			set_bit(ROOT_NOPREFIX, &opts->flags);
 		} else if (!strncmp(token, "release_agent=", 14)) {
@@ -800,7 +807,8 @@ static int parse_cgroupfs_options(char *
 			for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 				ss = subsys[i];
 				if (!strcmp(token, ss->name)) {
-					set_bit(i, &opts->subsys_bits);
+					if (!ss->disabled)
+						set_bit(i, &opts->subsys_bits);
 					break;
 				}
 			}
@@ -2604,6 +2612,8 @@ static int proc_cgroupstats_show(struct 
 	mutex_lock(&cgroup_mutex);
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
+		if (ss->disabled)
+			continue;
 		seq_printf(m, "%s\t%lu\t%d\n",
 			   ss->name, ss->root->subsys_bits,
 			   ss->root->number_of_cgroups);
@@ -3010,3 +3020,16 @@ static void cgroup_release_agent(struct 
 	spin_unlock(&release_list_lock);
 	mutex_unlock(&cgroup_mutex);
 }
+
+static int __init cgroup_disable(char *str)
+{
+	int i;
+	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+		struct cgroup_subsys *ss = subsys[i];
+		if (!strcmp(str, ss->name)) {
+			ss->disabled = 1;
+			break;
+		}
+	}
+}
+__setup("cgroup_disable=", cgroup_disable);
diff -puN Documentation/kernel-parameters.txt~cgroup_disable Documentation/kernel-parameters.txt
--- linux-2.6.25-rc4/Documentation/kernel-parameters.txt~cgroup_disable	2008-03-06 17:57:32.000000000 +0530
+++ linux-2.6.25-rc4-balbir/Documentation/kernel-parameters.txt	2008-03-06 18:00:32.000000000 +0530
@@ -383,6 +383,10 @@ and is between 256 and 4096 characters. 
 	ccw_timeout_log [S390]
 			See Documentation/s390/CommonIO for details.
 
+	cgroup_disable= [KNL] Enable disable a particular controller
+			Format: {name of the controller}
+			See /proc/cgroups for a list of compiled controllers
+
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
 			See security/selinux/Kconfig help text.
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
