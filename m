Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 1BAEA6B005D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 12:50:52 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so4656099bkc.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 09:50:51 -0800 (PST)
From: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
Subject: [RFC PATCH v3 3/3] acpi_memhotplug: Allow eject to proceed on rebind scenario
Date: Fri, 23 Nov 2012 18:50:37 +0100
Message-Id: <1353693037-21704-4-git-send-email-vasilis.liaskovitis@profitbricks.com>
In-Reply-To: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
References: <1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com
Cc: rjw@sisk.pl, lenb@kernel.org, toshi.kani@hp.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>

Consider the following sequence of operations for a hotplugged memory device:

1. echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/unbind
2. echo "PNP0C80:XX" > /sys/bus/acpi/drivers/acpi_memhotplug/bind
3. echo 1 >/sys/bus/pci/devices/PNP0C80:XX/eject

The driver is successfully re-bound to the device in step 2. However step 3 will
not attempt to remove the memory. This is because the acpi_memory_info enabled
bit for the newly bound driver has not been set to 1. This bit needs to be set
in the case where the memory is already used by the kernel (add_memory returns
-EEXIST)

Setting the enabled bit in this case (in acpi_memory_enable_device) makes the
driver function properly after a rebind of the driver i.e. eject operation
attempts to remove memory after a successful rebind.

I am not sure if this breaks some other usage of the enabled bit (see commit
65479472). When is it possible for the memory to be in use by the kernel but
not managed by the acpi driver, apart from a driver unbind scenario?

Perhaps the patch is not needed, depending on expected semantics of re-binding.
Is the newly bound driver supposed to manage the device, if it was earlier
managed by the same driver?

This patch is only specific to this scenario, and can be dropped from the patch
series if needed.

Signed-off-by: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>
---
 drivers/acpi/acpi_memhotplug.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index d0cfbd9..0562cb4 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -271,12 +271,11 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 			continue;
 		}
 
-		if (!result)
-			info->enabled = 1;
 		/*
 		 * Add num_enable even if add_memory() returns -EEXIST, so the
 		 * device is bound to this driver.
 		 */
+		info->enabled = 1;
 		num_enabled++;
 	}
 	if (!num_enabled) {
-- 
1.7.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
