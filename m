Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A342B6B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:27:17 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id ez4so76419286wjd.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:17 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t81si20578289wme.38.2017.02.01.01.27.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 01:27:16 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id u63so4480216wmu.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:16 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] fs: break out of iomap_file_buffered_write on fatal signals
Date: Wed,  1 Feb 2017 10:27:04 +0100
Message-Id: <20170201092706.9966-2-mhocko@kernel.org>
In-Reply-To: <20170201092706.9966-1-mhocko@kernel.org>
References: <20170201092706.9966-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo has noticed that an OOM stress test which performs large write
requests can cause the full memory reserves depletion. He has tracked
this down to the following path
	__alloc_pages_nodemask+0x436/0x4d0
	alloc_pages_current+0x97/0x1b0
	__page_cache_alloc+0x15d/0x1a0          mm/filemap.c:728
	pagecache_get_page+0x5a/0x2b0           mm/filemap.c:1331
	grab_cache_page_write_begin+0x23/0x40   mm/filemap.c:2773
	iomap_write_begin+0x50/0xd0             fs/iomap.c:118
	iomap_write_actor+0xb5/0x1a0            fs/iomap.c:190
	? iomap_write_end+0x80/0x80             fs/iomap.c:150
	iomap_apply+0xb3/0x130                  fs/iomap.c:79
	iomap_file_buffered_write+0x68/0xa0     fs/iomap.c:243
	? iomap_write_end+0x80/0x80
	xfs_file_buffered_aio_write+0x132/0x390 [xfs]
	? remove_wait_queue+0x59/0x60
	xfs_file_write_iter+0x90/0x130 [xfs]
	__vfs_write+0xe5/0x140
	vfs_write+0xc7/0x1f0
	? syscall_trace_enter+0x1d0/0x380
	SyS_write+0x58/0xc0
	do_syscall_64+0x6c/0x200
	entry_SYSCALL64_slow_path+0x25/0x25

the oom victim has access to all memory reserves to make a forward
progress to exit easier. But iomap_file_buffered_write and other callers
of iomap_apply loop to complete the full request. We need to check for
fatal signals and back off with a short write instead. As the
iomap_apply delegates all the work down to the actor we have to hook
into those. All callers that work with the page cache are calling
iomap_write_begin so we will check for signals there. dax_iomap_actor
has to handle the situation explicitly because it copies data to the
userspace directly. Other callers like iomap_page_mkwrite work on a
single page or iomap_fiemap_actor do not allocate memory based on the
given len.

Fixes: 68a9f5e7007c ("xfs: implement iomap based buffered write path")
Cc: stable # 4.8+
Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/dax.c   | 5 +++++
 fs/iomap.c | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/fs/dax.c b/fs/dax.c
index 413a91db9351..0e263dacf9cf 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1033,6 +1033,11 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		struct blk_dax_ctl dax = { 0 };
 		ssize_t map_len;
 
+		if (fatal_signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+
 		dax.sector = dax_iomap_sector(iomap, pos);
 		dax.size = (length + offset + PAGE_SIZE - 1) & PAGE_MASK;
 		map_len = dax_map_atomic(iomap->bdev, &dax);
diff --git a/fs/iomap.c b/fs/iomap.c
index e57b90b5ff37..691eada58b06 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -114,6 +114,9 @@ iomap_write_begin(struct inode *inode, loff_t pos, unsigned len, unsigned flags,
 
 	BUG_ON(pos + len > iomap->offset + iomap->length);
 
+	if (fatal_signal_pending(current))
+		return -EINTR;
+
 	page = grab_cache_page_write_begin(inode->i_mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
