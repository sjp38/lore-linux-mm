Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id ED3AD6B0253
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 10:47:52 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so231848731wmu.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:47:52 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id hq2si2502502wjb.240.2016.01.21.07.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 07:47:51 -0800 (PST)
Date: Thu, 21 Jan 2016 16:47:29 +0100 (CET)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [Xen-devel] [PATCH v2] cleancache: constify cleancache_ops
 structure
In-Reply-To: <56A0B6E7.9040201@citrix.com>
Message-ID: <alpine.DEB.2.10.1601211646580.2530@hadrien>
References: <1450904784-17139-1-git-send-email-Julia.Lawall@lip6.fr> <56A0B6E7.9040201@citrix.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>

The cleancache_ops structure is never modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

v2: put back the read mostly

 drivers/xen/tmem.c         |    2 +-
 include/linux/cleancache.h |    2 +-
 mm/cleancache.c            |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/cleancache.h b/include/linux/cleancache.h
index bda5ec0b4..cb3e142 100644
--- a/include/linux/cleancache.h
+++ b/include/linux/cleancache.h
@@ -37,7 +37,7 @@ struct cleancache_ops {
 	void (*invalidate_fs)(int);
 };

-extern int cleancache_register_ops(struct cleancache_ops *ops);
+extern int cleancache_register_ops(const struct cleancache_ops *ops);
 extern void __cleancache_init_fs(struct super_block *);
 extern void __cleancache_init_shared_fs(struct super_block *);
 extern int  __cleancache_get_page(struct page *);
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index 945fc43..4ac2ca8 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -242,7 +242,7 @@ static int tmem_cleancache_init_shared_fs(char *uuid, size_t pagesize)
 	return xen_tmem_new_pool(shared_uuid, TMEM_POOL_SHARED, pagesize);
 }

-static struct cleancache_ops tmem_cleancache_ops = {
+static const struct cleancache_ops tmem_cleancache_ops = {
 	.put_page = tmem_cleancache_put_page,
 	.get_page = tmem_cleancache_get_page,
 	.invalidate_page = tmem_cleancache_flush_page,
diff --git a/mm/cleancache.c b/mm/cleancache.c
index 8fc5081..c6356d6 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -22,7 +22,7 @@
  * cleancache_ops is set by cleancache_register_ops to contain the pointers
  * to the cleancache "backend" implementation functions.
  */
-static struct cleancache_ops *cleancache_ops __read_mostly;
+static const struct cleancache_ops *cleancache_ops __read_mostly;

 /*
  * Counters available via /sys/kernel/debug/cleancache (if debugfs is
@@ -49,7 +49,7 @@ static void cleancache_register_ops_sb(struct super_block *sb, void *unused)
 /*
  * Register operations for cleancache. Returns 0 on success.
  */
-int cleancache_register_ops(struct cleancache_ops *ops)
+int cleancache_register_ops(const struct cleancache_ops *ops)
 {
 	if (cmpxchg(&cleancache_ops, NULL, ops))
 		return -EBUSY;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
