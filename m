Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E64696B000D
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:44:55 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t11-v6so2660958iog.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:44:55 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b67-v6sor2090264ita.33.2018.06.27.14.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 14:44:55 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 27 Jun 2018 14:44:47 -0700
Message-Id: <20180627214447.260804-1-cannonmatthews@google.com>
Subject: [PATCH] mm: hugetlb: yield when prepping struct pages
From: Cannon Matthews <cannonmatthews@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, gthelen@google.com, Cannon Matthews <cannonmatthews@google.com>

When booting with very large numbers of gigantic (i.e. 1G) pages, the
operations in the loop of gather_bootmem_prealloc, and specifically
prep_compound_gigantic_page, takes a very long time, and can cause a
softlockup if enough pages are requested at boot.

For example booting with 3844 1G pages requires prepping
(set_compound_head, init the count) over 1 billion 4K tail pages, which
takes considerable time. This should also apply to reserving the same
amount of memory as 2M pages, as the same number of struct pages
are affected in either case.

Add a cond_resched() to the outer loop in gather_bootmem_prealloc() to
prevent this lockup.

Tested: Booted with softlockup_panic=1 hugepagesz=1G hugepages=3844 and
no softlockup is reported, and the hugepages are reported as
successfully setup.

Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
---
 mm/hugetlb.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a963f2034dfc..d38273c32d3b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2169,6 +2169,7 @@ static void __init gather_bootmem_prealloc(void)
 		 */
 		if (hstate_is_gigantic(h))
 			adjust_managed_page_count(page, 1 << h->order);
+		cond_resched();
 	}
 }
 
-- 
2.18.0.rc2.346.g013aa6912e-goog
