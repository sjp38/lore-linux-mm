Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9B40F6B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 17:28:37 -0500 (EST)
Received: by fxm22 with SMTP id 22so684331fxm.6
        for <linux-mm@kvack.org>; Fri, 19 Feb 2010 14:28:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH -mmotm 3/4] cgroups: Add simple listener of cgroup events to documentation
Date: Sat, 20 Feb 2010 00:28:18 +0200
Message-Id: <6afbe14e8bb2480d88377c14cb15d96edd2d18f6.1266618391.git.kirill@shutemov.name>
In-Reply-To: <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name>
 <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
In-Reply-To: <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
References: <05f582d6cdc85fbb96bfadc344572924c0776730.1266618391.git.kirill@shutemov.name> <a2717b1f5e0b49db7b6ecd1a5a41e65c1dc6b50a.1266618391.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: containers@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 Documentation/cgroups/cgroup_event_listener.c |  102 +++++++++++++++++++++++++
 1 files changed, 102 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/cgroups/cgroup_event_listener.c

diff --git a/Documentation/cgroups/cgroup_event_listener.c b/Documentation/cgroups/cgroup_event_listener.c
new file mode 100644
index 0000000..a8277b2
--- /dev/null
+++ b/Documentation/cgroups/cgroup_event_listener.c
@@ -0,0 +1,102 @@
+/*
+ * cgroup_event_listener.c - Simple listener of cgroup events
+ *
+ * Copyright (C) Kirill A. Shutemov <kirill@shutemov.name>
+ */
+
+#include <assert.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <libgen.h>
+#include <limits.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#include <sys/eventfd.h>
+
+#define USAGE_STR "Usage: cgroup_event_listener <path-to-control-file> <args>\n"
+
+int main(int argc, char **argv)
+{
+	int efd = -1;
+	int cfd = -1;
+	int event_control = -1;
+	char event_control_path[PATH_MAX];
+	int ret;
+
+	if (argc != 3) {
+		fputs(USAGE_STR, stderr);
+		return 1;
+	}
+
+	cfd = open(argv[1], O_RDONLY);
+	if (cfd == -1) {
+		fprintf(stderr, "Cannot open %s: %s\n", argv[1],
+				strerror(errno));
+		goto out;
+	}
+
+	ret = snprintf(event_control_path, PATH_MAX, "%s/cgroup.event_control",
+			dirname(argv[1]));
+	if (ret > PATH_MAX) {
+		fputs("Path to cgroup.event_control is too long\n", stderr);
+		goto out;
+	}
+
+	event_control = open(event_control_path, O_WRONLY);
+	if (event_control == -1) {
+		fprintf(stderr, "Cannot open %s: %s\n", event_control_path,
+				strerror(errno));
+		goto out;
+	}
+
+	efd = eventfd(0, 0);
+	if (efd == -1) {
+		perror("eventfd() failed");
+		goto out;
+	}
+
+	ret = dprintf(event_control, "%d %d %s", efd, cfd, argv[2]);
+	if (ret == -1) {
+		perror("Cannot write to cgroup.event_control");
+		goto out;
+	}
+
+	while (1) {
+		uint64_t result;
+
+		ret = read(efd, &result, sizeof(result));
+		if (ret == -1) {
+			if (errno == EINTR)
+				continue;
+			perror("Cannot read from eventfd");
+			break;
+		}
+		assert (ret == sizeof(result));
+
+		ret = access(event_control_path, W_OK);
+		if ((ret == -1) && (errno == ENOENT)) {
+				puts("The cgroup seems to have removed.");
+				ret = 0;
+				break;
+		}
+
+		if (ret == -1) {
+			perror("cgroup.event_control is not accessable any more");
+			break;
+		}
+
+		printf("%s %s: crossed\n", argv[1], argv[2]);
+	}
+
+out:
+	if (efd >= 0)
+		close(efd);
+	if (event_control >= 0)
+		close(event_control);
+	if (cfd >= 0)
+		close(cfd);
+
+	return (ret != 0);
+}
-- 
1.6.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
