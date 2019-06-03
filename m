Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42A5EC28CC7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F205527249
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:28:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="3d+ZatUl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F205527249
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EB526B0274; Mon,  3 Jun 2019 00:28:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C1AD6B0276; Mon,  3 Jun 2019 00:28:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78BCA6B0275; Mon,  3 Jun 2019 00:28:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3546B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:28:49 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id r58so6515748qtb.5
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:28:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rxVuyzm1WS3UxHiswMwmyEkW+N4rdmsFgqzw5exGUx0=;
        b=HS8qT8xPOLygp5emzcVhDJz0DP9oIiF2vy2NARWDSEtkUogH/DEZpsGtIjHG4QVh8S
         ioyBUSiXig7XRuNaqK2q8SjzseUweaFzqvObUi1cTJELHnjJuL4lNBOKtTgBXf6HaGyo
         BZtrScjWlcBw26f7mqCQFB8twuNJ59QPnwvsu3DmMP6V8PTwbdDJqliycb1XWdEfzz2H
         9o7W0FJu/1UiSHo6bQNxRfLzE5rcMl6TSpWkoDsjoRz4B2kkjCQGIxayH+NOh2yC2wZ5
         Z2UoBDqL70iDigkfIvLAWUzkuZ5kjXJQaGfy+VXgRuuIxTi5a/H8QLCQ+WeQrTcU1XbO
         7ouw==
X-Gm-Message-State: APjAAAUH5wJDHrzvKRUNKJ8qF/L5EmYNp+cIGHunn3I+UJjtNsimNP9G
	IFMIvEpTY5eEEtEtDmtJ9GLo0cjdEc2MT5kuqw7V/jiXm1xorel+PHBSVnJSRaWXXFTPrgdtFOT
	8dWXgFGS3xGbOftMPuSa8wQJliQXx8WbRl5O1gUxMkJgl04LOfBaLcRcyqRUgpMY=
X-Received: by 2002:a05:620a:247:: with SMTP id q7mr17246262qkn.265.1559536129140;
        Sun, 02 Jun 2019 21:28:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0nKM8777HlEjLT3735Zs7ScZrEVv1c9o4tS+z0IdcfCTmG5F67A5lzN+tcLqEI4i+GX+2
X-Received: by 2002:a05:620a:247:: with SMTP id q7mr17246221qkn.265.1559536128130;
        Sun, 02 Jun 2019 21:28:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536128; cv=none;
        d=google.com; s=arc-20160816;
        b=prOU82fCeaeuSycXMcjivCx6+wGWErs0PwfL5XmG7Y+7W3mquW50z+jK+coGm2fwmK
         ehQsF8JwcoMw0H2lgVjhkoJN5L5bp5x6KgVvVzul82v1YwbxVw8AO4gZ4jufU6G6S8jW
         YwwtF3elsFtHlN3qxH1WhlfaHXoXLPdx7b/lTFfXp/lkJN7lPWa5t6CDbqy5aWVfVQIP
         DDx9ZmZ1VzynFRrpQ+dwIaW0wQ2Y+rFP9Lzw9wS/6J43cT9tZLX6GhVTI7FmujZx1ZBA
         nuBp3MYlm+2Neqji7Lfjm2y/xUmcDPYq1JbVWbKO8F0KrV63sTgAV5Gf2pF1brKJd4HX
         o69Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rxVuyzm1WS3UxHiswMwmyEkW+N4rdmsFgqzw5exGUx0=;
        b=Khhk9IBIAeBD6I00pMy2u/7pKqtFlHZRlVRr9mi0NkH5/JPsTDzDqYGBof6hTUr+s0
         corE1pRETqKer2wuDwzdAVNjhE7BjnMUwKJyyoEi+am2ZR5ijy3SSEhkgOglNzGCghh4
         84yZ4NcGdWRVwH1k3dHFnw2h74TqL27FxPMo9afoR7T4cjG8Yuvkpp6tHsjOddKPUq3K
         yaOxcIXFkom3O9GGbGTzREK9h1fUyJBU1VVIjNESvdKsfl/BQJSYK7wqN10X8xKwlQFw
         Rzic3JDIzVI5XrXN7IkMjjynXfIFiMFnxa2haN0/OBtI48VjVT+SdcpONGBERVH9OtPT
         whcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=3d+ZatUl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id z193si8540868qka.236.2019.06.02.21.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:28:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=3d+ZatUl;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 826751320;
	Mon,  3 Jun 2019 00:28:47 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:28:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=rxVuyzm1WS3UxHiswMwmyEkW+N4rdmsFgqzw5exGUx0=; b=3d+ZatUl
	A1wPrysCoCMns7irCJnO7Xzs7tZnZQVOKKKVaWHjLzAFoXe4z13qk76ntzD8JLfU
	4HaxCNIuJL/exRpJajmfocUXwv4Ch6gFZ4YYN09t0niw059zAsAjvYo522x8vOov
	8L9UEKPmAyncQ0HRHJyMyevUkW+tmjAj1SZXGxDL2hHU/7DRwv7nvFU5FVNe4xNv
	/uneC2szDjRVXRGohIKjBhyC3shW1yigoMlax+huURJH4w+iuGc2SXRa0N6c6PkO
	RsV4+o1I9wI13p7aJyXEBTIcn0oPteBIq+ELuOTKKcOimm1Bu1VI1dQi3E9mnaU5
	LqbFoNczAeDp/A==
