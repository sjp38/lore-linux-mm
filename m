Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D49B6C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:08:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59CD02075C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 12:08:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sqxrywBk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59CD02075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9E466B027B; Mon, 27 May 2019 08:08:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B4E266B027C; Mon, 27 May 2019 08:08:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CA396B027D; Mon, 27 May 2019 08:08:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 145E06B027B
	for <linux-mm@kvack.org>; Mon, 27 May 2019 08:08:53 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id m2so3164149ljj.13
        for <linux-mm@kvack.org>; Mon, 27 May 2019 05:08:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-transfer-encoding;
        bh=xlxG1BvZvD+NUzbTb2SylxF0XwZGfTGANKHpXeuWu2Y=;
        b=nTFmJ+GNAKXNU+Rl01o9Wo1rXhF/Vyg9QvgIZEgiVhvM4GtizLvY2jTp2WNcohevzE
         rZ3b+gRdPcT+FFQdkDoL85Uh2+X9H1xNvp9ZeqIk6QOa1R9AmoQUPdCkZk5g+Wk0kYkU
         +yryjDj7MbEYonbnsoJpSKgUy7R+J8EYOnkSXRy60cWuXWYvnx1hwzNVZlOzsyW5rByq
         1PI9vSHRdQU3tDwcOE8hTbe5g+eC7qNFGXkSf+mbxR8+vSK7pPTjXomOE+8quOwD1SIc
         lo/+Der5iOOVvrV+4LYkNC5JeFZdigM9woBQER9zn6xacnLEVUreogUc71/qWOkD6FXi
         8OzQ==
X-Gm-Message-State: APjAAAUr3CYrIHZYyxHr2AJbkLXDXZ1S2Xdam6Xx7vVW8beMyXsHoWwU
	L85xDYfCMcorWU8FyJTzkJ1+lYABbykgjVpUTuNFE9zHhrEbHVHAukkKJjKbs3/Blt5kHha4lKA
	1QD7hyGjwUnbRMGHDBomcTybJOty8E68Ou9xzsHrUiFD5yHV9N3C1LatWM8jNveljCg==
X-Received: by 2002:a19:6a0c:: with SMTP id u12mr34460255lfu.109.1558958932187;
        Mon, 27 May 2019 05:08:52 -0700 (PDT)
X-Received: by 2002:a19:6a0c:: with SMTP id u12mr34460186lfu.109.1558958930466;
        Mon, 27 May 2019 05:08:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558958930; cv=none;
        d=google.com; s=arc-20160816;
        b=vEk/AmV2We/YSRposG8GRre+MwpPBFrX0A4xCKZhujN74tTs7JgXAYFgCgF8yC3fvm
         5Shygx925OWBfUKJ9SSUf/3SxwISPnuNagVssAnR2x5/wb4a3ysKWROhHIKfFR/t6IyI
         SdDDTWrwsVK8+iLHVj4mZWdAmS6z3/nLSj0GcaDjoAT54hUenhgpDlxPyhhgKDxvVugx
         n6God6336s+11j4GN01Q9ljAYvZ2+G8dPvPhiabdIJehqjxwWcPAhXF/0sTJFhDVVvQF
         Uq+4B2Ivrfga1psZeRldsdPUvtMMKDH4mYKVw8PO9GrDXrNDLOMdhWsHTbzjOaufOSWF
         f6mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:subject:cc:to
         :from:date:dkim-signature;
        bh=xlxG1BvZvD+NUzbTb2SylxF0XwZGfTGANKHpXeuWu2Y=;
        b=zlZtLaLROyeTltaoimXh3RGCdG+4r4WK3n56WVcRncDVn6wVRyMnKO2zbqCrhu4l+Z
         7pSAly2y1MJW0520C380NIiaUn87CzfB/uBcKhzpIDE+1wF1P6HjeMEfm26ldaIUKuA2
         aB4OeVhSA3JnWAXoWJEWXDctQ4oW20NYYAmCViSi096EsuhuZAt89BSYWio17VUqnT6j
         k2OsNLS0RfBSAMC3cS38izreC/BpX9Vsi5CHBsG82ROP2f44ICNz/MX0/7vQyHUJb+nd
         65HqStugS/2a5qXkRS9it2VFITHkvX4cdbNch/Wppvwf3pXAPw1EEYRBvbatvP4S1KWw
         iEfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sqxrywBk;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f16sor2676014lfa.49.2019.05.27.05.08.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 05:08:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sqxrywBk;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=xlxG1BvZvD+NUzbTb2SylxF0XwZGfTGANKHpXeuWu2Y=;
        b=sqxrywBkiJUnQDhBJbDp/09+RA3SnIcxsMpTCLFmkrR2qaFR5DBLEr25MrCLeEFiBx
         zDBvGPkEhmS7LbRMRF8Ng9Q0TgBZM++9jDRra/JSDrPhAPwWDsf2GUH90wDNInoEWysv
         UibAzclg+J3093YRmc6uDqoAOZJUax4/XDa1MXpEEey2gFNXZrCLoLki3JOvZMHCygZt
         MRMzPfk06wqUoe9/eOo+MfqUXHBaZ7+71knbhLCFUJSOrm/3j2uJdhrVcuwmS5kNY9Nb
         wH1O6bT+xcCG7VeadcFcEzmvBJPISnqjxfqdb20xYpBYVQaD/8Z5S0/3Yh0s/U29c/+a
         fzxA==
