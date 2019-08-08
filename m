Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F018CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99451216C8
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HwdqrDzr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99451216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46EEE6B000D; Thu,  8 Aug 2019 19:14:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FDBA6B000E; Thu,  8 Aug 2019 19:14:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 274E76B0010; Thu,  8 Aug 2019 19:14:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFB426B000D
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:14:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x19so58580298pgx.1
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:14:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=drCiqg5eO1p+COxGwvWoRnEMTmsA8j0da20LEkdR9+8=;
        b=e23Ro2Kb7zXSEAASjMTWKFDvCXGv+3xoPY6o/jUV57xo4J/Wdzr6yc9Ud/MCewK5iq
         3480qfbzHeGFIlN9I3hCHgEsA6QH5iQR9ksQwBYDn4VU6FkNfjlKWbrzw0af/wxlaxEn
         nwHvi8Ry67omLZO2hoazDQe2hbH33USUaiCDLFVep6wzyneLHN76GbmzDUUsxyCTwH5W
         xnIbk1+VTdw8vZCM6yZ644X3EsJzCcZEURQ54G0qEWdUikcl2cnP+Zpyulm8vJP+5g8i
         1widi5kPn7wOGmmKFaCmyOdvmMwReGCUMTyJOXdkvohKuEdauJ2gKRpoEdwdFGfZX+T9
         mpuQ==
X-Gm-Message-State: APjAAAXXrbhRdGqpJt9c+kb7Lbv8jNNNgJsKNxWZ8Te6MFfeXFXkgNhc
	TtfOA0J8q38wRJ8810uXtyuOOBg64lev9GDYksLpLYNmTA/rIAB7DPPleP2YxrvmsKpOrG1UftW
	YRbpefsJjSE4Io4mAUL6h2JKTYJjRFYiix+MrZjx4Zt45oYFEX3ZditQM3cj2vVmmYw==
X-Received: by 2002:aa7:86cc:: with SMTP id h12mr18508642pfo.2.1565306047583;
        Thu, 08 Aug 2019 16:14:07 -0700 (PDT)
