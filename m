Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D89A6B6BB8
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:26 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w1so15013218qta.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a41si9428631qtb.19.2018.12.03.15.36.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:25 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 14/14] test/hms: tests for heterogeneous memory system
Date: Mon,  3 Dec 2018 18:35:09 -0500
Message-Id: <20181203233509.20671-15-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

Set of tests for heterogeneous memory system (migration, binding, ...)

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
---
 tools/testing/hms/Makefile                    |  17 ++
 tools/testing/hms/hbind-create-device-file.sh |  11 +
 tools/testing/hms/test-hms-migrate.c          |  77 ++++++
 tools/testing/hms/test-hms.c                  | 237 ++++++++++++++++++
 tools/testing/hms/test-hms.h                  |  67 +++++
 5 files changed, 409 insertions(+)
 create mode 100644 tools/testing/hms/Makefile
 create mode 100755 tools/testing/hms/hbind-create-device-file.sh
 create mode 100644 tools/testing/hms/test-hms-migrate.c
 create mode 100644 tools/testing/hms/test-hms.c
 create mode 100644 tools/testing/hms/test-hms.h

diff --git a/tools/testing/hms/Makefile b/tools/testing/hms/Makefile
new file mode 100644
index 000000000000..57223a671cb0
--- /dev/null
+++ b/tools/testing/hms/Makefile
@@ -0,0 +1,17 @@
+# SPDX-License-Identifier: GPL-2.0
+LDFLAGS += -fsanitize=address -fsanitize=undefined
+CFLAGS += -std=c99 -D_GNU_SOURCE -I. -I../../../include/uapi -g -Og -Wall
+LDLIBS += -lpthread
+TARGETS = test-hms-migrate
+OFILES = test-hms
+
+targets: $(TARGETS)
+
+$(TARGETS): $(OFILES:%=%.o) $(TARGETS:%=%.c)
+	$(CC) $(CFLAGS) -o $@ $(OFILES:%=%.o) $@.c
+
+clean:
+	$(RM) $(TARGETS) *.o
+
+%.o: Makefile *.h %.c
+	$(CC) $(CFLAGS) -o $@ -c $(@:%.o=%.c)
diff --git a/tools/testing/hms/hbind-create-device-file.sh b/tools/testing/hms/hbind-create-device-file.sh
new file mode 100755
index 000000000000..60c2533cc85d
--- /dev/null
+++ b/tools/testing/hms/hbind-create-device-file.sh
@@ -0,0 +1,11 @@
+#!/bin/sh
+# SPDX-License-Identifier: GPL-2.0
+
+major=10
+minor=$(awk "\$2==\"hbind\" {print \$1}" /proc/misc)
+
+echo hbind device minor is $minor, creating device file:
+sudo rm /dev/hbind
+sudo mknod /dev/hbind c $major $minor
+sudo chmod 666 /dev/hbind
+echo /dev/hbind created
diff --git a/tools/testing/hms/test-hms-migrate.c b/tools/testing/hms/test-hms-migrate.c
new file mode 100644
index 000000000000..b90f701c0b75
--- /dev/null
+++ b/tools/testing/hms/test-hms-migrate.c
@@ -0,0 +1,77 @@
+/*
+ * Copyright 2018 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors:
+ * Jérôme Glisse <jglisse@redhat.com>
+ */
+#include <stdio.h>
+
+#include "test-hms.h"
+
+int main(int argc, char *argv[])
+{
+    struct hms_context ctx;
+    struct hms_object *target = NULL;
+    uint64_t targets[1], ntargets = 1;
+    unsigned long size = 64 << 10;
+    unsigned long start, end, i;
+    unsigned *ptr;
+    int ret;
+
+    if (argc != 2) {
+        printf("EE: usage: %s targetname\n", argv[0]);
+        return -1;
+    }
+
+    hms_context_init(&ctx);
+
+    /* Find target */
+    do {
+        target = hms_context_object_find_reference(&ctx, target, argv[1]);
+    } while (target && target->type != HMS_TARGET);
+    if (target == NULL) {
+        printf("EE: could not find %s target\n", argv[1]);
+        return -1;
+    }
+
+    /* Allocate memory */
+    ptr = hms_malloc(size);
+    for (i = 0; i < (size / 4); ++i) {
+        ptr[i] = i;
+    }
+
+    /* Migrate to target */
+    targets[0] = target->id;
+    start = (uintptr_t)ptr;
+    end = start + size;
+    ntargets = 1;
+    ret = hms_migrate(&ctx, start, end, targets, ntargets);
+    if (ret) {
+        printf("EE: migration failure (%d)\n", ret);
+    } else {
+        for (i = 0; i < (size / 4); ++i) {
+            if (ptr[i] != i) {
+                printf("EE: migration failure ptr[%ld] = %d\n", i, ptr[i]);
+                goto out;
+            }
+        }
+        printf("OK: migration successful\n");
+    }
+
+out:
+    /* Free */
+    hms_mfree(ptr, size);
+
+    hms_context_fini(&ctx);
+    return 0;
+}
diff --git a/tools/testing/hms/test-hms.c b/tools/testing/hms/test-hms.c
new file mode 100644
index 000000000000..0502f49198c4
--- /dev/null
+++ b/tools/testing/hms/test-hms.c
@@ -0,0 +1,237 @@
+/*
+ * Copyright 2018 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors:
+ * Jérôme Glisse <jglisse@redhat.com>
+ */
+#include <sys/ioctl.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/mman.h>
+#include <strings.h>
+#include <dirent.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <stdio.h>
+
+#include "test-hms.h"
+#include "linux/hbind.h"
+
+
+static unsigned long page_mask = 0;
+static int page_size = 0;
+static int page_shift = 0;
+
+static inline void page_shift_init(void)
+{
+    if (!page_shift) {
+        page_size = sysconf(_SC_PAGE_SIZE);
+
+        page_shift = ffs(page_size) - 1;
+        page_mask = ~((unsigned long)(page_size - 1));
+    }
+}
+
+static unsigned long page_align(unsigned long size)
+{
+    return (size + page_size - 1) & page_mask;
+}
+
+void hms_object_parse_dir(struct hms_object *object, const char *ctype)
+{
+    struct dirent *dirent;
+    char dirname[256];
+    DIR *dirp;
+
+    snprintf(dirname, 255, "/sys/bus/hms/devices/v%u-%u-%s",
+             object->version, object->id, ctype);
+    dirp = opendir(dirname);
+    if (dirp == NULL) {
+        return;
+    }
+    while ((dirent = readdir(dirp))) {
+        struct hms_reference *reference;
+
+        if (dirent->d_type != DT_LNK || !strcmp(dirent->d_name, "subsystem")) {
+            continue;
+        }
+
+        reference = malloc(sizeof(*reference));
+        strcpy(reference->name, dirent->d_name);
+        reference->object = NULL;
+
+        reference->next = object->references;
+        object->references = reference;
+    }
+    closedir(dirp);
+}
+
+void hms_object_free(struct hms_object *object)
+{
+    struct hms_reference *reference = object->references;
+
+    for (; reference; reference = object->references) {
+        object->references = reference->next;
+        free(reference);
+    }
+
+    free(object);
+}
+
+
+void hms_context_init(struct hms_context *ctx)
+{
+    struct dirent *dirent;
+    DIR *dirp;
+
+    ctx->objects = NULL;
+
+    /* Scan targets, initiators, links, bridges ... */
+    dirp = opendir("/sys/bus/hms/devices/");
+    if (dirp == NULL) {
+        printf("EE: could not open /sys/bus/hms/devices/\n");
+        exit(-1);
+    }
+    while ((dirent = readdir(dirp))) {
+        struct hms_object *object;
+        unsigned version, id;
+        enum hms_type type;
+        char ctype[256];
+
+        if (dirent->d_type != DT_LNK || dirent->d_name[0] != 'v') {
+            continue;
+        }
+        if (sscanf(dirent->d_name, "v%d-%d-%s", &version, &id, ctype) != 3) {
+            continue;
+        }
+
+        if (!strcmp("link", ctype)) {
+            type = HMS_LINK;
+        } else if (!strcmp("bridge", ctype)) {
+            type = HMS_BRIDGE;
+        } else if (!strcmp("target", ctype)) {
+            type = HMS_TARGET;
+        } else if (!strcmp("initiator", ctype)) {
+            type = HMS_INITIATOR;
+        } else {
+            continue;
+        }
+
+        object = malloc(sizeof(*object));
+        object->references = NULL;
+        object->version = version;
+        object->type = type;
+        object->id = id;
+
+        object->next = ctx->objects;
+        ctx->objects = object;
+
+        hms_object_parse_dir(object, ctype);
+    }
+    closedir(dirp);
+
+    ctx->fd = open("/dev/hbind", O_RDWR);
+    if (ctx->fd < 0) {
+        printf("EE: could not open /dev/hbind\n");
+        exit(-1);
+    }
+}
+
+void hms_context_fini(struct hms_context *ctx)
+{
+    struct hms_object *object = ctx->objects;
+
+    for (; object; object = ctx->objects) {
+        ctx->objects = object->next;
+        hms_object_free(object);
+    }
+
+    close(ctx->fd);
+}
+
+struct hms_object *hms_context_object_find_reference(struct hms_context *ctx,
+                                                     struct hms_object *object,
+                                                     const char *name)
+{
+    object = object ? object->next : ctx->objects;
+    for (; object; object = object->next) {
+        struct hms_reference *reference = object->references;
+
+        for (; reference; reference = reference->next) {
+            if (!strcmp(reference->name, name)) {
+                return object;
+            }
+        }
+    }
+
+    return NULL;
+}
+
+
+int hms_migrate(struct hms_context *ctx,
+                unsigned long start,
+                unsigned long end,
+                uint64_t *targets,
+                unsigned ntargets)
+{
+    struct hbind_params params;
+    uint64_t atoms[2], natoms;
+    int ret;
+
+    atoms[0] = HBIND_ATOM_SET_CMD(HBIND_CMD_MIGRATE) |
+               HBIND_ATOM_SET_DWORDS(1);
+    atoms[1] = 0;
+    natoms = 2;
+
+    params.targets = (uintptr_t)targets;
+    params.atoms = (uintptr_t)atoms;
+
+    params.ntargets = ntargets;
+    params.natoms = natoms;
+    params.start = start;
+    params.end = end;
+
+    do {
+        ret = ioctl(ctx->fd, HBIND_IOCTL, &params);
+printf("ret %d artoms %d\n", ret, (int)atoms[1]);
+    } while (ret && (errno == EINTR));
+
+    /* Result of migration is in the atoms after cmd dword */
+printf("ret %d artoms %d\n", ret, (int)atoms[1]);
+    ret = ret ? ret : atoms[1];
+
+    return ret;
+}
+
+
+void *hms_malloc(unsigned long size)
+{
+    void *ptr;
+
+    page_shift_init();
+
+    ptr = mmap(0, page_align(size), PROT_READ | PROT_WRITE,
+               MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
+    if (ptr == MAP_FAILED) {
+        return NULL;
+    }
+    return ptr;
+}
+
+void hms_mfree(void *ptr, unsigned long size)
+{
+    munmap(ptr, page_align(size));
+}
diff --git a/tools/testing/hms/test-hms.h b/tools/testing/hms/test-hms.h
new file mode 100644
index 000000000000..b5d625e18d59
--- /dev/null
+++ b/tools/testing/hms/test-hms.h
@@ -0,0 +1,67 @@
+/*
+ * Copyright 2018 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors:
+ * Jérôme Glisse <jglisse@redhat.com>
+ */
+#ifndef TEST_HMS_H
+#define TEST_HMS_H
+
+#include <stdint.h>
+
+enum hms_type {
+    HMS_LINK = 0,
+    HMS_BRIDGE,
+    HMS_TARGET,
+    HMS_INITIATOR,
+};
+
+struct hms_reference {
+    char name[256];
+    struct hms_object *object;
+    struct hms_reference *next;
+};
+
+struct hms_object {
+    struct hms_reference *references;
+    struct hms_object *next;
+    unsigned version;
+    unsigned id;
+    enum hms_type type;
+};
+
+struct hms_context {
+    struct hms_object *objects;
+    int fd;
+};
+
+void hms_context_init(struct hms_context *ctx);
+void hms_context_fini(struct hms_context *ctx);
+struct hms_object *hms_context_object_find_reference(struct hms_context *ctx,
+                                                     struct hms_object *object,
+                                                     const char *name);
+
+
+int hms_migrate(struct hms_context *ctx,
+                unsigned long start,
+                unsigned long end,
+                uint64_t *targets,
+                unsigned ntargets);
+
+
+/* Provide page align memory allocations */
+void *hms_malloc(unsigned long size);
+void hms_mfree(void *ptr, unsigned long size);
+
+
+#endif
-- 
2.17.2
