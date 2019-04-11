Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7122C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58D81217D9
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:37:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="T2Dnazcb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58D81217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 079C66B000A; Wed, 10 Apr 2019 21:37:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 029DE6B026E; Wed, 10 Apr 2019 21:37:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0CB66B026F; Wed, 10 Apr 2019 21:37:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BD7BC6B000A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:37:19 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c28so3004956qtd.2
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:37:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=I7l3yM/h8U4u/fWuyfCEATUALz7WJApwxEjpIpATWg+1hDg7NqUB1OZiAzBf3lM5+S
         bYA55PaVvb2KhNLFZP1knbQuOYAUuJvLkGQFBDTbiB58d/Yg3q+ROU3DxCLoK4axmmoV
         ZrAYBu2z6uMwBuxl/PqtevfnmztpI7oZL5e6fEpkWR0kTh1dEOdeoN+VH3+iQoSEnTTN
         dm7YcLVXqCvGsINkUVgUFJNbvwn+3xBchUccL0yV/wu9CrMqDmF4etBESfArFLlSeJ+W
         gofNBAp7BtL85tZCMMAGDsAbPXORlO7Lzc6MtjG2M2Cu5DudQCDijdFRpY4nvab7k/ZS
         wq0g==
X-Gm-Message-State: APjAAAUKP+oujc9tZ+0gFpIYdmWqexaWdcRTeL8Hor6zqgkiTcu/Te5I
	g+f+k3wgsFOtqkhaS3Ue5A8GL2WcOveGEkn60RgTFO6NTUpDDzMItNaRdIifeELhrjjFQx7DcyK
	KhD6hEVoUUd5D2Z4AZKHBq5GHQmWt7e3P+fOS0WGZJa/rHN1W/3BD6Dz4smN4Dw4=
X-Received: by 2002:aed:3762:: with SMTP id i89mr39194387qtb.311.1554946639522;
        Wed, 10 Apr 2019 18:37:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwt8ffjNyomNbBtf9o4XhgzdqV99ipRu7oVrTOmxvYxPGZIvCEzkxpgCRk4rFBJ3b6AhDNz
X-Received: by 2002:aed:3762:: with SMTP id i89mr39194351qtb.311.1554946638682;
        Wed, 10 Apr 2019 18:37:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946638; cv=none;
        d=google.com; s=arc-20160816;
        b=pNnb8ZH2bpEpfT7Km1cBe7BbrFTiEw5WlAuP2/+8VQSV0XwFAf5SnADdv0wZk+qQ+J
         qMHhEwV3tGu0k96xqEnhl7DVmJ+wkvZbhWeZU7k0VPTPVLrnYyLSLjI8WLGCwZxFORvR
         MQ5XvZZtLJW7mmizsewga65u2SpYSOf/p/nLc3G4pSc3idpePfC23xrKNnEvLnFyzCsO
         lJLEd5Cm9roMVrn7QyB1NHkNvy/bRb0NYVNllqwOdFVUkIa65OvPQwken7RSAZQDEIcd
         FYam+lYOHFChyCShNOyEKCUrrO7RwVUY8DzskbDVNCqtWrkG7XSx4pDSrKgX2nraOhCA
         xoQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=LQAq5ZGQ8o0h/oRYsU3ZZla/huSN2riS76fxO54XGWnqlpehAa23MF6FcEY0OvR/Ed
         sToX2IsI4+hIxXd7jMF69T8ky3fzTtL581zJnshxQrE3R874Tn/kgbR9g9/CwMQhs+/7
         khRUr/R/nxbnTIFaYtQUcJTIfdom0YOCCm3P2e4CgAAQvERG6dQ3xf03RzDhx9sPXVfZ
         kGRD2qRWKrdQEktkEpqu2DAAZh4VE18gvQKEhGsmFFSNRlb0jB5blHOh4V9z5HZBbGRP
         +l8SzxpnDh9TRLHgwiz/qyf0z6rJpdkUXJ6AVJSEsK31I/C7c0YucZp15Ln5yDUKPK7d
         mQ8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=T2Dnazcb;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id n11si1179646qvd.178.2019.04.10.18.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:37:18 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=T2Dnazcb;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 62EFB65C2;
	Wed, 10 Apr 2019 21:37:18 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:37:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=; b=T2Dnazcb
	/R5hs8UgDc52FqBf3Tc+JxzOrMivrjhEbFPq95OABXHc5Kulcwy1LXhCLmVs4b+v
	7vUtrj0ATPPVG/WL35+1azsveq5sj4nYpbPXnTRkv+kicTsjpGYLJN4PSY4zlHBP
	I+rrACBM3oA+VUHODQLqOM7f1SDTcjwn1P5iLE53yQQw8AV/9DHPbh0ZqB6rO/tG
	bE7g0co41WG80M51Khuh6o+hVTDuRWosh9TGqM4MjNFh6a5U+itLY4uP5OEtsjwG
	6gevfogm5twv+IFJa3rhI66WoYalFJx8EHPfMGx5LQWs7Jn21oYhRHAaE4BGXqJ3
	bAL+25a4C0eOGg==
