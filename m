Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C66FBC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 620CF206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:24:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="X5wsJ1NW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 620CF206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1153E6B0272; Wed,  3 Apr 2019 00:24:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C6786B027C; Wed,  3 Apr 2019 00:24:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED0936B027D; Wed,  3 Apr 2019 00:24:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB73F6B0272
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:24:09 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d8so13534016qkk.17
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:24:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YTpDBiPIz+r0uG1auSa8ph45UtBEpiDJlB6LNiHXZmQ=;
        b=cBzVLJ2+Fqsq28lj4PMoYCkuAt6m3O9pYQ0XQxLVKRpy9DP9WzqpMa8+P+40gH7Yqi
         wmR+MTemPVZ/PLfL/VW4cHaX/VwcGqse2C14clZRfCrBEqWSjzAgss2CvY6esZIMgJpO
         1FU3diMea/gKrtvtGWMLB0a0ygbZKcEMT27iFa4JbykkL3GExACgPwPFv3egOYboKOsp
         07j2uMkMj0qWPaDweOCr22E62kZdPNplrtDhrzvhQkji7shzTnNIEz90ybU+O3Xpvfxw
         I1bM8glgfkbYTBshfq8gMqkPp2JQE8Igf7tw5Fp0jeS5lzPe2kl6tMiYBtimYJFR9/5+
         uFAw==
X-Gm-Message-State: APjAAAWajbNNgtrXX61hSj6jdBkLLaMZFi1wbFQVlfiSNnvy06uDFUn4
	+ADNL93bNAMNToHnLW/jO0FSiv2jMz7ezMjX5xbPjtTBfvFynB+UIcwlwt62F66ckvaRjI54fnC
	NEJN4S/YKgyCXXm+CJkvYwgAnP10CTnAsfXxmFFA7+dVB3mslYH1nAaSmcX8pxZ4=
X-Received: by 2002:a0c:ba8b:: with SMTP id x11mr27193qvf.196.1554265449489;
        Tue, 02 Apr 2019 21:24:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykBRLl2pId63Z7GP2LLw5sLBBLVnd/a9QQYnjQONkGA4wUiz/KXxBvN6PZFR4h2pqOK3ZD
X-Received: by 2002:a0c:ba8b:: with SMTP id x11mr27140qvf.196.1554265447915;
        Tue, 02 Apr 2019 21:24:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265447; cv=none;
        d=google.com; s=arc-20160816;
        b=JBMi0yYyv3DA5b7GimfwH4SpeTdYj+8Z21yVZj74f0Zds8DAoEYpaU3kGt0nuQRbIe
         igfciJ/u7ck6tWtiPKJa1s+sTlu3izY3Mzq2yIHat0WjGM8zyon54jUkbFjR6V64o9GM
         6XYNXHsIL9OrChMq5bZRL6QKWjPupXCZlEVQizEAz8K8+m0B9jlNnN9LA9fC970Q8W8l
         eKTSBeh2WNuiTGORSc/bZu/0rkweiQxLN+wZI5FCsY5wJ5NkIglMU0Cd069DrR1j1iwb
         pimDhxVspqpY/QrJwVs/BQqAvPsVhFspkXP7bICfMW8W+g8KDnsSu0Ko1DlL6K3X+Xpu
         409A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YTpDBiPIz+r0uG1auSa8ph45UtBEpiDJlB6LNiHXZmQ=;
        b=z0RfU145R37zcPvNFWjF0tDxrTTz9rp76aD+cqCPPW8ds4RvCZw2rvWA3j4q6dZDnN
         8aG/jF3WR/z+Wdozt+potctBj0BLa+sYVBiu9ZLCzM9mUqtfIAVw2z5giOqgwmaxhK0m
         CeVM78o9AVhCQAxM7IO2qSEdA+Gatmny4JIkmrgw5Qh8AaRLx6uJj2iAd7hZauTZt9tR
         Px3Um4Waa9I/QVjdVebhoOGaIHt4qo9gc9St/enhPFnBJtztQYRwkI78w2ojai+lEfTu
         uPBAkgdcKhwrSrqlDH0wnvVG0wVi427w1qxKSEaMyJvN+rHFtpG4bEQh5l1JKWt+A3F1
         hzRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=X5wsJ1NW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id q31si2853875qtq.129.2019.04.02.21.24.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:24:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=X5wsJ1NW;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9A09121F58;
	Wed,  3 Apr 2019 00:24:07 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:24:07 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=YTpDBiPIz+r0uG1auSa8ph45UtBEpiDJlB6LNiHXZmQ=; b=X5wsJ1NW
	j0kMUfLEpoua6IDApdgX2D7yPdMhSZdgZn7LQCeXgAfFApbVJApH41rmM3CuhuKQ
	kIlIUBmlYtXnf0ndhfiei7+kKgVJHfbvsQDmXo2IOGqS6mTQvjPc2gXqlMcwa3KJ
	BlBZy2FIJ5WYCsvUHiYkrX1e54/P3NaF3ZwhwTynoqeyZFshk7Gh/F55Ts3i2H+/
	SfWKOzPAI46ATOYN4MoZ3vo/GUoQ3YZwjV86VWv5gNU/8amiMZQh+/12BXgN7oee
	LSE4FUYnRz9aOZg4uCa+QIuFODjrChMraumCeGxQFxct5Q5xN1A3SpAglREARmcB
	KN8fNlHrXPRUBw==
