Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 274C46B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 08:05:03 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m190so512318pgm.4
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:05:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b72sor270892pfm.1.2018.04.11.05.05.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 05:05:01 -0700 (PDT)
From: mhocko@kernel.org
Subject: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
Date: Wed, 11 Apr 2018 14:04:52 +0200
Message-Id: <20180411120452.1736-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
atomicaly probe for a given address range.

[wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
Hi,
Andrew's sent the MAP_FIXED_NOREPLACE to Linus for the upcoming merge
window. So here we go with the man page update.

 man2/mmap.2 | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/man2/mmap.2 b/man2/mmap.2
index ea64eb8f0dcc..f702f3e4eba2 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -261,6 +261,27 @@ Examples include
 and the PAM libraries
 .UR http://www.linux-pam.org
 .UE .
+Newer kernels
+(Linux 4.17 and later) have a
+.B MAP_FIXED_NOREPLACE
+option that avoids the corruption problem; if available, MAP_FIXED_NOREPLACE
+should be preferred over MAP_FIXED.
+.TP
+.BR MAP_FIXED_NOREPLACE " (since Linux 4.17)"
+Similar to MAP_FIXED with respect to the
+.I
+addr
+enforcement, but different in that MAP_FIXED_NOREPLACE never clobbers a pre-existing
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
 .TP
 .B MAP_GROWSDOWN
 This flag is used for stacks.
@@ -487,6 +508,12 @@ is not a valid file descriptor (and
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
2.16.3
