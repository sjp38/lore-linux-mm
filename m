Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 249A76B00A0
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 01:33:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 43CBF3EE0C3
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:33:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A06D45DEBA
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:33:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A1DB45DEB5
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:33:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E124D1DB8041
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:33:29 +0900 (JST)
Received: from g01jpexchkw10.g01.fujitsu.local (g01jpexchkw10.g01.fujitsu.local [10.0.194.49])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95D411DB803C
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 14:33:29 +0900 (JST)
Message-ID: <50501E97.2020200@jp.fujitsu.com>
Date: Wed, 12 Sep 2012 14:33:11 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: hot-added cpu is not asiggned to the correct node
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When I hot-added CPUs and memories simultaneously using container driver,
all the hot-added CPUs were mistakenly assigned to node0.

Accoding to my DSDT, hot-added CPUs and memorys have PXM#1. So in my system,
these devices should be assigned to node1 as follows:

--- Expected result
ls /sys/devices/system/node/node1/:
cpu16 cpu17 cpu18 cpu19 cpu20 cpu21 cpu22 cpu23 cpu24 cpu25 cpu26 cpu27
cpu28 cpu29 cpu30 cpu31 cpulist ... memory512 memory513 - 767 meminfo ...

=> hot-added CPUs and memorys are assigned to same node.
---

But in actuality, the CPUs were assigned to node0 and the memorys were assigned
to node1 as follows:

--- Actual result
ls /sys/devices/system/node/node0/:
cpu0 cpu1 cpu2 cpu3 cpu4 cpu5 cpu6 cpu7 cpu8 cpu9 cpu10 cpu11 cpu12 cpu13
cpu14 cpu15 cpu16 cpu17 cpu18 cpu19 cpu20 cpu21 cpu22 cpu23 cpu24 cpu25 cpu26
cpu27 cpu28 cpu29 cpu30 cpu31 cpulist ... memory1 memory2 - 255 meminfo ...

ls /sys/devices/system/node/node1/:
cpulist memory512 memory513 - 767 meminfo ...

=> hot-added CPUs are assinged to node0 and hot-added memorys are assigned to
   node1. CPUs and memorys has same PXM#. But assigned node is different.
---

In my investigation, "acpi_map_cpu2node()" causes the problem.

---
#arch/x86/kernel/acpi/boot.c"
static void __cpuinit acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
 {
 #ifdef CONFIG_ACPI_NUMA
   int nid;

   nid = acpi_get_node(handle);
   if (nid == -1 || !node_online(nid))
           return;
   set_apicid_to_node(physid, nid);
   numa_set_node(cpu, nid);
 #endif
 }
---

In my DSDT, CPUs were written ahead of memories, so CPUs were hot-added
before memories. Thus the system has memory-less-node temporarily .
In this case, "node_online()" fails. So the CPU is assigned to node 0.

When I wrote memories ahead of CPUs in DSDT, the CPUs were assigned to the
correct node. In current Linux, the CPUs were assigned to the correct node
or not depends on the order of hot-added resources in DSDT.

ACPI specification doesn't define the order of hot-added resources. So I think
the kernel should properly handle any DSDT conformable to its specification.

I'm thinking a solution about the problem, but I don't have any good idea...
Does anyone has opinion how we should treat it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
