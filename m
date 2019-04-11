Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71303C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 118F42075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 01:35:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="uOGReI6S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 118F42075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9075C6B0006; Wed, 10 Apr 2019 21:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B6D86B0007; Wed, 10 Apr 2019 21:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D6F6B0008; Wed, 10 Apr 2019 21:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53F5E6B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 21:35:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so4122571qtz.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 18:35:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=;
        b=LdgY0geuAtmU0a4FFBloeLMFn8nyhxPGq3WT/zbwqr4IbXJrmFctL479AeNwLJASPq
         zJkYPaIoBINjZAJvD/lgdI7aMWqJkJnzK9VxbMEK9YRUdyk5GjLMbYnqGSVZXMpnNlN8
         g6tYAieh1ciEXRSR9CulpfWuT60DRgJK8XAZEumpcgNDOZXckJcAsjvo6DxounTajvyP
         UV1O/ke/uJJSLqUM7v6xTZnqhftPUJ5tX7NK6K4cMK1NdP3PfdOUFnffdCCeI+x/2oUR
         u3TWD6AdActVEsaQNJn2yfpviPzWUy76TsHiEWCkDfNZ7/RJGOyawIZWcHwsm9yxgxxR
         jA7w==
X-Gm-Message-State: APjAAAVIebri3AnlXLZQ/65z9UpL45vCjSBoyJR00pIDYjYoakuUZW27
	N2rkZPowQ8MXYrKf5KcSE3WSXxmEx2WjlRIk+4pZ8GOWJFqJ+qWxA7S1v5y4dFHhyJ6/YKmfzVk
	K0DqTZ3XoQUXbjNnIIUKYT6b991On3SZlKHcHQskAtNhzd0wB42HedWT1RFBx1fE=
X-Received: by 2002:aed:2507:: with SMTP id v7mr39123466qtc.131.1554946549028;
        Wed, 10 Apr 2019 18:35:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzruZ/3TxbGilEYvWLhpGTue5VnbLgEGhH3ztX0KHqQUUdxYQ7O43ODRlE6b7RL0uc8edqV
X-Received: by 2002:aed:2507:: with SMTP id v7mr39123395qtc.131.1554946547595;
        Wed, 10 Apr 2019 18:35:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554946547; cv=none;
        d=google.com; s=arc-20160816;
        b=emvWeumJMZ4sjr9KY4qPPD9I8YUF7fdiOdcbBKwOk+C9J+F/LA3LMaZ20TNqkKIiG1
         fN70ch7AgvxnG6dmvGQrJGTjYpcpHEvqbTXMZenGAsc7vMjKlnkvNMjRpL3HgxfrO+3r
         TYr/4SP8HhxI+Z54hIbo0XF2oDkd5on9QLe8n7rGrfbJlXlxJ4F3cS1SfDAeWEwjlA6L
         VKSNmLQn7aBKpS3Y28MPXWq4aMReeJVgNH/SX9lzPlIrQoUp7b3+p8/8iG0BqNeYPno4
         z92GiMr+e59rizpxbaj6K8MM0OMF53wI/CUf1Bw6Pe8h+5NqSFXsy+ETwh3kmoMnAwB2
         UVpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=;
        b=twBeoNjoL/7iMiDz72CzwNzvFcmLNF3C3X1pApCmNC8p8W9ce8yQuq13sFXBOJ8mi7
         pgiNzv8C0Cf9vGtai3GXzVRs0beiphXdfTuOqgrWJ2LhT+HAbKt4EYElRD+5QNsQ2/Q5
         nFvbPJ3gA/hFkKBv7TogrTUQhRnFYaqFS6FX9+jM37xXTD6e4+PE/g5/oAS3LZ2LC74d
         C5Wr1EBhUakIzfZEcQhT2hNVvf3dE+Of9NPfxdGRxKBRwxEgB6XOU66OK3pEu/aL7RyY
         ZjBoDkAdV2p2a5SWcrguL8Y2juE3IMa7y92cSnL0Fu5aeTL1EQtjRsgc0ISMEA22o9Gr
         aArA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=uOGReI6S;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id a75si6096017qkb.166.2019.04.10.18.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 18:35:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=uOGReI6S;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 4D04F13FF0;
	Wed, 10 Apr 2019 21:35:47 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Wed, 10 Apr 2019 21:35:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=; b=uOGReI6S
	ys0onALU/h3kW47M6AwIWq2JgRc/lEMak4Ca7PEEtBALSeO4HXaUwLNC04E6/Fvh
	YfhVbeexbKw1VlQJ3zmIluQ7xE0ait8P6aFHrzZJjXgJfgnh7DaqtfjRAdXHrJ4u
	CcODF30Pcpoq6+QwpR8nRq/Y9ShYjCH6JcM2UEqZnovNYjjg/LuQzrBIZivniIez
	uFcdPXW8ygxBrtMjZjcYMNZFlqTxsm4+4Zc/WbkeyZPTUhbRfQLw6WcRxivyumna
	HHYfM7/aMMYv4GXgidZsg3KlRrQ6s0oQWHANlW44htj3vuTurgG1mUEkc4eUxmj9
	q964rRqEXeYI4g==
