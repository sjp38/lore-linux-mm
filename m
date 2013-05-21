Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id E18706B0034
	for <linux-mm@kvack.org>; Mon, 20 May 2013 20:04:44 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [RFC PATCH 02/02] swapon: add "cluster-discard" support
Date: Mon, 20 May 2013 21:04:25 -0300
Message-Id: <398ace0dd3ca1283372b3aad3fceeee59f6897d7.1369084886.git.aquini@redhat.com>
In-Reply-To: <cover.1369092449.git.aquini@redhat.com>
References: <cover.1369092449.git.aquini@redhat.com>
In-Reply-To: <cover.1369092449.git.aquini@redhat.com>
References: <cover.1369092449.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

Introduce a new swapon flag/option to support more flexible swap discard setup.
The --cluster-discard swapon(8) option can be used by a system admin to flag
sys_swapon() to perform page-cluster fine-grained discards.

This patch also changes the behaviour of swapon(8) --discard option, that now
will only be used to flag sys_swapon() batched discards will be issued at
swapon(8) time.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 sys-utils/swapon.8 | 19 ++++++++++++++++---
 sys-utils/swapon.c | 34 ++++++++++++++++++++++++++--------
 2 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/sys-utils/swapon.8 b/sys-utils/swapon.8
index 385bf5a..0c8ac69 100644
--- a/sys-utils/swapon.8
+++ b/sys-utils/swapon.8
@@ -112,10 +112,23 @@ All devices marked as ``swap'' in
 are made available, except for those with the ``noauto'' option.
 Devices that are already being used as swap are silently skipped.
 .TP
+.TP
+.B "\-c, \-\-cluster\-discard"
+Swapping will discard clusters of swap pages in between freeing them
+and re-writing to them, if the swap device supports that. This option
+also implies the
+.I \-d, \-\-discard
+swapon flag.
+The
+.I /etc/fstab
+mount option
+.BI cluster\-discard
+may be also used to enable this flag.
+
+.TP
 .B "\-d, \-\-discard"
-Discard freed swap pages before they are reused, if the swap
-device supports the discard or trim operation.  This may improve
-performance on some Solid State Devices, but often it does not.
+Enables swap discards, if the swap device supports that, and performs
+a batch discard operation for the swap device at swapon time.
 The
 .I /etc/fstab
 mount option
diff --git a/sys-utils/swapon.c b/sys-utils/swapon.c
index f1e2433..a71f69e 100644
--- a/sys-utils/swapon.c
+++ b/sys-utils/swapon.c
@@ -34,7 +34,11 @@
 #endif
 
 #ifndef SWAP_FLAG_DISCARD
-# define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
+# define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
+#endif
+
+#ifndef SWAP_FLAG_DISCARD_CLUSTER
+# define SWAP_FLAG_DISCARD_CLUSTER 0x20000 /* discard swap cluster after use */
 #endif
 
 #ifndef SWAP_FLAG_PREFER
@@ -70,7 +74,7 @@ enum {
 
 static int all;
 static int priority = -1;	/* non-prioritized swap by default */
-static int discard;
+static int discard = 0;		/* don't send swap discards by default */
 
 /* If true, don't complain if the device/file doesn't exist */
 static int ifexists;
@@ -570,8 +574,11 @@ static int do_swapon(const char *orig_special, int prio,
 			   << SWAP_FLAG_PRIO_SHIFT);
 	}
 #endif
-	if (fl_discard)
+	if (fl_discard) {
 		flags |= SWAP_FLAG_DISCARD;
+		if (fl_discard > 1)
+			flags |= SWAP_FLAG_DISCARD_CLUSTER;
+	}
 
 	status = swapon(special, flags);
 	if (status < 0)
@@ -615,8 +622,14 @@ static int swapon_all(void)
 
 		if (mnt_fs_get_option(fs, "noauto", NULL, NULL) == 0)
 			continue;
-		if (mnt_fs_get_option(fs, "discard", NULL, NULL) == 0)
-			dsc = 1;
+		if (mnt_fs_get_option(fs, "discard", NULL, NULL) == 0) {
+			if !(dsc)
+				dsc = 1;
+		}
+		if (mnt_fs_get_option(fs, "cluster-discard", NULL, NULL) == 0) {
+			if (!dsc || dsc == 1)
+				dsc = 2;
+		}
 		if (mnt_fs_get_option(fs, "nofail", NULL, NULL) == 0)
 			nofail = 1;
 		if (mnt_fs_get_option(fs, "pri", &p, NULL) == 0 && p)
@@ -647,7 +660,8 @@ static void __attribute__ ((__noreturn__)) usage(FILE * out)
 
 	fputs(USAGE_OPTIONS, out);
 	fputs(_(" -a, --all              enable all swaps from /etc/fstab\n"
-		" -d, --discard          discard freed pages before they are reused\n"
+		" -c, --cluster-discard  discard freed pages before they are reused, while swapping\n"
+		" -d, --discard          discard freed pages before they are reused, all at once, at swapon time\n"
 		" -e, --ifexists         silently skip devices that do not exist\n"
 		" -f, --fixpgsz          reinitialize the swap space if necessary\n"
 		" -p, --priority <prio>  specify the priority of the swap device\n"
@@ -696,6 +710,7 @@ int main(int argc, char *argv[])
 
 	static const struct option long_opts[] = {
 		{ "priority", 1, 0, 'p' },
+		{ "cluster-discard",  0, 0, 'c' },
 		{ "discard",  0, 0, 'd' },
 		{ "ifexists", 0, 0, 'e' },
 		{ "summary",  0, 0, 's' },
@@ -719,7 +734,7 @@ int main(int argc, char *argv[])
 	mnt_init_debug(0);
 	mntcache = mnt_new_cache();
 
-	while ((c = getopt_long(argc, argv, "ahdefp:svVL:U:",
+	while ((c = getopt_long(argc, argv, "ahcdefp:svVL:U:",
 				long_opts, NULL)) != -1) {
 		switch (c) {
 		case 'a':		/* all */
@@ -738,8 +753,11 @@ int main(int argc, char *argv[])
 		case 'U':
 			add_uuid(optarg);
 			break;
+		case 'c':
+			discard += 2;
+			break;
 		case 'd':
-			discard = 1;
+			discard += 1;
 			break;
 		case 'e':               /* ifexists */
 		        ifexists = 1;
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
