Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6DF6B0070
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 16:37:43 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id b13so8473813qcw.9
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 13:37:42 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 8si3641100qcp.5.2015.01.23.13.37.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 13:37:38 -0800 (PST)
Message-Id: <20150123213735.817839692@linux.com>
Date: Fri, 23 Jan 2015 15:37:30 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 3/3] Array alloc test code
References: <20150123213727.142554068@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=array_alloc_test
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>


Some simply throw in thing that allocates 100 objects and frees them again.

Spews out complaints about interrupts disabled since we are in an initcall.
But it shows that it works.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -5308,6 +5308,22 @@ static int __init slab_sysfs_init(void)
 
 	mutex_unlock(&slab_mutex);
 	resiliency_test();
+
+	/* Test array alloc */
+	{
+		void *arr[100];
+		int nr;
+
+		printk(KERN_INFO "Array allocation test\n");
+		printk(KERN_INFO "---------------------\n");
+		printk(KERN_INFO "Allocation 100 objects\n");
+		nr = kmem_cache_alloc_array(kmem_cache_node, GFP_KERNEL, 100, arr);
+		printk(KERN_INFO "Number allocated = %d\n", nr);
+		printk(KERN_INFO "Freeing the objects\n");
+		kmem_cache_free_array(kmem_cache_node, 100, arr);
+		printk(KERN_INFO "Array allocation test done.\n");
+	}
+
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