X-ME-Sender: <xms:85muXGR3mxvmk5gT6JU24AicIswVA_yt_e-VhAGcbgS2VlQ4VGhxSA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudekgdegvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrudelrdduleegnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:85muXGLC2r0mv3tFTpOUjLBevJyLVBMH5NJJ1Dd2rLZgOoimPWG7OA>
    <xmx:85muXJ9v5zvTVaR0xDlH9cM3VDkeEQW3b2oYR0xTMvlWESZuQMQ-_A>
    <xmx:85muXNKEzlN6xw_1vaCrwArGotRfKwg7KDCy3WU3l6Ml63iDyu-WlQ>
    <xmx:85muXMT02W8lE210hBRLxhRbNHmY-KTH4vTUiduibPFJk25xO4REWw>
Received: from eros.localdomain (124-171-19-194.dyn.iinet.net.au [124.171.19.194])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3A32CE408B;
	Wed, 10 Apr 2019 21:35:37 -0400 (EDT)
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
Subject: [RFC PATCH v3 01/15] slub: Add isolate() and migrate() methods
Date: Thu, 11 Apr 2019 11:34:27 +1000
Message-Id: <20190411013441.5415-2-tobin@kernel.org>
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

Add the two methods needed for moving objects and enable the display of
the callbacks via the /sys/kernel/slab interface.

Add documentation explaining the use of these methods and the prototypes
for slab.h. Add functions to setup the callbacks method for a slab
cache.

Add empty functions for SLAB/SLOB. The API is generic so it could be
theoretically implemented for these allocators as well.

Change sysfs 'ctor' field to be 'ops' to contain all the callback
operations defined for a slab cache.  Display the existing 'ctor'
callback in the ops fields contents along with 'isolate' and 'migrate'
callbacks.

Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 include/linux/slab.h     | 70 ++++++++++++++++++++++++++++++++++++++++
 include/linux/slub_def.h |  3 ++
 mm/slub.c                | 59 +++++++++++++++++++++++++++++----
 3 files changed, 126 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9449b19c5f10..886fc130334d 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -154,6 +154,76 @@ void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
 void memcg_deactivate_kmem_caches(struct mem_cgroup *);
 void memcg_destroy_kmem_caches(struct mem_cgroup *);
 
+/*
+ * Function prototypes passed to kmem_cache_setup_mobility() to enable
+ * mobile objects and targeted reclaim in slab caches.
+ */
+
+/**
+ * typedef kmem_cache_isolate_func - Object migration callback function.
+ * @s: The cache we are working on.
+ * @ptr: Pointer to an array of pointers to the objects to isolate.
+ * @nr: Number of objects in @ptr array.
+ *
+ * The purpose of kmem_cache_isolate_func() is to pin each object so that
+ * they cannot be freed until kmem_cache_migrate_func() has processed
+ * them. This may be accomplished by increasing the refcount or setting
+ * a flag.
+ *
+ * The object pointer array passed is also passed to
+ * kmem_cache_migrate_func().  The function may remove objects from the
+ * array by setting pointers to %NULL. This is useful if we can
+ * determine that an object is being freed because
+ * kmem_cache_isolate_func() was called when the subsystem was calling
+ * kmem_cache_free().  In that case it is not necessary to increase the
+ * refcount or specially mark the object because the release of the slab
+ * lock will lead to the immediate freeing of the object.
+ *
+ * Context: Called with locks held so that the slab objects cannot be
+ *          freed.  We are in an atomic context and no slab operations
+ *          may be performed.
+ * Return: A pointer that is passed to the migrate function. If any
+ *         objects cannot be touched at this point then the pointer may
+ *         indicate a failure and then the migration function can simply
+ *         remove the references that were already obtained. The private
+ *         data could be used to track the objects that were already pinned.
+ */
+typedef void *kmem_cache_isolate_func(struct kmem_cache *s, void **ptr, int nr);
+
+/**
+ * typedef kmem_cache_migrate_func - Object migration callback function.
+ * @s: The cache we are working on.
+ * @ptr: Pointer to an array of pointers to the objects to migrate.
+ * @nr: Number of objects in @ptr array.
+ * @node: The NUMA node where the object should be allocated.
+ * @private: The pointer returned by kmem_cache_isolate_func().
+ *
+ * This function is responsible for migrating objects.  Typically, for
+ * each object in the input array you will want to allocate an new
+ * object, copy the original object, update any pointers, and free the
+ * old object.
+ *
+ * After this function returns all pointers to the old object should now
+ * point to the new object.
+ *
+ * Context: Called with no locks held and interrupts enabled.  Sleeping
+ *          is possible.  Any operation may be performed.
+ */
+typedef void kmem_cache_migrate_func(struct kmem_cache *s, void **ptr,
+				     int nr, int node, void *private);
+
+/*
+ * kmem_cache_setup_mobility() is used to setup callbacks for a slab cache.
+ */
+#ifdef CONFIG_SLUB
+void kmem_cache_setup_mobility(struct kmem_cache *, kmem_cache_isolate_func,
+			       kmem_cache_migrate_func);
+#else
+static inline void
+kmem_cache_setup_mobility(struct kmem_cache *s, kmem_cache_isolate_func isolate,
+			  kmem_cache_migrate_func migrate) {}
+#endif
+
 /*
  * Please use this macro to create slab caches. Simply specify the
  * name of the structure and maybe some flags that are listed above.
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2153789bd9f..2879a2f5f8eb 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -99,6 +99,9 @@ struct kmem_cache {
 	gfp_t allocflags;	/* gfp flags to use on each alloc */
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
+	kmem_cache_isolate_func *isolate;
+	kmem_cache_migrate_func *migrate;
+
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
 	unsigned int red_left_pad;	/* Left redzone padding size */
