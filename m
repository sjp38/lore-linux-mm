Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6486E6B000C
	for <linux-mm@kvack.org>; Sun,  6 May 2018 05:22:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j18-v6so15986954pgv.18
        for <linux-mm@kvack.org>; Sun, 06 May 2018 02:22:05 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a12-v6si16157695pgn.631.2018.05.06.02.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 06 May 2018 02:22:03 -0700 (PDT)
Date: Sun, 6 May 2018 06:21:47 -0300
From: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Subject: Re: [PATCH 1/2] media: siano: don't use GFP_DMA
Message-ID: <20180506062147.260be463@vento.lan>
In-Reply-To: <CAM1upfOiM77w=_65xarL9=68cTDP81b3_cx02v8mUjsrCwBo=Q@mail.gmail.com>
References: <dc56acf384130d9703684a239d8daa8748f63d8e.1525536580.git.mchehab+samsung@kernel.org>
	<CAM1upfOiM77w=_65xarL9=68cTDP81b3_cx02v8mUjsrCwBo=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomoki Sekiyama <tomoki.sekiyama@gmail.com>
Cc: Linux Media Mailing List <linux-media@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, Markus Elfring <elfring@users.sourceforge.net>, Hans Verkuil <hansverk@cisco.com>, "Luis
 R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org

Em Sun, 6 May 2018 08:05:05 +0900
Tomoki Sekiyama <tomoki.sekiyama@gmail.com> escreveu:

> 2018/5/6 1:09 Mauro Carvalho Chehab <mchehab+samsung@kernel.org>:
> 
> > I can't think on a single reason why this driver would be using
> > GFP_DMA. The typical usage is as an USB driver. Any DMA restrictions
> > should be handled inside the HCI driver, if any.
> >  
> 
> siano driver supports SDIO (implemented
> in drivers/media/mmc/siano/smssdio.c) as well as USB.
> It looks like using sdio_memcpy_toio() to DMA transfer. I think that's why
> it is using GFP_DMA.

Good point. I always forget about the mmc variant, as I don't
have any hardware to test.

The best seems to add a new parameter to sms core register
function, allowing it to use extra gfp flags, and pass it only
for the SDIO variant.

Patch enclosed.

Regards,
Mauro

[PATCH 1/2 v2] media: siano: use GFP_DMA only for smssdio

Right now, the Siano's core uses GFP_DMA for both USB and
SDIO variants of the driver. There's no reason to use it
for USB. So, pass GFP_DMA as a parameter during sms core
register.

Signed-off-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>

