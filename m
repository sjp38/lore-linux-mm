Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AFE3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:53:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEC69206DD
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 22:53:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Jtzltnmi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC69206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5F308E0004; Thu, 28 Feb 2019 17:53:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B96E98E0001; Thu, 28 Feb 2019 17:53:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A373C8E0004; Thu, 28 Feb 2019 17:53:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52D9F8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 17:53:21 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id z1so16134686pln.11
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:53:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j1iTxAxv6pbEuzIkxfF4lpzr259T0cpQc63OyitFdlw=;
        b=HeVjkkGecWzAkWQ7vzS9qcEuEjHBu1RCvlXU1mvISJ7ySi6y5YiX77TkTpwKEpirVA
         AvG8FIHPkOUSObZRxVW61ZJzKJxcMYljvSDWhTrnPt79G9DvjpvwErt/3DEI+/38OHWM
         x8TvlbBHHlz5Gem2RYAQ4n0gJsQIQ3QxxvwlUoM3Bk3mvHOw93RrhtKJgqd1/9zc+fjb
         TP9PqnGcc0/D84LlegdLFaOsH+iyfrtjBc5Rl3YKc/kqGLX5wg8y2zx/wn5HD+LQyMPl
         5ELGSk1CTrQ8n7oekEIIBupCCESG7Achvq8dgDJh36/cWjA4XmmEzlCsmWmUlE5YLOAw
         8wCA==
X-Gm-Message-State: APjAAAV+V87SUdIXiiT28pH29UrDlJhrmdAfKFAcGqtya7aegYpM0iT+
	FkZ4fdsJhthEFCeWLtYm/IvYQ4ZyGRkFaB0xKRx+FJadBluvbwnZVMLyyxRFAk+u8i/wkQa6xY4
	p0gGvv4ElZQZFgu0qDISduoYgxy0DlJ5t3vJ7VTu7LMnjJ2JMOfY62KyoXB9eKm85xQ==
X-Received: by 2002:a62:14c6:: with SMTP id 189mr2153091pfu.23.1551394400853;
        Thu, 28 Feb 2019 14:53:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaLmNDiAaN652qKDs1AnPsxTaQbshCOfRt/gRJ7Ix7IBASFrBh5S9gbBwomzXrGZCmTP648
X-Received: by 2002:a62:14c6:: with SMTP id 189mr2152975pfu.23.1551394399245;
        Thu, 28 Feb 2019 14:53:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551394399; cv=none;
        d=google.com; s=arc-20160816;
        b=wJexnj4wL7tSM0cnAaV/BjMNxos21c1bue6KohCeLOs8EhZuC1+Hp1ePXgxO5AyvYX
         h488xBhf3I/0t1Hca8bqqOpnEaBFHGzMcftYErRZrOW5d8PSKkITaqk2fTZyeHkQwNRW
         t9hX7Wh8veiB6Gl5mDQ5eMIfQJLAZUWLvMoYeoj10iyyLzKSEQsUxkKCFnjRfNkpIvLD
         J9Hfkj8zZSoZVEkr8a0DSMxGK5N0Oh47320RUk1VIGxN+6/sDUUwCGzt7qjoUOVZXgOY
         l0wCGYJRbOjwo9pJHA0AEp73W3ByK4M5ZQg7wKnjUhmLLnxT6BIMDhg7tOd2vHpUS0y0
         W1Xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j1iTxAxv6pbEuzIkxfF4lpzr259T0cpQc63OyitFdlw=;
        b=vBmIfqIieiJvZ6wpfsqeUMKsINmNsjZGt4KAlgkAR65+ZZFL1S9QbvrVdk/O6CVwEI
         m0XPK5d/BMvMerLPu4+29apc+E/KTCMao+DWl/fOcGxqmjhXkY5ctNdNbJAYzt5aj90q
         0RXlLxj3NZUFW5R5Quc0aJgP2JwQyWZJoWFApBlrtoIWiyCdBma+3NGBVChu6Rj62Ib6
         8JN3yq2Y4RpJyk0t4jjSgliBemFw9J9W2Y3PlI3zDyMbBxs6cTn0aRbvBJmYRktiybMm
         NCffX2nA+o4bpnLKHLIxbDiom3idLOwO2L7d8mNYmO7XfUTFe9X2ZkjWZJLVPpvARKlt
         qttA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Jtzltnmi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w185si17090726pgd.495.2019.02.28.14.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 14:53:18 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Jtzltnmi;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=j1iTxAxv6pbEuzIkxfF4lpzr259T0cpQc63OyitFdlw=; b=Jtzltnmi3KZlcUmmrvLCe0tLO
	Z+hcuFsOuv86OqAmicnHPRgOwTdc+96ECEhyMqiddm4985C4x0egQV+dooNJf/5Tzv3s1/f/9lv1H
	f7Q8p2mRUHZz8cp38JdR4xvkamv2NeyObkx+BeNBh0XR7hGpd24V2OZcGiP4HKe//iP//QJMQxVO5
	Pn+UJ+3wMLqNQN1Wwsm+L1CwcllSKk5z8IlPZU0qXlqlWsbUWSK+SmUuO9zVxqbJ7hlRYhuQX2dT+
	mPLoTiRQ5L8z5EOk91Dh6tEvpRPVptUFbbu0JTDnKPJZ6dPgsxD93wt9IPTTxc9yzgfW16SqmOb5G
	vCUxb/ZOg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gzUYH-00036D-W9; Thu, 28 Feb 2019 22:53:18 +0000
