Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A92A78E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 22:09:17 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id a12so8429839iok.8
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 19:09:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i136sor26942447iti.2.2019.01.09.19.09.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 Jan 2019 19:09:16 -0800 (PST)
From: Yu Zhao <yuzhao@google.com>
Subject: [PATCH] mm/shmem: make find_get_pages_range() work for huge page
Date: Wed,  9 Jan 2019 20:08:38 -0700
Message-Id: <20190110030838.84446-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, Dave Chinner <david@fromorbit.com>, "Darrick J . Wong" <darrick.wong@oracle.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yu Zhao <yuzhao@google.com>

find_get_pages_range() and find_get_pages_range_tag() already
correctly increment reference count on head when seeing compound
page, but they may still use page index from tail. Page index
from tail is always zero, so these functions don't work on huge
shmem. This hasn't been a problem because, AFAIK, nobody calls
these functions on (huge) shmem. Fix them anyway just in case.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/filemap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 81adec8ee02c..cf5fd773314a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1704,7 +1704,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*start = page->index + 1;
+			*start = xas.xa_index + 1;
 			goto out;
 		}
 		continue;
@@ -1850,7 +1850,7 @@ unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*index = page->index + 1;
+			*index = xas.xa_index + 1;
 			goto out;
 		}
 		continue;
-- 
2.20.1.97.g81188d93c3-goog
