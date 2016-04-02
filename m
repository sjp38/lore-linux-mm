Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f42.google.com (mail-lf0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1916B025F
	for <linux-mm@kvack.org>; Sat,  2 Apr 2016 15:18:38 -0400 (EDT)
Received: by mail-lf0-f42.google.com with SMTP id k79so115512950lfb.2
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 12:18:38 -0700 (PDT)
Received: from mail-lb0-x243.google.com (mail-lb0-x243.google.com. [2a00:1450:4010:c04::243])
        by mx.google.com with ESMTPS id o2si11352585lfa.61.2016.04.02.12.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Apr 2016 12:18:37 -0700 (PDT)
Received: by mail-lb0-x243.google.com with SMTP id bc4so14220674lbc.0
        for <linux-mm@kvack.org>; Sat, 02 Apr 2016 12:18:36 -0700 (PDT)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH 3/3] man/mremap.2: don't unmap the overlapping VMA(s)
Date: Sat,  2 Apr 2016 21:17:34 +0200
Message-Id: <1459624654-7955-4-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
References: <1459624654-7955-1-git-send-email-kwapulinski.piotr@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, mtk.manpages@gmail.com, cmetcalf@mellanox.com, arnd@arndb.de, viro@zeniv.linux.org.uk, mszeredi@suse.cz, dave@stgolabs.net, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mingo@kernel.org, dan.j.williams@intel.com, dave.hansen@linux.intel.com, koct9i@gmail.com, hannes@cmpxchg.org, jack@suse.cz, xiexiuqi@huawei.com, iamjoonsoo.kim@lge.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, rientjes@google.com, denc716@gmail.com, toshi.kani@hpe.com, ldufour@linux.vnet.ibm.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

mremap.2 man page update for MREAP_DONTUNMAP flag of mremap.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
It should be considered to be merged only in case the patch
"[PATCH 2/3] mm/mremap.c: don't unmap the overlapping VMA(s)"
is merged.
---
 man2/mremap.2 | 50 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 45 insertions(+), 5 deletions(-)

diff --git a/man2/mremap.2 b/man2/mremap.2
index e4998a4..978d509 100644
--- a/man2/mremap.2
+++ b/man2/mremap.2
@@ -27,7 +27,7 @@
 .\"            Update for Linux 1.3.87 and later
 .\" 2005-10-11 mtk: Added NOTES for MREMAP_FIXED; revised EINVAL text.
 .\"
-.TH MREMAP 2 2015-12-05 "Linux" "Linux Programmer's Manual"
+.TH MREMAP 2 2016-04-02 "Linux" "Linux Programmer's Manual"
 .SH NAME
 mremap \- remap a virtual memory address
 .SH SYNOPSIS
@@ -104,7 +104,9 @@ accepts a fifth argument,
 .IR "void\ *new_address" ,
 which specifies a page-aligned address to which the mapping must
 be moved.
-Any previous mapping at the address range specified by
+If
+.B MREMAP_DONTUNMAP
+is not set then any previous mapping at the address range specified by
 .I new_address
 and
 .I new_size
@@ -114,6 +116,30 @@ If
 is specified, then
 .B MREMAP_MAYMOVE
 must also be specified.
+.TP
+.BR MREMAP_DONTUNMAP " (since Linux 4.6)"
+This flag is similar to
+.B MAP_DONTUNMAP
+flag of
+.BR mmap (2).
+If this flag and
+.B MREMAP_FIXED
+are set and the memory region specified by
+.I new_address
+and
+.I new_size
+overlaps pages of any existing mapping(s), then the
+.BR mremap ()
+will fail with
+.BR ENOMEM .
+No existing mapping(s) will be discarded. If
+.B MREMAP_DONTUNMAP
+is specified, then
+.B MREMAP_FIXED
+must also be specified.
+
+Note: currently, this flag is not implemented in the glibc wrapper.
+Use the numerical value 4, if you want to use it.
 .PP
 If the memory segment specified by
 .I old_address
@@ -156,8 +182,9 @@ page aligned; a value other than
 .B MREMAP_MAYMOVE
 or
 .B MREMAP_FIXED
-was specified in
-.IR flags ;
+or
+.B MREMAP_DONTUNMAP
+was specified in \fIflags\fP;
 .I new_size
 was zero;
 .I new_size
@@ -175,13 +202,26 @@ and
 or
 .B MREMAP_FIXED
 was specified without also specifying
-.BR MREMAP_MAYMOVE .
+.BR MREMAP_MAYMOVE ;
+or
+.B MREMAP_DONTUNMAP
+was specified without also specifying
+.BR MREMAP_FIXED .
 .TP
 .B ENOMEM
 The memory area cannot be expanded at the current virtual address, and the
 .B MREMAP_MAYMOVE
 flag is not set in \fIflags\fP.
 Or, there is not enough (virtual) memory available.
+Or, both the
+.B MREMAP_FIXED
+and
+.B MREMAP_DONTUNMAP
+flags are set and the memory region specified by
+.I new_address
+and
+.I new_size
+overlaps pages of any existing mapping(s).
 .SH CONFORMING TO
 This call is Linux-specific, and should not be used in programs
 intended to be portable.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
