Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C0D266B007E
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:33 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 2/2] qemu: add ksmctl.
Date: Tue, 31 Mar 2009 03:00:28 +0300
Message-Id: <1238457628-7668-3-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457628-7668-2-git-send-email-ieidus@redhat.com>
References: <1238457628-7668-1-git-send-email-ieidus@redhat.com>
 <1238457628-7668-2-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

userspace tool to control the ksm kernel thread

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 user/Makefile              |    6 +++-
 user/config-x86-common.mak |    2 +-
 user/ksmctl.c              |   69 ++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 2 deletions(-)
 create mode 100644 user/ksmctl.c

diff --git a/user/Makefile b/user/Makefile
index cf7f8ed..a291b37 100644
--- a/user/Makefile
+++ b/user/Makefile
@@ -39,6 +39,10 @@ autodepend-flags = -MMD -MF $(dir $*).$(notdir $*).d
 
 LDFLAGS += -pthread -lrt
 
+ksmctl_objs= ksmctl.o
+ksmctl: $(ksmctl_objs)
+	$(CC) $(LDFLAGS) $^ -o $@
+
 kvmtrace_objs= kvmtrace.o
 
 kvmctl: $(kvmctl_objs)
@@ -56,4 +60,4 @@ $(libcflat): $(cflatobjs)
 -include .*.d
 
 clean: arch_clean
-	$(RM) kvmctl kvmtrace *.o *.a .*.d $(libcflat) $(cflatobjs)
+	$(RM) ksmctl kvmctl kvmtrace *.o *.a .*.d $(libcflat) $(cflatobjs)
diff --git a/user/config-x86-common.mak b/user/config-x86-common.mak
index e789fd4..4303aee 100644
--- a/user/config-x86-common.mak
+++ b/user/config-x86-common.mak
@@ -1,6 +1,6 @@
 #This is a make file with common rules for both x86 & x86-64
 
-all: kvmctl kvmtrace test_cases
+all: ksmctl kvmctl kvmtrace test_cases
 
 kvmctl_objs= main.o iotable.o ../libkvm/libkvm.a
 balloon_ctl: balloon_ctl.o
diff --git a/user/ksmctl.c b/user/ksmctl.c
new file mode 100644
index 0000000..034469f
--- /dev/null
+++ b/user/ksmctl.c
@@ -0,0 +1,69 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/ioctl.h>
+#include <fcntl.h>
+#include <sys/mman.h>
+#include <unistd.h>
+#include "../qemu/ksm.h"
+
+int main(int argc, char *argv[])
+{
+	int fd;
+	int used = 0;
+	int fd_start;
+	struct ksm_kthread_info info;
+	
+
+	if (argc < 2) {
+		fprintf(stderr, "usage: %s {start npages sleep | stop | info}\n", argv[0]);
+		exit(1);
+	}
+
+	fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
+	if (fd == -1) {
+		fprintf(stderr, "could not open /dev/ksm\n");
+		exit(1);
+	}
+
+	if (!strncmp(argv[1], "start", strlen(argv[1]))) {
+		used = 1;
+		if (argc < 4) {
+			fprintf(stderr,
+		    "usage: %s start npages_to_scan sleep\n",
+		    argv[0]);
+			exit(1);
+		}
+		info.pages_to_scan = atoi(argv[2]);
+		info.sleep = atoi(argv[3]);
+		info.flags = ksm_control_flags_run;
+
+		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
+		if (fd_start == -1) {
+			fprintf(stderr, "KSM_START_KTHREAD failed\n");
+			exit(1);
+		}
+		printf("created scanner\n");
+	}
+
+	if (!strncmp(argv[1], "stop", strlen(argv[1]))) {
+		used = 1;
+		info.flags = 0;
+		fd_start = ioctl(fd, KSM_START_STOP_KTHREAD, &info);
+		printf("stopped scanner\n");
+	}
+
+	if (!strncmp(argv[1], "info", strlen(argv[1]))) {
+		used = 1;
+		ioctl(fd, KSM_GET_INFO_KTHREAD, &info);
+	 printf("flags %d, pages_to_scan %d, sleep_time %d\n",
+	 info.flags, info.pages_to_scan, info.sleep);
+	}
+
+	if (!used)
+		fprintf(stderr, "unknown command %s\n", argv[1]);
+
+	return 0;
+}
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
