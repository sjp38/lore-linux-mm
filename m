Date: Sun, 5 Aug 2007 10:18:13 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] add noatime/atime boot options, CONFIG_DEFAULT_NOATIME
Message-ID: <20070805081812.GA13572@elte.hu>
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070804191205.GA24723@lazybastard.org> <20070804192130.GA25346@elte.hu> <20070804192615.GA25600@lazybastard.org> <alpine.LFD.0.999.0708041246530.5037@woody.linux-foundation.org> <20070804200038.GA31017@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070804200038.GA31017@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: J?rn Engel <joern@logfs.org>, Jeff Garzik <jeff@garzik.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

here's an updated patch that implements a full spectrum of config, boot 
and sysctl parameters to make it easy for users and distros to make 
noatime the default. Tested on ext3, with and without atime.

for compatibility reasons the config option defaults to disabled, so 
this patch has no impact by default. If CONFIG_DEFAULT_NOATIME is 
enabled for a kernel then all filesystems will be noatime mounted. The 
boot and sysctl options are available unconditionally.

	Ingo

---------------------------->
Subject: [patch] add noatime/atime boot options, CONFIG_DEFAULT_NOATIME
From: Ingo Molnar <mingo@elte.hu>

add the "noatime" (and "atime") boot options to enable/disable atime
updates for all filesystems.

also add the CONFIG_DEFAULT_NOATIME kernel option (disabled by default
for compatibility reasons), which makes "noatime" the default for all
mounts without an extra kernel boot option.

also add the /proc/sys/kernel/mount_with_atime flag which can be changed
runtime to modify the behavior of subsequent new mounts.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 Documentation/kernel-parameters.txt |   12 +++++++
 fs/Kconfig                          |   21 +++++++++++++
 fs/namespace.c                      |   56 ++++++++++++++++++++++++++++++++++++
 include/linux/mount.h               |    2 +
 kernel/sysctl.c                     |    9 +++++
 5 files changed, 100 insertions(+)

Index: linux/Documentation/kernel-parameters.txt
===================================================================
--- linux.orig/Documentation/kernel-parameters.txt
+++ linux/Documentation/kernel-parameters.txt
@@ -303,6 +303,12 @@ and is between 256 and 4096 characters. 
 
 	atascsi=	[HW,SCSI] Atari SCSI
 
+	atime           [FS] default to enabled atime updates on all
+			filesystems.
+
+	atime=          [FS] default to enabled/disabled atime updates on all
+			filesystems.
+
 	atkbd.extra=	[HW] Enable extra LEDs and keys on IBM RapidAccess,
 			EzKey and similar keyboards
 
@@ -1100,6 +1106,12 @@ and is between 256 and 4096 characters. 
 	noasync		[HW,M68K] Disables async and sync negotiation for
 			all devices.
 
+	noatime         [FS] default to disabled atime updates on all
+			filesystems.
+
+	noatime=        [FS] default to disabled/enabled atime updates on all
+			filesystems.
+
 	nobats		[PPC] Do not use BATs for mapping kernel lowmem
 			on "Classic" PPC cores.
 
Index: linux/fs/Kconfig
===================================================================
--- linux.orig/fs/Kconfig
+++ linux/fs/Kconfig
@@ -2060,6 +2060,27 @@ config 9P_FS
 
 endmenu
 
+config DEFAULT_NOATIME
+	bool "Mount all filesystems with noatime by default"
+	help
+	  If you say Y here, all your filesystems will be mounted
+	  with the "noatime" mount option. This eliminates atime
+	  ('file last accessed' timestamp) updates (which otherwise
+	  is performed on every file access and generates a write
+	  IO to the inode) and thus speeds up IO.
+
+	  The mtime ('file last modified') and ctime ('file created')
+	  timestamp are unaffected by this change.
+
+	  Note: the overwhelming majority of applications make no
+	  use of atime. Known exceptions: the Mutt mail client can
+	  depend on it (for new mail notification) on multi-user
+	  machines and some HSM backup tools might also work better
+	  in the presence of atime.
+
+	  Use the "atime" kernel boot option to turn off this
+	  feature.
+
 if BLOCK
 menu "Partition Types"
 
Index: linux/fs/namespace.c
===================================================================
--- linux.orig/fs/namespace.c
+++ linux/fs/namespace.c
@@ -1362,6 +1362,60 @@ int copy_mount_options(const void __user
 }
 
 /*
+ * Allow users to disable (or enable) atime updates via a .config
+ * option or via the boot line, or via /proc/sys/fs/mount_with_atime:
+ */
+int mount_with_atime __read_mostly =
+#ifdef CONFIG_DEFAULT_NOATIME
+0
+#else
+1
+#endif
+;
+
+/*
+ * The "noatime=", "atime=", "noatime" and "atime" boot parameters:
+ */
+static int toggle_atime_updates(int val)
+{
+	mount_with_atime = val;
+
+	printk("Atime updates are: %s\n", val ? "on" : "off");
+
+	return 1;
+}
+
+static int __init set_atime_setup(char *str)
+{
+	int val;
+
+	get_option(&str, &val);
+	return toggle_atime_updates(val);
+}
+__setup("atime=", set_atime_setup);
+
+static int __init set_noatime_setup(char *str)
+{
+	int val;
+
+	get_option(&str, &val);
+	return toggle_atime_updates(!val);
+}
+__setup("noatime=", set_noatime_setup);
+
+static int __init set_atime(char *str)
+{
+	return toggle_atime_updates(1);
+}
+__setup("atime", set_atime);
+
+static int __init set_noatime(char *str)
+{
+	return toggle_atime_updates(0);
+}
+__setup("noatime", set_noatime);
+
+/*
  * Flags is a 32-bit value that allows up to 31 non-fs dependent flags to
  * be given to the mount() call (ie: read-only, no-dev, no-suid etc).
  *
@@ -1409,6 +1463,8 @@ long do_mount(char *dev_name, char *dir_
 		mnt_flags |= MNT_NODIRATIME;
 	if (flags & MS_RELATIME)
 		mnt_flags |= MNT_RELATIME;
+	if (!mount_with_atime && !(flags & (MNT_NOATIME | MNT_NODIRATIME)))
+		mnt_flags |= MNT_NOATIME;
 
 	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE |
 		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME);
Index: linux/include/linux/mount.h
===================================================================
--- linux.orig/include/linux/mount.h
+++ linux/include/linux/mount.h
@@ -103,5 +103,7 @@ extern void shrink_submounts(struct vfsm
 extern spinlock_t vfsmount_lock;
 extern dev_t name_to_dev_t(char *name);
 
+extern int mount_with_atime;
+
 #endif
 #endif /* _LINUX_MOUNT_H */
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c
+++ linux/kernel/sysctl.c
@@ -30,6 +30,7 @@
 #include <linux/capability.h>
 #include <linux/smp_lock.h>
 #include <linux/fs.h>
+#include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/kobject.h>
@@ -1206,6 +1207,14 @@ static ctl_table fs_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "mount_with_atime",
+		.data		= &mount_with_atime,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #if defined(CONFIG_BINFMT_MISC) || defined(CONFIG_BINFMT_MISC_MODULE)
 	{
 		.ctl_name	= CTL_UNNUMBERED,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
