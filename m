Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59633C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B7F120851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 04:15:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="5HYCTy6Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B7F120851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B07918E0007; Thu,  7 Mar 2019 23:15:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7FA8E0002; Thu,  7 Mar 2019 23:15:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 980D88E0007; Thu,  7 Mar 2019 23:15:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7838E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 23:15:16 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 35so17518473qtq.5
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 20:15:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JsjE/DB7CgND14aqwEzfQQRvORRnlRv5KuF04km8r4g=;
        b=JZkaVz+lv6gP6HWmAocjemJ42+nbo2Uka5XzFjVYo5XHRy2aDd7ADxak9KsOqq+O/Y
         d6K8/nzG/k/7tpNUrjfwjryfrbFdEqo6Jw3pcbHnetY/s0aMTCXPtZquvKI4JBzMDVOW
         ZfrOOslOLyCdGeWlowbxeE7QM4CljTuMix/8+50B8F6ApPcjnw52Zmd8dKRYupbkJ0du
         2/pxtgXwHQsYVn9WIzLRYjvvclSQj8xZ2mvtBMfejCbXQlvHIR+Y6fDXXLlXehuRrA7d
         TGYy34Nh/nRsxXjqtBxGpFG0oY/FDuu8U1mKYQnOm6W601q0JAh4RyYPa/66qNY57cPS
         YgXA==
X-Gm-Message-State: APjAAAWjmnkXPQfOSOMDfM2KgIAWoDaT5sKZ476vzTLs76t+yFHvLUai
	XJVFmXbRcrXmW/Ev9xiWEZYVq4ezUrUwH2CI9aUgZslPxFME03MPBMYJY3ehtNS6eaH18BGZMT2
	kfUr7xPNCFnqM7QuZu1X2g/crB5+FDcYlI09y071pnigulVjPgyL3lbopWAsxGqw=
X-Received: by 2002:a37:4e58:: with SMTP id c85mr12898670qkb.89.1552018516166;
        Thu, 07 Mar 2019 20:15:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqwZnZgR52PBFcXIRF6Iu6muaLBKduodd7AkV3fDTnrydsfjWGJKTZ2CPyJ0YX7LGSi/vSJ5
X-Received: by 2002:a37:4e58:: with SMTP id c85mr12898617qkb.89.1552018514722;
        Thu, 07 Mar 2019 20:15:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552018514; cv=none;
        d=google.com; s=arc-20160816;
        b=dzIweopGXQxrAIIpYcKQsvK72+1YtQ7r5KdAyqQVYCfL4qb6ZHLtkxJYgRRuAirFdq
         FZy/sPbaNG2VEQd4jN/2lHjVKBrcd/k7u0OQaB5sa1Wm2EnCV5itcAwEcUNCOBPF4vZd
         ptnXNeNunctjm0ZqMKVvx6423c7E+9pddw5kqDUeSe/s3o2SpADPs21F4Wyv8Tlzhjbr
         b+mflxw4hNIEZZcwbWzpUJCJwSlvbl6h9FmTAGn4S3xhmuzAQdBFkJx8mQk2guHhwYRR
         oRiA4sGwS7vgmxiLkDVGqX3yP0waetDC1gKOIywZAcvNq9qdBciCLgTPI4q/ror7Pa1h
         QB9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JsjE/DB7CgND14aqwEzfQQRvORRnlRv5KuF04km8r4g=;
        b=nZbXIoj3r/C23123T5sTzBmuFunYN7m979BiDSZDLWmSUjhxfIFRigBAXLv3lzk5sw
         pB0n3kJIeqe4ytUAZrh+/7OKUACgYs5RxJ+qnKIIwGJIdyE6sxUy088XhJtVUcLkPIGN
         RawHbkUDuACSawkM7HEXhs5YuZfFrXb8eLXphBOqqJndVG5EqnZ57ODXlKuSLaPSuANY
         oih7HdhY8cwkJFfgFpNK5vr1aiJ3FeUFrhpjtGbQ/tnPLdD3zroloFFifGlkbBYVRkKb
         ZrHBefTdcBCXfHqJuBg8hh8U+m9YM6IhCvAsJQ5vIwwQVG76T49tlxHm4f3vhV5sbG8J
         kv4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5HYCTy6Q;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id r47si4132237qte.237.2019.03.07.20.15.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 20:15:14 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5HYCTy6Q;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 64.147.123.25 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.west.internal (Postfix) with ESMTP id 46DC2344B;
	Thu,  7 Mar 2019 23:15:13 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Thu, 07 Mar 2019 23:15:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=JsjE/DB7CgND14aqwEzfQQRvORRnlRv5KuF04km8r4g=; b=5HYCTy6Q
	SrpVPWr/y+ND4NM8vTUOx2ewIo94P8eltVKp2IISnKwCwKGZpS7bBcL5LhXseLEf
	BFc3fPcknZqqUCRxQLGeyeIJH8jV82MMXd68wn5ZyBCjgOSNxyxN6s66vpg8kN6+
	9N5SlPIlYPUa0n+55Rw1mG5uewIztNB24PdDIsi9uZ1R6N4mXIK3gsY+7ylL4XZ9
	mcwf7Y6iJ/qdj45+nd8XdsDgTPCC85svuHWJsVwblWMXRu17KzS6Fonpednchwzj
	CssUz1rmk/3sOkyr1qd7/tJh+ALGFCfejcKwQ1Ns50O9P+QeCATwIj85kM11HrmN
	UmDYJba33ioUWQ==
