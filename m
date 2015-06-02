Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 46A8F6B0072
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 14:13:50 -0400 (EDT)
Received: by qgdy38 with SMTP id y38so37301465qgd.1
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 11:13:50 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id q5si16591951qce.7.2015.06.02.11.13.48
        for <linux-mm@kvack.org>;
        Tue, 02 Jun 2015 11:13:49 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH] Update mlockall() and mmap() man pages for LOCKONFAULT flags
Date: Tue,  2 Jun 2015 14:13:44 -0400
Message-Id: <1433268824-17183-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org

Document the new flags for mmap() and mlockall() and their behavior.
Inlcude a change to getrlimit(2) to cover interactions with
RLIMIT_MEMLOCK.  These new flags will be introduced with the 4.2 kernel.

Signed-off-by: Eric B Munson <emunson@akamai.com>

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-man@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 man2/getrlimit.2 |  9 +++++++--
 man2/mlock.2     | 28 ++++++++++++++++++++++++++--
 man2/mmap.2      | 21 +++++++++++++++++++++
 3 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/man2/getrlimit.2 b/man2/getrlimit.2
index ec464fe..729197e 100644
--- a/man2/getrlimit.2
+++ b/man2/getrlimit.2
@@ -215,7 +215,9 @@ and
 and the
 .BR mmap (2)
 .B MAP_LOCKED
-operation.
+or
+.B MAP_LOCKONFAULT
+operations.
 Since Linux 2.6.9 it also affects the
 .BR shmctl (2)
 .B SHM_LOCK
@@ -232,7 +234,10 @@ locks established by
 .BR mlockall (2),
 and
 .BR mmap (2)
-.BR MAP_LOCKED ;
+with
+.B MAP_LOCKED
+or
+.BR MAP_LOCKONFAULT ;
 a process can lock bytes up to this limit in each of these
 two categories.
 In Linux kernels before 2.6.9, this limit controlled the amount of
diff --git a/man2/mlock.2 b/man2/mlock.2
index b8487ff..139a7be 100644
--- a/man2/mlock.2
+++ b/man2/mlock.2
@@ -96,9 +96,31 @@ process in the future.
 These could be for instance new pages required
 by a growing heap and stack as well as new memory-mapped files or
 shared memory regions.
+.B MCL_FUTURE
+will attempt to make all pages present when the address
+space is allocated.
+.TP
+.BR MCL_ONFAULT " (since Linux 4.2)"
+Like
+.BR MCL_FUTURE ,
+but
+.B MCL_ONFAULT
+does not attempt to make all pages present when the address space is
+allocated, instead wait until each page is accessed for the first
+time before locking.  Note that as with the difference between
+.B MAP_LOCKED
+and
+.B MAP_LOCKONFAULT
+for
+.BR mmap "(2),"
+the caller is charged for the entire allocated address space.  See
+.BR setrlimit "(2)"
+for more details on resource limits.
 .PP
 If
 .B MCL_FUTURE
+or
+.B MCL_ONFAULT
 has been specified, then a later system call (e.g.,
 .BR mmap (2),
 .BR sbrk (2),
@@ -250,9 +272,11 @@ or when the process terminates.
 The
 .BR mlockall ()
 .B MCL_FUTURE
-setting is not inherited by a child created via
+and
+.B MCL_ONFAULT
+settings are not inherited by a child created via
 .BR fork (2)
-and is cleared during an
+and are cleared during an
 .BR execve (2).
 
 The memory lock on an address range is automatically removed
diff --git a/man2/mmap.2 b/man2/mmap.2
index a865612..5aa29e9 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -277,6 +277,26 @@ of the mapping.
 This flag is ignored in older kernels.
 .\" If set, the mapped pages will not be swapped out.
 .TP
+.BR MAP_LOCKONFAULT " (since Linux 4.2)"
+Lock pages covered by this mapping after they are
+accessed for the first time.  Unlike
+.BR MAP_LOCKED ,
+.B MAP_LOCKONFAULT
+does not attempt to populate the mapping immediately.  Note that while
+.B MAP_LOCKONFAULT
+does not populate the mapping, the caller is charged for the full mapping
+against
+.B RLIMIT_MEMLOCK
+when the mapping is created.  This allows
+.BR mmap "(2)"
+calls to fail the same way for
+.B MAP_LOCKED
+and
+.B MAP_LOCKONFAULT
+when the resource limit would be exceeded.  See
+.BR setrlimit "(2)"
+for more details on resource limits.
+.TP
 .BR MAP_NONBLOCK " (since Linux 2.5.46)"
 Only meaningful in conjunction with
 .BR MAP_POPULATE .
@@ -618,6 +638,7 @@ The relevant flags are:
 .BR MAP_GROWSDOWN ,
 .BR MAP_HUGETLB ,
 .BR MAP_LOCKED ,
+.BR MAP_LOCKONFAULT ,
 .BR MAP_NONBLOCK ,
 .BR MAP_NORESERVE ,
 .BR MAP_POPULATE ,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
