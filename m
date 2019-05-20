Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA564C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620912081C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="4q0hWeJv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620912081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EED56B0266; Mon, 20 May 2019 01:42:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09FBD6B0269; Mon, 20 May 2019 01:42:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAA486B026A; Mon, 20 May 2019 01:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD6486B0266
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:17 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w34so13200138qtc.16
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F5aR/6PSAAo/4gqYLlgL9w8L/omD4wgEh0XNiCKl+dI=;
        b=ZcBQOLFCdcg3jFVGIo1qFgn/JLd36szFtga5iJ2jnz4TBFB9lh3c6zLiQB7hDuarKi
         CNla9Aas7WHndT7MjZzlM0fqde4W+6o2LdgBObsyGGY96xhwyFCjWrQ62usAm4GYeEiE
         CtHav9b57Ka7vhNibWvqfq0lo1gqPzvB2Uco2Tod7m2toJ1UMpiY21Hl6vxiZRRTknqy
         cwsgJuVjgDdJ0peoOeKy3zkTPygMXfKcLbUU/QvShxl7WwFrjEeF3rkV/ucIDUMj4/YB
         WHsBM979K9K4Uj0Mvho/QilLplU6d0zZ8lzncuVRNldnrGh2V6WjgdefUxnm8PonB/wr
         hpFw==
X-Gm-Message-State: APjAAAU0ZfbhhKp9jhXBG8DLJE6GR6i+LxuvAS/47JHtaNBr46jl2KDf
	mOEfDbgxxGL++CNDHDWwbijHu9S1vtWYF/PTrMdkh0PTzXM5w2aIij73OgIfIHOBrhbJhzVTtrJ
	7I+/y7VKMD0EQvt4oOYRpWQFoc2OeCFenEEWbiV4GgwsL3lI1QakuTXUjkuu+2X8=
X-Received: by 2002:a05:620a:1346:: with SMTP id c6mr56223389qkl.275.1558330937517;
        Sun, 19 May 2019 22:42:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOYq6fz0eWrWE2vuLDbp4ILFMK4YqFw1yWfPwT5BMdMGZiRavF5Yk44GML5/2uvQnks1Wn
X-Received: by 2002:a05:620a:1346:: with SMTP id c6mr56223326qkl.275.1558330936213;
        Sun, 19 May 2019 22:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330936; cv=none;
        d=google.com; s=arc-20160816;
        b=vF5fTnN/3iFvhQ5dZcWO59vn34exYivb89uG54LSiq4PPwzazIvSaJ/kw6cj+y+OCD
         YBN0J9fUJniWy2C+fRNSswj+ErdG4nlEOuwfPZ2mTay4vc5hVYJi3ALRvuMBwq/DMB7/
         Mp+oC6dLi7tECsxU/jCazx2NdZ90z7ihn7DdmWTSriX4/+dczLed7yjj6M5ryS9umbkZ
         nuRrDdwgIuvomaQr85Ug3xixyZeBOwlAVbYQhSWpuiERwkrnTUJvc0/EwPMulbcVrMrJ
         ByVAG0Fmk9MDgsbyaN+lWUQLDe7TH9NPm28f47U7f6kiTRryuI3Go2/iUHAV3uemWsLe
         ZhSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F5aR/6PSAAo/4gqYLlgL9w8L/omD4wgEh0XNiCKl+dI=;
        b=DR0/r2XA2f634SKT1CVrWSG9U27d6SoA/QyhM9yzvEmnVMmlYugFD65IJpzMbnUG0r
         GtV5zgpiG3mLDk06rodta2hpjsUSyS/qETIC+oq9oAEpMYNQcKGUy0u/ADuGE2P2WeIL
         C8jqNpnwuH+poVoaT4SwzvfregAHXbr1bIkU6N6DyPekWdfoPg9/7d/MQaw1qLiP06g0
         ZwTWjXyVD5nYPiv01Jy1lzlwWAJquqzXBDsa9aL0NJIUb5hqh0Wmk9Fnf3kUbk5kNhXx
         x/PXgejK/q1rqUM3cVDOBC6lWSKwI4ET6wk/yTSgRMNBnzFa7IeGY2pIe/+rQTGC+Xtz
         kr9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4q0hWeJv;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id u20si1277192qka.162.2019.05.19.22.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=4q0hWeJv;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id C619AA829;
	Mon, 20 May 2019 01:42:15 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=F5aR/6PSAAo/4gqYLlgL9w8L/omD4wgEh0XNiCKl+dI=; b=4q0hWeJv
	FFIFSzB6p1Y6Ld4qHXbTythAidiWhdLsKMnKSWiR5p01cWZpv4hFaNHhAkwteTso
	YBCvHKCyNhdOhs2m6HTXibD3ARgYfxV6x1grE5JpOEOtTAtRRWn4gkw1YPFIiBJ3
	scfIfzv1LsLBBxCWhjaIkoOEtBTqGcdTgxy+taAh5a9gAIWMiL84hsZ/l2RTKUBE
	bM/JxmtQ79/pYZrYpJ/hRSYqVPf4sG4307TJJzZmOD4rooSaBremXmbKUkJqkve8
	8vsWXXbVvc4fWaeKbUeGFaf+oyAb4nqgZ00zTN+NqAs5xZ8/PwgUyD2yUM0BDRJZ
	hPdz6VR3FKdrNA==
