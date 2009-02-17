Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8353C6B00B4
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 14:44:11 -0500 (EST)
Message-Id: <20090217184136.097882343@cmpxchg.org>
Date: Tue, 17 Feb 2009 19:26:20 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/7] usb: use kzfree()
References: <20090217182615.897042724@cmpxchg.org>
Content-Disposition: inline; filename=usb-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Chas Williams <chas@cmf.nrl.navy.mil>, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
---
 drivers/usb/host/hwa-hc.c   |    3 +--
 drivers/usb/wusbcore/cbaf.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

--- a/drivers/usb/host/hwa-hc.c
+++ b/drivers/usb/host/hwa-hc.c
@@ -464,8 +464,7 @@ static int __hwahc_dev_set_key(struct wu
 			port_idx << 8 | iface_no,
 			keyd, keyd_len, 1000 /* FIXME: arbitrary */);
 
-	memset(keyd, 0, sizeof(*keyd));	/* clear keys etc. */
-	kfree(keyd);
+	kzfree(keyd); /* clear keys etc. */
 	return result;
 }
 
--- a/drivers/usb/wusbcore/cbaf.c
+++ b/drivers/usb/wusbcore/cbaf.c
@@ -638,8 +638,7 @@ static void cbaf_disconnect(struct usb_i
 	usb_put_intf(iface);
 	kfree(cbaf->buffer);
 	/* paranoia: clean up crypto keys */
-	memset(cbaf, 0, sizeof(*cbaf));
-	kfree(cbaf);
+	kzfree(cbaf);
 }
 
 static struct usb_device_id cbaf_id_table[] = {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
