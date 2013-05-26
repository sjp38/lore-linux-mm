Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 182C66B005C
	for <linux-mm@kvack.org>; Sun, 26 May 2013 00:32:22 -0400 (EDT)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 02/02] swapon: allow a more flexible swap discard policy
Date: Sun, 26 May 2013 01:31:56 -0300
Message-Id: <6346c223ca2acb30b35480b9d51638466aac5fe6.1369530033.git.aquini@redhat.com>
In-Reply-To: <cover.1369529143.git.aquini@redhat.com>
References: <cover.1369529143.git.aquini@redhat.com>
In-Reply-To: <cover.1369529143.git.aquini@redhat.com>
References: <cover.1369529143.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, kosaki.motohiro@gmail.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

Introduce the necessary changes to swapon(8) allowing a sysadmin to leverage
the new changes introduced to sys_swapon by "swap: discard while swapping
only if SWAP_FLAG_DISCARD_PAGES", therefore allowing a more flexible set of
choices when selection the discard policy for mounted swap areas.
This patch introduces the following optional arguments to the already
existent swapon(8) "--discard" option, in order to allow a discard type to 
be selected at swapon time:
 * once    : only single-time area discards are issued. (swapon)
 * pages   : discard freed pages before they are reused.
If no policy is selected both discard types are enabled. (default)

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 sys-utils/swapon.8 | 24 +++++++++++++------
 sys-utils/swapon.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 77 insertions(+), 17 deletions(-)

diff --git a/sys-utils/swapon.8 b/sys-utils/swapon.8
index 385bf5a..17f7970 100644
--- a/sys-utils/swapon.8
+++ b/sys-utils/swapon.8
@@ -112,15 +112,25 @@ All devices marked as ``swap'' in
 are made available, except for those with the ``noauto'' option.
 Devices that are already being used as swap are silently skipped.
 .TP
-.B "\-d, \-\-discard"
-Discard freed swap pages before they are reused, if the swap
-device supports the discard or trim operation.  This may improve
-performance on some Solid State Devices, but often it does not.
+.B "\-d, \-\-discard\fR [\fIpolicy\fR]"
+Enable swap discards, if the swap backing device supports the discard or
+trim operation. This may improve performance on some Solid State Devices,
+but often it does not. The long option \-\-discard allows one to select
+between two available swap discard policies:
+.BI \-\-discard=once
+to perform a single-time discard operation for the whole swap area at swapon;
+or
+.BI \-\-discard=pages
+to discard freed swap pages before they are reused, while swapping.
+If no policy is selected, the default behavior is to enable both discard types.
 The
 .I /etc/fstab
-mount option
-.BI discard
-may be also used to enable discard flag.
+mount options
+.BI discard,
+.BI discard=once,
+or
+.BI discard=pages
+may be also used to enable discard flags.
 .TP
 .B "\-e, \-\-ifexists"
 Silently skip devices that do not exist.
diff --git a/sys-utils/swapon.c b/sys-utils/swapon.c
index f1e2433..8a90bfe 100644
--- a/sys-utils/swapon.c
+++ b/sys-utils/swapon.c
@@ -34,9 +34,20 @@
 #endif
 
 #ifndef SWAP_FLAG_DISCARD
-# define SWAP_FLAG_DISCARD	0x10000 /* discard swap cluster after use */
+# define SWAP_FLAG_DISCARD	0x10000 /* enable discard for swap */
 #endif
 
+#ifndef SWAP_FLAG_DISCARD_ONCE
+# define SWAP_FLAG_DISCARD_ONCE 0x20000 /* discard swap area at swapon-time */
+#endif
+
+#ifndef SWAP_FLAG_DISCARD_PAGES
+# define SWAP_FLAG_DISCARD_PAGES 0x40000 /* discard page-clusters after use */
+#endif
+
+#define SWAP_FLAGS_DISCARD_VALID (SWAP_FLAG_DISCARD | SWAP_FLAG_DISCARD_ONCE | \
+				  SWAP_FLAG_DISCARD_PAGES)
+
 #ifndef SWAP_FLAG_PREFER
 # define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #endif
@@ -70,7 +81,7 @@ enum {
 
 static int all;
 static int priority = -1;	/* non-prioritized swap by default */
-static int discard;
+static int discard = 0;		/* don't send swap discards by default */
 
 /* If true, don't complain if the device/file doesn't exist */
 static int ifexists;
@@ -570,8 +581,22 @@ static int do_swapon(const char *orig_special, int prio,
 			   << SWAP_FLAG_PRIO_SHIFT);
 	}
 #endif
