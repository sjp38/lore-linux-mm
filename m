Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BB1FC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E45520851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Qmgo7VSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E45520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1A518E0012; Thu,  7 Mar 2019 23:15:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCC278E0002; Thu,  7 Mar 2019 23:15:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A45F08E0012; Thu,  7 Mar 2019 23:15:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7166B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:55 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id u66so3628406qkf.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C1UFNBfZ1PMvCNxNU0QdAtVm0PxPQxmOQ26CPtV4v/w=;
        b=DTkg+g1yP5eHoJWJXe8s7Aru4TjL97sN8ePZBnN45PeTW4Z1UP0rlipgk/R1pAeZ9h
         H9cc5siGP15XAfQqjSR89oEbGHr91Xw0B7WyqwqeI3jzQ0wAXH2ca/iXtf/33RvYEr5x
         3BRyNctrWE8bdyGbQCh3gEIbSeqO7MnbIH3AZkmYM1fWxGx8WBcbcjpt8fiOOGFzGq83
         VRIK5SS1+7VGAVDk3ovLPXDOMjC8mUGxZ/eREvbLY0n5x20ubZ32MjAHeFqEVrmvSzFY
         ZKktvVzkeEGXOztyItmcOANUCAvAA8qbBXqIy/qzcW4qVzHBiVCFR3fSoVDXIrGwa1i6
         zvjA==
X-Gm-Message-State: APjAAAWEaUG8k9FB/bHY8YpMR8Ed1A7v+C95dv3ZhYuKUoLNEx/jDRlI
	0EBrBFY9W6RhKXaW9pZwmYGU7M8Sk/2mq7xyAou7MrnxoVZWDC2X9XXP/e2icGWeUW57JQU+MnN
	EhGZCd29GT18FXyBxCMUahOcrEb2kxsngkFTbPiAMb4m6kVsfQLJbUt9OyenOxYQ=
X-Received: by 2002:ac8:3774:: with SMTP id p49mr13036312qtb.388.1552018555237;
        Thu, 07 Mar 2019 20:15:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqzptyvHXAxhDIOOijZGn6kDLD9nzvLEERikgOmS+bGI3X3QtmFkmNeKqTA/G5bNZW2wQ5Py
X-Received: by 2002:ac8:3774:: with SMTP id p49mr13036277qtb.388.1552018554296;
        Thu, 07 Mar 2019 20:15:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018554; cv=none;
        d=google.com; s=arc-20160816;
        b=yVgbUejb1qtREN3hZqcPeA4GK5TT2WsMsEu6tgLP0NS4EiddGWa1raaD0FH8OYeyPj
         Hx6bwanCf1xwyJMG/93sjMF6HzedDJGoEOtriqDEvTCApmqIZJCUfVpouIb1Ob7wMD1D
         suNWeQeOVmcRuIQqdKq7BNAn18Hr+MfyxeEPldJVOk2J+JqF1W5Vbb/Kdyk4SYuy1F3m
         ZDm+T9X89nPkj+9RFwxDnnrkrXDMvLfHJhKnh2NG6wIvz4q7TVPNT2Ivr+5UVRUHadRb
         aG98YEjNxftK1nYwMJmEDeY+eGP5N1RSGggIui2+Fsnp9Jq404iuuOJ9zit6+2KS2QKu
         1J5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=C1UFNBfZ1PMvCNxNU0QdAtVm0PxPQxmOQ26CPtV4v/w=;
        b=HWCtEVLx7APx/hw0Ia2+wcfOo0xct54cErFdN8+etqZ2TTF2m30Eq3IVqDKJKVuEMa
         y+D2N25+gCNTfDICyw5iljOJ+nih2Ck0RJ3rPQZ7CWdN4y1co/7mT4q1pPag9uw94c3j
         MZdSe6Kh6W3SzaPuIRKOgWsHBNKb1xhjpjhfzFrAtUKi/8teY3eM2wjo2Hu1YnF2wCwW
         BYASL41y8g7nWKcVANC7lfp4VjLPF2u/NN6AvNF1zZ70YTri/TQcR5u+USQR40vgbP1Y
         i5LZqIFqIxeo2bPMfoBIyJzSAE7VOQJADmbCfs2Gvoi+8uPFnh1TzkjxRwHN7pOnhKFa
         /5KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Qmgo7VSB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id m49si4172790qvm.204.2019.03.07.20.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:54 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Qmgo7VSB;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id D3DC7344B;
	Thu,  7 Mar 2019 23:15:52 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:53 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=C1UFNBfZ1PMvCNxNU0QdAtVm0PxPQxmOQ26CPtV4v/w=; b=Qmgo7VSB
	25Hv9qMlIjQRkzsqOTVGEP5pLcSbpt3DJWN8NWVNcmjDKNpiyIyEtFWdajaruenR
	33v3iwjZWOfl5JkRUIRJC7kJAtaxoxgARgjAq1sufoH46mTMp1QyzGDSsfgqa5O+
	6w+qnrmhq4BO9tyIg4nccAOu0S+AjwSUgNpgIuqfcJ8fTCW664/tarqTE/ut3iGn
	PDO2Xsa0JWcl2TVuPC7cKht8NTrIxwF6mdZUrsCduNPz+y6CojsMKS1qQMo6szLW
	aoGsCaX8wrSfQbcVPagNzwupUVF6poQuujexNn1h9A/qGLh/msC9US0BgBrnwYm4
	zMDmQoMU8kUyiQ==
