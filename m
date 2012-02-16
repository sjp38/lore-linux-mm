Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 389786B0083
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:44 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: =?UTF-8?q?=5BPATCH=2001/18=5D=20Added=20hacking=20menu=20for=20override=20optimization=20by=20GCC=2E?=
Date: Thu, 16 Feb 2012 15:31:28 +0100
Message-Id: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

From: mail@smogura.eu <mail@smogura.eu>

This patch gives ability for add some "-fno-..." options for GCC
and to force -O1 optimization. Supporting files, like Kconfig, Makefile
are auto-generated due to large amount of available options.

Patch helps to debug kernel.
---
 Makefile                           |   11 ++++
 lib/Kconfig.debug                  |    2 +
 lib/Kconfig.debug.optim            |  102 ++++++++++++++++++++++++++++++++++++
 scripts/Makefile.optim.inc         |   23 ++++++++
 scripts/debug/make_config_optim.sh |   88 +++++++++++++++++++++++++++++++
 5 files changed, 226 insertions(+), 0 deletions(-)
 create mode 100644 lib/Kconfig.debug.optim
 create mode 100644 scripts/Makefile.optim.inc
 create mode 100644 scripts/debug/make_config_optim.sh

diff --git a/Makefile b/Makefile
index 7c44b67..bc9a961 100644
--- a/Makefile
+++ b/Makefile
@@ -558,12 +558,23 @@ endif # $(dot-config)
 # Defaults to vmlinux, but the arch makefile usually adds further targets
 all: vmlinux
 
+ifdef CONFIG_HACK_OPTIM_FORCE_O1_LEVEL
+KBUILD_CFLAGS += -O1
+else
+
 ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
 KBUILD_CFLAGS	+= -Os
 else
 KBUILD_CFLAGS	+= -O2
 endif
 
+endif
+
+# Include makefile for optimization override
+ifdef CONFIG_HACK_OPTIM
+include $(srctree)/scripts/Makefile.optim.inc
+endif
+
 include $(srctree)/arch/$(SRCARCH)/Makefile
 
 ifneq ($(CONFIG_FRAME_WARN),0)
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 8745ac7..928265e 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1274,5 +1274,7 @@ source "lib/Kconfig.kgdb"
 
 source "lib/Kconfig.kmemcheck"
 
+source "lib/Kconfig.debug.optim"
+
 config TEST_KSTRTOX
 	tristate "Test kstrto*() family of functions at runtime"