-	if (fl_discard)
-		flags |= SWAP_FLAG_DISCARD;
+	/*
+	 * Validate the discard flags passed and set them
+	 * accordingly before calling sys_swapon.
+	 */
+	if (fl_discard && !(fl_discard & ~SWAP_FLAGS_DISCARD_VALID)) {
+		/*
+		 * If we get here with both discard policy flags set,
+		 * we just need to tell the kernel to enable discards
+		 * and it will do correctly, just as we expect.
+		 */
+		if ((fl_discard & SWAP_FLAG_DISCARD_ONCE) &&
+		    (fl_discard & SWAP_FLAG_DISCARD_PAGES))
+			flags |= SWAP_FLAG_DISCARD;
+		else
+			flags |= fl_discard;
+	}
 
 	status = swapon(special, flags);
 	if (status < 0)
@@ -611,12 +636,22 @@ static int swapon_all(void)
 	while (mnt_table_find_next_fs(tb, itr, match_swap, NULL, &fs) == 0) {
 		/* defaults */
 		int pri = priority, dsc = discard, nofail = ifexists;
-		char *p, *src;
+		char *p, *src, *dscarg;
 
 		if (mnt_fs_get_option(fs, "noauto", NULL, NULL) == 0)
 			continue;
-		if (mnt_fs_get_option(fs, "discard", NULL, NULL) == 0)
-			dsc = 1;
+		if (mnt_fs_get_option(fs, "discard", &dscarg, NULL) == 0) {
+			dsc |= SWAP_FLAG_DISCARD;
+			if (dscarg) {
+				/* only single-time discards are wanted */
+				if (strcmp(dscarg, "once") == 0)
+					dsc |= SWAP_FLAG_DISCARD_ONCE;
+
+				/* do discard for every released swap page */
+				if (strcmp(dscarg, "pages") == 0)
+					dsc |= SWAP_FLAG_DISCARD_PAGES;
+			}
+		}
 		if (mnt_fs_get_option(fs, "nofail", NULL, NULL) == 0)
 			nofail = 1;
 		if (mnt_fs_get_option(fs, "pri", &p, NULL) == 0 && p)
@@ -647,7 +682,7 @@ static void __attribute__ ((__noreturn__)) usage(FILE * out)
 
 	fputs(USAGE_OPTIONS, out);
 	fputs(_(" -a, --all              enable all swaps from /etc/fstab\n"
-		" -d, --discard          discard freed pages before they are reused\n"
+		" -d, --discard[=policy] enable swap discards, if supported by device\n"
 		" -e, --ifexists         silently skip devices that do not exist\n"
 		" -f, --fixpgsz          reinitialize the swap space if necessary\n"
 		" -p, --priority <prio>  specify the priority of the swap device\n"
@@ -672,6 +707,11 @@ static void __attribute__ ((__noreturn__)) usage(FILE * out)
 		" <device>               name of device to be used\n"
 		" <file>                 name of file to be used\n"), out);
 
+	fputs(_("\nAvailable discard policy types (for --discard):\n"
+		" once	  : only single-time area discards are issued. (swapon)\n"
+		" pages	  : discard freed pages before they are reused.\n"
+		" * if no policy is selected both discard types are enabled. (default)\n"), out);
+
 	fputs(_("\nAvailable columns (for --show):\n"), out);
 	for (i = 0; i < NCOLS; i++)
 		fprintf(out, " %4s  %s\n", infos[i].name, _(infos[i].help));
@@ -696,7 +736,7 @@ int main(int argc, char *argv[])
 
 	static const struct option long_opts[] = {
 		{ "priority", 1, 0, 'p' },
-		{ "discard",  0, 0, 'd' },
+		{ "discard",  2, 0, 'd' },
 		{ "ifexists", 0, 0, 'e' },
 		{ "summary",  0, 0, 's' },
 		{ "fixpgsz",  0, 0, 'f' },
@@ -739,7 +779,17 @@ int main(int argc, char *argv[])
 			add_uuid(optarg);
 			break;
 		case 'd':
-			discard = 1;
+			discard |= SWAP_FLAG_DISCARD;
+
+			if (optarg) {
+				/* only single-time discards are wanted */
+				if (strcmp(optarg, "once") == 0)
+					discard |= SWAP_FLAG_DISCARD_ONCE;
+
+				/* do discard for every released swap page */
+				if (strcmp(optarg, "pages") == 0)
+					discard |= SWAP_FLAG_DISCARD_PAGES;
+			}
 			break;
 		case 'e':               /* ifexists */
 		        ifexists = 1;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
