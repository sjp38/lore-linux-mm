Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 161496B0255
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 10:23:51 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so153130832wic.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 07:23:50 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id br17si29696200wib.49.2015.09.29.07.23.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 29 Sep 2015 07:23:49 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id E1ED498CAF
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 14:23:48 +0000 (UTC)
Date: Tue, 29 Sep 2015 15:23:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: swap: Use swap_lock to prevent parallel swapon
 activations instead of i_mutex
Message-ID: <20150929142347.GK3068@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Marchand <jmarchan@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Hugh Dickins <hughd@google.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Jerome Marchand reported a lockdep warning as follows

    [ 6819.501009] =================================
    [ 6819.501009] [ INFO: inconsistent lock state ]
    [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tainted
    [ 6819.501009] ---------------------------------
    [ 6819.501009] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
    [ 6819.501009] kswapd0/38 [HC0[0]:SC0[0]:HE1:SE1] takes:
    [ 6819.501009]  (&sb->s_type->i_mutex_key#17){+.+.?.}, at: [<ffffffffa03772a5>] nfs_file_direct_write+0x85/0x3f0 [nfs]
    [ 6819.501009] {RECLAIM_FS-ON-W} state was registered at:
    [ 6819.501009]   [<ffffffff81107f51>] mark_held_locks+0x71/0x90
    [ 6819.501009]   [<ffffffff8110b775>] lockdep_trace_alloc+0x75/0xe0
    [ 6819.501009]   [<ffffffff81245529>] kmem_cache_alloc_node_trace+0x39/0x440
    [ 6819.501009]   [<ffffffff81225b8f>] __get_vm_area_node+0x7f/0x160
    [ 6819.501009]   [<ffffffff81226eb2>] __vmalloc_node_range+0x72/0x2c0
    [ 6819.501009]   [<ffffffff81227424>] vzalloc+0x54/0x60
    [ 6819.501009]   [<ffffffff8122c7c8>] SyS_swapon+0x628/0xfc0
    [ 6819.501009]   [<ffffffff81867772>] entry_SYSCALL_64_fastpath+0x12/0x76

It's due to NFS acquiring i_mutex since a9ab5e840669 ("nfs: page
cache invalidation for dio") to invalidate page cache before direct I/O.
Filesystems may safely acquire i_mutex during direct writes but NFS is unique
in its treatment of swap files. Ordinarily swap files are supported by the
core VM looking up the physical block for a given offset in advance. There
is no physical block for NFS and the direct write paths are used after
calling mapping->swap_activate.

The lockdep warning is triggered by swapon(), which is not in reclaim
context, acquiring the i_mutex to ensure a swapfile is not activated twice.

swapon does not need the i_mutex for this purpose.  There is a requirement
that fallocate not be used on swapfiles but this is protected by the inode
flag S_SWAPFILE and nothing to do with i_mutex. In fact, the current
protection does nothing for block devices. This patch expands the role
of swap_lock to protect against parallel activations of block devices and
swapfiles and removes the use of i_mutex. This both improves the protection
for swapon and avoids the lockdep warning.

Reported-and-tested-by: Jerome Marchand <jmarchan@redhat.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/swapfile.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 58877312cf6b..e55a69fd24e4 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1970,9 +1970,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		set_blocksize(bdev, old_block_size);
 		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
 	} else {
-		mutex_lock(&inode->i_mutex);
+		spin_lock(&swap_lock);
 		inode->i_flags &= ~S_SWAPFILE;
-		mutex_unlock(&inode->i_mutex);
+		spin_unlock(&swap_lock);
 	}
 	filp_close(swap_file, NULL);
 
@@ -2197,7 +2197,6 @@ static int claim_swapfile(struct swap_info_struct *p, struct inode *inode)
 		p->flags |= SWP_BLKDEV;
 	} else if (S_ISREG(inode->i_mode)) {
 		p->bdev = inode->i_sb->s_bdev;
-		mutex_lock(&inode->i_mutex);
 		if (IS_SWAPFILE(inode))
 			return -EBUSY;
 	} else
@@ -2426,12 +2425,15 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 
+	/* prevent parallel swapons */
+	spin_lock(&swap_lock);
 	p->swap_file = swap_file;
 	mapping = swap_file->f_mapping;
 	inode = mapping->host;
 
 	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
 	error = claim_swapfile(p, inode);
+	spin_unlock(&swap_lock);
 	if (unlikely(error))
 		goto bad_swap;
 
@@ -2574,10 +2576,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	vfree(swap_map);
 	vfree(cluster_info);
 	if (swap_file) {
-		if (inode && S_ISREG(inode->i_mode)) {
-			mutex_unlock(&inode->i_mutex);
+		if (inode && S_ISREG(inode->i_mode))
 			inode = NULL;
-		}
 		filp_close(swap_file, NULL);
 	}
 out:
@@ -2587,8 +2587,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	}
 	if (name)
 		putname(name);
-	if (inode && S_ISREG(inode->i_mode))
-		mutex_unlock(&inode->i_mutex);
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
