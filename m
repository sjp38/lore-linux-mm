Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 355376B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 17:46:00 -0400 (EDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] mm/hotplug, x86: Disable ARCH_MEMORY_PROBE by default
Date: Wed, 17 Jul 2013 15:45:03 -0600
Message-Id: <1374097503-25515-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com, Toshi Kani <toshi.kani@hp.com>

CONFIG_ARCH_MEMORY_PROBE enables /sys/devices/system/memory/probe
interface, which allows a given memory address to be hot-added as
follows. (See Documentation/memory-hotplug.txt for more detail.)

# echo start_address_of_new_memory > /sys/devices/system/memory/probe

This probe interface is required on powerpc. On x86, however, ACPI
notifies a memory hotplug event to the kernel, which performs its
hotplug operation as the result. Therefore, users should not be
required to use this interface on x86. This probe interface is also
error-prone that the kernel blindly adds a given memory address
without checking if the memory is present on the system; no probing
is done despite of its name. The kernel crashes when a user requests
to online a memory block that is not present on the system.

This patch disables CONFIG_ARCH_MEMORY_PROBE by default on x86,
and clarifies it in Documentation/memory-hotplug.txt.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 Documentation/memory-hotplug.txt |    7 ++++---
 arch/x86/Kconfig                 |    2 +-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
index 8e5eacb..396d871 100644
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -214,9 +214,10 @@ In some environments, especially virtualized environment, firmware will not
 notify memory hotplug event to the kernel. For such environment, "probe"
 interface is supported. This interface depends on CONFIG_ARCH_MEMORY_PROBE.
 
-Now, CONFIG_ARCH_MEMORY_PROBE is supported only by powerpc but it does not
-contain highly architecture codes. Please add config if you need "probe"
-interface.
+CONFIG_ARCH_MEMORY_PROBE is supported on powerpc only. On x86, this config
+option is disabled by default since ACPI notifies a memory hotplug event to
+the kernel, which performs its hotplug operation as the result. Please
+enable this option if you need the "probe" interface on x86.
 
 Probe interface is located at
 /sys/devices/system/memory/probe
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index b32ebf9..0729682 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1344,7 +1344,7 @@ config ARCH_SELECT_MEMORY_MODEL
 	depends on ARCH_SPARSEMEM_ENABLE
 
 config ARCH_MEMORY_PROBE
-	def_bool y
+	def_bool n
 	depends on X86_64 && MEMORY_HOTPLUG
 
 config ARCH_PROC_KCORE_TEXT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
