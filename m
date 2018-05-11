Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 618BA6B06BE
	for <linux-mm@kvack.org>; Fri, 11 May 2018 15:10:30 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id y49-v6so4300003oti.11
        for <linux-mm@kvack.org>; Fri, 11 May 2018 12:10:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x35-v6si1403539oti.95.2018.05.11.12.10.29
        for <linux-mm@kvack.org>;
        Fri, 11 May 2018 12:10:29 -0700 (PDT)
From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Subject: [PATCH v2 32/40] iommu/arm-smmu-v3: Maintain a SID->device structure
Date: Fri, 11 May 2018 20:06:33 +0100
Message-Id: <20180511190641.23008-33-jean-philippe.brucker@arm.com>
In-Reply-To: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, devicetree@vger.kernel.org, iommu@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org
Cc: joro@8bytes.org, will.deacon@arm.com, robin.murphy@arm.com, alex.williamson@redhat.com, tn@semihalf.com, liubo95@huawei.com, thunder.leizhen@huawei.com, xieyisheng1@huawei.com, xuzaibo@huawei.com, ilias.apalodimas@linaro.org, jonathan.cameron@huawei.com, liudongdong3@huawei.com, shunyong.yang@hxt-semitech.com, nwatters@codeaurora.org, okaya@codeaurora.org, jcrouse@codeaurora.org, rfranz@cavium.com, dwmw2@infradead.org, jacob.jun.pan@linux.intel.com, yi.l.liu@intel.com, ashok.raj@intel.com, kevin.tian@intel.com, baolu.lu@linux.intel.com, robdclark@gmail.com, christian.koenig@amd.com, bharatku@xilinx.com, rgummal@xilinx.com

When handling faults from the event or PRI queue, we need to find the
struct device associated to a SID. Add a rb_tree to keep track of SIDs.

Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
---
 drivers/iommu/arm-smmu-v3.c | 114 +++++++++++++++++++++++++++++++++++-
 1 file changed, 113 insertions(+), 1 deletion(-)

diff --git a/drivers/iommu/arm-smmu-v3.c b/drivers/iommu/arm-smmu-v3.c
index d5f3875abfb9..0f2d8aa0deee 100644
--- a/drivers/iommu/arm-smmu-v3.c
+++ b/drivers/iommu/arm-smmu-v3.c
@@ -570,9 +570,18 @@ struct arm_smmu_device {
 	/* IOMMU core code handle */
 	struct iommu_device		iommu;
 
+	struct rb_root			streams;
+	struct mutex			streams_mutex;
+
 	struct iopf_queue		*iopf_queue;
 };
 