X-ME-Sender: <xms:TZquXLdSZ49BlOsvCXXkpy19FIc9K9IZHZKmEmnFw80u4U7w3TLjBA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:TpquXGerAeWU1tFJ0qP-pzHqN1ULQCSwL1m1KWS1M1ID-QNqeI0TSw>
    <xmx:TpquXGMkPC_i8MpWcp95x7rcFbzKZ3j9fMDAJ8QG-N9PYehPjhBKYg>
    <xmx:TpquXFJm2b7uEJlnWQRKT3eU3LKNMwAZ802Pr9yvTlFYNX-MyhT4oA>
    <xmx:TpquXB156yEZOmPbZUDA5c3Wx5IsTwETnm-IhqTgdPD1MJGSsI5pwQ>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6C4C7E409D;
	Wed, 10 Apr 2019 21:37:10 -0400 (EDT)
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
Subject: [RFC PATCH v3 12/15] slub: Enable balancing slabs across nodes
Date: Thu, 11 Apr 2019 11:34:38 +1000
Message-Id: <20190411013441.5415-13-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (SMO).  On NUMA systems
slabs can become unbalanced i.e. many slabs on one node while other
nodes have few slabs.  Using SMO we can balance the slabs across all
the nodes.

The algorithm used is as follows:

 1. Move all objects to node 0 (this has the effect of defragmenting the
    cache).

 2. Calculate the desired number of slabs for each node (this is done
    using the approximation nr_slabs / nr_nodes).

 3. Loop over the nodes moving the desired number of slabs from node 0
    to the node.

Feature is conditionally built in with CONFIG_SMO_NODE, this is because
we need the full list (we enable SLUB_DEBUG to get this).  Future
version may separate final list out of SLUB_DEBUG.

Expose this functionality to userspace via a sysfs entry.  Add sysfs
entry:

       /sysfs/kernel/slab/<cache>/balance

Write of '1' to this file triggers balance, no other value accepted.

This feature relies on SMO being enable for the cache, this is done with
a call to, after the isolate/migrate functions have been defined.

	kmem_cache_setup_mobility(s, isolate, migrate)

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 120 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 120 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index e4f3dde443f5..a5c48c41d72b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4583,6 +4583,109 @@ static unsigned long kmem_cache_move_to_node(struct kmem_cache *s, int node)
 
 	return left;
 }
+
+/*
+ * kmem_cache_move_slabs() - Attempt to move @num slabs to target_node,
+ * @s: The cache we are working on.
+ * @node: The node to move objects from.
+ * @target_node: The node to move objects to.
+ * @num: The number of slabs to move.
+ *
+ * Attempts to move @num slabs from @node to @target_node.  This is done
+ * by migrating objects from slabs on the full_list.
+ *
+ * Return: The number of slabs moved or error code.
+ */
+static long kmem_cache_move_slabs(struct kmem_cache *s,
+				  int node, int target_node, long num)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+	LIST_HEAD(move_list);
+	struct page *page, *page2;
+	unsigned long flags;
+	void **scratch;
+	long done = 0;
+
+	if (node == target_node)
+		return -EINVAL;
+
+	scratch = alloc_scratch(s);
+	if (!scratch)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &n->full, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		list_move(&page->lru, &move_list);
+		page->frozen = 1;
+		slab_unlock(page);
+
+		if (++done >= num)
+			break;
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	list_for_each_entry(page, &move_list, lru) {
+		if (page->inuse)
+			move_slab_page(page, scratch, target_node);
+	}
+	kfree(scratch);
+
+	/* Inspect results and dispose of pages */
+	spin_lock_irqsave(&n->list_lock, flags);
+	list_for_each_entry_safe(page, page2, &move_list, lru) {
+		list_del(&page->lru);
+		slab_lock(page);
+		page->frozen = 0;
+
+		if (page->inuse) {
+			/*
+			 * This is best effort only, if slab still has
+			 * objects just put it back on the partial list.
+			 */
+			n->nr_partial++;
+			list_add_tail(&page->lru, &n->partial);
+			slab_unlock(page);
+		} else {
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	return done;
+}
+
+/*
+ * kmem_cache_balance_nodes() - Balance slabs across nodes.
+ * @s: The cache we are working on.
+ */
+static void kmem_cache_balance_nodes(struct kmem_cache *s)
+{
+	struct kmem_cache_node *n = get_node(s, 0);
+	unsigned long desired_nr_slabs_per_node;
+	unsigned long nr_slabs;
+	int nr_nodes = 0;
+	int nid;
+
+	(void)kmem_cache_move_to_node(s, 0);
+
+	for_each_node_state(nid, N_NORMAL_MEMORY)
+		nr_nodes++;
+
+	nr_slabs = atomic_long_read(&n->nr_slabs);
+	desired_nr_slabs_per_node = nr_slabs / nr_nodes;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == 0)
+			continue;
+
+		kmem_cache_move_slabs(s, 0, nid, desired_nr_slabs_per_node);
+	}
+}
 #endif
 
 /**
@@ -5847,6 +5950,22 @@ static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
 	return length;
 }
 SLAB_ATTR(move);
+
+static ssize_t balance_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+static ssize_t balance_store(struct kmem_cache *s,
+			     const char *buf, size_t length)
+{
+	if (buf[0] == '1')
+		kmem_cache_balance_nodes(s);
+	else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(balance);
 #endif	/* CONFIG_SMO_NODE */
 
 #ifdef CONFIG_NUMA
@@ -5975,6 +6094,7 @@ static struct attribute *slab_attrs[] = {
 	&shrink_attr.attr,
 #ifdef CONFIG_SMO_NODE
 	&move_attr.attr,
+	&balance_attr.attr,
 #endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
-- 
2.21.0

