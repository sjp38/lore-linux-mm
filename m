Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 014FDC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:49:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90AA8217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:49:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TE/rFngG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90AA8217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 180CD6B000D; Fri, 24 May 2019 11:49:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 131E26B000E; Fri, 24 May 2019 11:49:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3BF46B0010; Fri, 24 May 2019 11:49:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 688026B000D
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:49:24 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id f15so1808586lfc.10
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:49:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-transfer-encoding;
        bh=6DVuf6G0pnmFLgrCnuOoTLUpwesl0ogSQoeGJ38/Nqk=;
        b=TsFgSitK2o6IFIvXgSQbswL3lGr2I9vdUYqf9V3xKR5TuxEXlqO0Nn/B4Mi5CMtOdR
         Wz20jLN+jOuudnDD2zeiEjCRmzQzGUlc4ut6w50yjCG53qOm6bRQ6P8Zjny58gxhfiDu
         P6lrPstQDtOmHMbP8WZy6yXFfauos+t6dyPWozqY1/tf7Wx6iZQIiTZO0KG6pIaAi63t
         CquhbHP5gnSS6yMDypweW0OxtYnHuMMixsarEaLnNsAVvcG2LguGn8XBF1iusl0MV8VI
         +pRU+VnSir8p6S/Ksm3tAyoOay+HKfd6jBEHtEv/2OozP5JVLdy9XnVldq2nZ43Lilnj
         te8g==
X-Gm-Message-State: APjAAAVVbu5Ka2BbpEbpvpKqhk9DLIPQN9zCJnbG35LP7D0GEkVECGLX
	kQlXRQh/prop0wgbmn/898SG8Bl1ovMUuGvdyKDlT/3hUNXGjjElrBCNyOklvf/l2C7r1zcu4AK
	siAWVlYdQl042bOI9/g3huXxds0pZdriDN/GaTwUD2oraHDnIfC4Zq72K2SCibnEDjg==
X-Received: by 2002:a2e:8985:: with SMTP id c5mr8599862lji.84.1558712963580;
        Fri, 24 May 2019 08:49:23 -0700 (PDT)
X-Received: by 2002:a2e:8985:: with SMTP id c5mr8599776lji.84.1558712961841;
        Fri, 24 May 2019 08:49:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558712961; cv=none;
        d=google.com; s=arc-20160816;
        b=dmfzhBsCEbSPxOqXbFfMP7eZYY3+P5sbNGEiixLtd4Tzj9OLXXBw2WDjuXIQoCAH9l
         icaZqKQJpUKdncDuf+AxVaQS7k597GCejh+/s8zH1s8X/QX6qoBXwYkh9nUMU6R/3Q/k
         5ohjyOUI3cR+Pt1NEpcOWQiXQa4b8fxlDTmfEbAMVnZUn7QYEcMqmLqgPkInmxyRi2r0
         OvdZaHcBa/VVnSWDduzWjNGgFwXV6odWCoKvPAC5hONvkMqfeHSdUgUUbNHZtzTxvaYN
         hSirUqsR9elhBkD1bBww1RNkAdhM1RlZLDBkLaqrot9W6dcCVJWPyLvHbwwm+GV/iizc
         PR6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date:dkim-signature;
        bh=6DVuf6G0pnmFLgrCnuOoTLUpwesl0ogSQoeGJ38/Nqk=;
        b=wk8s5Zqvf/zYIH473SBRD1GIc9fRfwOzktvwwMFo2t8xOStW/9GXjOCHs22MZFAO4u
         BJ/KY2w9sf4Gk9qB0/ZQgEH2VdHgwx+TBPgbuclj5Zk+h2gDZKVBbDZFvGDC97Cx3Sbj
         mC6OGCWyIaep6JY4LNH5fwEm4hT4XH2woln4uWgDFho84tPgwkv/pQTDI4U6Id1nhXLk
         nOBdmDf5nu7gNOW+vHiX+ACjh7ysdW4ULhj6ZBay5fNh7vmHVMKjbmP/zKIlbPjUN0vu
         WkkCnDmnQ6ayFS+JRfyPwp5YzWrbwI8h814g9cCuoLeER+s/MhlyZg+4oxIYHZK54u6O
         xA9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="TE/rFngG";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor1032650lfg.41.2019.05.24.08.49.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 08:49:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="TE/rFngG";
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=6DVuf6G0pnmFLgrCnuOoTLUpwesl0ogSQoeGJ38/Nqk=;
        b=TE/rFngG/4Ul87RlD4i5uFnRo73KjG6OJ7BhFGLnUuOYXDsARSDIIUl7c8mx9OtoZo
         MwDGJqTVPis1Wk6ZTsESiIicxCB6jR25XVw6LDlIGfuWYE+E+l6WaZTE2ab+caMvW97Q
         5JwE5LURU1qgwkfTclYNJOU9tdTsPBiVMKhiMCz4n/b8I0JPzJBbz7C6fSVqplzc6Px3
         fduOdWbAKqyui1C88A4KcJcGfyKUNhyR3vKMyZ+2hCxzl1bHKEGrbQ3qHHQNZJRVelwA
         3f9FD5mWAyBh60Yaiwe2eqIEGtz28fEDGD2yUKGLW4Yv7xPXQTY2McHhsypW+8lTATsM
         gZUg==
