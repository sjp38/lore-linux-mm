Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 515E2C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E72AD20851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="ktuyz6Qt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E72AD20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 935258E0011; Thu,  7 Mar 2019 23:15:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BD3B8E0002; Thu,  7 Mar 2019 23:15:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7365B8E0011; Thu,  7 Mar 2019 23:15:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 477398E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:52 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s65so14958492qke.16
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=L214L83KhqUBPr9WyhX49pLHqdAqJvMWalLp9qh2UjE=;
        b=kJMPIY7VOT9lynXStIcn5yvzjxpm9TV4cF+Gp7SCi3pjtJ7xTlHW7HljTT1AVsqpdN
         mHq/9G8Sl9aT1xWAzY/Cx9jZEycYb51pV/9laofJejB+NifhubCSRygdt+wTSUQXTix4
         B2erPKO7Swi8OL19IrnmCv4yYCTESiggR60l09JFYQ2x/LVMR1E8Yq1u2i/3BHPq1C6Q
         0YegIAUj58D1r2N6tLcFagJyb+WERZO5MDLZxuuKJQh3PKm8WAsv4F0/i+oCt3poe+ak
         GYcQUcr4sw682dhSPOznZU5OJsSCJYx86Vadj4LB9GfhoVtACWtvquWqewgafKFNxrvl
         X7Eg==
X-Gm-Message-State: APjAAAU1f2Eyr0k2dDa2Wan0VdLn3Mkou6pz4z4Ti7lAG7UYZPOAAfEO
	5HdSRMSI/6hImPxizgt4cfz31YVByl3o5MV+fWcbGOp/RzESSzJhrnckgBgSIxOlURbFKFC9VaJ
	f2Goj0QPgSf/xt3nU9xgx6tfQ74sRGhpWZ/YkpYAtnplWDuBukK++SOnsNjLVZmA=
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr13548691qtk.175.1552018552037;
        Thu, 07 Mar 2019 20:15:52 -0800 (PST)
X-Google-Smtp-Source: APXvYqyqHemeosG3wOY9klYP7KaVHe8oUd/RzShHGF7EKgTVAZMBu6b9uHwvO6M3sj4ekXEsSvai
X-Received: by 2002:ac8:3f46:: with SMTP id w6mr13548619qtk.175.1552018550426;
        Thu, 07 Mar 2019 20:15:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018550; cv=none;
        d=google.com; s=arc-20160816;
        b=TpO6MMNRGG5xHmvb2Iyh28fTOfAJNx3NuZ/lIkFCUDhyL5wgVusen3V64aK9QTppEy
         eIjSvGXU6Ulb54K0ytNsNxeEP89nKnV9TL+8OV/L5Hqa7yo+VUnvGkFe8RgeI4wMBRmt
         Pzrld4n4cBRnfHNHewku0ZvgARoaJikaa8czE/sQBaDqU1hUpF+Za4sa8PCVbgsTlAlA
         fd84bc6OZRBAA7SdwEzRAYsJcLISpO/aF2M5oSQBCMVLhVMVzoAil8+NdVbMBuNI/dI6
         /rvcG55F93EU1m60RYwKRuT+FjCwWzR29epkTHDkeJz7cYIfHP6KZlI6wZtQLRuZOvX0
         bDAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=L214L83KhqUBPr9WyhX49pLHqdAqJvMWalLp9qh2UjE=;
        b=HMdpZ5bfyPDGDbJ+velCLTtsVlwqKL0NHWX0K76kwl6eA2wNNE8q62vlrILFsRd9CK
         Qxi3GJCbfQ/vedkI4/7qTMeMJIZoILNFMqcsxdw2pGROQBMLsz6hTQ46ZPSuNtADclNZ
         0XOOlaf49VzaghzoRIO+fE8q+rnIGPN6OAVD6COiPFX5pQSo0UaVbbKrfJOIREnQ6ALI
         GmI2fkFxRRA+p+DyASEQ9K/4n9nLDYVgPswqKB9jmb32wocflSExMqqXI+1H+9kk8akp
         /V8GOlCDLvKhV8tSe7lJATFYdXkjc0zHwTrwigHuZKeA8XRoDFbTw6MBsnT9YO/mMMw2
         EAhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ktuyz6Qt;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id z4si40072qvm.216.2019.03.07.20.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:50 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=ktuyz6Qt;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id DE73D36C0;
	Thu,  7 Mar 2019 23:15:48 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:49 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=L214L83KhqUBPr9WyhX49pLHqdAqJvMWalLp9qh2UjE=; b=ktuyz6Qt
	LklEfjHoNGOdFg9jp4yBWv6DHFksCu73Yg0+lqbTTPqJAiy/2UZDLzt+afmR2Vnf
	4nnNz6cJWhOHRlvYrJT5FMVm0q3vclisGDcUBlo4gPEELIdbDZv9HnIZVdGJmU01
	FQMn1bf3pnl6jSn4yOz/5yFB/HHcO8r+dzz6nffcYjEWDBBG97CyHur2W3hfxXLw
	YwTeJNJbDIgV1jG3mBQIpWkkXgWScIf+boOYGB4EBSgdGcDSbU9Fido+us+A/cej
	y7jB9W12mTLQSMnh1yvfCWAoQ/PY++tkBZvOctWX49d216pIm7oxrjcx00uolqrJ
	idBYZp9iC0aZyQ==