X-ME-Sender: <xms:eOyBXPurOQTwkP8AG9egnxs-3gU5aP-8JZef8WSS_sat6m_XAaU1Vg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepudeg
X-ME-Proxy: <xmx:eOyBXFFdpEdM1h3tbFwsgeor7IYGiE3xhifLk4MeDOAhEcUnmnHF3A>
    <xmx:eOyBXK4YDy2cIezjiVSvUpT6pIoSva4FlSS4iZtU1rwF_OoL9YjseQ>
    <xmx:eOyBXIXk3rc5QMoBiJCjc3AuwVL_W8l-PS3x1OnU9nXn5Q26hIxMoA>
    <xmx:eOyBXNHnCDk4TdN97Fy1SwrgY_2GiVVIqywcOrrE3Cksv3BdqeXnMw>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id 38D21E4548;
	Thu,  7 Mar 2019 23:15:48 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 15/15] slub: Enable balancing slab objects across nodes
Date: Fri,  8 Mar 2019 15:14:26 +1100
Message-Id: <20190308041426.16654-16-tobin@kernel.org>
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

We have just implemented Slab Movable Objects (SMO).  On NUMA systems
slabs can become unbalanced i.e. many objects on one node while other
nodes have few objects.  Using SMO we can balance the objects across all
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
 mm/slub.c | 115 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 115 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index ac9b8f592e10..65cf305a70c3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4584,6 +4584,104 @@ static unsigned long __move_all_objects_to(struct kmem_cache *s, int node)
 
 	return left;
 }
+
+/*
+ * __move_n_slabs() - Attempt to move 'num' slabs to target_node,
+ * Return: The number of slabs moved or error code.
+ */
+static long __move_n_slabs(struct kmem_cache *s, int node, int target_node,
+			   long num)
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
+			__move(page, scratch, target_node);
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
+ * __balance_nodes_partial() - Balance partial objects.
+ * @s: The cache we are working on.
+ *
+ * Attempt to balance the objects that are in partial slabs evenly
+ * across all nodes.
+ */
+static void __balance_nodes_partial(struct kmem_cache *s)
+{
+	struct kmem_cache_node *n = get_node(s, 0);
+	unsigned long desired_nr_slabs_per_node;
+	unsigned long nr_slabs;
+	int nr_nodes = 0;
+	int nid;
+
+	(void)__move_all_objects_to(s, 0);
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
+		__move_n_slabs(s, 0, nid, desired_nr_slabs_per_node);
+	}
+}
 #endif
 
 /**
@@ -5836,6 +5934,22 @@ static ssize_t move_store(struct kmem_cache *s, const char *buf, size_t length)
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
+		__balance_nodes_partial(s);
+	else
+		return -EINVAL;
+	return length;
+}
+SLAB_ATTR(balance);
 #endif	/* CONFIG_SMO_NODE */
 
 #ifdef CONFIG_NUMA
@@ -5964,6 +6078,7 @@ static struct attribute *slab_attrs[] = {
 	&shrink_attr.attr,
 #ifdef CONFIG_SMO_NODE
 	&move_attr.attr,
+	&balance_attr.attr,
 #endif
 	&slabs_cpu_partial_attr.attr,
 #ifdef CONFIG_SLUB_DEBUG
-- 
2.21.0