X-Received: by 2002:aa7:86cc:: with SMTP id h12mr18508569pfo.2.1565306046344;
        Thu, 08 Aug 2019 16:14:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565306046; cv=none;
        d=google.com; s=arc-20160816;
        b=H1jYDOWH0f/l3UQ/XF3uX0USkd5iDMwXAJ2z9+dOQcVX0AKDPXs5b5iw3N6HTYE9yw
         HRzpr2yeh6vqRSmtlR3Jjc7Kfz7holXE3ukkssu5hApfn4Q6EDHrHRvnxZHXjjF8KoE0
         syLfRikCLf32K86h68Oq3NmeuN16+CaWd1JUXXEM9xcK1Ny/hlY8bEwBPmjgXDQWq5M9
         jFts3MNJVMRhZ9MPzbSBlKl4b6S7Vz/W2Ro5IItCMKLq1701P8gMD1ve0sFuEUWSsx3G
         LIatOhqbAh/Rq0kQtxwWc1BmHA0uKHE+hXNP+z0Z+HVBjO/i3cIvUL/4qKaW9necSmXx
         WBAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=drCiqg5eO1p+COxGwvWoRnEMTmsA8j0da20LEkdR9+8=;
        b=MXbqN09p7hAMF2DVkd6bsNQkVEH1sL17GCHHClRdybisONpR8PfYb+mp5IilY4XsEX
         LlWQSN9kq1rzBm38Ro3ISv7HYv/7yWWP6xK/gEUUcgIxBhX+j9h1UpLJ//sVH4o1BOl1
         I976nBE3v1dRHwBa4TzzUwsW/5DsgncS9LvhE1tjcMDOOs5iai9EXtGD2Ke3o0Q/e4z2
         W3jxJC1UIhALj8q1nO3jEa4Zqjnr1HfNwk2N4KI2QbAxYOUcjRZd394hvwS6ruG9ITYK
         zLEFiI+jB+pYPCY3UN4jagCTSQ3M6ndJs9dK9HNHN1I+la4Ug3WSaMfqpH6/mZ2pC6lt
         V2vg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HwdqrDzr;
       spf=pass (google.com: domain of 3vaxmxqskcdowhiwonuiejwckkcha.ykihejqt-iigrwyg.knc@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vaxMXQsKCDoWhiWonuiejWckkcha.Ykihejqt-iigrWYg.knc@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id g15sor68648943pgg.19.2019.08.08.16.14.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:14:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3vaxmxqskcdowhiwonuiejwckkcha.ykihejqt-iigrwyg.knc@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HwdqrDzr;
       spf=pass (google.com: domain of 3vaxmxqskcdowhiwonuiejwckkcha.ykihejqt-iigrwyg.knc@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3vaxMXQsKCDoWhiWonuiejWckkcha.Ykihejqt-iigrWYg.knc@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=drCiqg5eO1p+COxGwvWoRnEMTmsA8j0da20LEkdR9+8=;
        b=HwdqrDzr13x64ZIseXlcLcodkObujd2c9PGDHKeGJvwU4h7405yqZw+dhi88K6thZ/
         Hkk7kedUYi0DGhpXnUevb7H9L/5iTKlHpGXS82/zvKmrtlRX2T7iRPae99XQnuH0yp4c
         yGb7XS7i9QugXTcFtu0TUFjZbfZpRAeX5w1EEA/34a+DlAspSW2HuXf4Li8u7+l5HTK4
         28m947qa5CJM0ibSgMCjh1HsJKFHudJg/O578scs8UgFTjIHtx+y91PaExxiJqfgs9yk
         nCcYu9Hrm56wOkmNUrntb1lzpcUG7yFDAq16LlE2WItq3Y0AqvYvEeCwTPwI4mAD8SfT
         ISMw==
X-Google-Smtp-Source: APXvYqyvXv68SxmFiKFPVh/7lJ9pVVf/mq3qplP82Zyca+bEQZ85+a43+DwF33JU6YM617k79zoSdt24qkmqNAzF5w==
X-Received: by 2002:a65:41c2:: with SMTP id b2mr14787518pgq.320.1565306045744;
 Thu, 08 Aug 2019 16:14:05 -0700 (PDT)
Date: Thu,  8 Aug 2019 16:13:39 -0700
In-Reply-To: <20190808231340.53601-1-almasrymina@google.com>
Message-Id: <20190808231340.53601-5-almasrymina@google.com>
Mime-Version: 1.0
References: <20190808231340.53601-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [RFC PATCH v2 4/5] hugetlb_cgroup: Add accounting for shared mappings
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For shared mappings, the pointer to the hugetlb_cgroup to uncharge lives
in the resv_map entries, in file_region->reservation_counter.

When a file_region entry is added to the resv_map via region_add, we
also charge the appropriate hugetlb_cgroup and put the pointer to that
in file_region->reservation_counter. This is slightly delicate since we
need to not modify the resv_map until we know that charging the
reservation has succeeded. If charging doesn't succeed, we report the
error to the caller, so that the kernel fails the reservation.

On region_del, which is when the hugetlb memory is unreserved, we delete
the file_region entry in the resv_map, but also uncharge the
file_region->reservation_counter.

---
 mm/hugetlb.c | 208 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 170 insertions(+), 38 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 235996aef6618..d76e3137110ab 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -242,8 +242,72 @@ struct file_region {
 	struct list_head link;
 	long from;
 	long to;
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * On shared mappings, each reserved region appears as a struct
+	 * file_region in resv_map. These fields hold the info needed to
+	 * uncharge each reservation.
+	 */
+	struct page_counter *reservation_counter;
+	unsigned long pages_per_hpage;
+#endif
 };

+/* Must be called with resv->lock held. Calling this with dry_run == true will
+ * count the number of pages added but will not modify the linked list.
+ */
+static long consume_regions_we_overlap_with(struct file_region *rg,
+		struct list_head *head, long f, long *t,
+		struct hugetlb_cgroup *h_cg,
+		struct hstate *h,
+		bool dry_run)
+{
+	long add = 0;
+	struct file_region *trg = NULL, *nrg = NULL;
+
+	/* Consume any regions we now overlap with. */
+	nrg = rg;
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > *t)
+			break;
+
+		/* If this area reaches higher then extend our area to
+		 * include it completely.  If this is not the first area
+		 * which we intend to reuse, free it.
+		 */
+		if (rg->to > *t)
+			*t = rg->to;
+		if (rg != nrg) {
+			/* Decrement return value by the deleted range.
+			 * Another range will span this area so that by
+			 * end of routine add will be >= zero
+			 */
+			add -= (rg->to - rg->from);
+			if (!dry_run) {
+				list_del(&rg->link);
+				kfree(rg);
+			}
+		}
+	}
+
+	add += (nrg->from - f);		/* Added to beginning of region */
+	add += *t - nrg->to;		/* Added to end of region */
+
+	if (!dry_run) {
+		nrg->from = f;
+		nrg->to = *t;
+#ifdef CONFIG_CGROUP_HUGETLB
+		nrg->reservation_counter =
+			&h_cg->reserved_hugepage[hstate_index(h)];
+		nrg->pages_per_hpage = pages_per_huge_page(h);
+#endif
+	}
+
+	return add;
+}
+
 /*
  * Add the huge page range represented by [f, t) to the reserve
  * map.  In the normal case, existing regions will be expanded
@@ -258,11 +322,13 @@ struct file_region {
  * Return the number of new huge pages added to the map.  This
  * number is greater than or equal to zero.
  */
