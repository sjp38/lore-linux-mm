Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 70DBB6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 04:12:00 -0400 (EDT)
Received: by wiga1 with SMTP id a1so98430890wig.0
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 01:11:59 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id r1si24469749wic.112.2015.06.23.01.11.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jun 2015 01:11:58 -0700 (PDT)
Received: by wibdq8 with SMTP id dq8so8585640wib.1
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 01:11:58 -0700 (PDT)
From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH] dell-laptop: Fix allocating & freeing SMI buffer page
Date: Tue, 23 Jun 2015 10:11:19 +0200
Message-Id: <1435047079-949-1-git-send-email-pali.rohar@gmail.com>
In-Reply-To: <1434876063-13460-1-git-send-email-pali.rohar@gmail.com>
References: <1434876063-13460-1-git-send-email-pali.rohar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Darren Hart <dvhart@infradead.org>, Matthew Garrett <mjg59@srcf.ucam.org>, Michal Hocko <mhocko@suse.cz>
Cc: platform-driver-x86@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>, stable@vger.kernel.org

This commit fix kernel crash when probing for rfkill devices in dell-laptop
driver failed. Function free_page() was incorrectly used on struct page *
instead of virtual address of SMI buffer.

This commit also simplify allocating page for SMI buffer by using
__get_free_page() function instead of sequential call of functions
alloc_page() and page_address().

Signed-off-by: Pali RohA!r <pali.rohar@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Cc: stable@vger.kernel.org
---
 drivers/platform/x86/dell-laptop.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/platform/x86/dell-laptop.c b/drivers/platform/x86/dell-laptop.c
index d688d80..2c1d5f5 100644
--- a/drivers/platform/x86/dell-laptop.c
+++ b/drivers/platform/x86/dell-laptop.c
@@ -305,7 +305,6 @@ static const struct dmi_system_id dell_quirks[] __initconst = {
 };
 
 static struct calling_interface_buffer *buffer;
-static struct page *bufferpage;
 static DEFINE_MUTEX(buffer_mutex);
 
 static int hwswitch_state;
@@ -1896,12 +1895,11 @@ static int __init dell_init(void)
 	 * Allocate buffer below 4GB for SMI data--only 32-bit physical addr
 	 * is passed to SMI handler.
 	 */
-	bufferpage = alloc_page(GFP_KERNEL | GFP_DMA32);
-	if (!bufferpage) {
+	buffer = (void *)__get_free_page(GFP_KERNEL | GFP_DMA32);
+	if (!buffer) {
 		ret = -ENOMEM;
 		goto fail_buffer;
 	}
-	buffer = page_address(bufferpage);
 
 	ret = dell_setup_rfkill();
 
@@ -1965,7 +1963,7 @@ fail_backlight:
 	cancel_delayed_work_sync(&dell_rfkill_work);
 	dell_cleanup_rfkill();
 fail_rfkill:
-	free_page((unsigned long)bufferpage);
+	free_page((unsigned long)buffer);
 fail_buffer:
 	platform_device_del(platform_device);
 fail_platform_device2:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
