Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D1AC3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAB6C206B7
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAB6C206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A31D6B0567; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97A826B0569; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88FBA6B056A; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB226B0567
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:16:44 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 01F2C181AC9B4
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:44 +0000 (UTC)
X-FDA: 75864326328.06.front88_1d9eb5a38ec5b
X-HE-Tag: front88_1d9eb5a38ec5b
X-Filterd-Recvd-Size: 5779
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:43 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DF8EFAC28;
	Mon, 26 Aug 2019 11:16:41 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-btrfs@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/2] mm, sl[ou]b: improve memory accounting
Date: Mon, 26 Aug 2019 13:16:26 +0200
Message-Id: <20190826111627.7505-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190826111627.7505-1-vbabka@suse.cz>
References: <20190826111627.7505-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SLOB currently doesn't account its pages at all, so in /proc/meminfo the =
Slab
field shows zero. Modifying a counter on page allocation and freeing shou=
ld be
acceptable even for the small system scenarios SLOB is intended for.
Since reclaimable caches are not separated in SLOB, account everything as
unreclaimable.

SLUB currently doesn't account kmalloc() and kmalloc_node() allocations l=
arger
than order-1 page, that are passed directly to the page allocator. As the=
y also
don't appear in /proc/slabinfo, it might look like a memory leak. For
consistency, account them as well. (SLAB doesn't actually use page alloca=
tor
directly, so no change there).

Ideally SLOB and SLUB would be handled in separate patches, but due to th=
e
shared kmalloc_order() function and different kfree() implementations, it=
's
easier to patch both at once to prevent inconsistencies.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab_common.c |  8 ++++++--
 mm/slob.c        | 20 ++++++++++++++++----
 mm/slub.c        | 14 +++++++++++---
 3 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 807490fe217a..929c02a90fba 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1250,12 +1250,16 @@ void __init create_kmalloc_caches(slab_flags_t fl=
ags)
  */
 void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
 {
-	void *ret;
+	void *ret =3D NULL;
 	struct page *page;
=20
 	flags |=3D __GFP_COMP;
 	page =3D alloc_pages(flags, order);
-	ret =3D page ? page_address(page) : NULL;
+	if (likely(page)) {
+		ret =3D page_address(page);
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
+				    1 << order);
+	}
 	ret =3D kasan_kmalloc_large(ret, size, flags);
 	/* As ret might get tagged, call kmemleak hook after KASAN. */
 	kmemleak_alloc(ret, size, 1, flags);
diff --git a/mm/slob.c b/mm/slob.c
index 7f421d0ca9ab..3dcde9cf2b17 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -190,7 +190,7 @@ static int slob_last(slob_t *s)
=20
 static void *slob_new_pages(gfp_t gfp, int order, int node)
 {
-	void *page;
+	struct page *page;
=20
 #ifdef CONFIG_NUMA
 	if (node !=3D NUMA_NO_NODE)
@@ -202,14 +202,21 @@ static void *slob_new_pages(gfp_t gfp, int order, i=
nt node)
 	if (!page)
 		return NULL;
=20
+	mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
+			    1 << order);
 	return page_address(page);
 }
=20
 static void slob_free_pages(void *b, int order)
 {
+	struct page *sp =3D virt_to_page(b);
+
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab +=3D 1 << order;
-	free_pages((unsigned long)b, order);
+
+	mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE,
+			    -(1 << order));
+	__free_pages(sp, order);
 }
=20
 /*
@@ -521,8 +528,13 @@ void kfree(const void *block)
 		int align =3D max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN)=
;
 		unsigned int *m =3D (unsigned int *)(block - align);
 		slob_free(m, *m + align);
-	} else
-		__free_pages(sp, compound_order(sp));
+	} else {
+		unsigned int order =3D compound_order(sp);
+		mod_node_page_state(page_pgdat(sp), NR_SLAB_UNRECLAIMABLE,
+				    -(1 << order));
+		__free_pages(sp, order);
+
+	}
 }
 EXPORT_SYMBOL(kfree);
=20
diff --git a/mm/slub.c b/mm/slub.c
index 8834563cdb4b..74365d083a1e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3819,11 +3819,15 @@ static void *kmalloc_large_node(size_t size, gfp_=
t flags, int node)
 {
 	struct page *page;
 	void *ptr =3D NULL;
+	unsigned int order =3D get_order(size);
=20
 	flags |=3D __GFP_COMP;
-	page =3D alloc_pages_node(node, flags, get_order(size));
-	if (page)
+	page =3D alloc_pages_node(node, flags, order);
+	if (page) {
 		ptr =3D page_address(page);
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
+				    1 << order);
+	}
=20
 	return kmalloc_large_node_hook(ptr, size, flags);
 }
@@ -3949,9 +3953,13 @@ void kfree(const void *x)
=20
 	page =3D virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
+		unsigned int order =3D compound_order(page);
+
 		BUG_ON(!PageCompound(page));
 		kfree_hook(object);
-		__free_pages(page, compound_order(page));
+		mod_node_page_state(page_pgdat(page), NR_SLAB_UNRECLAIMABLE,
+				    -(1 << order));
+		__free_pages(page, order);
 		return;
 	}
 	slab_free(page->slab_cache, page, object, NULL, 1, _RET_IP_);
--=20
2.22.1