diff --git a/drivers/media/common/siano/smscoreapi.c b/drivers/media/common/siano/smscoreapi.c
index b5dcc6d1fe90..9ed7afa7b2ae 100644
--- a/drivers/media/common/siano/smscoreapi.c
+++ b/drivers/media/common/siano/smscoreapi.c
@@ -649,6 +649,7 @@ smscore_buffer_t *smscore_createbuffer(u8 *buffer, void *common_buffer,
  */
 int smscore_register_device(struct smsdevice_params_t *params,
 			    struct smscore_device_t **coredev,
+			    gfp_t gfp_buf_flags,
 			    void *mdev)
 {
 	struct smscore_device_t *dev;
@@ -661,6 +662,7 @@ int smscore_register_device(struct smsdevice_params_t *params,
 #ifdef CONFIG_MEDIA_CONTROLLER_DVB
 	dev->media_dev = mdev;
 #endif
+	dev->gfp_buf_flags = gfp_buf_flags;
 
 	/* init list entry so it could be safe in smscore_unregister_device */
 	INIT_LIST_HEAD(&dev->entry);
@@ -697,7 +699,7 @@ int smscore_register_device(struct smsdevice_params_t *params,
 		buffer = dma_alloc_coherent(params->device,
 					    dev->common_buffer_size,
 					    &dev->common_buffer_phys,
-					    GFP_KERNEL | GFP_DMA);
+					    GFP_KERNEL | dev->gfp_buf_flags);
 	if (!buffer) {
 		smscore_unregister_device(dev);
 		return -ENOMEM;
@@ -792,7 +794,7 @@ static int smscore_init_ir(struct smscore_device_t *coredev)
 		else {
 			buffer = kmalloc(sizeof(struct sms_msg_data2) +
 						SMS_DMA_ALIGNMENT,
-						GFP_KERNEL | GFP_DMA);
+						GFP_KERNEL | coredev->gfp_buf_flags);
 			if (buffer) {
 				struct sms_msg_data2 *msg =
 				(struct sms_msg_data2 *)
@@ -933,7 +935,7 @@ static int smscore_load_firmware_family2(struct smscore_device_t *coredev,
 	}
 
 	/* PAGE_SIZE buffer shall be enough and dma aligned */
-	msg = kmalloc(PAGE_SIZE, GFP_KERNEL | GFP_DMA);
+	msg = kmalloc(PAGE_SIZE, GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!msg)
 		return -ENOMEM;
 
@@ -1168,7 +1170,7 @@ static int smscore_load_firmware_from_file(struct smscore_device_t *coredev,
 	}
 	pr_debug("read fw %s, buffer size=0x%zx\n", fw_filename, fw->size);
 	fw_buf = kmalloc(ALIGN(fw->size + sizeof(struct sms_firmware),
-			 SMS_ALLOC_ALIGNMENT), GFP_KERNEL | GFP_DMA);
+			 SMS_ALLOC_ALIGNMENT), GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!fw_buf) {
 		pr_err("failed to allocate firmware buffer\n");
 		rc = -ENOMEM;
@@ -1260,7 +1262,7 @@ EXPORT_SYMBOL_GPL(smscore_unregister_device);
 static int smscore_detect_mode(struct smscore_device_t *coredev)
 {
 	void *buffer = kmalloc(sizeof(struct sms_msg_hdr) + SMS_DMA_ALIGNMENT,
-			       GFP_KERNEL | GFP_DMA);
+			       GFP_KERNEL | coredev->gfp_buf_flags);
 	struct sms_msg_hdr *msg =
 		(struct sms_msg_hdr *) SMS_ALIGN_ADDRESS(buffer);
 	int rc;
@@ -1309,7 +1311,7 @@ static int smscore_init_device(struct smscore_device_t *coredev, int mode)
 	int rc = 0;
 
 	buffer = kmalloc(sizeof(struct sms_msg_data) +
-			SMS_DMA_ALIGNMENT, GFP_KERNEL | GFP_DMA);
+			SMS_DMA_ALIGNMENT, GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!buffer)
 		return -ENOMEM;
 
@@ -1398,7 +1400,7 @@ int smscore_set_device_mode(struct smscore_device_t *coredev, int mode)
 		coredev->device_flags &= ~SMS_DEVICE_NOT_READY;
 
 		buffer = kmalloc(sizeof(struct sms_msg_data) +
-				 SMS_DMA_ALIGNMENT, GFP_KERNEL | GFP_DMA);
+				 SMS_DMA_ALIGNMENT, GFP_KERNEL | coredev->gfp_buf_flags);
 		if (buffer) {
 			struct sms_msg_data *msg = (struct sms_msg_data *) SMS_ALIGN_ADDRESS(buffer);
 
@@ -1971,7 +1973,7 @@ int smscore_gpio_configure(struct smscore_device_t *coredev, u8 pin_num,
 	total_len = sizeof(struct sms_msg_hdr) + (sizeof(u32) * 6);
 
 	buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
-			GFP_KERNEL | GFP_DMA);
+			GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!buffer)
 		return -ENOMEM;
 
@@ -2043,7 +2045,7 @@ int smscore_gpio_set_level(struct smscore_device_t *coredev, u8 pin_num,
 			(3 * sizeof(u32)); /* keep it 3 ! */
 
 	buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
-			GFP_KERNEL | GFP_DMA);
+			GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!buffer)
 		return -ENOMEM;
 
@@ -2091,7 +2093,7 @@ int smscore_gpio_get_level(struct smscore_device_t *coredev, u8 pin_num,
 	total_len = sizeof(struct sms_msg_hdr) + (2 * sizeof(u32));
 
 	buffer = kmalloc(total_len + SMS_DMA_ALIGNMENT,
-			GFP_KERNEL | GFP_DMA);
+			GFP_KERNEL | coredev->gfp_buf_flags);
 	if (!buffer)
 		return -ENOMEM;
 
diff --git a/drivers/media/common/siano/smscoreapi.h b/drivers/media/common/siano/smscoreapi.h
index 134c69f7ea7b..eb58853008c9 100644
--- a/drivers/media/common/siano/smscoreapi.h
+++ b/drivers/media/common/siano/smscoreapi.h
@@ -190,6 +190,8 @@ struct smscore_device_t {
 
 	int mode, modes_supported;
 
+	gfp_t gfp_buf_flags;
+
 	/* host <--> device messages */
 	struct completion version_ex_done, data_download_done, trigger_done;
 	struct completion data_validity_done, device_ready_done;
@@ -1125,6 +1127,7 @@ extern void smscore_unregister_hotplug(hotplug_t hotplug);
 
 extern int smscore_register_device(struct smsdevice_params_t *params,
 				   struct smscore_device_t **coredev,
+				   gfp_t gfp_buf_flags,
 				   void *mdev);
 extern void smscore_unregister_device(struct smscore_device_t *coredev);
 
diff --git a/drivers/media/mmc/siano/smssdio.c b/drivers/media/mmc/siano/smssdio.c
index fee2d710bbf8..b9e40d4ca0e8 100644
--- a/drivers/media/mmc/siano/smssdio.c
+++ b/drivers/media/mmc/siano/smssdio.c
@@ -279,7 +279,7 @@ static int smssdio_probe(struct sdio_func *func,
 		goto free;
 	}
 
-	ret = smscore_register_device(&params, &smsdev->coredev, NULL);
+	ret = smscore_register_device(&params, &smsdev->coredev, GFP_DMA, NULL);
 	if (ret < 0)
 		goto free;
 
diff --git a/drivers/media/usb/siano/smsusb.c b/drivers/media/usb/siano/smsusb.c
index 6d436e9e454f..be3634407f1f 100644
--- a/drivers/media/usb/siano/smsusb.c
+++ b/drivers/media/usb/siano/smsusb.c
@@ -455,7 +455,7 @@ static int smsusb_init_device(struct usb_interface *intf, int board_id)
 	mdev = siano_media_device_register(dev, board_id);
 
 	/* register in smscore */
-	rc = smscore_register_device(&params, &dev->coredev, mdev);
+	rc = smscore_register_device(&params, &dev->coredev, 0, mdev);
 	if (rc < 0) {
 		pr_err("smscore_register_device(...) failed, rc %d\n", rc);
 		smsusb_term_device(intf);
