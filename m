Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3DE296B021C
	for <linux-mm@kvack.org>; Thu, 13 May 2010 08:08:11 -0400 (EDT)
Date: Thu, 13 May 2010 20:03:52 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: [RFC, 7/7] NUMA hotplug emulator
Message-ID: <20100513120352.GH2169@shaohui>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="TmwHKJoIRFM7Mu/A"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Randy Dunlap <rdunlap@xenotime.net>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, ak@linux.intel.com, fengguang.wu@intel.com, haicheng.li@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>


--TmwHKJoIRFM7Mu/A
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Doc/x86_64: documentation of NUMA hotplug emulator

add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
to explain the usage for the hotplug emulator.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
diff --git a/Documentation/x86/x86_64/numa_hotplug_emulator.txt b/Documentation/x86/x86_64/numa_hotplug_emulator.txt
new file mode 100644
index 0000000..e65ecfe
--- /dev/null
+++ b/Documentation/x86/x86_64/numa_hotplug_emulator.txt
@@ -0,0 +1,85 @@
+NUMA Hotplug Emulator for x86
+---------------------------------------------------
+
+NUMA hotplug emulator is able to emulate NUMA Node Hotplug
+thru a pure software way. It intends to help people easily debug
+and test node/cpu/memory hotplug related stuff on a
+none-numa-hotplug-support machine, even a UMA machine and virtual
+environment.
+
+1) Node hotplug emulation:
+
+The emulator firstly hides RAM via E820 table, and then it can
+fake offlined nodes with the hidden RAM.
+
+After system bootup, user is able to hotplug-add these offlined
+nodes, which is just similar to a real hotplug hardware behavior.
+
+Using boot option "numa=hide=N*size" to fake offlined nodes:
+	- N is the number of hidden nodes
+	- size is the memory size (in MB) per hidden node.
+
+There is a sysfs entry "probe" under /sys/devices/system/node/ for user
+to hotplug the fake offlined nodes:
+
+ - to show all fake offlined nodes:
+    $ cat /sys/devices/system/node/probe
+
+ - to hotadd a fake offlined node, e.g. nodeid is N:
+    $ echo N > /sys/devices/system/node/probe
+
+2) CPU hotplug emulation:
+
+The emulator reserve CPUs throu grub parameter, the reserved CPUs can be
+hot-add/hot-remove in software method, it emulates the procuess of physical
+cpu hotplug.
+
+ - to hide CPUs
+	- Using boot option "maxcpus=N" hide CPUs
+	  N is the number of initialize CPUs
+	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation
+      when cpu_hpe is enabled, the rest CPUs will not be initialized 
+
+ - to hot-add CPU to node
+	$ echo nid > cpu/probe
+
+ - to hot-remove CPU
+	$ echo nid > cpu/release
+
+3) Memory hotplug emulation:
+
+The emulator reserve memory before OS booting, the reserved memory region
+is remove from e820 table, and they can be hot-added via the probe interface,
+this interface was extend to support add memory to the specified node, It
+maintains backwards compatibility.
+
+The difficulty of Memory Release is well-known, we have no plan for it until now.
+
+ - reserve memory throu grub parameter
+ 	mem=1024m
+
+ - add a memory section to node 3
+    $ echo 0x40000000,3 > memory/probe
+	OR
+    $ echo 1024m,3 > memory/probe
+
+4) Script for hotplug testing
+
+These scripts provides convenience when we hot-add memory/cpu in batch.
+
+- Online all pages:
+for m in /sys/devices/system/memory/memory*;
+do 
+	echo online > $m/state;
+done
+
+- CPU Online:
+for c in /sys/devices/system/cpu/cpu*;
+do 
+	echo 1 > $c/online;
+done
+
+- Haicheng Li <haicheng.li@linux.intel.com>
+- Shaohui Zheng <shaohui.zheng@intel.com>
+  May 2010
+
-- 
Thanks & Regards,
Shaohui


--TmwHKJoIRFM7Mu/A
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="007-hotplug-emulator-doc-x86_64-of-numa-hotplug-emulator.patch"

Doc/x86_64: documentation of NUMA hotplug emulator

add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
to explain the usage for the hotplug emulator.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
---
diff --git a/Documentation/x86/x86_64/numa_hotplug_emulator.txt b/Documentation/x86/x86_64/numa_hotplug_emulator.txt
new file mode 100644
index 0000000..e65ecfe
--- /dev/null
+++ b/Documentation/x86/x86_64/numa_hotplug_emulator.txt
@@ -0,0 +1,85 @@
+NUMA Hotplug Emulator for x86
+---------------------------------------------------
+
+NUMA hotplug emulator is able to emulate NUMA Node Hotplug
+thru a pure software way. It intends to help people easily debug
+and test node/cpu/memory hotplug related stuff on a
+none-numa-hotplug-support machine, even a UMA machine and virtual
+environment.
+
+1) Node hotplug emulation:
+
+The emulator firstly hides RAM via E820 table, and then it can
+fake offlined nodes with the hidden RAM.
+
+After system bootup, user is able to hotplug-add these offlined
+nodes, which is just similar to a real hotplug hardware behavior.
+
+Using boot option "numa=hide=N*size" to fake offlined nodes:
+	- N is the number of hidden nodes
+	- size is the memory size (in MB) per hidden node.
+
+There is a sysfs entry "probe" under /sys/devices/system/node/ for user
+to hotplug the fake offlined nodes:
+
+ - to show all fake offlined nodes:
+    $ cat /sys/devices/system/node/probe
+
+ - to hotadd a fake offlined node, e.g. nodeid is N:
+    $ echo N > /sys/devices/system/node/probe
+
+2) CPU hotplug emulation:
+
+The emulator reserve CPUs throu grub parameter, the reserved CPUs can be
+hot-add/hot-remove in software method, it emulates the procuess of physical
+cpu hotplug.
+
+ - to hide CPUs
+	- Using boot option "maxcpus=N" hide CPUs
+	  N is the number of initialize CPUs
+	- Using boot option "cpu_hpe=on" to enable cpu hotplug emulation
+      when cpu_hpe is enabled, the rest CPUs will not be initialized 
+
+ - to hot-add CPU to node
+	$ echo nid > cpu/probe
+
+ - to hot-remove CPU
+	$ echo nid > cpu/release
+
+3) Memory hotplug emulation:
+
+The emulator reserve memory before OS booting, the reserved memory region
+is remove from e820 table, and they can be hot-added via the probe interface,
+this interface was extend to support add memory to the specified node, It
+maintains backwards compatibility.
+
+The difficulty of Memory Release is well-known, we have no plan for it until now.
+
+ - reserve memory throu grub parameter
+ 	mem=1024m
+
+ - add a memory section to node 3
+    $ echo 0x40000000,3 > memory/probe
+	OR
+    $ echo 1024m,3 > memory/probe
+
+4) Script for hotplug testing
+
+These scripts provides convenience when we hot-add memory/cpu in batch.
+
+- Online all pages:
+for m in /sys/devices/system/memory/memory*;
+do 
+	echo online > $m/state;
+done
+
+- CPU Online:
+for c in /sys/devices/system/cpu/cpu*;
+do 
+	echo 1 > $c/online;
+done
+
+- Haicheng Li <haicheng.li@linux.intel.com>
+- Shaohui Zheng <shaohui.zheng@intel.com>
+  May 2010
+

--TmwHKJoIRFM7Mu/A--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
