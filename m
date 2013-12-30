Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E2ED86B0039
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 08:46:00 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so11667711pad.30
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 05:46:00 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id gx4si33593239pbc.141.2013.12.30.05.45.58
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 05:45:58 -0800 (PST)
From: Li Wang <liwang@ubuntukylin.com>
Subject: [PATCH 3/3] Fadvise: Add the ability for directory level page cache cleaning
Date: Mon, 30 Dec 2013 21:45:18 +0800
Message-Id: <c31e91f1cea4afc0d86671fbe84f70d8d5d11329.1388409687.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>, Li Wang <liwang@ubuntukylin.com>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>


Signed-off-by: Li Wang <liwang@ubuntukylin.com>
Signed-off-by: Yunchuan Wen <yunchuanwen@ubuntukylin.com>
---
 mm/fadvise.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index 3bcfd81..644d32d 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -113,6 +113,10 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	case POSIX_FADV_NOREUSE:
 		break;
 	case POSIX_FADV_DONTNEED:
+		if (S_ISDIR(file_inode(f.file)->i_mode)) {
+			shrink_pagecache_parent(f.file->f_dentry);
+			goto out;
+		}
 		if (!bdi_write_congested(mapping->backing_dev_info))
 			__filemap_fdatawrite_range(mapping, offset, endbyte,
 						   WB_SYNC_NONE);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
