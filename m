Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F82AC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E920D20855
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wnPbtlN6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E920D20855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C68C8E000F; Thu,  7 Mar 2019 23:15:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49D588E0002; Thu,  7 Mar 2019 23:15:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3663B8E000F; Thu,  7 Mar 2019 23:15:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 066C08E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:45 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id i66so14969163qke.21
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3ICf1F4yYMSB9kWf6DNRwgEAL3fOm46vEzPIjpQE3AA=;
        b=gNM2kvVD7gJTjYHlu5H7/Ae2xTbRgc4VXFH+GedR/FxWJS6+bxQHPAaQIst5Q20isI
         Tjvqt3WM/l7H6jW3QvzsRqhR8TqqcbN3kXloPQD65h5RXWaSAjGufuNpgSdji2jUtNEE
         ji/Ap/X/My9lhNrLSUrsOz4Jk19XYTqxTUf54WvuYNV2iS9e/I/Jj4UgR1HvoQ0gMWjF
         U9oSgzHvE5eLKcWY9PPcJBbt9XR0dY8ynxGYvzZqTRVgu1Q6QW/5M3z/6MujJLHIHDj0
         jZEOVXinEPGxxzQDWP0OXbPWjLKuBKxr635bibYoAg+KZJbrBgFtnO2SUxwj8RwIsvhj
         41hg==
X-Gm-Message-State: APjAAAUQZTQCBGOBfGr2hGN7a4qIxzEeMcHSI/sY0HdSjsGriTw5Mq25
	nwxwU9LjzcbmhZcOKLtqnNmpD6bcF28g7Y/Fy90ddZzehIO4l/kbmB3D5u+wlQBfUsscVSmFZ32
	+azf6Rop/KMOA+9Q0JXX9j0yUNqyZZKXx/pqS6tUxv4bEnnA+ezN+Md+K1IZOORE=
X-Received: by 2002:ae9:e913:: with SMTP id x19mr12699037qkf.45.1552018544788;
        Thu, 07 Mar 2019 20:15:44 -0800 (PST)
X-Google-Smtp-Source: APXvYqxaAa676OUvZnP8ColV8X+YpWynk+qJd60PP9EPSwz41bpr5hcTsV3RZh09x5VilYh7+/x6
X-Received: by 2002:ae9:e913:: with SMTP id x19mr12699001qkf.45.1552018543689;
        Thu, 07 Mar 2019 20:15:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018543; cv=none;
        d=google.com; s=arc-20160816;
        b=go0sI4rr8+DIiCNijk72FvB9dXIefZAVs2qHqfnt+2tSDue+0m+yuSbnByEjySEXF2
         uNYCD7uuWPo3/KQng+RmhSgcfIParwWtBJT7o8RYPPxo/+Ir3DcxeE8gAjESM0ECHh/w
         E/7cxJCqXbcRvLmNCDZT9Pjt3HKbJvSz6zbshsWuab7nvT6+jNz8l+r+z5gX1+aTwfy4
         rLfrZzUrXIIer9qiuJkhzwXVMXwmA4muuwX/rO7cmKOYvd3M7UZOY23/HWnvqjgageCE
         yBGMN+vILgamSrR1vWnwGZzrWmK8FAHWydR5c4+hEMgMM+RV44pnvItMZSrJEyEQsoi5
         sH6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3ICf1F4yYMSB9kWf6DNRwgEAL3fOm46vEzPIjpQE3AA=;
        b=EKndcbjKvg5dkBrap41HoTr75/4VSBu3pXVyrMtnYz7HOucLYWiJrH80STxi+6vm3p
         mCwbkvVnDoYNjeLLOyjhUqlxb4pXhGxjP7iR7h6ddAKya+LnuBT11sBKY8iD7nExRz0o
         905V6A/NGa7l/UZ7WunX5u+j2fLvDX7OjfH0AmWyEkLEHkoAa86CGv0jTaOiW7Oy+HvB
         H0S8MUe3kKV6XHt+qrvwJ1LMlKSsXf/mO0PhosxQjzLpik/Z3JVxYeLmZ/Gxytn7GKjE
         RIOjVsq4Lfg4l7VSOiTy+JWxR3QASAzMDmdi5Z+ufRckAyvK4ezM1yJX/ezmdEfZlGNt
         aFDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wnPbtlN6;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id p6si79931qkk.40.2019.03.07.20.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:43 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=wnPbtlN6;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 3F395173F;
	Thu,  7 Mar 2019 23:15:42 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=3ICf1F4yYMSB9kWf6DNRwgEAL3fOm46vEzPIjpQE3AA=; b=wnPbtlN6
	RC57mehAdbkgLwnR/WvJ/TT8udSoYHVbvFCmZkCjkSaSMoUAm5LlwMU312bg57+H
	6xwUIAkxleRGO/DO1Mo2+EvPzombVF6OqLWYKPFTldgVN9nDbPCpJQGa1MDwpLhB
	DFyag4Efz62jiOXOvKDvJIfFE5Z2yGLheTL5xI8RPuZu8/X0Eb2m616FqlsJPjR1
	dEtwyMJrztDmNqW4SbHfw665vzC4m7Vb3PAFpX+MOUXgQoPEMHhtaOupOqYaqtqP
	q9BdKJ08/wTkvvix56kpnZDHp8l9wijvkwFdnG+kSzHMuZqGz1byU5qfGsrzT+gy
	p4CKCE9JbR+oag==
