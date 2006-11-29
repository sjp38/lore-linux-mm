Date: Tue, 28 Nov 2006 16:44:57 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20061129004457.11682.99991.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
References: <20061129004426.11682.36688.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 6/8] Get rid of SLAB_ATOMIC
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Get rid of SLAB_ATOMIC

SLAB_ATOMIC is an alias of GFP_ATOMIC

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.19-rc6-mm1/drivers/atm/he.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/atm/he.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/atm/he.c	2006-11-28 16:10:00.000000000 -0800
@@ -1724,7 +1724,7 @@
 	struct he_tpd *tpd;
 	dma_addr_t dma_handle; 
 
-	tpd = pci_pool_alloc(he_dev->tpd_pool, SLAB_ATOMIC|SLAB_DMA, &dma_handle);              
+	tpd = pci_pool_alloc(he_dev->tpd_pool, GFP_ATOMIC|SLAB_DMA, &dma_handle);              
 	if (tpd == NULL)
 		return NULL;
 			
Index: linux-2.6.19-rc6-mm1/drivers/usb/mon/mon_text.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/mon/mon_text.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/mon/mon_text.c	2006-11-28 16:10:00.000000000 -0800
@@ -147,7 +147,7 @@
 	stamp = mon_get_timestamp();
 
 	if (rp->nevents >= EVENT_MAX ||
-	    (ep = kmem_cache_alloc(rp->e_slab, SLAB_ATOMIC)) == NULL) {
+	    (ep = kmem_cache_alloc(rp->e_slab, GFP_ATOMIC)) == NULL) {
 		rp->r.m_bus->cnt_text_lost++;
 		return;
 	}
@@ -188,7 +188,7 @@
 	struct mon_event_text *ep;
 
 	if (rp->nevents >= EVENT_MAX ||
-	    (ep = kmem_cache_alloc(rp->e_slab, SLAB_ATOMIC)) == NULL) {
+	    (ep = kmem_cache_alloc(rp->e_slab, GFP_ATOMIC)) == NULL) {
 		rp->r.m_bus->cnt_text_lost++;
 		return;
 	}
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/catc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/catc.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/catc.c	2006-11-28 16:10:00.000000000 -0800
@@ -345,7 +345,7 @@
 		} 
 	}
 resubmit:
-	status = usb_submit_urb (urb, SLAB_ATOMIC);
+	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status)
 		err ("can't resubmit intr, %s-%s, status %d",
 				catc->usbdev->bus->bus_name,
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/net1080.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/net1080.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/net1080.c	2006-11-28 16:10:00.000000000 -0800
@@ -383,7 +383,7 @@
 		int			status;
 
 		/* Send a flush */
-		urb = usb_alloc_urb(0, SLAB_ATOMIC);
+		urb = usb_alloc_urb(0, GFP_ATOMIC);
 		if (!urb)
 			return;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/pegasus.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/pegasus.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/pegasus.c	2006-11-28 16:10:00.000000000 -0800
@@ -855,7 +855,7 @@
 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
 	}
 
-	status = usb_submit_urb(urb, SLAB_ATOMIC);
+	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status == -ENODEV)
 		netif_device_detach(pegasus->net);
 	if (status && netif_msg_timer(pegasus))
Index: linux-2.6.19-rc6-mm1/drivers/usb/net/rtl8150.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/net/rtl8150.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/net/rtl8150.c	2006-11-28 16:10:00.000000000 -0800
@@ -587,7 +587,7 @@
 	}
 
 resubmit:
-	status = usb_submit_urb (urb, SLAB_ATOMIC);
+	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status == -ENODEV)
 		netif_device_detach(dev->netdev);
 	else if (status)
Index: linux-2.6.19-rc6-mm1/drivers/usb/core/hub.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/core/hub.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/core/hub.c	2006-11-28 16:10:00.000000000 -0800
@@ -459,7 +459,7 @@
 	 * since each TT has "at least two" buffers that can need it (and
 	 * there can be many TTs per hub).  even if they're uncommon.
 	 */