X-Google-Smtp-Source: APXvYqzMl+fAIsVrKKkDudPSWUEGBPkdjrEbaaBMnMcZLVcYkoRYdwx0fSfzOUz6VAgFdCNzbK0UYQ==
X-Received: by 2002:a19:ee0a:: with SMTP id g10mr23288688lfb.127.1558958929425;
        Mon, 27 May 2019 05:08:49 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id w11sm2252789lfe.32.2019.05.27.05.08.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 05:08:48 -0700 (PDT)
Date: Mon, 27 May 2019 14:08:47 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Uladzislau Rezki
 <urezki@gmail.com>
Subject: [PATCH v2] z3fold: add inter-page compaction
Message-Id: <20190527140847.a946dcfed436c959ae2e4c09@gmail.com>
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

Changes from v1:
* balanced use of inlining
* more comments in the key parts of code
* code rearranged to avoid forward declarations
* rwlock instead of seqlock

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 538 ++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 373 insertions(+), 165 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 985732c8b025..2bc3dbde6255 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -89,6 +89,7 @@ struct z3fold_buddy_slots {
 	 */
 	unsigned long slot[BUDDY_MASK + 1];
 	unsigned long pool; /* back link + flags */
+	rwlock_t lock;
 };
 #define HANDLE_FLAG_MASK	(0x03)
 
@@ -121,6 +122,7 @@ struct z3fold_header {
 	unsigned short start_middle;
 	unsigned short first_num:2;
 	unsigned short mapped_count:2;
+	unsigned short foreign_handles:2;
 };
 
 /**
@@ -175,6 +177,14 @@ enum z3fold_page_flags {
 	PAGE_CLAIMED, /* by either reclaim or free */
 };
 
+/*
+ * handle flags, go under HANDLE_FLAG_MASK
+ */
+enum z3fold_handle_flags {
+	HANDLES_ORPHANED = 0,
+};
+
+
 /*****************
  * Helpers
 *****************/
@@ -199,6 +209,7 @@ static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
 	if (slots) {
 		memset(slots->slot, 0, sizeof(slots->slot));
 		slots->pool = (unsigned long)pool;
+		rwlock_init(&slots->lock);
 	}
 
 	return slots;
@@ -214,33 +225,6 @@ static inline struct z3fold_buddy_slots *handle_to_slots(unsigned long handle)
 	return (struct z3fold_buddy_slots *)(handle & ~(SLOTS_ALIGN - 1));
 }
 
-static inline void free_handle(unsigned long handle)
-{
-	struct z3fold_buddy_slots *slots;
-	int i;
-	bool is_free;
-
-	if (handle & (1 << PAGE_HEADLESS))
-		return;
-
-	WARN_ON(*(unsigned long *)handle == 0);
-	*(unsigned long *)handle = 0;
-	slots = handle_to_slots(handle);
-	is_free = true;
-	for (i = 0; i <= BUDDY_MASK; i++) {
-		if (slots->slot[i]) {
-			is_free = false;
-			break;
-		}
-	}
-
-	if (is_free) {
-		struct z3fold_pool *pool = slots_to_pool(slots);
-
-		kmem_cache_free(pool->c_handle, slots);
-	}
-}
-
 static struct dentry *z3fold_do_mount(struct file_system_type *fs_type,
 				int flags, const char *dev_name, void *data)
 {
@@ -320,6 +304,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
 	zhdr->start_middle = 0;
 	zhdr->cpu = -1;
 	zhdr->slots = slots;
+	zhdr->foreign_handles = 0;
 	INIT_LIST_HEAD(&zhdr->buddy);
 	INIT_WORK(&zhdr->work, compact_page_work);
 	return zhdr;
@@ -361,6 +346,55 @@ static inline int __idx(struct z3fold_header *zhdr, enum buddy bud)
 	return (bud + zhdr->first_num) & BUDDY_MASK;
 }
 