X-ME-Sender: <xms:beyBXLwlRjE2GRY2ugZ0DNCpLsX9QiqrWy6N9yQqLiXNXnltQRvXFg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddu
X-ME-Proxy: <xmx:beyBXK5U70WJnwW9yY16_1Yv2ye0Ywm-9qGurpVlFDuVk_hbABlbrw>
    <xmx:beyBXC9dzE_ysDh2v5l8At9TcypYH-TDGnQkF-jPbxKwDIqr0zjlxw>
    <xmx:beyBXPqknNJ6ASlOl1Ua-OSCcPgRqIqlGySq0FWtl26xl0XsPu7OFQ>
    <xmx:beyBXCiUHCLaAHIvdvyNiKyVjt0MQFB9HTOqo32BDSVYgrStxDz70w>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id EB429E4362;
	Thu,  7 Mar 2019 23:15:38 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 12/15] xarray: Implement migration function for objects
Date: Fri,  8 Mar 2019 15:14:23 +1100
Message-Id: <20190308041426.16654-13-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190308041426.16654-1-tobin@kernel.org>
References: <20190308041426.16654-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implement functions to migrate objects. This is based on
initial code by Matthew Wilcox and was modified to work with
slab object migration.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/radix-tree.c | 13 +++++++++++++
 lib/xarray.c     | 44 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 57 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 14d51548bea6..9412c2853726 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1613,6 +1613,17 @@ static int radix_tree_cpu_dead(unsigned int cpu)
 	return 0;
 }
 
+extern void xa_object_migrate(void *tree_node, int numa_node);
+
+static void radix_tree_migrate(struct kmem_cache *s, void **objects, int nr,
+			       int node, void *private)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
 void __init radix_tree_init(void)
 {
 	int ret;
@@ -1627,4 +1638,6 @@ void __init radix_tree_init(void)
 	ret = cpuhp_setup_state_nocalls(CPUHP_RADIX_DEAD, "lib/radix:dead",
 					NULL, radix_tree_cpu_dead);
 	WARN_ON(ret < 0);
+	kmem_cache_setup_mobility(radix_tree_node_cachep, NULL,
+				  radix_tree_migrate);
 }
diff --git a/lib/xarray.c b/lib/xarray.c
index 81c3171ddde9..4f6f17c87769 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1950,6 +1950,50 @@ void xa_destroy(struct xarray *xa)
 }
 EXPORT_SYMBOL(xa_destroy);
 
+void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_FREE_MARK)
+		return;
+
+	new_node = kmem_cache_alloc_node(radix_tree_node_cachep,
+					 GFP_KERNEL, numa_node);
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array || !list_empty(&node->private_list)) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	/* Move pointers to new node */
+	INIT_LIST_HEAD(&new_node->private_list);
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
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.21.0

