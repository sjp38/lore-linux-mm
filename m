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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A2BEC28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43A4921744
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sUmGQPCg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43A4921744
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B767E6B026C; Mon, 27 May 2019 05:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A62626B026D; Mon, 27 May 2019 05:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83F206B026E; Mon, 27 May 2019 05:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 149866B026C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:38:56 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id y11so3071035ljc.20
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:38:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=Soclc60WuOAKTyvr07R1uukQ16ng1MqoLOuLruY1y84mRlykZzCZGbLqDaqxdX9dHT
         Z3UipjjWLXlVC6o7jdC7JmNIlj5kvA3K3xcGgzSVh3t4axW4RklgG5uPFqKuwZASfk6v
         ys3r+mzq+3k3plaQhURjN9KnDYoJUvqQ3Uft+CjN6hQ5VxrQ2//6x9a1oS/GZwTpfuil
         VCJYLH1up8z3xIL52+E8cW0j/er/e2fIteq1eoenl/ly/4RthwT8IB14DE+YEkFcatbL
         kZqPSO5o2vuTkZR9eD0fidK0PxNKEY91mrAINtssrR2ny2jZo/L2nsy8eKnwNuhxQCrJ
         39yg==
X-Gm-Message-State: APjAAAWUQCctnNdrmoyiAybERYurovf5EYQVJ/avvm/EhTrn4HxIp9An
	M5iCua+12CnvMiGwlLY4D0sRxJqUNcBVAkae/CphUYaJnBv0kRCj+5NEO2klkytalPc0ftU+PN/
	6Fo2WIWCU63bkErAUFJdF6kRs2bZnYwaF6uyl2WVULse69ONzwhhFpgMTg6VXLiLe6w==
X-Received: by 2002:a2e:8041:: with SMTP id p1mr9990251ljg.121.1558949935539;
        Mon, 27 May 2019 02:38:55 -0700 (PDT)
X-Received: by 2002:a2e:8041:: with SMTP id p1mr9990197ljg.121.1558949934245;
        Mon, 27 May 2019 02:38:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558949934; cv=none;
        d=google.com; s=arc-20160816;
        b=UyYeGu9WTX3BWKh4jpXjGj2oErQl/owZt0ptBYdEwyXOwvzDGduEvsV5tOpSfGWZXm
         ABAXqgjxcVo2P7Wdim7sZi8pWLcdYFQZ1d/252o40rwNgeGq66530utDNc1or3YR4iBP
         p2UaMcmOWBJ6/GStYfmtsZXGv57rdDULwvRZT7VNNmIkWbhpfTkAbqr8/4pbrLw86rLP
         k0pBKHVaZnTSxrSJzu3fQ364H28ZPz44E5JuG2DauaxPXTiiIdC+i24mDcMQzD3SjFF4
         qBkTo79bvOEXa6SFcDIVT/mYbLsfWQGdMVJJBfWIVtYQwrIQ29V0yy13d/2qXE0aGW5V
         oHiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=nEADGjEEKVAMQWKD9AczqeV0biRYIpEDVsshk8hiR6GYdb/F/Gm5AZAXsRizVpHATQ
         WjEU1abW+GGwSFewsZd2v01crbxr2R/cgWOteJRfsvWXMvacTQsCGm6ZxVE/L9VP5EsL
         clOxGDQ486yTOtuHn8Lp+8t9j+ErdYwV8227j3YHHlqGgpTKxa3BJYwk7Zbh0qVidSYs
         ELjuXmYCpSp/+udbgMR0slC4tOnB20y0y7CNSMUmUF/NEr6mno0CE19rtpQXnCwx2f3a
         h7AohQvSux/svFvRS/shHTlwrXozGNDhpDD0lbu/hfgEQ2wHSvoxnH176+IHgydH2zb+
         B/ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sUmGQPCg;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16sor1240008lfm.30.2019.05.27.02.38.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 02:38:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sUmGQPCg;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=sUmGQPCg1h4G78WjpktomzL1vsZjD0vSyk4a/TMHRWTP028OvSlppVxZRdtKGtzAdE
         dylJ9B0jJSDE4NcUiWzqLubR3R3IS1TrLXMmlTpGoe8Qo7FKO7MmDhH9Nu7psaV6+gq4
         hI1D22BOnCwUFc9siRF0Jyq/8y/Ujmz9NQtUKgTo/4yT+EiJE2Ai5NQaj385hImHrFMy
         I1BEQGZRmVHol66Bjz+NAC4ueF4Soqnx8L3y+Y8g6CwqNEJYL7ej4SKK6unwW2/17slz
         xuWVzqyjXSDEfPkHdHJLNbCb5A/XaaaOpimcUqBzhavLqVIsDrW8K7bkXeyMjwIAncPp
         85xg==
X-Google-Smtp-Source: APXvYqzERAbBtlp4Er6Lh4C9w2h4kNRVuBtp0mnWStcvdQ80Dpqy67L/LVB/6darmfplemsj1nipog==
X-Received: by 2002:a19:7716:: with SMTP id s22mr2343486lfc.64.1558949933874;
        Mon, 27 May 2019 02:38:53 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z26sm2176293lfg.31.2019.05.27.02.38.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 02:38:53 -0700 (PDT)
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
Subject: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split purpose
Date: Mon, 27 May 2019 11:38:40 +0200
Message-Id: <20190527093842.10701-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527093842.10701-1-urezki@gmail.com>
References: <20190527093842.10701-1-urezki@gmail.com>
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

