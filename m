Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1E96B0261
	for <linux-mm@kvack.org>; Mon,  5 Sep 2016 09:35:24 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g185so56393950ith.3
        for <linux-mm@kvack.org>; Mon, 05 Sep 2016 06:35:24 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0112.outbound.protection.outlook.com. [104.47.2.112])
        by mx.google.com with ESMTPS id f3si657988oig.181.2016.09.05.06.35.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 05 Sep 2016 06:35:22 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv5 1/6] x86/vdso: unmap vdso blob on vvar mapping failure
Date: Mon, 5 Sep 2016 16:33:03 +0300
Message-ID: <20160905133308.28234-2-dsafonov@virtuozzo.com>
In-Reply-To: <20160905133308.28234-1-dsafonov@virtuozzo.com>
References: <20160905133308.28234-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com, Dmitry Safonov <dsafonov@virtuozzo.com>

If remapping of vDSO blob failed on vvar mapping,
we need to unmap previously mapped vDSO blob.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
Acked-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/entry/vdso/vma.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index f840766659a8..3bab6ba3ffc5 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -238,12 +238,14 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-		goto up_fail;
+		do_munmap(mm, text_start, image->size);
 	}
 
 up_fail:
-	if (ret)
+	if (ret) {
 		current->mm->context.vdso = NULL;
+		current->mm->context.vdso_image = NULL;
+	}
 
 	up_write(&mm->mmap_sem);
 	return ret;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
