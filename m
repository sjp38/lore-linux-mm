Subject: Re: [PATCH] slub: reduce total stack usage of slab_err & object_err
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1222791638.2995.41.camel@castor.localdomain>
References: <1222787736.2995.24.camel@castor.localdomain>
	 <48E2480A.9090003@linux-foundation.org>
	 <1222791638.2995.41.camel@castor.localdomain>
Content-Type: text/plain
Date: Tue, 30 Sep 2008 11:43:15 -0500
Message-Id: <1222792996.23159.32.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-30 at 17:20 +0100, Richard Kennedy wrote:
> On Tue, 2008-09-30 at 10:38 -0500, Christoph Lameter wrote:
> > Richard Kennedy wrote:
> > > reduce the total stack usage of slab_err & object_err.
> > > 
> > > Introduce a new function to display a simple slab bug message, and call
> > > this when vprintk is not needed.
> > 
> > You could simply get rid of the 100 byte buffer by using vprintk? Same method
> > could be used elsewhere in the kernel and does not require additional
> > functions.

(Funny, I added vprintk precisely to fix the extra buffer issue in
ext2/3 years ago, but never hit the rest of the kernel..)

Use vprintk rather that vsnprintf where possible

This does away with lots of large static and on-stack buffers as well
as a few associated locks.

Signed-off-by: Matt Mackall <mpm@selenic.com>

diff -r 6841f3ce32be -r 9ac0727d59d8 drivers/cpufreq/cpufreq.c
--- a/drivers/cpufreq/cpufreq.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/drivers/cpufreq/cpufreq.c	Tue Sep 30 11:37:30 2008 -0500
@@ -220,9 +220,7 @@
 void cpufreq_debug_printk(unsigned int type, const char *prefix,
 			const char *fmt, ...)
 {
-	char s[256];
 	va_list args;
-	unsigned int len;
 	unsigned long flags;
 
 	WARN_ON(!prefix);
@@ -235,15 +233,10 @@
 		}
 		spin_unlock_irqrestore(&disable_ratelimit_lock, flags);
 
-		len = snprintf(s, 256, KERN_DEBUG "%s: ", prefix);
-
 		va_start(args, fmt);
-		len += vsnprintf(&s[len], (256 - len), fmt, args);
+		printk(KERN_DEBUG "%s: ", prefix);
+		vprintk(fmt, args);
 		va_end(args);
-
-		printk(s);
-
-		WARN_ON(len < 5);
 	}
 }
 EXPORT_SYMBOL(cpufreq_debug_printk);
