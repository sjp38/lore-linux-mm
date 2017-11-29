Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2E56B025F
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:45:36 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 8so2564176pfv.12
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:45:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f31sor751266plb.58.2017.11.29.06.45.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 06:45:35 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mmap.2: document new MAP_FIXED_SAFE flag
Date: Wed, 29 Nov 2017 15:45:24 +0100
Message-Id: <20171129144524.23518-1-mhocko@kernel.org>
In-Reply-To: <20171129144219.22867-1-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

4.16+ kernels offer a new MAP_FIXED_SAFE flag which allows to atomicaly
probe for a given address range.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 man2/mmap.2 | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 385f3bfd5393..622a7000de83 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -225,6 +225,18 @@ will fail.
 Because requiring a fixed address for a mapping is less portable,
 the use of this option is discouraged.
 .TP
+.B MAP_FIXED_SAFE (since 4.16)
+Similar to MAP_FIXED wrt. to the
+.I
+addr
+enforcement except it never clobbers a colliding mapped range and rather fail with
+.B EEXIST
+in such a case. This flag can therefore be used as a safe and atomic probe for the
+the specific address range. Please note that older kernels which do not recognize
+this flag can fallback to the hint based implementation and map to a different
+location. Any backward compatible software should therefore check the returning
+address with the given one.
+.TP
 .B MAP_GROWSDOWN
 This flag is used for stacks.
 It indicates to the kernel virtual memory system that the mapping
@@ -449,6 +461,12 @@ is not a valid file descriptor (and
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
