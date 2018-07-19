Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD3126B000C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:18:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o25-v6so2046957wmh.1
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:18:59 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.17.21])
        by mx.google.com with ESMTPS id q6-v6si4711679wrj.176.2018.07.19.01.18.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:18:58 -0700 (PDT)
From: Chengguang Xu <cgxu519@gmx.com>
Subject: [PATCH] mm: adjust max read count in generic_file_buffered_read()
Date: Thu, 19 Jul 2018 16:17:26 +0800
Message-Id: <20180719081726.3341-1-cgxu519@gmx.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jack@suse.cz, mgorman@techsingularity.net, jlayton@redhat.com, ak@linux.intel.com, mawilcox@microsoft.com, tim.c.chen@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chengguang Xu <cgxu519@gmx.com>

When we try to truncate read count in generic_file_buffered_read(),
should deliver (sb->s_maxbytes - offset) as maximum count not
sb->s_maxbytes itself.

Signed-off-by: Chengguang Xu <cgxu519@gmx.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 52517f28e6f4..5c2d481d21cf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2064,7 +2064,7 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
 
 	if (unlikely(*ppos >= inode->i_sb->s_maxbytes))
 		return 0;
-	iov_iter_truncate(iter, inode->i_sb->s_maxbytes);
+	iov_iter_truncate(iter, inode->i_sb->s_maxbytes - *ppos);
 
 	index = *ppos >> PAGE_SHIFT;
 	prev_index = ra->prev_pos >> PAGE_SHIFT;
-- 
2.17.1
