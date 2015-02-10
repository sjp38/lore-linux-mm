Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id BA0676B006E
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 14:48:19 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id b13so30609766qcw.0
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 11:48:19 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id dg4si19389528qcb.41.2015.02.10.11.48.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 11:48:15 -0800 (PST)
Message-Id: <20150210194812.009097005@linux.com>
Date: Tue, 10 Feb 2015 13:48:07 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 3/3] Array alloc test code
References: <20150210194804.288708936@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=array_alloc_test
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Some simply thrown in thing that allocates 100 objects and frees them again.

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