X-Google-Smtp-Source: APXvYqw70E6dpuUL3aXhUnwXYv7o80enHKDmM+y8v298qQ3HchQvRQqSUSxGHdfdhWLjKGXczoWtWg==
X-Received: by 2002:ac2:43b7:: with SMTP id t23mr2203332lfl.26.1558712960849;
        Fri, 24 May 2019 08:49:20 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id h14sm579945ljj.11.2019.05.24.08.49.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 08:49:20 -0700 (PDT)
Date: Fri, 24 May 2019 17:49:18 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Uladzislau Rezki
 <urezki@gmail.com>
Subject: [PATCH] z3fold: add inter-page compaction
Message-Id: <20190524174918.71074b358001bdbf1c23cd77@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For each page scheduled for compaction (e. g. by z3fold_free()),
try to apply inter-page compaction before running the traditional/
existing intra-page compaction. That means, if the page has only one
buddy, we treat that buddy as a new object that we aim to place into
an existing z3fold page. If such a page is found, that object is
transferred and the old page is freed completely. The transferred
object is named "foreign" and treated slightly differently thereafter.

Namely, we increase "foreign handle" counter for the new page. Pages
with non-zero "foreign handle" count become unmovable. This patch
implements "foreign handle" detection when a handle is freed to
decrement the foreign handle counter accordingly, so a page may as
well become movable again as the time goes by.

As a result, we almost always have exactly 3 objects per page and
significantly better average compression ratio.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 328 +++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 285 insertions(+), 43 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 985732c8b025..d82bccc8bc90 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -41,6 +41,7 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
+#include <linux/seqlock.h>
 #include <linux/zpool.h>
 
 /*
@@ -89,6 +90,7 @@ struct z3fold_buddy_slots {
 	 */
 	unsigned long slot[BUDDY_MASK + 1];
 	unsigned long pool; /* back link + flags */
+	seqlock_t seqlock;
 };
 #define HANDLE_FLAG_MASK	(0x03)
 
@@ -121,6 +123,7 @@ struct z3fold_header {
 	unsigned short start_middle;
 	unsigned short first_num:2;
 	unsigned short mapped_count:2;
+	unsigned short foreign_handles:2;
 };
 
 /**
@@ -175,6 +178,18 @@ enum z3fold_page_flags {
 	PAGE_CLAIMED, /* by either reclaim or free */
 };
 
+/*
+ * handle flags, go under HANDLE_FLAG_MASK
+ */
+enum z3fold_handle_flags {
+	HANDLES_ORPHANED = 0,
+};
+
+static inline struct z3fold_header *handle_to_z3fold_header(unsigned long);
+static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *);
+static struct z3fold_header *__z3fold_alloc(struct z3fold_pool *, size_t, bool);
+static void add_to_unbuddied(struct z3fold_pool *, struct z3fold_header *);
+
 /*****************
  * Helpers
 *****************/
@@ -199,6 +214,7 @@ static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
 	if (slots) {
 		memset(slots->slot, 0, sizeof(slots->slot));
 		slots->pool = (unsigned long)pool;
+		seqlock_init(&slots->seqlock);
 	}
 
 	return slots;
