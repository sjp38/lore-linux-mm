Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 294B3C3A5A4
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F9A206B7
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 11:16:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F9A206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F796B0569; Mon, 26 Aug 2019 07:16:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CBE26B056B; Mon, 26 Aug 2019 07:16:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 757966B056C; Mon, 26 Aug 2019 07:16:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 469416B0569
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 07:16:45 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E2C68180AD7C1
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:44 +0000 (UTC)
X-FDA: 75864326328.06.toes92_1dbd2cd5ec25c
X-HE-Tag: toes92_1dbd2cd5ec25c
X-Filterd-Recvd-Size: 11174
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:16:44 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A3E48AC64;
	Mon, 26 Aug 2019 11:16:42 +0000 (UTC)
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
Subject: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for kmalloc(power-of-two)
Date: Mon, 26 Aug 2019 13:16:27 +0200
Message-Id: <20190826111627.7505-3-vbabka@suse.cz>
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

In most configurations, kmalloc() happens to return naturally aligned (i.=
e.
aligned to the block size itself) blocks for power of two sizes. That mea=
ns
some kmalloc() users might unknowingly rely on that alignment, until stuf=
f
breaks when the kernel is built with e.g.  CONFIG_SLUB_DEBUG or CONFIG_SL=
OB,
and blocks stop being aligned. Then developers have to devise workaround =
such
as own kmem caches with specified alignment [1], which is not always prac=
tical,
as recently evidenced in [2].

The topic has been discussed at LSF/MM 2019 [3]. Adding a 'kmalloc_aligne=
d()'
variant would not help with code unknowingly relying on the implicit alig=
nment.
For slab implementations it would either require creating more kmalloc ca=
ches,
or allocate a larger size and only give back part of it. That would be
wasteful, especially with a generic alignment parameter (in contrast with=
 a
fixed alignment to size).

Ideally we should provide to mm users what they need without difficult
workarounds or own reimplementations, so let's make the kmalloc() alignme=
nt to
size explicitly guaranteed for power-of-two sizes under all configuration=
s.
What this means for the three available allocators?

* SLAB object layout happens to be mostly unchanged by the patch. The
  implicitly provided alignment could be compromised with CONFIG_DEBUG_SL=
AB due
  to redzoning, however SLAB disables redzoning for caches with alignment
  larger than unsigned long long. Practically on at least x86 this includ=
es
  kmalloc caches as they use cache line alignment, which is larger than t=
hat.
  Still, this patch ensures alignment on all arches and cache sizes.

* SLUB layout is also unchanged unless redzoning is enabled through
  CONFIG_SLUB_DEBUG and boot parameter for the particular kmalloc cache. =
With
  this patch, explicit alignment is guaranteed with redzoning as well. Th=
is
  will result in more memory being wasted, but that should be acceptable =
in a
  debugging scenario.

* SLOB has no implicit alignment so this patch adds it explicitly for
  kmalloc(). The potential downside is increased fragmentation. While
  pathological allocation scenarios are certainly possible, in my testing=
,
  after booting a x86_64 kernel+userspace with virtme, around 16MB memory
  was consumed by slab pages both before and after the patch, with differ=
ence
  in the noise.

[1] https://lore.kernel.org/linux-btrfs/c3157c8e8e0e7588312b40c853f65c02f=
e6c957a.1566399731.git.christophe.leroy@c-s.fr/
[2] https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@=
redhat.com/
[3] https://lwn.net/Articles/787740/

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/core-api/memory-allocation.rst |  4 ++
 include/linux/slab.h                         |  4 ++
 mm/slab_common.c                             | 11 ++++-
 mm/slob.c                                    | 42 +++++++++++++++-----
 4 files changed, 49 insertions(+), 12 deletions(-)

diff --git a/Documentation/core-api/memory-allocation.rst b/Documentation=
/core-api/memory-allocation.rst
index 7744aa3bf2e0..27c54854b508 100644
--- a/Documentation/core-api/memory-allocation.rst
+++ b/Documentation/core-api/memory-allocation.rst
@@ -98,6 +98,10 @@ limited. The actual limit depends on the hardware and =
the kernel
 configuration, but it is a good practice to use `kmalloc` for objects
 smaller than page size.
=20
+The address of a chunk allocated with `kmalloc` is aligned to at least
+ARCH_KMALLOC_MINALIGN bytes. For sizes of power of two bytes, the
+alignment is also guaranteed to be at least to the respective size.
+
 For large allocations you can use :c:func:`vmalloc` and
 :c:func:`vzalloc`, or directly request pages from the page
 allocator. The memory allocated by `vmalloc` and related functions is
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 56c9c7eed34e..0d4c26395785 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -493,6 +493,10 @@ static __always_inline void *kmalloc_large(size_t si=
ze, gfp_t flags)
  * kmalloc is the normal method of allocating memory
  * for objects smaller than page size in the kernel.
  *
