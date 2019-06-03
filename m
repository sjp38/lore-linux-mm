Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1397C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D04B27249
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="zBRQziWx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D04B27249
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E43986B026B; Mon,  3 Jun 2019 00:28:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E197C6B0273; Mon,  3 Jun 2019 00:28:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0B716B0274; Mon,  3 Jun 2019 00:28:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF1E26B026B
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:28:41 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 97so6490247qtb.16
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:28:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nu/o7ND31/Jz1+fQrVDSXNqvU8Wx++J3ZYdTw/+7V9o=;
        b=GXV1RuRkGo1VXKVmU4K2OStf3A8+Tm+AyOLdbh3E6rd2lkmaA5R0DjfLpklrhGACKN
         ZuxoGfaBgQTRpixHy9GbbP6zrxltTmPBitNTsUNW5+fIxix3ylMrylKmvurviI8obmfF
         Ot6LoLwATOVKTLRyThvPSCbbqHt85E5PEwDEPqNsoFqh2ZCGRGifH4W5ckkVqDud1FKY
         0zUPwybo6YUH8EaJJqj3QHpcke9Pufp/cNSEsRRKv3zXKNJLJ9jQnaYlNVGbmPcz2bDw
         tJGNxLywfuT4mT3uXpkAGwR+zFUHFSbY63BWjTBQ8/LbbIdZR5lOvPYKh9ab5tESMdJO
         4r3g==
X-Gm-Message-State: APjAAAXK70SW+AZFeR4fYlOci9YuB35FPEHhVBT7ivwYMbReF8Rkt1ml
	hQYfQk/SUogaVCLXtZggePYCfY50IElAghBbZ2kbEwd6Bau9J7EsJYRJWaxLdAy8GHfMiuAC7FN
	SXzc1/KgDt9zJ/TwX2GUtro0m22TF6A5Kaukhc1/U+A3JLpCsyKlquiIAuOCd5pE=
X-Received: by 2002:aed:24d9:: with SMTP id u25mr21507343qtc.111.1559536121465;
        Sun, 02 Jun 2019 21:28:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7jWVpzp0tF3a6eS5YNbnJVOMZYfN5mLMQaBjP46ILTMjnu1+DeLCFuZwXM0eNu69U5c93
X-Received: by 2002:aed:24d9:: with SMTP id u25mr21507297qtc.111.1559536120148;
        Sun, 02 Jun 2019 21:28:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536120; cv=none;
        d=google.com; s=arc-20160816;
        b=FYJ2qrkoJ5c8+xQPumwU14816Ur7W3916ZrlRaWGV1gkgvjejvbrMXiAY6I59OhdIp
         C1wS2Nsw7Rg7S8pWnZ4NTcUd17KofqCyn+0vGF6wnNzgvmXUX7ISpVTWbqu0ZoY+2EHx
         MPd68iWUpMxcN4ki1cTl6zSYCfVwa8XSNkDMQuVv/JnuIZGI+OLRdg6kU33ssRQdNBGw
         8qEYKGC0Qsxh2t2hTRss2nnoNwtTy03EUwvqlYwhxYKYeMz1DWbld7uLKL94hLIFFGna
         ABFFqvXReSaH8HU1trgaa5Hr31IA5lEHe2IjT7weYHhQc88Kv0AyFYg+99Zv1AJx2kl2
         VARA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nu/o7ND31/Jz1+fQrVDSXNqvU8Wx++J3ZYdTw/+7V9o=;
        b=MuxfwLjDZtVL8SMwUdOHsCmWnBlFfxhPvq11iG/ONTXojPtufRhYNg5dKj5QFYYOA3
         v/0NrkkWaWVbCZrnKlrWraBAPlNabm3zgox9lz2UkXf9TiAJiJEi/yDKqkGosmz1xZmq
         UxJGVoSTdgRtf1d2OY5NrZSXmULho8wntW3HlZrPt7QW+EoJqpNCLn+srS5bJg4pzOqj
         cSayJ/txh/RZBL/LIlU1szPdZty5YHdyiJbJwrSqhMhucZc86PFGBsd9wM14s8n2/Jh7
         LLiix/wGdfPb93HP1RzYOyg5Q+BY4dStVzu5vCZgDxepZ4V39lpSORRfN3YQjZEu9END
         N60w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=zBRQziWx;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id p57si5058329qtc.217.2019.06.02.21.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:28:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=zBRQziWx;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id E2EE61283;
	Mon,  3 Jun 2019 00:28:39 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:28:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=nu/o7ND31/Jz1+fQrVDSXNqvU8Wx++J3ZYdTw/+7V9o=; b=zBRQziWx
	nrqfLlLsLvXdwhD7MQ4bSso9ajZt8TG1PQfeRTZ8f/5YkjvRkNw1u8SgbCmrP2x1
	6W5DFPIFmI1Pu5rPZns4vcBrQgsFzku9TKaSyY6Ov5M5+3n6IRnZCetxzrSMG5z2
	EF2RrLCnxsG5WjducoH6igzGN9m4sdSFHNtdlq8TLILts+usAC0RSBpN29uuq2Fq
	mpG9998/sFqKmTAoqY3U0i0BsKvP6vtHOnO8nqt90CU5l4ENZBIgXPDo2NvgO9eo
	jey7ALOf/Vx+RnqDl2AbHIML1JpeeLMoKGqXccVoz8JrH+ADYKOvebDoxUrW9UvL
	xCXOrFixi9lxCQ==