diff --git a/mm/slub.c b/mm/slub.c
index d30ede89f4a6..ae44d640b8c1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4326,6 +4326,33 @@ int __kmem_cache_create(struct kmem_cache *s, slab_flags_t flags)
 	return err;
 }
 
+void kmem_cache_setup_mobility(struct kmem_cache *s,
+			       kmem_cache_isolate_func isolate,
+			       kmem_cache_migrate_func migrate)
+{
+	/*
+	 * Mobile objects must have a ctor otherwise the object may be
+	 * in an undefined state on allocation.  Since the object may
+	 * need to be inspected by the migration function at any time
+	 * after allocation we must ensure that the object always has a
+	 * defined state.
+	 */
+	if (!s->ctor) {
+		pr_err("%s: require constructor to setup mobility\n", s->name);
+		return;
+	}
+
+	s->isolate = isolate;
+	s->migrate = migrate;
+
+	/*
+	 * Sadly serialization requirements currently mean that we have
+	 * to disable fast cmpxchg based processing.
+	 */
+	s->flags &= ~__CMPXCHG_DOUBLE;
+}
+EXPORT_SYMBOL(kmem_cache_setup_mobility);
+
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, unsigned long caller)
 {
 	struct kmem_cache *s;
@@ -5010,13 +5037,33 @@ static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 }
 SLAB_ATTR(cpu_partial);
 
-static ssize_t ctor_show(struct kmem_cache *s, char *buf)
+static int op_show(char *buf, const char *txt, unsigned long addr)
 {
-	if (!s->ctor)
-		return 0;
-	return sprintf(buf, "%pS\n", s->ctor);
+	int x = 0;
+
+	x += sprintf(buf, "%s : ", txt);
+	x += sprint_symbol(buf + x, addr);
+	x += sprintf(buf + x, "\n");
+
+	return x;
+}
+
+static ssize_t ops_show(struct kmem_cache *s, char *buf)
+{
+	int x = 0;
+
+	if (s->ctor)
+		x += op_show(buf + x, "ctor", (unsigned long)s->ctor);
+
+	if (s->isolate)
+		x += op_show(buf + x, "isolate", (unsigned long)s->isolate);
+
+	if (s->migrate)
+		x += op_show(buf + x, "migrate", (unsigned long)s->migrate);
+
+	return x;
 }
-SLAB_ATTR_RO(ctor);
+SLAB_ATTR_RO(ops);
 
 static ssize_t aliases_show(struct kmem_cache *s, char *buf)
 {
@@ -5429,7 +5476,7 @@ static struct attribute *slab_attrs[] = {
 	&objects_partial_attr.attr,
 	&partial_attr.attr,
 	&cpu_slabs_attr.attr,
-	&ctor_attr.attr,
+	&ops_attr.attr,
 	&aliases_attr.attr,
 	&align_attr.attr,
 	&hwcache_align_attr.attr,
-- 
2.21.0

