Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 675F66B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 20:51:59 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so3263940pbb.5
        for <linux-mm@kvack.org>; Thu, 22 May 2014 17:51:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id hc10si1684138pac.34.2014.05.22.17.51.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 May 2014 17:51:58 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [PATCH] staging: ion: WARN when the handle kmap_cnt is going to wrap around
Date: Thu, 22 May 2014 17:51:21 -0700
Message-Id: <1400806281-32716-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Colin Cross <ccross@android.com>, John Stultz <john.stultz@linaro.org>
Cc: Android Kernel Team <kernel-team@android.com>, linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

There are certain client bugs (double unmap, for example) that can cause
the handle->kmap_cnt (an unsigned int) to wrap around from zero. This
causes problems when the handle is destroyed because we have:

        while (handle->kmap_cnt)
                ion_handle_kmap_put(handle);

which takes a long time to complete when kmap_cnt starts at ~0 and can
result in a watchdog timeout.

WARN and bail when kmap_cnt is about to wrap around from zero.

Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
---
 drivers/staging/android/ion/ion.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 3d5bf14722..f55f61a4cc 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -626,6 +626,10 @@ static void ion_handle_kmap_put(struct ion_handle *handle)
 {
 	struct ion_buffer *buffer = handle->buffer;
 
+	if (!handle->kmap_cnt) {
+		WARN(1, "%s: Double unmap detected! bailing...\n", __func__);
+		return;
+	}
 	handle->kmap_cnt--;
 	if (!handle->kmap_cnt)
 		ion_buffer_kmap_put(buffer);
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
