Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B8BE6B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:07:54 -0500 (EST)
Date: Tue, 30 Nov 2010 21:00:45 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/4] exec: introduce get_arg_ptr() helper
Message-ID: <20101130200045.GE11905@redhat.com>
References: <20101125140253.GA29371@redhat.com> <20101125193659.GA14510@redhat.com> <20101129093803.829F.A69D9226@jp.fujitsu.com> <20101129113357.GA30657@redhat.com> <20101129182332.GA21470@redhat.com> <20101130195456.GA11905@redhat.com> <20101130200016.GD11905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101130200016.GD11905@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

Introduce get_arg_ptr() helper, convert count() and copy_strings()
to use it.

No functional changes, preparation. This helper is trivial, it just
reads the pointer from argv/envp user-space array.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/exec.c |   36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

--- K/fs/exec.c~1_get_arg_ptr	2010-11-30 18:30:45.000000000 +0100
+++ K/fs/exec.c	2010-11-30 19:14:54.000000000 +0100
@@ -390,6 +390,17 @@ err:
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
@@ -399,13 +410,14 @@ static int count(const char __user * con
 
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
 
@@ -435,16 +447,18 @@ static int copy_strings(int argc, const 
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