X-ME-Sender: <xms:UOyBXJ-vpX7X9ZFa0mQKkveizclr0CW4dj0DV-h98tM6aHYWHsaiOw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrfeelgdeifecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudeiledrhedrudehkeenucfrrghrrghmpehmrghilhhfrhhomhepthhosghi
    nheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgepvd
X-ME-Proxy: <xmx:UOyBXPTdlsN7t1M6OwkaV7SuR43XoemkdTkjad_kTS-gaMKODTYFgg>
    <xmx:UOyBXGRPIE5V-OHnFl50fCvBkP6fnejxg8ljXUvUvTdVOvRbYxXH_A>
    <xmx:UOyBXD53RF56hdvw_xduML2C7WYaI6Oae5pZvDrE9Xvk-LYeF2HA7A>
    <xmx:UOyBXOCGLMrGWXXV7Eh4AzC4XNnqcQNl2Bon-NOil2xPN_tQlFvGyA>
Received: from eros.localdomain (124-169-5-158.dyn.iinet.net.au [124.169.5.158])
	by mail.messagingengine.com (Postfix) with ESMTPA id EA496E4481;
	Thu,  7 Mar 2019 23:15:09 -0500 (EST)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC 04/15] slub: Enable Slab Movable Objects (SMO)
Date: Fri,  8 Mar 2019 15:14:15 +1100
Message-Id: <20190308041426.16654-5-tobin@kernel.org>
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

We have now in place a mechanism for adding callbacks to a cache in
order to be able to implement object migration.

Add a function __move() that implements SMO by moving all objects in a
slab page using the isolate/migrate callback methods.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slub.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 0133168d1089..6ce866b420f1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4325,6 +4325,91 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
 	return err;
 }
 
+/*
+ * Allocate a slab scratch space that is sufficient to keep pointers to
+ * individual objects for all objects in cache and also a bitmap for the
+ * objects (used to mark which objects are active).
+ */
+static inline void *alloc_scratch(struct kmem_cache *s)
+{
+	unsigned int size = oo_objects(s->max);
+
+	return kmalloc(size * sizeof(void *) +
+		       BITS_TO_LONGS(size) * sizeof(unsigned long),
+		       GFP_KERNEL);
+}
+
+/*
+ * __move() - Move all objects in the given slab.
+ * @page: The slab we are working on.
+ * @scratch: Pointer to scratch space.
+ * @node: The target node to move objects to.
+ *
+ * If the target node is not the current node then the object is moved
+ * to the target node.  If the target node is the current node then this
+ * is an effective way of defragmentation since the current slab page
+ * with its object is exempt from allocation.
+ */
+static void __move(struct page *page, void *scratch, int node)
+{
+	unsigned long objects;
+	struct kmem_cache *s;
+	unsigned long flags;
+	unsigned long *map;
+	void *private;
+	int count;
+	void *p;
+	void **vector = scratch;
+	void *addr = page_address(page);
+
+	local_irq_save(flags);
+	slab_lock(page);
+
+	BUG_ON(!PageSlab(page)); /* Must be s slab page */
+	BUG_ON(!page->frozen);	 /* Slab must have been frozen earlier */
+
+	s = page->slab_cache;
+	objects = page->objects;
+	map = scratch + objects * sizeof(void **);
+
+	/* Determine used objects */
+	bitmap_fill(map, objects);
+	for (p = page->freelist; p; p = get_freepointer(s, p))
+		__clear_bit(slab_index(p, s, addr), map);
+
+	/* Build vector of pointers to objects */
+	count = 0;
+	memset(vector, 0, objects * sizeof(void **));
+	for_each_object(p, s, addr, objects)
+		if (test_bit(slab_index(p, s, addr), map))
+			vector[count++] = p;
+
+	if (s->isolate)
+		private = s->isolate(s, vector, count);
+	else
+		/* Objects do not need to be isolated */
+		private = NULL;
+
+	/*
+	 * Pinned the objects. Now we can drop the slab lock. The slab
+	 * is frozen so it cannot vanish from under us nor will
+	 * allocations be performed on the slab. However, unlocking the
+	 * slab will allow concurrent slab_frees to proceed. So the
+	 * subsystem must have a way to tell from the content of the
+	 * object that it was freed.
+	 *
+	 * If neither RCU nor ctor is being used then the object may be
+	 * modified by the allocator after being freed which may disrupt
+	 * the ability of the migrate function to tell if the object is
+	 * free or not.
+	 */
+	slab_unlock(page);
+	local_irq_restore(flags);
+
+	/* Perform callback to move the objects */
+	s->migrate(s, vector, count, node, private);
+}
+
 void kmem_cache_setup_mobility(struct kmem_cache *s,
 			       kmem_cache_isolate_func isolate,
 			       kmem_cache_migrate_func migrate)
-- 
2.21.0

