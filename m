Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 27ED76B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 11:42:35 -0500 (EST)
Received: by lfs39 with SMTP id 39so72700257lfs.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:42:34 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id q21si224143lfq.128.2015.11.20.08.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 08:42:33 -0800 (PST)
Received: by lfu94 with SMTP id 94so6670625lfu.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:42:33 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v2 2/2] mm/mmap.c: remove incorrect MAP_FIXED flag comparison from mmap_region
Date: Fri, 20 Nov 2015 17:42:14 +0100
Message-Id: <1448037734-4734-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <20151118162939.GA1842@home.local>
References: <20151118162939.GA1842@home.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The following flag comparison in mmap_region makes no sense:

if (!(vm_flags & MAP_FIXED))
    return -ENOMEM;

The condition is always false and thus the above "return -ENOMEM" is never
executed. The vm_flags must not be compared with MAP_FIXED flag.
The vm_flags may only be compared with VM_* flags.
MAP_FIXED has the same value as VM_MAYREAD.
It has no user visible effect.

Remove the code that makes no sense.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
I made a mistake in a changelog in a previous version of this patch.
I'm Sorry for the confusion.
This patch may be considered to be applied only in case the patch
"[PATCH v2 1/2] mm: fix incorrect behavior when process virtual
address space limit is exceeded"
is not going to be accepted.

 mm/mmap.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a6..42a8259 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1551,9 +1551,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 * MAP_FIXED may remove pages of mappings that intersects with
 		 * requested mapping. Account for the pages it would unmap.
 		 */
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
