Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 26F016B0069
	for <linux-mm@kvack.org>; Sun,  5 Oct 2014 04:58:52 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id l4so2886686lbv.10
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 01:58:51 -0700 (PDT)
Received: from metis.ext.pengutronix.de (metis.ext.pengutronix.de. [2001:6f8:1178:4:290:27ff:fe1d:cc33])
        by mx.google.com with ESMTPS id e7si18686402lag.100.2014.10.05.01.58.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 05 Oct 2014 01:58:50 -0700 (PDT)
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH] vfs: fix compilation for no-MMU configurations
Date: Sun,  5 Oct 2014 10:58:36 +0200
Message-Id: <1412499516-12839-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>
Cc: kernel@pengutronix.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

Commit ac4dd23b76ce introduced a new function pagecache_isize_extended.
In <linux/mm.h> it was declared static inline and empty for no-MMU and
defined unconditionally in mm/truncate.c which results a compiler
error:

	  CC      mm/truncate.o
	mm/truncate.c:751:6: error: redefinition of 'pagecache_isize_extended'
	 void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
	      ^
	In file included from mm/truncate.c:13:0:
	include/linux/mm.h:1161:91: note: previous definition of 'pagecache_isize_extended' was here
	 static inline void pagecache_isize_extended(struct inode *inode, loff_t from,
												   ^
	scripts/Makefile.build:257: recipe for target 'mm/truncate.o' failed

(tested with ARCH=arm efm32_defconfig).

Fixes: ac4dd23b76ce ("vfs: fix data corruption when blocksize < pagesize for mmaped data")
Signed-off-by: Uwe Kleine-KA?nig <u.kleine-koenig@pengutronix.de>
---
Hello,

the bad commit sits in

git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git#dev

and is included in next.

Best regards
Uwe

 mm/truncate.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index 261eaf6e5a19..0d9c4ebd5ecc 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -729,6 +729,7 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
 }
 EXPORT_SYMBOL(truncate_setsize);
 
+#ifdef CONFIG_MMU
 /**
  * pagecache_isize_extended - update pagecache after extension of i_size
  * @inode:	inode for which i_size was extended
@@ -780,6 +781,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	page_cache_release(page);
 }
 EXPORT_SYMBOL(pagecache_isize_extended);
+#endif
 
 /**
  * truncate_pagecache_range - unmap and remove pagecache that is hole-punched
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
