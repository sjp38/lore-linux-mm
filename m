Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 524208308F
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:59:18 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k135so8939130lfb.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 01:59:18 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z12si3505192wmz.119.2016.08.30.01.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 30 Aug 2016 01:59:16 -0700 (PDT)
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] mlock.2: document that is a bad idea to fork() after mlock()
Date: Tue, 30 Aug 2016 10:59:11 +0200
Message-Id: <20160830085911.5336-1-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

fork() will remove the write PTE bit from the page table on each VMA
which will be copied via COW. A such such, the memory is available but
marked read only in the page table and will fault on write access.
This renders the previous mlock() operation almost useless because in a
multi threaded application the RT thread may block on mmap_sem while the
thread with low priority is holding the mmap_sem (for instance because
it is allocating memory which needs to be mapped in).

There is actually nothing we can do to mitigate the outcome. We could
add a warning to the kernel for people that are not yet aware of the
updated documentation.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 man2/mlock.2 | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/man2/mlock.2 b/man2/mlock.2
index e34bb3b4e045..27f80f6664ef 100644
--- a/man2/mlock.2
+++ b/man2/mlock.2
@@ -350,6 +350,20 @@ settings are not inherited by a child created via
 and are cleared during an
 .BR execve (2).
=20
+Note that
+.BR fork (2)
+will prepare the address space for a copy-on-write operation. The conseque=
nce
+is that any write access that follows will cause a page fault which in tur=
n may
+cause high latencies for a real-time process. Therefore it is crucial not =
to
+invoke
+.BR fork (2)
+after the
+.BR mlockall ()
+or
+.BR mlock ()
+operation not even from thread which runs at a low priority within a proce=
ss
+which also has a thread running at elevated priority.
+
 The memory lock on an address range is automatically removed
 if the address range is unmapped via
 .BR munmap (2).
--=20
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
