Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F3F126B0070
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:32:45 -0400 (EDT)
Received: by payr10 with SMTP id r10so28487232pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:45 -0700 (PDT)
Received: from mail-pd0-x243.google.com (mail-pd0-x243.google.com. [2607:f8b0:400e:c02::243])
        by mx.google.com with ESMTPS id d7si12318670pdf.127.2015.06.09.23.32.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 23:32:45 -0700 (PDT)
Received: by pdev10 with SMTP id v10so7464260pde.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 23:32:44 -0700 (PDT)
From: Wenwei Tao <wenweitaowenwei@gmail.com>
Subject: [RFC PATCH 4/6] fs/binfmt_elf.c: change the condition of identifying hugetlb vm
Date: Wed, 10 Jun 2015 14:27:17 +0800
Message-Id: <1433917639-31699-5-git-send-email-wenweitaowenwei@gmail.com>
In-Reply-To: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
References: <1433917639-31699-1-git-send-email-wenweitaowenwei@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: izik.eidus@ravellosystems.com, aarcange@redhat.com, chrisw@sous-sol.org, hughd@google.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, viro@zeniv.linux.org.uk
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, wenweitaowenwei@gmail.com

Hugetlb VMAs are not mergeable, that means a VMA couldn't have VM_HUGETLB and
VM_MERGEABLE been set in the same time. So we use VM_HUGETLB to indicate new
mergeable VMAs. Because of that a VMA which has VM_HUGETLB been set is a hugetlb
VMA only if it doesn't have VM_MERGEABLE been set in the same time.

Signed-off-by: Wenwei Tao <wenweitaowenwei@gmail.com>
---
 fs/binfmt_elf.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 995986b..f529c8e 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1242,7 +1242,7 @@ static unsigned long vma_dump_size(struct vm_area_struct *vma,
 		return 0;
 
 	/* Hugetlb memory check */
-	if (vma->vm_flags & VM_HUGETLB) {
+	if ((vma->vm_flags & (VM_HUGETLB | VM_MERGEABLE)) == VM_HUGETLB) {
 		if ((vma->vm_flags & VM_SHARED) && FILTER(HUGETLB_SHARED))
 			goto whole;
 		if (!(vma->vm_flags & VM_SHARED) && FILTER(HUGETLB_PRIVATE))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
