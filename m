Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 1EF086B00EC
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 09:34:31 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: =?UTF-8?q?=5BPATCH=5D=20Added=20hacking=20menu=20for=20override=20optimization=20by=20GCC=2E?=
Date: Fri, 17 Feb 2012 15:33:47 +0100
Message-Id: <1329489227-19678-1-git-send-email-mail@smogura.eu>
In-Reply-To: <op.v9sn1gld3l0zgt@mpn-glaptop>
References: <op.v9sn1gld3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>, Randy Dunlap <rdunlap@xenotime.net>

New menu under kernel hacking allows to force "-01" optimization
and gives ability to discard additional optimizations (implicite
passed with -O1). Options are added as "-f-no-..." to GCC invoke line.
This may produce additional warnings, but makes compiled code more debug
friendly.

Patch is integrated with main Makefile. It generates additional KConfig
and Makefile from script so sources are keep clean. Adding
additional deopitmization option, requires appending, just, one line
in script.

Some options are specific to pariticullar GCC versions.
---
 .gitignore                         |    5 +
 Makefile                           |   28 +++++++-
 lib/Kconfig.debug                  |    2 +
 scripts/debug/make_config_optim.sh |  142 ++++++++++++++++++++++++++++++++++++
 4 files changed, 175 insertions(+), 2 deletions(-)
 create mode 100644 scripts/debug/make_config_optim.sh

diff --git a/.gitignore b/.gitignore
index 57af07c..1ad2a92 100644
--- a/.gitignore
+++ b/.gitignore
@@ -84,3 +84,8 @@ GTAGS
 *.orig
 *~
 \#*#
+
+# Deoptimzation generated files
+scripts/Makefile.optim.inc
+lib/Kconfig.debug.optim
+
diff --git a/Makefile b/Makefile
index 7c44b67..d1c4080 100644
--- a/Makefile
+++ b/Makefile
@@ -131,7 +131,7 @@ sub-make: FORCE
 	KBUILD_SRC=$(CURDIR) \
 	KBUILD_EXTMOD="$(KBUILD_EXTMOD)" -f $(CURDIR)/Makefile \
 	$(filter-out _all sub-make,$(MAKECMDGOALS))
-
+	
 # Leave processing to above invocation of make
 skip-makefile := 1
 endif # ifneq ($(KBUILD_OUTPUT),)
@@ -432,6 +432,19 @@ asm-generic:
 	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.asm-generic \
 	            obj=arch/$(SRCARCH)/include/generated/asm
 
+# Support for auto generating hackers deoptimization
+PHONY += deoptimize-config
+DEOPTIMIZE_FILES := $(srctree)/lib/Kconfig.debug.optim \
+	$(srctree)/scripts/Makefile.optim.inc
+
+$(DEOPTIMIZE_FILES): $(srctree)/scripts/debug/make_config_optim.sh
+	$(Q)$(srctree)/scripts/debug/make_config_optim.sh --kconfig \
+		> $(srctree)/lib/Kconfig.debug.optim
+	$(Q)$(srctree)/scripts/debug/make_config_optim.sh --makefile \
+		> scripts/Makefile.optim.inc
+
+deoptimize-config: $(DEOPTIMIZE_FILES)
+
 # To make sure we do not include .config for any of the *config targets
 # catch them early, and hand them over to scripts/kconfig/Makefile
 # It is allowed to specify more targets when calling make, including
@@ -484,7 +497,7 @@ ifeq ($(config-targets),1)
 include $(srctree)/arch/$(SRCARCH)/Makefile
 export KBUILD_DEFCONFIG KBUILD_KCONFIG
 
-config: scripts_basic outputmakefile FORCE
+config: deoptimize-config scripts_basic outputmakefile FORCE
 	$(Q)mkdir -p include/linux include/config
 	$(Q)$(MAKE) $(build)=scripts/kconfig $@
 
