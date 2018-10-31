Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1C66B034A
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 23:25:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id j1-v6so11327918pll.8
        for <linux-mm@kvack.org>; Tue, 30 Oct 2018 20:25:05 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i34-v6si10626359pgb.71.2018.10.30.20.25.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 20:25:03 -0700 (PDT)
Subject: [PATCH 5/8] device-dax: Introduce bus + driver model
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 30 Oct 2018 20:13:15 -0700
Message-ID: <154095559536.3271337.6454472951577982536.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154095556915.3271337.12581429676272726902.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com

In support of multiple device-dax instances per device-dax-region and
allowing the 'kmem' driver to attach to dax-instances instead of the
current device-node access, convert the dax sub-system from a class to a
bus. Recall that the kmem driver takes reserved / special purpose
memories and assigns them to be managed by the core-mm.

Aside from the fact the device-dax instances are registered and probed
on a bus, two other lifetime-management changes are made:

1/ Delay attaching a cdev until driver probe time

2/ A new run_dax() helper is introduced to allow restoring dax-operation
   after a kill_dax() event. So, at driver ->probe() time we run_dax()
   and at ->remove() time we kill_dax() and invalidate all mappings.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/bus.c         |  133 ++++++++++++++++++++++++++++++++++++++++++---
 drivers/dax/bus.h         |   16 +++++
 drivers/dax/dax-private.h |    6 +-
 drivers/dax/device.c      |   95 +++++++++++---------------------
 drivers/dax/super.c       |   40 +++++++++-----
 5 files changed, 203 insertions(+), 87 deletions(-)

diff --git a/drivers/dax/bus.c b/drivers/dax/bus.c
index 8a398e8e1956..0cff32102c4c 100644
--- a/drivers/dax/bus.c
+++ b/drivers/dax/bus.c
@@ -6,6 +6,33 @@
 #include "dax-private.h"
 #include "bus.h"
 
