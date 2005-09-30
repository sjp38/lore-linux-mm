From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073248.10631.19432.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 03/07] cpuset: smp or numa
Date: Fri, 30 Sep 2005 16:33:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Magnus Damm <magnus@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch for makes it possible to compile and use CONFIG_CPUSETS without 
CONFIG_SMP. Useful for NUMA emulation on real or emulated UP hardware.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 init/Kconfig    |    2 +-
 kernel/cpuset.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

--- from-0002/init/Kconfig
+++ to-work/init/Kconfig	2005-09-28 17:07:31.000000000 +0900
@@ -245,7 +245,7 @@ config IKCONFIG_PROC
 
 config CPUSETS
 	bool "Cpuset support"
-	depends on SMP
+	depends on SMP || NUMA
 	help
 	  This option will let you create and manage CPUSETs which
 	  allow dynamically partitioning a system into sets of CPUs and
--- from-0002/kernel/cpuset.c
+++ to-work/kernel/cpuset.c	2005-09-28 17:07:31.000000000 +0900
@@ -657,6 +657,7 @@ static int validate_change(const struct 
 
 static void update_cpu_domains(struct cpuset *cur)
 {
+#ifdef CONFIG_SMP
 	struct cpuset *c, *par = cur->parent;
 	cpumask_t pspan, cspan;
 
@@ -694,6 +695,7 @@ static void update_cpu_domains(struct cp
 	lock_cpu_hotplug();
 	partition_sched_domains(&pspan, &cspan);
 	unlock_cpu_hotplug();
+#endif
 }
 
 static int update_cpumask(struct cpuset *cs, char *buf)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
