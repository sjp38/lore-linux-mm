Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 894C06B0260
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 11:51:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q4so11703417qtq.16
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 08:51:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c193si1654017qkb.39.2017.10.12.08.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 08:51:33 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC] QEMU: Add virtio pmem device
Date: Thu, 12 Oct 2017 21:20:27 +0530
Message-Id: <20171012155027.3277-4-pagupta@redhat.com>
In-Reply-To: <20171012155027.3277-1-pagupta@redhat.com>
References: <20171012155027.3277-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@redhat.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, pagupta@redhat.com

 This patch adds virtio-pmem Qemu device.

 This device configures memory address range information with file
 backend type. It acts like persistent memory device for KVM guest.
 It presents the memory address range to virtio-pmem driver over
 virtio channel and does the block flush whenever there is request
 from guest to flush/sync. (later part is yet to be implemented).

 Current code is a prototype to support guest with persistent 
 memory range & DAX.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 hw/virtio/Makefile.objs                     |   2 +-
 hw/virtio/virtio-pci.c                      |  44 ++++++++++
 hw/virtio/virtio-pci.h                      |  14 +++
 hw/virtio/virtio-pmem.c                     | 130 ++++++++++++++++++++++++++++
 include/hw/pci/pci.h                        |   1 +
 include/hw/virtio/virtio-pmem.h             |  42 +++++++++
 include/standard-headers/linux/virtio_ids.h |   1 +
 7 files changed, 233 insertions(+), 1 deletion(-)
 create mode 100644 hw/virtio/virtio-pmem.c
 create mode 100644 include/hw/virtio/virtio-pmem.h

diff --git a/hw/virtio/Makefile.objs b/hw/virtio/Makefile.objs
index 765d363c1f..bb5573d2ef 100644
--- a/hw/virtio/Makefile.objs
+++ b/hw/virtio/Makefile.objs
@@ -5,7 +5,7 @@ common-obj-y += virtio-bus.o
 common-obj-y += virtio-mmio.o
 
 obj-y += virtio.o virtio-balloon.o 
-obj-$(CONFIG_LINUX) += vhost.o vhost-backend.o vhost-user.o
+obj-$(CONFIG_LINUX) += vhost.o vhost-backend.o vhost-user.o virtio-pmem.o
 obj-$(CONFIG_VHOST_VSOCK) += vhost-vsock.o
 obj-y += virtio-crypto.o
 obj-$(CONFIG_VIRTIO_PCI) += virtio-crypto-pci.o
diff --git a/hw/virtio/virtio-pci.c b/hw/virtio/virtio-pci.c
index 8b0d6b69cd..eb56afb290 100644
--- a/hw/virtio/virtio-pci.c
+++ b/hw/virtio/virtio-pci.c
@@ -2473,6 +2473,49 @@ static const TypeInfo virtio_rng_pci_info = {
     .class_init    = virtio_rng_pci_class_init,
 };
 