+static inline struct z3fold_header *__get_z3fold_header(unsigned long handle,
+							bool lock)
+{
+	struct z3fold_buddy_slots *slots;
+	struct z3fold_header *zhdr;
+
+	if (!(handle & (1 << PAGE_HEADLESS))) {
+		slots = handle_to_slots(handle);
+		do {
+			unsigned long addr;
+
+			read_lock(&slots->lock);
+			addr = *(unsigned long *)handle;
+			zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
+			if (lock && z3fold_page_trylock(zhdr)) {
+				read_unlock(&slots->lock);
+				break;
+			}
+			read_unlock(&slots->lock);
+			cpu_relax();
+		} while (lock);
+	} else {
+		zhdr = (struct z3fold_header *)(handle & PAGE_MASK);
+	}
+
+	return zhdr;
+}
+
+
+/* Returns the z3fold page where a given handle is stored */
+static struct z3fold_header *handle_to_z3fold_header(unsigned long h)
+{
+	return __get_z3fold_header(h, false);
+}
+
+/* return locked z3fold page if it's not headless */
+static struct z3fold_header *get_z3fold_header(unsigned long h)
+{
+	return __get_z3fold_header(h, true);
+}
+
+static void put_z3fold_header(struct z3fold_header *zhdr)
+{
+	struct page *page = virt_to_page(zhdr);
+
+	if (!test_bit(PAGE_HEADLESS, &page->private))
+		z3fold_page_unlock(zhdr);
+}
+
 /*
  * Encodes the handle of a particular buddy within a z3fold page
  * Pool lock should be held as this function accesses first_num
@@ -385,22 +419,56 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
 		h |= (zhdr->last_chunks << BUDDY_SHIFT);
 
 	slots = zhdr->slots;
+	write_lock(&slots->lock);
 	slots->slot[idx] = h;
+	write_unlock(&slots->lock);
 	return (unsigned long)&slots->slot[idx];
 }
 
-/* Returns the z3fold page where a given handle is stored */
-static inline struct z3fold_header *handle_to_z3fold_header(unsigned long h)
+static inline void free_handle(unsigned long handle)
 {
-	unsigned long addr = h;
+	struct z3fold_buddy_slots *slots;
+	struct z3fold_header *zhdr;
+	int i;
+	bool is_free = true;
+
+	if (handle & (1 << PAGE_HEADLESS))
+		return;
+
+	if (WARN_ON(*(unsigned long *)handle == 0))
+		return;
+
+	zhdr = handle_to_z3fold_header(handle);
+	slots = handle_to_slots(handle);
+	write_lock(&slots->lock);
+	*(unsigned long *)handle = 0;
+	write_unlock(&slots->lock);
+	if (zhdr->slots == slots)
+		return; /* simple case, nothing else to do */
 
-	if (!(addr & (1 << PAGE_HEADLESS)))
-		addr = *(unsigned long *)h;
+	/* we are freeing a foreign handle if we are here */
+	zhdr->foreign_handles--;
+	read_lock(&slots->lock);
+	for (i = 0; i <= BUDDY_MASK; i++) {
+		if (slots->slot[i]) {
+			is_free = false;
+			break;
+		}
+	}
+	read_unlock(&slots->lock);
+
+	if (is_free && test_and_clear_bit(HANDLES_ORPHANED, &slots->pool)) {
+		struct z3fold_pool *pool = slots_to_pool(slots);
 
-	return (struct z3fold_header *)(addr & PAGE_MASK);
+		kmem_cache_free(pool->c_handle, slots);
+	}
 }
 
