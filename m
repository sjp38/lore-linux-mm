Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E760E6B0033
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 16:22:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so2462972pgo.2
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 13:22:32 -0700 (PDT)
Received: from out4433.biz.mail.alibaba.com (out4433.biz.mail.alibaba.com. [47.88.44.33])
        by mx.google.com with ESMTPS id 79si1574148pgg.602.2017.10.06.13.22.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 13:22:31 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [RFC PATCH] mm: shm: round up tmpfs size to huge page size when huge=always
Date: Sat, 07 Oct 2017 04:22:10 +0800
Message-Id: <1507321330-22525-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

When passing "huge=always" option for mounting tmpfs, THP is supposed to
be allocated all the time when it can fit, but when the available space is
smaller than the size of THP (2MB on x86), shmem fault handler still tries
to allocate huge page every time, then fallback to regular 4K page
allocation, i.e.:

	# mount -t tmpfs -o huge,size=3000k tmpfs /tmp
	# dd if=/dev/zero of=/tmp/test bs=1k count=2048
	# dd if=/dev/zero of=/tmp/test1 bs=1k count=2048

The last dd command will handle 952 times page fault handler, then exit
with -ENOSPC.

Rounding up tmpfs size to THP size in order to use THP with "always"
more efficiently. And, it will not wast too much memory (just allocate
511 extra pages in worst case).

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/shmem.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/shmem.c b/mm/shmem.c
index 07a1d22..b2b595d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3567,6 +3567,11 @@ static int shmem_parse_options(char *options, struct shmem_sb_info *sbinfo,
 		}
 	}
 	sbinfo->mpol = mpol;
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+	/* Round up tmpfs size to huge page size */
+	if (sbinfo->max_blocks && sbinfo->huge == SHMEM_HUGE_ALWAYS)
+		sbinfo->max_blocks = round_up(sbinf->max_blocks, HPAGE_PMD_NR);
+#endif
 	return 0;
 
 bad_val:
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