X-ME-Sender: <xms:Nz7iXHc_p63WmT8Hv_zVX9-hQNRqAcx6_BpQy9aRA_RV-X5qO6YHqQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepke
X-ME-Proxy: <xmx:Nz7iXJi5cJTwvcQKFovaZf1kcLHiAvg27tawIkhVPrqBYsbaKjUNLA>
    <xmx:Nz7iXCI40xy_rDeW2AnOPKNgeaaJH_OM--sDroQErKyjjUrnlJ6qGQ>
    <xmx:Nz7iXGEx-o6FUj8lJSRAbf5wyWgfKU7ltKWH8d9GzLXNUozb0RFWVg>
    <xmx:Nz7iXHKZk7UsymP2gqffS4_zS8fZlms0ZDjJ2oub_T4PqlAG_-z7PA>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9B96980061;
	Mon, 20 May 2019 01:42:08 -0400 (EDT)
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
Subject: [RFC PATCH v5 09/16] lib: Separate radix_tree_node and xa_node slab cache
Date: Mon, 20 May 2019 15:40:10 +1000
Message-Id: <20190520054017.32299-10-tobin@kernel.org>
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

Earlier, Slab Movable Objects (SMO) was implemented.  The XArray is now
able to take advantage of SMO in order to make xarray nodes
movable (when using the SLUB allocator).

Currently the radix tree uses the same slab cache as the XArray.  Only
XArray nodes are movable _not_ radix tree nodes.  We can give the radix
tree its own slab cache to overcome this.

In preparation for implementing XArray object migration (xa_node
objects) via Slab Movable Objects add a slab cache solely for XArray
nodes and make the XArray use this slab cache instead of the
radix_tree_node slab cache.

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/xarray.h |  3 +++
 init/main.c            |  2 ++
 lib/radix-tree.c       |  2 +-
 lib/xarray.c           | 48 ++++++++++++++++++++++++++++++++++--------
 4 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 0e01e6129145..773f91f8e1db 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -42,6 +42,9 @@
 
 #define BITS_PER_XA_VALUE	(BITS_PER_LONG - 1)
 
+/* Called from init/main.c */
+void xarray_slabcache_init(void);
+
 /**
  * xa_mk_value() - Create an XArray entry from an integer.
  * @v: Value to store in XArray.
diff --git a/init/main.c b/init/main.c
index 5a2c69b4d7b3..e89915ffbe26 100644
--- a/init/main.c
+++ b/init/main.c
@@ -106,6 +106,7 @@ static int kernel_init(void *);
 
 extern void init_IRQ(void);
 extern void radix_tree_init(void);
+extern void xarray_slabcache_init(void);
 
 /*
  * Debug helper: via this flag we know that we are in 'early bootup code'
@@ -621,6 +622,7 @@ asmlinkage __visible void __init start_kernel(void)
 		 "Interrupts were enabled *very* early, fixing it\n"))
 		local_irq_disable();
 	radix_tree_init();
+	xarray_slabcache_init();
 
 	/*
 	 * Set up housekeeping before setting up workqueues to allow the unbound
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 14d51548bea6..edbfb530ba73 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -44,7 +44,7 @@
 /*
  * Radix tree node cache.
  */
