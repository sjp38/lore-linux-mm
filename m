Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BA7886007BA
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 07:37:28 -0500 (EST)
Date: Tue, 5 Jan 2010 12:37:19 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] nommu: reject MAP_HUGETLB
In-Reply-To: <20100104123858.GA5045@us.ibm.com>
Message-ID: <alpine.LSU.2.00.1001051232530.1055@sister.anvils>
References: <alpine.LSU.2.00.0912302009040.30390@sister.anvils> <20100104123858.GA5045@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric B Munson <ebmunson@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>, David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We've agreed to restore the rejection of MAP_HUGETLB to nommu.
Mimic what happens with mmu when hugetlb is not configured in:
say -ENOSYS, but -EINVAL if MAP_ANONYMOUS was not given too.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/nommu.c |    8 ++++++++
 1 file changed, 8 insertions(+)

--- 2.6.33-rc2-git/mm/nommu.c	2009-12-31 08:08:16.000000000 +0000
+++ linux/mm/nommu.c	2010-01-05 12:08:01.000000000 +0000
@@ -1405,6 +1405,14 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned lon
 	struct file *file = NULL;
 	unsigned long retval = -EBADF;
 
+	if (unlikely(flags & MAP_HUGETLB)) {
+		if (flags & MAP_ANONYMOUS)
+			retval = -ENOSYS;	/* like hugetlb_file_setup */
+		else
+			retval = -EINVAL;
+		goto out;
+	}
+
 	if (!(flags & MAP_ANONYMOUS)) {
 		file = fget(fd);
 		if (!file)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