Date: Thu, 28 Feb 2019 14:53:17 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190228225317.GM11592@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
 <20190227122451.GJ11592@bombadil.infradead.org>
 <20190227165538.GD27119@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190227165538.GD27119@quack2.suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 05:55:38PM +0100, Jan Kara wrote:
> On Wed 27-02-19 04:24:51, Matthew Wilcox wrote:
> Looking more into perf traces, I didn't notice any other obvious low
> hanging fruit. There is one suboptimality in the fact that
> __clear_shadow_entry() does xas_load() and the first thing xas_store() does
> is xas_load() again. Removing this double tree traversal does bring
> something back but since the traversals are so close together, everything
> is cache hot and so the overall gain is small (but still):

Calling xas_load() twice isn't too bad; the iterator stays at the base of
the tree, so it's just one pointer reload.  Still, I think we can avoid it.

> COMMIT     AVG            STDDEV
> singleiter 1467763.900000 1078.261049
> 
> So still 34 ms to go to the original time.
> 
> What profiles do show is there's slightly more time spent here and there
> adding to overall larger xas_store() time (compared to
> __radix_tree_replace()) mostly due to what I'd blame to cache misses
> (xas_store() is responsible for ~3.4% of cache misses after the patch while
> xas_store() + __radix_tree_replace() caused only 1.5% together before).
> 
> Some of the expensive loads seem to be from 'xas' structure (kind
> of matches with what Nick said), other expensive loads seem to be loads from
> xa_node. And I don't have a great explanation why e.g. a load of
> xa_node->count is expensive when we looked at xa_node->shift before -
> either the cache line fell out of cache or the byte accesses somehow
> confuse the CPU. Also xas_store() has some new accesses compared to
> __radix_tree_replace() - e.g. it did not previously touch node->shift.
> 
> So overall I don't see easy way how to speed up xarray code further so
> maybe just batching truncate to make up for some of the losses and live
> with them where we cannot batch will be as good as it gets...

Here's what I'm currently looking at.  xas_store() becomes a wrapper
around xas_replace() and xas_replace() avoids the xas_init_marks() and
xas_load() calls:

diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 0e01e6129145..26fdba17ce67 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -1455,6 +1455,7 @@ static inline bool xas_retry(struct xa_state *xas, const void *entry)
 
 void *xas_load(struct xa_state *);
 void *xas_store(struct xa_state *, void *entry);
