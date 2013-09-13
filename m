Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 93FE96B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 07:02:33 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id eo20so858452lab.6
        for <linux-mm@kvack.org>; Fri, 13 Sep 2013 04:02:31 -0700 (PDT)
Subject: [PATCH] shmem: fixup memory reservation during truncating
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 13 Sep 2013 15:02:24 +0400
Message-ID: <20130913110224.20826.74479.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Shared anon mappings created without MAP_NORESERVE may hold reservation of
memory commitment for whole size of shmem segment. There was no way to change
that size, but recently introduced 'map_files' in proc allows to do that.
This patch adjust memory reservation in shmem_setattr() during truncating.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index ff08920..a15c8dd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -148,6 +148,19 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
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
@@ -607,6 +620,10 @@ static int shmem_setattr(struct dentry *dentry, struct iattr *attr)
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
