Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id C47DA6B025E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 04:57:48 -0400 (EDT)
Received: by mail-lf0-f50.google.com with SMTP id c62so54646436lfc.1
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 01:57:48 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id m206si4796011lfd.84.2016.03.31.01.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 01:57:47 -0700 (PDT)
Subject: [PATCH] mm/rmap: replace BUG_ON(anon_vma->degree) with VM_WARN_ON
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 31 Mar 2016 11:57:10 +0300
Message-ID: <145941463036.29562.15629573511013443187.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This check effectively catches anon vma hierarchy inconsistence and some
vma corruptions. It was effective for catching corner cases in anon vma
reusing logic. For now this code seems stable so check could be hidden
under CONFIG_DEBUG_VM and replaced with WARN because it's not so fatal.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Suggested-by: Vasily Averin <vvs@virtuozzo.com>
---
 mm/rmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 395e314b7996..a8d52d3f40ed 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -409,7 +409,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
 		struct anon_vma *anon_vma = avc->anon_vma;
 
-		BUG_ON(anon_vma->degree);
+		VM_WARN_ON(anon_vma->degree);
 		put_anon_vma(anon_vma);
 
 		list_del(&avc->same_vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
