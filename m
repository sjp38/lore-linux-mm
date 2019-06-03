Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AA71C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A24F827B6A
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:29:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LPQlwJrO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A24F827B6A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F2096B0279; Mon,  3 Jun 2019 00:29:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A3DD6B027A; Mon,  3 Jun 2019 00:29:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36A8F6B027B; Mon,  3 Jun 2019 00:29:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1547F6B0279
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:29:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l11so3414590qtp.22
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:29:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u3v0eiZffY+v2sn8V9SnXJ0gtCWl1JCgJq73oZGa8dI=;
        b=FceihokTILCqS8kH70aDI+iFr2V0COHl+JEbF4RmN3t3k6ElP+yPV4li8dLZ7J3mqT
         VEFp7n1dl3ggQVtB2Cb7OaeK4S5sas7Tz2HM/hS/U1o4QCUMWyNAIfdGs5VESS+htQZE
         8VAynXs0xq0QP/kFgH5rVVtnt0M+gPkV3JUrCG/j/AQcu7WTkVNogpuu6j3JQx3g+HE2
         UIA7o1YSBpTUSrh0G/T6kbrtSSNfERoyqFsXZDA44Cl77RLwtam3q96Q4DE9vOOGDAGz
         5I8+Y/u0o/Y2w3gHCZqer/wkkCYkdXKVNt67977JhlCTmZzdZ3zOsNc5wBFv/gO/eCf8
         J4lA==
X-Gm-Message-State: APjAAAW+JQnx+Q9Q+BUwXR42+47ocmsPFsTscD1oFdvG+GqhrXig3jr2
	4ZbVEc5zW62hHSy2lWn+r3punuvqvgSu+lO7v57KTaA2tqjNKerxrKVMt5NbpfGmooX2NPrOJiY
	0gNLBDt/PDs7Z5PFi7jSJoSXnfrPW4Aq+27EuByBujrVLaAwue6dBLbdsAsMHN1M=
X-Received: by 2002:ac8:6984:: with SMTP id o4mr21012200qtq.122.1559536164818;
        Sun, 02 Jun 2019 21:29:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWtW5A6aIojwDR+Ct0s1cjEsuFB0mmAgkjbTNFn4Kc+DxxOKwlZWspmEZAFUAIUNSeYHbU
X-Received: by 2002:ac8:6984:: with SMTP id o4mr21012170qtq.122.1559536163998;
        Sun, 02 Jun 2019 21:29:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559536163; cv=none;
        d=google.com; s=arc-20160816;
        b=S5v9GTz9/G5CiFsG9P1jM3F5zDQzKrpEcJdbZU6X/44H8G1zgjml9hranQaCrYtGGn
         RCVh1ncZZ9NE6tuYQ0VzHpHH1+f092oSY/pXYETbfudOW1KsXic9r0DT4NWtplWpfwGQ
         NUGyuglCvmVKJdquhrc8vIVPiXf1uJRPm+9vCblP2nXrwOiA4vabg1f89VuuljKT/YU/
         9CVecImO2tbCcLuVJ59Hpe9FN/vcy+7vo44Pk+jnqM/F4RpLeE+Km2YApN/SZbqEsEza
         1FskFpLzAYwst1X7tpEUlXxSBcXHOo3OvfU1aAqds8aFwLra3UlQJMvp5zJi3BURUgIA
         4ejw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=u3v0eiZffY+v2sn8V9SnXJ0gtCWl1JCgJq73oZGa8dI=;
        b=cmhhfzIrh9tsNY2E3D9lqYp77qpBjlxrQbHYCR2SbsmeAbH6ZNIQ+zwrjAwstcaheQ
         czAc85iVM9yHY6Sdx+xrH97vXmZ0rG7okMGWY/+Axhdz50RhYnfn/bEKBoKVYee0U4B6
         U5bKm5in89qBZNr5z8PYaDjXfXtCvbsqIyJx4iE0JfMrZDe8CNFYthYn/9I0gNU4afDc
         SdRGEaOC5mdprIFypbYboz/C4XdBpFUdvo2rGloUvI2Zq9xuU2zzG8rR9b0KXKAopfTE
         EgUghwg0+GUFCLQAM9fjCvDMXXnC2LPaLfQsoFmzDB48yCg/tSdKwnpVynMXbz5DxT/a
         LdmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LPQlwJrO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id c8si9144229qkl.265.2019.06.02.21.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jun 2019 21:29:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=LPQlwJrO;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id BF63821FB;
	Mon,  3 Jun 2019 00:29:23 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 03 Jun 2019 00:29:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=u3v0eiZffY+v2sn8V9SnXJ0gtCWl1JCgJq73oZGa8dI=; b=LPQlwJrO
	rlkK/aTKLE3ZbR1UfmcfzlAUCyKPw8waLGQpzkYI/A5+0IKEnsjJYFiMUoD8MDkj
	vrHDs2Ya0zR7ue81LL1ThhvGv8BimaSnUO9o6q1Lwt09kbSu7ZxchL1OQteUlPRR
	7TuZ+oS/qf3nJ2oT0uqWSGSaPJ0UWQX4UGcbRHdiRq32EQzkgCpOOYZDWaBxbDAm
	2oIWR+76Jkwz5DjIXVBUpxmSEWbNUMo35tOH7i4WBJgkm4F0MSBJBY9jmNgjC6g4
	4zsmGirt8UPn1jynaz2Eei9l2/1GU3t43bhb1qgvnFXaPBS5rbUm90UCcp1+u6CA
	uhWce+zErqC7jQ==
