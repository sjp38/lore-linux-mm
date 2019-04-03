Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13645C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:22:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A08EF2084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:22:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="I/Ui5km2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A08EF2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 449D76B026F; Wed,  3 Apr 2019 00:22:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 421C16B0272; Wed,  3 Apr 2019 00:22:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3129C6B0274; Wed,  3 Apr 2019 00:22:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 127AB6B026F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:22:53 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p26so15548919qtq.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:22:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=;
        b=YbPb9BG3D34xOX8lhpj1L5Ewgkjm6AIc0X1E5SrQJjo3J8yifOLIkRJH0PbWQXIE8+
         zhdnbAjMamQ/ZRXmzWC1UabGNi8eZXc/gYFNcuOfavt53f3AwSgSwOb9J0Cfs6XCwC54
         5CdpErm+jdEDj/YlQv/WhEhCManHanfmskEEOP8LTubjAghM2OTBcuiCVBA824H/Z+vI
         gldUrnVrg6HM7hFwEHWtU+YMD2u6ETMV2atVdGAWZJsdD4W022z//y2kK6PjR7L4DuDT
         4Pon+bhawHTPufwhhav1KYw440tboIM2S3U3q4Ao4a8xW8p8MYkqac3glqVT++BKFUAa
         8oxg==
X-Gm-Message-State: APjAAAVoOKdtqngOCNzauNyEV1Vzq+mmkB7BjMDXWdqaDBKAB9DIWzjj
	T1nB2AY1aXw4fSDyKwDj4fL4mBtDxNyijdJWtX9aasXqvwiAs3Rk05fsWhf5LkiS1giEYzT6TiL
	xW+36onu1b4PvYhrtnb5bhEHcMhb7Qxtlz/YBFxk7Dy8gx/ddjNC53e2L25zkJYQ=
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr28089913qvf.10.1554265372800;
        Tue, 02 Apr 2019 21:22:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl27u43friSBtI/4bQ28lq12bQ3dV4XhYvbDVdUM/qP7eNnD5GaqBnLmmYl0kUiepMdVXY
X-Received: by 2002:a0c:b99c:: with SMTP id v28mr28089880qvf.10.1554265371696;
        Tue, 02 Apr 2019 21:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554265371; cv=none;
        d=google.com; s=arc-20160816;
        b=Nj4HZgu/kJ7I873A6uGNbnmTGFMgoZcjCJuvcVfjKPIl1cHgyR6mP8V12uIn8OpyBR
         epB0hVhqa1qJlUo2fjq1rEK35pn2Em4BmgBKfXKlu8tJchrIBHQj+Cg2qjnkdFUG6AW+
         1WhwPT/4H0yjDn6UiIuhrzbicDD5Me1JRRKPzwS6J5VoBCdP3KgA+LQiN16HavOdwS5r
         bL6Xzoxh7gxBaR/p5ngOa5p32scz2oX//51bfIl28z/3ImvOP/lbT40gCKP5JXgF5oH9
         lA0XN2dD7hWFDFdhhskeIuq+6V6iNSbeyrGWdZCfMrvYhY+QLWbcpdo7VwGp8n8ofcmy
         GvFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=;
        b=ESuD7kfYCcl727sd3sZUURj4W70I6aJBmrS3RYt2wCn33kBnKlJzhvXlty4MW0mG5o
         cA7d0sqOtbCqJMZ2NUe0UcZAzDx8PaJ9oevEwqRWD+AIhLwTZJOcu6WnjXYsUYdST60/
         vtlawi4WdX27sU9tzDOjQTqDGe7+Zkk57XAUsOJWmym4Ys+5vlmoZ76av40iv/7PNT79
         V85Tynpgg0x95QlUKRqztOfp9QJM0erQBjdm9e9QnvRB/Az0O1E7FK+NTu3Hz3Kkzvlr
         MJ9J672HZeP0z4qCvnTJ4WgXAN2fsWwf0tqpzQFW6Bq3uvTLrYEE1s3j1jqPejIQ0zyM
         2OWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="I/Ui5km2";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id m8si523769qte.391.2019.04.02.21.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:22:51 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) client-ip=66.111.4.28;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b="I/Ui5km2";
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.28 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6768821908;
	Wed,  3 Apr 2019 00:22:51 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 00:22:51 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=ToWY0R45y8BHjmAdWxteY+oDuIkdik3lI8PSNGM4h2M=; b=I/Ui5km2
	fzUg9Gk9NdXhf11L7d39CpWXho85pgZB3EdjjtN9gRTTuxOVubTuvbpUmRBh84Ee
	TbLt9X12k2w2Ck5Y6ubD9qYTYuDf2PxVW/jlY37hiNQGUXii1W8TgHdYHuLQ5Kx8
	2LPMvlFeI+bhIf54SrVprANJinvsUSTzHqMoOX6nf+H9qwfddHnwxfZhIxFcyAAo
	Zp9Ub5B3DOqc8g8MtltyXnY31R084eF33UB9lFNI+j0L0NRniqVo7Faort+zO+uh
	WLiWoR1QQCZWQaP9KSdayPpDRWjff/WRnkIDd3NNwLqAMaEVKqkJzUlbpj72zC8r
	m8YEo78EAkmftA==
X-ME-Sender: <xms:GzWkXBVYnLTGd06HjDNcA4r-lxNfksChskoHE_27oKDENFRybGZNPQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdektdculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedt
X-ME-Proxy: <xmx:GzWkXHnWEqBg2vlr9BHQicjoIM2dSAkUwELpxfTzmFUgGZNLpGlaUQ>
    <xmx:GzWkXINwAk41R8_f25AKPsX9ISDUN7EQ3VuHDteLqDTc4ANaNyKp4Q>
    <xmx:GzWkXHKqVX0yOj9VxirWtUlW51iRbaKmHiBAuJ5zKDBeC0bKxP8d9Q>
    <xmx:GzWkXFs0iUmghMCF9QPlZnyfcuFYDFW-iBZH70OIQ4dxxvLxnMY-OA>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 6A7E1100E5;
	Wed,  3 Apr 2019 00:22:44 -0400 (EDT)
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
Subject: [RFC PATCH v2 01/14] slub: Add isolate() and migrate() methods
Date: Wed,  3 Apr 2019 15:21:14 +1100
Message-Id: <20190403042127.18755-2-tobin@kernel.org>
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

