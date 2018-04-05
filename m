Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58FE76B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 17:03:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id v187so10116250qka.5
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 14:03:52 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p10si9933533qte.205.2018.04.05.14.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 14:03:51 -0700 (PDT)
Date: Fri, 6 Apr 2018 00:03:50 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 2/3] gup: return -EFAULT on access_ok failure
Message-ID: <1522962072-182137-4-git-send-email-mst@redhat.com>
References: <1522962072-182137-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522962072-182137-1-git-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>, stable@vger.kernel.org, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm@kvack.org

get_user_pages_fast is supposed to be a faster drop-in equivalent of
get_user_pages. As such, callers expect it to return a negative return
code when passed an invalid address, and never expect it to
return 0 when passed a positive number of pages, since
its documentation says:

 * Returns number of pages pinned. This may be fewer than the number
 * requested. If nr_pages is 0 or negative, returns 0. If no pages
 * were pinned, returns -errno.

When get_user_pages_fast fall back on get_user_pages this is exactly
what happens.  Unfortunately the implementation is inconsistent: it returns 0 if
passed a kernel address, confusing callers: for example, the following
is pretty common but does not appear to do the right thing with a kernel
address:

        ret = get_user_pages_fast(addr, 1, writeable, &page);
        if (ret < 0)
                return ret;

Change get_user_pages_fast to return -EFAULT when supplied a
kernel address to make it match expectations.

All caller have been audited for consistency with the documented
semantics.

Lightly tested.

Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jonathan Corbet <corbet@lwn.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Thorsten Leemhuis <regressions@leemhuis.info>
Cc: stable@vger.kernel.org
Fixes: 5b65c4677a57 ("mm, x86/mm: Fix performance regression in get_user_pages_fast()")
Reported-by: syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/gup.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 6afae32..8f3a064 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1806,9 +1806,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	if (nr_pages <= 0)
+		return 0;
+
 	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
 					(void __user *)start, len)))
-		return 0;
+		return -EFAULT;
 
 	if (gup_fast_permitted(start, nr_pages, write)) {
 		local_irq_disable();
-- 
MST