@@ -217,24 +233,39 @@ static inline struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
 static inline void free_handle(unsigned long handle)
 {
 	struct z3fold_buddy_slots *slots;
+	struct z3fold_header *zhdr;
 	int i;
 	bool is_free;
+	unsigned int seq;
 
 	if (handle & (1 << PAGE_HEADLESS))
 		return;
 
-	WARN_ON(*(unsigned long *)handle == 0);
-	*(unsigned long *)handle = 0;
+	if (WARN_ON(*(unsigned long *)handle == 0))
+		return;
+
+	zhdr = handle_to_z3fold_header(handle);
 	slots = handle_to_slots(handle);
-	is_free = true;
-	for (i = 0; i <= BUDDY_MASK; i++) {
-		if (slots->slot[i]) {
-			is_free = false;
-			break;
+	write_seqlock(&slots->seqlock);
+	*(unsigned long *)handle = 0;
+	write_sequnlock(&slots->seqlock);
+	if (zhdr->slots == slots)
+		return; /* simple case, nothing else to do */
+
+	/* we are freeing a foreign handle if we are here */
+	zhdr->foreign_handles--;
+	do {
+		is_free = true;
+		seq = read_seqbegin(&slots->seqlock);
+		for (i = 0; i <= BUDDY_MASK; i++) {
+			if (slots->slot[i]) {
+				is_free = false;
+				break;
+			}
 		}
-	}
+	} while (read_seqretry(&slots->seqlock, seq));
 
-	if (is_free) {
+	if (is_free && test_and_clear_bit(HANDLES_ORPHANED, &slots->pool)) {
 		struct z3fold_pool *pool = slots_to_pool(slots);
 
 		kmem_cache_free(pool->c_handle, slots);
@@ -320,6 +351,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	zhdr->start_middle = 0;
 	zhdr->cpu = -1;
 	zhdr->slots = slots;
+	zhdr->foreign_handles = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
@@ -385,25 +417,87 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 		h |= (zhdr->last_chunks << BUDDY_SHIFT);
 
 	slots = zhdr->slots;
+	write_seqlock(&slots->seqlock);
 	slots->slot[idx] = h;
+	write_sequnlock(&slots->seqlock);
 	return (unsigned long)&slots->slot[idx];
 }
 
+static inline struct z3fold_header *__get_z3fold_header(unsigned long handle,
+							bool lock)
+{
+	struct z3fold_buddy_slots *slots;
+	struct z3fold_header *zhdr;
+	unsigned int seq;
+	bool is_valid;
+
+	if (!(handle & (1 << PAGE_HEADLESS))) {
+		slots = handle_to_slots(handle);
+		do {
+			unsigned long addr;
+
+			seq = read_seqbegin(&slots->seqlock);
+			addr = *(unsigned long *)handle;
+			zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
+			preempt_disable();
+			is_valid = !read_seqretry(&slots->seqlock, seq);
+			if (!is_valid) {
+				preempt_enable();
+				continue;
+			}
+			/*
+			 * if we are here, zhdr is a pointer to a valid z3fold
+			 * header. Lock it! And then re-check if someone has
+			 * changed which z3fold page this handle points to
+			 */
+			if (lock)
+				z3fold_page_lock(zhdr);
+			preempt_enable();
+			/*
+			 * we use is_valid as a "cached" value: if it's false,
+			 * no other checks needed, have to go one more round
+			 */
+		} while (!is_valid || (read_seqretry(&slots->seqlock, seq) &&
+			(lock ? ({ z3fold_page_unlock(zhdr); 1; }) : 1)));
+	} else {
+		zhdr = (struct z3fold_header *)(handle & PAGE_MASK);
+	}
+
+	return zhdr;
+}
+
+
 /* Returns the z3fold page where a given handle is stored */
 static inline struct z3fold_header *handle_to_z3fold_header(unsigned long h)
 {
-	unsigned long addr = h;
+	return __get_z3fold_header(h, false);
+}
+
+/* return locked z3fold page if it's not headless */
+static inline struct z3fold_header *get_z3fold_header(unsigned long h)
+{
+	return __get_z3fold_header(h, true);
+}
 
-	if (!(addr & (1 << PAGE_HEADLESS)))
-		addr = *(unsigned long *)h;
+static inline void put_z3fold_header(struct z3fold_header *zhdr)
+{
+	struct page *page = virt_to_page(zhdr);
 
-	return (struct z3fold_header *)(addr & PAGE_MASK);
+	if (!test_bit(PAGE_HEADLESS, &page->private))
+		z3fold_page_unlock(zhdr);
 }
 
 /* only for LAST bud, returns zero otherwise */
 static unsigned short handle_to_chunks(unsigned long handle)
 {
-	unsigned long addr = *(unsigned long *)handle;
+	unsigned long addr;
+	struct z3fold_buddy_slots *slots = handle_to_slots(handle);
+	unsigned int seq;
+
+	do {
+		seq = read_seqbegin(&slots->seqlock);
+		addr = *(unsigned long *)handle;
+	} while (read_seqretry(&slots->seqlock, seq));
 
 	return (addr & ~PAGE_MASK) >> BUDDY_SHIFT;
 }
@@ -417,9 +511,15 @@ static enum buddy handle_to_buddy(unsigned long handle)
 {
 	struct z3fold_header *zhdr;
 	unsigned long addr;
+	struct z3fold_buddy_slots *slots;
+	unsigned int seq;
 
 	WARN_ON(handle & (1 << PAGE_HEADLESS));
-	addr = *(unsigned long *)handle;
+	slots = handle_to_slots(handle);
+	do {
+		seq = read_seqbegin(&slots->seqlock);
+		addr = *(unsigned long *)handle;
+	} while (read_seqretry(&slots->seqlock, seq));
 	zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
 	return (addr - zhdr->first_num) & BUDDY_MASK;
 }
@@ -433,6 +533,9 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 {
 	struct page *page = virt_to_page(zhdr);
 	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	unsigned int seq;
+	bool is_free;
+	int i;
 
 	WARN_ON(!list_empty(&zhdr->buddy));
 	set_bit(PAGE_STALE, &page->private);
@@ -441,8 +544,27 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 	if (!list_empty(&page->lru))
 		list_del_init(&page->lru);
 	spin_unlock(&pool->lock);
+
+	/* If there are no foreign handles, free the handles array */
+	do {
+		is_free = true;
+		seq = read_seqbegin(&zhdr->slots->seqlock);
+		for (i = 0; i <= BUDDY_MASK; i++) {
+			if (zhdr->slots->slot[i]) {
+				is_free = false;
+				break;
+			}
+		}
+	} while (read_seqretry(&zhdr->slots->seqlock, seq));
+
+	if (is_free)
+		kmem_cache_free(pool->c_handle, zhdr->slots);
+	else
+		set_bit(HANDLES_ORPHANED, &zhdr->slots->pool);
+
 	if (locked)
 		z3fold_page_unlock(zhdr);
+
 	spin_lock(&pool->stale_lock);
 	list_add(&zhdr->buddy, &pool->stale);
 	queue_work(pool->release_wq, &pool->work);
@@ -470,6 +592,7 @@ static void release_z3fold_page_locked_list(struct kref *ref)
 	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
 					       refcount);
 	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+
 	spin_lock(&pool->lock);
 	list_del_init(&zhdr->buddy);
 	spin_unlock(&pool->lock);
@@ -550,6 +673,119 @@ static inline void *mchunk_memmove(struct z3fold_header *zhdr,
 		       zhdr->middle_chunks << CHUNK_SHIFT);
 }
 
+static inline bool buddy_single(struct z3fold_header *zhdr)
+{
+	return !((zhdr->first_chunks && zhdr->middle_chunks) ||
+			(zhdr->first_chunks && zhdr->last_chunks) ||
+			(zhdr->middle_chunks && zhdr->last_chunks));
+}
+
+static struct z3fold_header *compact_single_buddy(struct z3fold_header *zhdr)
+{
+	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	void *p = zhdr;
+	unsigned long old_handle = 0;
+	enum buddy bud;
+	size_t sz = 0;
+	struct z3fold_header *new_zhdr = NULL;
+	int first_idx = __idx(zhdr, FIRST);
+	int middle_idx = __idx(zhdr, MIDDLE);
+	int last_idx = __idx(zhdr, LAST);
+
+	/*
+	 * No need to protect slots here -- all the slots are "local" and
+	 * the page lock is already taken
+	 */
+	if (zhdr->first_chunks && zhdr->slots->slot[first_idx]) {
+		bud = FIRST;
+		p += ZHDR_SIZE_ALIGNED;
+		sz = zhdr->first_chunks << CHUNK_SHIFT;
+		old_handle = (unsigned long)&zhdr->slots->slot[first_idx];
+	} else if (zhdr->middle_chunks && zhdr->slots->slot[middle_idx]) {
+		bud = MIDDLE;
+		p += zhdr->start_middle << CHUNK_SHIFT;
+		sz = zhdr->middle_chunks << CHUNK_SHIFT;
+		old_handle = (unsigned long)&zhdr->slots->slot[middle_idx];
+	} else if (zhdr->last_chunks && zhdr->slots->slot[last_idx]) {
+		bud = LAST;
+		p += PAGE_SIZE - (zhdr->last_chunks << CHUNK_SHIFT);
+		sz = zhdr->last_chunks << CHUNK_SHIFT;
+		old_handle = (unsigned long)&zhdr->slots->slot[last_idx];
+	}
+
+	if (sz > 0) {
+		struct page *newpage;
+		enum buddy new_bud = HEADLESS;
+		short chunks = size_to_chunks(sz);
+		void *q;
+
+		new_zhdr = __z3fold_alloc(pool, sz, false);
+		if (!new_zhdr)
+			return NULL;
+
+		newpage = virt_to_page(new_zhdr);
+		if (WARN_ON(new_zhdr == zhdr))
+			goto out_fail;
+
+		if (new_zhdr->first_chunks == 0) {
+			if (new_zhdr->middle_chunks != 0 &&
+					chunks >= new_zhdr->start_middle) {
+				new_bud = LAST;
+			} else {
+				new_bud = FIRST;
+			}
+		} else if (new_zhdr->last_chunks == 0) {
+			new_bud = LAST;
+		} else if (new_zhdr->middle_chunks == 0) {
+			new_bud = MIDDLE;
+		}
+		q = new_zhdr;
+		switch (new_bud) {
+		case FIRST:
+			new_zhdr->first_chunks = chunks;
+			q += ZHDR_SIZE_ALIGNED;
+			break;
+		case MIDDLE:
+			new_zhdr->middle_chunks = chunks;
+			new_zhdr->start_middle =
+				new_zhdr->first_chunks + ZHDR_CHUNKS;
+			q += new_zhdr->start_middle << CHUNK_SHIFT;
+			break;
+		case LAST:
+			new_zhdr->last_chunks = chunks;
+			q += PAGE_SIZE - (new_zhdr->last_chunks << CHUNK_SHIFT);
+			break;
+		default:
+			goto out_fail;
+		}
+		new_zhdr->foreign_handles++;
+		memcpy(q, p, sz);
+		write_seqlock(&zhdr->slots->seqlock);
+		*(unsigned long *)old_handle = (unsigned long)new_zhdr +
+			__idx(new_zhdr, new_bud);
+		if (new_bud == LAST)
+			*(unsigned long *)old_handle |=
+					(new_zhdr->last_chunks << BUDDY_SHIFT);
+		write_sequnlock(&zhdr->slots->seqlock);
+		add_to_unbuddied(pool, new_zhdr);
+		z3fold_page_unlock(new_zhdr);
+	}
+
+	return new_zhdr;
+
+out_fail:
+	if (new_zhdr) {
+		if (kref_put(&new_zhdr->refcount, release_z3fold_page_locked))
+			atomic64_dec(&pool->pages_nr);
+		else {
+			add_to_unbuddied(pool, new_zhdr);
+			z3fold_page_unlock(new_zhdr);
+		}
+	}
+	return NULL;
+
+}
+
 #define BIG_CHUNK_GAP	3
 /* Has to be called with lock held */
 static int z3fold_compact_page(struct z3fold_header *zhdr)
@@ -559,9 +795,6 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
 		return 0; /* can't move middle chunk, it's used */
 
-	if (unlikely(PageIsolated(page)))
-		return 0;
-
 	if (zhdr->middle_chunks == 0)
 		return 0; /* nothing to compact */
 
@@ -628,6 +861,15 @@ static void do_compact_page(struct z3fold_header *zhdr, bool locked)
 		return;
 	}
 
+	if (!zhdr->foreign_handles && buddy_single(zhdr) &&
+			compact_single_buddy(zhdr)) {
+		if (kref_put(&zhdr->refcount, release_z3fold_page_locked))
+			atomic64_dec(&pool->pages_nr);
+		else
+			z3fold_page_unlock(zhdr);
+		return;
+	}
+
 	z3fold_compact_page(zhdr);
 	add_to_unbuddied(pool, zhdr);
 	z3fold_page_unlock(zhdr);
@@ -968,11 +1210,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 {
 	struct z3fold_header *zhdr;
 	struct page *page;
-	enum buddy bud;
+	enum buddy bud = LAST; /* initialize to !HEADLESS */
 
-	zhdr = handle_to_z3fold_header(handle);
-	page = virt_to_page(zhdr);
+	zhdr = get_z3fold_header(handle);
 
+	page = virt_to_page(zhdr);
 	if (test_bit(PAGE_HEADLESS, &page->private)) {
 		/* if a headless page is under reclaim, just leave.
 		 * NB: we use test_and_set_bit for a reason: if the bit
@@ -983,6 +1225,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 			spin_lock(&pool->lock);
 			list_del(&page->lru);
 			spin_unlock(&pool->lock);
+			put_z3fold_header(zhdr);
 			free_z3fold_page(page, true);
 			atomic64_dec(&pool->pages_nr);
 		}
@@ -990,7 +1233,6 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 
 	/* Non-headless case */
-	z3fold_page_lock(zhdr);
 	bud = handle_to_buddy(handle);
 
 	switch (bud) {
@@ -1006,7 +1248,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	default:
 		pr_err("%s: unknown bud %d\n", __func__, bud);
 		WARN_ON(1);
-		z3fold_page_unlock(zhdr);
+		put_z3fold_header(zhdr);
 		return;
 	}
 
@@ -1021,7 +1263,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 	if (unlikely(PageIsolated(page)) ||
 	    test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
-		z3fold_page_unlock(zhdr);
+		put_z3fold_header(zhdr);
 		return;
 	}
 	if (zhdr->cpu < 0 || !cpu_online(zhdr->cpu)) {
@@ -1035,7 +1277,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 	kref_get(&zhdr->refcount);
 	queue_work_on(zhdr->cpu, pool->compact_wq, &zhdr->work);
-	z3fold_page_unlock(zhdr);
+	put_z3fold_header(zhdr);
 }
 
 /**
@@ -1217,14 +1459,13 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	zhdr = handle_to_z3fold_header(handle);
+	zhdr = get_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
 
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		goto out;
 
-	z3fold_page_lock(zhdr);
 	buddy = handle_to_buddy(handle);
 	switch (buddy) {
 	case FIRST:
@@ -1246,8 +1487,8 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 
 	if (addr)
 		zhdr->mapped_count++;
-	z3fold_page_unlock(zhdr);
 out:
+	put_z3fold_header(zhdr);
 	return addr;
 }
 
@@ -1262,18 +1503,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy buddy;
 
-	zhdr = handle_to_z3fold_header(handle);
+	zhdr = get_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		return;
 
-	z3fold_page_lock(zhdr);
 	buddy = handle_to_buddy(handle);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 	zhdr->mapped_count--;
-	z3fold_page_unlock(zhdr);
+	put_z3fold_header(zhdr);
 }
 
 /**
@@ -1304,19 +1544,21 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 	    test_bit(PAGE_STALE, &page->private))
 		goto out;
 
+	if (zhdr->mapped_count != 0 || zhdr->foreign_handles != 0)
+		goto out;
+
 	pool = zhdr_to_pool(zhdr);
+	spin_lock(&pool->lock);
+	if (!list_empty(&zhdr->buddy))
+		list_del_init(&zhdr->buddy);
+	if (!list_empty(&page->lru))
+		list_del_init(&page->lru);
+	spin_unlock(&pool->lock);
+
+	kref_get(&zhdr->refcount);
+	z3fold_page_unlock(zhdr);
+	return true;
 
-	if (zhdr->mapped_count == 0) {
-		kref_get(&zhdr->refcount);
-		if (!list_empty(&zhdr->buddy))
-			list_del_init(&zhdr->buddy);
-		spin_lock(&pool->lock);
-		if (!list_empty(&page->lru))
-			list_del(&page->lru);
-		spin_unlock(&pool->lock);
-		z3fold_page_unlock(zhdr);
-		return true;
-	}
 out:
 	z3fold_page_unlock(zhdr);
 	return false;
@@ -1342,7 +1584,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 		unlock_page(page);
 		return -EAGAIN;
 	}
-	if (zhdr->mapped_count != 0) {
+	if (zhdr->mapped_count != 0 || zhdr->foreign_handles != 0) {
 		z3fold_page_unlock(zhdr);
 		unlock_page(page);
 		return -EBUSY;
-- 
2.17.1

