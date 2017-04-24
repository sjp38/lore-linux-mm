Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E66CD6B0388
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:13:12 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j29so42401678qtj.19
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:13:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si18836535qkb.41.2017.04.24.11.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:13:11 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 14/15] mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v3
Date: Mon, 24 Apr 2017 14:12:42 -0400
Message-Id: <20170424181243.20320-15-jglisse@redhat.com>
In-Reply-To: <20170424181243.20320-1-jglisse@redhat.com>
References: <20170424181243.20320-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This introduce a dummy HMM device class so device driver can use it to
create hmm_device for the sole purpose of registering device memory.
It is useful to device driver that want to manage multiple physical
device memory under same struct device umbrella.

Changed since v2:
  - use device_initcall() and drop everything that is module specific
Changed since v1:
  - Improve commit message
  - Add drvdata parameter to set on struct device

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Evgeny Baskakov <ebaskakov@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 22 +++++++++++++-
 mm/hmm.c            | 88 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 109 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 0865afd..2f2a6ff 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -72,11 +72,11 @@
 
 #if IS_ENABLED(CONFIG_HMM)
 
+#include <linux/device.h>
 #include <linux/migrate.h>
 #include <linux/memremap.h>
 #include <linux/completion.h>
 
-
 struct hmm;
 
 /*
@@ -433,6 +433,26 @@ static inline unsigned long hmm_devmem_page_get_drvdata(struct page *page)
 
 	return drvdata[1];
 }
+
+
+/*
+ * struct hmm_device - fake device to hang device memory onto
+ *
+ * @device: device struct
+ * @minor: device minor number
+ */
+struct hmm_device {
+	struct device		device;
+	unsigned int		minor;
+};
+
+/*
+ * A device driver that wants to handle multiple devices memory through a
+ * single fake device can use hmm_device to do so. This is purely a helper and
+ * it is not strictly needed, in order to make use of any HMM functionality.
+ */
+struct hmm_device *hmm_device_new(void *drvdata);
+void hmm_device_put(struct hmm_device *hmm_device);
 #endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
 
 
diff --git a/mm/hmm.c b/mm/hmm.c
index 0ea0e12..f01c44f 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -19,6 +19,7 @@
  */
 #include <linux/mm.h>
 #include <linux/hmm.h>
+#include <linux/init.h>
 #include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
@@ -1112,4 +1113,91 @@ int hmm_devmem_fault_range(struct hmm_devmem *devmem,
 	return 0;
 }
 EXPORT_SYMBOL(hmm_devmem_fault_range);
+
+/*
+ * A device driver that wants to handle multiple devices memory through a
+ * single fake device can use hmm_device to do so. This is purely a helper
+ * and it is not needed to make use of any HMM functionality.
+ */
+#define HMM_DEVICE_MAX 256
+
+static DECLARE_BITMAP(hmm_device_mask, HMM_DEVICE_MAX);
+static DEFINE_SPINLOCK(hmm_device_lock);
+static struct class *hmm_device_class;
+static dev_t hmm_device_devt;
+
+static void hmm_device_release(struct device *device)
+{
+	struct hmm_device *hmm_device;
+
+	hmm_device = container_of(device, struct hmm_device, device);
+	spin_lock(&hmm_device_lock);
+	clear_bit(hmm_device->minor, hmm_device_mask);
+	spin_unlock(&hmm_device_lock);
+
+	kfree(hmm_device);
+}
+
+struct hmm_device *hmm_device_new(void *drvdata)
+{
+	struct hmm_device *hmm_device;
+	int ret;
+
+	hmm_device = kzalloc(sizeof(*hmm_device), GFP_KERNEL);
+	if (!hmm_device)
+		return ERR_PTR(-ENOMEM);
+
+	ret = alloc_chrdev_region(&hmm_device->device.devt, 0, 1, "hmm_device");
+	if (ret < 0) {
+		kfree(hmm_device);
+		return NULL;
+	}
+
+	spin_lock(&hmm_device_lock);
+	hmm_device->minor = find_first_zero_bit(hmm_device_mask, HMM_DEVICE_MAX);
+	if (hmm_device->minor >= HMM_DEVICE_MAX) {
+		spin_unlock(&hmm_device_lock);
+		kfree(hmm_device);
+		return NULL;
+	}
+	set_bit(hmm_device->minor, hmm_device_mask);
+	spin_unlock(&hmm_device_lock);
+
+	dev_set_name(&hmm_device->device, "hmm_device%d", hmm_device->minor);
+	hmm_device->device.devt = MKDEV(MAJOR(hmm_device_devt),
+					hmm_device->minor);
+	hmm_device->device.release = hmm_device_release;
+	dev_set_drvdata(&hmm_device->device, drvdata);
+	hmm_device->device.class = hmm_device_class;
+	device_initialize(&hmm_device->device);
+
+	return hmm_device;
+}
+EXPORT_SYMBOL(hmm_device_new);
+
+void hmm_device_put(struct hmm_device *hmm_device)
+{
+	put_device(&hmm_device->device);
+}
+EXPORT_SYMBOL(hmm_device_put);
+
+static int __init hmm_init(void)
+{
+	int ret;
+
+	ret = alloc_chrdev_region(&hmm_device_devt, 0,
+				  HMM_DEVICE_MAX,
+				  "hmm_device");
+	if (ret)
+		return ret;
+
+	hmm_device_class = class_create(THIS_MODULE, "hmm_device");
+	if (IS_ERR(hmm_device_class)) {
+		unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
+		return PTR_ERR(hmm_device_class);
+	}
+	return 0;
+}
+
+device_initcall(hmm_init);
 #endif /* IS_ENABLED(CONFIG_HMM_DEVMEM) */
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
