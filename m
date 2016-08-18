Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13B1F8308B
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 08:07:06 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id x131so59371251ite.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 05:07:06 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id y129si897023oie.222.2016.08.18.05.07.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Aug 2016 05:07:05 -0700 (PDT)
From: Xie Yisheng <xieyisheng1@huawei.com>
Subject: [RFC PATCH] arm64/hugetlb enable gigantic hugepage
Date: Thu, 18 Aug 2016 20:05:29 +0800
Message-ID: <1471521929-9207-1-git-send-email-xieyisheng1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: guohanjun@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

As we know, arm64 also support gigantic hugepage eg. 1G.
So I try to use this function by adding hugepagesz=1G
in kernel parameters, with CONFIG_CMA=y.
However, when:
echo xx > /sys/kernel/mm/hugepages/hugepages-1048576kB/
          nr_hugepages
it failed with the info:
-bash: echo: write error: Invalid argument

This patch make gigantic hugepage can be used on arm64,
when CONFIG_CMA=y or other related configs is enable.

Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>
---
 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 87e11d8..b4d8048 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1022,7 +1022,8 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#if (defined(CONFIG_X86_64) || defined(CONFIG_S390)) && \
+#if (defined(CONFIG_X86_64) || defined(CONFIG_S390) || \
+	defined(CONFIG_ARM64)) && \
 	((defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || \
 	defined(CONFIG_CMA))
 static void destroy_compound_gigantic_page(struct page *page,
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
