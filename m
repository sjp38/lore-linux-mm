Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE4096B0256
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 06:46:14 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so32192956pab.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 03:46:14 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bz4si11850980pbd.70.2015.09.26.03.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 03:46:14 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 2/5] fs: charge pipe buffers to memcg
Date: Sat, 26 Sep 2015 13:45:54 +0300
Message-ID: <94f055dc719129a26149b0f8b22af7c61a3fb4e6.1443262808.git.vdavydov@parallels.com>
In-Reply-To: <cover.1443262808.git.vdavydov@parallels.com>
References: <cover.1443262808.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Pipe buffers can be generated unrestrictedly by an unprivileged
userspace process, so they shouldn't go unaccounted.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 fs/pipe.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 8865f7963700..6880884b70b0 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -400,7 +400,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
 			int copied;
 
 			if (!page) {
-				page = alloc_page(GFP_HIGHUSER);
+				page = alloc_kmem_pages(GFP_HIGHUSER, 0);
 				if (unlikely(!page)) {
 					ret = ret ? : -ENOMEM;
 					break;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
