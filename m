Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5326B0273
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:46:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so34044392wmz.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:46:34 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id gy3si30992652wjb.244.2016.06.13.12.46.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:46:32 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id n184so17318483wmn.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:46:32 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 07/18] limits: track RLIMIT_FSIZE actual max
Date: Mon, 13 Jun 2016 22:44:14 +0300
Message-Id: <1465847065-3577-8-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Junichi Nomura <j-nomura@ce.jp.nec.com>, Matthew Wilcox <willy@linux.intel.com>, "open list:FILESYSTEMS VFS and infrastructure" <linux-fsdevel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Track maximum file size, presented in /proc/self/limits.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 fs/attr.c    | 2 ++
 mm/filemap.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/attr.c b/fs/attr.c
index 25b24d0..1b620f7 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -116,6 +116,8 @@ int inode_newsize_ok(const struct inode *inode, loff_t offset)
 			return -ETXTBSY;
 	}
 
+	bump_rlimit(RLIMIT_FSIZE, offset);
+
 	return 0;
 out_sig:
 	send_sig(SIGXFSZ, current, 0);
diff --git a/mm/filemap.c b/mm/filemap.c
index 00ae878..1fa9864 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2447,6 +2447,7 @@ inline ssize_t generic_write_checks(struct kiocb *iocb, struct iov_iter *from)
 			send_sig(SIGXFSZ, current, 0);
 			return -EFBIG;
 		}
+		bump_rlimit(RLIMIT_FSIZE, iocb->ki_pos);
 		iov_iter_truncate(from, limit - (unsigned long)pos);
 	}
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
