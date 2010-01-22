From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 3/4] vfs: take f_lock on modifying f_mode after open time
Date: Fri, 22 Jan 2010 12:59:17 +0800
Message-ID: <20100122051517.549075734@intel.com>
References: <20100122045914.993668874@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752306Ab0AVFTa@vger.kernel.org>
Content-Disposition: inline; filename=fmode-lock.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, stable@kernel.org, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

We'll introduce FMODE_RANDOM which will be runtime modified.
So protect all runtime modification to f_mode with f_lock to
avoid races.

CC: Al Viro <viro@zeniv.linux.org.uk>
CC: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/file_table.c     |    2 ++
 fs/nfsd/nfs4state.c |    2 ++
 2 files changed, 4 insertions(+)

--- linux.orig/fs/file_table.c	2010-01-15 09:11:07.000000000 +0800
+++ linux/fs/file_table.c	2010-01-15 09:11:15.000000000 +0800
@@ -392,7 +392,9 @@ retry:
 			continue;
 		if (!(f->f_mode & FMODE_WRITE))
 			continue;
+		spin_lock(&f->f_lock);
 		f->f_mode &= ~FMODE_WRITE;
+		spin_unlock(&f->f_lock);
 		if (file_check_writeable(f) != 0)
 			continue;
 		file_release_write(f);
--- linux.orig/fs/nfsd/nfs4state.c	2010-01-15 09:08:22.000000000 +0800
+++ linux/fs/nfsd/nfs4state.c	2010-01-15 09:11:15.000000000 +0800
@@ -1998,7 +1998,9 @@ nfs4_file_downgrade(struct file *filp, u
 {
 	if (share_access & NFS4_SHARE_ACCESS_WRITE) {
 		drop_file_write_access(filp);
+		spin_lock(&filp->f_lock);
 		filp->f_mode = (filp->f_mode | FMODE_READ) & ~FMODE_WRITE;
+		spin_unlock(&filp->f_lock);
 	}
 }
 
