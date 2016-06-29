Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6701A6B025E
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 06:59:00 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id g127so88756852ith.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 03:59:00 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id g16si2525122otd.237.2016.06.29.03.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 29 Jun 2016 03:58:59 -0700 (PDT)
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Subject: [PATCHv2 1/6] x86/vdso: unmap vdso blob on vvar mapping failure
Date: Wed, 29 Jun 2016 13:57:31 +0300
Message-ID: <20160629105736.15017-2-dsafonov@virtuozzo.com>
In-Reply-To: <20160629105736.15017-1-dsafonov@virtuozzo.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: 0x7f454c46@gmail.com, linux-mm@kvack.org, mingo@redhat.com, luto@amacapital.net, gorcunov@openvz.org, xemul@virtuozzo.com, oleg@redhat.com, Dmitry Safonov <dsafonov@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

If remapping of vDSO blob failed on vvar mapping,
we need to unmap previously mapped vDSO blob.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: Pavel Emelyanov <xemul@virtuozzo.com>
Cc: x86@kernel.org
Signed-off-by: Dmitry Safonov <dsafonov@virtuozzo.com>
---
 arch/x86/entry/vdso/vma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 3329844e3c43..387028e6755d 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -238,7 +238,7 @@ static int map_vdso(const struct vdso_image *image, bool calculate_addr)
 
 	if (IS_ERR(vma)) {
 		ret = PTR_ERR(vma);
-		goto up_fail;
+		do_munmap(mm, text_start, image->size);
 	}
 
 up_fail:
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
