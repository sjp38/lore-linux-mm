Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64C23C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 183D22147A
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:10:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Mz0JYE8q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 183D22147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE8096B0288; Mon, 29 Apr 2019 23:10:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBE276B028A; Mon, 29 Apr 2019 23:10:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A88416B0288; Mon, 29 Apr 2019 23:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 89BCE6B0288
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:10:38 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id a12so10767484qkb.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:10:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AtTOS3tLSFxiBVY6HKqiEZQDmJwYtvFPI1Eb7X0+v6o=;
        b=o7VIEU2QXX5t3MH2ksZYHV0fYVL8qWN8AQy2+MtFTU+pcEq6Hfp9v2W3x0mq5jBJ8Q
         qpOSvr9JeCGVOqyFFfUyUk7g91PvesWpFTVL0OWwwNGIvcxt8XTY2Q5YQsJNiTLFkpp9
         XOJyNPXcHpTHpR5gPh3+z9GE6eEebhijgxywRpYyAlhN0NzVrvU0T23mZ+sGGK3z7sX/
         adnyMzQg+t898ijyCx6Hygig8p1/8wE3mkbxN0Pu0sctkEtWBQYnm3u13AcQ704fvPFX
         e2XpKYFE4lc2vLJPu1vfF6DtBUYdpp5M7BFAsChv6iEMIYDJiXZquGmbAZ+IB1S4jbgB
         gFIA==
X-Gm-Message-State: APjAAAVTOFmzIeMiMdMsZYSkGdru+JSgWn8hhAwOeQq+L9iKSjbTwHEm
	Mn61tnO0f4o4WvFaQ26Db13XDIlSIeCAWZycfajtCJPelzcabz9r2CApdYuP2zL1cOUMTUDhl2U
	xCUZPgvXixSOoJLcxRu6Ppb033gSz6V9RAGttzdsahwTG5aXUMWrZNM7WRLXhB2k=
X-Received: by 2002:a0c:87bb:: with SMTP id 56mr13722537qvj.219.1556593838305;
        Mon, 29 Apr 2019 20:10:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3Av/a9DG8OEdW/2JETZt8rPiwwrsrcCnB6Bqh+E6Kxzc9zhWMBz+1NGz+qDdVEJe6U6Fz
X-Received: by 2002:a0c:87bb:: with SMTP id 56mr13722498qvj.219.1556593837127;
        Mon, 29 Apr 2019 20:10:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556593837; cv=none;
        d=google.com; s=arc-20160816;
        b=GZUQE1D7C9BhVV5QDogbxG1K9EXeJ8vUVvCVFKZcPHVspB6JbDdAC4r/L/cotJtvVt
         i8+INGOMGq0pI+nqyTu6dAjdgLljYYFFhj8AiIiI+Ln12wSLxy/DQBYA+ZuXuyRUBo7A
         9s+QOc9SSXrVov7bwS4tPJ0EjoZBNUwA/yRZFvDtk1aKytxBxPUgriDB1qYGggyclp3/
         5WiL9ENTcZQekDtnYvzkjTPqTpKMeCPD2yoEgKC4Z2zF05G7drqXRQWtA48YC9sZM3nb
         bs0LVh+LzVPBZScq9cejeh3s9+618EYR/IPNFuALLx0FaAW/RPB+bJY24oC4EbXeqT9B
         bZqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=AtTOS3tLSFxiBVY6HKqiEZQDmJwYtvFPI1Eb7X0+v6o=;
        b=bI5liHV7ECLq5obXitzF8lX3+DS5cAm1nkk3thpQ2bmGzhkzEeH7F6CUe9AXoxHjw0
         Vnb7jXjGJeN7Vu0o1toxPzjdXPHo8HWgptKLLe2fSmy9CxTb/LfbOkl/xrA42rEykuid
         8i5tL0+HDPY3cOpdV29iVyKK87Gpyfjuu95/Xh1hp5/HLLhvc/v+8zcn6Cul0y7tUljI
         FPm5zLgzJzykDMaG57Jpwp0NhfXCnG6tUX9/8OvNha5JtJQySx++WKP0Bzg5evGn1hFq
         edEiuvAq+7tThgbRrFZgOrFH7z8idle+yq45mH7ByjOolKbbdefQH3Nob78CqEm4+tlO
         fy9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Mz0JYE8q;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id k8si6530946qvj.219.2019.04.29.20.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 20:10:37 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=Mz0JYE8q;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.221 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id D25E41489D;
	Mon, 29 Apr 2019 23:10:36 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 29 Apr 2019 23:10:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=AtTOS3tLSFxiBVY6HKqiEZQDmJwYtvFPI1Eb7X0+v6o=; b=Mz0JYE8q
	6mfgLxTsFaZvnrjTOzIU1K9OLF5xaipxeaIRg07vVAIGydkzG41j0c9cIjAaqfPu
	suuks90VIcxBWrW8xNvU/djcyBGQwdRU8LhIOmphBHp/qUEnucLkh9SU3+9ZrL3d
	v86+RFNKYWgLRshebiLPhu1k9CgZjaQD1CV3uvfH9jdUJwTpHIVG5GyAVb5fJUDT
	JmLxKIFRmxu8gZGpBn9e4PvBsthjqhArLsJfe0HayxvLV9XjrLsyETpCi35zzCbV
	1SPFpp+quxv5q+CrN0Tuy0K7BDEPf39g70zWVvBkBJXP2T0/7SihlY93d07n60Fm
	ApjoRKAP/cCWfA==
