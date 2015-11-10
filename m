Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id D278B6B0255
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:33:48 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so210581575pac.3
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:48 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ya7si5203248pbc.121.2015.11.10.05.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 05:33:48 -0800 (PST)
Received: by pasz6 with SMTP id z6so242003765pas.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 05:33:48 -0800 (PST)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH 2/3] tools/vm/page-types: suppress gcc warnings
Date: Tue, 10 Nov 2015 22:32:05 +0900
Message-Id: <1447162326-30626-3-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Define 'end' and 'first' as volatile to suppress
gcc warnings:

page-types.c:854:13: warning: variable 'end' might be
   clobbered by 'longjmp' or 'vfork' [-Wclobbered]
page-types.c:858:6: warning: variable 'first' might be
   clobbered by 'longjmp' or 'vfork' [-Wclobbered]

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 tools/vm/page-types.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index bcf5ec7..0651cd5 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -851,11 +851,12 @@ static void walk_file(const char *name, const struct stat *st)
 	uint8_t vec[PAGEMAP_BATCH];
 	uint64_t buf[PAGEMAP_BATCH], flags;
 	unsigned long nr_pages, pfn, i;
-	off_t off, end = st->st_size;
+	off_t off;
 	int fd;
 	ssize_t len;
 	void *ptr;
-	int first = 1;
+	volatile int first = 1;
+	volatile off_t end = st->st_size;
 
 	fd = checked_open(name, O_RDONLY|O_NOATIME|O_NOFOLLOW);
 
-- 
2.6.2.280.g74301d6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
