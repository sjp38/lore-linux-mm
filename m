Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B8955620005
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:59:46 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/6] NOMMU: Fix SYSV SHM for NOMMU
Date: Thu, 14 Jan 2010 13:58:30 +0000
Message-ID: <20100114135830.10482.54124.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: torvalds@osdl.org, akpm@linux-foundation.org
Cc: viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org, dhowells@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Commit c4caa778157dbbf04116f0ac2111e389b5cd7a29 broke SYSV SHM for NOMMU by
taking away the pointer to shm_get_unmapped_area() from shm_file_operations.

Put it back conditionally on CONFIG_MMU=n.

file->f_ops->get_unmapped_area() is used to find out the base address for a
mapping of a mappable chardev device or mappable memory-based file (such as a
ramfs file).  It needs to be called prior to file->f_ops->mmap() being called.

Signed-off-by: David Howells <dhowells@redhat.com>
Acked-by: Al Viro <viro@zeniv.linux.org.uk>
---

 ipc/shm.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)


diff --git a/ipc/shm.c b/ipc/shm.c
index 92fe923..23256b8 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -298,6 +298,9 @@ static const struct file_operations shm_file_operations = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
 	.release	= shm_release,
+#ifndef CONFIG_MMU
+	.get_unmapped_area	= shm_get_unmapped_area,
+#endif
 };
 
 static const struct file_operations shm_file_operations_huge = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
