Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 970AB6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:42:07 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so116287407ioi.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 09:42:07 -0700 (PDT)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com. [209.85.220.45])
        by mx.google.com with ESMTPS id 1si3473003ioo.192.2015.09.25.09.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 09:42:06 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so110216358pac.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 09:42:06 -0700 (PDT)
From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH V4 1/2] ACPI / EC: Fix broken 64bit big-endian users of 'global_lock'
Date: Fri, 25 Sep 2015 09:41:37 -0700
Message-Id: <e28c4b4deaf766910c366ab87b64325da59c8ad6.1443198783.git.viresh.kumar@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linaro-kernel@lists.linaro.org, QCA ath9k Development <ath9k-devel@qca.qualcomm.com>, Intel Linux Wireless <ilw@linux.intel.com>, Viresh Kumar <viresh.kumar@linaro.org>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org, linux-bluetooth@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org, linux-edac@vger.kernel.org, linux-mm@kvack.org, alsa-devel@alsa-project.org

global_lock is defined as an unsigned long and accessing only its lower
32 bits from sysfs is incorrect, as we need to consider other 32 bits
for big endian 64 bit systems. There are no such platforms yet, but the
code needs to be robust for such a case.

Fix that by passing a local variable to debugfs_create_bool() and
assigning its value to global_lock later.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
V3->V4:
- Create a local variable instead of changing type of global_lock
  (Rafael)
- Drop the stable tag
- BCC'd a lot of people (rather than cc'ing them) to make sure
  - the series reaches them
  - mailing lists do not block the patchset due to long cc list
  - and we don't spam the BCC'd people for every reply
---
 drivers/acpi/ec_sys.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/ec_sys.c b/drivers/acpi/ec_sys.c
index b4c216bab22b..b44b91331a56 100644
--- a/drivers/acpi/ec_sys.c
+++ b/drivers/acpi/ec_sys.c
@@ -110,6 +110,7 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
 	struct dentry *dev_dir;
 	char name[64];
 	umode_t mode = 0400;
+	u32 val;
 
 	if (ec_device_count == 0) {
 		acpi_ec_debugfs_dir = debugfs_create_dir("ec", NULL);
@@ -127,10 +128,11 @@ static int acpi_ec_add_debugfs(struct acpi_ec *ec, unsigned int ec_device_count)
 
 	if (!debugfs_create_x32("gpe", 0444, dev_dir, (u32 *)&first_ec->gpe))
 		goto error;
-	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir,
-				 (u32 *)&first_ec->global_lock))
+	if (!debugfs_create_bool("use_global_lock", 0444, dev_dir, &val))
 		goto error;
 
+	first_ec->global_lock = val;
+
 	if (write_support)
 		mode = 0600;
 	if (!debugfs_create_file("io", mode, dev_dir, ec, &acpi_ec_io_ops))
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
