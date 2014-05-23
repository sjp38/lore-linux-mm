Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id ED5316B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 16:01:37 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so4531850pab.31
        for <linux-mm@kvack.org>; Fri, 23 May 2014 13:01:37 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id yf6si5309438pbc.37.2014.05.23.13.01.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 May 2014 13:01:37 -0700 (PDT)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: [RESEND PATCH] staging: ion: WARN when the handle kmap_cnt is going to wrap around
Date: Fri, 23 May 2014 13:01:22 -0700
Message-Id: <1400875282-17892-1-git-send-email-mitchelh@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Colin Cross <ccross@android.com>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Android Kernel Team <kernel-team@android.com>, linux-kernel@vger.kernel.org, Mitchel Humpherys <mitchelh@codeaurora.org>

There are certain client bugs (double unmap, for example) that can cause
the handle->kmap_cnt (an unsigned int) to wrap around from zero. This
causes problems when the handle is destroyed because we have:

        while (handle->kmap_cnt)
                ion_handle_kmap_put(handle);

which takes a long time to complete when kmap_cnt starts at ~0 and can
result in a watchdog timeout.

WARN and bail when kmap_cnt is about to wrap around from zero.

Signed-off-by: Mitchel Humpherys <mitchelh@codeaurora.org>
Acked-by: Colin Cross <ccross@android.com>
---
Resending since I missed a few folks on the original. Also retaining
Colin's Acked-by.
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