-static long region_add(struct resv_map *resv, long f, long t)
+static long region_add(struct hstate *h, struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
-	struct file_region *rg, *nrg, *trg;
-	long add = 0;
+	struct file_region *rg, *nrg;
+	long add = 0, newadd = 0;
+	struct hugetlb_cgroup *h_cg = NULL;
+	int ret = 0;

 	spin_lock(&resv->lock);
 	/* Locate the region we are either in or before. */
@@ -277,6 +343,23 @@ static long region_add(struct resv_map *resv, long f, long t)
 	 * from the cache and use it for this range.
 	 */
 	if (&rg->link == head || t < rg->from) {
+#ifdef CONFIG_CGROUP_HUGETLB
+		/*
+		 * If res->reservation_counter is NULL, then it means this is
+		 * a shared mapping, and hugetlb cgroup accounting should be
+		 * done on the file_region entries inside resv_map.
+		 */
+		if (!resv->reservation_counter) {
+			ret = hugetlb_cgroup_charge_cgroup(
+					hstate_index(h),
+					(t - f) * pages_per_huge_page(h),
+					&h_cg, true);
+		}
+
+		if (ret)
+			goto out_locked;
+#endif
+
 		VM_BUG_ON(resv->region_cache_count <= 0);

 		resv->region_cache_count--;
@@ -286,6 +369,15 @@ static long region_add(struct resv_map *resv, long f, long t)

 		nrg->from = f;
 		nrg->to = t;
+
+#ifdef CONFIG_CGROUP_HUGETLB
+		if (h_cg) {
+			nrg->reservation_counter =
+				&h_cg->reserved_hugepage[hstate_index(h)];
+			nrg->pages_per_hpage = pages_per_huge_page(h);
+		}
+#endif
+
 		list_add(&nrg->link, rg->link.prev);

 		add += t - f;
@@ -296,38 +388,37 @@ static long region_add(struct resv_map *resv, long f, long t)
 	if (f > rg->from)
 		f = rg->from;

-	/* Check for and consume any regions we now overlap with. */
-	nrg = rg;
-	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			break;
-
-		/* If this area reaches higher then extend our area to
-		 * include it completely.  If this is not the first area
-		 * which we intend to reuse, free it. */
-		if (rg->to > t)
-			t = rg->to;
-		if (rg != nrg) {
-			/* Decrement return value by the deleted range.
-			 * Another range will span this area so that by
-			 * end of routine add will be >= zero
-			 */
-			add -= (rg->to - rg->from);
-			list_del(&rg->link);
-			kfree(rg);
-		}
+#ifdef CONFIG_CGROUP_HUGETLB
+	/* Count any regions we now overlap with. */
+	add = consume_regions_we_overlap_with(rg, head, f, &t, NULL, NULL,
+			true);
+
+	if (!resv->reservation_counter) {
+		ret = hugetlb_cgroup_charge_cgroup(
+				hstate_index(h),
+				add * pages_per_huge_page(h),
+				&h_cg, true);
 	}

-	add += (nrg->from - f);		/* Added to beginning of region */
-	nrg->from = f;
-	add += t - nrg->to;		/* Added to end of region */
-	nrg->to = t;
+	if (ret)
+		goto out_locked;
+#endif
+
+	/* Check for and consume any regions we now overlap with. */
+	newadd = consume_regions_we_overlap_with(rg, head, f, &t, h_cg, h,
+			false);
+	/*
+	 * If these aren't equal, then there is a bug with
+	 * consume_regions_we_overlap_with, and we're charging the wrong amount
+	 * of memory.
+	 */
+	WARN_ON(add != newadd);

 out_locked:
 	resv->adds_in_progress--;
 	spin_unlock(&resv->lock);
+	if (ret)
+		return ret;
 	VM_BUG_ON(add < 0);
 	return add;
 }
@@ -487,6 +578,10 @@ static long region_del(struct resv_map *resv, long f, long t)
 	struct file_region *rg, *trg;
 	struct file_region *nrg = NULL;
 	long del = 0;
+#ifdef CONFIG_CGROUP_HUGETLB
+	struct page_counter *reservation_counter = NULL;
+	unsigned long pages_per_hpage = 0;
+#endif

 retry:
 	spin_lock(&resv->lock);
@@ -514,6 +609,14 @@ static long region_del(struct resv_map *resv, long f, long t)
 				nrg = list_first_entry(&resv->region_cache,
 							struct file_region,
 							link);
+#ifdef CONFIG_CGROUP_HUGETLB
+				/*
+				 * Save counter information from the deleted
+				 * node, in case we need to do an uncharge.
+				 */
+				reservation_counter = nrg->reservation_counter;
+				pages_per_hpage = nrg->pages_per_hpage;
+#endif
 				list_del(&nrg->link);
 				resv->region_cache_count--;
 			}