X-ME-Sender: <xms:dOyBXOK6T6yZ8WCtzuqBF09IrTjQkiLhsF7nSnkr6dtPvXxPsCj9ZQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepuddv
X-ME-Proxy: <xmx:dOyBXGWUenjeNoIr39R6rX4YbnHbtPLOdwesctsWNNRKxJFmn7I9Cw>
    <xmx:dOyBXAg2evi-LrgdxkIeZMMS2eHn-dod_K8fZIqe3fAtfWNELPbTTw>
    <xmx:dOyBXB-vukEccuhi-SMw6VjdTHOzVu0cACZt5dyS03qZX0fTP6rMpQ>
    <xmx:dOyBXFUKJmdRtD6EVvdnkQAYzQYbmqs9DWQpReD1eORcVnsRVBJ5XQ>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8BC1AE4362;
	Thu,  7 Mar 2019 23:15:45 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 14/15] slub: Enable move _all_ objects to node
Date: Fri,  8 Mar 2019 15:14:25 +1100
Message-Id: <20190308041426.16654-15-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (object migration).
Currently object migration is used to defrag a cache.  On NUMA systems
it would be nice to be able to move objects and control the source and
destination nodes.

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
index 53dd4cb5b5a4..ac9b8f592e10 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4344,6 +4344,106 @@ static void __move(struct page *page, void *scratch, int node)
 	s->migrate(s, vector, count, node, private);
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * kmem_cache_move() - Move _all_ slabs from node to target node.
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
+			__move(page, scratch, target_node);
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
  * __defrag() - Defragment node.
  * @s: cache we are working on.
@@ -4460,6 +4560,32 @@ static unsigned long __defrag(struct kmem_cache *s, int node, int target_node,
 	return n->nr_partial;
 }
 
+#ifdef CONFIG_SMO_NODE
+/*
+ * __move_all_objects_to() - Move all slab objects to node.
+ * @s: The cache we are working on.
+ * @node: The target node to move objects to.
+ *
+ * Attempt to move all slab objects from all nodes to @node.
+ *
+ * Return: The total number of slabs left on emptied nodes.
+ */
+static unsigned long __move_all_objects_to(struct kmem_cache *s, int node)
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
  * kmem_cache_defrag() - Defrag slab caches.
  * @node: The node to defrag or -1 for all nodes.
@@ -5592,6 +5718,126 @@ static ssize_t shrink_store(struct kmem_cache *s,
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
+		(void)__move_all_objects_to(s, arg0);
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
@@ -5716,6 +5962,9 @@ static struct attribute *slab_attrs[] = {
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

