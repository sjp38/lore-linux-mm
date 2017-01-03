Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD6826B026D
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:22:36 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k15so5760qtg.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:36 -0800 (PST)
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com. [209.85.220.179])
        by mx.google.com with ESMTPS id e2si43157246qta.253.2017.01.03.09.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:22:36 -0800 (PST)
Received: by mail-qk0-f179.google.com with SMTP id n21so376104485qka.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:36 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv6 10/11] mm/usercopy: Switch to using lm_alias
Date: Tue,  3 Jan 2017 09:21:52 -0800
Message-Id: <1483464113-1587-11-git-send-email-labbott@redhat.com>
In-Reply-To: <1483464113-1587-1-git-send-email-labbott@redhat.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

The usercopy checking code currently calls __va(__pa(...)) to check for
aliases on symbols. Switch to using lm_alias instead.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 mm/usercopy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 3c8da0a..8345299 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -108,13 +108,13 @@ static inline const char *check_kernel_text_object(const void *ptr,
 	 * __pa() is not just the reverse of __va(). This can be detected
 	 * and checked:
 	 */
-	textlow_linear = (unsigned long)__va(__pa(textlow));
+	textlow_linear = (unsigned long)lm_alias(textlow);
 	/* No different mapping: we're done. */
 	if (textlow_linear == textlow)
 		return NULL;
 
 	/* Check the secondary mapping... */
-	texthigh_linear = (unsigned long)__va(__pa(texthigh));
+	texthigh_linear = (unsigned long)lm_alias(texthigh);
 	if (overlaps(ptr, n, textlow_linear, texthigh_linear))
 		return "<linear kernel text>";
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