-	if ((clear = kmalloc (sizeof *clear, SLAB_ATOMIC)) == NULL) {
+	if ((clear = kmalloc (sizeof *clear, GFP_ATOMIC)) == NULL) {
 		dev_err (&udev->dev, "can't save CLEAR_TT_BUFFER state\n");
 		/* FIXME recover somehow ... RESET_TT? */
 		return;
Index: linux-2.6.19-rc6-mm1/drivers/usb/core/message.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/core/message.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/core/message.c	2006-11-28 16:10:00.000000000 -0800
@@ -488,7 +488,7 @@
 		int	retval;
 
 		io->urbs [i]->dev = io->dev;
-		retval = usb_submit_urb (io->urbs [i], SLAB_ATOMIC);
+		retval = usb_submit_urb (io->urbs [i], GFP_ATOMIC);
 
 		/* after we submit, let completions or cancelations fire;
 		 * we handshake using io->status.
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/ehci-dbg.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/ehci-dbg.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/ehci-dbg.c	2006-11-28 16:10:00.000000000 -0800
@@ -492,7 +492,7 @@
 	unsigned		i;
 	__le32			tag;
 
-	if (!(seen = kmalloc (DBG_SCHED_LIMIT * sizeof *seen, SLAB_ATOMIC)))
+	if (!(seen = kmalloc (DBG_SCHED_LIMIT * sizeof *seen, GFP_ATOMIC)))
 		return 0;
 	seen_count = 0;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/uhci-q.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/uhci-q.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/uhci-q.c	2006-11-28 16:10:00.000000000 -0800
@@ -498,7 +498,7 @@
 {
 	struct urb_priv *urbp;
 
-	urbp = kmem_cache_alloc(uhci_up_cachep, SLAB_ATOMIC);
+	urbp = kmem_cache_alloc(uhci_up_cachep, GFP_ATOMIC);
 	if (!urbp)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/hc_crisv10.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/hc_crisv10.c	2006-11-28 16:10:00.000000000 -0800
@@ -188,7 +188,7 @@
 #define CHECK_ALIGN(x) if (((__u32)(x)) & 0x00000003) \
 {panic("Alignment check (DWORD) failed at %s:%s:%d\n", __FILE__, __FUNCTION__, __LINE__);}
 
-#define SLAB_FLAG     (in_interrupt() ? SLAB_ATOMIC : SLAB_KERNEL)
+#define SLAB_FLAG     (in_interrupt() ? GFP_ATOMIC : SLAB_KERNEL)
 #define KMALLOC_FLAG  (in_interrupt() ? GFP_ATOMIC : GFP_KERNEL)
 
 /* Most helpful debugging aid */
@@ -1743,7 +1743,7 @@
 
 		*R_DMA_CH8_SUB3_CLR_INTR = IO_STATE(R_DMA_CH8_SUB3_CLR_INTR, clr_descr, do);
 
-		comp_data = (usb_isoc_complete_data_t*)kmem_cache_alloc(isoc_compl_cache, SLAB_ATOMIC);
+		comp_data = (usb_isoc_complete_data_t*)kmem_cache_alloc(isoc_compl_cache, GFP_ATOMIC);
 		assert(comp_data != NULL);
 
                 INIT_WORK(&comp_data->usb_bh, etrax_usb_isoc_descr_interrupt_bottom_half, comp_data);
@@ -3010,7 +3010,7 @@
 			if (!urb->iso_frame_desc[i].length)
 				continue;
 
-			next_sb_desc = (USB_SB_Desc_t*)kmem_cache_alloc(usb_desc_cache, SLAB_ATOMIC);
+			next_sb_desc = (USB_SB_Desc_t*)kmem_cache_alloc(usb_desc_cache, GFP_ATOMIC);
 			assert(next_sb_desc != NULL);
 
 			if (urb->iso_frame_desc[i].length > 0) {
@@ -3063,7 +3063,7 @@
 		if (TxIsocEPList[epid].sub == 0) {
 			dbg_isoc("Isoc traffic not already running, allocating SB");
 
-			next_sb_desc = (USB_SB_Desc_t*)kmem_cache_alloc(usb_desc_cache, SLAB_ATOMIC);
+			next_sb_desc = (USB_SB_Desc_t*)kmem_cache_alloc(usb_desc_cache, GFP_ATOMIC);
 			assert(next_sb_desc != NULL);
 
 			next_sb_desc->command = (IO_STATE(USB_SB_command, tt, in) |
@@ -3317,7 +3317,7 @@
 
 	restore_flags(flags);
 
-	reg = (usb_interrupt_registers_t *)kmem_cache_alloc(top_half_reg_cache, SLAB_ATOMIC);
+	reg = (usb_interrupt_registers_t *)kmem_cache_alloc(top_half_reg_cache, GFP_ATOMIC);
 
 	assert(reg != NULL);
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/host/ohci-dbg.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/host/ohci-dbg.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/host/ohci-dbg.c	2006-11-28 16:10:00.000000000 -0800
@@ -505,7 +505,7 @@
 	char			*next;
 	unsigned		i;
 
-	if (!(seen = kmalloc (DBG_SCHED_LIMIT * sizeof *seen, SLAB_ATOMIC)))
+	if (!(seen = kmalloc (DBG_SCHED_LIMIT * sizeof *seen, GFP_ATOMIC)))
 		return 0;
 	seen_count = 0;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/misc/phidgetkit.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/misc/phidgetkit.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/misc/phidgetkit.c	2006-11-28 16:10:00.000000000 -0800
@@ -377,7 +377,7 @@
 		schedule_work(&kit->do_notify);
 
 resubmit:
-	status = usb_submit_urb(urb, SLAB_ATOMIC);
+	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status)
 		err("can't resubmit intr, %s-%s/interfacekit0, status %d",
 			kit->udev->bus->bus_name,
@@ -565,7 +565,7 @@
 
 	kit->dev_no = -1;
 	kit->ifkit = ifkit;
-	kit->data = usb_buffer_alloc(dev, URB_INT_SIZE, SLAB_ATOMIC, &kit->data_dma);
+	kit->data = usb_buffer_alloc(dev, URB_INT_SIZE, GFP_ATOMIC, &kit->data_dma);
 	if (!kit->data)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/misc/usbtest.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/misc/usbtest.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/misc/usbtest.c	2006-11-28 16:10:00.000000000 -0800
@@ -819,7 +819,7 @@
 
 	/* resubmit if we need to, else mark this as done */
 	if ((status == 0) && (ctx->pending < ctx->count)) {
-		if ((status = usb_submit_urb (urb, SLAB_ATOMIC)) != 0) {
+		if ((status = usb_submit_urb (urb, GFP_ATOMIC)) != 0) {
 			dbg ("can't resubmit ctrl %02x.%02x, err %d",
 				reqp->bRequestType, reqp->bRequest, status);
 			urb->dev = NULL;
@@ -999,7 +999,7 @@
 	context.urb = urb;
 	spin_lock_irq (&context.lock);
 	for (i = 0; i < param->sglen; i++) {
-		context.status = usb_submit_urb (urb [i], SLAB_ATOMIC);
+		context.status = usb_submit_urb (urb [i], GFP_ATOMIC);
 		if (context.status != 0) {
 			dbg ("can't submit urb[%d], status %d",
 					i, context.status);
@@ -1041,7 +1041,7 @@
 
 	// we "know" -EPIPE (stall) never happens
 	if (!status)
-		status = usb_submit_urb (urb, SLAB_ATOMIC);
+		status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status) {
 		urb->status = status;
 		complete ((struct completion *) urb->context);
@@ -1481,7 +1481,7 @@
 	spin_lock_irq (&context.lock);
 	for (i = 0; i < param->sglen; i++) {
 		++context.pending;
-		status = usb_submit_urb (urbs [i], SLAB_ATOMIC);
+		status = usb_submit_urb (urbs [i], GFP_ATOMIC);
 		if (status < 0) {
 			ERROR (dev, "submit iso[%d], error %d\n", i, status);
 			if (i == 0) {
Index: linux-2.6.19-rc6-mm1/drivers/usb/misc/phidgetmotorcontrol.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/misc/phidgetmotorcontrol.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/misc/phidgetmotorcontrol.c	2006-11-28 16:10:00.000000000 -0800
@@ -151,7 +151,7 @@
 		schedule_work(&mc->do_notify);
 
 resubmit:
-	status = usb_submit_urb(urb, SLAB_ATOMIC);
+	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status)
 		dev_err(&mc->intf->dev,
 			"can't resubmit intr, %s-%s/motorcontrol0, status %d",
@@ -337,7 +337,7 @@
 		goto out;
 
 	mc->dev_no = -1;
-	mc->data = usb_buffer_alloc(dev, URB_INT_SIZE, SLAB_ATOMIC, &mc->data_dma);
+	mc->data = usb_buffer_alloc(dev, URB_INT_SIZE, GFP_ATOMIC, &mc->data_dma);
 	if (!mc->data)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/yealink.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/yealink.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/yealink.c	2006-11-28 16:10:00.000000000 -0800
@@ -874,17 +874,17 @@
 
 	/* allocate usb buffers */
 	yld->irq_data = usb_buffer_alloc(udev, USB_PKT_LEN,
-					SLAB_ATOMIC, &yld->irq_dma);
+					GFP_ATOMIC, &yld->irq_dma);
 	if (yld->irq_data == NULL)
 		return usb_cleanup(yld, -ENOMEM);
 
 	yld->ctl_data = usb_buffer_alloc(udev, USB_PKT_LEN,
-					SLAB_ATOMIC, &yld->ctl_dma);
+					GFP_ATOMIC, &yld->ctl_dma);
 	if (!yld->ctl_data)
 		return usb_cleanup(yld, -ENOMEM);
 
 	yld->ctl_req = usb_buffer_alloc(udev, sizeof(*(yld->ctl_req)),
-					SLAB_ATOMIC, &yld->ctl_req_dma);
+					GFP_ATOMIC, &yld->ctl_req_dma);
 	if (yld->ctl_req == NULL)
 		return usb_cleanup(yld, -ENOMEM);
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/powermate.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/powermate.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/powermate.c	2006-11-28 16:10:00.000000000 -0800
@@ -277,12 +277,12 @@
 static int powermate_alloc_buffers(struct usb_device *udev, struct powermate_device *pm)
 {
 	pm->data = usb_buffer_alloc(udev, POWERMATE_PAYLOAD_SIZE_MAX,
-				    SLAB_ATOMIC, &pm->data_dma);
+				    GFP_ATOMIC, &pm->data_dma);
 	if (!pm->data)
 		return -1;
 
 	pm->configcr = usb_buffer_alloc(udev, sizeof(*(pm->configcr)),
-					SLAB_ATOMIC, &pm->configcr_dma);
+					GFP_ATOMIC, &pm->configcr_dma);
 	if (!pm->configcr)
 		return -1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/mtouchusb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/mtouchusb.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/mtouchusb.c	2006-11-28 16:10:00.000000000 -0800
@@ -164,7 +164,7 @@
 	dbg("%s - called", __FUNCTION__);
 
 	mtouch->data = usb_buffer_alloc(udev, MTOUCHUSB_REPORT_DATA_SIZE,
-					SLAB_ATOMIC, &mtouch->data_dma);
+					GFP_ATOMIC, &mtouch->data_dma);
 
 	if (!mtouch->data)
 		return -1;
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/usbmouse.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/usbmouse.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/usbmouse.c	2006-11-28 16:10:00.000000000 -0800
@@ -86,7 +86,7 @@
 
 	input_sync(dev);
 resubmit:
-	status = usb_submit_urb (urb, SLAB_ATOMIC);
+	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status)
 		err ("can't resubmit intr, %s-%s/input0, status %d",
 				mouse->usbdev->bus->bus_name,
@@ -137,7 +137,7 @@
 	if (!mouse || !input_dev)
 		goto fail1;
 
-	mouse->data = usb_buffer_alloc(dev, 8, SLAB_ATOMIC, &mouse->data_dma);
+	mouse->data = usb_buffer_alloc(dev, 8, GFP_ATOMIC, &mouse->data_dma);
 	if (!mouse->data)
 		goto fail1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/ati_remote.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/ati_remote.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/ati_remote.c	2006-11-28 16:10:00.000000000 -0800
@@ -592,7 +592,7 @@
 			__FUNCTION__, urb->status);
 	}
 
-	retval = usb_submit_urb(urb, SLAB_ATOMIC);
+	retval = usb_submit_urb(urb, GFP_ATOMIC);
 	if (retval)
 		dev_err(&ati_remote->interface->dev, "%s: usb_submit_urb()=%d\n",
 			__FUNCTION__, retval);
@@ -604,12 +604,12 @@
 static int ati_remote_alloc_buffers(struct usb_device *udev,
 				    struct ati_remote *ati_remote)
 {
-	ati_remote->inbuf = usb_buffer_alloc(udev, DATA_BUFSIZE, SLAB_ATOMIC,
+	ati_remote->inbuf = usb_buffer_alloc(udev, DATA_BUFSIZE, GFP_ATOMIC,
 					     &ati_remote->inbuf_dma);
 	if (!ati_remote->inbuf)
 		return -1;
 
-	ati_remote->outbuf = usb_buffer_alloc(udev, DATA_BUFSIZE, SLAB_ATOMIC,
+	ati_remote->outbuf = usb_buffer_alloc(udev, DATA_BUFSIZE, GFP_ATOMIC,
 					      &ati_remote->outbuf_dma);
 	if (!ati_remote->outbuf)
 		return -1;
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/aiptek.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/aiptek.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/aiptek.c	2006-11-28 16:10:00.000000000 -0800
@@ -1988,7 +1988,7 @@
 		goto fail1;
 
 	aiptek->data = usb_buffer_alloc(usbdev, AIPTEK_PACKET_LENGTH,
-					SLAB_ATOMIC, &aiptek->data_dma);
+					GFP_ATOMIC, &aiptek->data_dma);
 	if (!aiptek->data)
 		goto fail1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/xpad.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/xpad.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/xpad.c	2006-11-28 16:10:00.000000000 -0800
@@ -325,7 +325,7 @@
 		goto fail1;
 
 	xpad->idata = usb_buffer_alloc(udev, XPAD_PKT_LEN,
-				       SLAB_ATOMIC, &xpad->idata_dma);
+				       GFP_ATOMIC, &xpad->idata_dma);
 	if (!xpad->idata)
 		goto fail1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/usbkbd.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/usbkbd.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/usbkbd.c	2006-11-28 16:10:00.000000000 -0800
@@ -122,7 +122,7 @@
 	memcpy(kbd->old, kbd->new, 8);
 
 resubmit:
-	i = usb_submit_urb (urb, SLAB_ATOMIC);
+	i = usb_submit_urb (urb, GFP_ATOMIC);
 	if (i)
 		err ("can't resubmit intr, %s-%s/input0, status %d",
 				kbd->usbdev->bus->bus_name,
@@ -196,11 +196,11 @@
 		return -1;
 	if (!(kbd->led = usb_alloc_urb(0, GFP_KERNEL)))
 		return -1;
-	if (!(kbd->new = usb_buffer_alloc(dev, 8, SLAB_ATOMIC, &kbd->new_dma)))
+	if (!(kbd->new = usb_buffer_alloc(dev, 8, GFP_ATOMIC, &kbd->new_dma)))
 		return -1;
-	if (!(kbd->cr = usb_buffer_alloc(dev, sizeof(struct usb_ctrlrequest), SLAB_ATOMIC, &kbd->cr_dma)))
+	if (!(kbd->cr = usb_buffer_alloc(dev, sizeof(struct usb_ctrlrequest), GFP_ATOMIC, &kbd->cr_dma)))
 		return -1;
-	if (!(kbd->leds = usb_buffer_alloc(dev, 1, SLAB_ATOMIC, &kbd->leds_dma)))
+	if (!(kbd->leds = usb_buffer_alloc(dev, 1, GFP_ATOMIC, &kbd->leds_dma)))
 		return -1;
 
 	return 0;
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/keyspan_remote.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/keyspan_remote.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/keyspan_remote.c	2006-11-28 16:10:00.000000000 -0800
@@ -456,7 +456,7 @@
 	remote->in_endpoint = endpoint;
 	remote->toggle = -1;	/* Set to -1 so we will always not match the toggle from the first remote message. */
 
-	remote->in_buffer = usb_buffer_alloc(udev, RECV_SIZE, SLAB_ATOMIC, &remote->in_dma);
+	remote->in_buffer = usb_buffer_alloc(udev, RECV_SIZE, GFP_ATOMIC, &remote->in_dma);
 	if (!remote->in_buffer) {
 		retval = -ENOMEM;
 		goto fail1;
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/hid-core.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/hid-core.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/hid-core.c	2006-11-28 16:10:00.000000000 -0800
@@ -1078,7 +1078,7 @@
 			warn("input irq status %d received", urb->status);
 	}
 
-	status = usb_submit_urb(urb, SLAB_ATOMIC);
+	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status) {
 		clear_bit(HID_IN_RUNNING, &hid->iofl);
 		if (status != -EPERM) {
@@ -1853,13 +1853,13 @@
 
 static int hid_alloc_buffers(struct usb_device *dev, struct hid_device *hid)
 {
-	if (!(hid->inbuf = usb_buffer_alloc(dev, hid->bufsize, SLAB_ATOMIC, &hid->inbuf_dma)))
+	if (!(hid->inbuf = usb_buffer_alloc(dev, hid->bufsize, GFP_ATOMIC, &hid->inbuf_dma)))
 		return -1;
-	if (!(hid->outbuf = usb_buffer_alloc(dev, hid->bufsize, SLAB_ATOMIC, &hid->outbuf_dma)))
+	if (!(hid->outbuf = usb_buffer_alloc(dev, hid->bufsize, GFP_ATOMIC, &hid->outbuf_dma)))
 		return -1;
-	if (!(hid->cr = usb_buffer_alloc(dev, sizeof(*(hid->cr)), SLAB_ATOMIC, &hid->cr_dma)))
+	if (!(hid->cr = usb_buffer_alloc(dev, sizeof(*(hid->cr)), GFP_ATOMIC, &hid->cr_dma)))
 		return -1;
-	if (!(hid->ctrlbuf = usb_buffer_alloc(dev, hid->bufsize, SLAB_ATOMIC, &hid->ctrlbuf_dma)))
+	if (!(hid->ctrlbuf = usb_buffer_alloc(dev, hid->bufsize, GFP_ATOMIC, &hid->ctrlbuf_dma)))
 		return -1;
 
 	return 0;
Index: linux-2.6.19-rc6-mm1/drivers/usb/input/touchkitusb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/input/touchkitusb.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/input/touchkitusb.c	2006-11-28 16:10:00.000000000 -0800
@@ -248,7 +248,7 @@
 				  struct touchkit_usb *touchkit)
 {
 	touchkit->data = usb_buffer_alloc(udev, TOUCHKIT_REPORT_DATA_SIZE,
-	                                  SLAB_ATOMIC, &touchkit->data_dma);
+	                                  GFP_ATOMIC, &touchkit->data_dma);
 
 	if (!touchkit->data)
 		return -1;
Index: linux-2.6.19-rc6-mm1/drivers/usb/storage/onetouch.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/storage/onetouch.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/storage/onetouch.c	2006-11-28 16:10:00.000000000 -0800
@@ -76,7 +76,7 @@
 	input_sync(dev);
 
 resubmit:
-	status = usb_submit_urb (urb, SLAB_ATOMIC);
+	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status)
 		err ("can't resubmit intr, %s-%s/input0, status %d",
 			onetouch->udev->bus->bus_name,
@@ -154,7 +154,7 @@
 		goto fail1;
 
 	onetouch->data = usb_buffer_alloc(udev, ONETOUCH_PKT_LEN,
-					  SLAB_ATOMIC, &onetouch->data_dma);
+					  GFP_ATOMIC, &onetouch->data_dma);
 	if (!onetouch->data)
 		goto fail1;
 
Index: linux-2.6.19-rc6-mm1/drivers/usb/serial/mos7720.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/serial/mos7720.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/serial/mos7720.c	2006-11-28 16:10:00.000000000 -0800
@@ -363,7 +363,7 @@
 
 	/* Initialising the write urb pool */
 	for (j = 0; j < NUM_URBS; ++j) {
-		urb = usb_alloc_urb(0,SLAB_ATOMIC);
+		urb = usb_alloc_urb(0,GFP_ATOMIC);
 		mos7720_port->write_urb_pool[j] = urb;
 
 		if (urb == NULL) {
Index: linux-2.6.19-rc6-mm1/drivers/usb/serial/mos7840.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/usb/serial/mos7840.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/usb/serial/mos7840.c	2006-11-28 16:10:00.000000000 -0800
@@ -826,7 +826,7 @@
 
 	/* Initialising the write urb pool */
 	for (j = 0; j < NUM_URBS; ++j) {
-		urb = usb_alloc_urb(0, SLAB_ATOMIC);
+		urb = usb_alloc_urb(0, GFP_ATOMIC);
 		mos7840_port->write_urb_pool[j] = urb;
 
 		if (urb == NULL) {
@@ -2787,7 +2787,7 @@
 				    i + 1, status);
 
 		}
-		mos7840_port->control_urb = usb_alloc_urb(0, SLAB_ATOMIC);
+		mos7840_port->control_urb = usb_alloc_urb(0, GFP_ATOMIC);
 		mos7840_port->ctrl_buf = kmalloc(16, GFP_KERNEL);
 
 	}
Index: linux-2.6.19-rc6-mm1/drivers/base/dmapool.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/base/dmapool.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/base/dmapool.c	2006-11-28 16:10:00.000000000 -0800
@@ -297,7 +297,7 @@
 			}
 		}
 	}
-	if (!(page = pool_alloc_page (pool, SLAB_ATOMIC))) {
+	if (!(page = pool_alloc_page (pool, GFP_ATOMIC))) {
 		if (mem_flags & __GFP_WAIT) {
 			DECLARE_WAITQUEUE (wait, current);
 
Index: linux-2.6.19-rc6-mm1/drivers/char/watchdog/pcwd_usb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/char/watchdog/pcwd_usb.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/char/watchdog/pcwd_usb.c	2006-11-28 16:10:00.000000000 -0800
@@ -634,7 +634,7 @@
 	usb_pcwd->intr_size = (le16_to_cpu(endpoint->wMaxPacketSize) > 8 ? le16_to_cpu(endpoint->wMaxPacketSize) : 8);
 
 	/* set up the memory buffer's */
-	if (!(usb_pcwd->intr_buffer = usb_buffer_alloc(udev, usb_pcwd->intr_size, SLAB_ATOMIC, &usb_pcwd->intr_dma))) {
+	if (!(usb_pcwd->intr_buffer = usb_buffer_alloc(udev, usb_pcwd->intr_size, GFP_ATOMIC, &usb_pcwd->intr_dma))) {
 		printk(KERN_ERR PFX "Out of memory\n");
 		goto error;
 	}
Index: linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/usb-gigaset.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/isdn/gigaset/usb-gigaset.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/usb-gigaset.c	2006-11-28 16:10:00.000000000 -0800
@@ -410,7 +410,7 @@
 
 	if (resubmit) {
 		spin_lock_irqsave(&cs->lock, flags);
-		r = cs->connected ? usb_submit_urb(urb, SLAB_ATOMIC) : -ENODEV;
+		r = cs->connected ? usb_submit_urb(urb, GFP_ATOMIC) : -ENODEV;
 		spin_unlock_irqrestore(&cs->lock, flags);
 		if (r)
 			dev_err(cs->dev, "error %d when resubmitting urb.\n",
@@ -486,7 +486,7 @@
 			atomic_set(&ucs->busy, 1);
 
 			spin_lock_irqsave(&cs->lock, flags);
-			status = cs->connected ? usb_submit_urb(ucs->bulk_out_urb, SLAB_ATOMIC) : -ENODEV;
+			status = cs->connected ? usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC) : -ENODEV;
 			spin_unlock_irqrestore(&cs->lock, flags);
 
 			if (status) {
@@ -664,7 +664,7 @@
 						  ucs->bulk_out_endpointAddr & 0x0f),
 				  ucs->bulk_out_buffer, count,
 				  gigaset_write_bulk_callback, cs);
-		ret = usb_submit_urb(ucs->bulk_out_urb, SLAB_ATOMIC);
+		ret = usb_submit_urb(ucs->bulk_out_urb, GFP_ATOMIC);
 	} else {
 		ret = -ENODEV;
 	}
Index: linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/bas-gigaset.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/isdn/gigaset/bas-gigaset.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/isdn/gigaset/bas-gigaset.c	2006-11-28 16:10:00.000000000 -0800
@@ -572,7 +572,7 @@
 			     ucs->rcvbuf, ucs->rcvbuf_size,
 			     read_ctrl_callback, cs->inbuf);
 
-	if ((ret = usb_submit_urb(ucs->urb_cmd_in, SLAB_ATOMIC)) != 0) {
+	if ((ret = usb_submit_urb(ucs->urb_cmd_in, GFP_ATOMIC)) != 0) {
 		update_basstate(ucs, 0, BS_ATRDPEND);
 		dev_err(cs->dev, "could not submit HD_READ_ATMESSAGE: %s\n",
 			get_usb_rcmsg(ret));
@@ -747,7 +747,7 @@
 	check_pending(ucs);
 
 resubmit:
-	rc = usb_submit_urb(urb, SLAB_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
 	if (unlikely(rc != 0 && rc != -ENODEV)) {
 		dev_err(cs->dev, "could not resubmit interrupt URB: %s\n",
 			get_usb_rcmsg(rc));
@@ -807,7 +807,7 @@
 			urb->number_of_packets = BAS_NUMFRAMES;
 			gig_dbg(DEBUG_ISO, "%s: isoc read overrun/resubmit",
 				__func__);
-			rc = usb_submit_urb(urb, SLAB_ATOMIC);
+			rc = usb_submit_urb(urb, GFP_ATOMIC);
 			if (unlikely(rc != 0 && rc != -ENODEV)) {
 				dev_err(bcs->cs->dev,
 					"could not resubmit isochronous read "
@@ -900,7 +900,7 @@
 		}
 
 		dump_urb(DEBUG_ISO, "Initial isoc read", urb);
-		if ((rc = usb_submit_urb(urb, SLAB_ATOMIC)) != 0)
+		if ((rc = usb_submit_urb(urb, GFP_ATOMIC)) != 0)
 			goto error;
 	}
 
@@ -935,7 +935,7 @@
 	/* submit two URBs, keep third one */
 	for (k = 0; k < 2; ++k) {
 		dump_urb(DEBUG_ISO, "Initial isoc write", urb);
-		rc = usb_submit_urb(ubc->isoouturbs[k].urb, SLAB_ATOMIC);
+		rc = usb_submit_urb(ubc->isoouturbs[k].urb, GFP_ATOMIC);
 		if (rc != 0)
 			goto error;
 	}
@@ -1042,7 +1042,7 @@
 		return 0;	/* no data to send */
 	urb->number_of_packets = nframe;
 
-	rc = usb_submit_urb(urb, SLAB_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
 	if (unlikely(rc)) {
 		if (rc == -ENODEV)
 			/* device removed - give up silently */
@@ -1341,7 +1341,7 @@
 		urb->dev = bcs->cs->hw.bas->udev;
 		urb->transfer_flags = URB_ISO_ASAP;
 		urb->number_of_packets = BAS_NUMFRAMES;
-		rc = usb_submit_urb(urb, SLAB_ATOMIC);
+		rc = usb_submit_urb(urb, GFP_ATOMIC);
 		if (unlikely(rc != 0 && rc != -ENODEV)) {
 			dev_err(cs->dev,
 				"could not resubmit isochronous read URB: %s\n",
@@ -1458,7 +1458,7 @@
 			   ucs->retry_ctrl);
 		/* urb->dev is clobbered by USB subsystem */
 		urb->dev = ucs->udev;
-		rc = usb_submit_urb(urb, SLAB_ATOMIC);
+		rc = usb_submit_urb(urb, GFP_ATOMIC);
 		if (unlikely(rc)) {
 			dev_err(&ucs->interface->dev,
 				"could not resubmit request 0x%02x: %s\n",
@@ -1517,7 +1517,7 @@
 			     (unsigned char*) &ucs->dr_ctrl, NULL, 0,
 			     write_ctrl_callback, ucs);
 	ucs->retry_ctrl = 0;
-	ret = usb_submit_urb(ucs->urb_ctrl, SLAB_ATOMIC);
+	ret = usb_submit_urb(ucs->urb_ctrl, GFP_ATOMIC);
 	if (unlikely(ret)) {
 		dev_err(bcs->cs->dev, "could not submit request 0x%02x: %s\n",
 			req, get_usb_rcmsg(ret));
@@ -1763,7 +1763,7 @@
 			     usb_sndctrlpipe(ucs->udev, 0),
 			     (unsigned char*) &ucs->dr_cmd_out, buf, len,
 			     write_command_callback, cs);
-	rc = usb_submit_urb(ucs->urb_cmd_out, SLAB_ATOMIC);
+	rc = usb_submit_urb(ucs->urb_cmd_out, GFP_ATOMIC);
 	if (unlikely(rc)) {
 		update_basstate(ucs, 0, BS_ATWRPEND);
 		dev_err(cs->dev, "could not submit HD_WRITE_ATMESSAGE: %s\n",
Index: linux-2.6.19-rc6-mm1/drivers/s390/scsi/zfcp_fsf.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/s390/scsi/zfcp_fsf.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/s390/scsi/zfcp_fsf.c	2006-11-28 16:10:00.000000000 -0800
@@ -109,7 +109,7 @@
 			ptr = kmalloc(size, GFP_ATOMIC);
 		else
 			ptr = kmem_cache_alloc(zfcp_data.fsf_req_qtcb_cache,
-					       SLAB_ATOMIC);
+					       GFP_ATOMIC);
 	}
 
 	if (unlikely(!ptr))
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/amso1100/c2_vq.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/amso1100/c2_vq.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/amso1100/c2_vq.c	2006-11-28 16:10:00.000000000 -0800
@@ -164,7 +164,7 @@
  */
 void *vq_repbuf_alloc(struct c2_dev *c2dev)
 {
-	return kmem_cache_alloc(c2dev->host_msg_cache, SLAB_ATOMIC);
+	return kmem_cache_alloc(c2dev->host_msg_cache, GFP_ATOMIC);
 }
 
 /*
Index: linux-2.6.19-rc6-mm1/drivers/infiniband/hw/mthca/mthca_av.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/infiniband/hw/mthca/mthca_av.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/infiniband/hw/mthca/mthca_av.c	2006-11-28 16:10:00.000000000 -0800
@@ -189,7 +189,7 @@
 on_hca_fail:
 	if (ah->type == MTHCA_AH_PCI_POOL) {
 		ah->av = pci_pool_alloc(dev->av_table.pool,
-					SLAB_ATOMIC, &ah->avdma);
+					GFP_ATOMIC, &ah->avdma);
 		if (!ah->av)
 			return -ENOMEM;
 
Index: linux-2.6.19-rc6-mm1/drivers/block/DAC960.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/block/DAC960.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/block/DAC960.c	2006-11-28 16:10:00.000000000 -0800
@@ -324,13 +324,13 @@
       Command->Next = Controller->FreeCommands;
       Controller->FreeCommands = Command;
       Controller->Commands[CommandIdentifier-1] = Command;
-      ScatterGatherCPU = pci_pool_alloc(ScatterGatherPool, SLAB_ATOMIC,
+      ScatterGatherCPU = pci_pool_alloc(ScatterGatherPool, GFP_ATOMIC,
 							&ScatterGatherDMA);
       if (ScatterGatherCPU == NULL)
 	  return DAC960_Failure(Controller, "AUXILIARY STRUCTURE CREATION");
 
       if (RequestSensePool != NULL) {
-  	  RequestSenseCPU = pci_pool_alloc(RequestSensePool, SLAB_ATOMIC,
+  	  RequestSenseCPU = pci_pool_alloc(RequestSensePool, GFP_ATOMIC,
 						&RequestSenseDMA);
   	  if (RequestSenseCPU == NULL) {
                 pci_pool_free(ScatterGatherPool, ScatterGatherCPU,
Index: linux-2.6.19-rc6-mm1/drivers/media/dvb/ttusb-dec/ttusb_dec.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/media/dvb/ttusb-dec/ttusb_dec.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/media/dvb/ttusb-dec/ttusb_dec.c	2006-11-28 16:10:00.000000000 -0800
@@ -1251,7 +1251,7 @@
 			return -ENOMEM;
 		}
 		dec->irq_buffer = usb_buffer_alloc(dec->udev,IRQ_PACKET_SIZE,
-					SLAB_ATOMIC, &dec->irq_dma_handle);
+					GFP_ATOMIC, &dec->irq_dma_handle);
 		if(!dec->irq_buffer) {
 			return -ENOMEM;
 		}
Index: linux-2.6.19-rc6-mm1/drivers/media/dvb/dvb-usb/usb-urb.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/media/dvb/dvb-usb/usb-urb.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/media/dvb/dvb-usb/usb-urb.c	2006-11-28 16:10:00.000000000 -0800
@@ -116,7 +116,7 @@
 	for (stream->buf_num = 0; stream->buf_num < num; stream->buf_num++) {
 		deb_mem("allocating buffer %d\n",stream->buf_num);
 		if (( stream->buf_list[stream->buf_num] =
-					usb_buffer_alloc(stream->udev, size, SLAB_ATOMIC,
+					usb_buffer_alloc(stream->udev, size, GFP_ATOMIC,
 					&stream->dma_addr[stream->buf_num]) ) == NULL) {
 			deb_mem("not enough memory for urb-buffer allocation.\n");
 			usb_free_stream_buffers(stream);
Index: linux-2.6.19-rc6-mm1/drivers/ieee1394/raw1394.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/drivers/ieee1394/raw1394.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/drivers/ieee1394/raw1394.c	2006-11-28 16:10:00.000000000 -0800
@@ -274,7 +274,7 @@
 	if (hi != NULL) {
 		list_for_each_entry(fi, &hi->file_info_list, list) {
 			if (fi->notification == RAW1394_NOTIFY_ON) {
-				req = __alloc_pending_request(SLAB_ATOMIC);
+				req = __alloc_pending_request(GFP_ATOMIC);
 
 				if (req != NULL) {
 					req->file_info = fi;
@@ -321,13 +321,13 @@
 			if (!(fi->listen_channels & (1ULL << channel)))
 				continue;
 
-			req = __alloc_pending_request(SLAB_ATOMIC);
+			req = __alloc_pending_request(GFP_ATOMIC);
 			if (!req)
 				break;
 
 			if (!ibs) {
 				ibs = kmalloc(sizeof(*ibs) + length,
-					      SLAB_ATOMIC);
+					      GFP_ATOMIC);
 				if (!ibs) {
 					kfree(req);
 					break;
@@ -382,13 +382,13 @@
 			if (!fi->fcp_buffer)
 				continue;
 
-			req = __alloc_pending_request(SLAB_ATOMIC);
+			req = __alloc_pending_request(GFP_ATOMIC);
 			if (!req)
 				break;
 
 			if (!ibs) {
 				ibs = kmalloc(sizeof(*ibs) + length,
-					      SLAB_ATOMIC);
+					      GFP_ATOMIC);
 				if (!ibs) {
 					kfree(req);
 					break;
@@ -608,7 +608,7 @@
 	switch (req->req.type) {
 	case RAW1394_REQ_LIST_CARDS:
 		spin_lock_irqsave(&host_info_lock, flags);
-		khl = kmalloc(sizeof(*khl) * host_count, SLAB_ATOMIC);
+		khl = kmalloc(sizeof(*khl) * host_count, GFP_ATOMIC);
 
 		if (khl) {
 			req->req.misc = host_count;
@@ -1060,7 +1060,7 @@
 	}
 	if (arm_addr->notification_options & ARM_READ) {
 		DBGMSG("arm_read -> entering notification-section");
-		req = __alloc_pending_request(SLAB_ATOMIC);
+		req = __alloc_pending_request(GFP_ATOMIC);
 		if (!req) {
 			DBGMSG("arm_read -> rcode_conflict_error");
 			spin_unlock_irqrestore(&host_info_lock, irqflags);
@@ -1079,7 +1079,7 @@
 			    sizeof(struct arm_response) +
 			    sizeof(struct arm_request_response);
 		}
-		req->data = kmalloc(size, SLAB_ATOMIC);
+		req->data = kmalloc(size, GFP_ATOMIC);
 		if (!(req->data)) {
 			free_pending_request(req);
 			DBGMSG("arm_read -> rcode_conflict_error");
@@ -1213,7 +1213,7 @@
 	}
 	if (arm_addr->notification_options & ARM_WRITE) {
 		DBGMSG("arm_write -> entering notification-section");
-		req = __alloc_pending_request(SLAB_ATOMIC);
+		req = __alloc_pending_request(GFP_ATOMIC);
 		if (!req) {
 			DBGMSG("arm_write -> rcode_conflict_error");
 			spin_unlock_irqrestore(&host_info_lock, irqflags);
@@ -1224,7 +1224,7 @@
 		    sizeof(struct arm_request) + sizeof(struct arm_response) +
 		    (length) * sizeof(byte_t) +
 		    sizeof(struct arm_request_response);
-		req->data = kmalloc(size, SLAB_ATOMIC);
+		req->data = kmalloc(size, GFP_ATOMIC);
 		if (!(req->data)) {
 			free_pending_request(req);
 			DBGMSG("arm_write -> rcode_conflict_error");
@@ -1415,7 +1415,7 @@
 	if (arm_addr->notification_options & ARM_LOCK) {
 		byte_t *buf1, *buf2;
 		DBGMSG("arm_lock -> entering notification-section");
-		req = __alloc_pending_request(SLAB_ATOMIC);
+		req = __alloc_pending_request(GFP_ATOMIC);
 		if (!req) {
 			DBGMSG("arm_lock -> rcode_conflict_error");
 			spin_unlock_irqrestore(&host_info_lock, irqflags);
@@ -1423,7 +1423,7 @@
 							   The request may be retried */
 		}
 		size = sizeof(struct arm_request) + sizeof(struct arm_response) + 3 * sizeof(*store) + sizeof(struct arm_request_response);	/* maximum */
-		req->data = kmalloc(size, SLAB_ATOMIC);
+		req->data = kmalloc(size, GFP_ATOMIC);
 		if (!(req->data)) {
 			free_pending_request(req);
 			DBGMSG("arm_lock -> rcode_conflict_error");
@@ -1643,7 +1643,7 @@
 	if (arm_addr->notification_options & ARM_LOCK) {
 		byte_t *buf1, *buf2;
 		DBGMSG("arm_lock64 -> entering notification-section");
-		req = __alloc_pending_request(SLAB_ATOMIC);
+		req = __alloc_pending_request(GFP_ATOMIC);
 		if (!req) {
 			spin_unlock_irqrestore(&host_info_lock, irqflags);
 			DBGMSG("arm_lock64 -> rcode_conflict_error");
@@ -1651,7 +1651,7 @@
 							   The request may be retried */
 		}
 		size = sizeof(struct arm_request) + sizeof(struct arm_response) + 3 * sizeof(*store) + sizeof(struct arm_request_response);	/* maximum */
-		req->data = kmalloc(size, SLAB_ATOMIC);
+		req->data = kmalloc(size, GFP_ATOMIC);
 		if (!(req->data)) {
 			free_pending_request(req);
 			spin_unlock_irqrestore(&host_info_lock, irqflags);
@@ -2460,7 +2460,7 @@
 	/* only one ISO activity event may be in the queue */
 	if (!__rawiso_event_in_queue(fi)) {
 		struct pending_request *req =
-		    __alloc_pending_request(SLAB_ATOMIC);
+		    __alloc_pending_request(GFP_ATOMIC);
 
 		if (req) {
 			req->file_info = fi;
Index: linux-2.6.19-rc6-mm1/include/net/request_sock.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/net/request_sock.h	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/net/request_sock.h	2006-11-28 16:10:00.000000000 -0800
@@ -60,7 +60,7 @@
 
 static inline struct request_sock *reqsk_alloc(const struct request_sock_ops *ops)
 {
-	struct request_sock *req = kmem_cache_alloc(ops->slab, SLAB_ATOMIC);
+	struct request_sock *req = kmem_cache_alloc(ops->slab, GFP_ATOMIC);
 
 	if (req != NULL)
 		req->rsk_ops = ops;
Index: linux-2.6.19-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.19-rc6-mm1.orig/include/linux/slab.h	2006-11-28 16:09:09.000000000 -0800
+++ linux-2.6.19-rc6-mm1/include/linux/slab.h	2006-11-28 16:10:10.000000000 -0800
@@ -17,7 +17,6 @@
 #include	<linux/types.h>
 
 /* flags for kmem_cache_alloc() */
-#define	SLAB_ATOMIC		GFP_ATOMIC
 #define	SLAB_KERNEL		GFP_KERNEL
 #define	SLAB_DMA		GFP_DMA
 
Index: linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/loss_interval.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccids/lib/loss_interval.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccids/lib/loss_interval.c	2006-11-28 16:10:00.000000000 -0800
@@ -125,7 +125,7 @@
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(hist, SLAB_ATOMIC);
+		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
 		if (entry == NULL) {
 			dccp_li_hist_purge(hist, list);
 			DCCP_BUG("loss interval list entry is NULL");
Index: linux-2.6.19-rc6-mm1/net/dccp/ccids/ccid3.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/dccp/ccids/ccid3.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/dccp/ccids/ccid3.c	2006-11-28 16:10:00.000000000 -0800
@@ -277,7 +277,7 @@
 	new_packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
 	if (new_packet == NULL || new_packet->dccphtx_sent) {
 		new_packet = dccp_tx_hist_entry_new(ccid3_tx_hist,
-						    SLAB_ATOMIC);
+						    GFP_ATOMIC);
 
 		rc = -ENOBUFS;
 		if (unlikely(new_packet == NULL)) {
@@ -887,7 +887,7 @@
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, SLAB_ATOMIC);
+		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
 
 		if (entry == NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
@@ -1009,7 +1009,7 @@
 	}
 
 	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
-					skb, SLAB_ATOMIC);
+					skb, GFP_ATOMIC);
 	if (unlikely(packet == NULL)) {
 		DCCP_WARN("%s, sk=%p, Not enough mem to add rx packet "
 			  "to history, consider it lost!\n", dccp_role(sk), sk);
Index: linux-2.6.19-rc6-mm1/net/core/dst.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/dst.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/dst.c	2006-11-28 16:10:00.000000000 -0800
@@ -132,7 +132,7 @@
 		if (ops->gc())
 			return NULL;
 	}
-	dst = kmem_cache_alloc(ops->kmem_cachep, SLAB_ATOMIC);
+	dst = kmem_cache_alloc(ops->kmem_cachep, GFP_ATOMIC);
 	if (!dst)
 		return NULL;
 	memset(dst, 0, ops->entry_size);
Index: linux-2.6.19-rc6-mm1/net/core/flow.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/flow.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/flow.c	2006-11-28 16:10:00.000000000 -0800
@@ -211,7 +211,7 @@
 		if (flow_count(cpu) > flow_hwm)
 			flow_cache_shrink(cpu);
 
-		fle = kmem_cache_alloc(flow_cachep, SLAB_ATOMIC);
+		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
 			fle->next = *head;
 			*head = fle;
Index: linux-2.6.19-rc6-mm1/net/core/neighbour.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/core/neighbour.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/core/neighbour.c	2006-11-28 16:10:00.000000000 -0800
@@ -251,7 +251,7 @@
 			goto out_entries;
 	}
 
-	n = kmem_cache_alloc(tbl->kmem_cachep, SLAB_ATOMIC);
+	n = kmem_cache_alloc(tbl->kmem_cachep, GFP_ATOMIC);
 	if (!n)
 		goto out_entries;
 
Index: linux-2.6.19-rc6-mm1/net/ipv4/inet_timewait_sock.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/inet_timewait_sock.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/inet_timewait_sock.c	2006-11-28 16:10:00.000000000 -0800
@@ -91,7 +91,7 @@
 {
 	struct inet_timewait_sock *tw =
 		kmem_cache_alloc(sk->sk_prot_creator->twsk_prot->twsk_slab,
-				 SLAB_ATOMIC);
+				 GFP_ATOMIC);
 	if (tw != NULL) {
 		const struct inet_sock *inet = inet_sk(sk);
 
Index: linux-2.6.19-rc6-mm1/net/ipv4/inet_hashtables.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv4/inet_hashtables.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv4/inet_hashtables.c	2006-11-28 16:10:00.000000000 -0800
@@ -31,7 +31,7 @@
 						 struct inet_bind_hashbucket *head,
 						 const unsigned short snum)
 {
-	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, SLAB_ATOMIC);
+	struct inet_bind_bucket *tb = kmem_cache_alloc(cachep, GFP_ATOMIC);
 
 	if (tb != NULL) {
 		tb->port      = snum;
Index: linux-2.6.19-rc6-mm1/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv6/ip6_fib.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv6/ip6_fib.c	2006-11-28 16:10:00.000000000 -0800
@@ -150,7 +150,7 @@
 {
 	struct fib6_node *fn;
 
-	if ((fn = kmem_cache_alloc(fib6_node_kmem, SLAB_ATOMIC)) != NULL)
+	if ((fn = kmem_cache_alloc(fib6_node_kmem, GFP_ATOMIC)) != NULL)
 		memset(fn, 0, sizeof(struct fib6_node));
 
 	return fn;
Index: linux-2.6.19-rc6-mm1/net/ipv6/xfrm6_tunnel.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/ipv6/xfrm6_tunnel.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/ipv6/xfrm6_tunnel.c	2006-11-28 16:10:00.000000000 -0800
@@ -180,7 +180,7 @@
 	spi = 0;
 	goto out;
 alloc_spi:
-	x6spi = kmem_cache_alloc(xfrm6_tunnel_spi_kmem, SLAB_ATOMIC);
+	x6spi = kmem_cache_alloc(xfrm6_tunnel_spi_kmem, GFP_ATOMIC);
 	if (!x6spi)
 		goto out;
 
Index: linux-2.6.19-rc6-mm1/net/sctp/sm_make_chunk.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sctp/sm_make_chunk.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sctp/sm_make_chunk.c	2006-11-28 16:10:00.000000000 -0800
@@ -979,7 +979,7 @@
 {
 	struct sctp_chunk *retval;
 
-	retval = kmem_cache_alloc(sctp_chunk_cachep, SLAB_ATOMIC);
+	retval = kmem_cache_alloc(sctp_chunk_cachep, GFP_ATOMIC);
 
 	if (!retval)
 		goto nodata;
Index: linux-2.6.19-rc6-mm1/net/sctp/socket.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/sctp/socket.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/sctp/socket.c	2006-11-28 16:10:00.000000000 -0800
@@ -4989,7 +4989,7 @@
 {
 	struct sctp_bind_bucket *pp;
 
-	pp = kmem_cache_alloc(sctp_bucket_cachep, SLAB_ATOMIC);
+	pp = kmem_cache_alloc(sctp_bucket_cachep, GFP_ATOMIC);
 	SCTP_DBG_OBJCNT_INC(bind_bucket);
 	if (pp) {
 		pp->port = snum;
Index: linux-2.6.19-rc6-mm1/net/xfrm/xfrm_input.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/net/xfrm/xfrm_input.c	2006-11-28 16:02:30.000000000 -0800
+++ linux-2.6.19-rc6-mm1/net/xfrm/xfrm_input.c	2006-11-28 16:10:00.000000000 -0800
@@ -27,7 +27,7 @@
 {
 	struct sec_path *sp;
 
-	sp = kmem_cache_alloc(secpath_cachep, SLAB_ATOMIC);
+	sp = kmem_cache_alloc(secpath_cachep, GFP_ATOMIC);
 	if (!sp)
 		return NULL;
 
Index: linux-2.6.19-rc6-mm1/security/selinux/avc.c
===================================================================
--- linux-2.6.19-rc6-mm1.orig/security/selinux/avc.c	2006-11-28 16:02:31.000000000 -0800
+++ linux-2.6.19-rc6-mm1/security/selinux/avc.c	2006-11-28 16:10:00.000000000 -0800
@@ -332,7 +332,7 @@
 {
 	struct avc_node *node;
 
-	node = kmem_cache_alloc(avc_node_cachep, SLAB_ATOMIC);
+	node = kmem_cache_alloc(avc_node_cachep, GFP_ATOMIC);
 	if (!node)
 		goto out;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
