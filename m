Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j51MRPRt005647
	for <linux-mm@kvack.org>; Wed, 1 Jun 2005 15:27:26 -0700 (PDT)
From: pmeda@akamai.com
Date: Wed, 1 Jun 2005 15:27:19 -0700
Message-Id: <200506012227.PAA05624@allur.sanmateo.akamai.com>
Subject: [patch] scm: fix scm_fp_list allocation problem
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The change is to use kmalloc or vmalloc for scm_fp_list based on the
structure size similar to fdset allocation in fs code.  This change allows
local users to change the number of files macros(SCM_MAX_FD, OPEN_MAX, NR_OPEN etc.)
to large values without changing other code. This change does not touch those macros,
and hence compiler should generate the same code as before for normal users.

One of the problems faced by changing the number of fds is not being able to
ssh for nonroot user. This is because of scm credentail passing an fd from 
authentication process to actual shell process, and allocating big array wth kmalloc
for that passing. The kmalloc works at 1024 fds, and fails now and then after.

More soph. fix would be to embed the size as part of structure, and allocate fd array,
and passin one fd or small array(<32 fds) for passing just one fd, and expanding the
array based on the passed fds dynamically. The structure change needs to be taught to
all functions (like scm_fp_dup) that understand scm_fp_list. Since credentials will be
freed shortly, and normal SCM_FD_MAX case is just 1024 fds, and it needs to use vmalloc
for the worst case anyway, it can wait or is not worth. I stick to simple fix.

Thanks to Peter Swain for help in debugging ssh problem and Sudhin Mishra for reproducing the
problem with ltp recvmsg testcase.

Signed-Off-by: Prasanna Meda <pmeda@akamai.com>


--- a/include/net/scm.h	Wed Jun  1 20:02:43 2005
+++ b/include/net/scm.h	Wed Jun  1 20:04:59 2005
@@ -3,6 +3,8 @@
 
 #include <linux/limits.h>
 #include <linux/net.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 /* Well, we should have at least one descriptor open
  * to accept passed FDs 8)
@@ -27,6 +29,30 @@
 extern int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
 extern void __scm_destroy(struct scm_cookie *scm);
 extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
+
+static __inline__ struct scm_fp_list *scm_fp_alloc(void)
+{
+	struct scm_fp_list *fpl;
+	int size  = sizeof(struct scm_fp_list);
+	
+	if (size <= PAGE_SIZE) {
+		fpl = (struct scm_fp_list *) kmalloc (size, GFP_KERNEL);
+	}
+	else {
+		fpl = (struct scm_fp_list *) vmalloc (size);
+	}
+	return fpl;
+}
+
+static __inline__ void scm_fp_free(struct scm_fp_list *fpl)
+{
+	if (sizeof(struct scm_fp_list) <= PAGE_SIZE) {
+		kfree(fpl);
+	}
+	else {
+		vfree(fpl);
+	}
+}
 
 static __inline__ void scm_destroy(struct scm_cookie *scm)
 {
--- a/net/core/scm.c	Wed Jun  1 12:46:33 2005
+++ b/net/core/scm.c	Wed Jun  1 12:47:11 2005
@@ -69,7 +69,7 @@ static int scm_fp_copy(struct cmsghdr *c
 
 	if (!fpl)
 	{
-		fpl = kmalloc(sizeof(struct scm_fp_list), GFP_KERNEL);
+		fpl = scm_fp_alloc();
 		if (!fpl)
 			return -ENOMEM;
 		*fplp = fpl;
@@ -106,7 +106,7 @@ void __scm_destroy(struct scm_cookie *sc
 		scm->fp = NULL;
 		for (i=fpl->count-1; i>=0; i--)
 			fput(fpl->fp[i]);
-		kfree(fpl);
+		scm_fp_free(fpl);
 	}
 }
 
@@ -155,7 +155,7 @@ int __scm_send(struct socket *sock, stru
 
 	if (p->fp && !p->fp->count)
 	{
-		kfree(p->fp);
+		scm_fp_free(p->fp);
 		p->fp = NULL;
 	}
 	return 0;
@@ -275,7 +275,7 @@ struct scm_fp_list *scm_fp_dup(struct sc
 	if (!fpl)
 		return NULL;
 
-	new_fpl = kmalloc(sizeof(*fpl), GFP_KERNEL);
+	new_fpl = scm_fp_alloc();
 	if (new_fpl) {
 		for (i=fpl->count-1; i>=0; i--)
 			get_file(fpl->fp[i]);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
