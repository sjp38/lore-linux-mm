Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 771B09000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:49:07 -0400 (EDT)
From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 2/2] coredump: add support for exe_file in core name
Date: Tue, 26 Apr 2011 11:48:25 +0200
Message-Id: <1303811305-1191-2-git-send-email-jslaby@suse.cz>
In-Reply-To: <1303811305-1191-1-git-send-email-jslaby@suse.cz>
References: <1303811305-1191-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Al Viro <viro@zeniv.linux.org.uk>

Now, exe_file is not proc FS dependent, so we can use it to name core
file. So we add %E pattern for core file name cration which extract
path from mm_struct->exe_file. Then it converts slashes to exclamation
marks and pastes the result to the core file name itself.

This is useful for environments where binary names are longer than 16
character (the current->comm limitation). Also where there are
binaries with same name but in a different path. Further in case the
binery itself changes its current->comm after exec.

So by doing (s/$/#/ -- # is treated as git comment):
$ sysctl kernel.core_pattern='core.%p.%e.%E'
$ ln /bin/cat cat45678901234567890
$ ./cat45678901234567890
^Z
$ rm cat45678901234567890
$ fg
^\Quit (core dumped)
$ ls core*

we now get:
core.2434.cat456789012345.!root!cat45678901234567890 (deleted)

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Al Viro <viro@zeniv.linux.org.uk>
---
 Documentation/sysctl/kernel.txt |    3 ++-
 fs/exec.c                       |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 36f0075..5e7cb39 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -161,7 +161,8 @@ core_pattern is used to specify a core dumpfile pattern name.
 	%s	signal number
 	%t	UNIX time of dump
 	%h	hostname
-	%e	executable filename
+	%e	executable filename (may be shortened)
+	%E	executable path
 	%<OTHER> both are dropped
 . If the first character of the pattern is a '|', the kernel will treat
   the rest of the pattern as a command to run.  The core dump will be
diff --git a/fs/exec.c b/fs/exec.c
index 5d27d5c..27ed2a2 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1547,6 +1547,41 @@ expand_fail:
 	return ret;
 }
 
+static int cn_print_exe_file(struct core_name *cn)
+{
+	struct file *exe_file;
+	char *pathbuf, *path, *p;
+	int ret;
+
+	exe_file = get_mm_exe_file(current->mm);
+	if (!exe_file)
+		return cn_printf(cn, "(unknown)");
+
+	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
+	if (!pathbuf) {
+		ret = -ENOMEM;
+		goto put_exe_file;
+	}
+
+	path = d_path(&exe_file->f_path, pathbuf, PATH_MAX);
+	if (IS_ERR(path)) {
+		ret = PTR_ERR(path);
+		goto free_buf;
+	}
+
+	for (p = path; *p; p++)
+		if (*p == '/')
+			*p = '!';
+
+	ret = cn_printf(cn, "%s", path);
+
+free_buf:
+	kfree(pathbuf);
+put_exe_file:
+	fput(exe_file);
+	return ret;
+}
+
 /* format_corename will inspect the pattern parameter, and output a
  * name into corename, which must have space for at least
  * CORENAME_MAX_SIZE bytes plus one byte for the zero terminator.
@@ -1624,6 +1659,9 @@ static int format_corename(struct core_name *cn, long signr)
 			case 'e':
 				err = cn_printf(cn, "%s", current->comm);
 				break;
+			case 'E':
+				err = cn_print_exe_file(cn);
+				break;
 			/* core limit size */
 			case 'c':
 				err = cn_printf(cn, "%lu",
-- 
1.7.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
