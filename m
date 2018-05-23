Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7376B000D
	for <linux-mm@kvack.org>; Wed, 23 May 2018 14:24:25 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c20-v6so23283271qkm.13
        for <linux-mm@kvack.org>; Wed, 23 May 2018 11:24:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t63-v6si3660962qkc.142.2018.05.23.11.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 11:24:23 -0700 (PDT)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH RFCv2 4/4] virtio-mem: paravirtualized memory
Date: Wed, 23 May 2018 20:24:04 +0200
Message-Id: <20180523182404.11433-5-david@redhat.com>
In-Reply-To: <20180523182404.11433-1-david@redhat.com>
References: <20180523182404.11433-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, Stefan Hajnoczi <stefanha@redhat.com>, Cornelia Huck <cohuck@redhat.com>, Halil Pasic <pasic@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Thomas Gleixner <tglx@linutronix.de>

Each virtio-mem device owns exactly one memory region. It is responsible
for adding/removing memory from that memory region on request in a
certain fixed chunk size.

When the device driver starts up, the requested amount of memory is
queried and then added to Linux. On request, further memory can be added
or removed.

We add memory using add_memory() on a section basis (e.g. 128MB) but
keep it offline. We can then online/offline e.g. 4MB chunks from such a
section, which basically means adding/removing 4MB from Linux and
therefore the guest.

Memory is always onlined as ONLINE, not ONLINE_MOVABLE. We might decide
to automatically manage the assignment to specific zones later on
(which will require some work in the zone and memory offline/removal code).
Having small chunks (e.g. 4MB) compared to bigger chunks (e.g. 128MB) makes
it more likely for memore hotunplug to succeed, however a single page
(out of 1024) on a 4MB block can hinder it from being able to be offlined.
Compared to a typical balloon, we avoid any memory fragmentation.

Another future implementation could be to also support smaller chunks of
memory (e.g. 1MB or 256k), which would be a good compromise between being
able to unplug more memory (from !MOVABLE zone) and avoiding memory
fragmentation. The existing virtio protocol supports this extension, but
for now 4MB seem to be possible without a lot of messing around in Linux
mm code.

Once all chunks of a section are offline, we can go ahead and remove the
memory again using remove_memory(). This also removes the "struct
pages", which is nice.

Each virtio-mem device can belong to a NUMA node, which allows us to
easily add/remove small chunks of memory to/from a specific NUMA node by
using multiple virtio-mem devices. Something that works even when the
guest has no idea about the NUMA topology, but the host does - something
that can easily happen in cloud environments.

One way to view virtio-mem is as a "resizable DIMM" or a DIMM with many
"sub-DIMMS". Right now, x86 and s390x are supported.

Driver/Device removal: Whenever the device is removed/reset, all device
		       memory is no longer accessible. This is
		       problematic, as we cannot simply remove all
		       memory using remove_memory() from Linux.

Suspend/Hypernate: Only supported if no device memory is plugged. When
                   the device is reset, all device memory is no longer
		   accessible. See "Driver/Device removal".

Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Cornelia Huck <cohuck@redhat.com>
Cc: Halil Pasic <pasic@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/virtio/Kconfig          |   15 +
 drivers/virtio/Makefile         |    1 +
 drivers/virtio/virtio_mem.c     | 1040 +++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_ids.h |    1 +
 include/uapi/linux/virtio_mem.h |  134 ++++
 5 files changed, 1191 insertions(+)
 create mode 100644 drivers/virtio/virtio_mem.c
 create mode 100644 include/uapi/linux/virtio_mem.h

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 35897649c24f..39d3bcb2546b 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -52,6 +52,21 @@ config VIRTIO_BALLOON
 
 	 If unsure, say M.
 
+config VIRTIO_MEM
+	tristate "Virtio mem driver"
+	depends on VIRTIO && MEMORY_HOTPLUG && MEMORY_HOTREMOVE && (X86_64 || S390)
+	help
+	 Virtio Mem driver
+
+	 This driver provides access to virtio-mem paravirtualized memory
+	 devices.
+
+	 This driver is experimental and was only tested under s390x and x86_64.
+	 In theory, all architectures that support add_memory/remove_memory
+	 and a reasonably large address space should be supported.
+
+	 If unsure, say M.
+
 config VIRTIO_INPUT
 	tristate "Virtio input driver"
 	depends on VIRTIO
diff --git a/drivers/virtio/Makefile b/drivers/virtio/Makefile
index 3a2b5c5dcf46..906d5a00ac85 100644
--- a/drivers/virtio/Makefile
+++ b/drivers/virtio/Makefile
@@ -6,3 +6,4 @@ virtio_pci-y := virtio_pci_modern.o virtio_pci_common.o
 virtio_pci-$(CONFIG_VIRTIO_PCI_LEGACY) += virtio_pci_legacy.o
 obj-$(CONFIG_VIRTIO_BALLOON) += virtio_balloon.o
 obj-$(CONFIG_VIRTIO_INPUT) += virtio_input.o
