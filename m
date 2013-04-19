Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 7E87C6B0072
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 01:23:53 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4613E3EE0C1
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 14:23:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 536D545DE52
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 14:23:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5612545DE54
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 14:23:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 40A531DB8038
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 14:23:49 +0900 (JST)
Received: from g01jpexchyt35.g01.fujitsu.local (g01jpexchyt35.g01.fujitsu.local [10.128.193.50])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D78121DB8040
	for <linux-mm@kvack.org>; Fri, 19 Apr 2013 14:23:48 +0900 (JST)
Message-ID: <5170D4CB.20900@jp.fujitsu.com>
Date: Fri, 19 Apr 2013 14:23:23 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Bug fix PATCH v2] numa, cpu hotplug: Change links of CPU and node
 when changing node number by onlining CPU
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com, mingo@kernel.org, hpa@zytor.com, srivatsa.bhat@linux.vnet.ibm.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

When booting x86 system contains memoryless node, node numbers of CPUs
on memoryless node were changed to nearest online node number by
init_cpu_to_node() because the node is not online.

In my system, node numbers of cpu#30-44 and 75-89 were changed from 2 to 0
as follows:

$ numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 30 31 32 33 34 35 36 37 38 39 40
41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 75 76 77 78 79 80 81 82
83 84 85 86 87 88 89
node 0 size: 32394 MB
node 0 free: 27898 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 60 61 62 63 64 65 66
67 68 69 70 71 72 73 74
node 1 size: 32768 MB
node 1 free: 30335 MB

If we hot add memory to memoryless node and offine/online all CPUs on
the node, node numbers of these CPUs are changed to correct node numbers
by srat_detect_node() because the node become online.

In this case, node numbers of cpu#30-44 and 75-89 were changed from 0 to 2
in my system as follows:

$ numactl --hardware
available: 3 nodes (0-2)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 45 46 47 48 49 50 51 52 53 54 55
56 57 58 59
node 0 size: 32394 MB
node 0 free: 27218 MB
node 1 cpus: 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 60 61 62 63 64 65 66
67 68 69 70 71 72 73 74
node 1 size: 32768 MB
node 1 free: 30014 MB
node 2 cpus: 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 75 76 77 78 79 80 81
82 83 84 85 86 87 88 89
node 2 size: 16384 MB
node 2 free: 16384 MB

But "cpu to node" and "node to cpu" links were not changed as follows:

$ ls /sys/devices/system/cpu/cpu30/|grep node
node0
$ ls /sys/devices/system/node/node0/|grep cpu30
cpu30

"numactl --hardware" shows that cpu30 belongs to node 2. But sysfs links
does  not change.

This patch changes "cpu to node" and "node to cpu" links when node number
changed by onlining CPU.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
---
v2:
Change argument's name from num to cpuid in store_online()
Add comments for explaining why node number change
---
 drivers/base/cpu.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index fb10728..229d6e7 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -25,6 +25,15 @@ EXPORT_SYMBOL_GPL(cpu_subsys);
 static DEFINE_PER_CPU(struct device *, cpu_sys_devices);
 
 #ifdef CONFIG_HOTPLUG_CPU
+static void change_cpu_under_node(struct cpu *cpu,
+			unsigned int from_nid, unsigned int to_nid)
+{
+	int cpuid = cpu->dev.id;
+	unregister_cpu_under_node(cpuid, from_nid);
+	register_cpu_under_node(cpuid, to_nid);
+	cpu->node_id = to_nid;
+}
+
 static ssize_t show_online(struct device *dev,
 			   struct device_attribute *attr,
 			   char *buf)
@@ -39,17 +48,29 @@ static ssize_t __ref store_online(struct device *dev,
 				  const char *buf, size_t count)
 {
 	struct cpu *cpu = container_of(dev, struct cpu, dev);
+	int cpuid = cpu->dev.id;
+	int from_nid, to_nid;
 	ssize_t ret;
 
 	cpu_hotplug_driver_lock();
 	switch (buf[0]) {
 	case '0':
-		ret = cpu_down(cpu->dev.id);
+		ret = cpu_down(cpuid);
 		if (!ret)
 			kobject_uevent(&dev->kobj, KOBJ_OFFLINE);
 		break;
 	case '1':
-		ret = cpu_up(cpu->dev.id);
+		from_nid = cpu_to_node(cpuid);
+		ret = cpu_up(cpuid);
+
+		/*
+		 * When hot adding memory to memoryless node and enabling a cpu
+		 * on the node, node number of the cpu may internally change.
+		 */
+		to_nid = cpu_to_node(cpuid);
+		if (from_nid != to_nid)
+			change_cpu_under_node(cpu, from_nid, to_nid);
+
 		if (!ret)
 			kobject_uevent(&dev->kobj, KOBJ_ONLINE);
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
