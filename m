Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 470262806D2
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:44:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q26so35515379pfa.6
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 07:44:06 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d10si4454728pgc.168.2017.08.22.07.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Aug 2017 07:44:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, shmem: Fix handling /sys/kernel/mm/transparent_hugepage/shmem_enabled
Date: Tue, 22 Aug 2017 17:42:54 +0300
Message-Id: <20170822144254.66431-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable <stable@vger.kernel.org>

/sys/kernel/mm/transparent_hugepage/shmem_enabled controls if we want to
allocate huge pages when allocate pages for private in-kernel shmem mount.

Unfortunately, as Dan noticed, I've screwed it up and the only way to
make kernel allocate huge page for the mount is to use "force" there.
All other values will be effectively ignored.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 5a6e75f8110c ("shmem: prepare huge= mount option and sysfs knob")
Cc: stable <stable@vger.kernel.org> [4.8+]
---
 mm/shmem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 6540e5982444..fbcb3c96a186 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3967,7 +3967,7 @@ int __init shmem_init(void)
 	}
 
 #ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
-	if (has_transparent_hugepage() && shmem_huge < SHMEM_HUGE_DENY)
+	if (has_transparent_hugepage() && shmem_huge > SHMEM_HUGE_DENY)
 		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
 	else
 		shmem_huge = 0; /* just in case it was patched */
@@ -4028,7 +4028,7 @@ static ssize_t shmem_enabled_store(struct kobject *kobj,
 		return -EINVAL;
 
 	shmem_huge = huge;
-	if (shmem_huge < SHMEM_HUGE_DENY)
+	if (shmem_huge > SHMEM_HUGE_DENY)
 		SHMEM_SB(shm_mnt->mnt_sb)->huge = shmem_huge;
 	return count;
 }
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
