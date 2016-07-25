Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C55046B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 10:39:43 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w207so383449731oiw.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 07:39:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g17si10723649ita.7.2016.07.25.07.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 07:39:43 -0700 (PDT)
From: Kyle Walker <kwalker@redhat.com>
Subject: [PATCH] mm: Move readahead limit outside of readahead, and advisory syscalls
Date: Mon, 25 Jul 2016 10:39:25 -0400
Message-Id: <1469457565-22693-1-git-send-email-kwalker@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Kyle Walker <kwalker@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Geliang Tang <geliangtang@163.com>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <klamm@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Java workloads using the MappedByteBuffer library result in the fadvise()
and madvise() syscalls being used extensively. Following recent readahead
limiting alterations, such as 600e19af ("mm: use only per-device readahead
limit") and 6d2be915 ("mm/readahead.c: fix readahead failure for
memoryless NUMA nodes and limit readahead pages"), application performance
suffers in instances where small readahead is configured.

By moving this limit outside of the syscall codepaths, the syscalls are
able to advise an inordinately large amount of readahead when desired.
With a cap being imposed based on the half of NR_INACTIVE_FILE and
NR_FREE_PAGES. In essence, allowing performance tuning efforts to define a
small readahead limit, but then benefiting from large sequential readahead
values selectively.

Signed-off-by: Kyle Walker <kwalker@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Geliang Tang <geliangtang@163.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Roman Gushchin <klamm@yandex-team.ru>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
---
 mm/readahead.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 65ec288..6f8bb44 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -211,7 +211,9 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
 		return -EINVAL;
 
-	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
+	nr_to_read = min(nr_to_read, (global_page_state(NR_INACTIVE_FILE) +
+				     (global_page_state(NR_FREE_PAGES)) / 2));
+
 	while (nr_to_read) {
 		int err;
 
@@ -484,6 +486,7 @@ void page_cache_sync_readahead(struct address_space *mapping,
 
 	/* be dumb */
 	if (filp && (filp->f_mode & FMODE_RANDOM)) {
+		req_size = min(req_size, inode_to_bdi(mapping->host)->ra_pages);
 		force_page_cache_readahead(mapping, filp, offset, req_size);
 		return;
 	}
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