X-ME-Sender: <xms:ZzWkXPJoJ_ZBbRxEFIprP_Mtr6lz8Ki2-UpL7CVz2OmGLEd1mmPFrg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedutd
X-ME-Proxy: <xmx:ZzWkXIYkKOGr4A35vlt1V9YjOj5aAIpCAwwXhSajxULC2gJQLwUJrA>
    <xmx:ZzWkXJaQA6f-Misl1HrCYVJlqyxxrX97qUTYewBg8ix1cDHOT2iSwA>
    <xmx:ZzWkXAlK_OI_LUYdYHlSExkdHx6RzwF0xJki3qixVbh6NnQE59FTmg>
    <xmx:ZzWkXMffJHX55B0Zd8Gal1z_zlqiXzCY1JIRYTKrQtyB5wRUnAcgSg>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 909C9100E5;
	Wed,  3 Apr 2019 00:24:00 -0400 (EDT)
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
Subject: [RFC PATCH v2 11/14] slub: Enable moving objects to/from specific nodes
Date: Wed,  3 Apr 2019 15:21:24 +1100
Message-Id: <20190403042127.18755-12-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (object migration).
Currently object migration is used to defrag a cache.  On NUMA systems
it would be nice to be able to control the source and destination nodes
when moving objects.

Add CONFIG_SMO_NODE to guard this feature.  CONFIG_SMO_NODE depends on
CONFIG_SLUB_DEBUG because we use the full list.  Leave it like this for
the RFC because the patch will be less cluttered to review, separate
full list out of CONFIG_DEBUG before doing a PATCH version.

Implement moving all objects (including those in full slabs) to a
specific node.  Expose this functionality to userspace via a sysfs entry.

Add sysfs entry:

   /sysfs/kernel/slab/<cache>/move

With this users get access to the following functionality:

 - Move all objects to specified node.

   	echo "N1" > move

 - Move all objects from specified node to other specified
   node (from N1 -> to N2):

   	echo "N1 N2" > move

This also enables shrinking slabs on a specific node:

   	echo "N1 N1" > move

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/Kconfig |   7 ++
 mm/slub.c  | 249 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 256 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..47040d939f3b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -258,6 +258,13 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config ARCH_ENABLE_THP_MIGRATION
 	bool
 
