Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE706B0032
	for <linux-mm@kvack.org>; Sat,  7 Feb 2015 21:55:16 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id l18so4562824wgh.13
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 18:55:15 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id vs8si671064wjc.119.2015.02.07.18.55.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Feb 2015 18:55:14 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so20476055wgh.6
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 18:55:13 -0800 (PST)
From: Grazvydas Ignotas <notasas@gmail.com>
Subject: [PATCH] mm: actually remap enough memory
Date: Sun,  8 Feb 2015 04:55:12 +0200
Message-Id: <1423364112-15487-1-git-send-email-notasas@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Grazvydas Ignotas <notasas@gmail.com>

For whatever reason, generic_access_phys() only remaps one page, but
actually allows to access arbitrary size. It's quite easy to trigger
large reads, like printing out large structure with gdb, which leads to
a crash. Fix it by remapping correct size.

Fixes: 28b2ee20c7cb ("access_process_vm device memory infrastructure")
Cc: stable@vger.kernel.org
Signed-off-by: Grazvydas Ignotas <notasas@gmail.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index cd62019..a53df67 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3829,7 +3829,7 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 	if (follow_phys(vma, addr, write, &prot, &phys_addr))
 		return -EINVAL;
 
-	maddr = ioremap_prot(phys_addr, PAGE_SIZE, prot);
+	maddr = ioremap_prot(phys_addr, PAGE_ALIGN(len + offset), prot);
 	if (write)
 		memcpy_toio(maddr + offset, buf, len);
 	else
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
