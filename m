Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72FBDC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13FE2206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="8XjWeMn3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13FE2206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9C546B027C; Wed,  3 Apr 2019 00:24:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4B816B027D; Wed,  3 Apr 2019 00:24:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A15216B027E; Wed,  3 Apr 2019 00:24:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E45F6B027C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:24:16 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e31so11510847qtb.0
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:24:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=Ey0HEKq65UA29PpjVvRlXWV30nw9MY3iwHs5dzXTrx5YJOuaZRx69lf07GCnJbKH1k
         eSN8kH84r/CDFHXkSs+hOnZXbClLiW8ZjeQuTO+B307trd8c27mRyxLW2N7Z6R0Jyo+B
         FeVhOMQNC1jcwHA0N6cogXcGmNjADhHguF6an+DXmdzT0961JA8ph/EcRY8WjxZWDIda
         FkE45ffCZ+KPbL0re/c8aODvktz8+mj/EJoUEQ4qzXx5J60ThRhyZSCfUrwTY2iCoBAe
         7lshE+ZnM2zBmlEUsaHiwzpk+ymLqQK0ANHsRuO2OqAjoHKc0ai6UcCc9tXiZIlRelzz
         xZxw==
X-Gm-Message-State: APjAAAXmnI8GRF6sZLUWbVkj6UdyTdTybnEaXTOnhw8pVtlFji0sf7zr
	jmmNFc0gMoDwzMagcdH+W+xYBSGlEEkBziiZA1dHL5RGTRr/e2pb0iSVlPlXQ67NBDEUWO2wnoi
	JwxFujXyj6smA0cjhZdeNfMuEDvW4OHGtKcxPoDE1Li9HFEmkJKlgG5ukW99hERU=
X-Received: by 2002:aed:2bc7:: with SMTP id e65mr52285932qtd.339.1554265456257;
        Tue, 02 Apr 2019 21:24:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWagwU+/Z5sBioysnZZcQ6YVp+xuenla8Pw0qvWj75306GOkS5+sgUsPeFBw+mv42A7ds7
X-Received: by 2002:aed:2bc7:: with SMTP id e65mr52285890qtd.339.1554265455286;
        Tue, 02 Apr 2019 21:24:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265455; cv=none;
        d=google.com; s=arc-20160816;
        b=Tfm+rM+1Ts2nmCu31z8hFyUOdzP6iaXb01KnYsc3R8D8QSjkE4XCYRony8sFKfHvzF
         6dfTdUmqDxf5EwQ3Wt3Wk446hESDoNyXVpNC+bAnClPZsdNXAHxGZZblYmu6FUoJ6UeL
         79AGoMyYi+Z0egulYaYh3hAVDDae7z8zeshfQvyVyTrvD8QiaXmup45CMfl1Ktz6xx3J
         BoI+wrocaZiE8rDwL6noLMPQ774/4DzU40SHcdxkU+8418mQ+up3N1QnEj+H3JAqmU+g
         Sf9IRDyMNMf6hhzOQJxP8eNm3Cs0IojLFe/U59/cpUfSDeQyPuprnOteYLidbSBRRObx
         pQkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=NkhEIbJCkjeasABT+oS5okLNQufuJoN07P5CO1Cs2zgV1+ssumYu3vl92himWLeQ2L
         9KjRiS/3S1I+JHV9kx06RjoOIwYK4Kpw7ExIfojTGnLZvQQQ2W3g5sgUYdBWCbDa9T8r
         H2hT4CkzBks6/JyYI/oVPo0OzoD/N3indsbdKHb0b61QNvKUrCZio1f5fxE51g+g77YL
         yysHuR6Q5PryScpaqQUA9Nhy5DYqMu/glq2TCpUk5WKfH/hRwAMes6iGttBAV7ktXBDQ
         zaoO1Ge8+5RlRsFPpjU0JDQKKVurCM9hOeIJhakEF/J+8eq5HARcLZn7oXTHmpLDQCdD
         oyVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8XjWeMn3;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id i13si3522891qta.371.2019.04.02.21.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:24:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=8XjWeMn3;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id F3F2921BCD;
	Wed,  3 Apr 2019 00:24:14 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:24:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=; b=8XjWeMn3
	stH473eDauTmxcBAVjsdZ6VLe07BfcTO+2jHtP6gWq0xcnjBPRi3hGnlBM9khyi4
	x7rcfhtn6on7u25FsA2urq4JCHEBepYJkczrl/3vlZ48x4/DSRQKqoEWbBnBvVfJ
	MxfOOHWtw0PZu+4cT57honGKLamY1JbCpj+a27p+axoBMaxq5f4bSlAr2TeE93n/
	U5cd+18ck6m9ASBOCRNlBOQYvXX19OfKV4J3f9gfs/p/Ykio4ZEep0Nd/8CLNKMu
	SmIyQa15UNhCGj7disyal3eeyG8Ig8iFK8sUvsUwB+8kAaMt75jfZBoxCvTOLV4w
	pZs8GJCUsqb2jg==
X-ME-Sender: <xms:bjWkXDI7rudn-Spb64giJmJB-shiY4vTqGZ_skv51pgdHoA5qXG9nA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpeduud
X-ME-Proxy: <xmx:bjWkXLvrdzTT7ajNuVw9SLH6CPT_arCRO7SQzZJZtutKtjnPIamIig>
    <xmx:bjWkXBLk7a4fcv0_qLI004cSSpfO6qoAz8X7y3Sk0CqidPNOwGEBCw>
    <xmx:bjWkXPCvuHXbiwvTJ5vYueFxFzCv4Ebf0k_izTZhK4_Nffhbc-DnSg>
    <xmx:bjWkXPa31EcJUk2qFxh9OGXpoCT9D-VcIsScU2hancUDnJyxI199sg>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 22EAF100E5;
	Wed,  3 Apr 2019 00:24:07 -0400 (EDT)
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v2 12/14] slub: Enable balancing slabs across nodes
Date: Wed,  3 Apr 2019 15:21:25 +1100
Message-Id: <20190403042127.18755-13-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190403042127.18755-1-tobin@kernel.org>
References: <20190403042127.18755-1-tobin@kernel.org>
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

