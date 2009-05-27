Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44D9F6B00AF
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:43:14 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 25/43] tee: don't return 0 when another task drains/fills a pipe
Date: Wed, 27 May 2009 13:32:51 -0400
Message-Id: <1243445589-32388-26-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

This patch is a modified version of Max Kellerman patch that fixes
a race in do_tee() (see http://patchwork/kernel/org/patch/21040).

It differs in that it rafactors link_pipe() so that the following
patch (that adds support for splice() between pipes, also based on
a patch by Max Kellerman), can better share code.

Below is Max's original description:
--
Cite from the tee() manual page:

 "A return value of 0 means that there was no data to transfer, and it
 would not make sense to block, because there are no writers connected
 to the write end of the pipe"

There is however a race condition in the tee() implementation, which
violates this definition:

- do_tee() ensures that ipipe is readable and opipe is writable by
  calling link_ipipe_prep() and link_opipe_prep()
- these two functions unlock the pipe after they have waited
- during this unlocked phase, there is a short window where other
  tasks may drain the input pipe or fill the output pipe
- do_tee() now calls link_pipe(), which re-locks both pipes
- link_pipe() sees that it is unable to read ("i >= ipipe->nrbufs ||
  opipe->nrbufs >= PIPE_BUFFERS") and breaks from the loop
- link_pipe() returns 0

Although there may be writers connected to the input pipe, tee() now
returns 0, and the caller (spuriously) assumes this is the end of the
stream.

This patch wraps the link_[io]pipe_prep() invocation in a loop within
link_pipe(), and loops until the result is reliable.
--

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 fs/splice.c |   80 +++++++++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 61 insertions(+), 19 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 666953d..92dd63c 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -1586,6 +1586,59 @@ static int link_opipe_prep(struct pipe_inode_info *pipe, unsigned int flags)
 	return ret;
 }
 
+/**
+ * link_pipe_prep - make sure there's readable data and writable room
+ * @ipipe: the input pipe
+ * @opipe: the output pipe
+ * @flags: splice modifier flags
+ *
+ * Wrap the link_[io]pipe_prep() invocation in a loop until the result
+ * is reliable.
+ *
+ * Expects pipes to be unlocked, and on success returns them locked.
+ */
+static int link_pipe_prep(struct pipe_inode_info *ipipe,
+			  struct pipe_inode_info *opipe,
+			  unsigned int flags)
+{
+	int ret;
+
+	while (1) {
+		/* wait for ipipe to become ready to read */
+		ret = link_ipipe_prep(ipipe, flags);
+		if (ret)
+			return ret;
+
+		/* wait for opipe to become ready to write */
+		ret = link_opipe_prep(opipe, flags);
+		if (ret)
+			return ret;
+
+		/*
+		 * Potential ABBA deadlock, work around it by ordering
+		 * lock grabbing by inode address. Otherwise two
+		 * different processes could deadlock (one doing tee
+		 * from A -> B, the other from B -> A).
+		 */
+		pipe_double_lock(ipipe, opipe);
+
+		/* see if the tee() is still possible */
+		if ((ipipe->nrbufs > 0 || ipipe->writers == 0) &&
+		    opipe->nrbufs < PIPE_BUFFERS)
+			/* yes, it is - keep the locks and end this
+			   loop */
+			break;
+
+		/* no - someone has drained ipipe or has filled opipe
+		   between link_[io]pipe_pre()'s lock and our lock.
+		   Drop both locks and wait again. */
+		pipe_unlock(ipipe);
+		pipe_unlock(opipe);
+	}
+
+	return 0;
+}
+
 /*
  * Link contents of ipipe to opipe.
  */
@@ -1594,14 +1647,13 @@ static int link_pipe(struct pipe_inode_info *ipipe,
 		     size_t len, unsigned int flags)
 {
 	struct pipe_buffer *ibuf, *obuf;
-	int ret = 0, i = 0, nbuf;
+	int ret, i = 0, nbuf;
 
-	/*
-	 * Potential ABBA deadlock, work around it by ordering lock
-	 * grabbing by pipe info address. Otherwise two different processes
-	 * could deadlock (one doing tee from A -> B, the other from B -> A).
-	 */
-	pipe_double_lock(ipipe, opipe);
+	ret = link_pipe_prep(ipipe, opipe, flags);
+	if (ret < 0)
+		return ret;
+
+	/* pipes are now locked */
 
 	do {
 		if (!opipe->readers) {
@@ -1685,18 +1737,8 @@ static long do_tee(struct file *in, struct file *out, size_t len,
 	 * Duplicate the contents of ipipe to opipe without actually
 	 * copying the data.
 	 */
-	if (ipipe && opipe && ipipe != opipe) {
-		/*
-		 * Keep going, unless we encounter an error. The ipipe/opipe
-		 * ordering doesn't really matter.
-		 */
-		ret = link_ipipe_prep(ipipe, flags);
-		if (!ret) {
-			ret = link_opipe_prep(opipe, flags);
-			if (!ret)
-				ret = link_pipe(ipipe, opipe, len, flags);
-		}
-	}
+	if (ipipe && opipe && ipipe != opipe)
+		ret = link_pipe(ipipe, opipe, len, flags);
 
 	return ret;
 }
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
