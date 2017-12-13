Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EDB16B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:31:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id v190so1289690pgv.11
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 01:31:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor450022pll.95.2017.12.13.01.31.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 01:31:24 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mmap.2: document new MAP_FIXED_SAFE flag
Date: Wed, 13 Dec 2017 10:31:09 +0100
Message-Id: <20171213093110.3550-1-mhocko@kernel.org>
In-Reply-To: <20171213092550.2774-1-mhocko@kernel.org>
References: <20171213092550.2774-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

4.16+ kernels offer a new MAP_FIXED_SAFE flag which allows the caller to
atomicaly probe for a given address range.

[wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 man2/mmap.2 | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
index a5a8eb47a263..02d391697ce6 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -227,6 +227,22 @@ in mind that the exact layout of a process' memory map is allowed to change
 significantly between kernel versions, C library versions, and operating system
 releases.
 .TP
+.BR MAP_FIXED_SAFE " (since Linux 4.16)"
+Similar to MAP_FIXED with respect to the
+.I
+addr
+enforcement, but different in that MAP_FIXED_SAFE never clobbers a pre-existing
+mapped range. If the requested range would collide with an existing
+mapping, then this call fails with
+.B EEXIST.
+This flag can therefore be used as a way to atomically (with respect to other
+threads) attempt to map an address range: one thread will succeed; all others
+will report failure. Please note that older kernels which do not recognize this
+flag will typically (upon detecting a collision with a pre-existing mapping)
+fall back to a "non-MAP_FIXED" type of behavior: they will return an address that
+is different than the requested one. Therefore, backward-compatible software
+should check the returned address against the requested address.
+.TP
 .B MAP_GROWSDOWN
 This flag is used for stacks.
 It indicates to the kernel virtual memory system that the mapping
@@ -451,6 +467,12 @@ is not a valid file descriptor (and
 .B MAP_ANONYMOUS
 was not set).
 .TP
+.B EEXIST
+range covered by
+.IR addr ,
+.IR length
+is clashing with an existing mapping.
+.TP
 .B EINVAL
 We don't like
 .IR addr ,
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
