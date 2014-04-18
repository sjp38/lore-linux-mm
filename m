Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id D06F46B005A
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 10:50:52 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so1682403eek.6
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 07:50:52 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o46si40610989eem.69.2014.04.18.07.50.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 07:50:51 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/16] mm: filemap: Prefetch page->flags if !PageUptodate
Date: Fri, 18 Apr 2014 15:50:43 +0100
Message-Id: <1397832643-14275-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1397832643-14275-1-git-send-email-mgorman@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>

The write_end handler is likely to call SetPageUptodate which is an atomic
operation so prefetch the line.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/filemap.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/filemap.c b/mm/filemap.c
index c28f69c..40713da 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2551,6 +2551,9 @@ again:
 		copied = iov_iter_copy_from_user_atomic(page, i, offset, bytes);
 		flush_dcache_page(page);
 
+		if (!PageUptodate(page))
+			prefetchw(&page->flags);
+
 		status = a_ops->write_end(file, mapping, pos, bytes, copied,
 						page, fsdata);
 		if (unlikely(status < 0))
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
