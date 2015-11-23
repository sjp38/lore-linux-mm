Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 876036B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 12:37:23 -0500 (EST)
Received: by lfs39 with SMTP id 39so112906735lfs.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 09:37:22 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id a199si9557310lfb.197.2015.11.23.09.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 09:37:21 -0800 (PST)
Received: by lffu14 with SMTP id u14so11024590lff.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 09:37:21 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v3] mm/mmap.c: remove incorrect MAP_FIXED flag comparison from mmap_region
Date: Mon, 23 Nov 2015 18:36:42 +0100
Message-Id: <1448300202-5004-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <20151123081946.GA21050@dhcp22.suse.cz>
References: <20151123081946.GA21050@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, oleg@redhat.com, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The following flag comparison in mmap_region makes no sense:

if (!(vm_flags & MAP_FIXED))
    return -ENOMEM;

The condition is always false and thus the above "return -ENOMEM" is never
executed. The vm_flags must not be compared with MAP_FIXED flag.
The vm_flags may only be compared with VM_* flags.
MAP_FIXED has the same value as VM_MAYREAD.
Hitting the rlimit is a slow path and find_vma_intersection should realize
that there is no overlapping VMA for !MAP_FIXED case pretty quickly.

Remove the code that makes no sense.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
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