@@ -543,6 +646,14 @@ static long region_del(struct resv_map *resv, long f, long t)

 		if (f <= rg->from && t >= rg->to) { /* Remove entire region */
 			del += rg->to - rg->from;
+#ifdef CONFIG_CGROUP_HUGETLB
+			/*
+			 * Save counter information from the deleted node,
+			 * in case we need to do an uncharge.
+			 */
+			reservation_counter = rg->reservation_counter;
+			pages_per_hpage = rg->pages_per_hpage;
+#endif
 			list_del(&rg->link);
 			kfree(rg);
 			continue;
@@ -559,6 +670,19 @@ static long region_del(struct resv_map *resv, long f, long t)

 	spin_unlock(&resv->lock);
 	kfree(nrg);
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * If resv->reservation_counter is NULL, then this is shared
+	 * reservation, and the reserved memory is tracked in the file_struct
+	 * entries inside of resv_map. So we need to uncharge the memory here.
+	 */
+	if (reservation_counter && pages_per_hpage && del > 0 &&
+	    !resv->reservation_counter) {
+		hugetlb_cgroup_uncharge_counter(
+				reservation_counter,
+				del * pages_per_hpage);
+	}
+#endif
 	return del;
 }

@@ -1930,7 +2054,7 @@ static long __vma_reservation_common(struct hstate *h,
 		ret = region_chg(resv, idx, idx + 1);
 		break;
 	case VMA_COMMIT_RESV:
-		ret = region_add(resv, idx, idx + 1);
+		ret = region_add(h, resv, idx, idx + 1);
 		break;
 	case VMA_END_RESV:
 		region_abort(resv, idx, idx + 1);
@@ -1938,7 +2062,7 @@ static long __vma_reservation_common(struct hstate *h,
 		break;
 	case VMA_ADD_RESV:
 		if (vma->vm_flags & VM_MAYSHARE)
-			ret = region_add(resv, idx, idx + 1);
+			ret = region_add(h, resv, idx, idx + 1);
 		else {
 			region_abort(resv, idx, idx + 1);
 			ret = region_del(resv, idx, idx + 1);
@@ -4536,7 +4660,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 					struct vm_area_struct *vma,
 					vm_flags_t vm_flags)
 {
-	long ret, chg;
+	long ret, chg, add;
 	struct hstate *h = hstate_inode(inode);
 	struct hugepage_subpool *spool = subpool_inode(inode);
 	struct resv_map *resv_map;
@@ -4624,9 +4748,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 */
 	ret = hugetlb_acct_memory(h, gbl_reserve);
 	if (ret < 0) {
-		/* put back original number of pages, chg */
-		(void)hugepage_subpool_put_pages(spool, chg);
-		goto out_err;
+		goto out_put_pages;
 	}

 	/*
@@ -4641,7 +4763,12 @@ int hugetlb_reserve_pages(struct inode *inode,
 	 * else has to be done for private mappings here
 	 */
 	if (!vma || vma->vm_flags & VM_MAYSHARE) {
-		long add = region_add(resv_map, from, to);
+		add = region_add(h, resv_map, from, to);
+		if (add < 0) {
+			ret = -ENOMEM;
+			goto out_acct_memory;
+		}
+

 		if (unlikely(chg > add)) {
 			/*
@@ -4659,10 +4786,15 @@ int hugetlb_reserve_pages(struct inode *inode,
 		}
 	}
 	return 0;
+out_acct_memory:
+	hugetlb_acct_memory(h, -gbl_reserve);
+out_put_pages:
+	/* put back original number of pages, chg */
+	(void)hugepage_subpool_put_pages(spool, chg);
 out_err:
 	if (!vma || vma->vm_flags & VM_MAYSHARE)
-		/* Don't call region_abort if region_chg failed */
-		if (chg >= 0)
+		/* Don't call region_abort if region_chg or region_add failed */
+		if (chg >= 0 && add >= 0)
 			region_abort(resv_map, from, to);
 	if (vma && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		kref_put(&resv_map->refs, resv_map_release);
--
2.23.0.rc1.153.gdeed80330f-goog

