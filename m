Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC4A6B0261
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 08:42:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so20273528wmz.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 05:42:44 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id 131si2873441wma.114.2016.08.09.05.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 05:42:43 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] thp: move shmem_huge_enabled() outside of SYSFS ifdef
Date: Tue,  9 Aug 2016 14:36:02 +0200
Message-Id: <20160809123638.1357593-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The newly introduced shmem_huge_enabled() function has two definitions,
but neither of them is visible if CONFIG_SYSFS is disabled, leading
to a build error:

mm/khugepaged.o: In function `khugepaged':
khugepaged.c:(.text.khugepaged+0x3ca): undefined reference to `shmem_huge_enabled'

This changes the #ifdef guards around the definition to match those that
are used in the header file.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: e496cf3d7821 ("thp: introduce CONFIG_TRANSPARENT_HUGE_PAGECACHE")
---
 mm/shmem.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 7f7748a0f9e1..fd8b2b5741b1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -3975,7 +3975,9 @@ static ssize_t shmem_enabled_store(struct kobject *kobj,
 
 struct kobj_attribute shmem_enabled_attr =
 	__ATTR(shmem_enabled, 0644, shmem_enabled_show, shmem_enabled_store);
+#endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE && CONFIG_SYSFS */
 
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
 bool shmem_huge_enabled(struct vm_area_struct *vma)
 {
 	struct inode *inode = file_inode(vma->vm_file);
@@ -4006,7 +4008,7 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
 			return false;
 	}
 }
-#endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE && CONFIG_SYSFS */
+#endif /* CONFIG_TRANSPARENT_HUGE_PAGECACHE */
 
 #else /* !CONFIG_SHMEM */
 
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
