Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD226B03A5
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 14:58:47 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p50so49700154qtc.9
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:47 -0700 (PDT)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by mx.google.com with ESMTPS id x66si12692072qkc.129.2017.04.03.11.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Apr 2017 11:58:46 -0700 (PDT)
Received: by mail-qt0-f170.google.com with SMTP id n21so120802682qta.1
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 11:58:46 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 11/22] staging: android: ion: Remove duplicate ION_IOC_MAP
Date: Mon,  3 Apr 2017 11:57:53 -0700
Message-Id: <1491245884-15852-12-git-send-email-labbott@redhat.com>
In-Reply-To: <1491245884-15852-1-git-send-email-labbott@redhat.com>
References: <1491245884-15852-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, arve@android.com
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

ION_IOC_MAP is the same as ION_IOC_SHARE. We really don't need two
identical interfaces. Remove it.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/compat_ion.c |  1 -
 drivers/staging/android/ion/ion-ioctl.c  |  1 -
 drivers/staging/android/uapi/ion.h       | 10 ----------
 3 files changed, 12 deletions(-)

diff --git a/drivers/staging/android/ion/compat_ion.c b/drivers/staging/android/ion/compat_ion.c
index ae1ffc3..5037ddd 100644
--- a/drivers/staging/android/ion/compat_ion.c
+++ b/drivers/staging/android/ion/compat_ion.c
@@ -144,7 +144,6 @@ long compat_ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 							(unsigned long)data);
 	}
 	case ION_IOC_SHARE:
-	case ION_IOC_MAP:
 		return filp->f_op->unlocked_ioctl(filp, cmd,
 						(unsigned long)compat_ptr(arg));
 	default:
diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index 7b54eea..a361724 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -118,7 +118,6 @@ long ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		break;
 	}
 	case ION_IOC_SHARE:
-	case ION_IOC_MAP:
 	{
 		struct ion_handle *handle;
 
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index 3a59044..abd72fd 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -164,16 +164,6 @@ struct ion_heap_query {
 #define ION_IOC_FREE		_IOWR(ION_IOC_MAGIC, 1, struct ion_handle_data)
 
 /**
- * DOC: ION_IOC_MAP - get a file descriptor to mmap
- *
- * Takes an ion_fd_data struct with the handle field populated with a valid
- * opaque handle.  Returns the struct with the fd field set to a file
- * descriptor open in the current address space.  This file descriptor
- * can then be used as an argument to mmap.
- */
-#define ION_IOC_MAP		_IOWR(ION_IOC_MAGIC, 2, struct ion_fd_data)
-
-/**
  * DOC: ION_IOC_SHARE - creates a file descriptor to use to share an allocation
  *
  * Takes an ion_fd_data struct with the handle field populated with a valid
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