-struct kmem_cache *radix_tree_node_cachep;
+static struct kmem_cache *radix_tree_node_cachep;
 
 /*
  * The radix tree is variable-height, so an insert operation not only has
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..a528a5277c9d 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -27,6 +27,8 @@
  * @entry refers to something stored in a slot in the xarray
  */
 
+static struct kmem_cache *xa_node_cachep;
+
 static inline unsigned int xa_lock_type(const struct xarray *xa)
 {
 	return (__force unsigned int)xa->xa_flags & 3;
@@ -244,9 +246,21 @@ void *xas_load(struct xa_state *xas)
 }
 EXPORT_SYMBOL_GPL(xas_load);
 
-/* Move the radix tree node cache here */
-extern struct kmem_cache *radix_tree_node_cachep;
-extern void radix_tree_node_rcu_free(struct rcu_head *head);
+void xa_node_rcu_free(struct rcu_head *head)
+{
+	struct xa_node *node = container_of(head, struct xa_node, rcu_head);
+
+	/*
+	 * Must only free zeroed nodes into the slab.  We can be left with
+	 * non-NULL entries by radix_tree_free_nodes, so clear the entries
+	 * and tags here.
+	 */
+	memset(node->slots, 0, sizeof(node->slots));
+	memset(node->tags, 0, sizeof(node->tags));
+	INIT_LIST_HEAD(&node->private_list);
+
+	kmem_cache_free(xa_node_cachep, node);
+}
 
 #define XA_RCU_FREE	((struct xarray *)1)
 
@@ -254,7 +268,7 @@ static void xa_node_free(struct xa_node *node)
 {
 	XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
 	node->array = XA_RCU_FREE;
-	call_rcu(&node->rcu_head, radix_tree_node_rcu_free);
+	call_rcu(&node->rcu_head, xa_node_rcu_free);
 }
 
 /*
@@ -270,7 +284,7 @@ static void xas_destroy(struct xa_state *xas)
 	if (!node)
 		return;
 	XA_NODE_BUG_ON(node, !list_empty(&node->private_list));
-	kmem_cache_free(radix_tree_node_cachep, node);
+	kmem_cache_free(xa_node_cachep, node);
 	xas->xa_alloc = NULL;
 }
 
@@ -298,7 +312,7 @@ bool xas_nomem(struct xa_state *xas, gfp_t gfp)
 		xas_destroy(xas);
 		return false;
 	}
-	xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+	xas->xa_alloc = kmem_cache_alloc(xa_node_cachep, gfp);
 	if (!xas->xa_alloc)
 		return false;
 	XA_NODE_BUG_ON(xas->xa_alloc, !list_empty(&xas->xa_alloc->private_list));
@@ -327,10 +341,10 @@ static bool __xas_nomem(struct xa_state *xas, gfp_t gfp)
 	}
 	if (gfpflags_allow_blocking(gfp)) {
 		xas_unlock_type(xas, lock_type);
-		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+		xas->xa_alloc = kmem_cache_alloc(xa_node_cachep, gfp);
 		xas_lock_type(xas, lock_type);
 	} else {
-		xas->xa_alloc = kmem_cache_alloc(radix_tree_node_cachep, gfp);
+		xas->xa_alloc = kmem_cache_alloc(xa_node_cachep, gfp);
 	}
 	if (!xas->xa_alloc)
 		return false;
@@ -358,7 +372,7 @@ static void *xas_alloc(struct xa_state *xas, unsigned int shift)
 	if (node) {
 		xas->xa_alloc = NULL;
 	} else {
-		node = kmem_cache_alloc(radix_tree_node_cachep,
+		node = kmem_cache_alloc(xa_node_cachep,
 					GFP_NOWAIT | __GFP_NOWARN);
 		if (!node) {
 			xas_set_err(xas, -ENOMEM);
@@ -1971,6 +1985,22 @@ void xa_destroy(struct xarray *xa)
 }
 EXPORT_SYMBOL(xa_destroy);
 
+static void xa_node_ctor(void *arg)
+{
+	struct xa_node *node = arg;
+
+	memset(node, 0, sizeof(*node));
+	INIT_LIST_HEAD(&node->private_list);
+}
+
+void __init xarray_slabcache_init(void)
+{
+	xa_node_cachep = kmem_cache_create("xarray_node",
+					   sizeof(struct xa_node), 0,
+					   SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
+					   xa_node_ctor);
+}
+
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.21.0

