Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B22096B0447
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:18:00 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so33993277itc.2
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:18:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m20si2719058ita.87.2016.11.18.09.18.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:18:00 -0800 (PST)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM v13 18/18] mm/hmm/devmem: dummy HMM device as an helper for ZONE_DEVICE memory
Date: Fri, 18 Nov 2016 13:18:27 -0500
Message-Id: <1479493107-982-19-git-send-email-jglisse@redhat.com>
In-Reply-To: <1479493107-982-1-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

This introduce a dummy HMM device class so device driver can use it to
create hmm_device for the sole purpose of registering device memory.
It is usefull to device driver that want to manage multiple physical
device memory under same device umbrella.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
---
 include/linux/hmm.h | 22 ++++++++++++-
 mm/hmm.c            | 95 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 116 insertions(+), 1 deletion(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ac0b69a..106de1f 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -88,10 +88,10 @@
 
 #if IS_ENABLED(CONFIG_HMM)
 
+#include <linux/device.h>
 #include <linux/memremap.h>
 #include <linux/completion.h>
 
-
 struct hmm;
 
 /*
@@ -484,6 +484,26 @@ static inline unsigned long hmm_devmem_page_get_drvdata(struct page *page)
 }
 
 
+/*
+ * struct hmm_device - fake device to hang device memory onto
+ *
+ * @device: device struct
+ * @minor: device minor number
+ */
+struct hmm_device {
+	struct device		device;
+	unsigned		minor;
+};
+
+/*
+ * Device driver that want to handle multiple devices memory through a single
+ * fake device can use hmm_device to do so. This is purely an helper and it
+ * is not needed to make use of any HMM functionality.
+ */
+struct hmm_device *hmm_device_new(void);
+void hmm_device_put(struct hmm_device *hmm_device);
+
+
 /* Below are for HMM internal use only ! Not to be use by device driver ! */
 void hmm_mm_destroy(struct mm_struct *mm);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index f2ca895..61c3640187 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/sched.h>
 #include <linux/mmzone.h>
+#include <linux/module.h>
 #include <linux/pagemap.h>
 #include <linux/swapops.h>
 #include <linux/hugetlb.h>
@@ -1078,3 +1079,97 @@ int hmm_devmem_fault_range(struct hmm_devmem *devmem,
 	return 0;
 }
 EXPORT_SYMBOL(hmm_devmem_fault_range);
+
+/*
+ * Device driver that want to handle multiple devices memory through a single
+ * fake device can use hmm_device to do so. This is purely an helper and it
+ * is not needed to make use of any HMM functionality.
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
+struct hmm_device *hmm_device_new(void)
+{
+	struct hmm_device *hmm_device;
+	int ret;
+
+	hmm_device = kzalloc(sizeof(*hmm_device), GFP_KERNEL);
+	if (!hmm_device)
+		return ERR_PTR(-ENOMEM);
+
+	ret = alloc_chrdev_region(&hmm_device->device.devt,0,1,"hmm_device");
+	if (ret < 0) {
+		kfree(hmm_device);
+		return NULL;
+	}
+
+	spin_lock(&hmm_device_lock);
+	hmm_device->minor=find_first_zero_bit(hmm_device_mask,HMM_DEVICE_MAX);
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
+static void __exit hmm_exit(void)
+{
+	unregister_chrdev_region(hmm_device_devt, HMM_DEVICE_MAX);
+	class_destroy(hmm_device_class);
+}
+
+module_init(hmm_init);
+module_exit(hmm_exit);
+MODULE_LICENSE("GPL");
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
