Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB226B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:46:56 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so257444pab.0
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:46:56 -0700 (PDT)
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
        by mx.google.com with ESMTPS id he5si1720073pbb.27.2014.05.14.16.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 16:46:55 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so249791pad.23
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:46:55 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH v2 -next] x86,vdso: Fix an OOPS accessing the hpet mapping w/o an hpet
Date: Wed, 14 May 2014 16:46:50 -0700
Message-Id: <c8b0a9a0b8d011a8b273cbb2de88d37190ed2751.1400111179.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Stefani Seibold <stefani@seibold.net>

The oops can be triggered in qemu using -no-hpet (but not nohpet) by
reading a couple of pages past the end of the vdso text.  This
should send SIGBUS instead of OOPSing.

The bug was introduced by:

commit 7a59ed415f5b57469e22e41fc4188d5399e0b194
Author: Stefani Seibold <stefani@seibold.net>
Date:   Mon Mar 17 23:22:09 2014 +0100

    x86, vdso: Add 32 bit VDSO time support for 32 bit kernel

which is new in 3.15.

This will be fixed separately in 3.15, but that patch will not apply
to tip/x86/vdso.  This is the equivalent fix for tip/x86/vdso and,
presumably, 3.16.

Cc: Stefani Seibold <stefani@seibold.net>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 arch/x86/vdso/vma.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/x86/vdso/vma.c b/arch/x86/vdso/vma.c
index e915eae..8ad0081 100644
--- a/arch/x86/vdso/vma.c
+++ b/arch/x86/vdso/vma.c
@@ -90,6 +90,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 	struct vm_area_struct *vma;
 	unsigned long addr;
 	int ret = 0;
+	static struct page *no_pages[] = {NULL};
 
 	if (calculate_addr) {
 		addr = vdso_addr(current->mm->start_stack,
@@ -125,7 +126,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
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
