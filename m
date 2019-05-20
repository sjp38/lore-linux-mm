Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F001AC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:43:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A753320856
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:43:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gAlSX8TO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A753320856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 448686B0272; Mon, 20 May 2019 01:43:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F8F06B0273; Mon, 20 May 2019 01:43:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E9556B0274; Mon, 20 May 2019 01:43:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 07B026B0272
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:43:01 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id h11so11803407qkk.1
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:43:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=saCxizw32Jq7dMTN5gwfHcfa+dy7EpZHGbTHKFMG+ho=;
        b=aLKpSCqqsloO/JFiMsaJlQ6/H9WdZrtp3jeDniQUVMI7wARFAU9yg+Y84uQuH8U1cV
         UiwNlSboGtyeG3+ELarmVJRzGW6mHSRmOz/BiYcn+yBwpAuCr1AP0VVEMuueTerfUni+
         EXgwN51Es1NYSb7MzO+DeXJHSX1x9yUIpGTZLb80yScvt1CrekPoYM8AaZoaBBMv0hii
         wUOJVE4xPSAubveZArlLEROJAxK1EYAcWUv1wLhOmrtfF+bXRPYL+bUXAH7w9t3McAEz
         596y5+VLPd9/NLKv7qh0EZsBllqGW1YNUJwHJu8xJXOzCXyfsNICNWKdKATS8fh1DuGr
         3Efg==
X-Gm-Message-State: APjAAAX8WYPELMa+2/iKM8ZDKHnA7ky/87195iKCdzs/SeGfT1JuXqH5
	ZIsvDxVQ4Y+3CdXW7f+U36DcY7AnMcjY+jNTE6uQ7tfaPjmB9lN8MDdkshoLa9SPBrokVpN2pTe
	lF50AyPWR4yU1ebfR25a6t8WWkF0d6hZJx20vcJs7JsD12HJMqeDEUQMdV5hjVZI=
X-Received: by 2002:a0c:b92f:: with SMTP id u47mr49121300qvf.94.1558330980727;
        Sun, 19 May 2019 22:43:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9d9F7XDuiHOHgVcj+XLX1lCU6U6ZHAyj8SKzqb/1VsYuBWC98ka9GNgQegqUjh72fQ4g6
X-Received: by 2002:a0c:b92f:: with SMTP id u47mr49121227qvf.94.1558330979547;
        Sun, 19 May 2019 22:42:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330979; cv=none;
        d=google.com; s=arc-20160816;
        b=xuUyp4OLmswxnOw0o2EvbLSYbarWfGY2DcTTD1o59YbZqUF9Oyp5UBXPuTuUn8LylW
         EEa5ROsnrhZuVehm2cMvvOWqyPz2874vvcKH/pFr9WfTD5Mfcz8GIFnOy3oR7ciCQpr/
         WZRj4rq1wZYGqdDXEDQI8h8OsFh2YOmZGPXRazGno9gyZHy0W0xMJib1XaLTqlU4Y+w3
         NJ6epaKJ8chrWm5LYfNrxyS0Op77onsCU+AQtRdUzR/uDqnJz21dYS+/FJNuwwvVTLS0
         rNfuU9VeqFMnqoK/DvqhCCwxE1GYZJfkK5Z5T8vMZ4cb3LTCdm/jzw/qJtDESzkxPCHD
         fSEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=saCxizw32Jq7dMTN5gwfHcfa+dy7EpZHGbTHKFMG+ho=;
        b=IvfR/zh8Tunc79XvF2lNg8kblqthMZpxTFAX4jCwT+33HqznEfrd5BA7FvSBPbmViB
         tJO4mIYM6gkJJWeX9t9JqfQP78uiW7oJqul/ttLVa6hNab09+VtO8vQw0ld6ojU804La
         GBRvB4K+MOH1g/Eu2YilVfARvXlKIgyDu08Vlkip5W0bDE2It6bG8FSfiF+XKr9iYDN/
         w78d2J9gxiVfZVPQTIM5gfWeYntAH0wVaVBsx6OsfwluGD4LyO8e/T/RPk5eGLJfMQol
         IlJ2x+MddAlxG5Gxdj+27odi5hsEenIrfDqyssePiRAPZYE9vD9FBKInkWj8uyQ29p1x
         wsxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gAlSX8TO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id k36si3040568qtd.217.2019.05.19.22.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gAlSX8TO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 3D25710E56;
	Mon, 20 May 2019 01:42:59 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=saCxizw32Jq7dMTN5gwfHcfa+dy7EpZHGbTHKFMG+ho=; b=gAlSX8TO
	fcuek0YYCjnPtnRqtTcFPf18A3CjnScnL+unrhGzFdsGVFTur1RufeyGl9kcHIaL
	uh+hknblFftXo3OYtovnHQI2ovqIw3J2VlkVvKvL2XMGveghgWqujLvvqSY+MEoe
	E4fMy9EQy2zlr1MI5fcpEWgb9YE1vP/9Uql5R27Y98ZbHlNDeqFpIlf9d7j1De8p
	CK6f9780Qk7kRhUIHEU9zvE4Ugss5ENJOjjRl8UG/N8YxE2xrnBzHk9BvYQANfJN
	RHwzqYkX7doCeg+0YeDniqXxNMRyE+u8ftFvTnoIrEeAIoDQguHkwlYO5BE0GgMT
	zwwTNjFHjeRviw==
