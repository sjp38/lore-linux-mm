Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C50CE6B0299
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:42:33 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e11-v6so3593326pgt.19
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:42:33 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z141-v6si21943489pfc.95.2018.06.07.07.42.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:42:31 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 6/7] tools: Add cetcmd
Date: Thu,  7 Jun 2018 07:38:54 -0700
Message-Id: <20180607143855.3681-7-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143855.3681-1-yu-cheng.yu@intel.com>
References: <20180607143855.3681-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>

From: "H.J. Lu" <hjl.tools@gmail.com>

Introduce CET command-line utility.  This utility allows system admin
to enable/disable CET features and set default shadow stack size.

Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
---
 tools/Makefile                                 |  13 +--
 tools/arch/x86/include/uapi/asm/elf_property.h |  16 +++
 tools/arch/x86/include/uapi/asm/prctl.h        |  33 ++++++
 tools/cet/.gitignore                           |   1 +
 tools/cet/Makefile                             |  11 ++
 tools/cet/cetcmd.c                             | 134 +++++++++++++++++++++++++
 tools/include/uapi/asm/elf_property.h          |   4 +
 tools/include/uapi/asm/prctl.h                 |   4 +
 8 files changed, 210 insertions(+), 6 deletions(-)
 create mode 100644 tools/arch/x86/include/uapi/asm/elf_property.h
 create mode 100644 tools/arch/x86/include/uapi/asm/prctl.h
 create mode 100644 tools/cet/.gitignore
 create mode 100644 tools/cet/Makefile
 create mode 100644 tools/cet/cetcmd.c
 create mode 100644 tools/include/uapi/asm/elf_property.h
 create mode 100644 tools/include/uapi/asm/prctl.h

diff --git a/tools/Makefile b/tools/Makefile
index be02c8b904db..bdca71e61d22 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -10,6 +10,7 @@ help:
 	@echo 'Possible targets:'
 	@echo ''
 	@echo '  acpi                   - ACPI tools'
+	@echo '  cet                    - Intel CET tools'
 	@echo '  cgroup                 - cgroup tools'
 	@echo '  cpupower               - a tool for all things x86 CPU power'
 	@echo '  firewire               - the userspace part of nosy, an IEEE-1394 traffic sniffer'
@@ -59,7 +60,7 @@ acpi: FORCE
 cpupower: FORCE
 	$(call descend,power/$@)
 
-cgroup firewire hv guest spi usb virtio vm bpf iio gpio objtool leds wmi: FORCE
+cet cgroup firewire hv guest spi usb virtio vm bpf iio gpio objtool leds wmi: FORCE
 	$(call descend,$@)
 
 liblockdep: FORCE
@@ -91,7 +92,7 @@ freefall: FORCE
 kvm_stat: FORCE
 	$(call descend,kvm/$@)
 
-all: acpi cgroup cpupower gpio hv firewire liblockdep \
+all: acpi cet cgroup cpupower gpio hv firewire liblockdep \
 		perf selftests spi turbostat usb \
 		virtio vm bpf x86_energy_perf_policy \
 		tmon freefall iio objtool kvm_stat wmi
@@ -102,7 +103,7 @@ acpi_install:
 cpupower_install:
 	$(call descend,power/$(@:_install=),install)
 
-cgroup_install firewire_install gpio_install hv_install iio_install perf_install spi_install usb_install virtio_install vm_install bpf_install objtool_install wmi_install:
+cet_install cgroup_install firewire_install gpio_install hv_install iio_install perf_install spi_install usb_install virtio_install vm_install bpf_install objtool_install wmi_install:
 	$(call descend,$(@:_install=),install)
 
 liblockdep_install:
@@ -123,7 +124,7 @@ freefall_install:
 kvm_stat_install:
 	$(call descend,kvm/$(@:_install=),install)
 
-install: acpi_install cgroup_install cpupower_install gpio_install \
+install: acpi_install cet_install cgroup_install cpupower_install gpio_install \
 		hv_install firewire_install iio_install liblockdep_install \
 		perf_install selftests_install turbostat_install usb_install \
 		virtio_install vm_install bpf_install x86_energy_perf_policy_install \
@@ -136,7 +137,7 @@ acpi_clean:
 cpupower_clean:
 	$(call descend,power/cpupower,clean)
 
-cgroup_clean hv_clean firewire_clean spi_clean usb_clean virtio_clean vm_clean wmi_clean bpf_clean iio_clean gpio_clean objtool_clean leds_clean:
+cet_clean cgroup_clean hv_clean firewire_clean spi_clean usb_clean virtio_clean vm_clean wmi_clean bpf_clean iio_clean gpio_clean objtool_clean leds_clean:
 	$(call descend,$(@:_clean=),clean)
 
 liblockdep_clean:
@@ -170,7 +171,7 @@ freefall_clean:
 build_clean:
 	$(call descend,build,clean)
 