X-ME-Sender: <xms:I6L0XFEznNRIUkNHx7UbsZfU9uDOw6Pn3cmv7vgfcRGktT7hz75qaw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudefiedgkedvucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhephffvufffkffojghfggfgsedtkeertdertddtnecuhfhrohhmpedfvfhosghi
    nhcuvedrucfjrghrughinhhgfdcuoehtohgsihhnsehkvghrnhgvlhdrohhrgheqnecukf
    hppeduvdegrddugeelrdduudefrdefieenucfrrghrrghmpehmrghilhhfrhhomhepthho
    sghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:I6L0XD6XFsa_C5ICtjyrrqbuwSuHB4fQ37d1hdpdEfYg2uSW9Xc5Yw>
    <xmx:I6L0XCn8NLLBcNa-_ERRzkHIJbw9gA4n1PciJj_sPM0vmTB55-vVZw>
    <xmx:I6L0XJx0SX5f1wjC9N1bHp1dsCmOvgZLpMXtQlnbIRYHpl5D5-Ihgg>
    <xmx:I6L0XGIvyG0fCyoVfFBSyKm10T_BvgTvEyXvbgoULHTtC5W9qnRIUw>
Received: from eros.localdomain (124-149-113-36.dyn.iinet.net.au [124.149.113.36])
	by mail.messagingengine.com (Postfix) with ESMTPA id 9CF3C8005B;
	Mon,  3 Jun 2019 00:29:16 -0400 (EDT)
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
Subject: [PATCH 15/15] slub: Enable balancing slabs across nodes
Date: Mon,  3 Jun 2019 14:26:37 +1000
Message-Id: <20190603042637.2018-16-tobin@kernel.org>
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
 mm/slub.c | 130 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 130 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 23566e5a712b..70e46c4db757 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4458,6 +4458,119 @@ static unsigned long kmem_cache_move_to_node(struct kmem_cache *s, int node)
 
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
+	if (!s->migrate) {
+		pr_warn("%s SMO not enabled, cannot move objects\n", s->name);
+		goto out;
+	}
+
+	if (node == target_node)
+		return -EINVAL;
+
+	scratch = alloc_scratch(s);
+	if (!scratch)
+		return -ENOMEM;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
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
+	/* Bail here to save taking the list_lock */
+	if (list_empty(&move_list))
+		goto out;
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
+out:
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
 #endif	/* CONFIG_SLUB_SMO_NODE */
 
 /*
@@ -5836,6 +5949,22 @@ static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
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
 #endif	/* CONFIG_SLUB_SMO_NODE */
 
 #ifdef CONFIG_NUMA
@@ -5964,6 +6093,7 @@ static struct attribute *slab_attrs[] = {
 	&shrink_attr.attr,
 #ifdef CONFIG_SLUB_SMO_NODE
 	&move_attr.attr,
+	&balance_attr.attr,
 #endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
-- 
2.21.0

