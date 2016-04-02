Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id BE1466B0253
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 15:18:16 -0400 (EDT)
Received: by mail-lf0-f51.google.com with SMTP id c62so115477223lfc.1
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 12:18:16 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id s197si11369718lfs.110.2016.04.02.12.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Apr 2016 12:18:15 -0700 (PDT)
Received: by mail-lb0-x242.google.com with SMTP id gk8so12046368lbc.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 12:18:15 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH 1/3] man/mmap.2: don't unmap the overlapping VMA(s)
Date: Sat,  2 Apr 2016 21:17:32 +0200
Message-Id: <1459624654-7955-2-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

mmap.2 man page update for MAP_DONTUNMAP flag of mmap.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
It should be considered to be merged only in case the patch
"[PATCH 0/3] mm/mmap.c: don't unmap the overlapping VMA(s)"
is merged.
---
 man2/mmap.2 | 32 ++++++++++++++++++++++++++++++--
 1 file changed, 30 insertions(+), 2 deletions(-)

diff --git a/man2/mmap.2 b/man2/mmap.2
index 0f2f277..0fc5879 100644
--- a/man2/mmap.2
+++ b/man2/mmap.2
@@ -37,7 +37,7 @@
 .\" 2007-07-10, mtk, Added an example program.
 .\" 2008-11-18, mtk, document MAP_STACK
 .\"
-.TH MMAP 2 2016-03-15 "Linux" "Linux Programmer's Manual"
+.TH MMAP 2 2016-04-02 "Linux" "Linux Programmer's Manual"
 .SH NAME
 mmap, munmap \- map or unmap files or devices into memory
 .SH SYNOPSIS
@@ -213,7 +213,9 @@ If the memory region specified by
 .I addr
 and
 .I len
-overlaps pages of any existing mapping(s), then the overlapped
+overlaps pages of any existing mapping(s) and
+.B MAP_DONTUNMAP
+is not set, then the overlapped
 part of the existing mapping(s) will be discarded.
 If the specified address cannot be used,
 .BR mmap ()
@@ -221,6 +223,23 @@ will fail.
 Because requiring a fixed address for a mapping is less portable,
 the use of this option is discouraged.
 .TP
+.BR MAP_DONTUNMAP " (since Linux 4.6)"
+If this flag and
+.B MAP_FIXED
+are set and the memory region specified by
+.I addr
+and
+.I length
+overlaps pages of any existing mapping(s), then the
+.BR mmap ()
+will fail with
+.BR ENOMEM .
+No existing mapping(s) will be
+discarded.
+
+Note: currently, this flag is not implemented in the glibc wrapper.
+Use the numerical hex value 40, if you want to use it.
+.TP
 .B MAP_GROWSDOWN
 Used for stacks.
 Indicates to the kernel virtual memory system that the mapping
@@ -477,6 +496,15 @@ No memory is available.
 .TP
 .B ENOMEM
 The process's maximum number of mappings would have been exceeded.
+Or, both the
+.B MAP_FIXED
+and
+.B MAP_DONTUNMAP
+flags are set and the memory region specified by
+.I addr
+and
+.I length
+overlaps pages of any existing mapping(s).
 This error can also occur for
 .BR munmap (2),
 when unmapping a region in the middle of an existing mapping,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
