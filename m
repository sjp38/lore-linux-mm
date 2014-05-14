Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id AB6146B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 19:01:27 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rq2so212581pbb.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:01:27 -0700 (PDT)
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
        by mx.google.com with ESMTPS id qh4si97051pbb.180.2014.05.14.16.01.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 16:01:26 -0700 (PDT)
Received: by mail-pb0-f50.google.com with SMTP id ma3so210878pbc.23
        for <linux-mm@kvack.org>; Wed, 14 May 2014 16:01:26 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH 3.15] x86,vdso: Fix an OOPS accessing the hpet mapping w/o an hpet
Date: Wed, 14 May 2014 16:01:22 -0700
Message-Id: <e1640272803e7711d9a43d9454dbdae57ba22eed.1400108299.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>

The access should fail, but it shouldn't oops.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

The oops can be triggered in qemu using -no-hpet (but not nohpet) by
running a 32-bit program and reading a couple of pages before the vdso.

This will conflict with tip/x86/vdso.  Sorry.

 arch/x86/vdso/vdso32-setup.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/vdso/vdso32-setup.c b/arch/x86/vdso/vdso32-setup.c
index 0034898..33426da 100644
--- a/arch/x86/vdso/vdso32-setup.c
+++ b/arch/x86/vdso/vdso32-setup.c
@@ -147,6 +147,8 @@ int __init sysenter_setup(void)
 	return 0;
 }
 
+static struct page *no_pages[] = {NULL};
+
 /* Setup a VMA at program startup for the vsyscall page */
 int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 {
@@ -192,7 +194,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm, int uses_interp)
 			addr -  VDSO_OFFSET(VDSO_PREV_PAGES),
 			VDSO_OFFSET(VDSO_PREV_PAGES),
 			VM_READ,
-			NULL);
+			no_pages);
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
