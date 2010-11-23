Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2496D6B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:50:23 -0500 (EST)
Received: by vws10 with SMTP id 10so4191279vws.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:50:18 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: [PATCH 1/3] Add fadvise interface wrapper
Date: Tue, 23 Nov 2010 09:49:50 -0500
Message-Id: <1290523792-6170-2-git-send-email-bgamari.foss@gmail.com>
In-Reply-To: <20101122103756.E236.A69D9226@jp.fujitsu.com>
References: <20101122103756.E236.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, rsync@lists.samba.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Ben Gamari <bgamari.foss@gmail.com>
List-ID: <linux-mm.kvack.org>

With recent discussion on the LKML[1], it seems likely that Linux will
finally support posix_fadvise in a useful way with the FADV_DONTNEED
flag. This should allow us to minimize the effect of rsync on the
system's working set. Add the necessary wrapper to syscall.c.

[1] http://lkml.org/lkml/2010/11/21/59
---
 syscall.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/syscall.c b/syscall.c
index cfabc3e..9f5b1c3 100644
--- a/syscall.c
+++ b/syscall.c
@@ -28,6 +28,7 @@
 #ifdef HAVE_SYS_ATTR_H
 #include <sys/attr.h>
 #endif
+#include <fcntl.h>
 
 extern int dry_run;
 extern int am_root;
@@ -282,3 +283,13 @@ OFF_T do_lseek(int fd, OFF_T offset, int whence)
 	return lseek(fd, offset, whence);
 #endif
 }
+
+#if _XOPEN_SOURCE >= 600
+int do_fadvise(int fd, OFF_T offset, OFF_T len, int advise)
+{
+        return posix_fadvise(fd, offset, len, advise);
+}
+#else
+#define do_fadvise() 
+#endif
+
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
