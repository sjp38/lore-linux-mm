Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id EAF246B0098
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:17 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 34/36] autonuma: make the AUTONUMA_SCAN_PMD_FLAG conditional to CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
Date: Wed, 22 Aug 2012 16:59:18 +0200
Message-Id: <1345647560-30387-35-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Remove the sysfs entry /sys/kernel/mm/autonuma/knuma_scand/pmd and
force the knuma_scand pmd mode off if
CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD is not set by the architecture.

Enable AutoNUMA for PPC64.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/Kconfig         |    3 +++
 arch/powerpc/Kconfig |    6 ++++++
 arch/x86/Kconfig     |    1 +
 mm/autonuma.c        |    9 ++++++++-
 4 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index ee3ed89..6f4f19f 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -284,4 +284,7 @@ config SECCOMP_FILTER
 config HAVE_ARCH_AUTONUMA
 	bool
 
+config HAVE_ARCH_AUTONUMA_SCAN_PMD
+	bool
+
 source "kernel/gcov/Kconfig"
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 352f416..73fa908 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -140,6 +140,12 @@ config PPC
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 
+# allow AutoNUMA only on PPC64 for now
+config PPC_HAVE_ARCH_AUTONUMA
+	bool
+	default y if PPC64
+	select HAVE_ARCH_AUTONUMA
+
 config EARLY_PRINTK
 	bool
 	default y
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4cbdfce..f24bff8 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -98,6 +98,7 @@ config X86
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
 	select HAVE_ARCH_AUTONUMA
+	select HAVE_ARCH_AUTONUMA_SCAN_PMD
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS || UPROBES)
diff --git a/mm/autonuma.c b/mm/autonuma.c
index a4da3f3..4b7c744 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -25,7 +25,10 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
 	|(1<<AUTONUMA_ENABLED_FLAG)
 #endif
-	|(0<<AUTONUMA_SCAN_PMD_FLAG);
+#ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
+	|(1<<AUTONUMA_SCAN_PMD_FLAG)
+#endif
+	;
 
 static DEFINE_MUTEX(knumad_mm_mutex);
 
@@ -1300,7 +1303,9 @@ static ssize_t NAME ## _store(struct kobject *kobj,			\
 static struct kobj_attribute NAME ## _attr =				\
 	__ATTR(NAME, 0644, NAME ## _show, NAME ## _store);
 
+#ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
 SYSFS_ENTRY(pmd, AUTONUMA_SCAN_PMD_FLAG);
+#endif /* CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD */
 SYSFS_ENTRY(debug, AUTONUMA_DEBUG_FLAG);
 #ifdef CONFIG_DEBUG_VM
 SYSFS_ENTRY(load_balance_strict, AUTONUMA_SCHED_LOAD_BALANCE_STRICT_FLAG);
@@ -1398,7 +1403,9 @@ static struct attribute *knuma_scand_attr[] = {
 	&pages_to_scan_attr.attr,
 	&pages_scanned_attr.attr,
 	&full_scans_attr.attr,
+#ifdef CONFIG_HAVE_ARCH_AUTONUMA_SCAN_PMD
 	&pmd_attr.attr,
+#endif
 	NULL,
 };
 static struct attribute_group knuma_scand_attr_group = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
