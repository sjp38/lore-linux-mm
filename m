Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 161D56B0261
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 04:27:19 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so76553354wjy.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:19 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id d196si15473863wmd.9.2017.02.01.01.27.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 01:27:17 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id u63so4480292wmu.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:27:17 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/3] vmalloc: back of when the current is killed
Date: Wed,  1 Feb 2017 10:27:06 +0100
Message-Id: <20170201092706.9966-4-mhocko@kernel.org>
In-Reply-To: <20170201092706.9966-1-mhocko@kernel.org>
References: <20170201092706.9966-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__vmalloc_area_node allocates pages to cover the requested vmalloc size.
This can be a lot of memory. If the current task is killed by the OOM
killer, and thus has an unlimited access to memory reserves, it can
consume all the memory theoretically. Fix this by checking for
fatal_signal_pending and back off early.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmalloc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d89034a393f2..011b446f8758 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1642,6 +1642,11 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
+		if (fatal_signal_pending(current)) {
+			area->nr_pages = i;
+			goto fail;
+		}
+
 		if (node == NUMA_NO_NODE)
 			page = alloc_page(alloc_mask);
 		else
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