@@ -558,12 +571,23 @@ endif # $(dot-config)
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
diff --git a/scripts/debug/make_config_optim.sh b/scripts/debug/make_config_optim.sh
new file mode 100644
index 0000000..35bb321
--- /dev/null
+++ b/scripts/debug/make_config_optim.sh
@@ -0,0 +1,142 @@
+#!/bin/sh
+
+############################################################################
+## Utility script for generating deoptimization overrides for kernel
+## compilation.
+##
+## By default kernel is build with -O2 or -Os options which make it harder
+## to debug, due to reorganization of execution paths, stripping code or
+## variables.
+##
+## This script generates KConfig and Makefiles includes to force -O1 and
+## add many deoptimization parameters to GCC (-fno-*).
+##
+## Happy hacking.
+##
+## Distributed under GPL v2 license
+## (c) RadosA?aw Smogura, 2011,2012
+
+# Prefix added for variable
+CFG_PREFIX="HACK_OPTIM"
+
+function printHelpAndExit() {
+    printf "KConfig and Makefile generator for kenrel deoptimization :)\n"
+    printf "Use one of options:\n"
+    printf "%s\n" "  --kconfig  - to generate Kconfig.debug.optim"
+    printf "%s\n" "  --makefile - to generate Makefile.optim.inc"
+    printf "Files are generated to standard output\n"
+    exit 1;
+}
+
+if [ "$1" != "--kconfig" ] && [ "$1" != "--makefile" ]; then
+    printHelpAndExit
+fi
+
+OPTIMIZATIONS_PARAMS="-fno-inline-functions-called-once
+ -fno-combine-stack-adjustments
+ -fno-tree-dce
+ -fno-tree-dominator-opts
+ -fno-dse
+ -fno-dce
+ -fno-auto-inc-dec
+ -fno-inline-small-functions
+ -fno-if-conversion
+ -fno-if-conversion2
+ -fno-tree-fre
+ -fno-tree-dse
+ -fno-tree-sra
+"
+
+function printStandardHelp() {
+    printf "\t  This changes how GCC optimizes code. Code\n"
+    printf "\t  may be slower and larger but will be more debug\n"
+    printf "\t  \"friendly\".\n"
+    printf "\n"
+    printf "\t  In some cases there is a low chance that the kernel\n"
+    printf "\t  will run differently than normal, reporting or not\n"
+    printf "\t  reporting some bugs or errors.\n"
+    printf "\t  Refer to GCC manual for more details.\n"
+    printf "\n"
+    printf "\t  You SHOULD say N here.\n"
+}
+
+function printFileHeader() {
+    printf "################################################################\n"
+    printf "## THIS FILE WAS AUTO GENERATED.\n"
+    printf "## YOU MAY MODIFY IT, BUT YOUR MODIFICATIONS MAY BE LOST\n"
+    printf "## GENERATED ON $(date)\n"
+    printf "## BY $0\n"
+    printf "## Distributed under GPL v2 License\n"
+    printf "##\n"
+    printf "## Happy hacking.\n"
+    printf "################################################################\n"
+}
+
+function printKconfigHeader() {
+    printFileHeader;
+    printf "\n"
+    printf "menuconfig ${CFG_PREFIX}\n"
+    printf "\tbool \"Allows overriding GCC optimizations\"\n"
+    printf "\tdepends on DEBUG_KERNEL && EXPERIMENTAL\n"
+    printf "\thelp\n"
+    printf "\t  If you say Y here you will be able to override\n"
+    printf "\t  how GCC optimizes kernel code. This creates\n"
+    printf "\t  more debug-friendly code, but does not guarantee\n"
+    printf "\t  the same running code like a production kernel.\n"
+    printf "\n"
+    printf "\t  If you say Y here probably you will want to say\n"
+    printf "\t  Y for all suboptions\n"
+    printf "\n"
+    printf "if ${CFG_PREFIX}\n"
+
+    # Insert standard override optimization level
+    # This is exception, and this value will not be included
+    # in auto generated makefile. Support for this value
+    # is hard coded in main Makefile.
+    printf "config ${CFG_PREFIX}_FORCE_O1_LEVEL\n"
+    printf "\tbool \"Forces -O1 optimization level\"\n"
+    printf "\t---help---\n"
+    printStandardHelp;
+    printf "\n"
+}
+
+function printMakeOptimStart() {
+    printFileHeader;
+    printf "\n"
+}
+
+if [ "$1" == "--kconfig" ]; then
+    printKconfigHeader;
+else
+    printMakeOptimStart;
+fi
+
+# Print each option to KConfig and Makefile
+for o in $OPTIMIZATIONS_PARAMS ; do
+    # I'm not shell script guru, but it looks like printf is not portable
+    # across various shells, in my Gentoo bash if text starts with -, then
+    # printf prints error (e.g. printf "-f-no" | sed... cause error),
+    # in posh (Bourne sh clone, it's hard to get original sh) works good,
+    # so we use here extended form of %s
+    cfg_o="${CFG_PREFIX}_$(printf "%s" "${o}" |sed -r -e 's/-/_/g;' )";
+
+    if [ "$1" == "--kconfig" ]; then
+        # Generate kconfig entry
+        printf "config ${cfg_o}\n";
+        printf "\tbool \"Adds $o parameter to gcc invoke line.\"\n";
+        printf "\t---help---\n";
+        printStandardHelp;
+        printf "\n";
+    else
+        #Generate Make for include
+        printf "ifdef CONFIG_${cfg_o}\n";
+        printf "\tKBUILD_CFLAGS += $o\n";
+        printf "endif\n";
+        printf "\n";
+    fi
+done;
+
+# Close KConfig
+if [ "$1" == "--kconfig" ]; then
+    echo "endif # if ${CFG_PREFIX}";
+fi
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
