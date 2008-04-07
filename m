From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [-mm] Disable the memory controller by default
Date: Mon, 07 Apr 2008 17:21:37 +0530
Message-ID: <20080407115137.24124.59692.sendpatchset@localhost.localdomain>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757672AbYDGLxJ@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org



Due to the overhead of the memory controller. The
memory controller is now disabled by default. This patch changes
cgroup_disable to cgroup_toggle, so that each controller can decide
whether it wants to be enabled/disabled by default.

If everyone agrees on this approach and likes it, should we push this
into 2.6.25?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 Documentation/kernel-parameters.txt |    5 +++--
 kernel/cgroup.c                     |   11 ++++++-----
 mm/memcontrol.c                     |    1 +
 3 files changed, 10 insertions(+), 7 deletions(-)

diff -puN kernel/cgroup.c~memory-controller-default-option-off kernel/cgroup.c
--- linux-2.6.25-rc8/kernel/cgroup.c~memory-controller-default-option-off	2008-04-07 16:24:28.000000000 +0530
+++ linux-2.6.25-rc8-balbir/kernel/cgroup.c	2008-04-07 16:47:48.000000000 +0530
@@ -3063,7 +3063,7 @@ static void cgroup_release_agent(struct 
 	mutex_unlock(&cgroup_mutex);
 }
 
-static int __init cgroup_disable(char *str)
+static int __init cgroup_toggle(char *str)
 {
 	int i;
 	char *token;
@@ -3076,13 +3076,14 @@ static int __init cgroup_disable(char *s
 			struct cgroup_subsys *ss = subsys[i];
 
 			if (!strcmp(token, ss->name)) {
-				ss->disabled = 1;
-				printk(KERN_INFO "Disabling %s control group"
-					" subsystem\n", ss->name);
+				ss->disabled = !ss->disabled;
+				if (ss->disabled)
+					printk(KERN_INFO "%s control group "
+						"is disabled", ss->name);
 				break;
 			}
 		}
 	}
 	return 1;
 }
-__setup("cgroup_disable=", cgroup_disable);
+__setup("cgroup_toggle=", cgroup_toggle);
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
+++ linux-2.6.25-rc8-balbir/Documentation/kernel-parameters.txt	2008-04-07 17:20:08.000000000 +0530
@@ -381,9 +381,10 @@ and is between 256 and 4096 characters. 
 	ccw_timeout_log [S390]
 			See Documentation/s390/CommonIO for details.
 
-	cgroup_disable= [KNL] Disable a particular controller
-			Format: {name of the controller(s) to disable}
+	cgroup_toggle= [KNL] Toggle (enable/disable) a particular controller
+			Format: {name of the controller(s) to enable/disable}
 				{Currently supported controllers - "memory"}
+				{The memory controller is disabled by default}
 
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
