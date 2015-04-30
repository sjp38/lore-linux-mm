Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id D78246B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:38:25 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so48941359lbb.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:38:25 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kw5si2114469lac.121.2015.04.30.09.38.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 09:38:23 -0700 (PDT)
Message-ID: <55425A74.3020604@parallels.com>
Date: Thu, 30 Apr 2015 19:38:12 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH] UserfaultFD: Rename uffd_api.bits into .features
References: <5509D342.7000403@parallels.com> <20150421120222.GC4481@redhat.com> <55389261.50105@parallels.com> <20150427211650.GC24035@redhat.com>
In-Reply-To: <20150427211650.GC24035@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linux MM <linux-mm@kvack.org>

Hi,

This is (seem to be) the minimal thing that is required to unblock
standard uffd usage from the non-cooperative one. Now more bits can
be added to the features field indicating e.g. UFFD_FEATURE_FORK and
others needed for the latter use-case.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index d2db3e1..c4d0216 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1090,7 +1090,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 		goto out;
 	}
 	/* careful not to leak info, we only read the first 8 bytes */
-	uffdio_api.bits = UFFD_API_BITS;
+	uffdio_api.features = UFFD_API_FEATURES;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 	ret = -EFAULT;
 	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
@@ -1159,7 +1159,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	 *	protocols: aa:... bb:...
 	 */
 	seq_printf(m, "pending:\t%lu\ntotal:\t%lu\nAPI:\t%Lx:%x:%Lx\n",
-		   pending, total, UFFD_API, UFFD_API_BITS,
+		   pending, total, UFFD_API, UFFD_API_FEATURES,
 		   UFFD_API_IOCTLS|UFFD_API_RANGE_IOCTLS);
 }
 #endif
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index aecd64b..3dc0cba 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -11,7 +11,7 @@
 
 #define UFFD_API ((__u64)0xAA)
 /* FIXME: add "|UFFD_BIT_WP" to UFFD_API_BITS after implementing it */
-#define UFFD_API_BITS (UFFD_BIT_WRITE)
+#define UFFD_API_FEATURES (UFFD_FEATURE_WRITE_BIT)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -63,12 +63,18 @@
 #define UFFD_BIT_WP	(1<<1)	/* handle_userfault() reason VM_UFFD_WP */
 #define UFFD_BITS	2	/* two above bits used for UFFD_BIT_* mask */
 
+/*
+ * Features reported in uffdio_api.features field
+ */
+#define UFFD_FEATURE_WRITE_BIT	(1<<0) /* Corresponds to UFFD_BIT_WRITE */
+#define UFFD_FEATURE_WP_BIT	(1<<1) /* Corresponds to UFFD_BIT_WP */
+
 struct uffdio_api {
 	/* userland asks for an API number */
 	__u64 api;
 
 	/* kernel answers below with the available features for the API */
-	__u64 bits;
+	__u64 features;
 	__u64 ioctls;
 };
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
