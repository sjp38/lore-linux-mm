Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9643E6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 17:03:51 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id n204-v6so15271234yba.1
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 14:03:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m34si3569301qtc.121.2018.04.05.14.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 14:03:50 -0700 (PDT)
Date: Fri, 6 Apr 2018 00:03:49 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 1/3] mm/gup_benchmark: handle gup failures
Message-ID: <1522962072-182137-3-git-send-email-mst@redhat.com>
References: <1522962072-182137-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522962072-182137-1-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, stable@vger.kernel.org, linux-mm@kvack.org

__gup_benchmark_ioctl does not handle the case where
get_user_pages_fast fails:

- a negative return code will cause a buffer overrun
- returning with partial success will cause use of
  uninitialized memory.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Thorsten Leemhuis <regressions@leemhuis.info>
Cc: stable@vger.kernel.org
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/gup_benchmark.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 5c8e2ab..d743035 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -23,7 +23,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	struct page **pages;
 
 	nr_pages = gup->size / PAGE_SIZE;
-	pages = kvmalloc(sizeof(void *) * nr_pages, GFP_KERNEL);
+	pages = kvzalloc(sizeof(void *) * nr_pages, GFP_KERNEL);
 	if (!pages)
 		return -ENOMEM;
 
@@ -41,7 +41,8 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 		}
 
 		nr = get_user_pages_fast(addr, nr, gup->flags & 1, pages + i);
-		i += nr;
+		if (nr > 0)
+			i += nr;
 	}
 	end_time = ktime_get();
 
-- 
MST
