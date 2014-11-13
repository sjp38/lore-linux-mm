Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 535BF6B00E3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:31:10 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so15160333pde.8
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 14:31:10 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id uk9si24278405pac.11.2014.11.13.14.31.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 14:31:09 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so16168526pab.12
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 14:31:08 -0800 (PST)
Date: Fri, 14 Nov 2014 07:31:27 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 1/3] mm/zsmalloc: avoid unregister a NOT-registered
 zsmalloc zpool driver
Message-ID: <20141113223127.GA951@swordfish>
References: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
 <20141113152247.GB1408@swordfish>
 <20141113153017.GC1408@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141113153017.GC1408@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (11/14/14 00:30), Sergey Senozhatsky wrote:
> Factor out zsmalloc cpu notifier unregistration code and call
> it from both zs_exit() and zs_init() error path.

I should had have a good sleep before posting this.
shame on me!

v3

Signed-ogg-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

---

 mm/zsmalloc.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b3b57ef..cd4efa1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -881,14 +881,10 @@ static struct notifier_block zs_cpu_nb = {
 	.notifier_call = zs_cpu_notifier
 };
 
-static void zs_exit(void)
+static void zs_unregister_cpu_notifier(void)
 {
 	int cpu;
 
-#ifdef CONFIG_ZPOOL
-	zpool_unregister_driver(&zs_zpool_driver);
-#endif
-
 	cpu_notifier_register_begin();
 
 	for_each_online_cpu(cpu)
@@ -898,6 +894,14 @@ static void zs_exit(void)
 	cpu_notifier_register_done();
 }
 
+static void zs_exit(void)
+{
+#ifdef CONFIG_ZPOOL
+	zpool_unregister_driver(&zs_zpool_driver);
+#endif
+	zs_unregister_cpu_notifier();
+}
+
 static int zs_init(void)
 {
 	int cpu, ret;
@@ -921,7 +925,7 @@ static int zs_init(void)
 
 	return 0;
 fail:
-	zs_exit();
+	zs_unregister_cpu_notifier();
 	return notifier_to_errno(ret);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