+void xas_replace(struct xa_state *, void *curr, void *entry);
 void *xas_find(struct xa_state *, unsigned long max);
 void *xas_find_conflict(struct xa_state *);
 
diff --git a/lib/test_xarray.c b/lib/test_xarray.c
index 5d4bad8bd96a..b2e2cdf4eb74 100644
--- a/lib/test_xarray.c
+++ b/lib/test_xarray.c
@@ -38,6 +38,12 @@ static void *xa_store_index(struct xarray *xa, unsigned long index, gfp_t gfp)
 	return xa_store(xa, index, xa_mk_index(index), gfp);
 }
 
+static void xa_insert_index(struct xarray *xa, unsigned long index)
+{
+	XA_BUG_ON(xa, xa_insert(xa, index, xa_mk_index(index),
+				GFP_KERNEL) != 0);
+}
+
 static void xa_alloc_index(struct xarray *xa, unsigned long index, gfp_t gfp)
 {
 	u32 id;
@@ -338,6 +344,20 @@ static noinline void check_xa_shrink(struct xarray *xa)
 	}
 }
 
+static noinline void check_insert(struct xarray *xa)
+{
+	unsigned long i;
+
+	for (i = 0; i < 1024; i++) {
+		xa_insert_index(xa, i);
+		XA_BUG_ON(xa, xa_load(xa, i - 1) != NULL);
+		XA_BUG_ON(xa, xa_load(xa, i + 1) != NULL);
+		xa_erase_index(xa, i);
+	}
+
+	XA_BUG_ON(xa, !xa_empty(xa));
+}
+
 static noinline void check_cmpxchg(struct xarray *xa)
 {
 	void *FIVE = xa_mk_value(5);
@@ -1527,6 +1547,7 @@ static int xarray_checks(void)
 	check_xa_mark(&array);
 	check_xa_shrink(&array);
 	check_xas_erase(&array);
+	check_insert(&array);
 	check_cmpxchg(&array);
 	check_reserve(&array);
 	check_reserve(&xa0);
diff --git a/lib/xarray.c b/lib/xarray.c
index 6be3acbb861f..8ff605bd0fee 100644
--- a/lib/xarray.c
+++ b/lib/xarray.c
@@ -613,7 +613,7 @@ static int xas_expand(struct xa_state *xas, void *head)
 /*
  * xas_create() - Create a slot to store an entry in.
  * @xas: XArray operation state.
- * @allow_root: %true if we can store the entry in the root directly
+ * @entry: Entry which will be stored in the slot.
  *
  * Most users will not need to call this function directly, as it is called
  * by xas_store().  It is useful for doing conditional store operations
@@ -623,14 +623,14 @@ static int xas_expand(struct xa_state *xas, void *head)
  * If the slot was newly created, returns %NULL.  If it failed to create the
  * slot, returns %NULL and indicates the error in @xas.
  */
-static void *xas_create(struct xa_state *xas, bool allow_root)
+static void *xas_create(struct xa_state *xas, void *entry)
 {
 	struct xarray *xa = xas->xa;
-	void *entry;
 	void __rcu **slot;
 	struct xa_node *node = xas->xa_node;
 	int shift;
 	unsigned int order = xas->xa_shift;
+	bool allow_root = !xa_is_node(entry) && !xa_is_zero(entry);
 
 	if (xas_top(node)) {
 		entry = xa_head_locked(xa);
@@ -701,7 +701,7 @@ void xas_create_range(struct xa_state *xas)
 	xas->xa_sibs = 0;
 
 	for (;;) {
-		xas_create(xas, true);
+		xas_create(xas, XA_ZERO_ENTRY);
 		if (xas_error(xas))
 			goto restore;
 		if (xas->xa_index <= (index | XA_CHUNK_MASK))
@@ -745,44 +745,36 @@ static void update_node(struct xa_state *xas, struct xa_node *node,
 }
 
 /**
- * xas_store() - Store this entry in the XArray.
+ * xas_replace() - Replace one XArray entry with another.
  * @xas: XArray operation state.
+ * @curr: Current entry.
  * @entry: New entry.
  *
- * If @xas is operating on a multi-index entry, the entry returned by this
- * function is essentially meaningless (it may be an internal entry or it
- * may be %NULL, even if there are non-NULL entries at some of the indices
- * covered by the range).  This is not a problem for any current users,
- * and can be changed if needed.
- *
- * Return: The old entry at this index.
+ * This is not a cmpxchg operation.  The caller asserts that @curr is the
+ * current entry at the index referred to by @xas and wishes to replace it
+ * with @entry.  The slot must have already been created by xas_create()
+ * or by virtue of @curr being non-NULL.  The marks are not changed by
+ * this operation.
  */
-void *xas_store(struct xa_state *xas, void *entry)
+void xas_replace(struct xa_state *xas, void *curr, void *entry)
 {
 	struct xa_node *node;
 	void __rcu **slot = &xas->xa->xa_head;
 	unsigned int offset, max;
 	int count = 0;
 	int values = 0;
-	void *first, *next;
+	void *next;
 	bool value = xa_is_value(entry);
 
-	if (entry) {
-		bool allow_root = !xa_is_node(entry) && !xa_is_zero(entry);
-		first = xas_create(xas, allow_root);
-	} else {
-		first = xas_load(xas);
-	}
-
 	if (xas_invalid(xas))
-		return first;
+		return;
 	node = xas->xa_node;
 	if (node && (xas->xa_shift < node->shift))
 		xas->xa_sibs = 0;
-	if ((first == entry) && !xas->xa_sibs)
-		return first;
+	if ((curr == entry) && !xas->xa_sibs)
+		return;
 
-	next = first;
+	next = curr;
 	offset = xas->xa_offset;
 	max = xas->xa_offset + xas->xa_sibs;
 	if (node) {
@@ -790,8 +782,6 @@ void *xas_store(struct xa_state *xas, void *entry)
 		if (xas->xa_sibs)
 			xas_squash_marks(xas);
 	}
-	if (!entry)
-		xas_init_marks(xas);
 
 	for (;;) {
 		/*
@@ -807,7 +797,7 @@ void *xas_store(struct xa_state *xas, void *entry)
 		if (!node)
 			break;
 		count += !next - !entry;
-		values += !xa_is_value(first) - !value;
+		values += !xa_is_value(curr) - !value;
 		if (entry) {
 			if (offset == max)
 				break;
@@ -821,13 +811,41 @@ void *xas_store(struct xa_state *xas, void *entry)
 		if (!xa_is_sibling(next)) {
 			if (!entry && (offset > max))
 				break;
-			first = next;
+			curr = next;
 		}
 		slot++;
 	}
 
 	update_node(xas, node, count, values);
-	return first;
+}
+
+/**
+ * xas_store() - Store this entry in the XArray.
+ * @xas: XArray operation state.
+ * @entry: New entry.
+ *
+ * If @xas is operating on a multi-index entry, the entry returned by this
+ * function is essentially meaningless (it may be an internal entry or it
+ * may be %NULL, even if there are non-NULL entries at some of the indices
+ * covered by the range).  This is not a problem for any current users,
+ * and can be changed if needed.
+ *
+ * Return: The old entry at this index.
+ */
+void *xas_store(struct xa_state *xas, void *entry)
+{
+	void *curr;
+
+	if (entry) {
+		curr = xas_create(xas, entry);
+	} else {
+		curr = xas_load(xas);
+		if (curr)
+			xas_init_marks(xas);
+	}
+
+	xas_replace(xas, curr, entry);
+	return curr;
 }
 EXPORT_SYMBOL_GPL(xas_store);
 
@@ -1472,9 +1490,9 @@ int __xa_insert(struct xarray *xa, unsigned long index, void *entry, gfp_t gfp)
 		entry = XA_ZERO_ENTRY;
 
 	do {
-		curr = xas_load(&xas);
+		curr = xas_create(&xas, entry);
 		if (!curr) {
-			xas_store(&xas, entry);
+			xas_replace(&xas, curr, entry);
 			if (xa_track_free(xa))
 				xas_clear_mark(&xas, XA_FREE_MARK);
 		} else {
@@ -1553,7 +1571,7 @@ void *xa_store_range(struct xarray *xa, unsigned long first,
 			if (last + 1)
 				order = __ffs(last + 1);
 			xas_set_order(&xas, last, order);
-			xas_create(&xas, true);
+			xas_create(&xas, entry);
 			if (xas_error(&xas))
 				goto unlock;
 		}
@@ -1606,11 +1624,13 @@ int __xa_alloc(struct xarray *xa, u32 *id, void *entry,
 	do {
 		xas.xa_index = limit.min;
 		xas_find_marked(&xas, limit.max, XA_FREE_MARK);
-		if (xas.xa_node == XAS_RESTART)
+		if (xas.xa_node == XAS_RESTART) {
 			xas_set_err(&xas, -EBUSY);
-		else
+		} else {
+			xas_create(&xas, entry);
 			*id = xas.xa_index;
-		xas_store(&xas, entry);
+		}
+		xas_replace(&xas, NULL, entry);
 		xas_clear_mark(&xas, XA_FREE_MARK);
 	} while (__xas_nomem(&xas, gfp));
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e..56a7ef579879 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -131,8 +131,8 @@ static void page_cache_delete(struct address_space *mapping,
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(nr != 1 && shadow, page);
 
-	xas_store(&xas, shadow);
 	xas_init_marks(&xas);
+	xas_replace(&xas, page, shadow);
 
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
@@ -326,7 +326,7 @@ static void page_cache_delete_batch(struct address_space *mapping,
 					!= pvec->pages[i]->index, page);
 			tail_pages--;
 		}
-		xas_store(&xas, NULL);
+		xas_replace(&xas, page, NULL);
 		total_pages++;
 	}
 	mapping->nrpages -= total_pages;
@@ -771,7 +771,7 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	new->index = offset;
 
 	xas_lock_irqsave(&xas, flags);
-	xas_store(&xas, new);
+	xas_replace(&xas, old, new);
 
 	old->mapping = NULL;
 	/* hugetlb pages do not participate in page cache accounting. */
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..083f52797d11 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -459,13 +459,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
 		SetPageDirty(newpage);
 	}
 
-	xas_store(&xas, newpage);
+	xas_replace(&xas, page, newpage);
 	if (PageTransHuge(page)) {
 		int i;
 
 		for (i = 1; i < HPAGE_PMD_NR; i++) {
 			xas_next(&xas);
-			xas_store(&xas, newpage + i);
+			xas_replace(&xas, page + i, newpage + i);
 		}
 	}
 
@@ -536,7 +536,7 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
 
 	get_page(newpage);
 
-	xas_store(&xas, newpage);
+	xas_replace(&xas, page, newpage);
 
 	page_ref_unfreeze(page, expected_count - 1);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 6ece1e2fe76e..83925601089d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -341,7 +341,7 @@ static int shmem_replace_entry(struct address_space *mapping,
 	item = xas_load(&xas);
 	if (item != expected)
 		return -ENOENT;
-	xas_store(&xas, replacement);
+	xas_replace(&xas, item, replacement);
 	return 0;
 }
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 798e7ccfb030..0682b2f9ac0e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -38,7 +38,7 @@ static inline void __clear_shadow_entry(struct address_space *mapping,
 	xas_set_update(&xas, workingset_update_node);
 	if (xas_load(&xas) != entry)
 		return;
-	xas_store(&xas, NULL);
+	xas_replace(&xas, entry, NULL);
 	mapping->nrexceptional--;
 }
 