diff -r 6841f3ce32be -r 9ac0727d59d8 drivers/scsi/arm/fas216.c
--- a/drivers/scsi/arm/fas216.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/drivers/scsi/arm/fas216.c	Tue Sep 30 11:37:30 2008 -0500
@@ -290,10 +290,8 @@
 static void
 fas216_do_log(FAS216_Info *info, char target, char *fmt, va_list ap)
 {
-	static char buf[1024];
-
-	vsnprintf(buf, sizeof(buf), fmt, ap);
-	printk("scsi%d.%c: %s", info->host->host_no, target, buf);
+	printk("scsi%d.%c: ", info->host->host_no, target, buf);
+	vprintk(fmt, ap);
 }
 
 static void fas216_log_command(FAS216_Info *info, int level,
diff -r 6841f3ce32be -r 9ac0727d59d8 drivers/scsi/nsp32.c
--- a/drivers/scsi/nsp32.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/drivers/scsi/nsp32.c	Tue Sep 30 11:37:30 2008 -0500
@@ -323,36 +323,31 @@
 #define NSP32_DEBUG_INIT		BIT(17)
 #define NSP32_SPECIAL_PRINT_REGISTER	BIT(20)
 
-#define NSP32_DEBUG_BUF_LEN		100
-
 static void nsp32_message(const char *func, int line, char *type, char *fmt, ...)
 {
 	va_list args;
-	char buf[NSP32_DEBUG_BUF_LEN];
-
 	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
+#ifndef NSP32_DEBUG
+	printk("%snsp32: ", type);
+#else
+	printk("%snsp32: %s (%d): ", type, func, line);
+#endif
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-#ifndef NSP32_DEBUG
-	printk("%snsp32: %s\n", type, buf);
-#else
-	printk("%snsp32: %s (%d): %s\n", type, func, line, buf);
-#endif
 }
 
 #ifdef NSP32_DEBUG
 static void nsp32_dmessage(const char *func, int line, int mask, char *fmt, ...)
 {
 	va_list args;
-	char buf[NSP32_DEBUG_BUF_LEN];
-
-	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
-	va_end(args);
 
 	if (mask & NSP32_DEBUG_MASK) {
-		printk("nsp32-debug: 0x%x %s (%d): %s\n", mask, func, line, buf);
+		va_start(args, fmt);
+		printk("nsp32-debug: 0x%x %s (%d): ", mask, func, line);
+		vprintk(fmt, args);
+		printk("\n");
+		va_end(args);
 	}
 }
 #endif
diff -r 6841f3ce32be -r 9ac0727d59d8 drivers/scsi/pcmcia/nsp_cs.c
--- a/drivers/scsi/pcmcia/nsp_cs.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/drivers/scsi/pcmcia/nsp_cs.c	Tue Sep 30 11:37:30 2008 -0500
@@ -132,8 +132,6 @@
 #define NSP_DEBUG_DATA_IO      		BIT(18)
 #define NSP_SPECIAL_PRINT_REGISTER	BIT(20)
 
-#define NSP_DEBUG_BUF_LEN		150
-
 static inline void nsp_inc_resid(struct scsi_cmnd *SCpnt, int residInc)
 {
 	scsi_set_resid(SCpnt, scsi_get_resid(SCpnt) + residInc);
@@ -142,31 +140,28 @@
 static void nsp_cs_message(const char *func, int line, char *type, char *fmt, ...)
 {
 	va_list args;
-	char buf[NSP_DEBUG_BUF_LEN];
 
 	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
+#ifndef NSP_DEBUG
+	printk("%snsp_cs: ", type);
+#else
+	printk("%snsp_cs: %s (%d): ", type, func);
+#endif
+	vprintk(fmt, args);
 	va_end(args);
-
-#ifndef NSP_DEBUG
-	printk("%snsp_cs: %s\n", type, buf);
-#else
-	printk("%snsp_cs: %s (%d): %s\n", type, func, line, buf);
-#endif
 }
 
 #ifdef NSP_DEBUG
 static void nsp_cs_dmessage(const char *func, int line, int mask, char *fmt, ...)
 {
 	va_list args;
-	char buf[NSP_DEBUG_BUF_LEN];
-
-	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
-	va_end(args);
 
 	if (mask & NSP_DEBUG_MASK) {
-		printk("nsp_cs-debug: 0x%x %s (%d): %s\n", mask, func, line, buf);
+		va_start(args, fmt);
+		printk("nsp_cs-debug: 0x%x %s (%d): ", mask, func, line);
+		vprintk(fmt, args);
+		printk("\n");
+		va_end(args);
 	}
 }
 #endif
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/adfs/super.c
--- a/fs/adfs/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/adfs/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -37,16 +37,14 @@
 
 void __adfs_error(struct super_block *sb, const char *function, const char *fmt, ...)
 {
-	char error_buf[128];
 	va_list args;
-
 	va_start(args, fmt);
-	vsnprintf(error_buf, sizeof(error_buf), fmt, args);
+	printk(KERN_CRIT "ADFS-fs error (device %s)%s%s: ",
+		sb->s_id, function ? ": " : "",
+		function ? function : "");
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_CRIT "ADFS-fs error (device %s)%s%s: %s\n",
-		sb->s_id, function ? ": " : "",
-		function ? function : "", error_buf);
 }
 
 static int adfs_checkdiscrecord(struct adfs_discrecord *dr)
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/affs/amigaffs.c
--- a/fs/affs/amigaffs.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/affs/amigaffs.c	Tue Sep 30 11:37:30 2008 -0500
@@ -11,8 +11,6 @@
 #include "affs.h"
 
 extern struct timezone sys_tz;
-
-static char ErrorBuffer[256];
 
 /*
  * Functions for accessing Amiga-FFS structures.
@@ -444,14 +442,13 @@
 void
 affs_error(struct super_block *sb, const char *function, const char *fmt, ...)
 {
-	va_list	 args;
-
+	va_list	args;
 	va_start(args,fmt);
-	vsnprintf(ErrorBuffer,sizeof(ErrorBuffer),fmt,args);
+	printk(KERN_CRIT "AFFS error (device %s): %s(): ", sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
 
-	printk(KERN_CRIT "AFFS error (device %s): %s(): %s\n", sb->s_id,
-		function,ErrorBuffer);
 	if (!(sb->s_flags & MS_RDONLY))
 		printk(KERN_WARNING "AFFS: Remounting filesystem read-only\n");
 	sb->s_flags |= MS_RDONLY;
@@ -460,14 +457,13 @@
 void
 affs_warning(struct super_block *sb, const char *function, const char *fmt, ...)
 {
-	va_list	 args;
-
+	va_list	args;
 	va_start(args,fmt);
-	vsnprintf(ErrorBuffer,sizeof(ErrorBuffer),fmt,args);
+	printk(KERN_WARNING "AFFS warning (device %s): %s(): ", sb->s_id,
+		function);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_WARNING "AFFS warning (device %s): %s(): %s\n", sb->s_id,
-		function,ErrorBuffer);
 }
 
 /* Check if the name is valid for a affs object. */
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/befs/debug.c
--- a/fs/befs/debug.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/befs/debug.c	Tue Sep 30 11:37:30 2008 -0500
@@ -22,70 +22,41 @@
 
 #include "befs.h"
 
-#define ERRBUFSIZE 1024
-
 void
 befs_error(const struct super_block *sb, const char *fmt, ...)
 {
 	va_list args;
-	char *err_buf = kmalloc(ERRBUFSIZE, GFP_KERNEL);
-	if (err_buf == NULL) {
-		printk(KERN_ERR "could not allocate %d bytes\n", ERRBUFSIZE);
-		return;
-	}
-
 	va_start(args, fmt);
-	vsnprintf(err_buf, ERRBUFSIZE, fmt, args);
+	printk(KERN_ERR "BeFS(%s): ", sb->s_id);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_ERR "BeFS(%s): %s\n", sb->s_id, err_buf);
-	kfree(err_buf);
 }
 
 void
 befs_warning(const struct super_block *sb, const char *fmt, ...)
 {
 	va_list args;
-	char *err_buf = kmalloc(ERRBUFSIZE, GFP_KERNEL);
-	if (err_buf == NULL) {
-		printk(KERN_ERR "could not allocate %d bytes\n", ERRBUFSIZE);
-		return;
-	}
-
 	va_start(args, fmt);
-	vsnprintf(err_buf, ERRBUFSIZE, fmt, args);
+	printk(KERN_WARNING "BeFS(%s): %s\n", sb->s_id);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_WARNING "BeFS(%s): %s\n", sb->s_id, err_buf);
-
-	kfree(err_buf);
 }
 
 void
 befs_debug(const struct super_block *sb, const char *fmt, ...)
 {
 #ifdef CONFIG_BEFS_DEBUG
-
 	va_list args;
-	char *err_buf = NULL;
 
 	if (BEFS_SB(sb)->mount_opts.debug) {
-		err_buf = kmalloc(ERRBUFSIZE, GFP_KERNEL);
-		if (err_buf == NULL) {
-			printk(KERN_ERR "could not allocate %d bytes\n",
-				ERRBUFSIZE);
-			return;
-		}
-
 		va_start(args, fmt);
-		vsnprintf(err_buf, ERRBUFSIZE, fmt, args);
+		printk(KERN_DEBUG "BeFS(%s): ", sb->s_id);
+		vprintk(fmt, args);
+		printk("\n");
 		va_end(args);
-
-		printk(KERN_DEBUG "BeFS(%s): %s\n", sb->s_id, err_buf);
-
-		kfree(err_buf);
 	}
-
 #endif				//CONFIG_BEFS_DEBUG
 }
 
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/hpfs/super.c
--- a/fs/hpfs/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/hpfs/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -46,18 +46,15 @@
 	}
 }
 
