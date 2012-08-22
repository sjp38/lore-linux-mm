Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 265A96B009E
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:19 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 27/36] autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
Date: Wed, 22 Aug 2012 16:59:11 +0200
Message-Id: <1345647560-30387-28-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Add the config options to allow building the kernel with AutoNUMA.

If CONFIG_AUTONUMA_DEFAULT_ENABLED is "=y", then
/sys/kernel/mm/autonuma/enabled will be equal to 1, and AutoNUMA will
be enabled automatically at boot.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/Kconfig     |    3 +++
 arch/x86/Kconfig |    1 +
 mm/Kconfig       |   17 +++++++++++++++++
 3 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 72f2fa1..ee3ed89 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -281,4 +281,7 @@ config SECCOMP_FILTER
 
 	  See Documentation/prctl/seccomp_filter.txt for details.
 
+config HAVE_ARCH_AUTONUMA
+	bool
+
 source "kernel/gcov/Kconfig"
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8ec3a1a..4cbdfce 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -97,6 +97,7 @@ config X86
 	select KTIME_SCALAR if X86_32
 	select GENERIC_STRNCPY_FROM_USER
 	select GENERIC_STRNLEN_USER
+	select HAVE_ARCH_AUTONUMA
 
 config INSTRUCTION_DECODER
 	def_bool (KPROBES || PERF_EVENTS || UPROBES)
diff --git a/mm/Kconfig b/mm/Kconfig
index d5c8019..f00a0cd 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -211,6 +211,23 @@ config MIGRATION
 	  pages as migration can relocate pages to satisfy a huge page
 	  allocation instead of reclaiming.
 
+config AUTONUMA
+	bool "AutoNUMA"
+	select MIGRATION
+	depends on NUMA && HAVE_ARCH_AUTONUMA
+	help
+	  Automatic NUMA CPU scheduling and memory migration.
+
+	  Avoids the administrator to manually setup hard NUMA
+	  bindings in order to achieve optimal performance on NUMA
+	  hardware.
+
+config AUTONUMA_DEFAULT_ENABLED
+	bool "Auto NUMA default enabled"
+	depends on AUTONUMA
+	help
+	  Automatic NUMA CPU scheduling and memory migration enabled at boot.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
