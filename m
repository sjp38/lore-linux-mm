Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 43B396B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 12:26:58 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so9933461lbb.0
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 09:26:57 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id e20si31405956lfi.75.2015.11.17.09.26.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 09:26:56 -0800 (PST)
Received: by lfu94 with SMTP id 94so1181611lfu.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 09:26:56 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH] mm/mmap.c: remove incorrect MAP_FIXED flag comparison from mmap_region
Date: Tue, 17 Nov 2015 18:26:38 +0100
Message-Id: <1447781198-5496-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <20151117161928.GA9611@redhat.com>
References: <20151117161928.GA9611@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: oleg@redhat.com, akpm@linux-foundation.org, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The following flag comparison in mmap_region is not fully correct:

if (!(vm_flags & MAP_FIXED))

The vm_flags should not be compared with MAP_FIXED (0x10). It is a bit
confusing. This condition is almost always true since VM_MAYREAD (0x10)
flag is almost always set by default. This patch removes this condition.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
 mm/mmap.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a6..02422ea 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1547,13 +1547,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	if (!may_expand_vm(mm, len >> PAGE_SHIFT)) {
 		unsigned long nr_pages;
 
-		/*
-		 * MAP_FIXED may remove pages of mappings that intersects with
-		 * requested mapping. Account for the pages it would unmap.
-		 */
-		if (!(vm_flags & MAP_FIXED))
-			return -ENOMEM;
-
 		nr_pages = count_vma_pages_range(mm, addr, addr + len);
 
 		if (!may_expand_vm(mm, (len >> PAGE_SHIFT) - nr_pages))
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
