Date: Sun, 5 Aug 2007 21:09:28 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805190928.GA17433@elte.hu>
References: <20070804103347.GA1956@elte.hu> <alpine.LFD.0.999.0708040915360.5037@woody.linux-foundation.org> <20070804163733.GA31001@elte.hu> <alpine.LFD.0.999.0708041030040.5037@woody.linux-foundation.org> <46B4C0A8.1000902@garzik.org> <20070805102021.GA4246@unthought.net> <46B5A996.5060006@garzik.org> <20070805105850.GC4246@unthought.net> <20070805124648.GA21173@elte.hu> <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708050944470.5037@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jakob Oestergaard <jakob@unthought.net>, Jeff Garzik <jeff@garzik.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, 5 Aug 2007, Ingo Molnar wrote:
> > 
> > you mean tmpwatch? The trivial change below fixes this. And with that 
> > we've come to the end of an extremely short list of atime dependencies.
> 
> You wouldn't even need these kinds of games.
> 
> What we could do is to make "relatime" updates a bit smarter.
> 
> A bit smarter would be:
> 
>  - update atime if the old atime is <= than mtime/ctime
> 
>    Logic: things like mailers can care about whether some new state has 
>    been read or not. This is the current relatime.
> 
>  - update atime if the old atime is more than X seconds in the past 
>    (defaulting to one day or something)
> 
>    Logic: things like tmpwatch and backup software may want to remove 
>    stuff that hasn't been touched in a long time, but they sure don't care 
>    about "exact" atime.

ok, i've implemented this and it's working fine. Check out the 
relatime_need_update() function for the details of the logic. Atime 
update frequency is 1 day with that, and we update at least once after 
every modification as well, for the mailer logic.

tested it by moving the date forward:

  # date
  Sun Aug  5 22:55:14 CEST 2007
  # date -s "Tue Aug  7 22:55:14 CEST 2007"
  Tue Aug  7 22:55:14 CEST 2007

access to a file did not generate disk IO before the date was set, and 
it generated exactly one IO after the date was set.

( should i perhaps reduce the number of boot options and only use a
  single "norelatime_default" boot option to turn this off? )

	Ingo

------------------------------------>
Subject: [patch] add norelatime/relatime boot options, CONFIG_DEFAULT_RELATIME
From: Ingo Molnar <mingo@elte.hu>

change relatime updates to be performed once per day. This makes
relatime a compatible solution for HSM, mailer-notification and
tmpwatch applications too.

also add the CONFIG_DEFAULT_RELATIME kernel option, which makes
"norelatime" the default for all mounts without an extra kernel
boot option.

add the "norelatime" (and "relatime") boot options to enable/disable
relatime updates for all filesystems.

also add the /proc/sys/kernel/mount_with_relatime flag which can be changed
runtime to modify the behavior of subsequent new mounts.

tested by moving the date forward:

   # date
   Sun Aug  5 22:55:14 CEST 2007
   # date -s "Tue Aug  7 22:55:14 CEST 2007"
   Tue Aug  7 22:55:14 CEST 2007

access to a file did not generate disk IO before the date was set, and
it generated exactly one IO after the date was set.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 Documentation/kernel-parameters.txt |   12 +++++++
 fs/Kconfig                          |   17 ++++++++++
 fs/inode.c                          |   48 ++++++++++++++++++++--------
 fs/namespace.c                      |   61 ++++++++++++++++++++++++++++++++++++
 include/linux/mount.h               |    2 +
 kernel/sysctl.c                     |    9 +++++
 6 files changed, 136 insertions(+), 13 deletions(-)

Index: linux/Documentation/kernel-parameters.txt
===================================================================
--- linux.orig/Documentation/kernel-parameters.txt
+++ linux/Documentation/kernel-parameters.txt
@@ -303,6 +303,12 @@ and is between 256 and 4096 characters. 
 
 	atascsi=	[HW,SCSI] Atari SCSI
 
+	relatime        [FS] default to enabled relatime updates on all
+			filesystems.
+
+	relatime=       [FS] default to enabled/disabled relatime updates on
+			all filesystems.
+
 	atkbd.extra=	[HW] Enable extra LEDs and keys on IBM RapidAccess,
 			EzKey and similar keyboards
 
@@ -1100,6 +1106,12 @@ and is between 256 and 4096 characters. 
 	noasync		[HW,M68K] Disables async and sync negotiation for
 			all devices.
 
+	norelatime      [FS] default to disabled relatime updates on all
+			filesystems.
+
+	norelatime=     [FS] default to disabled/enabled relatime updates
+			on all filesystems.
+
 	nobats		[PPC] Do not use BATs for mapping kernel lowmem
 			on "Classic" PPC cores.
 
Index: linux/fs/Kconfig
===================================================================
--- linux.orig/fs/Kconfig
+++ linux/fs/Kconfig
@@ -2060,6 +2060,23 @@ config 9P_FS
 
 endmenu
 
+config DEFAULT_RELATIME
+	bool "Mount all filesystems with relatime by default"
+	default y
+	help
+	  If you say Y here, all your filesystems will be mounted
+	  with the "relatime" mount option. This eliminates many atime
+	  ('file last accessed' timestamp) updates (which otherwise
+	  is performed on every file access and generates a write
+	  IO to the inode) and thus speeds up IO. Atime is still updated,
+	  but only once per day.
+
+	  The mtime ('file last modified') and ctime ('file created')
+	  timestamp are unaffected by this change.
+
+	  Use the "norelatime" kernel boot option to turn off this
+	  feature.
+
 if BLOCK
 menu "Partition Types"
 
Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c
+++ linux/fs/inode.c
@@ -1162,6 +1162,36 @@ sector_t bmap(struct inode * inode, sect
 }
 EXPORT_SYMBOL(bmap);
 
