Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 166DD6B0006
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g13so2534967wrh.23
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:04 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id u97si4763849wrb.547.2018.03.29.04.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:02 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 046/109] mm: add kernel_mbind() helper; remove in-kernel call to syscall
Date: Thu, 29 Mar 2018 13:23:23 +0200
Message-Id: <20180329112426.23043-47-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Using the mm-internal kernel_mbind() helper allows us to get rid of the
mm-internal call to the sys_mbind() syscall.

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 mm/mempolicy.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7399ede02b5f..e4d7d4c0b253 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1336,9 +1336,9 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
 	return copy_to_user(mask, nodes_addr(*nodes), copy) ? -EFAULT : 0;
 }
 
-SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
-		unsigned long, mode, const unsigned long __user *, nmask,
-		unsigned long, maxnode, unsigned, flags)
+static long kernel_mbind(unsigned long start, unsigned long len,
+			 unsigned long mode, const unsigned long __user *nmask,
+			 unsigned long maxnode, unsigned int flags)
 {
 	nodemask_t nodes;
 	int err;
@@ -1357,6 +1357,13 @@ SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
 	return do_mbind(start, len, mode, mode_flags, &nodes, flags);
 }
 
+SYSCALL_DEFINE6(mbind, unsigned long, start, unsigned long, len,
+		unsigned long, mode, const unsigned long __user *, nmask,
+		unsigned long, maxnode, unsigned int, flags)
+{
+	return kernel_mbind(start, len, mode, nmask, maxnode, flags);
+}
+
 /* Set the process memory policy */
 SYSCALL_DEFINE3(set_mempolicy, int, mode, const unsigned long __user *, nmask,
 		unsigned long, maxnode)
@@ -1575,7 +1582,7 @@ COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
 			return -EFAULT;
 	}
 
-	return sys_mbind(start, len, mode, nm, nr_bits+1, flags);
+	return kernel_mbind(start, len, mode, nm, nr_bits+1, flags);
 }
 
 COMPAT_SYSCALL_DEFINE4(migrate_pages, compat_pid_t, pid,
-- 
2.16.3