+ * The allocated object address is aligned to at least ARCH_KMALLOC_MINA=
LIGN
+ * bytes. For @size of power of two bytes, the alignment is also guarant=
eed
+ * to be at least to the size.
+ *
  * The @flags argument may be one of the GFP flags defined at
  * include/linux/gfp.h and described at
  * :ref:`Documentation/core-api/mm-api.rst <mm-api-gfp-flags>`
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 929c02a90fba..b9ba93ad5c7f 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -993,10 +993,19 @@ void __init create_boot_cache(struct kmem_cache *s,=
 const char *name,
 		unsigned int useroffset, unsigned int usersize)
 {
 	int err;
+	unsigned int align =3D ARCH_KMALLOC_MINALIGN;
=20
 	s->name =3D name;
 	s->size =3D s->object_size =3D size;
-	s->align =3D calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
+
+	/*
+	 * For power of two sizes, guarantee natural alignment for kmalloc
+	 * caches, regardless of SL*B debugging options.
+	 */
+	if (is_power_of_2(size))
+		align =3D max(align, size);
+	s->align =3D calculate_alignment(flags, align, size);
+
 	s->useroffset =3D useroffset;
 	s->usersize =3D usersize;
=20
diff --git a/mm/slob.c b/mm/slob.c
index 3dcde9cf2b17..07a39047aa54 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -224,6 +224,7 @@ static void slob_free_pages(void *b, int order)
  * @sp: Page to look in.
  * @size: Size of the allocation.
  * @align: Allocation alignment.
+ * @align_offset: Offset in the allocated block that will be aligned.
  * @page_removed_from_list: Return parameter.
  *
  * Tries to find a chunk of memory at least @size bytes big within @page=
.
@@ -234,7 +235,7 @@ static void slob_free_pages(void *b, int order)
  *         true (set to false otherwise).
  */
 static void *slob_page_alloc(struct page *sp, size_t size, int align,
-			     bool *page_removed_from_list)
+			      int align_offset, bool *page_removed_from_list)
 {
 	slob_t *prev, *cur, *aligned =3D NULL;
 	int delta =3D 0, units =3D SLOB_UNITS(size);
@@ -243,8 +244,17 @@ static void *slob_page_alloc(struct page *sp, size_t=
 size, int align,
 	for (prev =3D NULL, cur =3D sp->freelist; ; prev =3D cur, cur =3D slob_=
next(cur)) {
 		slobidx_t avail =3D slob_units(cur);
=20
+		/*
+		 * 'aligned' will hold the address of the slob block so that the
+		 * address 'aligned'+'align_offset' is aligned according to the
+		 * 'align' parameter. This is for kmalloc() which prepends the
+		 * allocated block with its size, so that the block itself is
+		 * aligned when needed.
+		 */
 		if (align) {
-			aligned =3D (slob_t *)ALIGN((unsigned long)cur, align);
+			aligned =3D (slob_t *)
+				(ALIGN((unsigned long)cur + align_offset, align)
+				 - align_offset);
 			delta =3D aligned - cur;
 		}
 		if (avail >=3D units + delta) { /* room enough? */
@@ -288,7 +298,8 @@ static void *slob_page_alloc(struct page *sp, size_t =
size, int align,
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node,
+							int align_offset)
 {
 	struct page *sp;
 	struct list_head *slob_list;
@@ -319,7 +330,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int a=
lign, int node)
 		if (sp->units < SLOB_UNITS(size))
 			continue;
=20
-		b =3D slob_page_alloc(sp, size, align, &page_removed_from_list);
+		b =3D slob_page_alloc(sp, size, align, align_offset, &page_removed_fro=
m_list);
 		if (!b)
 			continue;
=20
@@ -356,7 +367,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int a=
lign, int node)
 		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
-		b =3D slob_page_alloc(sp, size, align, &_unused);
+		b =3D slob_page_alloc(sp, size, align, align_offset, &_unused);
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
@@ -458,7 +469,7 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller=
)
 {
 	unsigned int *m;
-	int align =3D max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	int minalign =3D max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIG=
N);
 	void *ret;
=20
 	gfp &=3D gfp_allowed_mask;
@@ -466,19 +477,28 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node,=
 unsigned long caller)
 	fs_reclaim_acquire(gfp);
 	fs_reclaim_release(gfp);
=20
-	if (size < PAGE_SIZE - align) {
+	if (size < PAGE_SIZE - minalign) {
+		int align =3D minalign;
+
+		/*
+		 * For power of two sizes, guarantee natural alignment for
+		 * kmalloc()'d objects.
+		 */
+		if (is_power_of_2(size))
+			align =3D max(minalign, (int) size);
+
 		if (!size)
 			return ZERO_SIZE_PTR;
=20
-		m =3D slob_alloc(size + align, gfp, align, node);
+		m =3D slob_alloc(size + minalign, gfp, align, node, minalign);
=20
 		if (!m)
 			return NULL;
 		*m =3D size;
-		ret =3D (void *)m + align;
+		ret =3D (void *)m + minalign;
=20
 		trace_kmalloc_node(caller, ret,
-				   size, size + align, gfp, node);
+				   size, size + minalign, gfp, node);
 	} else {
 		unsigned int order =3D get_order(size);
=20
@@ -579,7 +599,7 @@ static void *slob_alloc_node(struct kmem_cache *c, gf=
p_t flags, int node)
 	fs_reclaim_release(flags);
=20
 	if (c->size < PAGE_SIZE) {
-		b =3D slob_alloc(c->size, flags, c->align, node);
+		b =3D slob_alloc(c->size, flags, c->align, node, 0);
 		trace_kmem_cache_alloc_node(_RET_IP_, b, c->object_size,
 					    SLOB_UNITS(c->size) * SLOB_UNIT,
 					    flags, node);
--=20
2.22.1


