Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 217176B0008
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 13:00:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c15-v6so5093720pls.15
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 10:00:22 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id v6-v6si29516489plo.134.2018.11.01.10.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 10:00:21 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH v4] mm/page_owner: clamp read count to PAGE_SIZE
Date: Fri, 2 Nov 2018 01:00:07 +0800
Message-ID: <1541091607-27402-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com, Miles Chen <miles.chen@mediatek.com>, Michal Hocko <mhocko@kernel.org>

From: Miles Chen <miles.chen@mediatek.com>

The page owner read might allocate a large size of memory with
a large read count. Allocation fails can easily occur when doing
high order allocations.

Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
and avoid allocation fails due to high order allocation.

Change since v3:
  - remove the change in kvmalloc
  - keep kmalloc in page_owner.c

Change since v2:
  - improve kvmalloc, allow sub page allocations fallback to
    vmalloc when CONFIG_HIGHMEM=y

Change since v1:
  - use kvmalloc()
  - clamp buffer size to PAGE_SIZE

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 87bc0dfdb52b..b83f295e4eca 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
+	count = count > PAGE_SIZE ? PAGE_SIZE : count;
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
-- 
2.18.0
