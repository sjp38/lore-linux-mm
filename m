Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id DCCD828024B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 23:21:59 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id wk8so236199022pab.3
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:21:59 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id dc7si11003058pad.277.2016.09.23.20.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 20:21:58 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id s13so13265936pfd.2
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 20:21:58 -0700 (PDT)
Date: Fri, 23 Sep 2016 20:21:56 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/3] shmem: fix tmpfs to handle the huge= option properly
In-Reply-To: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1609232017410.2495@eggly.anvils>
References: <alpine.LSU.2.11.1609232014130.2495@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hpe.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

shmem_get_unmapped_area() checks SHMEM_SB(sb)->huge incorrectly,
which leads to a reversed effect of "huge=" mount option.

Fix the check in shmem_get_unmapped_area().

Note, the default value of SHMEM_SB(sb)->huge remains as
SHMEM_HUGE_NEVER.  User will need to specify "huge=" option to
enable huge page mappings.

Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 4.8-rc7/mm/shmem.c	2016-08-14 20:17:02.388843463 -0700
+++ linux/mm/shmem.c	2016-09-22 19:41:29.057848626 -0700
@@ -1980,7 +1980,7 @@ unsigned long shmem_get_unmapped_area(st
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
