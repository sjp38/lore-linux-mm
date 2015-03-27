Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 261F96B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 04:37:37 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so17920130wib.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 01:37:36 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id dr2si2085249wid.108.2015.03.27.01.37.34
        for <linux-mm@kvack.org>;
        Fri, 27 Mar 2015 01:37:35 -0700 (PDT)
From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH] mm, trivial: Simplify flag check
Date: Fri, 27 Mar 2015 09:35:46 +0100
Message-Id: <1427445346-18858-1-git-send-email-bp@alien8.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: trivial@kernel.org
Cc: linux-mm@kvack.org

From: Borislav Petkov <bp@suse.de>

Flip the flag test so that it is the simplest. No functional change,
just a small readability improvement:

No code changed:

  # arch/x86/kernel/sys_x86_64.o:

   text    data     bss     dec     hex filename
   1551      24       0    1575     627 sys_x86_64.o.before
   1551      24       0    1575     627 sys_x86_64.o.after

md5:
   70708d1b1ad35cc891118a69dc1a63f9  sys_x86_64.o.before.asm
   70708d1b1ad35cc891118a69dc1a63f9  sys_x86_64.o.after.asm

Signed-off-by: Borislav Petkov <bp@suse.de>
---
 include/linux/mm.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a93928b90f..43e876e9e28b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1973,10 +1973,10 @@ extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info);
 static inline unsigned long
 vm_unmapped_area(struct vm_unmapped_area_info *info)
 {
-	if (!(info->flags & VM_UNMAPPED_AREA_TOPDOWN))
-		return unmapped_area(info);
-	else
+	if (info->flags & VM_UNMAPPED_AREA_TOPDOWN)
 		return unmapped_area_topdown(info);
+	else
+		return unmapped_area(info);
 }
 
 /* truncate.c */
-- 
2.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