+static int dax_bus_uevent(struct device *dev, struct kobj_uevent_env *env)
+{
+	/*
+	 * We only ever expect to handle device-dax instances, i.e. the
+	 * @type argument to MODULE_ALIAS_DAX_DEVICE() is always zero
+	 */
+	return add_uevent_var(env, "MODALIAS=" DAX_DEVICE_MODALIAS_FMT, 0);
+}
+
+static int dax_bus_match(struct device *dev, struct device_driver *drv);
+
+static struct bus_type dax_bus_type = {
+	.name = "dax",
+	.uevent = dax_bus_uevent,
+	.match = dax_bus_match,
+};
+
+static int dax_bus_match(struct device *dev, struct device_driver *drv)
+{
+	/*
+	 * The drivers that can register on the 'dax' bus are private to
+	 * drivers/dax/ so any device and driver on the bus always
+	 * match.
+	 */
+	return 1;
+}
+
 /*
  * Rely on the fact that drvdata is set before the attributes are
  * registered, and that the attributes are unregistered before drvdata
@@ -142,11 +169,10 @@ static const struct attribute_group dev_dax_attribute_group = {
 	.attrs = dev_dax_attributes,
 };
 
-const struct attribute_group *dax_attribute_groups[] = {
+static const struct attribute_group *dax_attribute_groups[] = {
 	&dev_dax_attribute_group,
 	NULL,
 };
-EXPORT_SYMBOL_GPL(dax_attribute_groups);
 
 void kill_dev_dax(struct dev_dax *dev_dax)
 {
@@ -158,17 +184,108 @@ void kill_dev_dax(struct dev_dax *dev_dax)
 }
 EXPORT_SYMBOL_GPL(kill_dev_dax);
 
-void unregister_dev_dax(void *dev)
+static void dev_dax_release(struct device *dev)
 {
 	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct dax_region *dax_region = dev_dax->region;
 	struct dax_device *dax_dev = dev_dax->dax_dev;
-	struct inode *inode = dax_inode(dax_dev);
-	struct cdev *cdev = inode->i_cdev;
 
-	dev_dbg(dev, "trace\n");
+	dax_region_put(dax_region);
+	put_dax(dax_dev);
+	kfree(dev_dax);
+}
+
+static void unregister_dev_dax(void *dev)
+{
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+
+	dev_dbg(dev, "%s\n", __func__);
 
 	kill_dev_dax(dev_dax);
-	cdev_device_del(cdev, dev);
+	device_del(dev);
 	put_device(dev);
 }
-EXPORT_SYMBOL_GPL(unregister_dev_dax);
+
+struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id)
+{
+	struct device *parent = dax_region->dev;
+	struct dax_device *dax_dev;
+	struct dev_dax *dev_dax;
+	struct inode *inode;
+	struct device *dev;
+	int rc = -ENOMEM;
+
+	if (id < 0)
+		return ERR_PTR(-EINVAL);
+
+	dev_dax = kzalloc(sizeof(*dev_dax), GFP_KERNEL);
+	if (!dev_dax)
+		return ERR_PTR(-ENOMEM);
+
+	/*
+	 * No 'host' or dax_operations since there is no access to this
+	 * device outside of mmap of the resulting character device.
+	 */
+	dax_dev = alloc_dax(dev_dax, NULL, NULL);
+	if (!dax_dev)
+		goto err;
+
+	/* a device_dax instance is dead while the driver is not attached */
+	kill_dax(dax_dev);
+
+	/* from here on we're committed to teardown via dax_dev_release() */
+	dev = &dev_dax->dev;
+	device_initialize(dev);
+
+	dev_dax->dax_dev = dax_dev;
+	dev_dax->region = dax_region;
+	kref_get(&dax_region->kref);
+
+	inode = dax_inode(dax_dev);
+	dev->devt = inode->i_rdev;
+	dev->bus = &dax_bus_type;
+	dev->parent = parent;
+	dev->groups = dax_attribute_groups;
+	dev->release = dev_dax_release;
+	dev_set_name(dev, "dax%d.%d", dax_region->id, id);
+
+	rc = device_add(dev);
+	if (rc) {
+		kill_dev_dax(dev_dax);
+		put_device(dev);
+		return ERR_PTR(rc);
+	}
+
+	rc = devm_add_action_or_reset(dax_region->dev, unregister_dev_dax, dev);
+	if (rc)
+		return ERR_PTR(rc);
+
+	return dev_dax;
+
+ err:
+	kfree(dev_dax);
+
+	return ERR_PTR(rc);
+}
+EXPORT_SYMBOL_GPL(devm_create_dev_dax);
+
+int __dax_driver_register(struct device_driver *drv,
+		struct module *module, const char *mod_name)
+{
+	drv->owner = module;
+	drv->name = mod_name;
+	drv->mod_name = mod_name;
+	drv->bus = &dax_bus_type;
+	return driver_register(drv);
+}
+EXPORT_SYMBOL_GPL(__dax_driver_register);
+
+int __init dax_bus_init(void)
+{
+	return bus_register(&dax_bus_type);
+}
+
+void __exit dax_bus_exit(void)
+{
+	bus_unregister(&dax_bus_type);
+}
diff --git a/drivers/dax/bus.h b/drivers/dax/bus.h
index 840865aa69e8..ea509504df3a 100644
--- a/drivers/dax/bus.h
+++ b/drivers/dax/bus.h
@@ -11,5 +11,21 @@ void dax_region_put(struct dax_region *dax_region);
 struct dax_region *alloc_dax_region(struct device *parent, int region_id,
 		struct resource *res, unsigned int align, unsigned long flags);
 struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id);
+int __dax_driver_register(struct device_driver *drv,
+		struct module *module, const char *mod_name);
+#define dax_driver_register(driver) \
+	__dax_driver_register(driver, THIS_MODULE, KBUILD_MODNAME)
 void kill_dev_dax(struct dev_dax *dev_dax);
+
+/*
+ * While run_dax() is potentially a generic operation that could be
+ * defined in include/linux/dax.h we don't want to grow any users
+ * outside of drivers/dax/
+ */
+void run_dax(struct dax_device *dax_dev);
+
+#define MODULE_ALIAS_DAX_DEVICE(type) \
+	MODULE_ALIAS("dax:t" __stringify(type) "*")
+#define DAX_DEVICE_MODALIAS_FMT "dax:t%d"
+
 #endif /* __DAX_BUS_H__ */
diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
index 620c3f4eefe7..c3a121700837 100644
--- a/drivers/dax/dax-private.h
+++ b/drivers/dax/dax-private.h
@@ -20,10 +20,8 @@
 struct dax_device;
 struct dax_device *inode_dax(struct inode *inode);
 struct inode *dax_inode(struct dax_device *dax_dev);
-
-/* temporary until devm_create_dax_dev moves to bus.c */
-extern const struct attribute_group *dax_attribute_groups[];
-void unregister_dev_dax(void *dev);
+int dax_bus_init(void);
+void dax_bus_exit(void);
 
 /**
  * struct dax_region - mapping infrastructure for dax devices
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 1fc375783e0b..f55829404a24 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -13,8 +13,6 @@
 #include "dax-private.h"
 #include "bus.h"
 
-static struct class *dax_class;
-
 static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
 		const char *func)
 {
@@ -404,93 +402,64 @@ static const struct file_operations dax_fops = {
 	.mmap_supported_flags = MAP_SYNC,
 };
 
-static void dev_dax_release(struct device *dev)
+static void dev_dax_cdev_del(void *cdev)
 {
-	struct dev_dax *dev_dax = to_dev_dax(dev);
-	struct dax_region *dax_region = dev_dax->region;
-	struct dax_device *dax_dev = dev_dax->dax_dev;
+	cdev_del(cdev);
+}
 
-	dax_region_put(dax_region);
-	put_dax(dax_dev);
-	kfree(dev_dax);
+static void dev_dax_kill(void *dev_dax)
+{
+	kill_dev_dax(dev_dax);
 }
 
-struct dev_dax *devm_create_dev_dax(struct dax_region *dax_region, int id)
+static int dev_dax_probe(struct device *dev)
 {
-	struct device *parent = dax_region->dev;
-	struct dax_device *dax_dev;
-	struct dev_dax *dev_dax;
+	struct dev_dax *dev_dax = to_dev_dax(dev);
+	struct dax_device *dax_dev = dev_dax->dax_dev;
 	struct inode *inode;
-	struct device *dev;
 	struct cdev *cdev;
 	int rc;
 
-	dev_dax = kzalloc(sizeof(*dev_dax), GFP_KERNEL);
-	if (!dev_dax)
-		return ERR_PTR(-ENOMEM);
-
-	/*
-	 * No 'host' or dax_operations since there is no access to this
-	 * device outside of mmap of the resulting character device.
-	 */
-	dax_dev = alloc_dax(dev_dax, NULL, NULL);
-	if (!dax_dev) {
-		rc = -ENOMEM;
-		goto err;
-	}
-
-	/* from here on we're committed to teardown via dax_dev_release() */
-	dev = &dev_dax->dev;
-	device_initialize(dev);
-
 	inode = dax_inode(dax_dev);
 	cdev = inode->i_cdev;
 	cdev_init(cdev, &dax_fops);
-	cdev->owner = parent->driver->owner;
-
-	dev_dax->dax_dev = dax_dev;
-	dev_dax->region = dax_region;
-	kref_get(&dax_region->kref);
-
-	dev->devt = inode->i_rdev;
-	dev->class = dax_class;
-	dev->parent = parent;
-	dev->groups = dax_attribute_groups;
-	dev->release = dev_dax_release;
-	dev_set_name(dev, "dax%d.%d", dax_region->id, id);
-
-	rc = cdev_device_add(cdev, dev);
-	if (rc) {
-		kill_dev_dax(dev_dax);
-		put_device(dev);
-		return ERR_PTR(rc);
-	}
-
-	rc = devm_add_action_or_reset(dax_region->dev, unregister_dev_dax, dev);
+	cdev->owner = dev->driver->owner;
+	cdev_set_parent(cdev, &dev->kobj);
+	rc = cdev_add(cdev, dev->devt, 1);
 	if (rc)
-		return ERR_PTR(rc);
+		return rc;
 
-	return dev_dax;
+	rc = devm_add_action_or_reset(dev, dev_dax_cdev_del, cdev);
+	if (rc)
+		return rc;
 
