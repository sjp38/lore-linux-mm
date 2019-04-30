Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECCADC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93FFA2147A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="eq8zJ4mn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93FFA2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0A56B0282; Mon, 29 Apr 2019 23:10:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 492A56B0283; Mon, 29 Apr 2019 23:10:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3320B6B0284; Mon, 29 Apr 2019 23:10:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1209D6B0282
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:10:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k6so10741705qkf.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:10:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=c4vjmygDxNgPoabrEig7WAHWWk1cpxB2NNWphxYU56H7+J7tZJPIfN620Q6kfbpULv
         RcaCiqaG3Tj19UgaupsegXaUvKEzkfykM04ofDFUO+fg/RlawZIMsVNyQZv7bJdH0so0
         MaTntrcqOXyenBJ26xq/RqaMDlOEC/vZ6ugECT5YIvYsqCj32CLvFCsK2I8/dasc2SPT
         bz/d+eoeguXJZUvKUTISzXMlSI4beyd4d0OE90qzwxuEoQSy09c1sQS1xyUQftlq/5T/
         VCZnitMhpk4nWme6qHi6eZPA3+QiEbZEWVp37qBi2Mo0Vzz4USi86S6BoNJ6WU/APEDS
         tnsA==
X-Gm-Message-State: APjAAAVbVSshzgjwZgy1tdkUZGZCMDjNijHMXPnfpPKdZRs1tK+VUq74
	jvmyG/Tlo2NrPtCGN7Zzmdrf3vTDmesFQOL4ZyioYCjrKynA4IxsNgAmHAV+2BjA+iFu9jFUtym
	I2G9a5W3hqzMiocMaj2rHS8Uj4wtVD8Ex4+53jGGbgoTeszT19lEtPUHyLKNRNOg=
X-Received: by 2002:a0c:d603:: with SMTP id c3mr41467243qvj.144.1556593821831;
        Mon, 29 Apr 2019 20:10:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6VHNMbuiA2hrvASaLpgbpcBiv81vjHaxAVRg9DHKyhndhRuUGZDRwugsB+DRBbeMFYfw3
X-Received: by 2002:a0c:d603:: with SMTP id c3mr41467197qvj.144.1556593820542;
        Mon, 29 Apr 2019 20:10:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593820; cv=none;
        d=google.com; s=arc-20160816;
        b=I4MvaAfzyMdheLtCSr/AIoTyVvool4PPBrhEWhUiBaRms+v8ZBUhv1/oZkNSYlLTBY
         bi4nQmMyMJglkMwVm3Jwq/N8n5Y7TQVLxArQOJQ6LQbD9YJYyLNR5JtB8DDD+4e4NQ65
         WbbloFP1hzG6HbHfiBaJHh2XksTRonOXxA4hWAE3YtfTeZ1wtWBZRfVglCnS7JFqGdr2
         aNXQ0M2Me9w/Ge2y9Rfp8PvLux2OBWxeJrAbt4JHXiXU8Oz9tpkfl0VxK37SUj/TKuQC
         QqxJMZy5NWODUityrpPH1KHWsAejJd3mLL6Fx7qZvgkT31e1t8o4cGjjwbaWEvnYKRE6
         dIdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=;
        b=CMiZu4kwKMdgFS3Qb7eOeoe7JZCqnN/I21rS9JTeU48k+Zw51JqKJWRDu0REBeXTAQ
         5okhOfy0tlrtvkHKwuFmtC92MMph1S1CwOcGAXjcPdqG9fb6XHsma7XJf7nF/HwoILYc
         SOAkbOxGN4WhEhuHgXJ9lODTP9zpW+zjvhMKpXFXhGR18H/5V5fOmGmuuvuXIUzVFLj2
         GSgau2IOK8JjBoQSkse4BIPyXycrcex1jiKIftB3AZfczaA2j/fnYAoZ0TqcJ5Aoc8+s
         tIei5QPKk5GDpVq8y+SnquPkv0GqN85xF7eGfTlaFYQNMAhDjTbHghuI4+3OnwxI32oC
         AbuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=eq8zJ4mn;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id m129si812870qkd.2.2019.04.29.20.10.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:10:20 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=eq8zJ4mn;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 48A29B24E;
	Mon, 29 Apr 2019 23:10:20 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:10:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=aa6iExGIwghZDn1ZohvQXbuCEdzySOldf4bort+1eX4=; b=eq8zJ4mn
	Lf3zb/snoc2FYDatoMhTLJ9Q4aZfQKL3GjXL3f59hF9pGLS0ly2Iw8VD6yKgIaMn
	fm9GLilO8ToenemuTBE3wLNe7QcfqeKyr7kAXc3UfNm01VqP6idcDVfOxgQFfRg3
	3MbjdgyWaveCL1W/BNxVwnpVSymreHU8+WLRqP1T8Y4flfpDv5NEZQ5J0vm4jg0X
	XPqjWCChAE+FucXI639pKS4FT9u/kePz7Y+rIakvO4vc3jmU1TPvGTDv6Y7Vy5hI
	+G6OjX+4/5eiHB1QzWvBcAFM12mGZi/Qpx6EmRGlL+eIJTlz54oP1+iGXdYCqSWf
	vsNbyM7NeoNnfw==
X-ME-Sender: <xms:m7zHXLMW7BJrOR0T0exI2YrydzMHFjqbYLqlJztlatKE9m77aVYpWw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeilecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:nLzHXBaON1Eqkgn8kyUXMHYjFnKrMx9JI7xqJ3FWl5OKBG78uKYeQw>
    <xmx:nLzHXI9piN7Qt_RxHD3yP_m4Th30o6oDSIWKqdxaoxDkVcnb8x2lVA>
    <xmx:nLzHXM2aYfmuSLhGuyjlaWa0hbzRZbHbzjCkWIatznnMqT8zOYaOGA>
    <xmx:nLzHXJ5Fp5yz0KR7a17PbZLLPynjjCyRoSzv4AiJzAwQWcju9Ah2vw>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 855FF103C9;
	Mon, 29 Apr 2019 23:10:11 -0400 (EDT)
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
Subject: [RFC PATCH v4 12/15] slub: Enable balancing slabs across nodes
Date: Tue, 30 Apr 2019 13:07:43 +1000
Message-Id: <20190430030746.26102-13-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190430030746.26102-1-tobin@kernel.org>
References: <20190430030746.26102-1-tobin@kernel.org>
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

