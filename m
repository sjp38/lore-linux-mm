Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C30CE6B0008
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 07:24:48 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c20so5061911qkm.13
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 04:24:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o34si1616481qkh.109.2018.04.25.04.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 04:24:47 -0700 (PDT)
From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC v2] qemu: Add virtio pmem device
Date: Wed, 25 Apr 2018 16:54:15 +0530
Message-Id: <20180425112415.12327-4-pagupta@redhat.com>
In-Reply-To: <20180425112415.12327-1-pagupta@redhat.com>
References: <20180425112415.12327-1-pagupta@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-nvdimm@ml01.01.org, linux-mm@kvack.org
Cc: jack@suse.cz, stefanha@redhat.com, dan.j.williams@intel.com, riel@surriel.com, haozhong.zhang@intel.com, nilal@redhat.com, kwolf@redhat.com, pbonzini@redhat.com, ross.zwisler@intel.com, david@redhat.com, xiaoguangrong.eric@gmail.com, hch@infradead.org, marcel@redhat.com, mst@redhat.com, niteshnarayanlal@hotmail.com, imammedo@redhat.com, pagupta@redhat.com, lcapitulino@redhat.com

This patch adds virtio-pmem Qemu device.

This device presents memory address range 
information to guest which is backed by file 
backend type. It acts like persistent memory 
device for KVM guest. Guest can perform read 
and persistent write operations on this memory 
range with the help of DAX capable filesystem.

Persistent guest writes are assured with the 
help of virtio based flushing interface. When 
guest userspace space performs fsync on file 
fd on pmem device, a flush command is send to 
Qemu over VIRTIO and host side flush/sync is 
done on backing image file.

This PV device code is dependent and tested 
with 'David Hildenbrand's ' patchset[1] to 
map non-PCDIMM devices to guest address space.
There is still upstream discussion on using 
among PCI bar vs memory device, will update 
as per concensus.

[1] https://marc.info/?l=qemu-devel&m=152450249319168&w=2

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 hw/virtio/Makefile.objs                     |   3 +
 hw/virtio/virtio-pci.c                      |  44 +++++++
 hw/virtio/virtio-pci.h                      |  14 ++
 hw/virtio/virtio-pmem.c                     | 197 ++++++++++++++++++++++++++++
 include/hw/pci/pci.h                        |   1 +
 include/hw/virtio/virtio-pmem.h             |  44 +++++++
 include/standard-headers/linux/virtio_ids.h |   1 +
 qapi/misc.json                              |  26 +++-
 8 files changed, 329 insertions(+), 1 deletion(-)
 create mode 100644 hw/virtio/virtio-pmem.c
 create mode 100644 include/hw/virtio/virtio-pmem.h

diff --git a/hw/virtio/Makefile.objs b/hw/virtio/Makefile.objs
index 765d363c1f..d329dbb1a1 100644
--- a/hw/virtio/Makefile.objs
+++ b/hw/virtio/Makefile.objs
@@ -6,6 +6,9 @@ common-obj-y += virtio-mmio.o
 
 obj-y += virtio.o virtio-balloon.o 
 obj-$(CONFIG_LINUX) += vhost.o vhost-backend.o vhost-user.o
+ifeq ($(CONFIG_MEM_HOTPLUG),y)
+obj-$(CONFIG_LINUX) += virtio-pmem.o
+endif
 obj-$(CONFIG_VHOST_VSOCK) += vhost-vsock.o
 obj-y += virtio-crypto.o
 obj-$(CONFIG_VIRTIO_PCI) += virtio-crypto-pci.o
