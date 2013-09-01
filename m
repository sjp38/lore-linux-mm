Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 868516B0032
	for <linux-mm@kvack.org>; Sun,  1 Sep 2013 15:59:17 -0400 (EDT)
From: Richard Hansen <rhansen@bbn.com>
Subject: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
Date: Sun,  1 Sep 2013 15:58:57 -0400
Message-Id: <1378065537-7222-1-git-send-email-rhansen@bbn.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org, Richard Hansen <rhansen@bbn.com>

For the flags parameter, POSIX says "Either MS_ASYNC or MS_SYNC shall
be specified, but not both." [1]  There was already a test for the
"both" condition.  Add a test to ensure that the caller specified one
of the flags; fail with EINVAL if neither are specified.

Without this change, specifying neither is the same as specifying
flags=MS_ASYNC because nothing in msync() is conditioned on the
MS_ASYNC flag.  This has not always been true, and there's no good
reason to believe that this behavior would have persisted
indefinitely.

The msync(2) man page (as currently written in man-pages.git) is
silent on the behavior if both flags are unset, so this change should
not break an application written by somone who carefully reads the
Linux man pages or the POSIX spec.

[1] http://pubs.opengroup.org/onlinepubs/9699919799/functions/msync.html

Signed-off-by: Richard Hansen <rhansen@bbn.com>
Reported-by: Greg Troxel <gdt@ir.bbn.com>
Reviewed-by: Greg Troxel <gdt@ir.bbn.com>
---
 mm/msync.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/msync.c b/mm/msync.c
index 632df45..472ad3e 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -42,6 +42,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 		goto out;
 	if ((flags & MS_ASYNC) && (flags & MS_SYNC))
 		goto out;
+	if (!(flags & (MS_ASYNC | MS_SYNC)))
+		goto out;
 	error = -ENOMEM;
 	len = (len + ~PAGE_MASK) & PAGE_MASK;
 	end = start + len;
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
