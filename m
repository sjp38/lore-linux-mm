Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id C3C816B0068
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:54:33 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id e9so3100068qcy.12
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:54:33 -0700 (PDT)
Received: from iriserv.iradimed.com (rrcs-67-78-168-186.se.biz.rr.com. [67.78.168.186])
        by mx.google.com with ESMTPS id t6si3632069qga.102.2014.03.14.08.54.33
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 08:54:33 -0700 (PDT)
From: Phillip Susi <psusi@ubuntu.com>
Subject: [PATCH] readahead.2: don't claim the call blocks until all data has been read
Date: Fri, 14 Mar 2014 11:54:31 -0400
Message-Id: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

The readahead(2) man page was claiming that the call blocks until all
data has been read into the cache.  This is incorrect.

Signed-off-by: Phillip Susi <psusi@ubuntu.com>
---
 man2/readahead.2 | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/man2/readahead.2 b/man2/readahead.2
index 605fa5e..1b0376e 100644
--- a/man2/readahead.2
+++ b/man2/readahead.2
@@ -27,7 +27,7 @@
 .\"
 .TH READAHEAD 2 2013-04-01 "Linux" "Linux Programmer's Manual"
 .SH NAME
-readahead \- perform file readahead into page cache
+readahead \- initiate file readahead into page cache
 .SH SYNOPSIS
 .nf
 .BR "#define _GNU_SOURCE" "             /* See feature_test_macros(7) */"
@@ -37,8 +37,8 @@ readahead \- perform file readahead into page cache
 .fi
 .SH DESCRIPTION
 .BR readahead ()
-populates the page cache with data from a file so that subsequent
-reads from that file will not block on disk I/O.
+initates readahead on a file so that subsequent reads from that file will
+hopefully be satisfied from the cache, and not block on disk I/O.
 The
 .I fd
 argument is a file descriptor identifying the file which is
@@ -57,8 +57,6 @@ equal to
 .IR "(offset+count)" .
 .BR readahead ()
 does not read beyond the end of the file.
-.BR readahead ()
-blocks until the specified data has been read.
 The current file offset of the open file referred to by
 .I fd
 is left unchanged.
@@ -94,6 +92,13 @@ On some 32-bit architectures,
 the calling signature for this system call differs,
 for the reasons described in
 .BR syscall (2).
+
+The call attempts to schedule the reads in the background and return
+immediately, however it may block while reading filesystem metadata
+in order to locate where the blocks requested are.  This occurs frequently
+with ext[234] on large files using indirect blocks instead of extents,
+giving the appearence that the call blocks until the requested data has
+been read.
 .SH SEE ALSO
 .BR lseek (2),
 .BR madvise (2),
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
