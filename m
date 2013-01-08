Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2D0326B005D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 09:57:24 -0500 (EST)
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: [PATCH 5/5] kfifo: log based kfifo API
Date: Tue,  8 Jan 2013 22:57:53 +0800
Message-Id: <1357657073-27352-6-git-send-email-yuanhan.liu@linux.intel.com>
In-Reply-To: <1357657073-27352-1-git-send-email-yuanhan.liu@linux.intel.com>
References: <1357657073-27352-1-git-send-email-yuanhan.liu@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Yuanhan Liu <yuanhan.liu@linux.intel.com>, Stefani Seibold <stefani@seibold.net>, Andrew Morton <akpm@linux-foundation.org>, linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, platform-driver-x86@vger.kernel.org, linux-input@vger.kernel.org, linux-iio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, linux-mmc@vger.kernel.org, linux-mtd@lists.infradead.org, libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org, netdev@vger.kernel.org, linux-pci@vger.kernel.org, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, devel@driverdev.osuosl.org, linux-serial@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org, dccp@vger.kernel.org, linux-sctp@vger.kernel.org

The current kfifo API take the kfifo size as input, while it rounds
 _down_ the size to power of 2 at __kfifo_alloc. This may introduce
potential issue.

Take the code at drivers/hid/hid-logitech-dj.c as example:

	if (kfifo_alloc(&djrcv_dev->notif_fifo,
                       DJ_MAX_NUMBER_NOTIFICATIONS * sizeof(struct dj_report),
                       GFP_KERNEL)) {

Where, DJ_MAX_NUMBER_NOTIFICATIONS is 8, and sizeo of(struct dj_report)
is 15.

Which means it wants to allocate a kfifo buffer which can store 8
dj_report entries at once. The expected kfifo buffer size would be
8 * 15 = 120 then. While, in the end, __kfifo_alloc will turn the
size to rounddown_power_of_2(120) =  64, and then allocate a buf
with 64 bytes, which I don't think this is the original author want.

With the new log API, we can do like following:

	int kfifo_size_order = order_base_2(DJ_MAX_NUMBER_NOTIFICATIONS *
					    sizeof(struct dj_report));

	if (kfifo_alloc(&djrcv_dev->notif_fifo, kfifo_size_order, GFP_KERNEL)) {

This make sure we will allocate enough kfifo buffer for holding
DJ_MAX_NUMBER_NOTIFICATIONS dj_report entries.

Cc: Stefani Seibold <stefani@seibold.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-omap@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: platform-driver-x86@vger.kernel.org
Cc: linux-input@vger.kernel.org
Cc: linux-iio@vger.kernel.org
Cc: linux-rdma@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: linux-mmc@vger.kernel.org
Cc: linux-mtd@lists.infradead.org
Cc: libertas-dev@lists.infradead.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: open-iscsi@googlegroups.com
Cc: linux-scsi@vger.kernel.org
Cc: devel@driverdev.osuosl.org
Cc: linux-serial@vger.kernel.org
Cc: linux-usb@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: dccp@vger.kernel.org
Cc: linux-sctp@vger.kernel.org
Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
---
 arch/arm/plat-omap/Kconfig                  |    2 +-
 arch/arm/plat-omap/mailbox.c                |    6 +++-
 arch/powerpc/sysdev/fsl_rmu.c               |    2 +-
 drivers/char/sonypi.c                       |    9 ++++---
 drivers/hid/hid-logitech-dj.c               |    7 +++--
 drivers/iio/industrialio-event.c            |    2 +-
 drivers/iio/kfifo_buf.c                     |    3 +-
 drivers/infiniband/hw/cxgb3/cxio_resource.c |    8 ++++--
 drivers/media/i2c/cx25840/cx25840-ir.c      |    9 +++++--
 drivers/media/pci/cx23885/cx23888-ir.c      |    9 +++++--
 drivers/media/pci/meye/meye.c               |    6 +---
 drivers/media/pci/meye/meye.h               |    2 +
 drivers/media/rc/ir-raw.c                   |    7 +++--
 drivers/memstick/host/r592.h                |    2 +-
 drivers/mmc/card/sdio_uart.c                |    4 ++-
 drivers/mtd/sm_ftl.c                        |    5 +++-
 drivers/net/wireless/libertas/main.c        |    4 ++-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    5 +--
 drivers/pci/pcie/aer/aerdrv_core.c          |    3 +-
 drivers/platform/x86/fujitsu-laptop.c       |    5 ++-
 drivers/platform/x86/sony-laptop.c          |    6 ++--
 drivers/rapidio/devices/tsi721.c            |    5 ++-
 drivers/scsi/libiscsi_tcp.c                 |    6 +++-
 drivers/staging/omapdrm/omap_plane.c        |    5 +++-
 drivers/tty/n_gsm.c                         |    4 ++-
 drivers/tty/nozomi.c                        |    5 +--
 drivers/tty/serial/ifx6x60.c                |    2 +-
 drivers/tty/serial/ifx6x60.h                |    3 +-
 drivers/tty/serial/kgdb_nmi.c               |    7 +++--
 drivers/usb/host/fhci.h                     |    4 ++-
 drivers/usb/serial/cypress_m8.c             |    4 +-
 drivers/usb/serial/io_ti.c                  |    4 +-
 drivers/usb/serial/ti_usb_3410_5052.c       |    7 +++--
 drivers/usb/serial/usb-serial.c             |    2 +-
 include/linux/kfifo.h                       |   31 +++++++++++++--------------
 include/linux/rio.h                         |    1 +
 include/media/lirc_dev.h                    |    4 ++-
 kernel/kfifo.c                              |    9 +------
 mm/memory-failure.c                         |    3 +-
 net/dccp/probe.c                            |    6 +++-
 net/sctp/probe.c                            |    6 +++-
 samples/kfifo/bytestream-example.c          |    8 +++---
 samples/kfifo/dma-example.c                 |    5 ++-
 samples/kfifo/inttype-example.c             |    7 +++--
 samples/kfifo/record-example.c              |    6 ++--
 45 files changed, 142 insertions(+), 108 deletions(-)

diff --git a/arch/arm/plat-omap/Kconfig b/arch/arm/plat-omap/Kconfig
index 665870d..7eda02c 100644
--- a/arch/arm/plat-omap/Kconfig
+++ b/arch/arm/plat-omap/Kconfig
@@ -124,7 +124,7 @@ config OMAP_MBOX_FWK
 	  DSP, IVA1.0 and IVA2 in OMAP1/2/3.
 
 config OMAP_MBOX_KFIFO_SIZE
-	int "Mailbox kfifo default buffer size (bytes)"
+	int "Mailbox kfifo default buffer size (bytes, should be power of 2. If not, will roundup to power of 2"
 	depends on OMAP_MBOX_FWK
 	default 256
 	help
diff --git a/arch/arm/plat-omap/mailbox.c b/arch/arm/plat-omap/mailbox.c
index 42377ef..848fa0b 100644
--- a/arch/arm/plat-omap/mailbox.c
+++ b/arch/arm/plat-omap/mailbox.c
@@ -30,6 +30,7 @@
 #include <linux/err.h>
 #include <linux/notifier.h>
 #include <linux/module.h>
+#include <linux/log2.h>
 
 #include <plat/mailbox.h>
 
@@ -40,7 +41,7 @@ static DEFINE_MUTEX(mbox_configured_lock);
 
 static unsigned int mbox_kfifo_size = CONFIG_OMAP_MBOX_KFIFO_SIZE;
 module_param(mbox_kfifo_size, uint, S_IRUGO);
-MODULE_PARM_DESC(mbox_kfifo_size, "Size of omap's mailbox kfifo (bytes)");
+MODULE_PARM_DESC(mbox_kfifo_size, "Size of omap's mailbox kfifo (bytes, should be power of 2. If not, will roundup to power of 2)");
 
 /* Mailbox FIFO handle functions */
 static inline mbox_msg_t mbox_fifo_read(struct omap_mbox *mbox)
@@ -218,6 +219,7 @@ static struct omap_mbox_queue *mbox_queue_alloc(struct omap_mbox *mbox,
 					void (*tasklet)(unsigned long))
 {
 	struct omap_mbox_queue *mq;
+	int mbox_kfifo_size_order = order_base_2(mbox_kfifo_size);
 
 	mq = kzalloc(sizeof(struct omap_mbox_queue), GFP_KERNEL);
 	if (!mq)
@@ -225,7 +227,7 @@ static struct omap_mbox_queue *mbox_queue_alloc(struct omap_mbox *mbox,
 
 	spin_lock_init(&mq->lock);
 
-	if (kfifo_alloc(&mq->fifo, mbox_kfifo_size, GFP_KERNEL))
+	if (kfifo_alloc(&mq->fifo, mbox_kfifo_size_order, GFP_KERNEL))
 		goto error;
 
 	if (work)
diff --git a/arch/powerpc/sysdev/fsl_rmu.c b/arch/powerpc/sysdev/fsl_rmu.c
index 14bd522..84d2b8c 100644
--- a/arch/powerpc/sysdev/fsl_rmu.c
+++ b/arch/powerpc/sysdev/fsl_rmu.c
@@ -587,7 +587,7 @@ int fsl_rio_port_write_init(struct fsl_rio_pw *pw)
 
 	INIT_WORK(&pw->pw_work, fsl_pw_dpc);
 	spin_lock_init(&pw->pw_fifo_lock);
-	if (kfifo_alloc(&pw->pw_fifo, RIO_PW_MSG_SIZE * 32, GFP_KERNEL)) {
+	if (kfifo_alloc(&pw->pw_fifo, RIO_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		pr_err("FIFO allocation failed\n");
 		rc = -ENOMEM;
 		goto err_out_irq;
diff --git a/drivers/char/sonypi.c b/drivers/char/sonypi.c
index d780295..39d8dd7 100644
--- a/drivers/char/sonypi.c
+++ b/drivers/char/sonypi.c
@@ -429,7 +429,7 @@ static struct sonypi_eventtypes {
 	{ 0 }
 };
 
-#define SONYPI_BUF_SIZE	128
+#define SONYPI_KFIFO_SIZE_ORDER		7
 
 /* Correspondance table between sonypi events and input layer events */
 static struct {
@@ -1316,7 +1316,8 @@ static int sonypi_probe(struct platform_device *dev)
 			"http://www.linux.it/~malattia/wiki/index.php/Sony_drivers\n");
 
 	spin_lock_init(&sonypi_device.fifo_lock);
-	error = kfifo_alloc(&sonypi_device.fifo, SONYPI_BUF_SIZE, GFP_KERNEL);
+	error = kfifo_alloc(&sonypi_device.fifo, SONYPI_KFIFO_SIZE_ORDER,
+			GFP_KERNEL);
 	if (error) {
 		printk(KERN_ERR "sonypi: kfifo_alloc failed\n");
 		return error;
@@ -1395,8 +1396,8 @@ static int sonypi_probe(struct platform_device *dev)
 		}
 
 		spin_lock_init(&sonypi_device.input_fifo_lock);
-		error = kfifo_alloc(&sonypi_device.input_fifo, SONYPI_BUF_SIZE,
-				GFP_KERNEL);
+		error = kfifo_alloc(&sonypi_device.input_fifo,
+				SONYPI_KFIFO_SIZE_ORDER, GFP_KERNEL);
 		if (error) {
 			printk(KERN_ERR "sonypi: kfifo_alloc failed\n");
 			goto err_inpdev_unregister;
diff --git a/drivers/hid/hid-logitech-dj.c b/drivers/hid/hid-logitech-dj.c
index 9500f2f..031be77 100644
--- a/drivers/hid/hid-logitech-dj.c
+++ b/drivers/hid/hid-logitech-dj.c
@@ -26,6 +26,7 @@
 #include <linux/hid.h>
 #include <linux/module.h>
 #include <linux/usb.h>
+#include <linux/log2.h>
 #include <asm/unaligned.h>
 #include "usbhid/usbhid.h"
 #include "hid-ids.h"
@@ -730,6 +731,8 @@ static int logi_dj_probe(struct hid_device *hdev,
 	struct usb_interface *intf = to_usb_interface(hdev->dev.parent);
 	struct dj_receiver_dev *djrcv_dev;
 	int retval;
+	int kfifo_size_order = order_base_2(DJ_MAX_NUMBER_NOTIFICATIONS *
+					    sizeof(struct dj_report));
 
 	if (is_dj_device((struct dj_device *)hdev->driver_data))
 		return -ENODEV;
@@ -757,9 +760,7 @@ static int logi_dj_probe(struct hid_device *hdev,
 	djrcv_dev->hdev = hdev;
 	INIT_WORK(&djrcv_dev->work, delayedwork_callback);
 	spin_lock_init(&djrcv_dev->lock);
-	if (kfifo_alloc(&djrcv_dev->notif_fifo,
-			DJ_MAX_NUMBER_NOTIFICATIONS * sizeof(struct dj_report),
-			GFP_KERNEL)) {
+	if (kfifo_alloc(&djrcv_dev->notif_fifo, kfifo_size_order, GFP_KERNEL)) {
 		dev_err(&hdev->dev,
 			"%s:failed allocating notif_fifo\n", __func__);
 		kfree(djrcv_dev);
diff --git a/drivers/iio/industrialio-event.c b/drivers/iio/industrialio-event.c
index 261cae0..9b73680 100644
--- a/drivers/iio/industrialio-event.c
+++ b/drivers/iio/industrialio-event.c
@@ -35,7 +35,7 @@
  */
 struct iio_event_interface {
 	wait_queue_head_t	wait;
-	DECLARE_KFIFO(det_events, struct iio_event_data, 16);
+	DECLARE_KFIFO(det_events, struct iio_event_data, 4);
 
 	struct list_head	dev_attr_list;
 	unsigned long		flags;
diff --git a/drivers/iio/kfifo_buf.c b/drivers/iio/kfifo_buf.c
index 5bc5c86..d8ba52ff 100644
--- a/drivers/iio/kfifo_buf.c
+++ b/drivers/iio/kfifo_buf.c
@@ -7,6 +7,7 @@
 #include <linux/mutex.h>
 #include <linux/iio/kfifo_buf.h>
 #include <linux/sched.h>
+#include <linux/log2.h>
 
 struct iio_kfifo {
 	struct iio_buffer buffer;
@@ -23,7 +24,7 @@ static inline int __iio_allocate_kfifo(struct iio_kfifo *buf,
 		return -EINVAL;
 
 	__iio_update_buffer(&buf->buffer, bytes_per_datum, length);
-	return __kfifo_alloc((struct __kfifo *)&buf->kf, length,
+	return __kfifo_alloc((struct __kfifo *)&buf->kf, order_base_2(length),
 			     bytes_per_datum, GFP_KERNEL);
 }
 
diff --git a/drivers/infiniband/hw/cxgb3/cxio_resource.c b/drivers/infiniband/hw/cxgb3/cxio_resource.c
index 31f9201..186d05e 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_resource.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_resource.c
@@ -36,6 +36,7 @@
 #include <linux/kfifo.h>
 #include <linux/spinlock.h>
 #include <linux/errno.h>
+#include <linux/log2.h>
 #include "cxio_resource.h"
 #include "cxio_hal.h"
 
@@ -54,8 +55,9 @@ static int __cxio_init_resource_fifo(struct kfifo *fifo,
 	u32 random_bytes;
 	u32 rarray[16];
 	spin_lock_init(fifo_lock);
+	int kfifo_size_order = order_base_2(nr * sizeof(u32));
 
-	if (kfifo_alloc(fifo, nr * sizeof(u32), GFP_KERNEL))
+	if (kfifo_alloc(fifo, kfifo_size_order, GFP_KERNEL))
 		return -ENOMEM;
 
 	for (i = 0; i < skip_low + skip_high; i++)
@@ -111,11 +113,11 @@ static int cxio_init_resource_fifo_random(struct kfifo *fifo,
 static int cxio_init_qpid_fifo(struct cxio_rdev *rdev_p)
 {
 	u32 i;
+	int kfifo_size_order = order_base_2(T3_MAX_NUM_QP * sizeof(u32));
 
 	spin_lock_init(&rdev_p->rscp->qpid_fifo_lock);
 
-	if (kfifo_alloc(&rdev_p->rscp->qpid_fifo, T3_MAX_NUM_QP * sizeof(u32),
-					      GFP_KERNEL))
+	if (kfifo_alloc(&rdev_p->rscp->qpid_fifo, kfifo_size_order, GFP_KERNEL))
 		return -ENOMEM;
 
 	for (i = 16; i < T3_MAX_NUM_QP; i++)
diff --git a/drivers/media/i2c/cx25840/cx25840-ir.c b/drivers/media/i2c/cx25840/cx25840-ir.c
index 38ce76e..1da0b6c 100644
--- a/drivers/media/i2c/cx25840/cx25840-ir.c
+++ b/drivers/media/i2c/cx25840/cx25840-ir.c
@@ -24,6 +24,7 @@
 #include <linux/slab.h>
 #include <linux/kfifo.h>
 #include <linux/module.h>
+#include <linux/log2.h>
 #include <media/cx25840.h>
 #include <media/rc-core.h>
 
@@ -106,8 +107,10 @@ union cx25840_ir_fifo_rec {
 	struct ir_raw_event ir_core_data;
 };
 
-#define CX25840_IR_RX_KFIFO_SIZE    (256 * sizeof(union cx25840_ir_fifo_rec))
-#define CX25840_IR_TX_KFIFO_SIZE    (256 * sizeof(union cx25840_ir_fifo_rec))
+#define CX25840_IR_RX_KFIFO_SIZE_ORDER	(order_base_2(256 * sizeof(union cx25840_ir_fifo_rec)))
+#define CX25840_IR_RX_KFIFO_SIZE    	(1<<CX25840_IR_RX_KFIFO_SIZE_ORDER)
+#define CX25840_IR_TX_KFIFO_SIZE_ORDER	(order_base_2(256 * sizeof(union cx25840_ir_fifo_rec)))
+#define CX25840_IR_TX_KFIFO_SIZE    	(CX25840_IR_TX_KFIFO_SIZE_ORDER)
 
 struct cx25840_ir_state {
 	struct i2c_client *c;
@@ -1236,7 +1239,7 @@ int cx25840_ir_probe(struct v4l2_subdev *sd)
 
 	spin_lock_init(&ir_state->rx_kfifo_lock);
 	if (kfifo_alloc(&ir_state->rx_kfifo,
-			CX25840_IR_RX_KFIFO_SIZE, GFP_KERNEL)) {
+			CX25840_IR_RX_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		kfree(ir_state);
 		return -ENOMEM;
 	}
diff --git a/drivers/media/pci/cx23885/cx23888-ir.c b/drivers/media/pci/cx23885/cx23888-ir.c
index c4bd1e9..4c6e24b 100644
--- a/drivers/media/pci/cx23885/cx23888-ir.c
+++ b/drivers/media/pci/cx23885/cx23888-ir.c
@@ -23,6 +23,7 @@
 
 #include <linux/kfifo.h>
 #include <linux/slab.h>
+#include <linux/log2.h>
 
 #include <media/v4l2-device.h>
 #include <media/v4l2-chip-ident.h>
@@ -125,8 +126,10 @@ union cx23888_ir_fifo_rec {
 	struct ir_raw_event ir_core_data;
 };
 
-#define CX23888_IR_RX_KFIFO_SIZE    (256 * sizeof(union cx23888_ir_fifo_rec))
-#define CX23888_IR_TX_KFIFO_SIZE    (256 * sizeof(union cx23888_ir_fifo_rec))
+#define CX23888_IR_RX_KFIFO_SIZE_ORDER	(order_base_2(256 * sizeof(union cx23888_ir_fifo_rec)))
+#define CX23888_IR_RX_KFIFO_SIZE    	(1<<CX23888_IR_RX_KFIFO_SIZE_ORDER)
+#define CX23888_IR_TX_KFIFO_SIZE_ORDER	(order_base_2(256 * sizeof(union cx23888_ir_fifo_rec)))
+#define CX23888_IR_TX_KFIFO_SIZE    	(1<<CX23888_IR_TX_KFIFO_SIZE_ORDER)
 
 struct cx23888_ir_state {
 	struct v4l2_subdev sd;
@@ -1213,7 +1216,7 @@ int cx23888_ir_probe(struct cx23885_dev *dev)
 		return -ENOMEM;
 
 	spin_lock_init(&state->rx_kfifo_lock);
-	if (kfifo_alloc(&state->rx_kfifo, CX23888_IR_RX_KFIFO_SIZE, GFP_KERNEL))
+	if (kfifo_alloc(&state->rx_kfifo, CX23888_IR_RX_KFIFO_SIZE_ORDER, GFP_KERNEL))
 		return -ENOMEM;
 
 	state->dev = dev;
diff --git a/drivers/media/pci/meye/meye.c b/drivers/media/pci/meye/meye.c
index 049e186..3bcde0c 100644
--- a/drivers/media/pci/meye/meye.c
+++ b/drivers/media/pci/meye/meye.c
@@ -1759,14 +1759,12 @@ static int meye_probe(struct pci_dev *pcidev, const struct pci_device_id *ent)
 	}
 
 	spin_lock_init(&meye.grabq_lock);
-	if (kfifo_alloc(&meye.grabq, sizeof(int) * MEYE_MAX_BUFNBRS,
-				GFP_KERNEL)) {
+	if (kfifo_alloc(&meye.grabq, MEYE_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		v4l2_err(v4l2_dev, "fifo allocation failed\n");
 		goto outkfifoalloc1;
 	}
 	spin_lock_init(&meye.doneq_lock);
-	if (kfifo_alloc(&meye.doneq, sizeof(int) * MEYE_MAX_BUFNBRS,
-				GFP_KERNEL)) {
+	if (kfifo_alloc(&meye.doneq, MEYE_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		v4l2_err(v4l2_dev, "fifo allocation failed\n");
 		goto outkfifoalloc2;
 	}
diff --git a/drivers/media/pci/meye/meye.h b/drivers/media/pci/meye/meye.h
index 4bdeb03..5d3ab4f 100644
--- a/drivers/media/pci/meye/meye.h
+++ b/drivers/media/pci/meye/meye.h
@@ -260,6 +260,7 @@
 /* private API definitions */
 #include <linux/meye.h>
 #include <linux/mutex.h>
+#include <linux/log2.h>
 
 
 /* Enable jpg software correction */
@@ -270,6 +271,7 @@
 
 /* Maximum number of buffers */
 #define MEYE_MAX_BUFNBRS	32
+#define MEYE_KFIFO_SIZE_ORDER	(order_base_2(MEYE_MAX_BUFNBRS * sizeof(int)))
 
 /* State of a buffer */
 #define MEYE_BUF_UNUSED	0	/* not used */
diff --git a/drivers/media/rc/ir-raw.c b/drivers/media/rc/ir-raw.c
index 97dc8d1..e4d1ec8 100644
--- a/drivers/media/rc/ir-raw.c
+++ b/drivers/media/rc/ir-raw.c
@@ -18,6 +18,7 @@
 #include <linux/kmod.h>
 #include <linux/sched.h>
 #include <linux/freezer.h>
+#include <linux/log2.h>
 #include "rc-core-priv.h"
 
 /* Define the max number of pulse/space transitions to buffer */
@@ -252,6 +253,8 @@ int ir_raw_event_register(struct rc_dev *dev)
 {
 	int rc;
 	struct ir_raw_handler *handler;
+	int kfifo_size_order = order_base_2(sizeof(struct ir_raw_event) *
+					    MAX_IR_EVENT_SIZE);
 
 	if (!dev)
 		return -EINVAL;
@@ -262,9 +265,7 @@ int ir_raw_event_register(struct rc_dev *dev)
 
 	dev->raw->dev = dev;
 	dev->raw->enabled_protocols = ~0;
-	rc = kfifo_alloc(&dev->raw->kfifo,
-			 sizeof(struct ir_raw_event) * MAX_IR_EVENT_SIZE,
-			 GFP_KERNEL);
+	rc = kfifo_alloc(&dev->raw->kfifo, kfifo_size_order, GFP_KERNEL);
 	if (rc < 0)
 		goto out;
 
diff --git a/drivers/memstick/host/r592.h b/drivers/memstick/host/r592.h
index c5726c1..6fc19f4 100644
--- a/drivers/memstick/host/r592.h
+++ b/drivers/memstick/host/r592.h
@@ -143,7 +143,7 @@ struct r592_device {
 	struct task_struct *io_thread;
 	bool parallel_mode;
 
-	DECLARE_KFIFO(pio_fifo, u8, sizeof(u32));
+	DECLARE_KFIFO(pio_fifo, u8, 2);
 
 	/* DMA area */
 	int dma_capable;
diff --git a/drivers/mmc/card/sdio_uart.c b/drivers/mmc/card/sdio_uart.c
index bd57a11..c54a7c5 100644
--- a/drivers/mmc/card/sdio_uart.c
+++ b/drivers/mmc/card/sdio_uart.c
@@ -43,12 +43,14 @@
 #include <linux/mmc/card.h>
 #include <linux/mmc/sdio_func.h>
 #include <linux/mmc/sdio_ids.h>
+#include <linux/log2.h>
 
 
 #define UART_NR		8	/* Number of UARTs this driver can handle */
 
 
 #define FIFO_SIZE	PAGE_SIZE
+#define FIFO_SIZE_ORDER	PAGE_SHIFT
 #define WAKEUP_CHARS	256
 
 struct uart_icount {
@@ -93,7 +95,7 @@ static int sdio_uart_add_port(struct sdio_uart_port *port)
 
 	mutex_init(&port->func_lock);
 	spin_lock_init(&port->write_lock);
-	if (kfifo_alloc(&port->xmit_fifo, FIFO_SIZE, GFP_KERNEL))
+	if (kfifo_alloc(&port->xmit_fifo, FIFO_SIZE_ORDER, GFP_KERNEL))
 		return -ENOMEM;
 
 	spin_lock(&sdio_uart_table_lock);
diff --git a/drivers/mtd/sm_ftl.c b/drivers/mtd/sm_ftl.c
index 8dd6ba5..672ef47 100644
--- a/drivers/mtd/sm_ftl.c
+++ b/drivers/mtd/sm_ftl.c
@@ -17,6 +17,7 @@
 #include <linux/bitops.h>
 #include <linux/slab.h>
 #include <linux/mtd/nand_ecc.h>
+#include <linux/log2.h>
 #include "nand/sm_common.h"
 #include "sm_ftl.h"
 
@@ -766,6 +767,7 @@ static int sm_init_zone(struct sm_ftl *ftl, int zone_num)
 	int lba;
 	int i = 0;
 	int len;
+	int kfifo_size_order;
 
 	dbg("initializing zone %d", zone_num);
 
@@ -778,7 +780,8 @@ static int sm_init_zone(struct sm_ftl *ftl, int zone_num)
 
 
 	/* Allocate memory for free sectors FIFO */
-	if (kfifo_alloc(&zone->free_sectors, ftl->zone_size * 2, GFP_KERNEL)) {
+	kfifo_size_order = order_base_2(ftl->zone_size * 2);
+	if (kfifo_alloc(&zone->free_sectors, kfifo_size_order, GFP_KERNEL)) {
 		kfree(zone->lba_to_phys_table);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 0c02f04..ea5ddf4 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -25,6 +25,8 @@
 #include "cmd.h"
 #include "mesh.h"
 
+#define KFIFO_SIZE_ORDER	6
+
 #define DRIVER_RELEASE_VERSION "323.p0"
 const char lbs_driver_version[] = "COMM-USB8388-" DRIVER_RELEASE_VERSION
 #ifdef  DEBUG
@@ -914,7 +916,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
 	priv->resp_len[0] = priv->resp_len[1] = 0;
 
 	/* Create the event FIFO */
-	ret = kfifo_alloc(&priv->event_fifo, sizeof(u32) * 16, GFP_KERNEL);
+	ret = kfifo_alloc(&priv->event_fifo, KFIFO_SIZE_ORDER, GFP_KERNEL);
 	if (ret) {
 		pr_err("Out of memory allocating event FIFO buffer\n");
 		goto out;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 44f8b3f..c8f68485 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -979,12 +979,11 @@ static int rt2x00lib_probe_hw(struct rt2x00_dev *rt2x00dev)
 		 * tx_queues * entry_num and round up to the nearest
 		 * power of 2.
 		 */
-		int kfifo_size =
-			roundup_pow_of_two(rt2x00dev->ops->tx_queues *
+		int kfifo_size_order = order_base_2(rt2x00dev->ops->tx_queues *
 					   rt2x00dev->ops->tx->entry_num *
 					   sizeof(u32));
 
-		status = kfifo_alloc(&rt2x00dev->txstatus_fifo, kfifo_size,
+		status = kfifo_alloc(&rt2x00dev->txstatus_fifo, kfifo_size_order,
 				     GFP_KERNEL);
 		if (status)
 			return status;
diff --git a/drivers/pci/pcie/aer/aerdrv_core.c b/drivers/pci/pcie/aer/aerdrv_core.c
index 421bbc5..ec9284a 100644
--- a/drivers/pci/pcie/aer/aerdrv_core.c
+++ b/drivers/pci/pcie/aer/aerdrv_core.c
@@ -574,7 +574,6 @@ static void handle_error_source(struct pcie_device *aerdev,
 static void aer_recover_work_func(struct work_struct *work);
 
 #define AER_RECOVER_RING_ORDER		4
-#define AER_RECOVER_RING_SIZE		(1 << AER_RECOVER_RING_ORDER)
 
 struct aer_recover_entry
 {
@@ -585,7 +584,7 @@ struct aer_recover_entry
 };
 
 static DEFINE_KFIFO(aer_recover_ring, struct aer_recover_entry,
-		    AER_RECOVER_RING_SIZE);
+		    AER_RECOVER_RING_ORDER);
 /*
  * Mutual exclusion for writers of aer_recover_ring, reader side don't
  * need lock, because there is only one reader and lock is not needed
diff --git a/drivers/platform/x86/fujitsu-laptop.c b/drivers/platform/x86/fujitsu-laptop.c
index c4c1a54..185bd55 100644
--- a/drivers/platform/x86/fujitsu-laptop.c
+++ b/drivers/platform/x86/fujitsu-laptop.c
@@ -66,6 +66,7 @@
 #include <linux/backlight.h>
 #include <linux/input.h>
 #include <linux/kfifo.h>
+#include <linux/log2.h>
 #include <linux/video_output.h>
 #include <linux/platform_device.h>
 #include <linux/slab.h>
@@ -116,6 +117,7 @@
 
 #define MAX_HOTKEY_RINGBUFFER_SIZE 100
 #define RINGBUFFERSIZE 40
+#define KFIFO_SIZE_ORDER	(order_base_2(RINGBUFFERSIZE * sizeof(int)))
 
 /* Debugging */
 #define FUJLAPTOP_LOG	   ACPI_FUJITSU_HID ": "
@@ -825,8 +827,7 @@ static int acpi_fujitsu_hotkey_add(struct acpi_device *device)
 
 	/* kfifo */
 	spin_lock_init(&fujitsu_hotkey->fifo_lock);
-	error = kfifo_alloc(&fujitsu_hotkey->fifo, RINGBUFFERSIZE * sizeof(int),
-			GFP_KERNEL);
+	error = kfifo_alloc(&fujitsu_hotkey->fifo, KFIFO_SIZE_ORDER, GFP_KERNEL);
 	if (error) {
 		pr_err("kfifo_alloc failed\n");
 		goto err_stop;
diff --git a/drivers/platform/x86/sony-laptop.c b/drivers/platform/x86/sony-laptop.c
index daaddec..ee57eac 100644
--- a/drivers/platform/x86/sony-laptop.c
+++ b/drivers/platform/x86/sony-laptop.c
@@ -183,7 +183,7 @@ static void sony_nc_rfkill_update(void);
 
 /*********** Input Devices ***********/
 
-#define SONY_LAPTOP_BUF_SIZE	128
+#define SONY_LAPTOP_KFIFO_SIZE_ORDER	7
 struct sony_laptop_input_s {
 	atomic_t		users;
 	struct input_dev	*jog_dev;
@@ -447,7 +447,7 @@ static int sony_laptop_setup_input(struct acpi_device *acpi_device)
 	/* kfifo */
 	spin_lock_init(&sony_laptop_input.fifo_lock);
 	error = kfifo_alloc(&sony_laptop_input.fifo,
-			    SONY_LAPTOP_BUF_SIZE, GFP_KERNEL);
+			    SONY_LAPTOP_KFIFO_SIZE_ORDER, GFP_KERNEL);
 	if (error) {
 		pr_err("kfifo_alloc failed\n");
 		goto err_dec_users;
@@ -3752,7 +3752,7 @@ static int sonypi_compat_init(void)
 
 	spin_lock_init(&sonypi_compat.fifo_lock);
 	error =
-	 kfifo_alloc(&sonypi_compat.fifo, SONY_LAPTOP_BUF_SIZE, GFP_KERNEL);
+	 kfifo_alloc(&sonypi_compat.fifo, SONY_LAPTOP_KFIFO_SIZE_ORDER, GFP_KERNEL);
 	if (error) {
 		pr_err("kfifo_alloc failed\n");
 		return error;
diff --git a/drivers/rapidio/devices/tsi721.c b/drivers/rapidio/devices/tsi721.c
index 6faba40..a731e87 100644
--- a/drivers/rapidio/devices/tsi721.c
+++ b/drivers/rapidio/devices/tsi721.c
@@ -32,6 +32,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/interrupt.h>
 #include <linux/kfifo.h>
+#include <linux/log2.h>
 #include <linux/delay.h>
 
 #include "tsi721.h"
@@ -970,11 +971,11 @@ static void tsi721_init_sr2pc_mapping(struct tsi721_device *priv)
  */
 static int tsi721_port_write_init(struct tsi721_device *priv)
 {
+	int kfifo_size_order = order_base_2(TSI721_RIO_PW_MSG_SIZE * 32);
 	priv->pw_discard_count = 0;
 	INIT_WORK(&priv->pw_work, tsi721_pw_dpc);
 	spin_lock_init(&priv->pw_fifo_lock);
-	if (kfifo_alloc(&priv->pw_fifo,
-			TSI721_RIO_PW_MSG_SIZE * 32, GFP_KERNEL)) {
+	if (kfifo_alloc(&priv->pw_fifo, kfifo_size_order, GFP_KERNEL)) {
 		dev_err(&priv->pdev->dev, "PW FIFO allocation failed\n");
 		return -ENOMEM;
 	}
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 552e8a2..bdb09bf 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -35,6 +35,7 @@
 #include <linux/crypto.h>
 #include <linux/delay.h>
 #include <linux/kfifo.h>
+#include <linux/log2.h>
 #include <linux/scatterlist.h>
 #include <linux/module.h>
 #include <net/tcp.h>
@@ -1113,6 +1114,7 @@ int iscsi_tcp_r2tpool_alloc(struct iscsi_session *session)
 {
 	int i;
 	int cmd_i;
+	int kfifo_size_order;
 
 	/*
 	 * initialize per-task: R2T pool and xmit queue
@@ -1135,8 +1137,8 @@ int iscsi_tcp_r2tpool_alloc(struct iscsi_session *session)
 		}
 
 		/* R2T xmit queue */
-		if (kfifo_alloc(&tcp_task->r2tqueue,
-		      session->max_r2t * 4 * sizeof(void*), GFP_KERNEL)) {
+		kfifo_size_order = order_base_2(session->max_r2t * 4 * sizeof(void *));
+		if (kfifo_alloc(&tcp_task->r2tqueue, kfifo_size_order, GFP_KERNEL)) {
 			iscsi_pool_free(&tcp_task->r2tpool);
 			goto r2t_alloc_fail;
 		}
diff --git a/drivers/staging/omapdrm/omap_plane.c b/drivers/staging/omapdrm/omap_plane.c
index 2a8e5ba..40f057f 100644
--- a/drivers/staging/omapdrm/omap_plane.c
+++ b/drivers/staging/omapdrm/omap_plane.c
@@ -28,6 +28,8 @@
  */
 #define omap_plane _omap_plane
 
+#define OMAP_KFIFO_SIZE_ORDER	4
+
 /*
  * plane funcs
  */
@@ -508,7 +510,8 @@ struct drm_plane *omap_plane_init(struct drm_device *dev,
 
 	mutex_init(&omap_plane->unpin_mutex);
 
-	ret = kfifo_alloc(&omap_plane->unpin_fifo, 16, GFP_KERNEL);
+	ret = kfifo_alloc(&omap_plane->unpin_fifo, OMAP_KFIFO_SIZE_ORDER,
+			  GFP_KERNEL);
 	if (ret) {
 		dev_err(dev->dev, "could not allocate unpin FIFO\n");
 		goto fail;
diff --git a/drivers/tty/n_gsm.c b/drivers/tty/n_gsm.c
index dcc0430..b3b1b1c 100644
--- a/drivers/tty/n_gsm.c
+++ b/drivers/tty/n_gsm.c
@@ -66,6 +66,8 @@
 static int debug;
 module_param(debug, int, 0600);
 
+#define KFIFO_SIZE_ORDER	12
+
 /* Defaults: these are from the specification */
 
 #define T1	10		/* 100mS */
@@ -1636,7 +1638,7 @@ static struct gsm_dlci *gsm_dlci_alloc(struct gsm_mux *gsm, int addr)
 	spin_lock_init(&dlci->lock);
 	mutex_init(&dlci->mutex);
 	dlci->fifo = &dlci->_fifo;
-	if (kfifo_alloc(&dlci->_fifo, 4096, GFP_KERNEL) < 0) {
+	if (kfifo_alloc(&dlci->_fifo, KFIFO_SIZE_ORDER, GFP_KERNEL) < 0) {
 		kfree(dlci);
 		return NULL;
 	}
diff --git a/drivers/tty/nozomi.c b/drivers/tty/nozomi.c
index a0c69ab..8b54da3 100644
--- a/drivers/tty/nozomi.c
+++ b/drivers/tty/nozomi.c
@@ -128,8 +128,7 @@ static int debug;
 #define NTTY_TTY_MAXMINORS	256
 #define NTTY_FIFO_BUFFER_SIZE	8192
 
-/* Must be power of 2 */
-#define FIFO_BUFFER_SIZE_UL	8192
+#define FIFO_BUFFER_SIZE_ORDER	13
 
 /* Size of tmp send buffer to card */
 #define SEND_BUF_MAX		1024
@@ -1428,7 +1427,7 @@ static int nozomi_card_init(struct pci_dev *pdev,
 	}
 
 	for (i = PORT_MDM; i < MAX_PORT; i++) {
-		if (kfifo_alloc(&dc->port[i].fifo_ul, FIFO_BUFFER_SIZE_UL,
+		if (kfifo_alloc(&dc->port[i].fifo_ul, FIFO_BUFFER_SIZE_ORDER,
 					GFP_KERNEL)) {
 			dev_err(&pdev->dev,
 					"Could not allocate kfifo buffer\n");
diff --git a/drivers/tty/serial/ifx6x60.c b/drivers/tty/serial/ifx6x60.c
index 675d94a..f80dc2c 100644
--- a/drivers/tty/serial/ifx6x60.c
+++ b/drivers/tty/serial/ifx6x60.c
@@ -880,7 +880,7 @@ static int ifx_spi_create_port(struct ifx_spi_device *ifx_dev)
 	lockdep_set_class_and_subclass(&ifx_dev->fifo_lock,
 		&ifx_spi_key, 0);
 
-	if (kfifo_alloc(&ifx_dev->tx_fifo, IFX_SPI_FIFO_SIZE, GFP_KERNEL)) {
+	if (kfifo_alloc(&ifx_dev->tx_fifo, IFX_SPI_FIFO_SIZE_ORDER, GFP_KERNEL)) {
 		ret = -ENOMEM;
 		goto error_ret;
 	}
diff --git a/drivers/tty/serial/ifx6x60.h b/drivers/tty/serial/ifx6x60.h
index 4fbddc2..da4fd1c 100644
--- a/drivers/tty/serial/ifx6x60.h
+++ b/drivers/tty/serial/ifx6x60.h
@@ -31,7 +31,8 @@
 
 #define IFX_SPI_MAX_MINORS		1
 #define IFX_SPI_TRANSFER_SIZE		2048
-#define IFX_SPI_FIFO_SIZE		4096
+#define IFX_SPI_FIFO_SIZE_ORDER		12
+#define IFX_SPI_FIFO_SIZE		(1 << IFX_SPI_FIFO_SIZE_ORDER)
 
 #define IFX_SPI_HEADER_OVERHEAD		4
 #define IFX_RESET_TIMEOUT		msecs_to_jiffies(50)
diff --git a/drivers/tty/serial/kgdb_nmi.c b/drivers/tty/serial/kgdb_nmi.c
index 6ac2b79..947dd72 100644
--- a/drivers/tty/serial/kgdb_nmi.c
+++ b/drivers/tty/serial/kgdb_nmi.c
@@ -26,6 +26,7 @@
 #include <linux/interrupt.h>
 #include <linux/hrtimer.h>
 #include <linux/tick.h>
+#include <linux/log2.h>
 #include <linux/kfifo.h>
 #include <linux/kgdb.h>
 #include <linux/kdb.h>
@@ -75,13 +76,13 @@ static struct console kgdb_nmi_console = {
  * This is usually the maximum rate on debug ports. We make fifo large enough
  * to make copy-pasting to the terminal usable.
  */
-#define KGDB_NMI_BAUD		115200
-#define KGDB_NMI_FIFO_SIZE	roundup_pow_of_two(KGDB_NMI_BAUD / 8 / HZ)
+#define KGDB_NMI_BAUD			115200
+#define KGDB_NMI_FIFO_SIZE_ORDER	order_base_2(KGDB_NMI_BAUD / 8 / HZ)
 
 struct kgdb_nmi_tty_priv {
 	struct tty_port port;
 	struct tasklet_struct tlet;
-	STRUCT_KFIFO(char, KGDB_NMI_FIFO_SIZE) fifo;
+	STRUCT_KFIFO(char, KGDB_NMI_FIFO_SIZE_ORDER) fifo;
 };
 
 static struct kgdb_nmi_tty_priv *kgdb_nmi_port_to_priv(struct tty_port *port)
diff --git a/drivers/usb/host/fhci.h b/drivers/usb/host/fhci.h
index 7cc1c32..e4a0ac6 100644
--- a/drivers/usb/host/fhci.h
+++ b/drivers/usb/host/fhci.h
@@ -24,6 +24,7 @@
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
 #include <linux/kfifo.h>
+#include <linux/log2.h>
 #include <linux/io.h>
 #include <linux/usb.h>
 #include <linux/usb/hcd.h>
@@ -478,7 +479,8 @@ static inline struct usb_hcd *fhci_to_hcd(struct fhci_hcd *fhci)
 /* fifo of pointers */
 static inline int cq_new(struct kfifo *fifo, int size)
 {
-	return kfifo_alloc(fifo, size * sizeof(void *), GFP_KERNEL);
+	int kfifo_size_order = order_base_2(size * sizeof(void *));
+	return kfifo_alloc(fifo, kfifo_size_order, GFP_KERNEL);
 }
 
 static inline void cq_delete(struct kfifo *kfifo)
diff --git a/drivers/usb/serial/cypress_m8.c b/drivers/usb/serial/cypress_m8.c
index fd8c35f..a4d7cd1 100644
--- a/drivers/usb/serial/cypress_m8.c
+++ b/drivers/usb/serial/cypress_m8.c
@@ -54,7 +54,7 @@ static bool unstable_bauds;
 #define DRIVER_DESC "Cypress USB to Serial Driver"
 
 /* write buffer size defines */
-#define CYPRESS_BUF_SIZE	1024
+#define CYPRESS_KFIFO_SIZE_ORDER	10
 
 static const struct usb_device_id id_table_earthmate[] = {
 	{ USB_DEVICE(VENDOR_ID_DELORME, PRODUCT_ID_EARTHMATEUSB) },
@@ -445,7 +445,7 @@ static int cypress_generic_port_probe(struct usb_serial_port *port)
 
 	priv->comm_is_ok = !0;
 	spin_lock_init(&priv->lock);
-	if (kfifo_alloc(&priv->write_fifo, CYPRESS_BUF_SIZE, GFP_KERNEL)) {
+	if (kfifo_alloc(&priv->write_fifo, CYPRESS_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		kfree(priv);
 		return -ENOMEM;
 	}
diff --git a/drivers/usb/serial/io_ti.c b/drivers/usb/serial/io_ti.c
index 58184f3..a19018b 100644
--- a/drivers/usb/serial/io_ti.c
+++ b/drivers/usb/serial/io_ti.c
@@ -64,7 +64,7 @@
 
 #define EDGE_CLOSING_WAIT	4000	/* in .01 sec */
 
-#define EDGE_OUT_BUF_SIZE	1024
+#define EDGE_KFIFO_SIZE_ORDER	10
 
 
 /* Product information read from the Edgeport */
@@ -2567,7 +2567,7 @@ static int edge_port_probe(struct usb_serial_port *port)
 	if (!edge_port)
 		return -ENOMEM;
 
-	ret = kfifo_alloc(&edge_port->write_fifo, EDGE_OUT_BUF_SIZE,
+	ret = kfifo_alloc(&edge_port->write_fifo, EDGE_KFIFO_SIZE_ORDER,
 								GFP_KERNEL);
 	if (ret) {
 		kfree(edge_port);
diff --git a/drivers/usb/serial/ti_usb_3410_5052.c b/drivers/usb/serial/ti_usb_3410_5052.c
index f2530d2..777e90a 100644
--- a/drivers/usb/serial/ti_usb_3410_5052.c
+++ b/drivers/usb/serial/ti_usb_3410_5052.c
@@ -45,7 +45,8 @@
 
 #define TI_FIRMWARE_BUF_SIZE	16284
 
-#define TI_WRITE_BUF_SIZE	1024
+#define TI_KFIFO_SIZE_ORDER	10
+#define TI_KFIFO_SIZE		(1 << TI_KFIFO_SIZE_ORDER)
 
 #define TI_TRANSFER_TIMEOUT	2
 
@@ -434,7 +435,7 @@ static int ti_port_probe(struct usb_serial_port *port)
 	tport->tp_closing_wait = closing_wait;
 	init_waitqueue_head(&tport->tp_msr_wait);
 	init_waitqueue_head(&tport->tp_write_wait);
-	if (kfifo_alloc(&tport->write_fifo, TI_WRITE_BUF_SIZE, GFP_KERNEL)) {
+	if (kfifo_alloc(&tport->write_fifo, TI_KFIFO_SIZE_ORDER, GFP_KERNEL)) {
 		kfree(tport);
 		return -ENOMEM;
 	}
@@ -1355,7 +1356,7 @@ static int ti_get_serial_info(struct ti_port *tport,
 	ret_serial.line = port->serial->minor;
 	ret_serial.port = port->number - port->serial->minor;
 	ret_serial.flags = tport->tp_flags;
-	ret_serial.xmit_fifo_size = TI_WRITE_BUF_SIZE;
+	ret_serial.xmit_fifo_size = TI_KFIFO_SIZE;
 	ret_serial.baud_base = tport->tp_tdev->td_is_3410 ? 921600 : 460800;
 	ret_serial.closing_wait = tport->tp_closing_wait;
 
diff --git a/drivers/usb/serial/usb-serial.c b/drivers/usb/serial/usb-serial.c
index 64bda13..11ca271 100644
--- a/drivers/usb/serial/usb-serial.c
+++ b/drivers/usb/serial/usb-serial.c
@@ -934,7 +934,7 @@ static int usb_serial_probe(struct usb_interface *interface,
 	for (i = 0; i < num_bulk_out; ++i) {
 		endpoint = bulk_out_endpoint[i];
 		port = serial->port[i];
-		if (kfifo_alloc(&port->write_fifo, PAGE_SIZE, GFP_KERNEL))
+		if (kfifo_alloc(&port->write_fifo, PAGE_SHIFT, GFP_KERNEL))
 			goto probe_error;
 		buffer_size = serial->type->bulk_out_size;
 		if (!buffer_size)
diff --git a/include/linux/kfifo.h b/include/linux/kfifo.h
index 4bf984e..28dfe98 100644
--- a/include/linux/kfifo.h
+++ b/include/linux/kfifo.h
@@ -76,8 +76,8 @@ struct __kfifo {
 	type		buf[((size < 2) || (size & (size - 1))) ? -1 : size]; \
 }
 
-#define STRUCT_KFIFO(type, size) \
-	struct __STRUCT_KFIFO(type, size, 0)
+#define STRUCT_KFIFO(type, size_order) \
+	struct __STRUCT_KFIFO(type, (1<<(size_order)), 0)
 
 #define __STRUCT_KFIFO_PTR(type, recsize) \
 { \
@@ -93,11 +93,11 @@ struct __kfifo {
  */
 struct kfifo __STRUCT_KFIFO_PTR(unsigned char, 0);
 
-#define STRUCT_KFIFO_REC_1(size) \
-	struct __STRUCT_KFIFO(unsigned char, size, 1)
+#define STRUCT_KFIFO_REC_1(size_order) \
+	struct __STRUCT_KFIFO(unsigned char, (1<<(size_order)), 1)
 
-#define STRUCT_KFIFO_REC_2(size) \
-	struct __STRUCT_KFIFO(unsigned char, size, 2)
+#define STRUCT_KFIFO_REC_2(size_order) \
+	struct __STRUCT_KFIFO(unsigned char, (1<<(size_order)), 2)
 
 /*
  * define kfifo_rec types
@@ -123,9 +123,9 @@ struct kfifo_rec_ptr_2 __STRUCT_KFIFO_PTR(unsigned char, 2);
  * DECLARE_KFIFO - macro to declare a fifo object
  * @fifo: name of the declared fifo
  * @type: type of the fifo elements
- * @size: the number of elements in the fifo, this must be a power of 2
+ * @size_order: request 2^size_order fifo elements
  */
-#define DECLARE_KFIFO(fifo, type, size)	STRUCT_KFIFO(type, size) fifo
+#define DECLARE_KFIFO(fifo, type, size_order)	STRUCT_KFIFO(type, size_order) fifo
 
 /**
  * INIT_KFIFO - Initialize a fifo declared by DECLARE_KFIFO
@@ -146,12 +146,12 @@ struct kfifo_rec_ptr_2 __STRUCT_KFIFO_PTR(unsigned char, 2);
  * DEFINE_KFIFO - macro to define and initialize a fifo
  * @fifo: name of the declared fifo datatype
  * @type: type of the fifo elements
- * @size: the number of elements in the fifo, this must be a power of 2
+ * @size_order: request 2^size_order fifo elements
  *
  * Note: the macro can be used for global and local fifo data type variables.
  */
-#define DEFINE_KFIFO(fifo, type, size) \
-	DECLARE_KFIFO(fifo, type, size) = \
+#define DEFINE_KFIFO(fifo, type, size_order) \
+	DECLARE_KFIFO(fifo, type, size_order) = \
 	(typeof(fifo)) { \
 		{ \
 			{ \
@@ -317,22 +317,21 @@ __kfifo_uint_must_check_helper( \
 /**
  * kfifo_alloc - dynamically allocates a new fifo buffer
  * @fifo: pointer to the fifo
- * @size: the number of elements in the fifo, this must be a power of 2
+ * @size_order: request 2^size_order fifo elements
  * @gfp_mask: get_free_pages mask, passed to kmalloc()
  *
  * This macro dynamically allocates a new fifo buffer.
  *
- * The numer of elements will be rounded-up to a power of 2.
  * The fifo will be release with kfifo_free().
  * Return 0 if no error, otherwise an error code.
  */
-#define kfifo_alloc(fifo, size, gfp_mask) \
+#define kfifo_alloc(fifo, size_order, gfp_mask) \
 __kfifo_int_must_check_helper( \
 ({ \
 	typeof((fifo) + 1) __tmp = (fifo); \
 	struct __kfifo *__kfifo = &__tmp->kfifo; \
 	__is_kfifo_ptr(__tmp) ? \
-	__kfifo_alloc(__kfifo, size, sizeof(*__tmp->type), gfp_mask) : \
+	__kfifo_alloc(__kfifo, size_order, sizeof(*__tmp->type), gfp_mask) : \
 	-EINVAL; \
 }) \
 )
@@ -745,7 +744,7 @@ __kfifo_uint_must_check_helper( \
 }) \
 )
 
-extern int __kfifo_alloc(struct __kfifo *fifo, unsigned int size,
+extern int __kfifo_alloc(struct __kfifo *fifo, int size_order,
 	size_t esize, gfp_t gfp_mask);
 
 extern void __kfifo_free(struct __kfifo *fifo);
diff --git a/include/linux/rio.h b/include/linux/rio.h
index a3e7842..05ff6bb 100644
--- a/include/linux/rio.h
+++ b/include/linux/rio.h
@@ -70,6 +70,7 @@
 #define RIO_OUTB_MBOX_RESOURCE	2
 
 #define RIO_PW_MSG_SIZE		64
+#define RIO_KFIFO_SIZE_ORDER	11	/* 64 * 32 */
 
 /*
  * A component tag value (stored in the component tag CSR) is used as device's
diff --git a/include/media/lirc_dev.h b/include/media/lirc_dev.h
index 168dd0b..7816d39 100644
--- a/include/media/lirc_dev.h
+++ b/include/media/lirc_dev.h
@@ -19,6 +19,7 @@
 #include <linux/ioctl.h>
 #include <linux/poll.h>
 #include <linux/kfifo.h>
+#include <linux/log2.h>
 #include <media/lirc.h>
 
 struct lirc_buffer {
@@ -50,12 +51,13 @@ static inline int lirc_buffer_init(struct lirc_buffer *buf,
 				    unsigned int size)
 {
 	int ret;
+	int kfifo_size_order = order_base_2(size * chunk_size);
 
 	init_waitqueue_head(&buf->wait_poll);
 	spin_lock_init(&buf->fifo_lock);
 	buf->chunk_size = chunk_size;
 	buf->size = size;
-	ret = kfifo_alloc(&buf->fifo, size * chunk_size, GFP_KERNEL);
+	ret = kfifo_alloc(&buf->fifo, kfifo_size_order, GFP_KERNEL);
 	if (ret == 0)
 		buf->fifo_initialized = 1;
 
diff --git a/kernel/kfifo.c b/kernel/kfifo.c
index d07f480..be1c2a0 100644
--- a/kernel/kfifo.c
+++ b/kernel/kfifo.c
@@ -35,15 +35,10 @@ static inline unsigned int kfifo_unused(struct __kfifo *fifo)
 	return (fifo->mask + 1) - (fifo->in - fifo->out);
 }
 
-int __kfifo_alloc(struct __kfifo *fifo, unsigned int size,
+int __kfifo_alloc(struct __kfifo *fifo, int size_order,
 		size_t esize, gfp_t gfp_mask)
 {
-	/*
-	 * round down to the next power of 2, since our 'let the indices
-	 * wrap' technique works only in this case.
-	 */
-	if (!is_power_of_2(size))
-		size = rounddown_pow_of_two(size);
+	unsigned int size = 1 << size_order;
 
 	fifo->in = 0;
 	fifo->out = 0;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index c6e4dd3..827bbf3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1189,7 +1189,6 @@ out:
 EXPORT_SYMBOL_GPL(memory_failure);
 
 #define MEMORY_FAILURE_FIFO_ORDER	4
-#define MEMORY_FAILURE_FIFO_SIZE	(1 << MEMORY_FAILURE_FIFO_ORDER)
 
 struct memory_failure_entry {
 	unsigned long pfn;
@@ -1199,7 +1198,7 @@ struct memory_failure_entry {
 
 struct memory_failure_cpu {
 	DECLARE_KFIFO(fifo, struct memory_failure_entry,
-		      MEMORY_FAILURE_FIFO_SIZE);
+		      MEMORY_FAILURE_FIFO_ORDER);
 	spinlock_t lock;
 	struct work_struct work;
 };
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 0a8d6eb..0a12fd5 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -31,6 +31,7 @@
 #include <linux/kfifo.h>
 #include <linux/vmalloc.h>
 #include <linux/gfp.h>
+#include <linux/log2.h>
 #include <net/net_namespace.h>
 
 #include "dccp.h"
@@ -166,10 +167,11 @@ static __init int setup_jprobe(void)
 static __init int dccpprobe_init(void)
 {
 	int ret = -ENOMEM;
+	int kfifo_size_order = order_base_2(bufsize);
 
 	init_waitqueue_head(&dccpw.wait);
 	spin_lock_init(&dccpw.lock);
-	if (kfifo_alloc(&dccpw.fifo, bufsize, GFP_KERNEL))
+	if (kfifo_alloc(&dccpw.fifo, kfifo_size_order, GFP_KERNEL))
 		return ret;
 	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
 		goto err0;
@@ -200,7 +202,7 @@ module_exit(dccpprobe_exit);
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
-MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k , should be power of 2. If not, will roundup to power of 2)");
 module_param(bufsize, int, 0);
 
 MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>");
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 5f7518d..1736ef4 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -33,6 +33,7 @@
 #include <linux/module.h>
 #include <linux/kfifo.h>
 #include <linux/time.h>
+#include <linux/log2.h>
 #include <net/net_namespace.h>
 
 #include <net/sctp/sctp.h>
@@ -47,7 +48,7 @@ MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
 static int bufsize __read_mostly = 64 * 1024;
-MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k, should be power of 2. If not, will roundup to power of 2)");
 module_param(bufsize, int, 0);
 
 static int full __read_mostly = 1;
@@ -182,10 +183,11 @@ static struct jprobe sctp_recv_probe = {
 static __init int sctpprobe_init(void)
 {
 	int ret = -ENOMEM;
+	int kfifo_size_order = order_base_2(bufsize);
 
 	init_waitqueue_head(&sctpw.wait);
 	spin_lock_init(&sctpw.lock);
-	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
+	if (kfifo_alloc(&sctpw.fifo, kfifo_size_order, GFP_KERNEL))
 		return ret;
 
 	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
diff --git a/samples/kfifo/bytestream-example.c b/samples/kfifo/bytestream-example.c
index cfe40ad..eb3a46e 100644
--- a/samples/kfifo/bytestream-example.c
+++ b/samples/kfifo/bytestream-example.c
@@ -18,7 +18,7 @@
  */
 
 /* fifo size in elements (bytes) */
-#define FIFO_SIZE	32
+#define FIFO_SIZE_ORDER	5
 
 /* name of the proc entry */
 #define	PROC_FIFO	"bytestream-fifo"
@@ -41,10 +41,10 @@ static DEFINE_MUTEX(write_lock);
 #ifdef DYNAMIC
 static struct kfifo test;
 #else
-static DECLARE_KFIFO(test, unsigned char, FIFO_SIZE);
+static DECLARE_KFIFO(test, unsigned char, FIFO_SIZE_ORDER);
 #endif
 
-static const unsigned char expected_result[FIFO_SIZE] = {
+static const unsigned char expected_result[1<<FIFO_SIZE_ORDER] = {
 	 3,  4,  5,  6,  7,  8,  9,  0,
 	 1, 20, 21, 22, 23, 24, 25, 26,
 	27, 28, 29, 30, 31, 32, 33, 34,
@@ -156,7 +156,7 @@ static int __init example_init(void)
 #ifdef DYNAMIC
 	int ret;
 
-	ret = kfifo_alloc(&test, FIFO_SIZE, GFP_KERNEL);
+	ret = kfifo_alloc(&test, FIFO_SIZE_ORDER, GFP_KERNEL);
 	if (ret) {
 		printk(KERN_ERR "error kfifo_alloc\n");
 		return ret;
diff --git a/samples/kfifo/dma-example.c b/samples/kfifo/dma-example.c
index 0647379..bbc0787 100644
--- a/samples/kfifo/dma-example.c
+++ b/samples/kfifo/dma-example.c
@@ -16,7 +16,8 @@
  */
 
 /* fifo size in elements (bytes) */
-#define FIFO_SIZE	32
+#define FIFO_SIZE_ORDER	5
+#define FIFO_SIZE	(1<< FIFO_SIZE_ORDER)
 
 static struct kfifo fifo;
 
@@ -29,7 +30,7 @@ static int __init example_init(void)
 
 	printk(KERN_INFO "DMA fifo test start\n");
 
-	if (kfifo_alloc(&fifo, FIFO_SIZE, GFP_KERNEL)) {
+	if (kfifo_alloc(&fifo, FIFO_SIZE_ORDER, GFP_KERNEL)) {
 		printk(KERN_WARNING "error kfifo_alloc\n");
 		return -ENOMEM;
 	}
diff --git a/samples/kfifo/inttype-example.c b/samples/kfifo/inttype-example.c
index 6f8e79e..bed3229 100644
--- a/samples/kfifo/inttype-example.c
+++ b/samples/kfifo/inttype-example.c
@@ -18,7 +18,8 @@
  */
 
 /* fifo size in elements (ints) */
-#define FIFO_SIZE	32
+#define FIFO_SIZE_ORDER	5
+#define FIFO_SIZE	(1<< FIFO_SIZE_ORDER)
 
 /* name of the proc entry */
 #define	PROC_FIFO	"int-fifo"
@@ -41,7 +42,7 @@ static DEFINE_MUTEX(write_lock);
 #ifdef DYNAMIC
 static DECLARE_KFIFO_PTR(test, int);
 #else
-static DEFINE_KFIFO(test, int, FIFO_SIZE);
+static DEFINE_KFIFO(test, int, FIFO_SIZE_ORDER);
 #endif
 
 static const int expected_result[FIFO_SIZE] = {
@@ -149,7 +150,7 @@ static int __init example_init(void)
 #ifdef DYNAMIC
 	int ret;
 
-	ret = kfifo_alloc(&test, FIFO_SIZE, GFP_KERNEL);
+	ret = kfifo_alloc(&test, FIFO_SIZE_ORDER, GFP_KERNEL);
 	if (ret) {
 		printk(KERN_ERR "error kfifo_alloc\n");
 		return ret;
diff --git a/samples/kfifo/record-example.c b/samples/kfifo/record-example.c
index 2d7529e..2902eae 100644
--- a/samples/kfifo/record-example.c
+++ b/samples/kfifo/record-example.c
@@ -18,7 +18,7 @@
  */
 
 /* fifo size in elements (bytes) */
-#define FIFO_SIZE	128
+#define FIFO_SIZE_ORDER	7
 
 /* name of the proc entry */
 #define	PROC_FIFO	"record-fifo"
@@ -50,7 +50,7 @@ static DEFINE_MUTEX(write_lock);
 struct kfifo_rec_ptr_1 test;
 
 #else
-typedef STRUCT_KFIFO_REC_1(FIFO_SIZE) mytest;
+typedef STRUCT_KFIFO_REC_1(FIFO_SIZE_ORDER) mytest;
 
 static mytest test;
 #endif
@@ -163,7 +163,7 @@ static int __init example_init(void)
 #ifdef DYNAMIC
 	int ret;
 
-	ret = kfifo_alloc(&test, FIFO_SIZE, GFP_KERNEL);
+	ret = kfifo_alloc(&test, FIFO_SIZE_ORDER, GFP_KERNEL);
 	if (ret) {
 		printk(KERN_ERR "error kfifo_alloc\n");
 		return ret;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