X-ME-Sender: <xms:rLzHXKOfqlGrWL8S2WhTKZLl5kxzbCQBIBWcW0smEu6avfPMdN87ig>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrieefgdeilecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvuddrgeegrddvfedtrddukeeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:rLzHXN4f46LGtTZJ7txwKxUIN2IAa7-SpRP9xEMQWgVAxIOQdxpRqw>
    <xmx:rLzHXFg1fs8qluDrz4RrsCEPUamfhH31RF5O25uIMecJ7xu9eAv55Q>
    <xmx:rLzHXKd8a0vMcvXbK2N8oG86vGehKVwfd_MuQHLZY0znoVAMei6pLg>
    <xmx:rLzHXLOmS5-J877V7vApJD0H0THHYtSFeeGb_EMyQgotvz9UJ95g_g>
Received: from eros.localdomain (ppp121-44-230-188.bras2.syd2.internode.on.net [121.44.230.188])
	by mail.messagingengine.com (Postfix) with ESMTPA id 24FE9103C8;
	Mon, 29 Apr 2019 23:10:28 -0400 (EDT)
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
Subject: [RFC PATCH v4 14/15] dcache: Implement partial shrink via Slab Movable Objects
Date: Tue, 30 Apr 2019 13:07:45 +1000
Message-Id: <20190430030746.26102-15-tobin@kernel.org>
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

The dentry slab cache is susceptible to internal fragmentation.  Now
that we have Slab Movable Objects we can attempt to defragment the
dcache.  Dentry objects are inherently _not_ relocatable however under
some conditions they can be free'd.  This is the same as shrinking the
dcache but instead of shrinking the whole cache we only attempt to free
those objects that are located in partially full slab pages.  There is
no guarantee that this will reduce the memory usage of the system, it is
a compromise between fragmented memory and total cache shrinkage with
the hope that some memory pressure can be alleviated.

This is implemented using the newly added Slab Movable Objects
infrastructure.  The dcache 'migration' function is intentionally _not_
called 'd_migrate' because we only free, we do not migrate.  Call it
'd_partial_shrink' to make explicit that no reallocation is done.

Implement isolate and 'migrate' functions for the dentry slab cache.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 fs/dcache.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 3d6cc06eca56..3f9daba1cc78 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -30,6 +30,7 @@
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
 #include <linux/list_lru.h>
+#include <linux/backing-dev.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -3067,6 +3068,79 @@ void d_tmpfile(struct dentry *dentry, struct inode *inode)
 }
 EXPORT_SYMBOL(d_tmpfile);
 
+/*
+ * d_isolate() - Dentry isolation callback function.
+ * @s: The dentry cache.
+ * @v: Vector of pointers to the objects to isolate.
+ * @nr: Number of objects in @v.
+ *
+ * The slab allocator is holding off frees. We can safely examine
+ * the object without the danger of it vanishing from under us.
+ */
+static void *d_isolate(struct kmem_cache *s, void **v, int nr)
+{
+	struct list_head *dispose;
+	struct dentry *dentry;
+	int i;
+
+	dispose = kmalloc(sizeof(*dispose), GFP_KERNEL);
+	if (!dispose)
+		return NULL;
+
+	INIT_LIST_HEAD(dispose);
+
+	for (i = 0; i < nr; i++) {
+		dentry = v[i];
+		spin_lock(&dentry->d_lock);
+
+		if (dentry->d_lockref.count > 0 ||
+		    dentry->d_flags & DCACHE_SHRINK_LIST) {
+			spin_unlock(&dentry->d_lock);
+			continue;
+		}
+
+		if (dentry->d_flags & DCACHE_LRU_LIST)
+			d_lru_del(dentry);
+
+		d_shrink_add(dentry, dispose);
+		spin_unlock(&dentry->d_lock);
+	}
+
+	return dispose;
+}
+
+/*
+ * d_partial_shrink() - Dentry migration callback function.
+ * @s: The dentry cache.
+ * @_unused: We do not access the vector.
+ * @__unused: No need for length of vector.
+ * @___unused: We do not do any allocation.
+ * @private: list_head pointer representing the shrink list.
+ *
+ * Dispose of the shrink list created during isolation function.
+ *
+ * Dentry objects can _not_ be relocated and shrinking the whole dcache
+ * can be expensive.  This is an effort to free dentry objects that are
+ * stopping slab pages from being free'd without clearing the whole dcache.
+ *
+ * This callback is called from the SLUB allocator object migration
+ * infrastructure in attempt to free up slab pages by freeing dentry
+ * objects from partially full slabs.
+ */
+static void d_partial_shrink(struct kmem_cache *s, void **_unused, int __unused,
+			     int ___unused, void *private)
+{
+	struct list_head *dispose = private;
+
+	if (!private)		/* kmalloc error during isolate. */
+		return;
+
+	if (!list_empty(dispose))
+		shrink_dentry_list(dispose);
+
+	kfree(private);
+}
+
 static __initdata unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
@@ -3112,6 +3186,8 @@ static void __init dcache_init(void)
 					   sizeof_field(struct dentry, d_iname),
 					   dcache_ctor);
 
+	kmem_cache_setup_mobility(dentry_cache, d_isolate, d_partial_shrink);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
-- 
2.21.0