+obj-$(CONFIG_VIRTIO_MEM) += virtio_mem.o
diff --git a/drivers/virtio/virtio_mem.c b/drivers/virtio/virtio_mem.c
new file mode 100644
index 000000000000..195c93864f3c
--- /dev/null
+++ b/drivers/virtio/virtio_mem.c
@@ -0,0 +1,1040 @@
+// SPDX-License-Identifier: GPL-2.0+
+/*
+ * Virtio Mem implementation
+ *
+ * Copyright Red Hat, Inc. 2018
+ *
+ * Authors:
+ *     David Hildenbrand <david@redhat.com>
+ */
+#include <linux/virtio.h>
+#include <linux/virtio_mem.h>
+#include <linux/workqueue.h>
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/memory_hotplug.h>
+#include <linux/memory.h>
+#include <linux/bitmap.h>
+#include <linux/hrtimer.h>
+
+#if defined(CONFIG_NUMA) && defined(CONFIG_ACPI_NUMA)
+#include <acpi/acpi_numa.h>
+#endif
+
+struct virtio_mem {
+	struct virtio_device *vdev;
+
+	/* Workqueue for config updates */
+	struct work_struct config_wq;
+	atomic_t config_changed;
+
+	/* Queue for guest->host requests */
+	struct virtqueue *vq;
+
+	/* Space for one request and its response (to avoid extra allocs) */
+	struct virtio_mem_req req;
+	struct virtio_mem_resp resp;
+
+	/* Waiting for host response to our request */
+	wait_queue_head_t host_resp;
+
+	/* Device properties from virtio-mem config */
+	struct virtio_mem_config cfg;
+
+	/* Node of this device - NUMA_NO_NODE if undefined */
+	int node;
+
+	/*
+	 * The size we use for add_memory/remove_memory. We try to make this
+	 * as small as possible (e.g. memory_block_size_bytes()), however
+	 * we can get multiple Linux memory blocks per virtio-mem memory
+	 * block (for really huge virtio-mem block sizes).
+	 */
+	uint32_t block_size;
+
+	/*
+	 * The size we use for online_pages/offline_pages, when unplugging
+	 * only parts of a Linux memory block. We try to make this as small
+	 * as possible, however we cannot go below the virtio-mem memory
+	 * block size and offline_nr_pages. Also, we limit the number sub
+	 * blocks per block to a reasonable size right now (max 64).
+	 */
+	uint32_t sub_block_size;
+	uint32_t nb_sub_blocks;
+
+	/* The region size for which we allocated block infos */
+	uint64_t processed_region_size;
+
+	/* List of blocks that are completely online */
+	struct list_head online;
+	/* List of blocks that are partially online */
+	struct list_head online_offline;
+	/* List of blocks that are offline (and require add_memory()) */
+	struct list_head offline;
+
+	/*
+	 * At most one block to remember and process first, if we failed
+	 * to unplug sub blocks.
+	 */
+	struct list_head failed_unplug;
+	int failed_unplug_offset;
+	int failed_unplug_count;
+
+	/* an error ocurred we cannot handle - stop processing requests */
+	bool broken;
+
+	/* the driver is being removed */
+	spinlock_t removal_lock;
+	bool removing;
+
+	/* timer for retrying to plug/unplug memory */
+	struct hrtimer retry_timer;
+	ktime_t retry_interval;
+#define VIRTIO_MEM_RETRY_MS		10000
+};
+
+/**
+ * struct virtio_mem_block_info - info about a memory block
+ * @addr:	The physical start address of the memory blocks.
+ * @online:	Bitmap storing which parts of the memory block are online.
+ * @next:	List head to store the infos in online/offline lists.
+ */
+struct virtio_mem_block_info {
+	uint64_t addr;
+#define MAX_NB_SUB_BLOCKS	64
+	DECLARE_BITMAP(online, MAX_NB_SUB_BLOCKS);
+	struct list_head next;
+};
+
+/**
+ * virtio_mem_translate_node_id() - translate a node id to a valid node
+ * @vm:		The virtio-mem device.
+ * @node_id:	The node_id indicated in the device config.
+ *
+ * Translate the node id from the device config to a valid node, or
+ * NUMA_NO_NODE if NUMA is not enabled or the node id cannot be translated.
+ *
+ * Return: A node.
+ */
+static int virtio_mem_translate_node_id(const struct virtio_mem *vm,
+					uint16_t node_id)
+{
+	int node = NUMA_NO_NODE;
+#if defined(CONFIG_NUMA) && defined(CONFIG_ACPI_NUMA)
+	if (virtio_has_feature(vm->vdev, VIRTIO_MEM_F_ACPI_NODE_ID))
+		node = pxm_to_node(node_id);
+#endif
+	return node;
+}
+
+/**
+ * virtio_mem_send_request() - send a request to the device
+ * @vm:		The virtio-mem device.
+ * @req:	The request to send.
+ *
+ * Send the request and wait for a response.
+ *
+ * Return: Negative error value in case of errors, otherwise a virtio-mem
+ *         response type.
+ */
+static uint64_t virtio_mem_send_request(struct virtio_mem *vm,
+					const struct virtio_mem_req *req)
+{
+	struct scatterlist *sgs[2], sg_req, sg_resp;
+	unsigned int len;
+	int rc;
+
+	vm->req = *req;
+
+	/* out: buffer for request */
+	sg_init_one(&sg_req, &vm->req, sizeof(vm->req));
+	sgs[0] = &sg_req;
+
+	/* in: buffer for response */
+	sg_init_one(&sg_resp, &vm->resp, sizeof(vm->resp));
+	sgs[1] = &sg_resp;
+
+	rc = virtqueue_add_sgs(vm->vq, sgs, 1, 1, vm, GFP_KERNEL);
+	if (rc < 0)
+		return rc;
+
+	virtqueue_kick(vm->vq);
+
+	/* wait for a response */
+	wait_event(vm->host_resp, virtqueue_get_buf(vm->vq, &len));
+
+	return virtio16_to_cpu(vm->vdev, vm->resp.type);
+}
+
+/**
+ * virtio_mem_send_plug_request() - try to plug the given memory blocks
+ * @vm:      The virtio-mem device.
+ * @addr:    The start of the memory blocks
+ * @size:    The size of the memory blocks
+ *
+ * Request to plug the memory blocks that are currently unplugged.
+ *
+ * Return: Negative error value in case of errors, otherwise 0.
+ */
+static int virtio_mem_send_plug_request(struct virtio_mem *vm, uint64_t addr,
+					uint64_t size)
+{
+	const uint64_t nb_vm_blocks = size / vm->cfg.block_size;
+	const struct virtio_mem_req req = {
+		.type = cpu_to_virtio16(vm->vdev, VIRTIO_MEM_REQ_PLUG),
+		.u.plug.addr = cpu_to_virtio64(vm->vdev, addr),
+		.u.plug.nb_blocks = cpu_to_virtio16(vm->vdev, nb_vm_blocks),
+	};
+
+	BUG_ON(!IS_ALIGNED(addr, vm->cfg.block_size));
+	BUG_ON(!IS_ALIGNED(size, vm->cfg.block_size));
+
+	if (atomic_read(&vm->config_changed))
+		return -EAGAIN;
+
+	switch (virtio_mem_send_request(vm, &req)) {
+	case VIRTIO_MEM_RESP_ACK:
+		/* we don't get (and want) a config update for this change */
+		vm->cfg.size += size;
+		return 0;
+	case VIRTIO_MEM_RESP_NACK:
+		return -EAGAIN;
+	case VIRTIO_MEM_RESP_RETRY:
+		return -EBUSY;
+	case VIRTIO_MEM_RESP_ERROR:
+		return -EINVAL;
+	default:
+		return -ENOMEM;
+	}
+}
+
+/**
+ * virtio_mem_send_unplug_request() - try to unplug the given memory blocks
+ * @vm:      The virtio-mem device.
+ * @addr:    The start of the memory blocks
+ * @size:    The size of the memory blocks
+ *
+ * Request to unplug the memory blocks that are currently plugged.
+ *
+ * If this function returns 0, all memory blocks were unplugged.
+ *
+ * Return: Negative error value in case of errors, otherwise 0.
+ */
+static int virtio_mem_send_unplug_request(struct virtio_mem *vm, uint64_t addr,
+					  uint64_t size)
+{
+	const uint64_t nb_vm_blocks = size / vm->cfg.block_size;
+	const struct virtio_mem_req req = {
+		.type = cpu_to_virtio16(vm->vdev, VIRTIO_MEM_REQ_UNPLUG),
+		.u.unplug.addr = cpu_to_virtio64(vm->vdev, addr),
+		.u.unplug.nb_blocks = cpu_to_virtio16(vm->vdev, nb_vm_blocks),
+	};
+
+	BUG_ON(!IS_ALIGNED(addr, vm->cfg.block_size));
+	BUG_ON(!IS_ALIGNED(size, vm->cfg.block_size));
+
+	if (atomic_read(&vm->config_changed))
+		return -EAGAIN;
+
+	switch (virtio_mem_send_request(vm, &req)) {
+	case VIRTIO_MEM_RESP_ACK:
+		/* we don't get (and want) a config update for this change */
+		vm->cfg.size -= size;
+		return 0;
+	case VIRTIO_MEM_RESP_NACK:
+		return -EAGAIN;
+	case VIRTIO_MEM_RESP_RETRY:
+		return -EBUSY;
+	case VIRTIO_MEM_RESP_ERROR:
+		return -EINVAL;
+	default:
+		return -ENOMEM;
+	}
+}
+
+static int virtio_mem_add_memory_block(struct virtio_mem *vm,
+				       struct virtio_mem_block_info *bi)
+{
+	int node = vm->node;
+	int rc;
+
+	BUG_ON(!bitmap_empty(bi->online, vm->nb_sub_blocks));
+
+	if (node == NUMA_NO_NODE)
+		node = memory_add_physaddr_to_nid(bi->addr);
+
+	/* we only expect lack of memory when trying to add new memory */
+	rc = add_memory_driver_managed(node, bi->addr, vm->block_size);
+	if (rc == -ENOMEM)
+		return -ENOMEM;
+	if (WARN_ON_ONCE(rc))
+		return -EINVAL;
+
+	mem_hotplug_begin();
+	/* Mark the memblocks as online */
+	online_memory_blocks(bi->addr, vm->block_size);
+	mem_hotplug_done();
+
+	return 0;
+}
+
+static void virtio_mem_remove_memory_block(struct virtio_mem *vm,
+					   struct virtio_mem_block_info *bi)
+{
+	int node = vm->node;
+
+	BUG_ON(!bitmap_empty(bi->online, vm->nb_sub_blocks));
+
+	mem_hotplug_begin();
+	/* Mark the memblocks as offline (to make remove_memory() work) */
+	offline_memory_blocks(bi->addr, vm->block_size);
+	mem_hotplug_done();
+
+	if (node == NUMA_NO_NODE)
+		node = memory_add_physaddr_to_nid(bi->addr);
+
+	remove_memory(node, bi->addr, vm->block_size);
+}
+
+static int virtio_mem_online_range(struct virtio_mem *vm, uint64_t addr,
+				   uint64_t size)
+{
+	const uint64_t pages = size / PAGE_SIZE;
+	int rc;
+
+	BUG_ON(!IS_ALIGNED(size, PAGE_SIZE));
+	BUG_ON(!IS_ALIGNED(size, vm->sub_block_size));
+
+	mem_hotplug_begin();
+	rc = online_pages(addr >> PAGE_SHIFT, pages, MMOP_ONLINE_KERNEL);
+	mem_hotplug_done();
+
+	if (rc == -ENOMEM)
+		return rc;
+	if (WARN_ON_ONCE(rc))
+		return -EINVAL;
+	return 0;
+}
+
+static int virtio_mem_offline_range(struct virtio_mem *vm, uint64_t addr,
+				    uint64_t size)
+{
+	const uint64_t pages = size / PAGE_SIZE;
+	int rc;
+
+	if (!is_mem_section_removable(addr >> PAGE_SHIFT, size / PAGE_SIZE))
+		return -ENOSPC;
+
+	mem_hotplug_begin();
+	rc = offline_pages(addr >> PAGE_SHIFT, pages, false);
+	mem_hotplug_done();
+
+	if (rc == -EBUSY)
+		return -ENOSPC;
+	/* TODO: offline_pages() should indicate -ENOMEM more reliably */
+	if (rc == -ENOMEM)
+		return -ENOMEM;
+	if (WARN_ON_ONCE(rc))
+		return -EINVAL;
+	return 0;
+}
+
+static int virtio_mem_plug_and_online(struct virtio_mem *vm,
+				      struct virtio_mem_block_info *bi,
+				      int offset, int count)
+{
+	const uint64_t addr = bi->addr + offset * vm->sub_block_size;
+	const uint64_t size = count * vm->sub_block_size;
+	int rc, rc2;
+
+	BUG_ON(test_bit(offset, bi->online));
+	BUG_ON(test_bit(offset + count - 1, bi->online));
+
+	rc = virtio_mem_send_plug_request(vm, addr, size);
+	if (rc)
+		return rc;
+
+	rc = virtio_mem_online_range(vm, addr, size);
+	if (rc) {
+		/* try to unplug, this however can now fail, too */
+		rc2 = virtio_mem_send_unplug_request(vm, addr, size);
+		if (!rc2)
+			return rc;
+		/* We cannot proceed before completing this block */
+		vm->failed_unplug_offset = offset;
+		vm->failed_unplug_count = count;
+		BUG_ON(!list_empty(&vm->failed_unplug));
+		list_move_tail(&bi->next, &vm->failed_unplug);
+		return rc2;
+	}
+
+	/* memory is definetly online */
+	bitmap_set(bi->online, offset, count);
+	return 0;
+}
+
+static int virtio_mem_offline_and_unplug(struct virtio_mem *vm,
+					 struct virtio_mem_block_info *bi,
+					 int offset, int count)
+{
+	const uint64_t addr = bi->addr + offset * vm->sub_block_size;
+	const uint64_t size = count * vm->sub_block_size;
+	int rc;
+
+	BUG_ON(!test_bit(offset, bi->online));
+	BUG_ON(!test_bit(offset + count - 1, bi->online));
+
+	rc = virtio_mem_offline_range(vm, addr, size);
+	if (rc)
+		return rc;
+
+	/* memory is definetly offline */
+	bitmap_clear(bi->online, offset, count);
+
+	rc = virtio_mem_send_unplug_request(vm, addr, size);
+	if (rc) {
+		/* We cannot proceed before completing this unplug */
+		vm->failed_unplug_offset = offset;
+		vm->failed_unplug_count = count;
+		BUG_ON(!list_empty(&vm->failed_unplug));
+		list_move_tail(&bi->next, &vm->failed_unplug);
+		return rc;
+	}
+	return 0;
+}
+
+static int virtio_mem_offline_and_unplug_block(struct virtio_mem *vm,
+					       struct virtio_mem_block_info *bi,
+					       uint64_t *nb_sub_blocks)
+{
+	int bit;
+	int rc = 0;
+
+	/* TODO: try to combine */
+	bit = find_first_bit(bi->online, vm->nb_sub_blocks);
+	BUG_ON(bit >= vm->nb_sub_blocks);
+	while (bit < vm->nb_sub_blocks) {
+		rc = virtio_mem_offline_and_unplug(vm, bi, bit, 1);
+		if (!rc)
+			(*nb_sub_blocks)--;
+		else if (rc != -ENOSPC)
+			break;
+		if (!*nb_sub_blocks)
+			break;
+
+		bit = find_next_bit(bi->online, vm->nb_sub_blocks, bit + 1);
+	}
+
+	/* properly remove the block if nothing is online*/
+	if (bitmap_empty(bi->online, vm->nb_sub_blocks))
+		virtio_mem_remove_memory_block(vm, bi);
+
+	return rc;
+}
+
+/* we might have blocks that can only partially be plugged */
+static bool virtio_mem_is_sub_block_valid(struct virtio_mem *vm,
+					  struct virtio_mem_block_info *bi,
+					  int nr)
+{
+	const uint64_t subblock_end = bi->addr + vm->sub_block_size * (nr + 1);
+	const uint64_t usable_region_end = vm->cfg.start_addr +
+					   vm->cfg.usable_region_size;
+
+	return subblock_end <= usable_region_end;
+}
+
+static int virtio_mem_pluggable_sub_blocks(struct virtio_mem *vm,
+					   struct virtio_mem_block_info *bi,
+					   int *offset, int *count)
+{
+	int bit;
+
+	if (bitmap_full(bi->online, vm->nb_sub_blocks))
+		return 1;
+
+	if (bitmap_empty(bi->online, vm->nb_sub_blocks) &&
+	    virtio_mem_is_sub_block_valid(vm, bi, vm->nb_sub_blocks - 1)) {
+		*offset = 0;
+		*count = vm->nb_sub_blocks;
+		return 0;
+	}
+
+	*count = 0;
+	bit = find_first_zero_bit(bi->online, vm->nb_sub_blocks);
+	*offset = bit;
+
+	while (bit < vm->nb_sub_blocks) {
+		if (!virtio_mem_is_sub_block_valid(vm, bi, bit))
+			break;
+		(*count)++;
+		bit++;
+		if (test_bit(bit, bi->online))
+			break;
+	}
+	return *count ? 0 : 1;
+}
+
+static int virtio_mem_plug_and_online_block(struct virtio_mem *vm,
+					    struct virtio_mem_block_info *bi,
+					    uint64_t *nb_sub_blocks)
+{
+	int offset, count;
+	int rc = 0;
+
+	if (bitmap_empty(bi->online, vm->nb_sub_blocks)) {
+		/* we have to add the block to MM first */
+		rc = virtio_mem_add_memory_block(vm, bi);
+		if (rc)
+			return rc;
+	}
+
+	while (!virtio_mem_pluggable_sub_blocks(vm, bi, &offset, &count)) {
+		count = min_t(int, count, (int) *nb_sub_blocks);
+		rc = virtio_mem_plug_and_online(vm, bi, offset, count);
+		if (rc)
+			break;
+		*nb_sub_blocks -= count;
+		if (!*nb_sub_blocks)
+			break;
+	}
+
+	/* properly remove the block if nothing is online */
+	if (bitmap_empty(bi->online, vm->nb_sub_blocks))
+		virtio_mem_remove_memory_block(vm, bi);
+
+	return rc;
+}
+
+static int virtio_mem_allocate_block_info(struct virtio_mem *vm)
+{
+	const uint64_t phys_limit = 1UL << MAX_PHYSMEM_BITS;
+	const uint64_t region_end = vm->cfg.start_addr + vm->cfg.region_size;
+	const uint64_t usable_region_end = vm->cfg.start_addr +
+					   vm->cfg.usable_region_size;
+	uint64_t block_start, block_end, sub_block_end;
+	struct virtio_mem_block_info *bi;
+
+	/* We can use add_memory() only with sane alignment. */
+	block_start = round_up(vm->cfg.start_addr + vm->processed_region_size,
+			       vm->block_size);
+	block_end = block_start + vm->block_size;
+	sub_block_end = block_start + vm->sub_block_size;
+
+	/* If we could exceed the physical limit with this block, stop. */
+	if (block_end > phys_limit)
+		return -ENOSPC;
+
+	/*
+	 * We can use add_memory() only if we don't exceed the region size.
+	 * Otherwise we could conflict with other devices/DIMMs).
+	 */
+	if (block_end > region_end)
+		return -ENOSPC;
+
+	/* create only if we can online at least one sub block */
+	if (sub_block_end > usable_region_end)
+		return -ENOSPC;
+
+	bi = kzalloc(sizeof(*bi), GFP_KERNEL);
+	if (!bi)
+		return -ENOMEM;
+
+	bi->addr = block_start;
+	list_add_tail(&bi->next, &vm->offline);
+	vm->processed_region_size = block_end - vm->cfg.start_addr;
+	return 0;
+}
+
+static int virtio_mem_offline_and_unplug_size(struct virtio_mem *vm,
+					      uint64_t diff)
+{
+	uint64_t nb_sub_blocks = diff / vm->sub_block_size;
+	struct virtio_mem_block_info *cur, *n;
+	int rc;
+
+	list_for_each_entry_safe(cur, n, &vm->online_offline, next) {
+		rc = virtio_mem_offline_and_unplug_block(vm, cur,
+							 &nb_sub_blocks);
+		BUG_ON(!list_empty(&vm->failed_unplug) && !rc);
+
+		/* don't modify lists if we have a failed unplug */
+		if (list_empty(&vm->failed_unplug) &&
+		    bitmap_empty(cur->online, vm->nb_sub_blocks))
+			list_move_tail(&cur->next, &vm->offline);
+
+		if (!nb_sub_blocks)
+			return 0;
+		/* continue as long we get no serious errors */
+		if (rc && rc != -ENOSPC)
+			return rc;
+		cond_resched();
+	}
+	list_for_each_entry_safe(cur, n, &vm->online, next) {
+		rc = virtio_mem_offline_and_unplug_block(vm, cur, &nb_sub_blocks);
+		BUG_ON(!list_empty(&vm->failed_unplug) && !rc);
+
+		/* don't modify lists if we have a failed unplug */
+		if (list_empty(&vm->failed_unplug)) {
+			if (bitmap_empty(cur->online, vm->nb_sub_blocks))
+				list_move_tail(&cur->next, &vm->offline);
+			else if (!bitmap_empty(cur->online, vm->nb_sub_blocks))
+				list_move_tail(&cur->next, &vm->online_offline);
+		}
+
+		/* continue as long we get no serious errors */
+		if (rc && rc != -ENOSPC)
+			return rc;
+		if (!nb_sub_blocks)
+			return 0;
+		cond_resched();
+	}
+
+	/* not everything offline? */
+	if (nb_sub_blocks)
+		return -ENOSPC;
+
+	return 0;
+}
+
+static int virtio_mem_plug_and_online_size(struct virtio_mem *vm, uint64_t diff)
+{
+	uint64_t nb_sub_blocks = diff / vm->sub_block_size;
+	struct virtio_mem_block_info *cur, *n;
+	int rc;
+
+	list_for_each_entry_safe(cur, n, &vm->online_offline, next) {
+		rc = virtio_mem_plug_and_online_block(vm, cur, &nb_sub_blocks);
+		BUG_ON(!list_empty(&vm->failed_unplug) && !rc);
+
+		/* don't modify lists if we have a failed unplug */
+		if (list_empty(&vm->failed_unplug) &&
+		    bitmap_full(cur->online, vm->nb_sub_blocks))
+			list_move_tail(&cur->next, &vm->online);
+
+		if (rc)
+			return rc;
+		if (!nb_sub_blocks)
+			return 0;
+		cond_resched();
+	}
+
+retry:
+	list_for_each_entry_safe(cur, n, &vm->offline, next) {
+		rc = virtio_mem_plug_and_online_block(vm, cur, &nb_sub_blocks);
+		BUG_ON(!list_empty(&vm->failed_unplug) && !rc);
+
+		/* don't modify lists if we have a failed unplug */
+		if (list_empty(&vm->failed_unplug)) {
+			if (bitmap_full(cur->online, vm->nb_sub_blocks))
+				list_move_tail(&cur->next, &vm->online);
+			else if (!bitmap_empty(cur->online, vm->nb_sub_blocks))
+				list_move_tail(&cur->next, &vm->online_offline);
+		}
+
+		if (rc)
+			return rc;
+		if (!nb_sub_blocks)
+			return 0;
+		cond_resched();
+	}
+	/* maybe we have not covered the whole usable_region_size yet */
+	rc = virtio_mem_allocate_block_info(vm);
+	if (!rc)
+		goto retry;
+	else if (rc == -ENOSPC)
+		/* we need a config update before we can try again */
+		return 0;
+	return rc;
+}
+
+static int virtio_mem_process_failed_unplug_request(struct virtio_mem *vm)
+{
+	struct virtio_mem_block_info *bi;
+	uint64_t addr, size;
+	int rc;
+
+	if (list_empty(&vm->failed_unplug))
+		return 0;
+
+	bi = list_first_entry(&vm->failed_unplug, typeof(*bi), next);
+	addr = bi->addr + vm->failed_unplug_offset * vm->sub_block_size;
+	size = vm->failed_unplug_count * vm->sub_block_size;
+
+	rc = virtio_mem_send_unplug_request(vm, addr, size);
+	if (rc)
+		return rc;
+
+	/* unplug request processed, move it to the right list */
+	if (bitmap_empty(bi->online, vm->nb_sub_blocks))
+		list_move_tail(&bi->next, &vm->offline);
+	else if (bitmap_full(bi->online, vm->nb_sub_blocks))
+		list_move_tail(&bi->next, &vm->online);
+	else
+		list_move_tail(&bi->next, &vm->online_offline);
+
+	/* there should never be more than one failed unplug request */
+	BUG_ON(!list_empty(&vm->failed_unplug));
+	vm->failed_unplug_offset = 0;
+	vm->failed_unplug_count = 0;
+	return 0;
+}
+
+static void virtio_mem_process_config(struct work_struct *work)
+{
+	struct virtio_mem *vm = container_of(work, struct virtio_mem,
+					     config_wq);
+	uint64_t diff, new_size;
+	int rc = 0;
+
+	hrtimer_cancel(&vm->retry_timer);
+
+config_update:
+	if (vm->broken)
+		return;
+	atomic_set(&vm->config_changed, 0);
+
+	/* the size is just a reflection of what _we_ did previously */
+	virtio_cread(vm->vdev, struct virtio_mem_config, size,
+		     &new_size);
+	BUG_ON(new_size != vm->cfg.size);
+
+	virtio_cread(vm->vdev, struct virtio_mem_config,
+		     usable_region_size, &vm->cfg.usable_region_size);
+	virtio_cread(vm->vdev, struct virtio_mem_config, requested_size,
+		     &vm->cfg.requested_size);
+
+	/* do we have an outstanding unplug request? */
+	rc = virtio_mem_process_failed_unplug_request(vm);
+	if (!rc) {
+		/* see if we have to plug or unplug memory */
+		if (vm->cfg.requested_size > vm->cfg.size) {
+			diff = vm->cfg.requested_size - vm->cfg.size;
+			diff = round_down(diff, vm->sub_block_size);
+			if (!diff)
+				return;
+
+			rc = virtio_mem_plug_and_online_size(vm, diff);
+		} else if (vm->cfg.requested_size < vm->cfg.size) {
+			diff = vm->cfg.size - vm->cfg.requested_size;
+			diff = round_down(diff, vm->sub_block_size);
+			if (!diff)
+				return;
+
+			rc = virtio_mem_offline_and_unplug_size(vm, diff);
+		}
+	}
+
+	switch (rc) {
+	case 0:
+		break;
+	case -EAGAIN:
+		goto config_update;
+	case -EBUSY:
+	case -ENOSPC:
+	case -ENOMEM:
+		/*
+		 * In all of the following errors, all we can do is retry
+		 * later.
+		 *
+		 * -EBUSY: device is busy
+		 * -ENOSPC: No more memory can be offlined (e.g. all busy)
+		 * -ENOMEM: Persistent out of memory condition
+		 *  1. onlining/offlining is out of memory
+		 *  2. we cannot add memory to the system
+		 *  3. we cannot allocate memory for a block_info/requests
+		 */
+		hrtimer_start(&vm->retry_timer, vm->retry_interval,
+			      HRTIMER_MODE_REL);
+		break;
+	case -EINVAL:
+		/*
+		 * 1. We received an ERROR from our device we didn't expect
+		 * 2. onlining/offlining/adding of memory unexpected errors
+		 */
+		WARN_ON("Unknown error handling virtio-mem config update.");
+		vm->broken = true;
+		break;
+	default:
+		WARN_ON_ONCE(rc);
+	}
+}
+
+static enum hrtimer_restart virtio_mem_retry(struct hrtimer *timer)
+{
+	struct virtio_mem *vm = container_of(timer, struct virtio_mem,
+					     retry_timer);
+
+	spin_lock_irq(&vm->removal_lock);
+	if (!vm->removing)
+		queue_work(system_freezable_wq, &vm->config_wq);
+	spin_unlock_irq(&vm->removal_lock);
+
+	return HRTIMER_NORESTART;
+}
+
+static void virtio_mem_config_changed(struct virtio_device *vdev)
+{
+	struct virtio_mem *vm = vdev->priv;
+
+	spin_lock_irq(&vm->removal_lock);
+	if (!vm->removing) {
+		atomic_set(&vm->config_changed, 1);
+		queue_work(system_freezable_wq, &vm->config_wq);
+	}
+	spin_unlock_irq(&vm->removal_lock);
+}
+
+static void virtio_mem_handle_response(struct virtqueue *vq)
+{
+	struct virtio_mem *vm = vq->vdev->priv;
+
+	wake_up(&vm->host_resp);
+}
+
+static int init_vq(struct virtio_mem *vm)
+{
+	struct virtqueue *vq;
+
+	vq = virtio_find_single_vq(vm->vdev, virtio_mem_handle_response,
+				   "guest-request");
+	if (IS_ERR(vq))
+		return PTR_ERR(vq);
+	vm->vq = vq;
+
+	return 0;
+}
+
+static int virtio_mem_init(struct virtio_mem *vm)
+{
+	const uint64_t phys_limit = 1UL << MAX_PHYSMEM_BITS;
+
+	/* all properties that can't change */
+	virtio_cread(vm->vdev, struct virtio_mem_config, block_size,
+		     &vm->cfg.block_size);
+	virtio_cread(vm->vdev, struct virtio_mem_config, node_id,
+		     &vm->cfg.node_id);
+	vm->node = virtio_mem_translate_node_id(vm, vm->cfg.node_id);
+	virtio_cread(vm->vdev, struct virtio_mem_config, size,
+		     &vm->cfg.size);
+	virtio_cread(vm->vdev, struct virtio_mem_config, start_addr,
+		     &vm->cfg.start_addr);
+	virtio_cread(vm->vdev, struct virtio_mem_config, region_size,
+		     &vm->cfg.region_size);
+
+	/*
+	 * A fresh device should never have memory marked as plugged. This
+	 * implies that the device was used since the last reboot - e.g.
+	 * somebody unloaded the driver or we're in kexec. Stop right here.
+	 *
+	 * TODO: Detect if we actually have memory added from the applicable
+	 * region and reinititalize by querying e.g. the hypervisor.
+	 */
+	if (vm->cfg.size) {
+		dev_err(&vm->vdev->dev, "the virtio-mem device still has some "
+			"memory plugged, reinit is not supported yet!\n");
+		return -EINVAL;
+	}
+
+	/* The size we have to use for add_memory/remove_memory */
+	vm->block_size = memory_block_size_bytes();
+	if (vm->block_size < vm->cfg.block_size)
+		vm->block_size = vm->cfg.block_size;
+
+	/* The size we use for manual online_pages/offline_pages */
+	vm->sub_block_size = offline_nr_pages;
+	if (vm->sub_block_size < vm->cfg.block_size)
+		vm->sub_block_size = vm->cfg.block_size;
+
+	/* Limit the number of sub blocks per block to a sane number */
+	BUG_ON(vm->block_size < vm->sub_block_size);
+	while (vm->block_size / vm->sub_block_size > MAX_NB_SUB_BLOCKS)
+		vm->sub_block_size <<= 1;
+	vm->nb_sub_blocks = vm->block_size / vm->sub_block_size;
+
+	/* bad device setup will make our life harder */
+	if (!IS_ALIGNED(vm->cfg.start_addr, vm->block_size))
+		dev_warn(&vm->vdev->dev, "The alignment of the physical start "
+			 "address can make some memory unusable.");
+	if (!IS_ALIGNED(vm->cfg.start_addr + vm->cfg.region_size,
+			vm->block_size))
+		dev_warn(&vm->vdev->dev, "The alignment of the physical end "
+			 "address can make some memory unusable.");
+	if (vm->cfg.start_addr + vm->cfg.region_size > phys_limit)
+		dev_warn(&vm->vdev->dev, "Some physical address are not "
+			 "adressable. This can make some memory unusable.");
+
+	/* handle everything else via the config workqueue */
+	queue_work(system_freezable_wq, &vm->config_wq);
+
+	return 0;
+}
+
+static int virtio_mem_probe(struct virtio_device *vdev)
+{
+	struct virtio_mem *vm;
+	int rc = -EINVAL;
+
+	if (!vdev->config->get) {
+		dev_err(&vdev->dev, "%s failure: config access disabled\n",
+			__func__);
+		return -EINVAL;
+	}
+
+	vdev->priv = vm = kzalloc(sizeof(*vm), GFP_KERNEL);
+	if (!vm)
+		return -ENOMEM;
+
+	init_waitqueue_head(&vm->host_resp);
+	vm->vdev = vdev;
+	INIT_WORK(&vm->config_wq, virtio_mem_process_config);
+	INIT_LIST_HEAD(&vm->online);
+	INIT_LIST_HEAD(&vm->online_offline);
+	INIT_LIST_HEAD(&vm->offline);
+	INIT_LIST_HEAD(&vm->failed_unplug);
+	hrtimer_init(&vm->retry_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
+	vm->retry_timer.function = virtio_mem_retry;
+	vm->retry_interval = ms_to_ktime(VIRTIO_MEM_RETRY_MS);
+
+	rc = init_vq(vm);
+	if (rc)
+		goto out_free_vm;
+
+	/* process the initital config */
+	rc = virtio_mem_init(vm);
+	if (rc)
+		goto out_del_vq;
+	virtio_device_ready(vdev);
+
+	return 0;
+out_del_vq:
+	vdev->config->del_vqs(vdev);
+out_free_vm:
+	kfree(vm);
+	vdev->priv = NULL;
+
+	return rc;
+}
+
+static void virtio_mem_remove(struct virtio_device *vdev)
+{
+	struct virtio_mem *vm = vdev->priv;
+	struct virtio_mem_block_info *cur, *n;
+
+	spin_lock_irq(&vm->removal_lock);
+	vm->removing = true;
+	spin_unlock_irq(&vm->removal_lock);
+
+	cancel_work_sync(&vm->config_wq);
+	hrtimer_cancel(&vm->retry_timer);
+
+	/*
+	 * There is no way we could deterministically remove all memory we have
+	 * added to the system. And there is no way to stop the driver/device
+	 * from going away.
+	 *
+	 * We have to leave all memory added to the system. The size of the
+	 * device will be > 0 (until the next real reboot) and we can detect
+	 * that this device is dirty when probing (and e.g. reinititalize).
+	 *
+	 * The hypervisor should guard us from actually removing the device
+	 * along with the memory - this would be really bad.
+	 */
+	if (vm->cfg.size) {
+		dev_warn(&vdev->dev, "removing a virtio-mem device or its "
+			 "driver while some of it memory is used by Linux can "
+			 "be dangerous!");
+	}
+
+	/* remove any block infos we allocated */
+	list_for_each_entry_safe(cur, n, &vm->online, next) {
+		list_del(&cur->next);
+		kfree(cur);
+	}
+	list_for_each_entry_safe(cur, n, &vm->offline, next) {
+		list_del(&cur->next);
+		kfree(cur);
+	}
+	list_for_each_entry_safe(cur, n, &vm->online_offline, next) {
+		list_del(&cur->next);
+		kfree(cur);
+	}
+	list_for_each_entry_safe(cur, n, &vm->failed_unplug, next) {
+		list_del(&cur->next);
+		kfree(cur);
+	}
+
+	/* reset the device and cleanup the queues */
+	vdev->config->reset(vdev);
+	vdev->config->del_vqs(vdev);
+
+	kfree(vm);
+	vdev->priv = NULL;
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int virtio_mem_freeze(struct virtio_device *vdev)
+{
+	struct virtio_mem *vm = vdev->priv;
+
+	/* everything (workqueue, timer) else should already be frozen by now */
+	if (vm->cfg.size) {
+		dev_err(&vdev->dev, "%s failure: cannot freeze virtio-mem with plugged memory\n",
+			__func__);
+		return -EPERM;
+	}
+
+	/* reset the device and cleanup the queues */
+	vdev->config->reset(vdev);
+	vdev->config->del_vqs(vdev);
+	return 0;
+}
+
+static int virtio_mem_restore(struct virtio_device *vdev)
+{
+	struct virtio_mem *vm = vdev->priv;
+	int rc;
+
+	rc = init_vq(vm);
+	if (rc)
+		return rc;
+
+	virtio_device_ready(vdev);
+
+	/* kick off a config update */
+	queue_work(system_freezable_wq, &vm->config_wq);
+	return 0;
+}
+#endif
+
+static unsigned int features[] = {
+#if defined(CONFIG_NUMA) && defined(CONFIG_ACPI_NUMA)
+	VIRTIO_MEM_F_ACPI_NODE_ID,
+#endif
+};
+
+static struct virtio_device_id id_table[] = {
+	{ VIRTIO_ID_MEM, VIRTIO_DEV_ANY_ID },
+	{ 0 },
+};
+
+static struct virtio_driver virtio_mem_driver = {
+	.feature_table =	features,
+	.feature_table_size =	ARRAY_SIZE(features),
+	.driver.name =		KBUILD_MODNAME,
+	.driver.owner =		THIS_MODULE,
+	.id_table =		id_table,
+	.probe =		virtio_mem_probe,
+	.config_changed =	virtio_mem_config_changed,
+	.remove =		virtio_mem_remove,
+#ifdef CONFIG_PM_SLEEP
+	.freeze	=	virtio_mem_freeze,
+	.restore =	virtio_mem_restore,
+#endif
+};
+
+module_virtio_driver(virtio_mem_driver);
+MODULE_DEVICE_TABLE(virtio, id_table);
+MODULE_AUTHOR("David Hildenbrand <david@redhat.com>");
+MODULE_DESCRIPTION("Virtio-mem driver");
+MODULE_LICENSE("GPL");
diff --git a/include/uapi/linux/virtio_ids.h b/include/uapi/linux/virtio_ids.h
index 6d5c3b2d4f4d..059cae62f6cc 100644
--- a/include/uapi/linux/virtio_ids.h
+++ b/include/uapi/linux/virtio_ids.h
@@ -43,5 +43,6 @@
 #define VIRTIO_ID_INPUT        18 /* virtio input */
 #define VIRTIO_ID_VSOCK        19 /* virtio vsock transport */
 #define VIRTIO_ID_CRYPTO       20 /* virtio crypto */
+#define VIRTIO_ID_MEM          24 /* virtio mem */
 
 #endif /* _LINUX_VIRTIO_IDS_H */
diff --git a/include/uapi/linux/virtio_mem.h b/include/uapi/linux/virtio_mem.h
new file mode 100644
index 000000000000..dbe77b9fbbcf
--- /dev/null
+++ b/include/uapi/linux/virtio_mem.h
@@ -0,0 +1,134 @@
+/*
+ * Virtio Mem Device
+ *
+ * Copyright Red Hat, Inc. 2018
+ *
+ * Authors:
+ *     David Hildenbrand <david@redhat.com>
+ *
+ * This header is BSD licensed so anyone can use the definitions
+ * to implement compatible drivers/servers:
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of IBM nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
+ * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL IBM OR
+ * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
+ * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
+ * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
+ * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGE.
+ */
+
+#ifndef _LINUX_VIRTIO_MEM_H
+#define _LINUX_VIRTIO_MEM_H
+
+#include <linux/types.h>
+#include <linux/virtio_types.h>
+#include <linux/virtio_ids.h>
+#include <linux/virtio_config.h>
+
+/* --- virtio-mem: feature bits --- */
+
+/* node_id is an ACPI node id and is valid */
+#define VIRTIO_MEM_F_ACPI_NODE_ID		0
+
+
+/* --- virtio-mem: guest -> host requests --- */
+
+/* request to plug memory blocks */
+#define VIRTIO_MEM_REQ_PLUG		0
+/* request to unplug memory blocks */
+#define VIRTIO_MEM_REQ_UNPLUG		1
+/* request information about the plugged state of memory blocks */
+#define VIRTIO_MEM_REQ_STATE		2
+
+struct virtio_mem_req_plug {
+	uint64_t addr;
+	uint16_t nb_blocks;
+};
+
+struct virtio_mem_req_unplug {
+	uint64_t addr;
+	uint16_t nb_blocks;
+};
+
+struct virtio_mem_req_state {
+	uint64_t addr;
+	uint16_t nb_blocks;
+};
+
+struct virtio_mem_req {
+	uint16_t type;
+	uint16_t padding[3];
+
+	union {
+		struct virtio_mem_req_plug plug;
+		struct virtio_mem_req_unplug unplug;
+		struct virtio_mem_req_state state;
+		uint8_t reserved[64];
+	} u;
+};
+
+
+/* --- virtio-mem: host -> guest response --- */
+
+/* request processed successfully - !VIRTIO_MEM_REQ_STATE */
+#define VIRTIO_MEM_RESP_ACK		0
+/* request cannot be processed right now */
+#define VIRTIO_MEM_RESP_RETRY		1
+/* request denied (e.g. plug more than requested) - !VIRTIO_MEM_REQ_STATE */
+#define VIRTIO_MEM_RESP_NACK		2
+/* error in request (e.g. address/alignment wrong) */
+#define VIRTIO_MEM_RESP_ERROR		3
+/* state of memory blocks is plugged */
+#define VIRTIO_MEM_RESP_PLUGGED		4
+/* state of memory blocks is unplugged */
+#define VIRTIO_MEM_RESP_UNPLUGGED	5
+/* state of memory blocks is mixed (contains plugged and unplugged) */
+#define VIRTIO_MEM_RESP_MIXED		6
+
+struct virtio_mem_resp {
+	uint16_t type;
+	uint16_t padding[3];
+};
+
+
+/* --- virtio-mem: configuration --- */
+
+struct virtio_mem_config {
+	/* block size and alignment. Cannot change. */
+	uint32_t block_size;
+	/* valid with VIRTIO_MEM_F_ACPI_NODE_ID. Cannot change. */
+	uint16_t node_id;
+	uint16_t unused1;
+	/* requested size. New plug requests cannot exceed it. Can change. */
+	uint64_t requested_size;
+	/*
+	 * currently used size. Changed due to plug/unplug requests, but no
+	 * config updates will be sent.
+	 */
+	uint64_t size;
+	/* start address of the memory region. Cannot change. */
+	uint64_t start_addr;
+	/* region size. Cannot change. */
+	uint64_t region_size;
+	/* currently usable region size. Can grow up to region_size. */
+	uint64_t usable_region_size;
+};
+
+#endif /* _LINUX_VIRTIO_MEM_H */
-- 
2.17.0