-/* Filesystem error... */
-static char err_buf[1024];
-
 void hpfs_error(struct super_block *s, const char *fmt, ...)
 {
 	va_list args;
 
 	va_start(args, fmt);
-	vsnprintf(err_buf, sizeof(err_buf), fmt, args);
+	printk("HPFS: filesystem error: ");
+	vprintk(fmt, args);
 	va_end(args);
 
-	printk("HPFS: filesystem error: %s", err_buf);
 	if (!hpfs_sb(s)->sb_was_error) {
 		if (hpfs_sb(s)->sb_err == 2) {
 			printk("; crashing the system because you wanted it\n");
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/jfs/super.c
--- a/fs/jfs/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/jfs/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -91,14 +91,13 @@
 
 void jfs_error(struct super_block *sb, const char * function, ...)
 {
-	static char error_buf[256];
 	va_list args;
 
 	va_start(args, function);
-	vsnprintf(error_buf, sizeof(error_buf), function, args);
+	printk(KERN_ERR "ERROR: (device %s): ", sb->s_id);
+	vprintk(function, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_ERR "ERROR: (device %s): %s\n", sb->s_id, error_buf);
 
 	jfs_handle_error(sb);
 }
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/ntfs/debug.c
--- a/fs/ntfs/debug.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/ntfs/debug.c	Tue Sep 30 11:37:30 2008 -0500
@@ -20,13 +20,6 @@
  */
 
 #include "debug.h"
-
-/*
- * A static buffer to hold the error string being displayed and a spinlock
- * to protect concurrent accesses to it.
- */
-static char err_buf[1024];
-static DEFINE_SPINLOCK(err_buf_lock);
 
 /**
  * __ntfs_warning - output a warning to the syslog
@@ -59,17 +52,16 @@
 #endif
 	if (function)
 		flen = strlen(function);
-	spin_lock(&err_buf_lock);
 	va_start(args, fmt);
-	vsnprintf(err_buf, sizeof(err_buf), fmt, args);
+	if (sb)
+		printk(KERN_ERR "NTFS-fs warning (device %s): %s(): ",
+				sb->s_id, flen ? function : "");
+	else
+		printk(KERN_ERR "NTFS-fs warning: %s(): ",
+				flen ? function : "");
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	if (sb)
-		printk(KERN_ERR "NTFS-fs warning (device %s): %s(): %s\n",
-				sb->s_id, flen ? function : "", err_buf);
-	else
-		printk(KERN_ERR "NTFS-fs warning: %s(): %s\n",
-				flen ? function : "", err_buf);
-	spin_unlock(&err_buf_lock);
 }
 
 /**
@@ -103,17 +95,16 @@
 #endif
 	if (function)
 		flen = strlen(function);
-	spin_lock(&err_buf_lock);
 	va_start(args, fmt);
-	vsnprintf(err_buf, sizeof(err_buf), fmt, args);
+	if (sb)
+		printk(KERN_ERR "NTFS-fs error (device %s): %s(): ",
+				sb->s_id, flen ? function : "");
+	else
+		printk(KERN_ERR "NTFS-fs error: %s(): ",
+				flen ? function : "");
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	if (sb)
-		printk(KERN_ERR "NTFS-fs error (device %s): %s(): %s\n",
-				sb->s_id, flen ? function : "", err_buf);
-	else
-		printk(KERN_ERR "NTFS-fs error: %s(): %s\n",
-				flen ? function : "", err_buf);
-	spin_unlock(&err_buf_lock);
 }
 
 #ifdef DEBUG
@@ -131,13 +122,12 @@
 		return;
 	if (function)
 		flen = strlen(function);
-	spin_lock(&err_buf_lock);
 	va_start(args, fmt);
-	vsnprintf(err_buf, sizeof(err_buf), fmt, args);
+	printk(KERN_DEBUG "NTFS-fs DEBUG (%s, %d): %s(): ", file, line,
+			flen ? function : "");
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	printk(KERN_DEBUG "NTFS-fs DEBUG (%s, %d): %s(): %s\n", file, line,
-			flen ? function : "", err_buf);
-	spin_unlock(&err_buf_lock);
 }
 
 /* Dump a runlist. Caller has to provide synchronisation for @rl. */
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/ocfs2/super.c
--- a/fs/ocfs2/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/ocfs2/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -1817,22 +1817,20 @@
 	ocfs2_set_ro_flag(osb, 0);
 }
 
-static char error_buf[1024];
-
 void __ocfs2_error(struct super_block *sb,
 		   const char *function,
 		   const char *fmt, ...)
 {
 	va_list args;
 
-	va_start(args, fmt);
-	vsnprintf(error_buf, sizeof(error_buf), fmt, args);
-	va_end(args);
-
 	/* Not using mlog here because we want to show the actual
 	 * function the error came from. */
-	printk(KERN_CRIT "OCFS2: ERROR (device %s): %s: %s\n",
-	       sb->s_id, function, error_buf);
+	va_start(args, fmt);
+	printk(KERN_CRIT "OCFS2: ERROR (device %s): %s: ",
+	       sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
+	va_end(args);
 
 	ocfs2_handle_error(sb);
 }
@@ -1847,11 +1845,11 @@
 	va_list args;
 
 	va_start(args, fmt);
-	vsnprintf(error_buf, sizeof(error_buf), fmt, args);
+	printk(KERN_CRIT "OCFS2: abort (device %s): %s: ",
+	       sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-
-	printk(KERN_CRIT "OCFS2: abort (device %s): %s: %s\n",
-	       sb->s_id, function, error_buf);
 
 	/* We don't have the cluster support yet to go straight to
 	 * hard readonly in here. Until then, we want to keep
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/partitions/ldm.c
--- a/fs/partitions/ldm.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/partitions/ldm.c	Tue Sep 30 11:37:30 2008 -0500
@@ -52,14 +52,13 @@
 static void _ldm_printk (const char *level, const char *function,
 			 const char *fmt, ...)
 {
-	static char buf[128];
 	va_list args;
 
 	va_start (args, fmt);
-	vsnprintf (buf, sizeof (buf), fmt, args);
+	printk("%s%s(): ", level, function, buf);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end (args);
-
-	printk ("%s%s(): %s\n", level, function, buf);
 }
 
 /**
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/udf/super.c
--- a/fs/udf/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/udf/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -75,8 +75,6 @@
 #define VDS_POS_LENGTH			7
 
 #define UDF_DEFAULT_BLOCKSIZE 2048
-
-static char error_buf[1024];
 
 /* These are the "meat" - everything else is stuffing */
 static int udf_fill_super(struct super_block *, void *, int);
@@ -2040,10 +2038,11 @@
 		sb->s_dirt = 1;
 	}
 	va_start(args, fmt);
-	vsnprintf(error_buf, sizeof(error_buf), fmt, args);
+	printk(KERN_CRIT "UDF-fs error (device %s): %s: ",
+		sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	printk(KERN_CRIT "UDF-fs error (device %s): %s: %s\n",
-		sb->s_id, function, error_buf);
 }
 
 void udf_warning(struct super_block *sb, const char *function,
@@ -2052,10 +2051,11 @@
 	va_list args;
 
 	va_start(args, fmt);
-	vsnprintf(error_buf, sizeof(error_buf), fmt, args);
+	printk(KERN_WARNING "UDF-fs warning (device %s): %s: ",
+	       sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	printk(KERN_WARNING "UDF-fs warning (device %s): %s: %s\n",
-	       sb->s_id, function, error_buf);
 }
 
 static void udf_put_super(struct super_block *sb)
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/ufs/super.c
--- a/fs/ufs/super.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/ufs/super.c	Tue Sep 30 11:37:30 2008 -0500
@@ -222,8 +222,6 @@
 
 static const struct super_operations ufs_super_ops;
 
-static char error_buf[1024];
-
 void ufs_error (struct super_block * sb, const char * function,
 	const char * fmt, ...)
 {
@@ -233,27 +231,28 @@
 
 	uspi = UFS_SB(sb)->s_uspi;
 	usb1 = ubh_get_usb_first(uspi);
-	
+
 	if (!(sb->s_flags & MS_RDONLY)) {
 		usb1->fs_clean = UFS_FSBAD;
 		ubh_mark_buffer_dirty(USPI_UBH(uspi));
 		sb->s_dirt = 1;
 		sb->s_flags |= MS_RDONLY;
 	}
-	va_start (args, fmt);
-	vsnprintf (error_buf, sizeof(error_buf), fmt, args);
-	va_end (args);
 	switch (UFS_SB(sb)->s_mount_opt & UFS_MOUNT_ONERROR) {
 	case UFS_MOUNT_ONERROR_PANIC:
-		panic ("UFS-fs panic (device %s): %s: %s\n", 
-			sb->s_id, function, error_buf);
+		panic ("UFS-fs panic (device %s): %s: ",
+			sb->s_id, function);
 
 	case UFS_MOUNT_ONERROR_LOCK:
 	case UFS_MOUNT_ONERROR_UMOUNT:
 	case UFS_MOUNT_ONERROR_REPAIR:
-		printk (KERN_CRIT "UFS-fs error (device %s): %s: %s\n",
-			sb->s_id, function, error_buf);
-	}		
+		printk (KERN_CRIT "UFS-fs error (device %s): %s: ",
+			sb->s_id, function);
+	}
+	va_start(args, fmt);
+	vprintk(fmt, args);
+	printk("\n");
+	va_end(args);
 }
 
 void ufs_panic (struct super_block * sb, const char * function,
@@ -262,21 +261,22 @@
 	struct ufs_sb_private_info * uspi;
 	struct ufs_super_block_first * usb1;
 	va_list args;
-	
+
 	uspi = UFS_SB(sb)->s_uspi;
 	usb1 = ubh_get_usb_first(uspi);
-	
+
 	if (!(sb->s_flags & MS_RDONLY)) {
 		usb1->fs_clean = UFS_FSBAD;
 		ubh_mark_buffer_dirty(USPI_UBH(uspi));
 		sb->s_dirt = 1;
 	}
-	va_start (args, fmt);
-	vsnprintf (error_buf, sizeof(error_buf), fmt, args);
-	va_end (args);
+	va_start(args, fmt);
+	printk(KERN_CRIT "UFS-fs panic (device %s): %s: ",
+		sb->s_id, function);
+	vprintk(fmt, args);
+	printk("\n");
+	va_end(args);
 	sb->s_flags |= MS_RDONLY;
-	printk (KERN_CRIT "UFS-fs panic (device %s): %s: %s\n",
-		sb->s_id, function, error_buf);
 }
 
 void ufs_warning (struct super_block * sb, const char * function,
@@ -284,11 +284,11 @@
 {
 	va_list args;
 
-	va_start (args, fmt);
-	vsnprintf (error_buf, sizeof(error_buf), fmt, args);
-	va_end (args);
-	printk (KERN_WARNING "UFS-fs warning (device %s): %s: %s\n",
-		sb->s_id, function, error_buf);
+	va_start(args, fmt);
+	printk(KERN_WARNING "UFS-fs warning (device %s): %s: ",
+		sb->s_id, function);
+	vprintk(fmt, args);
+	va_end(args);
 }
 
 enum {
diff -r 6841f3ce32be -r 9ac0727d59d8 fs/xfs/support/debug.c
--- a/fs/xfs/support/debug.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/fs/xfs/support/debug.c	Tue Sep 30 11:37:30 2008 -0500
@@ -18,9 +18,6 @@
 #include <xfs.h>
 #include "debug.h"
 
-static char		message[1024];	/* keep it off the stack */
-static DEFINE_SPINLOCK(xfs_err_lock);
-
 /* Translate from CE_FOO to KERN_FOO, err_level(CE_FOO) == KERN_FOO */
 #define XFS_MAX_ERR_LEVEL	7
 #define XFS_ERR_MASK		((1 << 3) - 1)
@@ -40,17 +37,13 @@
 	level &= XFS_ERR_MASK;
 	if (level > XFS_MAX_ERR_LEVEL)
 		level = XFS_MAX_ERR_LEVEL;
-	spin_lock_irqsave(&xfs_err_lock,flags);
+
 	va_start(ap, fmt);
 	if (*fmt == '!') fp++;
-	len = vsnprintf(message, sizeof(message), fp, ap);
-	if (len >= sizeof(message))
-		len = sizeof(message) - 1;
-	if (message[len-1] == '\n')
-		message[len-1] = 0;
-	printk("%s%s\n", err_level[level], message);
+	printk("%s", err_level[level]);
+	vprintk(fp, ap);
+	printk("\n");
 	va_end(ap);
-	spin_unlock_irqrestore(&xfs_err_lock,flags);
 	BUG_ON(level == CE_PANIC);
 }
 
@@ -63,14 +56,9 @@
 	level &= XFS_ERR_MASK;
 	if(level > XFS_MAX_ERR_LEVEL)
 		level = XFS_MAX_ERR_LEVEL;
-	spin_lock_irqsave(&xfs_err_lock,flags);
-	len = vsnprintf(message, sizeof(message), fmt, ap);
-	if (len >= sizeof(message))
-		len = sizeof(message) - 1;
-	if (message[len-1] == '\n')
-		message[len-1] = 0;
-	printk("%s%s\n", err_level[level], message);
-	spin_unlock_irqrestore(&xfs_err_lock,flags);
+	printk("%s", err_level[level]);
+	vprintk(fmt, ap);
+	printk("\n");
 	BUG_ON(level == CE_PANIC);
 }
 
diff -r 6841f3ce32be -r 9ac0727d59d8 kernel/panic.c
--- a/kernel/panic.c	Mon Sep 29 17:28:44 2008 -0500
+++ b/kernel/panic.c	Tue Sep 30 11:37:30 2008 -0500
@@ -62,7 +62,6 @@
 NORET_TYPE void panic(const char * fmt, ...)
 {
 	long i;
-	static char buf[1024];
 	va_list args;
 #if defined(CONFIG_S390)
 	unsigned long caller = (unsigned long) __builtin_return_address(0);
@@ -77,9 +76,10 @@
 
 	bust_spinlocks(1);
 	va_start(args, fmt);
-	vsnprintf(buf, sizeof(buf), fmt, args);
+	printk(KERN_EMERG "Kernel panic - not syncing: ");
+	vprintk(fmt, args);
+	printk("\n");
 	va_end(args);
-	printk(KERN_EMERG "Kernel panic - not syncing: %s\n",buf);
 	bust_spinlocks(0);
 
 	/*


-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
