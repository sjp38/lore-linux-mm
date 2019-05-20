Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72F92C04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28D15206B6
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:42:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kc0kWlJs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28D15206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B767F6B0269; Mon, 20 May 2019 01:42:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B263E6B026A; Mon, 20 May 2019 01:42:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A159B6B026B; Mon, 20 May 2019 01:42:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 836286B0269
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:42:24 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b46so13233652qte.6
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:42:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=US5HWl6Yr+o7Tqlb3g83eU3pKx3YxwNaogU4TX1LtRs=;
        b=Bar/2Ns0A9o5SW3o/3Z83fI6RERJV45TFObZL2eHbqHfwRv+oYimfyTElLwVDd/8yy
         kD2k6r2/6yOuv9pCSZJbU0k5+BaPo3N/TVq4r5AyI508VUixjiOuWTDZNIE5P9K4V6l1
         uUqMk+yLe/k369uYum1ZADczT5rSDTQ353NGZrNaT3jIydCBmYIp3isfn/bmBjPJ0Yyj
         7v9UpfvEAI4HeDeiMqos898bDyOJheFcctGNWTrEULmU84sepsHb0qi8a2SuvIbRO4tI
         TOdgkO1iP+LyKuRQeWEoA3pxRJ3br1ILGyS1ZwK5QP5Kt9aXkXxpsAvJIHiQfgnzjI+6
         IiIA==
X-Gm-Message-State: APjAAAWoFnBLYEWkKx/3h+RAokf5fI6GczW97B5ugnnZexJnLpZDwEvQ
	aIWoOF/ynypILzr+Eu94VyAQ/SOcfI0ddJBJlGJEIgzCIgEsZiWobp0iZWvbBuktGmuBn2xW2Th
	6ZwCHOooM+f5D1G0/bVe9+imstlJbS5qtm4EjSENRVstj3ALquh0AW9HBamKv0Ow=
X-Received: by 2002:a0c:98ab:: with SMTP id f40mr50984249qvd.177.1558330944302;
        Sun, 19 May 2019 22:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK20FjSDoudI30XPA0naBBiCs9xA/SkhF7QzQlv4Aq6L/bHuHJqfcc0oOblPh5toHTcoae
X-Received: by 2002:a0c:98ab:: with SMTP id f40mr50984197qvd.177.1558330943297;
        Sun, 19 May 2019 22:42:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558330943; cv=none;
        d=google.com; s=arc-20160816;
        b=hhWvvzosXEmSejY3Z8H+xJjvr+5RfWgdn2ZlP1h3cYl4rCjuWXhA+icoWY4LGm3G6G
         PEsfym2JwA+lJ/y++osO1OeJrLENQtlWAXjXcsXOVvUJRBTaBdIsnNyDq3vzYJ/lHjXQ
         w5i1ftDrfiHXjJb8uR++sF6mO4FN8eFTpie72hFvMwW2fplAMGxpWwTY5127Hszr9/Bt
         jjN8jczRN1k4CYr3JX8BTDV0r7qBGeYTSTn/pkZZKzVdX6zlxPTrujS2BY1j0cH0sXrf
         8peD/B+qrZ4JmYeyBO3r240vS96+mPUHmU0HPAbrGyO5PwySFC2UbdFfaP1ytdfx9opK
         OfGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=US5HWl6Yr+o7Tqlb3g83eU3pKx3YxwNaogU4TX1LtRs=;
        b=qFEH7Ln093Drap+F/e7qOxIPSTI0cdlPdG24xtkaUVXUkyDOO0crS63OBzTB3NClgI
         zyIGHd+fVRy39gtbdzzEa3w/3uU3CefdfEdfDBNErDFWbZFFdJCbTdgz1CLueU+thjy1
         h3py3XJ8i3gDEeRWUrYkZnyvfy/21h4RY7+AoTVU9ZwdZsuYesaaaH6KMlwBvgnPoRBl
         +qnXaowdgORr4PveLOCWunUeHBaC3xllg2R28ueLUDUyrNQm/XPhHX6DW8PB43tT98cH
         PiCRQuttHluHsoaJSRNeElHbK/Fx1kWcyJqTkweLIVUEwqmOsn0TyvSc5rToDWrVmHQa
         2kxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kc0kWlJs;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com. [66.111.4.230])
        by mx.google.com with ESMTPS id s92si3604756qtd.48.2019.05.19.22.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 22:42:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) client-ip=66.111.4.230;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=kc0kWlJs;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.230 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailnew.nyi.internal (Postfix) with ESMTP id 045C9BC13;
	Mon, 20 May 2019 01:42:23 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute3.internal (MEProxy); Mon, 20 May 2019 01:42:23 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=US5HWl6Yr+o7Tqlb3g83eU3pKx3YxwNaogU4TX1LtRs=; b=kc0kWlJs
	0NmjnfFnQi6LJk07eViEaoQIS4EmoXA3ywM5OjQF4mkY8O/fnqPxMiPO4eJ8GufP
	9CEETvaMZ5OeCvk7DNGRQS4MdzhgMBOx9/f6mwIBOaRjjW0gsGAba7cI/Vj+rkCH
	dqdNfbqvrGDv5OgqZmFlGxGS90D2eESO0qDO3VN37SwQcI0YUHkqRMeyUQEyyUA4
	1vho7FU/MKIdoJyvgGcNb7BTfBvEDaPlR6ZpSUWpGA1Iqi60m33B1iIIBIoF2fNW
	xxp75W69/QaOZpEOP/JEVcwmXEcp0qnKw9YflyGEDCy0BKnRld5h5QLLZnCSC9DH
	RN4TnjdXHArysw==