+struct arm_smmu_stream {
+	u32				id;
+	struct arm_smmu_master_data	*master;
+	struct rb_node			node;
+};
+
 /* SMMU private data for each master */
 struct arm_smmu_master_data {
 	struct arm_smmu_device		*smmu;
@@ -580,6 +589,7 @@ struct arm_smmu_master_data {
 
 	struct arm_smmu_domain		*domain;
 	struct list_head		list; /* domain->devices */
+	struct arm_smmu_stream		*streams;
 
 	struct device			*dev;
 	size_t				ssid_bits;
@@ -1186,6 +1196,32 @@ static int arm_smmu_init_l2_strtab(struct arm_smmu_device *smmu, u32 sid)
 	return 0;
 }
 
+__maybe_unused
+static struct arm_smmu_master_data *
+arm_smmu_find_master(struct arm_smmu_device *smmu, u32 sid)
+{
+	struct rb_node *node;
+	struct arm_smmu_stream *stream;
+	struct arm_smmu_master_data *master = NULL;
+
+	mutex_lock(&smmu->streams_mutex);
+	node = smmu->streams.rb_node;
+	while (node) {
+		stream = rb_entry(node, struct arm_smmu_stream, node);
+		if (stream->id < sid) {
+			node = node->rb_right;
+		} else if (stream->id > sid) {
+			node = node->rb_left;
+		} else {
+			master = stream->master;
+			break;
+		}
+	}
+	mutex_unlock(&smmu->streams_mutex);
+
+	return master;
+}
+
 /* IRQ and event handlers */
 static irqreturn_t arm_smmu_evtq_thread(int irq, void *dev)
 {
@@ -2086,6 +2122,71 @@ static bool arm_smmu_sid_in_range(struct arm_smmu_device *smmu, u32 sid)
 	return sid < limit;
 }
 
+static int arm_smmu_insert_master(struct arm_smmu_device *smmu,
+				  struct arm_smmu_master_data *master)
+{
+	int i;
+	int ret = 0;
+	struct arm_smmu_stream *new_stream, *cur_stream;
+	struct rb_node **new_node, *parent_node = NULL;
+	struct iommu_fwspec *fwspec = master->dev->iommu_fwspec;
+
+	master->streams = kcalloc(fwspec->num_ids,
+				  sizeof(struct arm_smmu_stream), GFP_KERNEL);
+	if (!master->streams)
+		return -ENOMEM;
+
+	mutex_lock(&smmu->streams_mutex);
+	for (i = 0; i < fwspec->num_ids && !ret; i++) {
+		new_stream = &master->streams[i];
+		new_stream->id = fwspec->ids[i];
+		new_stream->master = master;
+
+		new_node = &(smmu->streams.rb_node);
+		while (*new_node) {
+			cur_stream = rb_entry(*new_node, struct arm_smmu_stream,
+					      node);
+			parent_node = *new_node;
+			if (cur_stream->id > new_stream->id) {
+				new_node = &((*new_node)->rb_left);
+			} else if (cur_stream->id < new_stream->id) {
+				new_node = &((*new_node)->rb_right);
+			} else {
+				dev_warn(master->dev,
+					 "stream %u already in tree\n",
+					 cur_stream->id);
+				ret = -EINVAL;
+				break;
+			}
+		}
+
+		if (!ret) {
+			rb_link_node(&new_stream->node, parent_node, new_node);
+			rb_insert_color(&new_stream->node, &smmu->streams);
+		}
+	}
+	mutex_unlock(&smmu->streams_mutex);
+
+	return ret;
+}
+
+static void arm_smmu_remove_master(struct arm_smmu_device *smmu,
+				   struct arm_smmu_master_data *master)
+{
+	int i;
+	struct iommu_fwspec *fwspec = master->dev->iommu_fwspec;
+
+	if (!master->streams)
+		return;
+
+	mutex_lock(&smmu->streams_mutex);
+	for (i = 0; i < fwspec->num_ids; i++)
+		rb_erase(&master->streams[i].node, &smmu->streams);
+	mutex_unlock(&smmu->streams_mutex);
+
+	kfree(master->streams);
+}
+
 static struct iommu_ops arm_smmu_ops;
 
 static int arm_smmu_add_device(struct device *dev)
@@ -2142,16 +2243,23 @@ static int arm_smmu_add_device(struct device *dev)
 	if (ret)
 		goto err_free_master;
 
+	ret = arm_smmu_insert_master(smmu, master);
+	if (ret)
+		goto err_unlink;
+
 	group = iommu_group_get_for_dev(dev);
 	if (IS_ERR(group)) {
 		ret = PTR_ERR(group);
-		goto err_unlink;
+		goto err_remove_master;
 	}
 
 	iommu_group_put(group);
 
 	return 0;
 
+err_remove_master:
+	arm_smmu_remove_master(smmu, master);
+
 err_unlink:
 	iommu_device_unlink(&smmu->iommu, dev);
 
@@ -2180,6 +2288,7 @@ static void arm_smmu_remove_device(struct device *dev)
 	if (master->ste.assigned)
 		arm_smmu_detach_dev(dev);
 	iommu_group_remove_device(dev);
+	arm_smmu_remove_master(smmu, master);
 	iommu_device_unlink(&smmu->iommu, dev);
 	kfree(master);
 	iommu_fwspec_free(dev);
@@ -2483,6 +2592,9 @@ static int arm_smmu_init_structures(struct arm_smmu_device *smmu)
 	int ret;
 
 	atomic_set(&smmu->sync_nr, 0);
+	mutex_init(&smmu->streams_mutex);
+	smmu->streams = RB_ROOT;
+
 	ret = arm_smmu_init_queues(smmu);
 	if (ret)
 		return ret;
-- 
2.17.0