diff --git a/hw/virtio/virtio-pci.c b/hw/virtio/virtio-pci.c
index 1e8ab7bbc5..e15a3a5a2e 100644
--- a/hw/virtio/virtio-pci.c
+++ b/hw/virtio/virtio-pci.c
@@ -2501,6 +2501,49 @@ static const TypeInfo virtio_rng_pci_info = {
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
@@ -2693,6 +2736,7 @@ static void virtio_pci_register_types(void)
     type_register_static(&virtio_balloon_pci_info);
     type_register_static(&virtio_serial_pci_info);
     type_register_static(&virtio_net_pci_info);
+    type_register_static(&virtio_pmem_pci_info);
 #ifdef CONFIG_VHOST_SCSI
     type_register_static(&vhost_scsi_pci_info);
 #endif
diff --git a/hw/virtio/virtio-pci.h b/hw/virtio/virtio-pci.h
index 813082b0d7..fe74fcad3f 100644
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
@@ -57,6 +58,7 @@ typedef struct VirtIOInputHostPCI VirtIOInputHostPCI;
 typedef struct VirtIOGPUPCI VirtIOGPUPCI;
 typedef struct VHostVSockPCI VHostVSockPCI;
 typedef struct VirtIOCryptoPCI VirtIOCryptoPCI;
+typedef struct VirtIOPMEMPCI VirtIOPMEMPCI;
 
 /* virtio-pci-bus */
 
@@ -274,6 +276,18 @@ struct VirtIOBlkPCI {
     VirtIOBlock vdev;
 };
 
+/*
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
 /*
  * virtio-balloon-pci: This extends VirtioPCIProxy.
  */
diff --git a/hw/virtio/virtio-pmem.c b/hw/virtio/virtio-pmem.c
new file mode 100644
index 0000000000..70d3697423
--- /dev/null
+++ b/hw/virtio/virtio-pmem.c
@@ -0,0 +1,197 @@
+/*
+ * Virtio pmem device
+ */
+
+#include "qemu/osdep.h"
+#include "qapi/error.h"
+#include "qemu-common.h"
+#include "qemu/error-report.h"
+#include "hw/virtio/virtio-pmem.h"
+#include "hw/mem/memory-device.h"
+
+static void virtio_pmem_flush(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtQueueElement *elem;
+    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
+    HostMemoryBackend *backend = MEMORY_BACKEND(pmem->memdev);
+    int fd = memory_region_get_fd(&backend->mr);
+
+    elem = virtqueue_pop(vq, sizeof(VirtQueueElement));
+    if (!elem) {
+        return;
+    }
+    /* flush raw backing image */
+    fsync(fd);
+
+    virtio_notify(vdev, vq);
+    g_free(elem);
+
+}
+
+static void virtio_pmem_get_config(VirtIODevice *vdev, uint8_t *config)
+{
+    VirtIOPMEM *pmem = VIRTIO_PMEM(vdev);
+    struct virtio_pmem_config *pmemcfg = (struct virtio_pmem_config *) config;
+
+    pmemcfg->start = pmem->start;
+    pmemcfg->size  = pmem->size;
+}
+
+static uint64_t virtio_pmem_get_features(VirtIODevice *vdev, uint64_t features,
+                                        Error **errp)
+{
+    virtio_add_feature(&features, VIRTIO_PMEM_PLUG);
+    return features;
+}
+
+static void virtio_pmem_realize(DeviceState *dev, Error **errp)
+{
+    VirtIODevice   *vdev   = VIRTIO_DEVICE(dev);
+    VirtIOPMEM     *pmem   = VIRTIO_PMEM(dev);
+    MachineState   *ms     = MACHINE(qdev_get_machine());
+    uint64_t align;
+
+    Error *local_err = NULL;
+    MemoryRegion *mr;
+
+    if (!pmem->memdev) {
+        error_setg(errp, "virtio-pmem memdev not set");
+        return;
+    }
+
+    mr  = host_memory_backend_get_memory(pmem->memdev, errp);
+    align = memory_region_get_alignment(mr);
+    pmem->size = QEMU_ALIGN_DOWN(memory_region_size(mr), align);
+    pmem->start = memory_device_get_free_addr(ms, NULL, align, pmem->size,
+                                                               &local_err);
+
+    if (local_err) {
+        error_setg(errp, "Can't get free address in mem device");
+        return;
+    }
+
+    memory_region_init_alias(&pmem->mr, OBJECT(pmem),
+                             "virtio_pmem-memory", mr, 0, pmem->size);
+    memory_device_plug_region(ms, &pmem->mr, pmem->start);
+
+    host_memory_backend_set_mapped(pmem->memdev, true);
+    virtio_init(vdev, TYPE_VIRTIO_PMEM, VIRTIO_ID_PMEM,
+                sizeof(struct virtio_pmem_config));
+
+    pmem->rq_vq = virtio_add_queue(vdev, 128, virtio_pmem_flush);
+}
+
+static void virtio_mem_check_memdev(Object *obj, const char *name, Object *val,
+                                    Error **errp)
+{
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
+static const char *virtio_pmem_get_device_id(VirtIOPMEM *vm)
+{
+    Object *obj = OBJECT(vm);
+    DeviceState *parent_dev;
+
+    /* always use the ID of the proxy device */
+    if (obj->parent && object_dynamic_cast(obj->parent, TYPE_DEVICE)) {
+        parent_dev = DEVICE(obj->parent);
+        return parent_dev->id;
+    }
+    return NULL;
+}
+
+
+static void virtio_pmem_md_fill_device_info(const MemoryDeviceState *md,
+                                           MemoryDeviceInfo *info)
+{
+    VirtioPMemDeviceInfo *vi = g_new0(VirtioPMemDeviceInfo, 1);
+    VirtIOPMEM *vm = VIRTIO_PMEM(md);
+
+    const char *id = virtio_pmem_get_device_id(vm);
+
+    if (id) {
+        vi->has_id = true;
+        vi->id = g_strdup(id);
+    }
+
+    vi->start = vm->start;
+    vi->size = vm->size;
+    vi->memdev = object_get_canonical_path(OBJECT(vm->memdev));
+
+    info->u.virtio_pmem.data = vi;
+    info->type = MEMORY_DEVICE_INFO_KIND_VIRTIO_PMEM;
+}
+
+static uint64_t virtio_pmem_md_get_addr(const MemoryDeviceState *md)
+{
+    VirtIOPMEM *vm = VIRTIO_PMEM(md);
+
+    return vm->start;
+}
+
+static uint64_t virtio_pmem_md_get_plugged_size(const MemoryDeviceState *md)
+{
+    VirtIOPMEM *vm = VIRTIO_PMEM(md);
+
+    return vm->size;
+}
+
+static uint64_t virtio_pmem_md_get_region_size(const MemoryDeviceState *md)
+{
+    VirtIOPMEM *vm = VIRTIO_PMEM(md);
+
+    return vm->size;
+}
+
+static void virtio_pmem_instance_init(Object *obj)
+{
+    VirtIOPMEM *vm = VIRTIO_PMEM(obj);
+    object_property_add_link(obj, "memdev", TYPE_MEMORY_BACKEND,
+                             (Object **)&vm->memdev,
+                             (void *) virtio_mem_check_memdev,
+                             OBJ_PROP_LINK_UNREF_ON_RELEASE,
+                             &error_abort);
+}
+
+
+static void virtio_pmem_class_init(ObjectClass *klass, void *data)
+{
+    VirtioDeviceClass *vdc = VIRTIO_DEVICE_CLASS(klass);
+    MemoryDeviceClass *mdc = MEMORY_DEVICE_CLASS(klass);
+
+    vdc->realize      =  virtio_pmem_realize;
+    vdc->get_config   =  virtio_pmem_get_config;
+    vdc->get_features =  virtio_pmem_get_features;
+
+    mdc->get_addr         = virtio_pmem_md_get_addr;
+    mdc->get_plugged_size = virtio_pmem_md_get_plugged_size;
+    mdc->get_region_size  = virtio_pmem_md_get_region_size;
+    mdc->fill_device_info = virtio_pmem_md_fill_device_info;
+}
+
+static TypeInfo virtio_pmem_info = {
+    .name          = TYPE_VIRTIO_PMEM,
+    .parent        = TYPE_VIRTIO_DEVICE,
+    .class_init    = virtio_pmem_class_init,
+    .instance_size = sizeof(VirtIOPMEM),
+    .instance_init = virtio_pmem_instance_init,
+    .interfaces = (InterfaceInfo[]) {
+        { TYPE_MEMORY_DEVICE },
+        { }
+  },
+};
+
+static void virtio_register_types(void)
+{
+    type_register_static(&virtio_pmem_info);
+}
+
+type_init(virtio_register_types)
diff --git a/include/hw/pci/pci.h b/include/hw/pci/pci.h
index a9c3ee5aa2..df26e204ce 100644
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
index 0000000000..a8d017beca
--- /dev/null
+++ b/include/hw/virtio/virtio-pmem.h
@@ -0,0 +1,44 @@
+/*
+ * Virtio pmem Device
+ *
+ * PV device to emulate nvdimm memory.
+ * Provides guest flushing interface based
+ * on VIRTIO.
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
+/* VirtIOPMEM device structure */
+typedef struct VirtIOPMEM {
+
+    VirtIODevice parent_obj;
+    VirtQueue *rq_vq;
+    uint64_t start;
+    uint64_t size;
+
+    MemoryRegion mr;
+    HostMemoryBackend *memdev;
+} VirtIOPMEM;
+
+struct virtio_pmem_config {
+
+    uint64_t start;
+    uint64_t size;
+};
+
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
diff --git a/qapi/misc.json b/qapi/misc.json
index 5636f4a149..29a00b27d7 100644
--- a/qapi/misc.json
+++ b/qapi/misc.json
@@ -2871,6 +2871,29 @@
           }
 }
 
+##
+# @VirtioPMemDeviceInfo:
+#
+# VirtioPMem state information
+#
+# @id: device's ID
+#
+# @start: physical address, where device is mapped
+#
+# @size: size of memory that the device provides
+#
+# @memdev: memory backend linked with device
+#
+# Since: 2.13
+##
+{ 'struct': 'VirtioPMemDeviceInfo',
+    'data': { '*id': 'str',
+	      'start': 'size',
+	      'size': 'size',
+              'memdev': 'str'
+	    }
+}
+
 ##
 # @MemoryDeviceInfo:
 #
@@ -2880,7 +2903,8 @@
 ##
 { 'union': 'MemoryDeviceInfo',
   'data': { 'dimm': 'PCDIMMDeviceInfo',
-            'nvdimm': 'PCDIMMDeviceInfo'
+            'nvdimm': 'PCDIMMDeviceInfo',
+	    'virtio-pmem': 'VirtioPMemDeviceInfo'
           }
 }
 
-- 
2.14.3
