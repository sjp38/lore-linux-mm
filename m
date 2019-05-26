Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CED8C282E5
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060DA20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ppKXhdcY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060DA20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F66B6B0010; Sun, 26 May 2019 17:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AA336B0269; Sun, 26 May 2019 17:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6951B6B026A; Sun, 26 May 2019 17:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0C1F6B0010
	for <linux-mm@kvack.org>; Sun, 26 May 2019 17:22:26 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id t77so2792226lje.17
        for <linux-mm@kvack.org>; Sun, 26 May 2019 14:22:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=bhpiyG+fQrAwqd9DDrtMHY65m09+ZJLdNam4pYTOPyjDVGPwPCMsNJ4uhqk/mdviAZ
         1BzuDd4VEuxZtq9V5gp5GVWnISkuom5EzG3DER8JO3aK+Rpr1FQEFD7H3RyDf07iQ1mU
         drI1iX/pQ0tWTh4oX/NaEjUHzBUtcrVegjqRTY1o1NT2L7/UMpRO3qkpyOxjhNso5KKk
         A0LoYpz0Kosdk1CqnXjG1haBXcXzPG4kCp+xTfoURtaNtnql3ww5rQ/b3/PF/yDYviJw
         6NfAGskjqH0/ih+qekpTETYdO3+Xfyp+V/nfPNtKEIAWPMiJu7lU4EkiP3/PkiqmXfC9
         Nc3A==
X-Gm-Message-State: APjAAAVOUzoYaWpj8/ZFueogOspdB9vkz0wvogRGVyy/P1GPHzd1ZdDA
	FwNvyuE7HKWt4OUx9iM0KIWSkuT4hRzPntXQ0LaimBCJjSx6yYKbsJD6cyBHdx5YiojNCOiQf9j
	QMDcLbjU8XBVaN+NzUw0vIF0bUzHitbVHudEr54hdHyM4woEhS2DRE/P+KVwcqT1RMQ==
X-Received: by 2002:a2e:978f:: with SMTP id y15mr41438926lji.125.1558905746429;
        Sun, 26 May 2019 14:22:26 -0700 (PDT)
X-Received: by 2002:a2e:978f:: with SMTP id y15mr41438889lji.125.1558905745079;
        Sun, 26 May 2019 14:22:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558905745; cv=none;
        d=google.com; s=arc-20160816;
        b=p2msDoyUa1DYNEQJqynZErrFb6XSEgGaVMA1gaKPigi4xw4SU+3e1BNZOZmUYNehn3
         oYVXqP5pxdCJQuUboX2LSSYawpZ/hGJR2YUheFSs5Y+oCCsAha/l4HPp+s2lHd8Mx5op
         b7sPGge0gzre2Kc/pIb64qY1NcJiNwEIlOFt1XP8kOsLlHVFb81xGue27rBfXgnkl6pR
         MOA8s60HUvQ0kcj0V06uRyrE3J2Wp75nJPUQHPYhSavQjfglRqkedATIKsXQnsSt35kg
         3mnCdR8nu95Tjd0tU7iGOqn7MRaigg35eeCXYu+27MNSpeTo9Wp6hp1Cg0iJDrhjzvcC
         rnRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=Mx6IqSmdVYMzot7fy7DvDip1EeIAaq0DoE4SR+KTqe0xxZSXUekw15mJKrMG97GdCi
         oAKapUNf+X3jlxwNJYp9v1FP0d0dPAIQIBeHqrDT6UtiR+jp51tUKclZSx8dcppBtBTd
         Munn92Bz7E35YXWNTNoSMij4RPJ6K1+Az6uWh1txhSbvE83i5q7oyS8XFmc9JpR+gRmh
         j4iWdaGKlQeQzZKWwYdlxmIzNuciHbNqq7gNg1jL7507S/tAZ0pElpQvD6GEK6Ti0sE8
         IZjTv55M6bHslKIOGAb6Sc2GKB8DOVPEHEkkV/EsZ73o1ZDlxMapyMxCzQcXILPMLbsQ
         JpsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ppKXhdcY;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor4133494ljh.38.2019.05.26.14.22.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 14:22:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ppKXhdcY;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=MSM6WbF67OdKB/w9seZTGzSuynUfhCF7zBIV2w+Az9Q=;
        b=ppKXhdcYv/KS+lHxU0WQYWLLtvUUgJpmMrzEsrFlLI1NVg4OvTrmnbOsrKvDddyYyv
         DXoCrVZIRc3jEPmAgywzlACas20zyM4yq5e20hOeZBFnFgqw/Ti/QTrYF1suEu4F3ZOg
         hk0g8OSW1fcjurJLDHFj8tADADT71lHJd0xKkRyJtMKAk4JJNpXiBztGevsr/vXF7BfS
         ixnfZ0yczhG9qtuh1y3tr9SOCPIMZlY1VzIopaMZ2Vly3KrhzJsZ0ewrzGrBxPGFOn9P
         M0U+MIiW3FWQLBm70HawONYxYDIMTgQkgHwW3Dvc3Kqn6mgsqaK/Y/Mh/5HQqhcLL2v+
         IzgQ==
X-Google-Smtp-Source: APXvYqzjRREPhs/jfl9SG9/cgGQN1br+FVaYC31Ecl9Wnipwc23oiap1J5otLWtvsLFSBf1EkOKeHQ==
X-Received: by 2002:a2e:7d02:: with SMTP id y2mr32698875ljc.62.1558905744691;
        Sun, 26 May 2019 14:22:24 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y4sm1885105lje.24.2019.05.26.14.22.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 14:22:24 -0700 (PDT)
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
Subject: [PATCH v2 2/4] mm/vmap: preload a CPU with one object for split purpose
Date: Sun, 26 May 2019 23:22:11 +0200
Message-Id: <20190526212213.5944-3-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190526212213.5944-1-urezki@gmail.com>
References: <20190526212213.5944-1-urezki@gmail.com>
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

