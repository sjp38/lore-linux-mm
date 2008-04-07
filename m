From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [-mm] Disable the memory controller by default (v2)
Date: Mon, 07 Apr 2008 18:32:15 +0530
Message-ID: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758675AbYDGNDn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org



Changelog v1

1. Split cgroup_disable into cgroup_disable and cgroup_enable
2. Remove cgroup_toggle

Due to the overhead of the memory controller. The
memory controller is now disabled by default. This patch adds cgroup_enable.

If everyone agrees on this approach and likes it, should we push this
into 2.6.25?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/kernel-parameters.txt |    3 +++
 kernel/cgroup.c                     |   28 ++++++++++++++++++++++++++--
 mm/memcontrol.c                     |    1 +
 3 files changed, 30 insertions(+), 2 deletions(-)

diff -puN kernel/cgroup.c~memory-controller-default-option-off kernel/cgroup.c
--- linux-2.6.25-rc8/kernel/cgroup.c~memory-controller-default-option-off	2008-04-07 16:24:28.000000000 +0530
+++ linux-2.6.25-rc8-balbir/kernel/cgroup.c	2008-04-07 18:30:31.000000000 +0530
@@ -3077,8 +3077,8 @@ static int __init cgroup_disable(char *s
 
 			if (!strcmp(token, ss->name)) {
 				ss->disabled = 1;
-				printk(KERN_INFO "Disabling %s control group"
-					" subsystem\n", ss->name);
+				printk(KERN_INFO "%s control group "
+						"is disabled\n", ss->name);
 				break;
 			}
 		}
@@ -3086,3 +3086,27 @@ static int __init cgroup_disable(char *s
 	return 1;
 }
 __setup("cgroup_disable=", cgroup_disable);
+
+static int __init cgroup_enable(char *str)
+{
+	int i;
+	char *token;
+
+	while ((token = strsep(&str, ",")) != NULL) {
+		if (!*token)
+			continue;
+
+		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
+			struct cgroup_subsys *ss = subsys[i];
+
+			if (!strcmp(token, ss->name)) {
+				ss->disabled = 0;
+				printk(KERN_INFO "%s control group "
+						"is enabled\n", ss->name);
+				break;
+			}
+		}
+	}
+	return 1;
+}
+__setup("cgroup_enable=", cgroup_enable);
diff -puN mm/memcontrol.c~memory-controller-default-option-off mm/memcontrol.c
--- linux-2.6.25-rc8/mm/memcontrol.c~memory-controller-default-option-off	2008-04-07 16:24:28.000000000 +0530
+++ linux-2.6.25-rc8-balbir/mm/memcontrol.c	2008-04-07 16:40:22.000000000 +0530
@@ -1104,4 +1104,5 @@ struct cgroup_subsys mem_cgroup_subsys =
 	.populate = mem_cgroup_populate,
 	.attach = mem_cgroup_move_task,
 	.early_init = 0,
+	.disabled = 1,
 };
diff -puN Documentation/kernel-parameters.txt~memory-controller-default-option-off Documentation/kernel-parameters.txt
--- linux-2.6.25-rc8/Documentation/kernel-parameters.txt~memory-controller-default-option-off	2008-04-07 16:38:25.000000000 +0530
+++ linux-2.6.25-rc8-balbir/Documentation/kernel-parameters.txt	2008-04-07 17:53:28.000000000 +0530
@@ -382,8 +382,11 @@ and is between 256 and 4096 characters. 
 			See Documentation/s390/CommonIO for details.
 
 	cgroup_disable= [KNL] Disable a particular controller
+	cgroup_enable=  [KNL] Enable a particular controller
+			For both cgroup_enable and cgroup_enable
 			Format: {name of the controller(s) to disable}
 				{Currently supported controllers - "memory"}
+				{Memory controller is disabled by default}
 
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