+/*
+ * With relative atime, only update atime if the
+ * previous atime is earlier than either the ctime or
+ * mtime.
+ */
+static int relatime_need_update(struct inode *inode, struct timespec now)
+{
+	/*
+	 * Is mtime younger than atime? If yes, update atime:
+	 */
+	if (timespec_compare(&inode->i_mtime, &inode->i_atime) >= 0)
+		return 1;
+	/*
+	 * Is ctime younger than atime? If yes, update atime:
+	 */
+	if (timespec_compare(&inode->i_ctime, &inode->i_atime) >= 0)
+		return 1;
+
+	/*
+	 * Is the previous atime value older than a day? If yes,
+	 * update atime:
+	 */
+	if ((long)(now.tv_sec - inode->i_atime.tv_sec) >= 24*60*60)
+		return 1;
+	/*
+	 * Good, we can skip the atime update:
+	 */
+	return 0;
+}
+
 /**
  *	touch_atime	-	update the access time
  *	@mnt: mount the inode is accessed on
@@ -1191,22 +1221,14 @@ void touch_atime(struct vfsmount *mnt, s
 			return;
 		if ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode))
 			return;
-
-		if (mnt->mnt_flags & MNT_RELATIME) {
-			/*
-			 * With relative atime, only update atime if the
-			 * previous atime is earlier than either the ctime or
-			 * mtime.
-			 */
-			if (timespec_compare(&inode->i_mtime,
-						&inode->i_atime) < 0 &&
-			    timespec_compare(&inode->i_ctime,
-						&inode->i_atime) < 0)
+	}
+	now = current_fs_time(inode->i_sb);
+	if (mnt) {
+		if (mnt->mnt_flags & MNT_RELATIME)
+			if (!relatime_need_update(inode, now))
 				return;
-		}
 	}
 
-	now = current_fs_time(inode->i_sb);
 	if (timespec_equal(&inode->i_atime, &now))
 		return;
 
Index: linux/fs/namespace.c
===================================================================
--- linux.orig/fs/namespace.c
+++ linux/fs/namespace.c
@@ -1107,6 +1107,8 @@ int do_add_mount(struct vfsmount *newmnt
 		goto unlock;
 
 	newmnt->mnt_flags = mnt_flags;
+	WARN_ON_ONCE(newmnt->mnt_flags & MNT_RELATIME);
+
 	if ((err = graft_tree(newmnt, nd)))
 		goto unlock;
 
@@ -1362,6 +1364,60 @@ int copy_mount_options(const void __user
 }
 
 /*
+ * Allow users to disable (or enable) atime updates via a .config
+ * option or via the boot line, or via /proc/sys/fs/mount_with_relatime:
+ */
+int mount_with_relatime __read_mostly =
+#ifdef CONFIG_DEFAULT_RELATIME
+1
+#else
+0
+#endif
+;
+
+/*
+ * The "norelatime=", "atime=", "norelatime" and "relatime" boot parameters:
+ */
+static int toggle_relatime_updates(int val)
+{
+	mount_with_relatime = val;
+
+	printk("Relative atime updates are: %s\n", val ? "on" : "off");
+
+	return 1;
+}
+
+static int __init set_relatime_setup(char *str)
+{
+	int val;
+
+	get_option(&str, &val);
+	return toggle_relatime_updates(val);
+}
+__setup("relatime=", set_relatime_setup);
+
+static int __init set_norelatime_setup(char *str)
+{
+	int val;
+
+	get_option(&str, &val);
+	return toggle_relatime_updates(!val);
+}
+__setup("norelatime=", set_norelatime_setup);
+
+static int __init set_relatime(char *str)
+{
+	return toggle_relatime_updates(1);
+}
+__setup("relatime", set_relatime);
+
+static int __init set_norelatime(char *str)
+{
+	return toggle_relatime_updates(0);
+}
+__setup("norelatime", set_norelatime);
+
+/*
  * Flags is a 32-bit value that allows up to 31 non-fs dependent flags to
  * be given to the mount() call (ie: read-only, no-dev, no-suid etc).
  *
@@ -1409,6 +1465,11 @@ long do_mount(char *dev_name, char *dir_
 		mnt_flags |= MNT_NODIRATIME;
 	if (flags & MS_RELATIME)
 		mnt_flags |= MNT_RELATIME;
+	else if (mount_with_relatime &&
+				!(flags & (MNT_NOATIME | MNT_NODIRATIME))) {
+		mnt_flags |= MNT_RELATIME;
+		flags |= MS_RELATIME;
+	}
 
 	flags &= ~(MS_NOSUID | MS_NOEXEC | MS_NODEV | MS_ACTIVE |
 		   MS_NOATIME | MS_NODIRATIME | MS_RELATIME);
Index: linux/include/linux/mount.h
===================================================================
--- linux.orig/include/linux/mount.h
+++ linux/include/linux/mount.h
@@ -103,5 +103,7 @@ extern void shrink_submounts(struct vfsm
 extern spinlock_t vfsmount_lock;
 extern dev_t name_to_dev_t(char *name);
 
+extern int mount_with_relatime;
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
+		.procname	= "mount_with_relatime",
+		.data		= &mount_with_relatime,
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