diff --git a/lib/Kconfig.debug.optim b/lib/Kconfig.debug.optim
new file mode 100644
index 0000000..09b1012
--- /dev/null
+++ b/lib/Kconfig.debug.optim
@@ -0,0 +1,102 @@
+# This file was auto generated. It's utility configuration
+# Distributed under GPL v2 License
+
+menuconfig HACK_OPTIM
+	bool "Allows to override GCC optimization"
+	depends on DEBUG_KERNEL && EXPERIMENTAL
+	help
+	  If you say Y here you will be able to override
+	  how GCC optimize kernel code. This will create
+	  more debug friendly, but with not guarentee
+	  about same runi, like production, kernel.
+
+	  If you say Y here probably You will want say
+	  for all suboptions
+
+if HACK_OPTIM
+
+config HACK_OPTIM_FORCE_O1_LEVEL
+	bool "Forces -O1 optimization level"
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+config HACK_OPTIM__fno_inline_functions_called_once
+	bool "Adds -fno-inline-functions-called-once parameter to gcc invoke line."
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+config HACK_OPTIM__fno_combine_stack_adjustments
+	bool "Adds -fno-combine-stack-adjustments parameter to gcc invoke line."
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+config HACK_OPTIM__fno_tree_dce
+	bool "Adds -fno-tree-dce parameter to gcc invoke line."
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+config HACK_OPTIM__fno_tree_dominator_opts
+	bool "Adds -fno-tree-dominator-opts parameter to gcc invoke line."
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+config HACK_OPTIM__fno_dse
+	bool "Adds -fno-dse parameter to gcc invoke line."
+	---help---
+	  This will change how GCC optimize code. Code
+	  may be slower and larger but will be more debug
+	  "friendly".
+
+	  In some cases there is low chance that kernel
+	  will run different then normal, reporting or not
+	  some bugs or errors. Refere to GCC manual for
+	  more details.
+
+	  You SHOULD say N here.
+
+endif #HACK_OPTIM
diff --git a/scripts/Makefile.optim.inc b/scripts/Makefile.optim.inc
new file mode 100644
index 0000000..e78cc92
--- /dev/null
+++ b/scripts/Makefile.optim.inc
@@ -0,0 +1,23 @@
+# This file was auto generated. It's utility configuration
+# Distributed under GPL v2 License
+
+ifdef CONFIG_HACK_OPTIM__fno_inline_functions_called_once
+	KBUILD_CFLAGS += -fno-inline-functions-called-once
+endif
+
+ifdef CONFIG_HACK_OPTIM__fno_combine_stack_adjustments
+	KBUILD_CFLAGS += -fno-combine-stack-adjustments
+endif
+
+ifdef CONFIG_HACK_OPTIM__fno_tree_dce
+	KBUILD_CFLAGS += -fno-tree-dce
+endif
+
+ifdef CONFIG_HACK_OPTIM__fno_tree_dominator_opts
+	KBUILD_CFLAGS += -fno-tree-dominator-opts
+endif
+
+ifdef CONFIG_HACK_OPTIM__fno_dse
+	KBUILD_CFLAGS += -fno-dse
+endif
+
diff --git a/scripts/debug/make_config_optim.sh b/scripts/debug/make_config_optim.sh
new file mode 100644
index 0000000..26865923
--- /dev/null
+++ b/scripts/debug/make_config_optim.sh
@@ -0,0 +1,88 @@
+#!/bin/sh
+
+## Utility script for generating optimization override options
+## for kernel compilation.
+##
+## Distributed under GPL v2 license
+## (c) RadosA?aw Smogura, 2011
+
+# Prefix added for variable
+CFG_PREFIX="HACK_OPTIM"
+
+KCFG="Kconfig.debug.optim"
+MKFI="Makefile.optim.inc"
+
+OPTIMIZATIONS_PARAMS="-fno-inline-functions-called-once \
+ -fno-combine-stack-adjustments \
+ -fno-tree-dce \
+ -fno-tree-dominator-opts \
+ -fno-dse "
+
+echo "# This file was auto generated. It's utility configuration" > $KCFG
+echo "# Distributed under GPL v2 License" >> $KCFG
+echo >> $KCFG
+echo "menuconfig ${CFG_PREFIX}" >> $KCFG
+echo -e "\tbool \"Allows to override GCC optimization\"" >> $KCFG
+echo -e "\tdepends on DEBUG_KERNEL && EXPERIMENTAL" >> $KCFG
+echo -e "\thelp" >> $KCFG
+echo -e "\t  If you say Y here you will be able to override" >> $KCFG
+echo -e "\t  how GCC optimize kernel code. This will create" >> $KCFG
+echo -e "\t  more debug friendly, but with not guarentee"    >> $KCFG
+echo -e "\t  about same runi, like production, kernel."      >> $KCFG
+echo >> $KCFG
+echo -e "\t  If you say Y here probably You will want say"   >> $KCFG
+echo -e "\t  for all suboptions" >> $KCFG
+echo >> $KCFG
+echo "if ${CFG_PREFIX}" >> $KCFG
+echo >> $KCFG
+
+echo "# This file was auto generated. It's utility configuration" > $MKFI
+echo "# Distributed under GPL v2 License" >> $MKFI
+echo >> $MKFI
+
+# Insert standard override optimization level
+# This is exception, and this value will not be included
+# in auto generated makefile. Support for this value
+# is hard coded in main Makefile.
+echo -e "config ${CFG_PREFIX}_FORCE_O1_LEVEL" >> $KCFG
+echo -e "\tbool \"Forces -O1 optimization level\"" >> $KCFG
+echo -e "\t---help---" >> $KCFG
+echo -e "\t  This will change how GCC optimize code. Code" >> $KCFG
+echo -e "\t  may be slower and larger but will be more debug" >> $KCFG
+echo -e "\t  \"friendly\"." >> $KCFG
+echo >> $KCFG
+echo -e "\t  In some cases there is low chance that kernel" >> $KCFG
+echo -e "\t  will run different then normal, reporting or not" >> $KCFG
+echo -e "\t  some bugs or errors. Refere to GCC manual for" >> $KCFG
+echo -e "\t  more details." >> $KCFG
+echo >> $KCFG
+echo -e "\t  You SHOULD say N here." >> $KCFG
+echo >> $KCFG
+
+for o in $OPTIMIZATIONS_PARAMS ; do
+	cfg_o="${CFG_PREFIX}_${o//-/_}";
+	echo "Processing param ${o} config variable will be $cfg_o";
+
+	# Generate kconfig entry
+	echo -e "config ${cfg_o}" >> $KCFG
+	echo -e "\tbool \"Adds $o parameter to gcc invoke line.\"" >> $KCFG
+	echo -e "\t---help---" >> $KCFG
+	echo -e "\t  This will change how GCC optimize code. Code" >> $KCFG
+	echo -e "\t  may be slower and larger but will be more debug" >> $KCFG
+	echo -e "\t  \"friendly\"." >> $KCFG
+	echo >> $KCFG
+	echo -e "\t  In some cases there is low chance that kernel" >> $KCFG
+	echo -e "\t  will run different then normal, reporting or not" >> $KCFG
+	echo -e "\t  some bugs or errors. Refere to GCC manual for" >> $KCFG
+	echo -e "\t  more details." >> $KCFG
+	echo >> $KCFG
+	echo -e "\t  You SHOULD say N here." >> $KCFG
+	echo >> $KCFG
+
+	#Generate Make for include
+	echo "ifdef CONFIG_${cfg_o}" >> $MKFI
+	echo -e "\tKBUILD_CFLAGS += $o" >> $MKFI
+	echo "endif" >> $MKFI
+	echo  >> $MKFI
+done;
+echo "endif #${CFG_PREFIX}" >> $KCFG
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
