Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 44CF16B006C
	for <linux-mm@kvack.org>; Tue, 27 Jan 2015 03:26:26 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id v10so17500576pde.10
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:26:26 -0800 (PST)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id ko6si721097pab.77.2015.01.27.00.26.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 Jan 2015 00:26:25 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so17137800pac.2
        for <linux-mm@kvack.org>; Tue, 27 Jan 2015 00:26:25 -0800 (PST)
From: Sumit Semwal <sumit.semwal@linaro.org>
Subject: [RFCv3 2/2] dma-buf: add helpers for sharing attacher constraints with dma-parms
Date: Tue, 27 Jan 2015 13:55:54 +0530
Message-Id: <1422347154-15258-2-git-send-email-sumit.semwal@linaro.org>
In-Reply-To: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
References: <1422347154-15258-1-git-send-email-sumit.semwal@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: linaro-kernel@lists.linaro.org, robdclark@gmail.com, daniel@ffwll.ch, m.szyprowski@samsung.com, stanislawski.tomasz@googlemail.com, robin.murphy@arm.com, Sumit Semwal <sumit.semwal@linaro.org>

Add some helpers to share the constraints of devices while attaching
to the dmabuf buffer.

At each attach, the constraints are calculated based on the following:
- max_segment_size, max_segment_count, segment_boundary_mask from
   device_dma_parameters.

In case the attaching device's constraints don't match up, attach() fails.

At detach, the constraints are recalculated based on the remaining
attached devices.

Two helpers are added:
- dma_buf_get_constraints - which gives the current constraints as calculated
      during each attach on the buffer till the time,
- dma_buf_recalc_constraints - which recalculates the constraints for all
      currently attached devices for the 'paranoid' ones amongst us.

The idea of this patch is largely taken from Rob Clark's RFC at
https://lkml.org/lkml/2012/7/19/285, and the comments received on it.

Cc: Rob Clark <robdclark@gmail.com>
Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
---
v3: 
- Thanks to Russell's comment, remove dma_mask and coherent_dma_mask from
  constraints' calculation; has a nice side effect of letting us use
  device_dma_parameters directly to list constraints.
- update the debugfs output to show constraint info as well.
  
v2: split constraints-sharing and allocation helpers

 drivers/dma-buf/dma-buf.c | 126 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/dma-buf.h   |   7 +++
 2 files changed, 132 insertions(+), 1 deletion(-)

diff --git a/drivers/dma-buf/dma-buf.c b/drivers/dma-buf/dma-buf.c
index 5be225c2ba98..f363f1440803 100644
--- a/drivers/dma-buf/dma-buf.c
+++ b/drivers/dma-buf/dma-buf.c
@@ -264,6 +264,66 @@ static inline int is_dma_buf_file(struct file *file)
 	return file->f_op == &dma_buf_fops;
 }
 
