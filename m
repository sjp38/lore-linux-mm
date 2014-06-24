Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2367D6B0036
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:16:16 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id el20so52072lab.35
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:15 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id be17si1306499lab.88.2014.06.24.13.16.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 13:16:14 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id ty20so50911lab.17
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:16:14 -0700 (PDT)
Subject: [PATCH 2/3] shmem: update memory reservation on truncate
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Wed, 25 Jun 2014 00:16:10 +0400
Message-ID: <20140624201610.18273.93645.stgit@zurg>
In-Reply-To: <20140624201606.18273.44270.stgit@zurg>
References: <20140624201606.18273.44270.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

Shared anonymous mapping created without MAP_NORESERVE holds memory
reservation for whole range of shmem segment. Usually there is no way to
change its size, but /proc/<pid>/map_files/...
(available if CONFIG_CHECKPOINT_RESTORE=y) allows to do that.

This patch adjust memory reservation in shmem_setattr().

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

---

exploit:

#include <sys/mman.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char **argv)
{
	unsigned long addr;
	char path[100];

	/* charge 4KiB */
	addr = (unsigned long)mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANONYMOUS, -1, 0);
	sprintf(path, "/proc/self/map_files/%lx-%lx", addr, addr + 4096);
	truncate(path, 1 << 30);
	/* uncharge 1GiB */
}
---
 mm/shmem.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0aabcbd..a3c49d6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -149,6 +149,19 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
 		vm_unacct_memory(VM_ACCT(size));
 }
 
+static inline int shmem_reacct_size(unsigned long flags,
+		loff_t oldsize, loff_t newsize)
+{
+	if (!(flags & VM_NORESERVE)) {
+		if (VM_ACCT(newsize) > VM_ACCT(oldsize))
+			return security_vm_enough_memory_mm(current->mm,
+					VM_ACCT(newsize) - VM_ACCT(oldsize));
+		else if (VM_ACCT(newsize) < VM_ACCT(oldsize))
+			vm_unacct_memory(VM_ACCT(oldsize) - VM_ACCT(newsize));
+	}
+	return 0;
+}
+
 /*
  * ... whereas tmpfs objects are accounted incrementally as
  * pages are allocated, in order to allow huge sparse files.
@@ -543,6 +556,10 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
 		loff_t newsize = attr->ia_size;
 
 		if (newsize != oldsize) {
+			error = shmem_reacct_size(SHMEM_I(inode)->flags,
+					oldsize, newsize);
+			if (error)
+				return error;
 			i_size_write(inode, newsize);
 			inode->i_ctime = inode->i_mtime = CURRENT_TIME;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
