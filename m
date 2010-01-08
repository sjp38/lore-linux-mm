Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B0C8A60021B
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 17:10:20 -0500 (EST)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
References: <20100108220516.23489.11319.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH 1/6] NOMMU: Fix SYSV SHM for NOMMU
Date: Fri, 08 Jan 2010 22:10:13 +0000
Message-ID: <23917.1262988613@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: dhowells@redhat.com, viro@ZenIV.linux.org.uk, vapier@gentoo.org, lethal@linux-sh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Howells <dhowells@redhat.com> wrote:

> Put it back conditionally on CONFIG_MMU=n.

Seems I forgot to put in the conditional bits.  Revised patch attached.

David
---
From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Fix SYSV SHM for NOMMU

Commit c4caa778157dbbf04116f0ac2111e389b5cd7a29 broke SYSV SHM for NOMMU by
taking away the pointer to shm_get_unmapped_area() from shm_file_operations.

Put it back conditionally on CONFIG_MMU=n.

file->f_ops->get_unmapped_area() is used to find out the base address for a
mapping of a mappable chardev device or mappable memory-based file (such as a
ramfs file).  It needs to be called prior to file->f_ops->mmap() being called.

Signed-off-by: David Howells <dhowells@redhat.com>
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
