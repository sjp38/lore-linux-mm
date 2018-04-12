Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E21946B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:39:51 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v74so3795791qkl.9
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 08:39:51 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id y10sor3088346qkl.24.2018.04.12.08.39.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 08:39:50 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 12 Apr 2018 17:39:41 +0200
Message-Id: <20180412153941.170849-1-jannh@google.com>
Subject: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
From: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com, linux-man@vger.kernel.org, mhocko@kernel.org, jhubbard@nvidia.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, jannh@google.com

Clarify that MAP_FIXED is appropriate if the specified address range has
been reserved using an existing mapping, but shouldn't be used otherwise.

Signed-off-by: Jann Horn <jannh@google.com>
---
 man2/mmap.2 | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index bef8b4432..80c9ec285 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -253,8 +253,9 @@ Software that aspires to be portable should use this option with care,
 keeping in mind that the exact layout of a process's memory mappings
 is allowed to change significantly between kernel versions,
 C library versions, and operating system releases.
-Furthermore, this option is extremely hazardous (when used on its own),
-because it forcibly removes preexisting mappings,
+This option should only be used when the specified memory region has
+already been reserved using another mapping; otherwise, it is extremely
+hazardous because it forcibly removes preexisting mappings,
 making it easy for a multithreaded process to corrupt its own address space.
 .IP
 For example, suppose that thread A looks through
@@ -284,13 +285,15 @@ and the PAM libraries
 .UR http://www.linux-pam.org
 .UE .
 .IP
-Newer kernels
-(Linux 4.17 and later) have a
+For cases in which the specified memory region has not been reserved using an
+existing mapping, newer kernels (Linux 4.17 and later) provide an option
 .B MAP_FIXED_NOREPLACE
-option that avoids the corruption problem; if available,
-.B MAP_FIXED_NOREPLACE
-should be preferred over
-.BR MAP_FIXED .
+that should be used instead; older kernels require the caller to use
+.I addr
+as a hint (without
+.BR MAP_FIXED )
+and take appropriate action if the kernel places the new mapping at a
+different address.
 .TP
 .BR MAP_FIXED_NOREPLACE " (since Linux 4.17)"
 .\" commit a4ff8e8620d3f4f50ac4b41e8067b7d395056843
-- 
2.17.0.484.g0c8726318c-goog