X-ME-Sender: <xms:_6H0XG3MQauOjhRYnA2Qe8C2DuD0XU_YZmqCVKbls8tV5ARuj6XJgA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:_6H0XDHnyRjJLe3A6QUOQj0F7hHtGtgHam6uYJBbGsXXTn1ipzT2ew>
    <xmx:_6H0XI90qzVyyfcJc_i-Ej-xnEBO2szNnB6ldCDZav5CEOy78Dkb4w>
    <xmx:_6H0XJnwznT-s6I0tP2LMLgCENFpQgk1MaDKkmPIX9H40RA7QpYv1Q>
    <xmx:_6H0XB63MuU8MKLiUkKQp0w-WF2SKTfMOgcCtxhg_FVXf8Fkn6b36Q>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id EC9598005C;
	Mon,  3 Jun 2019 00:28:39 -0400 (EDT)
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
Subject: [PATCH 10/15] xarray: Implement migration function for xa_node objects
Date: Mon,  3 Jun 2019 14:26:32 +1000
Message-Id: <20190603042637.2018-11-tobin@kernel.org>
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

Recently Slab Movable Objects (SMO) was implemented for the SLUB
allocator.  The XArray can take advantage of this and make the xa_node
slab cache objects movable.

Implement functions to migrate objects and activate SMO when we
initialise the XArray slab cache.

This is based on initial code by Matthew Wilcox and was modified to work
with slab object migration.

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/xarray.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/lib/xarray.c b/lib/xarray.c
index 861c042daa1d..9354e0f01f26 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1993,12 +1993,73 @@ static void xa_node_ctor(void *arg)
 	INIT_LIST_HEAD(&node->private_list);
 }
 
+static void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_RCU_FREE)
+		return;
+
+	new_node = kmem_cache_alloc_node(xa_node_cachep, GFP_KERNEL, numa_node);
+	if (!new_node) {
+		pr_err("%s: slab cache allocation failed\n", __func__);
+		return;
+	}
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	if (list_empty(&node->private_list))
+		INIT_LIST_HEAD(&new_node->private_list);
+	else
+		list_replace(&node->private_list, &new_node->private_list);
+
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *x = xa_entry_locked(xa, new_node, i);
+
+		if (xa_is_node(x))
+			rcu_assign_pointer(xa_to_node(x)->parent, new_node);
+	}
+	if (!new_node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(node);
+	rcu_barrier();
+}
+
+static void xa_migrate(struct kmem_cache *s, void **objects, int nr,
+		       int node, void *_unused)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
 void __init xarray_slabcache_init(void)
 {
 	xa_node_cachep = kmem_cache_create("xarray_node",
 					   sizeof(struct xa_node), 0,
 					   SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 					   xa_node_ctor);
+
+	kmem_cache_setup_mobility(xa_node_cachep, NULL, xa_migrate);
 }
 
 #ifdef XA_DEBUG
-- 
2.21.0

