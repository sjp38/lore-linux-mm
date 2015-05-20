Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EC0CB6B010E
	for <linux-mm@kvack.org>; Wed, 20 May 2015 08:50:53 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so51817109wgj.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 05:50:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fi8si3667025wib.10.2015.05.20.05.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 05:50:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] mm, memcg: Optionally disable memcg by default using Kconfig
Date: Wed, 20 May 2015 13:50:45 +0100
Message-Id: <1432126245-10908-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1432126245-10908-1-git-send-email-mgorman@suse.de>
References: <1432126245-10908-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Linux-CGroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

memcg was reported years ago to have significant overhead when unused. It
has improved but it's still the case that users that have no knowledge of
memcg pay a small performance penalty.

This patch adds a Kconfig that controls whether memcg is enabled by default
and a kernel parameter cgroup_enable= to enable it if desired. Anyone using
oldconfig will get the historical behaviour. It is not an option for most
distributions to simply disable MEMCG as there are users that require it
but they should also be knowledgable enough to use cgroup_enable=.

This was evaluated using aim9, a page fault microbenchmark and ebizzy
but I'll focus on the page fault microbenchmark. It can be reproduced
using pft from mmtests (https://github.com/gormanm/mmtests).  Edit
configs/config-global-dhp__pagealloc-performance and update MMTESTS to
only contain pft. This is the relevant part of the profile summary

/usr/src/linux-4.0-chargefirst-v2r1/mm/memcontrol.c                  3.7907   223277
  __mem_cgroup_count_vm_event                                                  1.143%    67312
  mem_cgroup_page_lruvec                                                       0.465%    27403
  mem_cgroup_commit_charge                                                     0.381%    22452
  uncharge_list                                                                0.332%    19543
  mem_cgroup_update_lru_size                                                   0.284%    16704
  get_mem_cgroup_from_mm                                                       0.271%    15952
  mem_cgroup_try_charge                                                        0.237%    13982
  memcg_check_events                                                           0.222%    13058
  mem_cgroup_charge_statistics.isra.22                                         0.185%    10920
  commit_charge                                                                0.140%     8235
  try_charge                                                                   0.131%     7716

It's showing 3.79% overhead in memcontrol.c when no memcgs are in
use. Applying the patch and disabling memcg reduces this to 0.51%

/usr/src/linux-4.0-disable-v2r1/mm/memcontrol.c                      0.5100    29304
  mem_cgroup_page_lruvec                                                       0.161%     9267
  mem_cgroup_update_lru_size                                                   0.154%     8872
  mem_cgroup_try_charge                                                        0.153%     8768
  mem_cgroup_commit_charge                                                     0.042%     2397

pft faults
                                       4.0.0                  4.0.0
                                 chargefirst                disable
Hmean    faults/cpu-1 1509075.7561 (  0.00%) 1508934.4568 ( -0.01%)
Hmean    faults/cpu-3 1339160.7113 (  0.00%) 1379512.0698 (  3.01%)
Hmean    faults/cpu-5  874174.1255 (  0.00%)  875741.7674 (  0.18%)
Hmean    faults/cpu-7  601370.9977 (  0.00%)  599938.2026 ( -0.24%)
Hmean    faults/cpu-8  510598.8214 (  0.00%)  510663.5402 (  0.01%)
Hmean    faults/sec-1 1497935.5274 (  0.00%) 1496585.7400 ( -0.09%)
Hmean    faults/sec-3 3941920.1520 (  0.00%) 4050811.9259 (  2.76%)
Hmean    faults/sec-5 3869385.7553 (  0.00%) 3922299.6112 (  1.37%)
Hmean    faults/sec-7 3992181.4189 (  0.00%) 3988511.0065 ( -0.09%)
Hmean    faults/sec-8 3986452.2204 (  0.00%) 3977706.7883 ( -0.22%)

Low thread counts get a small boost but it's within noise as memcg overhead
does not dominate. It's not obvious at all at higher thread counts as other
factors cause more problems. The overall breakdown of CPU usage looks like

               4.0.0       4.0.0
        chargefirst-v2r1disable-v2r1
User           41.81       41.45
System        407.64      405.50
Elapsed       128.17      127.06

Despite the relative unimportance, there is at least some justification
for disabling memcg by default.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/kernel-parameters.txt |  4 ++++
 init/Kconfig                        | 15 +++++++++++++++
 kernel/cgroup.c                     | 20 ++++++++++++++++----
 mm/memcontrol.c                     |  3 +++
 4 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index bfcb1a62a7b4..4f264f906816 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -591,6 +591,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			cut the overhead, others just disable the usage. So
 			only cgroup_disable=memory is actually worthy}
 
+	cgroup_enable= [KNL] Enable a particular controller
+			Similar to cgroup_disable except that it enables
+			controllers that are disabled by default.
+
 	checkreqprot	[SELINUX] Set initial checkreqprot flag value.
 			Format: { "0" | "1" }
 			See security/selinux/Kconfig help text.
diff --git a/init/Kconfig b/init/Kconfig
index f5dbc6d4261b..819b6cc05cba 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -990,6 +990,21 @@ config MEMCG
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
 
+config MEMCG_DEFAULT_ENABLED
+	bool "Automatically enable memory resource controller"
+	default y
+	depends on MEMCG
+	help
+	  The memory controller has some overhead even if idle as resource
+	  usage must be tracked in case a group is created and a process
+	  migrated. As users may not be aware of this and the cgroup_disable=
+	  option, this config option controls whether it is enabled by
+	  default. It is assumed that someone that requires the controller
+	  can find the cgroup_enable= switch.
+
+	  Say N if unsure. This is default Y to preserve oldconfig and
+	  historical behaviour.
+
 config MEMCG_SWAP
 	bool "Memory Resource Controller Swap Extension"
 	depends on MEMCG && SWAP
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 29a7b2cc593e..0e79db55bf1a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5370,7 +5370,7 @@ out_free:
 	kfree(pathbuf);
 }
 
-static int __init cgroup_disable(char *str)
+static int __init __cgroup_set_state(char *str, bool disabled)
 {
 	struct cgroup_subsys *ss;
 	char *token;
@@ -5382,16 +5382,28 @@ static int __init cgroup_disable(char *str)
 
 		for_each_subsys(ss, i) {
 			if (!strcmp(token, ss->name)) {
-				ss->disabled = 1;
-				printk(KERN_INFO "Disabling %s control group"
-					" subsystem\n", ss->name);
+				ss->disabled = disabled;
+				printk(KERN_INFO "Setting %s control group"
+					" subsystem %s\n", ss->name,
+					disabled ? "disabled" : "enabled");
 				break;
 			}
 		}
 	}
 	return 1;
 }
+
+static int __init cgroup_disable(char *str)
+{
+	return __cgroup_set_state(str, true);
+}
+
+static int __init cgroup_enable(char *str)
+{
+	return __cgroup_set_state(str, false);
+}
 __setup("cgroup_disable=", cgroup_disable);
+__setup("cgroup_enable=", cgroup_enable);
 
 static int __init cgroup_set_legacy_files_on_dfl(char *str)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b34ef4a32a3b..ce171ba16949 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5391,6 +5391,9 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.dfl_cftypes = memory_files,
 	.legacy_cftypes = mem_cgroup_legacy_files,
 	.early_init = 0,
+#ifndef CONFIG_MEMCG_DEFAULT_ENABLED
+	.disabled = 1,
+#endif
 };
 
 /**
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
