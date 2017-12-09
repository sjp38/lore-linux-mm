Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2466D6B0280
	for <linux-mm@kvack.org>; Sat,  9 Dec 2017 02:10:13 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id h12so7101129wre.12
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 23:10:13 -0800 (PST)
Received: from smtp.smtpout.orange.fr (smtp02.smtpout.orange.fr. [80.12.242.124])
        by mx.google.com with ESMTPS id 19si2261993wmx.6.2017.12.08.23.10.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 23:10:11 -0800 (PST)
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mm: Release a semaphore in 'get_vaddr_frames()'
Date: Sat,  9 Dec 2017 08:09:41 +0100
Message-Id: <20171209070941.31828-1-christophe.jaillet@wanadoo.fr>
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

The wording of the commit entry and log description could be improved
but I didn't find something better.
---
 mm/frame_vector.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index 297c7238f7d4..e0c5e659fa82 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -62,8 +62,10 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
 	 * get_user_pages_longterm() and disallow it for filesystem-dax
 	 * mappings.
 	 */
-	if (vma_is_fsdax(vma))
+	if (vma_is_fsdax(vma)) {
+		up_read(&mm->mmap_sem);
 		return -EOPNOTSUPP;
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
