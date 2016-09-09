Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9425F6B0253
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 18:25:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so215414425pfb.3
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 15:25:34 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id n28si5910260pfa.263.2016.09.09.15.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 15:25:31 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 1/2] shmem: fix tmpfs to handle the huge= option properly
Date: Fri,  9 Sep 2016 16:24:22 -0600
Message-Id: <1473459863-11287-2-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
References: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, toshi.kani@hpe.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

shmem_get_unmapped_area() checks SHMEM_SB(sb)->huge incorrectly,
which leads to a reversed effect of "huge=" mount option.

Fix the check in shmem_get_unmapped_area().

Note, the default value of SHMEM_SB(sb)->huge remains as
SHMEM_HUGE_NEVER.  User will need to specify "huge=" option to
enable huge page mappings.

Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index fd8b2b5..aec5b49 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1980,7 +1980,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
 				return addr;
 			sb = shm_mnt->mnt_sb;
 		}
-		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
+		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
 			return addr;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
