Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66A6A6B0009
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:12 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id i9-v6so1738465oth.3
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:12 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id x2-v6si380748otd.114.2018.03.20.14.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:11 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 8/8] x86: vma: pass atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:26 +0800
Message-Id: <1521581486-99134-9-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

It sounds unnecessary to release mmap_sem in the middle of unmmaping
vdso map.

This is API change only.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/x86/entry/vdso/vma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5b8b556..6359ae5 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -192,7 +192,7 @@ static int map_vdso(const struct vdso_image *image, unsigned long addr)
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-		do_munmap(mm, text_start, image->size, NULL);
+		do_munmap(mm, text_start, image->size, NULL, true);
 	} else {
 		current->mm->context.vdso = (void __user *)text_start;
 		current->mm->context.vdso_image = image;
-- 
1.8.3.1
