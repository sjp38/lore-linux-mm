Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 95BCB6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 08:13:25 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3590603eei.14
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:13:24 -0700 (PDT)
Received: from mail-ee0-x22f.google.com (mail-ee0-x22f.google.com [2a00:1450:4013:c00::22f])
        by mx.google.com with ESMTPS id x41si6370286eea.18.2014.05.23.05.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 05:13:24 -0700 (PDT)
Received: by mail-ee0-f47.google.com with SMTP id c13so3536257eek.6
        for <linux-mm@kvack.org>; Fri, 23 May 2014 05:13:23 -0700 (PDT)
From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH] mm/madvise: fix WILLNEED on SHM/ANON to actually do something
Date: Fri, 23 May 2014 14:12:15 +0200
Message-Id: <1400847135-22291-1-git-send-email-dh.herrmann@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, Vladimir Cernov <gg.kaspersky@gmail.com>, linux-mm@kvack.org, David Herrmann <dh.herrmann@gmail.com>

Currently, madvise(MADV_WILLNEED) on shmem with swap enabled is a no-op.
Problem is, we use find_get_page() to lookup shmem pages in the given
range. However, what we're actually interested in is swapped-out pages.
Therefore, our current code is a no-op:
    page = find_get_page(mapping, index);
    if (!radix_tree_exceptional_entry(page))
        bail-out;

find_get_page() never returns exceptional entries. Fix this by using
find_get_entry(). This was probably meant to be used right from the
beginning.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 539eeb9..a402f8f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -195,7 +195,7 @@ static void force_shm_swapin_readahead(struct vm_area_struct *vma,
 	for (; start < end; start += PAGE_SIZE) {
 		index = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
-		page = find_get_page(mapping, index);
+		page = find_get_entry(mapping, index);
 		if (!radix_tree_exceptional_entry(page)) {
 			if (page)
 				page_cache_release(page);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
