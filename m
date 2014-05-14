Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA566B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:50:04 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so144524eek.32
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:50:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g41si1026974eep.276.2014.05.14.16.50.01
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 16:50:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak by race between poison and unpoison
Date: Wed, 14 May 2014 19:49:41 -0400
Message-Id: <5374012a.c1d80e0a.2cba.4e77SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140514151037.37592c3bb31f51fdad8c5a42@linux-foundation.org>
References: <1400080891-5145-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20140514151037.37592c3bb31f51fdad8c5a42@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 14, 2014 at 03:10:37PM -0700, Andrew Morton wrote:
...
> Looking at the surrounding code...
> 
> 	/*
> 	 * Lock the page and wait for writeback to finish.
> 	 * It's very difficult to mess with pages currently under IO
> 	 * and in many cases impossible, so we just avoid it here.
> 	 */
> 	lock_page(hpage);
> 
> 
> lock_page() doesn't wait for writeback to finish -
> wait_on_page_writeback() does that.  Either the code or the comment
> could do with fixing.

OK, here is the patch to move the comment.

---
Subject: [PATCH] mm/memory-failure.c: move comment

The comment about pages under writeback is far from the relevant code,
so let's move it to the right place.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 93a08bd78c78..e3154d99b87f 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1132,11 +1132,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		}
 	}
 
-	/*
-	 * Lock the page and wait for writeback to finish.
-	 * It's very difficult to mess with pages currently under IO
-	 * and in many cases impossible, so we just avoid it here.
-	 */
 	lock_page(hpage);
 
 	/*
@@ -1186,6 +1181,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	if (PageHuge(p))
 		set_page_hwpoison_huge_page(hpage);
 
+	/*
+	 * It's very difficult to mess with pages currently under IO
+	 * and in many cases impossible, so we just avoid it here.
+	 */
 	wait_on_page_writeback(p);
 
 	/*
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
