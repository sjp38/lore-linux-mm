Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1E96C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C81F2175B
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:11:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C81F2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9CE76B0006; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C28C96B000A; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4FCB6B0006; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7476B0008
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:11:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p5so110503edh.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V09LDBdRnWephqxFwrgzBDXM8cLyI7pzM1TQj9PFlJE=;
        b=dH/2whE+cL6KidVbqKA4skPDqN+8li4USCw7Jmu5RUePm1hFoLxuFHs1aUSZHWahhY
         dClVeWoQstvXkEOkpveiFNdwcEf40X7ZsVXghaMbxqLEbuBCMVFcXFD6MwIc0kHRWBQk
         1nsxiwzV9RvzTdSkPQM2uHNLClmiyvgPsCgY17cdu9M8Pk3WVEg76fYZRLZkZlDMvDNg
         51gyUGSy/UrvpZG/nliBq8CMOkqoSJ/O9VnQogApjQL3dX3/rAAq1sCRv7F/t+UBKbC7
         ME2e2xyIui0StvJfjPl1WRsH/jp9F/vXNO9uwQyFSDeLo2E02uRi3Wt4mzEwWyk+cwLQ
         TnIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVpSfUnyfpxXBVT/vtI5pqbDfPaMt0xfsNCtklfCEnNeGURT/ut
	oXMTn1A/dNoDlmwFdpVBzoX0qJLoFk0NzZBQthCOGqxyElzPKpZfyO/x9oRQbGS1kxPb/vrbtlD
	he1R4zsqMyKe2qI4BexkDhRaIeYd2D0bYpqC/+oxhf9osHlgBu2Nj+vg1aPlb4b33uw==
X-Received: by 2002:aa7:da09:: with SMTP id r9mr18079073eds.7.1553029889730;
        Tue, 19 Mar 2019 14:11:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsyfSOD5BZIOYk/EzcycR01W750G2iTFVPbhPFH+2JUo4P21iSR3TMP+ePr3GUsAKzO/6+
X-Received: by 2002:aa7:da09:: with SMTP id r9mr18079038eds.7.1553029888556;
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553029888; cv=none;
        d=google.com; s=arc-20160816;
        b=E8/hazH6pmS4fvaVTKqFaMXMAzMKzOWo/MWE5BACIymEYzMuMYx4uNWDKjlTOoG4/p
         56Ov6ijPYp9oEXkdeW7Tgunv+DGTLzK3aYPo5pRw6x6XFGwfJNheRZIxijRRTtdyGDzq
         x05tUmsPwdOibQhoiTRGU1pp7sbHJBZVPro08WDFtGKhYB9UrhXR3os5vB+ZUOQVBI4a
         5FYgDgTcGY6BOhjriu6CkRSddMtKSIxaWS0kp1lt5TgsFh6fyoZgb5PBTjHOSfnmkF3F
         8FyG/kKGQ9ymzVYAEgvcGibsmgeFpW+VtSn1Vbyw21ortSUJl8YWv6Rnoffdz5dd3nwY
         ivew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=V09LDBdRnWephqxFwrgzBDXM8cLyI7pzM1TQj9PFlJE=;
        b=x466Q5bT3LADTnJSz2xkUu7F6D67biUwdG4UAg6ends/s2BNAx2+rw/GKocevF15sK
         ks0zlTmuCMMX1zJL9fAUqCaVapoR2IGYVy3d+OL9+qCTpFuOMhN4QwqgEmiFDkksbqrP
         w9F14uvbpXDzzrAMy8A3ClW2MNvlPNQCdHJLuAiceL/gc9Wq1KKPelut4bVe94/p+p9Q
         Um7GCd801uRoXMivy/CycOdqr+X8KbLgcp0rBa+4vEkQNEaOesd6Ot1b5DWFx6KuNp8A
         1eQQd+rVkgBai3YAdwqq2Hoc/sJ2hpozqiGr+6eq166Ma2ZZWNg5ky2b24Vv/yir9VdH
         c1bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p6si1741394ejf.184.2019.03.19.14.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 14:11:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 96511B604;
	Tue, 19 Mar 2019 21:11:27 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>,
	Michal Hocko <mhocko@kernel.org>,
	linux-kernel@vger.kernel.org,
	linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 1/2] mm, sl[aou]b: guarantee natural alignment for kmalloc(power-of-two)
Date: Tue, 19 Mar 2019 22:11:07 +0100
Message-Id: <20190319211108.15495-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190319211108.15495-1-vbabka@suse.cz>
References: <20190319211108.15495-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In most configurations, kmalloc() happens to return naturally aligned blocks
for power of two sizes. That means some kmalloc() users might implicitly rely
on that alignment, until stuff breaks when the kernel is built with e.g.
CONFIG_SLUB_DEBUG or CONFIG_SLOB, and blocks stop being aligned. Then
developers have to devise workaround such as own kmem caches with specified
alignment, which is not always practical, as recently evidenced in [1].

Ideally we should provide to mm users what they need without difficult
workarounds or own reimplementations, so let's make the kmalloc() alignment
explicit and guaranteed for power-of-two sizes under all configurations.
What this means for the three available allocators?