X-ME-Sender: <xms:Yj7iXKNnVSUcQRk2g_7dQ0ex5OaE1H7QBvisnGaTsBHRtJh0JuWTMQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepudeg
X-ME-Proxy: <xmx:Yj7iXNOH4iW8wxBM2SLZ9guclf989J13YwVM2CrnSbKr4NzSADYbvw>
    <xmx:Yj7iXMRTqplrYJndw1fxg_JsUYdN2SgMpgd3WtEcbb2dNd3A78x6zg>
    <xmx:Yj7iXPDLdrTfg3fJfqQAwLdLrLao8F5ueKsP2yN_B9r5gOIVHFy7bQ>
    <xmx:Yz7iXGFoOtQ8Iy44Z1cLvm308Kv_fiOVCGVvmSLFcDRYYHIMr9mBqQ>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 016CE8005B;
	Mon, 20 May 2019 01:42:51 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Alexander Viro <viro@ftp.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Christopher Lameter <cl@linux.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	Theodore Ts'o <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 15/16] dcache: Implement partial shrink via Slab Movable Objects
Date: Mon, 20 May 2019 15:40:16 +1000
Message-Id: <20190520054017.32299-16-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The dentry slab cache is susceptible to internal fragmentation.  Now
that we have Slab Movable Objects we can attempt to defragment the
dcache.  Dentry objects are inherently _not_ relocatable however under
some conditions they can be free'd.  This is the same as shrinking the
dcache but instead of shrinking the whole cache we only attempt to free
those objects that are located in partially full slab pages.  There is
no guarantee that this will reduce the memory usage of the system, it is
a compromise between fragmented memory and total cache shrinkage with
the hope that some memory pressure can be alleviated.

This is implemented using the newly added Slab Movable Objects
infrastructure.  The dcache 'migration' function is intentionally _not_
called 'd_migrate' because we only free, we do not migrate.  Call it
'd_partial_shrink' to make explicit that no reallocation is done.

Implement isolate and 'migrate' functions for the dentry slab cache.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index b7318615979d..0dfe580c2d42 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -31,6 +31,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/list_lru.h>
+#include <linux/backing-dev.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -3071,6 +3072,79 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+/*
+ * d_isolate() - Dentry isolation callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to isolate.
+ * @nr: Number of objects in @v.
+ *
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *d_isolate(struct kmem_cache *s, void **v, int nr)
+{
+	struct list_head *dispose;
+	struct dentry *dentry;
+	int i;
+
+	dispose = kmalloc(sizeof(*dispose), GFP_KERNEL);
+	if (!dispose)
+		return NULL;
+
+	INIT_LIST_HEAD(dispose);
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		spin_lock(&dentry->d_lock);
+
+		if (dentry->d_lockref.count > 0 ||
+		    dentry->d_flags & DCACHE_SHRINK_LIST) {
+			spin_unlock(&dentry->d_lock);
+			continue;
+		}
+
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+
+		d_shrink_add(dentry, dispose);
+		spin_unlock(&dentry->d_lock);
+	}
+
+	return dispose;
+}
+
+/*
+ * d_partial_shrink() - Dentry migration callback function.
+ * @s: The dentry cache.
+ * @_unused: We do not access the vector.
+ * @__unused: No need for length of vector.
+ * @___unused: We do not do any allocation.
+ * @private: list_head pointer representing the shrink list.
+ *
+ * Dispose of the shrink list created during isolation function.
+ *
+ * Dentry objects can _not_ be relocated and shrinking the whole dcache
+ * can be expensive.  This is an effort to free dentry objects that are
+ * stopping slab pages from being free'd without clearing the whole dcache.
+ *
+ * This callback is called from the SLUB allocator object migration
+ * infrastructure in attempt to free up slab pages by freeing dentry
+ * objects from partially full slabs.
+ */
+static void d_partial_shrink(struct kmem_cache *s, void **_unused, int __unused,
+			     int ___unused, void *private)
+{
+	struct list_head *dispose = private;
+
+	if (!private)		/* kmalloc error during isolate. */
+		return;
+
+	if (!list_empty(dispose))
+		shrink_dentry_list(dispose);
+
+	kfree(private);
+}
+
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
@@ -3116,6 +3190,8 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
-- 
2.21.0