X-ME-Sender: <xms:96H0XFQSkU3ijE7bN3kNUD4HUFOfDbLXVNzArpuEs0kM4yAUB-pMPw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:96H0XCeHHRI_43vs_eGp5Xmq2TDceTVOPH5oF2JwmtM2cmRUiWgRwA>
    <xmx:96H0XErwtvC5--t7aQWuebMPewEO_5yrQ8bbpM_Q8tE5QsoLPVMnlw>
    <xmx:96H0XD877G2K3ij3c5IyX326zE-yGfmK0qy8oS-lhyIsfDpjnm5ZEw>
    <xmx:96H0XE6vIGTrKvWbsE6IELB_srkWfZdWBWS036FPS7vZETSuwdd4Lg>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id B5F6D80062;
	Mon,  3 Jun 2019 00:28:32 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
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
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/15] lib: Separate radix_tree_node and xa_node slab cache
Date: Mon,  3 Jun 2019 14:26:31 +1000
Message-Id: <20190603042637.2018-10-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603042637.2018-1-tobin@kernel.org>
References: <20190603042637.2018-1-tobin@kernel.org>
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
index 66a196c5e4c3..8c409a5dc937 100644
--- a/init/main.c
+++ b/init/main.c
@@ -107,6 +107,7 @@ static int kernel_init(void *);
 
 extern void init_IRQ(void);
 extern void radix_tree_init(void);
+extern void xarray_slabcache_init(void);
 
 /*
  * Debug helper: via this flag we know that we are in 'early bootup code'
@@ -622,6 +623,7 @@ asmlinkage __visible void __init start_kernel(void)
 		 "Interrupts were enabled *very* early, fixing it\n"))
 		local_irq_disable();
 	radix_tree_init();
+	xarray_slabcache_init();
 
 	/*
 	 * Set up housekeeping before setting up workqueues to allow the unbound
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 18c1dfbb1765..e6127c4c84b5 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -31,7 +31,7 @@
 /*
  * Radix tree node cache.
  */
-struct kmem_cache *radix_tree_node_cachep;
+static struct kmem_cache *radix_tree_node_cachep;
 
 /*
  * The radix tree is variable-height, so an insert operation not only has
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..861c042daa1d 100644
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
+static void xa_node_rcu_free(struct rcu_head *head)
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

