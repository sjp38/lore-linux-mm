Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4916B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:01:29 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so206790pab.35
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:01:28 -0700 (PDT)
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
        by mx.google.com with ESMTPS id dg5si1648250pbc.480.2014.05.14.16.01.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 16:01:28 -0700 (PDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so215736pbb.3
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:01:28 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] x86,vdso: Fix an OOPS accessing the hpet mapping w/o an hpet
Date: Wed, 14 May 2014 16:01:23 -0700
Message-Id: <c13c62bd41e75eb9f414b541dfd2adada009c7c2.1400107790.git.luto@amacapital.net>
In-Reply-To: <e1640272803e7711d9a43d9454dbdae57ba22eed.1400108299.git.luto@amacapital.net>
References: <e1640272803e7711d9a43d9454dbdae57ba22eed.1400108299.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>

The access should fail, but it shouldn't oops.

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

This applies to tip/x86/vdso and should be applied to unbreak Trinity
on linux-next.

 arch/x86/vdso/vma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index e915eae..d02131e 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -84,6 +84,8 @@ static unsigned long vdso_addr(unsigned long start, unsigned len)
 	return addr;
 }
 
+static struct page *no_pages[] = {NULL};
+
 static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 {
 	struct mm_struct *mm = current->mm;
@@ -125,7 +127,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 				       addr + image->size,
 				       image->sym_end_mapping - image->size,
 				       VM_READ,
-				       NULL);
+				       no_pages);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
