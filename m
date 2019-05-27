Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55287C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:19:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E88C21848
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:19:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bfSRoqQv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E88C21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4C286B0282; Mon, 27 May 2019 11:19:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD3BE6B0283; Mon, 27 May 2019 11:19:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DE736B0284; Mon, 27 May 2019 11:19:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 260DF6B0282
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:19:00 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id m2so56117lfj.1
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:19:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=WHIaMN3lLfACCF2Y00UTbjD+qGVelGd4go0TaJhmGcr2BZS+PuW+h/FWBeAL7Ygpt2
         XkOgPZMIwZWV5hdnuZ/tAdgeJcIMeEb/5hAm4EpnfIolxYcv76OJWa360bRhyYihj9r7
         U1fAEnpuCgPO6dQi8qXWi5AiCshkECzZycFUmJvpb1baUt9TCSbi7+7HzwUPGOqSBk26
         Pq2BrGAUzHy8rok/pNVQz/WiDrUvLTRCji5EVFCdKjmNpHK9ow9g3efw1yD0mUhrjEYT
         sjTtGVGgd7L04PddY/WQhzIGSEJcEOKKmgPQ93RLzFjCoVJqYxZbPlCacNdmmTMdtPe0
         8LVQ==
X-Gm-Message-State: APjAAAUQIr3nQCYxiKnEseYMOEl5TFrwn0q964QSUrAIbYhKajU3y2h1
	UUMyeevHPYX7B/C3QP+sxOCiTL1N9Vk2IXV6EcDejR//JZHJBadpnN8NukAyGFZnf/xj11z0RyC
	jhkUl04s9wSdDCpbctkqPLRjHJR02idTCNm7Y+kNRkeyllXHH/3YXa85BmaW6e6iNdQ==
X-Received: by 2002:a19:6517:: with SMTP id z23mr7728805lfb.98.1558970339605;
        Mon, 27 May 2019 08:18:59 -0700 (PDT)
X-Received: by 2002:a19:6517:: with SMTP id z23mr7728733lfb.98.1558970338257;
        Mon, 27 May 2019 08:18:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558970338; cv=none;
        d=google.com; s=arc-20160816;
        b=aygLaUGVu0ql1E5QQCm1XWkqNNlxtrJU4sFCVOpxhATBFKB87KA9+5mbdc+JTrCEn5
         EH0JyLXRw2F2dqd6eF5RB0hDH+AHP6ILkUmdQ33eJ61hZN5HF2FN/G2Tks2NPAtG39D4
         LMLMtUuh/xGsa8N0bEUfCb6Yrl9u11hT6DVleB0Q+EDAFhJ322RFkvRVPR5MycbxvfII
         WV4ctGqcyc1b63Aol8ZaUSeF1uqvEc8/sO5PfRYTPxmiWFI8AoMQzp+0j6fm/EBJ8zZx
         LOO17zaQNrtpdELf9E/OLjyw+GebY8rII7VHzYv9TdEQiJwyuj7YWajEIUELLBMjAZLB
         6AaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=d0Vmm7kkFsuELcXjce5cXiAqzZIQgbsb8RpzWqpqAIFgzTedWven1kt6CArvVWtOKf
         ZTeGuYG790ha2BrPu/dhv+dchD2dhsDfVnDgXmIkC33HejCHp7enPtpUaHGyClrhd4vv
         gbD/42dApyXfcHyNAq0xCHTLjIPS8GG9iMZZ+JifBPtZlnuRRNDTjuiwCye7o5HgRxsX
         0whNhq4T0Zifr1swzzgfhMI1CR5N1LqqsYhuN0T4fOtIB12V+e0CCA2nhfAfeZkhMUWW
         h6YyQP5Xz4LdfWDYp6TCWsvdYb6gEcAkpjCvq96FNSNyOQBqnf8fgxu/5h79uT9ODIbg
         Tm3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bfSRoqQv;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor5500097ljg.35.2019.05.27.08.18.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 08:18:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bfSRoqQv;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=bfSRoqQvdM4sTzNjojGwue5FzJlZoDMK55pnpPF/cOUXgMSSUzgX+oVG2bRQd9DS4q
         N3JJfQMNMdQ8xSekufRp7/WeOMTkM17k/+u8nFjZG9KjlIB/EHJZU7ZHEjOBjRKe9Yy/
         cEVA/45ITXTGIFVnBQAD7tC4Pidy43L7CCEfhg9c8vklVFyp2mOuTW8mk44FIrGhUjZV
         SAWx/sAhKDH6Es4467sgKNL/dkP15QkU2S+eZngzOlsbXr73/nN/3LEj+rqZ6ovCd532
         Zpnvx1hVp9PXrhoQv6z94z565Pms9Kn9FTTcDXYTOhsRupT0JZQsPvgeY9tTjjbuNMJU
         R+Gw==