-/* only for LAST bud, returns zero otherwise */
+/* Return the number of chunks for the object associated with handle.
+ *
+ * Should be called with page lock taken, otherwise we would have needed to
+ * read addr under slots lock
+ */
 static unsigned short handle_to_chunks(unsigned long handle)
 {
 	unsigned long addr = *(unsigned long *)handle;
@@ -412,15 +480,16 @@ static unsigned short handle_to_chunks(unsigned long handle)
  * (handle & BUDDY_MASK) < zhdr->first_num is possible in encode_handle
  *  but that doesn't matter. because the masking will result in the
  *  correct buddy number.
+ *
+ * NB: should be called with page lock taken
  */
-static enum buddy handle_to_buddy(unsigned long handle)
+static enum buddy handle_to_buddy(unsigned long handle,
+				  struct z3fold_header *zhdr)
 {
-	struct z3fold_header *zhdr;
 	unsigned long addr;
 
 	WARN_ON(handle & (1 << PAGE_HEADLESS));
 	addr = *(unsigned long *)handle;
-	zhdr = (struct z3fold_header *)(addr & PAGE_MASK);
 	return (addr - zhdr->first_num) & BUDDY_MASK;
 }
 
@@ -433,6 +502,8 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 {
 	struct page *page = virt_to_page(zhdr);
 	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	bool is_free = true;
+	int i;
 
 	WARN_ON(!list_empty(&zhdr->buddy));
 	set_bit(PAGE_STALE, &page->private);
@@ -441,8 +512,25 @@ static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
 	if (!list_empty(&page->lru))
 		list_del_init(&page->lru);
 	spin_unlock(&pool->lock);
+
+	/* If there are no foreign handles, free the handles array */
+	read_lock(&zhdr->slots->lock);
+	for (i = 0; i <= BUDDY_MASK; i++) {
+		if (zhdr->slots->slot[i]) {
+			is_free = false;
+			break;
+		}
+	}
+	read_unlock(&zhdr->slots->lock);
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
@@ -470,6 +558,7 @@ static void release_z3fold_page_locked_list(struct kref *ref)
 	struct z3fold_header *zhdr = container_of(ref, struct z3fold_header,
 					       refcount);
 	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+
 	spin_lock(&pool->lock);
 	list_del_init(&zhdr->buddy);
 	spin_unlock(&pool->lock);
@@ -541,106 +630,6 @@ static inline void add_to_unbuddied(struct z3fold_pool *pool,
 	}
 }
 
-static inline void *mchunk_memmove(struct z3fold_header *zhdr,
-				unsigned short dst_chunk)
-{
-	void *beg = zhdr;
-	return memmove(beg + (dst_chunk << CHUNK_SHIFT),
-		       beg + (zhdr->start_middle << CHUNK_SHIFT),
-		       zhdr->middle_chunks << CHUNK_SHIFT);
-}
-
-#define BIG_CHUNK_GAP	3
-/* Has to be called with lock held */
-static int z3fold_compact_page(struct z3fold_header *zhdr)
-{
-	struct page *page = virt_to_page(zhdr);
-
-	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
-		return 0; /* can't move middle chunk, it's used */
-
-	if (unlikely(PageIsolated(page)))
-		return 0;
-
-	if (zhdr->middle_chunks == 0)
-		return 0; /* nothing to compact */
-
-	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-		/* move to the beginning */
-		mchunk_memmove(zhdr, ZHDR_CHUNKS);
-		zhdr->first_chunks = zhdr->middle_chunks;
-		zhdr->middle_chunks = 0;
-		zhdr->start_middle = 0;
-		zhdr->first_num++;
-		return 1;
-	}
-
-	/*
-	 * moving data is expensive, so let's only do that if
-	 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
-	 */
-	if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
-	    zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
-			BIG_CHUNK_GAP) {
-		mchunk_memmove(zhdr, zhdr->first_chunks + ZHDR_CHUNKS);
-		zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
-		return 1;
-	} else if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
-		   TOTAL_CHUNKS - (zhdr->last_chunks + zhdr->start_middle
-					+ zhdr->middle_chunks) >=
-			BIG_CHUNK_GAP) {
-		unsigned short new_start = TOTAL_CHUNKS - zhdr->last_chunks -
-			zhdr->middle_chunks;
-		mchunk_memmove(zhdr, new_start);
-		zhdr->start_middle = new_start;
-		return 1;
-	}
-
-	return 0;
-}
-
-static void do_compact_page(struct z3fold_header *zhdr, bool locked)
-{
-	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
-	struct page *page;
-
-	page = virt_to_page(zhdr);
-	if (locked)
-		WARN_ON(z3fold_page_trylock(zhdr));
-	else
-		z3fold_page_lock(zhdr);
-	if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
-		z3fold_page_unlock(zhdr);
-		return;
-	}
-	spin_lock(&pool->lock);
-	list_del_init(&zhdr->buddy);
-	spin_unlock(&pool->lock);
-
-	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
-		atomic64_dec(&pool->pages_nr);
-		return;
-	}
-
-	if (unlikely(PageIsolated(page) ||
-		     test_bit(PAGE_STALE, &page->private))) {
-		z3fold_page_unlock(zhdr);
-		return;
-	}
-
-	z3fold_compact_page(zhdr);
-	add_to_unbuddied(pool, zhdr);
-	z3fold_page_unlock(zhdr);
-}
-
-static void compact_page_work(struct work_struct *w)
-{
-	struct z3fold_header *zhdr = container_of(w, struct z3fold_header,
-						work);
-
-	do_compact_page(zhdr, false);
-}
-
 /* returns _locked_ z3fold page header or NULL */
 static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
 						size_t size, bool can_sleep)