+/* virtio-pmem-pci */
+
+static void virtio_pmem_pci_realize(VirtIOPCIProxy *vpci_dev, Error **errp)
+{
+    VirtIOPMEMPCI *vpmem = VIRTIO_PMEM_PCI(vpci_dev);
+    DeviceState *vdev = DEVICE(&vpmem->vdev);
+
+    qdev_set_parent_bus(vdev, BUS(&vpci_dev->bus));
+    object_property_set_bool(OBJECT(vdev), true, "realized", errp);
+}
+
+static void virtio_pmem_pci_class_init(ObjectClass *klass, void *data)
+{
+    DeviceClass *dc = DEVICE_CLASS(klass);
+    VirtioPCIClass *k = VIRTIO_PCI_CLASS(klass);
+    PCIDeviceClass *pcidev_k = PCI_DEVICE_CLASS(klass);
+    k->realize = virtio_pmem_pci_realize;
+    set_bit(DEVICE_CATEGORY_MISC, dc->categories);
+    pcidev_k->vendor_id = PCI_VENDOR_ID_REDHAT_QUMRANET;
+    pcidev_k->device_id = PCI_DEVICE_ID_VIRTIO_PMEM;
+    pcidev_k->revision = VIRTIO_PCI_ABI_VERSION;
+    pcidev_k->class_id = PCI_CLASS_OTHERS;
+}
+
+static void virtio_pmem_pci_instance_init(Object *obj)
+{
+    VirtIOPMEMPCI *dev = VIRTIO_PMEM_PCI(obj);
+
+    virtio_instance_init_common(obj, &dev->vdev, sizeof(dev->vdev),
+                                TYPE_VIRTIO_PMEM);
+    object_property_add_alias(obj, "memdev", OBJECT(&dev->vdev), "memdev",
+                              &error_abort);
+}
+
+static const TypeInfo virtio_pmem_pci_info = {
+    .name          = TYPE_VIRTIO_PMEM_PCI,
+    .parent        = TYPE_VIRTIO_PCI,
+    .instance_size = sizeof(VirtIOPMEMPCI),
+    .instance_init = virtio_pmem_pci_instance_init,
+    .class_init    = virtio_pmem_pci_class_init,
+};
+
+
 /* virtio-input-pci */
 
 static Property virtio_input_pci_properties[] = {
@@ -2662,6 +2705,7 @@ static void virtio_pci_register_types(void)
     type_register_static(&virtio_balloon_pci_info);
     type_register_static(&virtio_serial_pci_info);
     type_register_static(&virtio_net_pci_info);
+    type_register_static(&virtio_pmem_pci_info);
 #ifdef CONFIG_VHOST_SCSI
     type_register_static(&vhost_scsi_pci_info);
 #endif
diff --git a/hw/virtio/virtio-pci.h b/hw/virtio/virtio-pci.h
index 69f5959623..37f0eeabd2 100644
--- a/hw/virtio/virtio-pci.h
+++ b/hw/virtio/virtio-pci.h
@@ -19,6 +19,7 @@
 #include "hw/virtio/virtio-blk.h"
 #include "hw/virtio/virtio-net.h"
 #include "hw/virtio/virtio-rng.h"
+#include "hw/virtio/virtio-pmem.h"
 #include "hw/virtio/virtio-serial.h"
 #include "hw/virtio/virtio-scsi.h"
 #include "hw/virtio/virtio-balloon.h"
@@ -53,6 +54,7 @@ typedef struct VirtIOInputHostPCI VirtIOInputHostPCI;
 typedef struct VirtIOGPUPCI VirtIOGPUPCI;
 typedef struct VHostVSockPCI VHostVSockPCI;
 typedef struct VirtIOCryptoPCI VirtIOCryptoPCI;
+typedef struct VirtIOPMEMPCI VirtIOPMEMPCI;
 
 /* virtio-pci-bus */
 
@@ -254,6 +256,18 @@ struct VirtIOBlkPCI {
 };
 
 /*
+ * virtio-pmem-pci: This extends VirtioPCIProxy.
+ */
+#define TYPE_VIRTIO_PMEM_PCI "virtio-pmem-pci"
+#define VIRTIO_PMEM_PCI(obj) \
+        OBJECT_CHECK(VirtIOPMEMPCI, (obj), TYPE_VIRTIO_PMEM_PCI)
+
+struct VirtIOPMEMPCI {
+    VirtIOPCIProxy parent_obj;
+    VirtIOPMEM vdev;
+};
+
+/*
  * virtio-balloon-pci: This extends VirtioPCIProxy.
  */
 #define TYPE_VIRTIO_BALLOON_PCI "virtio-balloon-pci"
diff --git a/hw/virtio/virtio-pmem.c b/hw/virtio/virtio-pmem.c
new file mode 100644
index 0000000000..6ba1fd1614
--- /dev/null
+++ b/hw/virtio/virtio-pmem.c
@@ -0,0 +1,130 @@
+/*
+ * Virtio pmem device
+ *
+ *
+ */
+
+#include "qemu/osdep.h"
+#include "qapi/error.h"
+#include "qemu-common.h"
+#include "qemu/error-report.h"
+#include "hw/virtio/virtio-pmem.h"
+
+
+static void virtio_pmem_system_reset(void *opaque)
+{
+
+}
+
+static void virtio_pmem_flush(VirtIODevice *vdev, VirtQueue *vq)
+{
+    /* VirtIOPMEM  *vm = VIRTIO_PMEM(vdev); */
+}
+
+
+static void virtio_pmem_get_config(VirtIODevice *vdev, uint8_t *config)
+{
+    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
+    struct virtio_pmem_config *pmemcfg = (struct virtio_pmem_config *) config;
+
+    pmemcfg->start = pmem->start;
+    pmemcfg->size  = pmem->size;
+    pmemcfg->align = pmem->align;
+}
+
+static uint64_t virtio_pmem_get_features(VirtIODevice *vdev, uint64_t features,
+                                        Error **errp)
+{
+    virtio_add_feature(&features, VIRTIO_PMEM_PLUG);
+    return features;
+}
+
+
+
+static void virtio_pmem_realize(DeviceState *dev, Error **errp)
+{
+    VirtIODevice   *vdev   = VIRTIO_DEVICE(dev);
+    VirtIOPMEM     *pmem   = VIRTIO_PMEM(dev);
+    MachineState   *ms     = MACHINE(qdev_get_machine());
+    MemoryRegion   *mr;
+    PCMachineState *pcms   =
+        PC_MACHINE(object_dynamic_cast(OBJECT(ms), TYPE_PC_MACHINE));
+
+    if (!pmem->memdev) {
+        error_setg(errp, "virtio-pmem not set");
+        return;
+    }
+
+    pmem->start = pcms->hotplug_memory.base;
+
+    /*if (!pcmc->broken_reserved_end) {
+            pmem->size = memory_region_size(&pcms->hotplug_memory.mr);
+    }*/
+
+
+    mr               = host_memory_backend_get_memory(pmem->memdev, errp);
+    pmem->size       = memory_region_size(mr);
+    pmem->align      = memory_region_get_alignment(mr);
+
+    virtio_init(vdev, TYPE_VIRTIO_PMEM, VIRTIO_ID_PMEM,
+                sizeof(struct virtio_pmem_config));
+
+    pmem->rq_vq = virtio_add_queue(vdev, 128, virtio_pmem_flush);
+
+    host_memory_backend_set_mapped(pmem->memdev, true);
+    qemu_register_reset(virtio_pmem_system_reset, pmem);
+}
+
+static void virtio_mem_check_memdev(Object *obj, const char *name, Object *val,
+                                    Error **errp)
+{
+
+    if (host_memory_backend_is_mapped(MEMORY_BACKEND(val))) {
+
+        char *path = object_get_canonical_path_component(val);
+        error_setg(errp, "Can't use already busy memdev: %s", path);
+        g_free(path);
+        return;
+    }
+
+    qdev_prop_allow_set_link_before_realize(obj, name, val, errp);
+}
+
+static void virtio_pmem_instance_init(Object *obj)
+{
+
+    VirtIOPMEM *vm = VIRTIO_PMEM(obj);
+
+    object_property_add_link(obj, "memdev", TYPE_MEMORY_BACKEND,
+                             (Object **)&vm->memdev,
+                             (void *) virtio_mem_check_memdev,
+                             OBJ_PROP_LINK_UNREF_ON_RELEASE,
+                             &error_abort);
+
+}
+
+
+static void virtio_pmem_class_init(ObjectClass *klass, void *data)
+{
+    VirtioDeviceClass *vdc = VIRTIO_DEVICE_CLASS(klass);
+
+    vdc->realize      =  virtio_pmem_realize;
+    vdc->get_config   =  virtio_pmem_get_config;
+    vdc->get_features =  virtio_pmem_get_features;
+}
+
+static TypeInfo virtio_pmem_info = {
+    .name          = TYPE_VIRTIO_PMEM,
+    .parent        = TYPE_VIRTIO_DEVICE,
+    .class_size    = sizeof(VirtIOPMEM),
+    .class_init    = virtio_pmem_class_init,
+    .instance_init = virtio_pmem_instance_init,
+};
+
+
+static void virtio_register_types(void)
+{
+    type_register_static(&virtio_pmem_info);
+}
+
+type_init(virtio_register_types)
diff --git a/include/hw/pci/pci.h b/include/hw/pci/pci.h
index 8bb6449dd7..b9bfb79a11 100644
--- a/include/hw/pci/pci.h
+++ b/include/hw/pci/pci.h
@@ -85,6 +85,7 @@ extern bool pci_available;
 #define PCI_DEVICE_ID_VIRTIO_RNG         0x1005
 #define PCI_DEVICE_ID_VIRTIO_9P          0x1009
 #define PCI_DEVICE_ID_VIRTIO_VSOCK       0x1012
+#define PCI_DEVICE_ID_VIRTIO_PMEM        0x1013
 
 #define PCI_VENDOR_ID_REDHAT             0x1b36
 #define PCI_DEVICE_ID_REDHAT_BRIDGE      0x0001
diff --git a/include/hw/virtio/virtio-pmem.h b/include/hw/virtio/virtio-pmem.h
new file mode 100644
index 0000000000..0d0642ed82
--- /dev/null
+++ b/include/hw/virtio/virtio-pmem.h
@@ -0,0 +1,42 @@
+/*
+ * Virtio pmem Device
+ *
+ *
+ */
+
+#ifndef QEMU_VIRTIO_PMEM_H
+#define QEMU_VIRTIO_PMEM_H
+
+#include "hw/virtio/virtio.h"
+#include "exec/memory.h"
+#include "sysemu/hostmem.h"
+#include "standard-headers/linux/virtio_ids.h"
+#include "hw/boards.h"
+#include "hw/i386/pc.h"
+
+#define VIRTIO_PMEM_PLUG 0
+
+#define TYPE_VIRTIO_PMEM "virtio-pmem"
+
+#define VIRTIO_PMEM(obj) \
+        OBJECT_CHECK(VirtIOPMEM, (obj), TYPE_VIRTIO_PMEM)
+
+typedef struct VirtIOPMEM {
+
+    VirtIODevice parent_obj;
+    uint64_t start;
+    uint64_t size;
+    uint64_t align;
+
+    VirtQueue *rq_vq;
+    MemoryRegion *mr;
+    HostMemoryBackend *memdev;
+} VirtIOPMEM;
+
+struct virtio_pmem_config {
+
+    uint64_t start;
+    uint64_t size;
+    uint64_t align;
+};
+#endif
diff --git a/include/standard-headers/linux/virtio_ids.h b/include/standard-headers/linux/virtio_ids.h
index 6d5c3b2d4f..5ebd04980d 100644
--- a/include/standard-headers/linux/virtio_ids.h
+++ b/include/standard-headers/linux/virtio_ids.h
@@ -43,5 +43,6 @@
 #define VIRTIO_ID_INPUT        18 /* virtio input */
 #define VIRTIO_ID_VSOCK        19 /* virtio vsock transport */
 #define VIRTIO_ID_CRYPTO       20 /* virtio crypto */
+#define VIRTIO_ID_PMEM         21 /* virtio pmem */
 
 #endif /* _LINUX_VIRTIO_IDS_H */
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
