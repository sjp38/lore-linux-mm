Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 382DE6B007B
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 21:41:06 -0500 (EST)
Date: Wed, 24 Feb 2010 10:41:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224024100.GA17048@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

With default rsize=512k and NFS_MAX_READAHEAD=15, the current NFS
readahead size 512k*15=7680k is too large than necessary for typical
clients.

On a e1000e--e1000e connection, I got the following numbers

	readahead size		throughput
		   16k           35.5 MB/s
		   32k           54.3 MB/s
		   64k           64.1 MB/s
		  128k           70.5 MB/s
		  256k           74.6 MB/s
rsize ==>	  512k           77.4 MB/s
		 1024k           85.5 MB/s
		 2048k           86.8 MB/s
		 4096k           87.9 MB/s
		 8192k           89.0 MB/s
		16384k           87.7 MB/s

So it seems that readahead_size=2*rsize (ie. keep two RPC requests in flight)
can already get near full NFS bandwidth.

The test script is:

#!/bin/sh

file=/mnt/sparse
BDI=0:15

for rasize in 16 32 64 128 256 512 1024 2048 4096 8192 16384
do
	echo 3 > /proc/sys/vm/drop_caches
	echo $rasize > /sys/devices/virtual/bdi/$BDI/read_ahead_kb
	echo readahead_size=${rasize}k
	dd if=$file of=/dev/null bs=4k count=1024000
done

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/client.c   |    4 +++-
 fs/nfs/internal.h |    8 --------
 2 files changed, 3 insertions(+), 9 deletions(-)

--- linux.orig/fs/nfs/client.c	2010-02-23 11:15:44.000000000 +0800
+++ linux/fs/nfs/client.c	2010-02-24 10:16:00.000000000 +0800
@@ -889,7 +889,9 @@ static void nfs_server_set_fsinfo(struct
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 
 	server->backing_dev_info.name = "nfs";
-	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	server->backing_dev_info.ra_pages = max_t(unsigned long,
+					      default_backing_dev_info.ra_pages,
+					      2 * server->rpages);
 	server->backing_dev_info.capabilities |= BDI_CAP_ACCT_UNSTABLE;
 
 	if (server->wsize > max_rpc_payload)
--- linux.orig/fs/nfs/internal.h	2010-02-23 11:15:44.000000000 +0800
+++ linux/fs/nfs/internal.h	2010-02-23 13:26:00.000000000 +0800
@@ -10,14 +10,6 @@
 
 struct nfs_string;
 
-/* Maximum number of readahead requests
- * FIXME: this should really be a sysctl so that users may tune it to suit
- *        their needs. People that do NFS over a slow network, might for
- *        instance want to reduce it to something closer to 1 for improved
- *        interactive response.
- */
-#define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
-
 /*
  * Determine if sessions are in use.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