+config SMO_NODE
+       bool "Enable per node control of Slab Movable Objects"
+       depends on SLUB && SYSFS
+       select SLUB_DEBUG
+       help
+         On NUMA systems enable moving objects to and from a specified node.
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
diff --git a/mm/slub.c b/mm/slub.c
index e601c804ed79..e4f3dde443f5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4345,6 +4345,106 @@ static void move_slab_page(struct page *page, void *scratch, int node)
 	s->migrate(s, vector, count, node, private);
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * kmem_cache_move() - Attempt to move all slab objects.
+ * @s: The cache we are working on.
+ * @node: The node to move objects away from.
+ * @target_node: The node to move objects on to.
+ *
+ * Attempts to move all objects (partial slabs and full slabs) to target
+ * node.
+ *
+ * Context: Takes the list_lock.
+ * Return: The number of slabs remaining on node.
+ */
+static unsigned long kmem_cache_move(struct kmem_cache *s,
+				     int node, int target_node)
+{
+	struct kmem_cache_node *n = get_node(s, node);
+	LIST_HEAD(move_list);
+	struct page *page, *page2;
+	unsigned long flags;
+	void **scratch;
+
+	if (!s->migrate) {
+		pr_warn("%s SMO not enabled, cannot move objects\n", s->name);
+		goto out;
+	}
+
+	scratch = alloc_scratch(s);
+	if (!scratch)
+		goto out;
+
+	spin_lock_irqsave(&n->list_lock, flags);
+
+	list_for_each_entry_safe(page, page2, &n->partial, lru) {
+		if (!slab_trylock(page))
+			/* Busy slab. Get out of the way */
+			continue;
+
+		if (page->inuse) {
+			list_move(&page->lru, &move_list);
+			/* Stop page being considered for allocations */
+			n->nr_partial--;
+			page->frozen = 1;
+
+			slab_unlock(page);
+		} else {	/* Empty slab page */
+			list_del(&page->lru);
+			n->nr_partial--;
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	list_for_each_entry_safe(page, page2, &n->full, lru) {
+		if (!slab_trylock(page))
+			continue;
+
+		list_move(&page->lru, &move_list);
+		page->frozen = 1;
+		slab_unlock(page);
+	}
+
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
+			if (page->inuse == page->objects) {
+				list_add(&page->lru, &n->full);
+				slab_unlock(page);
+			} else {
+				n->nr_partial++;
+				list_add_tail(&page->lru, &n->partial);
+				slab_unlock(page);
+			}
+		} else {
+			slab_unlock(page);
+			discard_slab(s, page);
+		}
+	}
+	spin_unlock_irqrestore(&n->list_lock, flags);
+out:
+	return atomic_long_read(&n->nr_slabs);
+}
+#endif	/* CONFIG_SMO_NODE */
+
 /*
  * kmem_cache_defrag() - Defragment node.
  * @s: cache we are working on.
@@ -4459,6 +4559,32 @@ static unsigned long kmem_cache_defrag(struct kmem_cache *s,
 	return n->nr_partial;
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * kmem_cache_move_to_node() - Move all slab objects to node.
+ * @s: The cache we are working on.
+ * @node: The target node to move objects to.
+ *
+ * Attempt to move all slab objects from all nodes to @node.
+ *
+ * Return: The total number of slabs left on emptied nodes.
+ */
+static unsigned long kmem_cache_move_to_node(struct kmem_cache *s, int node)
+{
+	unsigned long left = 0;
+	int nid;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == node)
+			continue;
+
+		left += kmem_cache_move(s, nid, node);
+	}
+
+	return left;
+}
+#endif
+
 /**
  * kmem_defrag_slabs() - Defrag slab caches.
  * @node: The node to defrag or -1 for all nodes.
@@ -5603,6 +5729,126 @@ static ssize_t shrink_store(struct kmem_cache *s,
 }
 SLAB_ATTR(shrink);
 
+#ifdef CONFIG_SMO_NODE
+static ssize_t move_show(struct kmem_cache *s, char *buf)
+{
+	return 0;
+}
+
+/*
+ * parse_move_store_input() - Parse buf getting integer arguments.
+ * @buf: Buffer to parse.
+ * @length: Length of @buf.
+ * @arg0: Return parameter, first argument.
+ * @arg1: Return parameter, second argument.
+ *
+ * Parses the input from user write to sysfs file 'move'.  Input string
+ * should contain either one or two node specifiers of form Nx where x
+ * is an integer specifying the NUMA node ID.  'N' or 'n' may be used.
+ * n/N may be omitted.
+ *
+ * e.g.
+ *     echo 'N1' > /sysfs/kernel/slab/cache/move
+ * or
+ *     echo 'N0 N2' > /sysfs/kernel/slab/cache/move
+ *
+ * Regex matching accepted forms: '[nN]?[0-9]( [nN]?[0-9])?'
+ *
+ * FIXME: This is really fragile.  Input must be exactly correct,
+ *        spurious whitespace causes parse errors.
+ *
+ * Return: 0 if an argument was successfully converted, or an error code.
+ */
+static ssize_t parse_move_store_input(const char *buf, size_t length,
+				      long *arg0, long *arg1)
+{
+	char *s, *save, *ptr;
+	int ret = 0;
+
+	if (!buf)
+		return -EINVAL;
+
+	s = kstrdup(buf, GFP_KERNEL);
+	if (!s)
+		return -ENOMEM;
+	save = s;
+
+	if (s[length - 1] == '\n') {
+		s[length - 1] = '\0';
+		length--;
+	}
+
+	ptr = strsep(&s, " ");
+	if (!ptr || strcmp(ptr, "") == 0) {
+		ret = 0;
+		goto out;
+	}
+
+	if (*ptr == 'N' || *ptr == 'n')
+		ptr++;
+	ret = kstrtol(ptr, 10, arg0);
+	if (ret < 0)
+		goto out;
+
+	if (s) {
+		if (*s == 'N' || *s == 'n')
+			s++;
+		ret = kstrtol(s, 10, arg1);
+		if (ret < 0)
+			goto out;
+	}
+
+	ret = 0;
+out:
+	kfree(save);
+	return ret;
+}
+
+static bool is_valid_node(int node)
+{
+	int nid;
+
+	for_each_node_state(nid, N_NORMAL_MEMORY) {
+		if (nid == node)
+			return true;
+	}
+	return false;
+}
+
+/*
+ * move_store() - Move objects between nodes.
+ * @s: The cache we are working on.
+ * @buf: String received.
+ * @length: Length of @buf.
+ *
+ * Writes to /sys/kernel/slab/<cache>/move are interpreted as follows:
+ *
+ *  echo "N1" > move       : Move all objects (from all nodes) to node 1.
+ *  echo "N0 N1" > move    : Move all objects from node 0 to node 1.
+ *
+ * 'N' may be omitted:
+ */
+static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
+{
+	long arg0 = -1;
+	long arg1 = -1;
+	int ret;
+
+	ret = parse_move_store_input(buf, length, &arg0, &arg1);
+	if (ret < 0)
+		return -EINVAL;
+
+	if (is_valid_node(arg0) && is_valid_node(arg1))
+		(void)kmem_cache_move(s, arg0, arg1);
+	else if (is_valid_node(arg0))
+		(void)kmem_cache_move_to_node(s, arg0);
+
+	/* FIXME: What should we be returning here? */
+	return length;
+}
+SLAB_ATTR(move);
+#endif	/* CONFIG_SMO_NODE */
+
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -5727,6 +5973,9 @@ static struct attribute *slab_attrs[] = {
 	&reclaim_account_attr.attr,
 	&destroy_by_rcu_attr.attr,
 	&shrink_attr.attr,
+#ifdef CONFIG_SMO_NODE
+	&move_attr.attr,
+#endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
 	&total_objects_attr.attr,
-- 
2.21.0