@@ -739,6 +728,225 @@ static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
 	return zhdr;
 }
 
+static inline void *mchunk_memmove(struct z3fold_header *zhdr,
+				unsigned short dst_chunk)
+{
+	void *beg = zhdr;
+	return memmove(beg + (dst_chunk << CHUNK_SHIFT),
+		       beg + (zhdr->start_middle << CHUNK_SHIFT),
+		       zhdr->middle_chunks << CHUNK_SHIFT);
+}
+
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
+		write_lock(&zhdr->slots->lock);
+		*(unsigned long *)old_handle = (unsigned long)new_zhdr +
+			__idx(new_zhdr, new_bud);
+		if (new_bud == LAST)
+			*(unsigned long *)old_handle |=
+					(new_zhdr->last_chunks << BUDDY_SHIFT);
+		write_unlock(&zhdr->slots->lock);
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
+#define BIG_CHUNK_GAP	3
+/* Has to be called with lock held */
+static int z3fold_compact_page(struct z3fold_header *zhdr)
+{
+	struct page *page = virt_to_page(zhdr);
+
+	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
+		return 0; /* can't move middle chunk, it's used */
+
+	if (zhdr->middle_chunks == 0)
+		return 0; /* nothing to compact */
+
+	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+		/* move to the beginning */
+		mchunk_memmove(zhdr, ZHDR_CHUNKS);
+		zhdr->first_chunks = zhdr->middle_chunks;
+		zhdr->middle_chunks = 0;
+		zhdr->start_middle = 0;
+		zhdr->first_num++;
+		return 1;
+	}
+
+	/*
+	 * moving data is expensive, so let's only do that if
+	 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
+	 */
+	if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+	    zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
+			BIG_CHUNK_GAP) {
+		mchunk_memmove(zhdr, zhdr->first_chunks + ZHDR_CHUNKS);
+		zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
+		return 1;
+	} else if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+		   TOTAL_CHUNKS - (zhdr->last_chunks + zhdr->start_middle
+					+ zhdr->middle_chunks) >=
+			BIG_CHUNK_GAP) {
+		unsigned short new_start = TOTAL_CHUNKS - zhdr->last_chunks -
+			zhdr->middle_chunks;
+		mchunk_memmove(zhdr, new_start);
+		zhdr->start_middle = new_start;
+		return 1;
+	}
+
+	return 0;
+}
+
+static void do_compact_page(struct z3fold_header *zhdr, bool locked)
+{
+	struct z3fold_pool *pool = zhdr_to_pool(zhdr);
+	struct page *page;
+
+	page = virt_to_page(zhdr);
+	if (locked)
+		WARN_ON(z3fold_page_trylock(zhdr));
+	else
+		z3fold_page_lock(zhdr);
+	if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
+		z3fold_page_unlock(zhdr);
+		return;
+	}
+	spin_lock(&pool->lock);
+	list_del_init(&zhdr->buddy);
+	spin_unlock(&pool->lock);
+
+	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
+		atomic64_dec(&pool->pages_nr);
+		return;
+	}
+
+	if (unlikely(PageIsolated(page) ||
+		     test_bit(PAGE_STALE, &page->private))) {
+		z3fold_page_unlock(zhdr);
+		return;
+	}
+
+	if (!zhdr->foreign_handles && buddy_single(zhdr) &&
+			compact_single_buddy(zhdr)) {
+		if (kref_put(&zhdr->refcount, release_z3fold_page_locked))
+			atomic64_dec(&pool->pages_nr);
+		else
+			z3fold_page_unlock(zhdr);
+		return;
+	}
+
+	z3fold_compact_page(zhdr);
+	add_to_unbuddied(pool, zhdr);
+	z3fold_page_unlock(zhdr);
+}
+
+static void compact_page_work(struct work_struct *w)
+{
+	struct z3fold_header *zhdr = container_of(w, struct z3fold_header,
+						work);
+
+	do_compact_page(zhdr, false);
+}
+
 /*
  * API Functions
  */
