Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1B486B0307
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:35:19 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so75404411itb.3
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:35:19 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id c82si252849iof.144.2016.11.16.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:35:19 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 23/29] idr: Add ida_is_empty
Date: Wed, 16 Nov 2016 16:16:50 -0800
Message-Id: <1479341856-30320-26-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Two of the USB Gadgets were poking around in the internals of struct ida
in order to determine if it is empty.  Add the appropriate abstraction.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 drivers/usb/gadget/function/f_hid.c     | 6 +++---
 drivers/usb/gadget/function/f_printer.c | 6 +++---
 include/linux/idr.h                     | 5 +++++
 3 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/gadget/function/f_hid.c b/drivers/usb/gadget/function/f_hid.c
index e2966f8..b9b04fc 100644
--- a/drivers/usb/gadget/function/f_hid.c
+++ b/drivers/usb/gadget/function/f_hid.c
@@ -840,7 +840,7 @@ static void hidg_free_inst(struct usb_function_instance *f)
 	mutex_lock(&hidg_ida_lock);
 
 	hidg_put_minor(opts->minor);
-	if (idr_is_empty(&hidg_ida.idr))
+	if (ida_is_empty(&hidg_ida))
 		ghid_cleanup();
 
 	mutex_unlock(&hidg_ida_lock);
@@ -866,7 +866,7 @@ static struct usb_function_instance *hidg_alloc_inst(void)
 
 	mutex_lock(&hidg_ida_lock);
 
-	if (idr_is_empty(&hidg_ida.idr)) {
+	if (ida_is_empty(&hidg_ida)) {
 		status = ghid_setup(NULL, HIDG_MINORS);
 		if (status)  {
 			ret = ERR_PTR(status);
@@ -879,7 +879,7 @@ static struct usb_function_instance *hidg_alloc_inst(void)
 	if (opts->minor < 0) {
 		ret = ERR_PTR(opts->minor);
 		kfree(opts);
-		if (idr_is_empty(&hidg_ida.idr))
+		if (ida_is_empty(&hidg_ida))
 			ghid_cleanup();
 		goto unlock;
 	}
diff --git a/drivers/usb/gadget/function/f_printer.c b/drivers/usb/gadget/function/f_printer.c
index 0de36cd..8054da9 100644
--- a/drivers/usb/gadget/function/f_printer.c
+++ b/drivers/usb/gadget/function/f_printer.c
@@ -1265,7 +1265,7 @@ static void gprinter_free_inst(struct usb_function_instance *f)
 	mutex_lock(&printer_ida_lock);
 
 	gprinter_put_minor(opts->minor);
-	if (idr_is_empty(&printer_ida.idr))
+	if (ida_is_empty(&printer_ida))
 		gprinter_cleanup();
 
 	mutex_unlock(&printer_ida_lock);
@@ -1289,7 +1289,7 @@ static struct usb_function_instance *gprinter_alloc_inst(void)
 
 	mutex_lock(&printer_ida_lock);
 
-	if (idr_is_empty(&printer_ida.idr)) {
+	if (ida_is_empty(&printer_ida)) {
 		status = gprinter_setup(PRINTER_MINORS);
 		if (status) {
 			ret = ERR_PTR(status);
@@ -1302,7 +1302,7 @@ static struct usb_function_instance *gprinter_alloc_inst(void)
 	if (opts->minor < 0) {
 		ret = ERR_PTR(opts->minor);
 		kfree(opts);
-		if (idr_is_empty(&printer_ida.idr))
+		if (ida_is_empty(&printer_ida))
 			gprinter_cleanup();
 		goto unlock;
 	}
diff --git a/include/linux/idr.h b/include/linux/idr.h
index 083d61e..3639a28 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -195,6 +195,11 @@ static inline int ida_get_new(struct ida *ida, int *p_id)
 	return ida_get_new_above(ida, 0, p_id);
 }
 
+static inline bool ida_is_empty(struct ida *ida)
+{
+	return idr_is_empty(&ida->idr);
+}
+
 void __init idr_init_cache(void);
 
 #endif /* __IDR_H__ */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
