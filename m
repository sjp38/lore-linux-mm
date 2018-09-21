Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E26448E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 05:50:52 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id h4-v6so5932040pls.17
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 02:50:52 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id cf16-v6si28489724plb.254.2018.09.21.02.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 02:50:51 -0700 (PDT)
From: YueHaibing <yuehaibing@huawei.com>
Subject: [PATCH -next] mm/gup_benchmark: Fix unsigned comparison to zero in __gup_benchmark_ioctl
Date: Fri, 21 Sep 2018 17:50:15 +0800
Message-ID: <20180921095015.26088-1-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mst@redhat.com, keescook@chromium.org, kirill.shutemov@linux.intel.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, YueHaibing <yuehaibing@huawei.com>

get_user_pages_fast will return negative value if no pages were pinned,
then be converted to a unsigned, which is compared to zero, giving
the wrong result.

Fixes: 09e35a4a1ca8 ("mm/gup_benchmark: handle gup failures")
Signed-off-by: YueHaibing <yuehaibing@huawei.com>
---
 mm/gup_benchmark.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 6a47370..7405c9d8 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -19,7 +19,8 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 		struct gup_benchmark *gup)
 {
 	ktime_t start_time, end_time;
-	unsigned long i, nr, nr_pages, addr, next;
+	unsigned long i, nr_pages, addr, next;
+	int nr;
 	struct page **pages;
 
 	nr_pages = gup->size / PAGE_SIZE;
-- 
2.7.0