-clean: acpi_clean cgroup_clean cpupower_clean hv_clean firewire_clean \
+clean: acpi_clean cet_clean cgroup_clean cpupower_clean hv_clean firewire_clean \
 		perf_clean selftests_clean turbostat_clean spi_clean usb_clean virtio_clean \
 		vm_clean bpf_clean iio_clean x86_energy_perf_policy_clean tmon_clean \
 		freefall_clean build_clean libbpf_clean libsubcmd_clean liblockdep_clean \
diff --git a/tools/arch/x86/include/uapi/asm/elf_property.h b/tools/arch/x86/include/uapi/asm/elf_property.h
new file mode 100644
index 000000000000..343a871b8fc1
--- /dev/null
+++ b/tools/arch/x86/include/uapi/asm/elf_property.h
@@ -0,0 +1,16 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
+#define _UAPI_ASM_X86_ELF_PROPERTY_H
+
+/*
+ * pr_type
+ */
+#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
+
+/*
+ * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
+ */
+#define GNU_PROPERTY_X86_FEATURE_1_SHSTK	(0x00000002)
+#define GNU_PROPERTY_X86_FEATURE_1_IBT		(0x00000001)
+
+#endif /* _UAPI_ASM_X86_ELF_PROPERTY_H */
diff --git a/tools/arch/x86/include/uapi/asm/prctl.h b/tools/arch/x86/include/uapi/asm/prctl.h
new file mode 100644
index 000000000000..fef476d2d2f6
--- /dev/null
+++ b/tools/arch/x86/include/uapi/asm/prctl.h
@@ -0,0 +1,33 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+#ifndef _ASM_X86_PRCTL_H
+#define _ASM_X86_PRCTL_H
+
+#define ARCH_SET_GS		0x1001
+#define ARCH_SET_FS		0x1002
+#define ARCH_GET_FS		0x1003
+#define ARCH_GET_GS		0x1004
+
+#define ARCH_GET_CPUID		0x1011
+#define ARCH_SET_CPUID		0x1012
+
+#define ARCH_MAP_VDSO_X32	0x2001
+#define ARCH_MAP_VDSO_32	0x2002
+#define ARCH_MAP_VDSO_64	0x2003
+
+#define ARCH_CET_STATUS		0x3001
+#define ARCH_CET_DISABLE	0x3002
+#define ARCH_CET_LOCK		0x3003
+#define ARCH_CET_EXEC		0x3004
+#define ARCH_CET_ALLOC_SHSTK	0x3005
+#define ARCH_CET_PUSH_SHSTK	0x3006
+#define ARCH_CET_LEGACY_BITMAP	0x3007
+
+/*
+ * Settings for ARCH_CET_EXEC
+ */
+#define CET_EXEC_ELF_PROPERTY	0
+#define CET_EXEC_ALWAYS_OFF	1
+#define CET_EXEC_ALWAYS_ON	2
+#define CET_EXEC_MAX CET_EXEC_ALWAYS_ON
+
+#endif /* _ASM_X86_PRCTL_H */
diff --git a/tools/cet/.gitignore b/tools/cet/.gitignore
new file mode 100644
index 000000000000..bd100f593454
--- /dev/null
+++ b/tools/cet/.gitignore
@@ -0,0 +1 @@
+cetcmd
diff --git a/tools/cet/Makefile b/tools/cet/Makefile
new file mode 100644
index 000000000000..fae42b84d796
--- /dev/null
+++ b/tools/cet/Makefile
@@ -0,0 +1,11 @@
+# SPDX-License-Identifier: GPL-2.0
+# Makefile for CET tools
+
+CFLAGS = -O2 -g -Wall -Wextra -I../include/uapi
+
+all: cetcmd
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+clean:
+	$(RM) cetcmd
diff --git a/tools/cet/cetcmd.c b/tools/cet/cetcmd.c
new file mode 100644
index 000000000000..dbbfb5267c1f
--- /dev/null
+++ b/tools/cet/cetcmd.c
@@ -0,0 +1,134 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#define _GNU_SOURCE
+#include <unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <getopt.h>
+#include <errno.h>
+#include <error.h>
+#include <asm/elf_property.h>
+#include <asm/prctl.h>
+
+enum command_line_switch {
+	OPTION_ELF_PROPERTY = 150,
+	OPTION_ALWAYS_OFF,
+	OPTION_ALWAYS_ON,
+	OPTION_SHSTK_SIZE
+};
+
+static const struct option options[] = {
+	{"property",	no_argument, 0, OPTION_ELF_PROPERTY},
+	{"off",		no_argument, 0, OPTION_ALWAYS_OFF},
+	{"on",		no_argument, 0, OPTION_ALWAYS_ON},
+	{"shstk-size",	required_argument, 0, OPTION_SHSTK_SIZE},
+	{"feature",	required_argument, 0, 'f'},
+	{"help",	no_argument, 0, 'h'},
+	{0,		no_argument, 0, 0}
+};
+
+__attribute__((__noreturn__))
+static void
+usage(FILE *stream, int exit_status)
+{
+	fprintf(stream, "Usage: %s <option(s)> -- command [args]\n",
+		program_invocation_short_name);
+	fprintf(stream, " Run command with CET features\n");
+	fprintf(stream, " The options are:\n");
+	fprintf(stream,
+		"\t--property                Enable CET features based on ELF property note\n"
+		"\t--off                     Always disable CET features\n"
+		"\t--on                      Always enable CET features\n"
+		"\t-f, --feature [ibt|shstk] Control CET [IBT|SHSTK] feature\n"
+		"\t--shstk-size SIZE         Set shadow stack size\n"
+		"\t-h --help                 Display this information\n");
+
+	exit(exit_status);
+}
+
+extern int arch_prctl(int, unsigned long *);
+
+int
+main(int argc, char *const *argv, char *const *envp)
+{
+	int c;
+	unsigned long values[3] = {0, -1, 0};
+	unsigned long status[3];
+	unsigned long shstk_size = -1;
+	char **args;
+	size_t i, num_of_args;
+
+	while ((c = getopt_long(argc, argv, "f:h",
+				options, (int *) 0)) != EOF) {
+		switch (c) {
+		case OPTION_ELF_PROPERTY:
+			values[1] = CET_EXEC_ELF_PROPERTY;
+			break;
+
+		case OPTION_ALWAYS_OFF:
+			values[1] = CET_EXEC_ALWAYS_OFF;
+			break;
+
+		case OPTION_ALWAYS_ON:
+			values[1] = CET_EXEC_ALWAYS_ON;
+			break;
+
+		case OPTION_SHSTK_SIZE:
+			shstk_size = strtol(optarg, NULL, 0);
+			break;
+
+		case 'f':
+			if (strcasecmp(optarg, "ibt") == 0)
+				values[0] = GNU_PROPERTY_X86_FEATURE_1_IBT;
+			else if (strcasecmp(optarg, "shstk") == 0)
+				values[0] = GNU_PROPERTY_X86_FEATURE_1_SHSTK;
+			else
+				usage(stderr, EXIT_FAILURE);
+			break;
+
+		case 'h':
+			usage(stdout, EXIT_SUCCESS);
+
+		default:
+			usage(stderr, EXIT_FAILURE);
+		}
+	}
+
+	if ((optind + 1) > argc ||
+	    (values[1] == (unsigned long)-1 &&
+	     shstk_size == (unsigned long)-1))
+		usage(stderr, EXIT_FAILURE);
+
+	/* If --shstk-size isn't used, get the current shadow stack size. */
+	if (shstk_size == (unsigned long)-1) {
+		if (arch_prctl(ARCH_CET_STATUS, status) < 0)
+			error(EXIT_FAILURE, errno, "arch_prctl failed\n");
+		shstk_size = status[2];
+	}
+
+	/* If --property/--off/--on aren't used, clear all features. */
+	if (values[1] == (unsigned long)-1) {
+		values[0] = 0;
+		values[1] = 0;
+	} else {
+		if (values[0] == 0)
+			values[0] = (GNU_PROPERTY_X86_FEATURE_1_IBT |
+				     GNU_PROPERTY_X86_FEATURE_1_SHSTK);
+	}
+
+	values[2] = shstk_size;
+	if (arch_prctl(ARCH_CET_EXEC, values) < 0)
+		error(EXIT_FAILURE, errno, "arch_prctl failed\n");
+
+	num_of_args = argc - optind + 1;
+	args = malloc(num_of_args * sizeof(char *));
+	if (args == NULL)
+		error(EXIT_FAILURE, errno, "malloc failed\n");
+
+	for (i = 0; i < num_of_args; i++)
+		args[i] = argv[optind + i];
+	args[i] = NULL;
+
+	return execvpe(argv[optind], args, envp);
+}
diff --git a/tools/include/uapi/asm/elf_property.h b/tools/include/uapi/asm/elf_property.h
new file mode 100644
index 000000000000..1281b4e1a578
--- /dev/null
+++ b/tools/include/uapi/asm/elf_property.h
@@ -0,0 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#if defined(__i386__) || defined(__x86_64__)
+#include "../../arch/x86/include/uapi/asm/elf_property.h"
+#endif
\ No newline at end of file
diff --git a/tools/include/uapi/asm/prctl.h b/tools/include/uapi/asm/prctl.h
new file mode 100644
index 000000000000..b0894b828b06
--- /dev/null
+++ b/tools/include/uapi/asm/prctl.h
@@ -0,0 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#if defined(__i386__) || defined(__x86_64__)
+#include "../../arch/x86/include/uapi/asm/prctl.h"
+#endif
\ No newline at end of file
-- 
2.15.1