X-ME-Sender: <xms:Pj7iXCUNA08MwsYu5IX3tZvJh0N1IPILLzZ4Yifg02CVzOly11pGPQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddruddtjedguddtudcutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgs
    ihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenuc
    fkphepuddvgedrudeiledrudehiedrvddtfeenucfrrghrrghmpehmrghilhhfrhhomhep
    thhosghinheskhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivgeple
X-ME-Proxy: <xmx:Pj7iXIn0IAsTU1BMvy5Pzl3kvULEP46U3l_7yP-sRiggzZ2kj0htqw>
    <xmx:Pj7iXNDCRb0IOfsaWYmSFmF1QxV1Xw94DRB7-cwVMdW6NMSNKqcSWg>
    <xmx:Pj7iXHjQMhy_D6yVWyr9yqf1weJjFjAM5j_T-_6JYWhl1WkN9M8nOA>
    <xmx:Pj7iXHxwAKqWEbwNJ7zAAejwR9xygPgXid6LgQMl0-uzEdMZli4Trg>
Received: from eros.localdomain (124-169-156-203.dyn.iinet.net.au [124.169.156.203])
	by mail.messagingengine.com (Postfix) with ESMTPA id DBBF380064;
	Mon, 20 May 2019 01:42:15 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <willy@infradead.org>
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
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 10/16] xarray: Implement migration function for xa_node objects
Date: Mon, 20 May 2019 15:40:11 +1000
Message-Id: <20190520054017.32299-11-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190520054017.32299-1-tobin@kernel.org>
References: <20190520054017.32299-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recently Slab Movable Objects (SMO) was implemented for the SLUB
allocator.  The XArray can take advantage of this and make the xa_node
slab cache objects movable.

Implement functions to migrate objects and activate SMO when we
initialise the XArray slab cache.

This is based on initial code by Matthew Wilcox and was modified to work
with slab object migration.

Cc: Matthew Wilcox <willy@infradead.org>
Co-developed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 lib/xarray.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 61 insertions(+)

diff --git a/lib/xarray.c b/lib/xarray.c
index a528a5277c9d..c6b077f59e88 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -1993,12 +1993,73 @@ static void xa_node_ctor(void *arg)
 	INIT_LIST_HEAD(&node->private_list);
 }
 
+static void xa_object_migrate(struct xa_node *node, int numa_node)
+{
+	struct xarray *xa = READ_ONCE(node->array);
+	void __rcu **slot;
+	struct xa_node *new_node;
+	int i;
+
+	/* Freed or not yet in tree then skip */
+	if (!xa || xa == XA_RCU_FREE)
+		return;
+
+	new_node = kmem_cache_alloc_node(xa_node_cachep, GFP_KERNEL, numa_node);
+	if (!new_node) {
+		pr_err("%s: slab cache allocation failed\n", __func__);
+		return;
+	}
+
+	xa_lock_irq(xa);
+
+	/* Check again..... */
+	if (xa != node->array) {
+		node = new_node;
+		goto unlock;
+	}
+
+	memcpy(new_node, node, sizeof(struct xa_node));
+
+	if (list_empty(&node->private_list))
+		INIT_LIST_HEAD(&new_node->private_list);
+	else
+		list_replace(&node->private_list, &new_node->private_list);
+
+	for (i = 0; i < XA_CHUNK_SIZE; i++) {
+		void *x = xa_entry_locked(xa, new_node, i);
+
+		if (xa_is_node(x))
+			rcu_assign_pointer(xa_to_node(x)->parent, new_node);
+	}
+	if (!new_node->parent)
+		slot = &xa->xa_head;
+	else
+		slot = &xa_parent_locked(xa, new_node)->slots[new_node->offset];
+	rcu_assign_pointer(*slot, xa_mk_node(new_node));
+
+unlock:
+	xa_unlock_irq(xa);
+	xa_node_free(node);
+	rcu_barrier();
+}
+
+static void xa_migrate(struct kmem_cache *s, void **objects, int nr,
+		       int node, void *_unused)
+{
+	int i;
+
+	for (i = 0; i < nr; i++)
+		xa_object_migrate(objects[i], node);
+}
+
+
 void __init xarray_slabcache_init(void)
 {
 	xa_node_cachep = kmem_cache_create("xarray_node",
 					   sizeof(struct xa_node), 0,
 					   SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
 					   xa_node_ctor);
+	kmem_cache_setup_mobility(xa_node_cachep, NULL, xa_migrate);
 }
 
 #ifdef XA_DEBUG
-- 
2.21.0