X-Google-Smtp-Source: APXvYqwcjDd7zgKi++glHLj+RM/99G19P83k7qZ5BeJwNZRPcDXHcJeMZReOkx9Hw9J4zkct+fKI1A==
X-Received: by 2002:a2e:9a94:: with SMTP id p20mr17141512lji.2.1558970337822;
        Mon, 27 May 2019 08:18:57 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h25sm2308701ljb.80.2019.05.27.08.18.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:18:57 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v4 2/4] mm/vmap: preload a CPU with one object for split purpose
Date: Mon, 27 May 2019 17:18:41 +0200
Message-Id: <20190527151843.27416-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527151843.27416-1-urezki@gmail.com>
References: <20190527151843.27416-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Refactor the NE_FIT_TYPE split case when it comes to an
allocation of one extra object. We need it in order to
build a remaining space.

Introduce ne_fit_preload()/ne_fit_preload_end() functions
for preloading one extra vmap_area object to ensure that
we have it available when fit type is NE_FIT_TYPE.

The preload is done per CPU in non-atomic context thus with
GFP_KERNEL allocation masks. More permissive parameters can
be beneficial for systems which are suffer from high memory
pressure or low memory condition.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 79 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 76 insertions(+), 3 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ea1b65fac599..b553047aa05b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -364,6 +364,13 @@ static LIST_HEAD(free_vmap_area_list);
  */
 static struct rb_root free_vmap_area_root = RB_ROOT;
 
+/*
+ * Preload a CPU with one object for "no edge" split case. The
+ * aim is to get rid of allocations from the atomic context, thus
+ * to use more permissive allocation masks.
+ */
+static DEFINE_PER_CPU(struct vmap_area *, ne_fit_preload_node);
+
 static __always_inline unsigned long
 va_size(struct vmap_area *va)
 {
@@ -950,9 +957,24 @@ adjust_va_to_fit_type(struct vmap_area *va,
 		 *   L V  NVA  V R
 		 * |---|-------|---|
 		 */
-		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
-		if (unlikely(!lva))
-			return -1;
+		lva = __this_cpu_xchg(ne_fit_preload_node, NULL);
+		if (unlikely(!lva)) {
+			/*
+			 * For percpu allocator we do not do any pre-allocation
+			 * and leave it as it is. The reason is it most likely
+			 * never ends up with NE_FIT_TYPE splitting. In case of
+			 * percpu allocations offsets and sizes are aligned to
+			 * fixed align request, i.e. RE_FIT_TYPE and FL_FIT_TYPE
+			 * are its main fitting cases.
+			 *
+			 * There are a few exceptions though, as an example it is
+			 * a first allocation (early boot up) when we have "one"
+			 * big free space that has to be split.
+			 */
+			lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
+			if (!lva)
+				return -1;
+		}
 
 		/*
 		 * Build the remainder.
@@ -1023,6 +1045,48 @@ __alloc_vmap_area(unsigned long size, unsigned long align,
 }
 
 /*
+ * Preload this CPU with one extra vmap_area object to ensure
+ * that we have it available when fit type of free area is
+ * NE_FIT_TYPE.
+ *
+ * The preload is done in non-atomic context, thus it allows us
+ * to use more permissive allocation masks to be more stable under
+ * low memory condition and high memory pressure.
+ *
+ * If success it returns 1 with preemption disabled. In case
+ * of error 0 is returned with preemption not disabled. Note it
+ * has to be paired with ne_fit_preload_end().
+ */
+static int
+ne_fit_preload(int nid)
+{
+	preempt_disable();
+
+	if (!__this_cpu_read(ne_fit_preload_node)) {
+		struct vmap_area *node;
+
+		preempt_enable();
+		node = kmem_cache_alloc_node(vmap_area_cachep, GFP_KERNEL, nid);
+		if (node == NULL)
+			return 0;
+
+		preempt_disable();
+
+		if (__this_cpu_cmpxchg(ne_fit_preload_node, NULL, node))
+			kmem_cache_free(vmap_area_cachep, node);
+	}
+
+	return 1;
+}
+
+static void
+ne_fit_preload_end(int preloaded)
+{
+	if (preloaded)
+		preempt_enable();
+}
+
+/*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
  */
@@ -1034,6 +1098,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	struct vmap_area *va;
 	unsigned long addr;
 	int purged = 0;
+	int preloaded;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
@@ -1056,6 +1121,12 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
 
 retry:
+	/*
+	 * Even if it fails we do not really care about that.
+	 * Just proceed as it is. "overflow" path will refill
+	 * the cache we allocate from.
+	 */
+	preloaded = ne_fit_preload(node);
 	spin_lock(&vmap_area_lock);
 
 	/*
@@ -1063,6 +1134,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * returned. Therefore trigger the overflow path.
 	 */
 	addr = __alloc_vmap_area(size, align, vstart, vend);
+	ne_fit_preload_end(preloaded);
+
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

