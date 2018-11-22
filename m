Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB746B2CFD
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 14:57:16 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x21-v6so7140405pln.10
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:57:16 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cd16si24508687plb.47.2018.11.22.11.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 11:57:15 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.9 15/15] tmpfs: make lseek(SEEK_DATA/SEK_HOLE) return ENXIO with a negative offset
Date: Thu, 22 Nov 2018 14:56:21 -0500
Message-Id: <20181122195621.13776-15-sashal@kernel.org>
In-Reply-To: <20181122195621.13776-1-sashal@kernel.org>
References: <20181122195621.13776-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Yufen Yu <yuyufen@huawei.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, William Kucharski <william.kucharski@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Yufen Yu <yuyufen@huawei.com>

[ Upstream commit 1a413646931cb14442065cfc17561e50f5b5bb44 ]

Other filesystems such as ext4, f2fs and ubifs all return ENXIO when
lseek (SEEK_DATA or SEEK_HOLE) requests a negative offset.

man 2 lseek says

:      EINVAL whence  is  not  valid.   Or: the resulting file offset would be
:             negative, or beyond the end of a seekable device.
:
:      ENXIO  whence is SEEK_DATA or SEEK_HOLE, and the file offset is  beyond
:             the end of the file.

Make tmpfs return ENXIO under these circumstances as well.  After this,
tmpfs also passes xfstests's generic/448.

[akpm@linux-foundation.org: rewrite changelog]
Link: http://lkml.kernel.org/r/1540434176-14349-1-git-send-email-yuyufen@huawei.com
Signed-off-by: Yufen Yu <yuyufen@huawei.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Hugh Dickins <hughd@google.com>
Cc: William Kucharski <william.kucharski@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/shmem.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 4b5cca167baf..358a92be43eb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2414,9 +2414,7 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 	inode_lock(inode);
 	/* We're holding i_mutex so we can access i_size directly */
 
-	if (offset < 0)
-		offset = -EINVAL;
-	else if (offset >= inode->i_size)
+	if (offset < 0 || offset >= inode->i_size)
 		offset = -ENXIO;
 	else {
 		start = offset >> PAGE_SHIFT;
-- 
2.17.1