+static inline void init_constraints(struct device_dma_parameters *cons)
+{
+	cons->max_segment_count = (unsigned int)-1;
+	cons->max_segment_size = (unsigned int)-1;
+	cons->segment_boundary_mask = (unsigned long)-1;
+}
+
+/*
+ * calc_constraints - calculates if the new attaching device's constraints
+ * match, with the constraints of already attached devices; if yes, returns
+ * the constraints; else return ERR_PTR(-EINVAL)
+ */
+static int calc_constraints(struct device *dev,
+			    struct device_dma_parameters *calc_cons)
+{
+	struct device_dma_parameters cons = *calc_cons;
+
+	cons.max_segment_count = min(cons.max_segment_count,
+					dma_get_max_seg_count(dev));
+	cons.max_segment_size = min(cons.max_segment_size,
+					dma_get_max_seg_size(dev));
+	cons.segment_boundary_mask &= dma_get_seg_boundary(dev);
+
+	if (!cons.max_segment_count ||
+	    !cons.max_segment_size ||
+	    !cons.segment_boundary_mask) {
+		pr_err("Dev: %s's constraints don't match\n", dev_name(dev));
+		return -EINVAL;
+	}
+
+	*calc_cons = cons;
+
+	return 0;
+}
+
+/*
+ * recalc_constraints - recalculates constraints for all attached devices;
+ *  useful for detach() recalculation, and for dma_buf_recalc_constraints()
+ *  helper.
+ *  Returns recalculated constraints in recalc_cons, or error in the unlikely
+ *  case when constraints of attached devices might have changed.
+ */
+static int recalc_constraints(struct dma_buf *dmabuf,
+			      struct device_dma_parameters *recalc_cons)
+{
+	struct device_dma_parameters calc_cons;
+	struct dma_buf_attachment *attach;
+	int ret = 0;
+
+	init_constraints(&calc_cons);
+
+	list_for_each_entry(attach, &dmabuf->attachments, node) {
+		ret = calc_constraints(attach->dev, &calc_cons);
+		if (ret)
+			return ret;
+	}
+	*recalc_cons = calc_cons;
+	return 0;
+}
+
 /**
  * dma_buf_export_named - Creates a new dma_buf, and associates an anon file
  * with this buffer, so it can be exported.
@@ -313,6 +373,9 @@ struct dma_buf *dma_buf_export_named(void *priv, const struct dma_buf_ops *ops,
 	dmabuf->ops = ops;
 	dmabuf->size = size;
 	dmabuf->exp_name = exp_name;
+
+	init_constraints(&dmabuf->constraints);
+
 	init_waitqueue_head(&dmabuf->poll);
 	dmabuf->cb_excl.poll = dmabuf->cb_shared.poll = &dmabuf->poll;
 	dmabuf->cb_excl.active = dmabuf->cb_shared.active = 0;
@@ -422,7 +485,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 					  struct device *dev)
 {
 	struct dma_buf_attachment *attach;
-	int ret;
+	int ret = 0;
 
 	if (WARN_ON(!dmabuf || !dev))
 		return ERR_PTR(-EINVAL);
@@ -436,6 +499,9 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 
 	mutex_lock(&dmabuf->lock);
 
+	if (calc_constraints(dev, &dmabuf->constraints))
+		goto err_constraints;
+
 	if (dmabuf->ops->attach) {
 		ret = dmabuf->ops->attach(dmabuf, dev, attach);
 		if (ret)
@@ -448,6 +514,7 @@ struct dma_buf_attachment *dma_buf_attach(struct dma_buf *dmabuf,
 
 err_attach:
 	kfree(attach);
+err_constraints:
 	mutex_unlock(&dmabuf->lock);
 	return ERR_PTR(ret);
 }
@@ -470,6 +537,8 @@ void dma_buf_detach(struct dma_buf *dmabuf, struct dma_buf_attachment *attach)
 	if (dmabuf->ops->detach)
 		dmabuf->ops->detach(dmabuf, attach);
 
+	recalc_constraints(dmabuf, &dmabuf->constraints);
+
 	mutex_unlock(&dmabuf->lock);
 	kfree(attach);
 }
@@ -770,6 +839,56 @@ void dma_buf_vunmap(struct dma_buf *dmabuf, void *vaddr)
 }
 EXPORT_SYMBOL_GPL(dma_buf_vunmap);
 
+/**
+ * dma_buf_get_constraints - get the *current* constraints of the dmabuf,
+ *  as calculated during each attach(); returns error on invalid inputs
+ *
+ * @dmabuf:		[in]	buffer to get constraints of
+ * @constraints:	[out]	current constraints are returned in this
+ */
+int dma_buf_get_constraints(struct dma_buf *dmabuf,
+			    struct device_dma_parameters *constraints)
+{
+	if (WARN_ON(!dmabuf || !constraints))
+		return -EINVAL;
+
+	mutex_lock(&dmabuf->lock);
+	*constraints = dmabuf->constraints;
+	mutex_unlock(&dmabuf->lock);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dma_buf_get_constraints);
+
+/**
+ * dma_buf_recalc_constraints - *recalculate* the constraints for the buffer
+ *  afresh, from the list of currently attached devices; this could be useful
+ *  cross-check the current constraints, for exporters that might want to be
+ *  'paranoid' about the device constraints.
+ *
+ *  returns error on invalid inputs
+ *
+ * @dmabuf:		[in]	buffer to get constraints of
+ * @constraints:	[out]	recalculated constraints are returned in this
+ */
+int dma_buf_recalc_constraints(struct dma_buf *dmabuf,
+			    struct device_dma_parameters *constraints)
+{
+	struct device_dma_parameters calc_cons;
+	int ret = 0;
+
+	if (WARN_ON(!dmabuf || !constraints))
+		return -EINVAL;
+
+	mutex_lock(&dmabuf->lock);
+	ret = recalc_constraints(dmabuf, &calc_cons);
+	if (!ret)
+		*constraints = calc_cons;
+
+	mutex_unlock(&dmabuf->lock);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(dma_buf_recalc_constraints);
+
 #ifdef CONFIG_DEBUG_FS
 static int dma_buf_describe(struct seq_file *s)
 {
@@ -801,6 +920,11 @@ static int dma_buf_describe(struct seq_file *s)
 				buf_obj->file->f_flags, buf_obj->file->f_mode,
 				file_count(buf_obj->file),
 				buf_obj->exp_name);
+		seq_printf(s, "\tConstraints: Seg Count: %08u, Seg Size: %08u",
+				buf_obj->constraints.max_segment_count,
+				buf_obj->constraints.max_segment_size);
+		seq_printf(s, " seg boundary mask: %08lx\n",
+				buf_obj->constraints.segment_boundary_mask);
 
 		seq_puts(s, "\tAttached Devices:\n");
 		attach_count = 0;
diff --git a/include/linux/dma-buf.h b/include/linux/dma-buf.h
index 694e1fe1c4b4..489ad9b2e5ae 100644
--- a/include/linux/dma-buf.h
+++ b/include/linux/dma-buf.h
@@ -34,6 +34,7 @@
 #include <linux/wait.h>
 
 struct device;
+struct device_dma_parameters;
 struct dma_buf;
 struct dma_buf_attachment;
 
@@ -116,6 +117,7 @@ struct dma_buf_ops {
  * @ops: dma_buf_ops associated with this buffer object.
  * @exp_name: name of the exporter; useful for debugging.
  * @list_node: node for dma_buf accounting and debugging.
+ * @constraints: calculated constraints of attached devices.
  * @priv: exporter specific private data for this buffer object.
  * @resv: reservation object linked to this dma-buf
  */
@@ -130,6 +132,7 @@ struct dma_buf {
 	void *vmap_ptr;
 	const char *exp_name;
 	struct list_head list_node;
+	struct device_dma_parameters constraints;
 	void *priv;
 	struct reservation_object *resv;
 
@@ -211,4 +214,8 @@ void *dma_buf_vmap(struct dma_buf *);
 void dma_buf_vunmap(struct dma_buf *, void *vaddr);
 int dma_buf_debugfs_create_file(const char *name,
 				int (*write)(struct seq_file *));
+
+int dma_buf_get_constraints(struct dma_buf *, struct device_dma_parameters *);
+int dma_buf_recalc_constraints(struct dma_buf *,
+					struct device_dma_parameters *);
 #endif /* __DMA_BUF_H__ */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
