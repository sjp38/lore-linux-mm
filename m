Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 077D36B0069
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 16:46:44 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 184so6843136oii.1
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 13:46:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w197si3331492oie.8.2018.01.08.13.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 13:46:43 -0800 (PST)
Date: Mon, 8 Jan 2018 15:46:41 -0600
From: Pete Zaitcev <zaitcev@redhat.com>
Subject: [PATCH] The usbmon triggers a BUG in ./include/linux/mm.h
Message-ID: <20180108154641.106218e8@lembas.zaitcev.lan>
In-Reply-To: <20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
References: <20171228160346.6406d52df0d9afe8cf7a0862@linux-foundation.org>
	<20171229132420.jn2pwabl6pyjo6mk@node.shutemov.name>
	<20180103010238.1e510ac2@lembas.zaitcev.lan>
	<20180103092604.5y4bvh3i644ts3zm@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, linux-usb@vger.kernel.org, zaitcev@redhat.com

Automated tests triggered this by opening usbmon and accessing the
mmap while simultaneously resizing the buffers. This bug was with
us since 2006, because typically applications only size the buffers
once and thus avoid racing. Reported by Kirill A. Shutemov.

Signed-off-by: Pete Zaitcev <zaitcev@redhat.com>
---
 drivers/usb/mon/mon_bin.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/usb/mon/mon_bin.c b/drivers/usb/mon/mon_bin.c
index f6ae753ab99b..f932f40302df 100644
--- a/drivers/usb/mon/mon_bin.c
+++ b/drivers/usb/mon/mon_bin.c
@@ -1004,7 +1004,9 @@ static long mon_bin_ioctl(struct file *file, unsigned int cmd, unsigned long arg
 		break;
 
 	case MON_IOCQ_RING_SIZE:
+		mutex_lock(&rp->fetch_lock);
 		ret = rp->b_size;
+		mutex_unlock(&rp->fetch_lock);
 		break;
 
 	case MON_IOCT_RING_SIZE:
@@ -1231,12 +1233,16 @@ static int mon_bin_vma_fault(struct vm_fault *vmf)
 	unsigned long offset, chunk_idx;
 	struct page *pageptr;
 
+	mutex_lock(&rp->fetch_lock);
 	offset = vmf->pgoff << PAGE_SHIFT;
-	if (offset >= rp->b_size)
+	if (offset >= rp->b_size) {
+		mutex_unlock(&rp->fetch_lock);
 		return VM_FAULT_SIGBUS;
+	}
 	chunk_idx = offset / CHUNK_SIZE;
 	pageptr = rp->b_vec[chunk_idx].pg;
 	get_page(pageptr);
+	mutex_unlock(&rp->fetch_lock);
 	vmf->page = pageptr;
 	return 0;
 }
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
