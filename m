Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB4F58D003B
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:01:40 -0500 (EST)
Date: Fri, 25 Feb 2011 18:52:25 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/5] exec: introduce get_arg_ptr() helper
Message-ID: <20110225175225.GB19059@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com> <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110225175202.GA19059@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

Introduce get_arg_ptr() helper, convert count() and copy_strings()
to use it.

No functional changes, preparation. This helper is trivial, it just
reads the pointer from argv/envp user-space array.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |   36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

--- 38/fs/exec.c~1_get_arg_ptr	2011-02-25 18:01:59.000000000 +0100
+++ 38/fs/exec.c	2011-02-25 18:04:50.000000000 +0100
@@ -395,6 +395,17 @@ err:
 	return err;
 }
 
+static const char __user *
+get_arg_ptr(const char __user * const __user *argv, int argc)
+{
+	const char __user *ptr;
+
+	if (get_user(ptr, argv + argc))
+		return ERR_PTR(-EFAULT);
+
+	return ptr;
+}
+
 /*
  * count() counts the number of strings in array ARGV.
  */
@@ -404,13 +415,14 @@ static int count(const char __user * con
 
 	if (argv != NULL) {
 		for (;;) {
-			const char __user * p;
+			const char __user *p = get_arg_ptr(argv, i);
 
-			if (get_user(p, argv))
-				return -EFAULT;
 			if (!p)
 				break;
-			argv++;
+
+			if (IS_ERR(p))
+				return -EFAULT;
+
 			if (i++ >= max)
 				return -E2BIG;
 
@@ -440,16 +452,18 @@ static int copy_strings(int argc, const 
 		int len;
 		unsigned long pos;
 
-		if (get_user(str, argv+argc) ||
-				!(len = strnlen_user(str, MAX_ARG_STRLEN))) {
-			ret = -EFAULT;
+		ret = -EFAULT;
+		str = get_arg_ptr(argv, argc);
+		if (IS_ERR(str))
 			goto out;
-		}
 
-		if (!valid_arg_len(bprm, len)) {
-			ret = -E2BIG;
+		len = strnlen_user(str, MAX_ARG_STRLEN);
+		if (!len)
+			goto out;
+
+		ret = -E2BIG;
+		if (!valid_arg_len(bprm, len))
 			goto out;
-		}
 
 		/* We're going to work our way backwords. */
 		pos = bprm->p;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
