Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66D496B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 01:39:17 -0500 (EST)
Received: by lffu14 with SMTP id u14so79739142lff.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 22:39:16 -0800 (PST)
Received: from sesbmg22.ericsson.net (sesbmg22.ericsson.net. [193.180.251.48])
        by mx.google.com with ESMTPS id m199si4690943lfg.80.2015.12.02.22.39.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 22:39:15 -0800 (PST)
From: Janne Karhunen <Janne.Karhunen@gmail.com>
Subject: [PATCH] Introduce a recovery= command line option.
Date: Thu, 3 Dec 2015 08:35:50 +0200
Message-ID: <1449124550-7781-1-git-send-email-Janne.Karhunen@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Janne Karhunen <Janne.Karhunen@gmail.com>

Recovery option can be used to define a secondary rootfs
in case mounting of the primary root fails. While it has
been possible to solve the issue via bootloader and/or
initrd means, this solution is suitable for systems that
want to stay bootloader agnostic and operate without an
initrd.

Signed-off-by: Janne Karhunen <Janne.Karhunen@gmail.com>
---
 Documentation/kernel-parameters.txt |  3 ++
 init/do_mounts.c                    | 64 +++++++++++++++++++++++++++++--------
 2 files changed, 54 insertions(+), 13 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 742f69d..0d65a63 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -3390,6 +3390,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 		nocompress	Don't compress/decompress hibernation images.
 		no		Disable hibernation and resume.
 
+	recovery= 	[KNL] Recovery root filesystem. This partition is attempted as
+			root in case default root filesystem does not mount.
+
 	retain_initrd	[RAM] Keep initrd memory after extraction
 
 	rfkill.default_state=
diff --git a/init/do_mounts.c b/init/do_mounts.c
index dea5de9..994b2e5 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -39,8 +39,11 @@ int __initdata rd_doload;	/* 1 = load RAM disk, 0 = don't load */
 
 int root_mountflags = MS_RDONLY | MS_SILENT;
 static char * __initdata root_device_name;
+static char * __initdata recovery_device_name;
 static char __initdata saved_root_name[64];
+static char __initdata saved_recovery_name[64];
 static int root_wait;
+static int recovery_attempt;
 
 dev_t ROOT_DEV;
 
@@ -298,6 +301,15 @@ static int __init root_dev_setup(char *line)
 
 __setup("root=", root_dev_setup);
 
+static int __init recovery_setup(char *line)
+{
+	strlcpy(saved_recovery_name, line, sizeof(saved_recovery_name));
+	recovery_attempt = 1;
+	return 1;
+}
+
+__setup("recovery=", recovery_setup);
+
 static int __init rootwait_setup(char *str)
 {
 	if (*str)
@@ -384,6 +396,7 @@ void __init mount_block_root(char *name, int flags)
 					__GFP_NOTRACK_FALSE_POSITIVE);
 	char *fs_names = page_address(page);
 	char *p;
+	int err;
 #ifdef CONFIG_BLOCK
 	char b[BDEVNAME_SIZE];
 #else
@@ -393,7 +406,7 @@ void __init mount_block_root(char *name, int flags)
 	get_fs_names(fs_names);
 retry:
 	for (p = fs_names; *p; p += strlen(p)+1) {
-		int err = do_mount_root(name, p, flags, root_mount_data);
+		err = do_mount_root(name, p, flags, root_mount_data);
 		switch (err) {
 			case 0:
 				goto out;
@@ -401,7 +414,33 @@ retry:
 			case -EINVAL:
 				continue;
 		}
-	        /*
+		if (!(flags & MS_RDONLY)) {
+			pr_warn("Retrying rootfs mount as read-only.\n");
+			flags |= MS_RDONLY;
+			goto retry;
+		}
+		if (recovery_device_name && recovery_attempt) {
+			recovery_attempt = 0;
+
+			ROOT_DEV = name_to_dev_t(recovery_device_name);
+			if (strncmp(recovery_device_name, "/dev/", 5) == 0)
+				recovery_device_name += 5;
+
+			pr_warn("Unable to mount rootfs at %s, error %d.\n",
+				root_device_name, err);
+			pr_warn("Attempting %s for recovery as requested.\n",
+				recovery_device_name);
+
+			err = create_dev("/dev/root", ROOT_DEV);
+			if (err < 0)
+				pr_emerg("Failed to re-create /dev/root: %d\n",
+					err);
+
+			root_device_name = recovery_device_name;
+			goto retry;
+		}
+
+		/*
 		 * Allow the user to distinguish between failed sys_open
 		 * and bad superblock on root device.
 		 * and give them a list of the available devices
@@ -409,28 +448,24 @@ retry:
 #ifdef CONFIG_BLOCK
 		__bdevname(ROOT_DEV, b);
 #endif
-		printk("VFS: Cannot open root device \"%s\" or %s: error %d\n",
+		pr_emerg("VFS: Cannot open root device \"%s\" or %s: error %d\n",
 				root_device_name, b, err);
-		printk("Please append a correct \"root=\" boot option; here are the available partitions:\n");
+		pr_emerg("Please append a correct \"root=\" boot option; here are the available partitions:\n");
 
 		printk_all_partitions();
 #ifdef CONFIG_DEBUG_BLOCK_EXT_DEVT
-		printk("DEBUG_BLOCK_EXT_DEVT is enabled, you need to specify "
+		pr_emerg("DEBUG_BLOCK_EXT_DEVT is enabled, you need to specify "
 		       "explicit textual name for \"root=\" boot option.\n");
 #endif
 		panic("VFS: Unable to mount root fs on %s", b);
 	}
-	if (!(flags & MS_RDONLY)) {
-		flags |= MS_RDONLY;
-		goto retry;
-	}
 
-	printk("List of all partitions:\n");
+	pr_emerg("List of all partitions:\n");
 	printk_all_partitions();
-	printk("No filesystem could mount root, tried: ");
+	pr_emerg("No filesystem could mount root, tried: ");
 	for (p = fs_names; *p; p += strlen(p)+1)
-		printk(" %s", p);
-	printk("\n");
+		pr_emerg(" %s", p);
+	pr_emerg("\n");
 #ifdef CONFIG_BLOCK
 	__bdevname(ROOT_DEV, b);
 #endif
@@ -567,6 +602,9 @@ void __init prepare_namespace(void)
 
 	md_run_setup();
 
+	if (saved_recovery_name[0])
+		recovery_device_name = saved_recovery_name;
+
 	if (saved_root_name[0]) {
 		root_device_name = saved_root_name;
 		if (!strncmp(root_device_name, "mtd", 3) ||
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
