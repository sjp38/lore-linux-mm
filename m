Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 11B506B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 14:25:49 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id j107so9338109qga.21
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:25:48 -0700 (PDT)
Received: from smtp.bbn.com (smtp.bbn.com. [128.33.0.80])
        by mx.google.com with ESMTPS id m6si7954025qay.149.2014.04.01.11.25.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 11:25:48 -0700 (PDT)
Message-ID: <533B04A9.6090405@bbn.com>
Date: Tue, 01 Apr 2014 14:25:45 -0400
From: Richard Hansen <rhansen@bbn.com>
MIME-Version: 1.0
Subject: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-api@vger.kernel.org, Greg Troxel <gdt@ir.bbn.com>

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

This is a resend of:
http://article.gmane.org/gmane.linux.kernel/1554416
I didn't get any feedback from that submission, so I'm resending it
without changes.

 mm/msync.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/msync.c b/mm/msync.c
index 632df45..472ad3e 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -42,6 +42,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t,
len, int, flags)
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
