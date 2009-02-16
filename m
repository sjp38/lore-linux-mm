Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB116B009B
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 10:05:05 -0500 (EST)
Message-Id: <20090216144725.901238204@cmpxchg.org>
Date: Mon, 16 Feb 2009 15:29:31 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/8] usb: use kzfree()
References: <20090216142926.440561506@cmpxchg.org>
Content-Disposition: inline; filename=usb-use-kzfree.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

Use kzfree() instead of memset() + kfree().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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
+	kzfree(keyd);
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