* SLAB happens to be OK even before the patch. The implicit alignment could be
  compromised with CONFIG_DEBUG_SLAB due to redzoning, however SLAB disables
  red zoning for caches with alignment larger than unsigned long long.
  Practically on at least x86 this includes kmalloc caches as they use cache
  line alignment which is larger than that. Still, this patch ensures alignment
  on all arches and cache sizes.

* SLUB is implicitly OK unless red zoning is enabled through CONFIG_SLUB_DEBUG
  or boot parameter. With this patch, explicit alignment guarantees it with red
  zoning as well. This will result in more memory being wasted, but that should
  be acceptable in a debugging scenario.

* SLOB has no implicit alignment so this patch adds it explicitly for
  kmalloc(). The downside is increased fragmentation, which is hopefully
  acceptable for this relatively rarely used allocator.

[1] https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#u

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab_common.c | 11 ++++++++++-
 mm/slob.c        | 42 +++++++++++++++++++++++++++++++-----------
 2 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 03eeb8b7b4b1..e591d5688558 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -968,10 +968,19 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name,
 		unsigned int useroffset, unsigned int usersize)
 {
 	int err;
+	unsigned int align = ARCH_KMALLOC_MINALIGN;
 
 	s->name = name;
 	s->size = s->object_size = size;
-	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
+
+	/*
+	 * For power of two sizes, guarantee natural alignment for kmalloc
+	 * caches, regardless of SL*B debugging options.
+	 */
+	if (is_power_of_2(size))
+		align = max(align, size);
+	s->align = calculate_alignment(flags, align, size);
+
 	s->useroffset = useroffset;
 	s->usersize = usersize;
 
diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..e100fa09493f 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -215,7 +215,8 @@ static void slob_free_pages(void *b, int order)
 /*
  * Allocate a slob block within a given slob_page sp.
  */
-static void *slob_page_alloc(struct page *sp, size_t size, int align)
+static void *slob_page_alloc(struct page *sp, size_t size, int align,
+							int align_offset)
 {
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
@@ -223,8 +224,17 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 	for (prev = NULL, cur = sp->freelist; ; prev = cur, cur = slob_next(cur)) {
 		slobidx_t avail = slob_units(cur);
 
+		/*
+		 * 'aligned' will hold the address of the slob block so that the
+		 * address 'aligned'+'align_offset' is aligned according to the
+		 * 'align' parameter. This is for kmalloc() which prepends the
+		 * allocated block with its size, so that the block itself is
+		 * aligned when needed.
+		 */
 		if (align) {
-			aligned = (slob_t *)ALIGN((unsigned long)cur, align);
+			aligned = (slob_t *)
+				(ALIGN((unsigned long)cur + align_offset, align)
+				 - align_offset);
 			delta = aligned - cur;
 		}
 		if (avail >= units + delta) { /* room enough? */
@@ -266,7 +276,8 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 /*
  * slob_alloc: entry point into the slob allocator.
  */
-static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
+static void *slob_alloc(size_t size, gfp_t gfp, int align, int node,
+							int align_offset)
 {
 	struct page *sp;
 	struct list_head *prev;
@@ -298,7 +309,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 		/* Attempt to alloc */
 		prev = sp->lru.prev;
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(sp, size, align, align_offset);
 		if (!b)
 			continue;
 
@@ -326,7 +337,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		INIT_LIST_HEAD(&sp->lru);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(sp, size, align, align_offset);
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
@@ -428,7 +439,7 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 {
 	unsigned int *m;
-	int align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	int minalign = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	void *ret;
 
 	gfp &= gfp_allowed_mask;
@@ -436,19 +447,28 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 	fs_reclaim_acquire(gfp);
 	fs_reclaim_release(gfp);
 
-	if (size < PAGE_SIZE - align) {
+	if (size < PAGE_SIZE - minalign) {
+		int align = minalign;
+
+		/*
+		 * For power of two sizes, guarantee natural alignment for
+		 * kmalloc()'d objects.
+		 */
+		if (is_power_of_2(size))
+			align = max(minalign, (int) size);
+
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-		m = slob_alloc(size + align, gfp, align, node);
+		m = slob_alloc(size + minalign, gfp, align, node, minalign);
 
 		if (!m)
 			return NULL;
 		*m = size;
-		ret = (void *)m + align;
+		ret = (void *)m + minalign;
 
 		trace_kmalloc_node(caller, ret,
-				   size, size + align, gfp, node);
+				   size, size + minalign, gfp, node);
 	} else {
 		unsigned int order = get_order(size);
 
@@ -544,7 +564,7 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 	fs_reclaim_release(flags);
 
 	if (c->size < PAGE_SIZE) {
-		b = slob_alloc(c->size, flags, c->align, node);
+		b = slob_alloc(c->size, flags, c->align, node, 0);
 		trace_kmem_cache_alloc_node(_RET_IP_, b, c->object_size,
 					    SLOB_UNITS(c->size) * SLOB_UNIT,
 					    flags, node);
-- 
2.21.0

