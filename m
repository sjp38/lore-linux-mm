Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0BD56B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:05:51 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id o200so1830557itg.2
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 12:05:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f193si2056863oic.255.2017.09.14.12.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 12:05:50 -0700 (PDT)
Date: Thu, 14 Sep 2017 15:05:46 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
Message-ID: <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
In-Reply-To: <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
	<CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colm =?UTF-8?B?TWFjQ8OhcnRoYWlnaA==?= <colm@allcosts.net>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

v2: implement the improvements suggested by Colm, and add
    Colm's text to the fork.2 man page
    (Colm, I have added a signed-off-by in your name - is that ok?)

Add MADV_WIPEONFORK and MADV_KEEPONFORK documentation to
madvise.2.  The new functionality was recently merged by
Linus, and should be in the 4.14 kernel.

While documenting what EINVAL means for MADV_WIPEONFORK,
I realized that MADV_FREE has the same thing going on,
so I documented EINVAL for both in the ERRORS section.

This patch documents the following kernel commit:

commit d2cd9ede6e193dd7d88b6d27399e96229a551b19
Author: Rik van Riel <riel@redhat.com>
Date:   Wed Sep 6 16:25:15 2017 -0700

    mm,fork: introduce MADV_WIPEONFORK

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Colm MacC=C3=A1rthaigh <colm@allcosts.net>

diff --git a/man2/fork.2 b/man2/fork.2
index b5af58ca08c0..b11e750e3876 100644
--- a/man2/fork.2
+++ b/man2/fork.2
@@ -140,6 +140,12 @@ Memory mappings that have been marked with the
 flag are not inherited across a
 .BR fork ().
 .IP *
+Memory in mappings that have been marked with the
+.BR madvise (2)
+.B MADV_WIPEONFORK
+flag is zeroed in the child after a
+.BR fork ().
+.IP *
 The termination signal of the child is always
 .B SIGCHLD
 (see
diff --git a/man2/madvise.2 b/man2/madvise.2
index dfb31b63dba3..bb0ac469c509 100644
--- a/man2/madvise.2
+++ b/man2/madvise.2
@@ -31,6 +31,9 @@
 .\" 2010-06-19, Andi Kleen, Add documentation of MADV_SOFT_OFFLINE.
 .\" 2011-09-18, Doug Goldstein <cardoe@cardoe.com>
 .\"     Document MADV_HUGEPAGE and MADV_NOHUGEPAGE
+.\" 2017-09-14, Rik van Riel <riel@redhat.com>
+.\"     Document MADV_WIPEONFORK and MADV_KEEPONFORK
+.\" commit d2cd9ede6e193dd7d88b6d27399e96229a551b19
 .\"
 .TH MADVISE 2 2017-07-13 "Linux" "Linux Programmer's Manual"
 .SH NAME
@@ -405,6 +408,22 @@ can be applied only to private anonymous pages (see
 .BR mmap (2)).
 On a swapless system, freeing pages in a given range happens instantly,
 regardless of memory pressure.
+.TP
+.BR MADV_WIPEONFORK " (since Linux 4.14)"
+Present the child process with zero-filled memory in this range after a
+.BR fork (2).
+This is useful for per-process data in forking servers that should be
+re-initialized in the child process after a fork, for example PRNG seeds,
+cryptographic secrets, etc.
+.IP
+The
+.B MADV_WIPEONFORK
+operation can only be applied to private anonymous pages (see
+.BR mmap (2)).
+.TP
+.BR MADV_KEEPONFORK " (since Linux 4.14)"
+Undo the effect of an earlier
+.BR MADV_WIPEONFORK .
 .SH RETURN VALUE
 On success,
 .BR madvise ()
@@ -457,6 +476,18 @@ or
 but the kernel was not configured with
 .BR CONFIG_KSM .
 .TP
+.B EINVAL
+.I advice
+is
+.BR MADV_FREE
+or
+.BR MADV_WIPEONFORK
+but the specified address range includes file, Huge TLB,
+.BR MAP_SHARED ,
+or
+.BR VM_PFNMAP
+ranges.
+.TP
 .B EIO
 (for
 .BR MADV_WILLNEED )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
