Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD276B0253
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 16:10:44 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l33so11119812wrl.5
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 13:10:44 -0800 (PST)
Received: from smtp.smtpout.orange.fr (smtp12.smtpout.orange.fr. [80.12.242.134])
        by mx.google.com with ESMTPS id j6si10957557wrh.315.2017.12.11.13.10.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 13:10:43 -0800 (PST)
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH v2] mm: Release a semaphore in 'get_vaddr_frames()'
Date: Mon, 11 Dec 2017 22:10:09 +0100
Message-Id: <20171211211009.4971-1-christophe.jaillet@wanadoo.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.j.williams@intel.com, akpm@linux-foundation.org, borntraeger@de.ibm.com, mhocko@suse.com, dsterba@suse.com, gregkh@linuxfoundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

A semaphore is acquired before this check, so we must release it before
leaving.

Fixes: b7f0554a56f2 ("mm: fail get_vaddr_frames() for filesystem-dax mappings")
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
-- Untested --

v1 -> v2: 'goto out' instead of duplicating code
---
 mm/frame_vector.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 297c7238f7d4..c64dca6e27c2 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -62,8 +62,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	 * get_user_pages_longterm() and disallow it for filesystem-dax
 	 * mappings.
 	 */
-	if (vma_is_fsdax(vma))
-		return -EOPNOTSUPP;
+	if (vma_is_fsdax(vma)) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
 
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
