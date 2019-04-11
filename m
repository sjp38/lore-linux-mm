Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55758C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 018D22075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:36:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qzRvdUhs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 018D22075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8BE56B0006; Wed, 10 Apr 2019 21:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3C776B026B; Wed, 10 Apr 2019 21:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904236B026C; Wed, 10 Apr 2019 21:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 719376B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:36:55 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g17so4060463qte.17
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:36:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=;
        b=XMpBhvRtiTiFXt4WKJ/IuKxHicc7HQqaqrE0K3a7Bv4MqOwMX0KC+W5QbwJZP0TSjm
         GCxvgua9dLONcAoRLYX43iolxrvLE25wEw/WfADK6JrUKrjhg4PC8ShJAsE2BvEfTm1W
         YZ4/y0dgm7utvxTVS5SriZV5mcHbRE0mOPc5VN1t2fHGDvZkBhslrIAJNIAGKtqZCmIj
         MNv442gr2ch2naicwnVnV0eWGget6yp9awT5oAN9FVjCoogExQlzgbgG2ZUHwxZZ4/EU
         bxoLsRAVBFAAVIu5V+lp0KcP9SiuZJI3JjP2/aqUnG5GmwlNOvkGbt2He+sarXrU89z5
         tJFQ==
X-Gm-Message-State: APjAAAUkt6IYf8pemM8HDQijITqbemR7OUwlUUsifwtYObyin515Tt3I
	M2jeOa9TpfCLhU0HRNNpd5eqr5/89dWGIcLJ8VYkAMbbWCdYp9im8SqZ5/pfJPukCxxNmC+YgBB
	0SIsFD1ycJUu9gryIghWiV7dMATdb02vFDVyocDguHD+mNB1VfWipf++sgLC646Y=
X-Received: by 2002:a37:9103:: with SMTP id t3mr36138404qkd.78.1554946615241;
        Wed, 10 Apr 2019 18:36:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLTtJO9Z2m0mr5tZbgqGNwjCpUjxh90Fny2XfJwx+xUb24zjYoX7U7a+x9IwkX5d5dlx2H
X-Received: by 2002:a37:9103:: with SMTP id t3mr36138355qkd.78.1554946614189;
        Wed, 10 Apr 2019 18:36:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946614; cv=none;
        d=google.com; s=arc-20160816;
        b=FAj1+BObnX7Fww0OfW6W8j4K3wgieU6x0rxLcO2m28QnrUxmEtN1Ftw6+muzoC1W+z
         6dwC08EacPC1rgxFET8WCaN5jRyhnbSh6loReHymbGuzULeA7fVkfaB+3/UIbo2e0/l7
         cQa05UL43cH5I+SfwRwxgqdFgeZhDFUL7VV1Vq2Ds4Jb6tHTYStldEh6wyAHdlFDcy2R
         1242iCEArXJ62Q8PSVENJZu8vo0tSXhQqfJWQseGyJPVIxgLNzSmGGN28zuWNsRYMlQL
         FtaeDByz0u4xG5meAbWRaC8gWgm9qwu/CS/tGWnxdTXzYwMT+05m7E7pnixdm+g+3vDx
         ou3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=;
        b=Ry85pWy1Kz2uuL/wB1dmUV2vW5y4OVg4qbJ53hZXIOVCzuCLF9CiRaNN1kJrbFG+sk
         fgS+r7FZ0VcYR8uVvkMeYKLa+qncot6CX/VBOFVlm53kGzR5NXJbUsNrmquOqxDDJDyK
         B7MCWblaaix4sn+dZr8zLHXI07i7FnvwnFoDxrjC4+vj7YMSAVy3jqqgm7feR2M6QmPh
         Bzp+V9BXFtbJ7azsbw/YHozwoaBFUk52mVmQsNI9P/VkMhdwpnF2RG56AhfCewFpseN+
         RYNio+LTEOyiL16cDRTy7HnzvaauaciJRRkX7M/8kvPVH6t/KhIagFXjl2/pkY43CZ4r
         4Chg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qzRvdUhs;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id r48si940576qta.100.2019.04.10.18.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:36:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=qzRvdUhs;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id E174B95AA;
	Wed, 10 Apr 2019 21:36:53 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:36:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=+np6ZQiGNtF1RzthBJCokkLQhVYLo5zEKFMlgFr5PgA=; b=qzRvdUhs
	UVD4kyF8HJ7vBxCzVS8IYhTP/yBOeoOJ8PIdPnqARP3eX3pn8F6bHlUMx4NW+bqS
	TqwY+D0W0EHYASNuJXP+gP0jMjXji0hadDm8uDWa0tHVduPZo9PkDV2urFfnpBL8
	V7T/5LcjbLCAgmpVvqlPD0rWxm8XqKY60exQ9yNtdL0WBZSj9jASXsvRdjQVjLei
	FMSrJfYK9pAIq+Lzk39T5xR8zFen5FVAEju0lGvafW4YFbO2D3nVD5GfRwM2j6wP
	VFa7jwTh1JmRZo22bmbrHGANnZOkZ2LO5RVRNArjecXWW0LAkKQP3A9DkiQ6Kat0
	I6b7rT7YLxEvkw==
X-ME-Sender: <xms:NZquXJ6FqX33i7PtYAMBUodN0doBj59LYc8vaXoKQPMkhfSfFEPYHg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:NZquXEa7z3rdg0o8vLUCgRyen1outPCswxvBHkxKNxi7m-Fd3ppygA>
    <xmx:NZquXDGUAePeD-JWcaDMLAM9IuFEg7K7o1jSrEzlq80-8f_nzdzFDw>
    <xmx:NZquXHlsc_WOf9xte6pLrBd6-6P4jZxbN8N3Nm4lF10yIEV1UGpXcg>
    <xmx:NZquXO81NJpPSsKVIKunIoikdl7o-w391DaR7WTvCzi6a7KdZHe-OA>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 18549E408B;
	Wed, 10 Apr 2019 21:36:45 -0400 (EDT)
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
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Andreas Dilger <adilger@dilger.ca>,
	Waiman Long <longman@redhat.com>,
	Tycho Andersen <tycho@tycho.ws>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Andi Kleen <ak@linux.intel.com>,
	David Chinner <david@fromorbit.com>,
	Nick Piggin <npiggin@gmail.com>,
	Rik van Riel <riel@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v3 09/15] xarray: Implement migration function for objects
Date: Thu, 11 Apr 2019 11:34:35 +1000
Message-Id: <20190411013441.5415-10-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190411013441.5415-1-tobin@kernel.org>
References: <20190411013441.5415-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Implement functions to migrate objects. This is based on initial code by
Matthew Wilcox and was modified to work with slab object migration.

This patch can not be merged until all radix tree & IDR users are
converted to the XArray because xa_nodes and radix tree nodes share the
same slab cache (thanks Matthew).

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/radix-tree.c | 13 +++++++++++++
 lib/xarray.c     | 49 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

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
index 6be3acbb861f..731dd3d8ddb8 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1971,6 +1971,55 @@ void xa_destroy(struct xarray *xa)
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
+	if (!xa || xa == XA_RCU_FREE)
+		return;
+
+	new_node = kmem_cache_alloc_node(radix_tree_node_cachep,
+					 GFP_KERNEL, numa_node);
+	if (!new_node)
+		return;
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
 #ifdef XA_DEBUG
 void xa_dump_node(const struct xa_node *node)
 {
-- 
2.21.0

