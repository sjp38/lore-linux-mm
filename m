Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE0C6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 15:53:35 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 14so20847045pgg.4
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 12:53:35 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id i23si11110301pll.72.2017.02.09.12.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 12:53:34 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 4/4] mm,hugetlb: compute page_size_log properly
Date: Thu,  9 Feb 2017 12:53:02 -0800
Message-Id: <1486673582-6979-5-git-send-email-dave@stgolabs.net>
In-Reply-To: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
References: <1486673582-6979-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: manfred@colorfullife.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Davidlohr Bueso <dbueso@suse.de>

The SHM_HUGE_* stuff  was introduced in:

   42d7395feb5 (mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB)

It unnecessarily adds another layer, specific to sysv shm, without
anything special about it: the macros are identical to the MAP_HUGE_*
stuff, which in turn does correctly describe the hugepage subsystem.

One example of the problems with extra layers what this patch fixes:
mmap_pgoff() should never be using SHM_HUGE_* logic. It is obviously
harmless but it would still be grand to get rid of it -- although
now in the manpages I don't see that happening.

Cc: linux-mm@kvack.org
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 499b988b1639..40b29aca18c1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1479,7 +1479,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		struct user_struct *user = NULL;
 		struct hstate *hs;
 
-		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & SHM_HUGE_MASK);
+		hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
 		if (!hs)
 			return -EINVAL;
 
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