@@ -968,11 +1176,11 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
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
@@ -983,6 +1191,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 			spin_lock(&pool->lock);
 			list_del(&page->lru);
 			spin_unlock(&pool->lock);
+			put_z3fold_header(zhdr);
 			free_z3fold_page(page, true);
 			atomic64_dec(&pool->pages_nr);
 		}
@@ -990,8 +1199,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 
 	/* Non-headless case */
-	z3fold_page_lock(zhdr);
-	bud = handle_to_buddy(handle);
+	bud = handle_to_buddy(handle, zhdr);
 
 	switch (bud) {
 	case FIRST:
@@ -1006,7 +1214,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	default:
 		pr_err("%s: unknown bud %d\n", __func__, bud);
 		WARN_ON(1);
-		z3fold_page_unlock(zhdr);
+		put_z3fold_header(zhdr);
 		return;
 	}
 
@@ -1021,7 +1229,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 	if (unlikely(PageIsolated(page)) ||
 	    test_and_set_bit(NEEDS_COMPACTING, &page->private)) {
-		z3fold_page_unlock(zhdr);
+		put_z3fold_header(zhdr);
 		return;
 	}
 	if (zhdr->cpu < 0 || !cpu_online(zhdr->cpu)) {
@@ -1035,7 +1243,7 @@ static void z3fold_free(struct z3fold_pool *pool, unsigned long handle)
 	}
 	kref_get(&zhdr->refcount);
 	queue_work_on(zhdr->cpu, pool->compact_wq, &zhdr->work);
-	z3fold_page_unlock(zhdr);
+	put_z3fold_header(zhdr);
 }
 
 /**
@@ -1217,15 +1425,14 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 	void *addr;
 	enum buddy buddy;
 
-	zhdr = handle_to_z3fold_header(handle);
+	zhdr = get_z3fold_header(handle);
 	addr = zhdr;
 	page = virt_to_page(zhdr);
 
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		goto out;
 
-	z3fold_page_lock(zhdr);
-	buddy = handle_to_buddy(handle);
+	buddy = handle_to_buddy(handle, zhdr);
 	switch (buddy) {
 	case FIRST:
 		addr += ZHDR_SIZE_ALIGNED;
@@ -1246,8 +1453,8 @@ static void *z3fold_map(struct z3fold_pool *pool, unsigned long handle)
 
 	if (addr)
 		zhdr->mapped_count++;
-	z3fold_page_unlock(zhdr);
 out:
+	put_z3fold_header(zhdr);
 	return addr;
 }
 
@@ -1262,18 +1469,17 @@ static void z3fold_unmap(struct z3fold_pool *pool, unsigned long handle)
 	struct page *page;
 	enum buddy buddy;
 
-	zhdr = handle_to_z3fold_header(handle);
+	zhdr = get_z3fold_header(handle);
 	page = virt_to_page(zhdr);
 
 	if (test_bit(PAGE_HEADLESS, &page->private))
 		return;
 
-	z3fold_page_lock(zhdr);
-	buddy = handle_to_buddy(handle);
+	buddy = handle_to_buddy(handle, zhdr);
 	if (buddy == MIDDLE)
 		clear_bit(MIDDLE_CHUNK_MAPPED, &page->private);
 	zhdr->mapped_count--;
-	z3fold_page_unlock(zhdr);
+	put_z3fold_header(zhdr);
 }
 
 /**
@@ -1304,19 +1510,21 @@ static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
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
@@ -1342,7 +1550,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
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