- err:
-	kfree(dev_dax);
+	run_dax(dax_dev);
+	return devm_add_action_or_reset(dev, dev_dax_kill, dev_dax);
+}
 
-	return ERR_PTR(rc);
+static int dev_dax_remove(struct device *dev)
+{
+	/* all probe actions are unwound by devm */
+	return 0;
 }
-EXPORT_SYMBOL_GPL(devm_create_dev_dax);
+
+static struct device_driver device_dax_driver = {
+	.probe = dev_dax_probe,
+	.remove = dev_dax_remove,
+};
 
 static int __init dax_init(void)
 {
-	dax_class = class_create(THIS_MODULE, "dax");
-	return PTR_ERR_OR_ZERO(dax_class);
+	return dax_driver_register(&device_dax_driver);
 }
 
 static void __exit dax_exit(void)
 {
-	class_destroy(dax_class);
+	driver_unregister(&device_dax_driver);
 }
 
 MODULE_AUTHOR("Intel Corporation");
 MODULE_LICENSE("GPL v2");
-subsys_initcall(dax_init);
+module_init(dax_init);
 module_exit(dax_exit);
+MODULE_ALIAS_DAX_DEVICE(0);
diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 0ecc1a2cf1cc..ccb22d8db3a2 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -366,11 +366,15 @@ void kill_dax(struct dax_device *dax_dev)
 	spin_lock(&dax_host_lock);
 	hlist_del_init(&dax_dev->list);
 	spin_unlock(&dax_host_lock);
-
-	dax_dev->private = NULL;
 }
 EXPORT_SYMBOL_GPL(kill_dax);
 
+void run_dax(struct dax_device *dax_dev)
+{
+	set_bit(DAXDEV_ALIVE, &dax_dev->flags);
+}
+EXPORT_SYMBOL_GPL(run_dax);
+
 static struct inode *dax_alloc_inode(struct super_block *sb)
 {
 	struct dax_device *dax_dev;
@@ -585,6 +589,8 @@ EXPORT_SYMBOL_GPL(dax_inode);
 
 void *dax_get_private(struct dax_device *dax_dev)
 {
+	if (!test_bit(DAXDEV_ALIVE, &dax_dev->flags))
+		return NULL;
 	return dax_dev->private;
 }
 EXPORT_SYMBOL_GPL(dax_get_private);
@@ -598,7 +604,7 @@ static void init_once(void *_dax_dev)
 	inode_init_once(inode);
 }
 
-static int __dax_fs_init(void)
+static int dax_fs_init(void)
 {
 	int rc;
 
@@ -630,35 +636,45 @@ static int __dax_fs_init(void)
 	return rc;
 }
 
-static void __dax_fs_exit(void)
+static void dax_fs_exit(void)
 {
 	kern_unmount(dax_mnt);
 	unregister_filesystem(&dax_fs_type);
 	kmem_cache_destroy(dax_cache);
 }
 
-static int __init dax_fs_init(void)
+static int __init dax_core_init(void)
 {
 	int rc;
 
-	rc = __dax_fs_init();
+	rc = dax_fs_init();
 	if (rc)
 		return rc;
 
 	rc = alloc_chrdev_region(&dax_devt, 0, MINORMASK+1, "dax");
 	if (rc)
-		__dax_fs_exit();
-	return rc;
+		goto err_chrdev;
+
+	rc = dax_bus_init();
+	if (rc)
+		goto err_bus;
+	return 0;
+
+err_bus:
+	unregister_chrdev_region(dax_devt, MINORMASK+1);
+err_chrdev:
+	dax_fs_exit();
+	return 0;
 }
 
-static void __exit dax_fs_exit(void)
+static void __exit dax_core_exit(void)
 {
 	unregister_chrdev_region(dax_devt, MINORMASK+1);
 	ida_destroy(&dax_minor_ida);
-	__dax_fs_exit();
+	dax_fs_exit();
 }
 
 MODULE_AUTHOR("Intel Corporation");
 MODULE_LICENSE("GPL v2");
-subsys_initcall(dax_fs_init);
-module_exit(dax_fs_exit);
+subsys_initcall(dax_core_init);
+module_exit(dax_core_exit);
