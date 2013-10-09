Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 46FA36B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 05:08:11 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so747976pad.16
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 02:08:10 -0700 (PDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 9 Oct 2013 10:08:06 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id E6D6C2190069
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 10:08:03 +0100 (BST)
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9996aE314090462
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 09:06:36 GMT
Received: from d06av02.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9996jmP026107
	for <linux-mm@kvack.org>; Wed, 9 Oct 2013 03:06:48 -0600
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 1/2] mmap: arch_get_unmapped_area(): use proper mmap base for bottom up direction
Date: Wed,  9 Oct 2013 11:06:42 +0200
Message-Id: <1381309603-19570-1-git-send-email-heiko.carstens@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Radu Caragea <sinaelgl@gmail.com>, Michel Lespinasse <walken@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Heiko Carstens <heiko.carstens@de.ibm.com>

This is more or less the generic variant of 41aacc1eea "x86 get_unmapped_area:
Access mmap_legacy_base through mm_struct member".

So effectively architectures which use an own arch_pick_mmap_layout()
implementation but call the generic arch_get_unmapped_area() now can also
randomize their mmap_base.

All architectures which have an own arch_pick_mmap_layout() and call
the generic arch_get_unmapped_area() (arm64, s390, tile) currently set
mmap_base to TASK_UNMAPPED_BASE. This is also true for the generic
arch_pick_mmap_layout() function. So this change is a no-op currently.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 9d54851..fa206ab 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1872,7 +1872,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 
 	info.flags = 0;
 	info.length = len;
-	info.low_limit = TASK_UNMAPPED_BASE;
+	info.low_limit = mm->mmap_base;
 	info.high_limit = TASK_SIZE;
 	info.align_mask = 0;
 	return vm_unmapped_area(&info);
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
