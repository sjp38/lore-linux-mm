Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29AEAC41514
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C77562173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:14:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="r1KEmh0q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C77562173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77CAA6B000C; Thu,  8 Aug 2019 19:14:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70ED86B000D; Thu,  8 Aug 2019 19:14:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 532846B000E; Thu,  8 Aug 2019 19:14:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 296796B000C
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:14:05 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id a11so24688641vso.9
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:14:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=M6cyBd5hA6OsVmAelGzV5tX+uF9n4OBWzNC5c9d9ybI=;
        b=kY0JtrXtsdhmjOXcYMzQuHtX21nyFoe+122QBGqoNNuGeUCz29H3gVw3bZqw56bvcQ
         Psuar864earnGST8hibnTkl6wryWhO7kAPLAIWZE9pY8uIHThXLTdBBq+6TSVkAEZpgH
         unmJpo+/CBDVvKVV6s1MrZik0MdXOYXauxyVIrnXRH2Aw1IrdDInlegqosTfuXKp2il2
         ZCGbS8fMS3b/XYCZQAcO0g5qyEEXKzakm1Iq35PiIxc1Do45bONQ4oVN+YJ20Sb5GJUN
         RJkTh/IR8LXrVHokOxNfRnc/eglJ81mp+xXRhNOAEx39LcKLiCAeOlqiSQpFA36vufPg
         Yqtg==
X-Gm-Message-State: APjAAAVVgv/ahkuJ3mv4ZwWpHu2P/ip/aYrzQoH4p5vQ5mFoCai71tpt
	lz8kz3Sx4yFwtfMH18tPQ2M6r8kM7C7Qu9OFU8PThyhk8gF6Dvhbqn42dBCl0hBzVppBcNNXh2D
	5U2+GfyxPOJkb3SHvdDl5RTbjzBiLQHnjZL/XrIcsxw168deUyU3YIY/iNLypm7UmWw==
X-Received: by 2002:a1f:b48e:: with SMTP id d136mr6826415vkf.57.1565306044708;
        Thu, 08 Aug 2019 16:14:04 -0700 (PDT)
X-Received: by 2002:a1f:b48e:: with SMTP id d136mr6826404vkf.57.1565306043905;
        Thu, 08 Aug 2019 16:14:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565306043; cv=none;
        d=google.com; s=arc-20160816;
        b=KUnWOOW0T6/ta+qBztE1NxSDYDHzG20z/RLyCnKI4KDf9PvI0zkv9RJTQq4eB2UJ2j
         34RQe7cQYIweU1Uc5GBtDQPGnK+zJ9s1fBVgozw6hbI7F1NjY06paikCF4IBHeglG6nQ
         XPAuC63XWRQP/e0OziIjTlY4WeGs4gYM4yEm/7kumTwxz6BD9P2yQNhXhf/mYSNCtqwg
         kjHCgeCXr0J53ENozwd0IKBYmh6dE0vu70EXnHX3RJrsoJAxZTMDOHst/5GyoHrqSIp/
         OvEY8mrnJYGQ5yhmkitbJ8kHi3weuaJprWojl7jwrnoP1bxKcj2rqYKWyrE5RYdYIXXG
         ZYFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=M6cyBd5hA6OsVmAelGzV5tX+uF9n4OBWzNC5c9d9ybI=;
        b=QjKqsBAL5TQTf2LpdAMgkiQt78E69gpIlCj62+KU4dnqCz0xNDP8Rb71bm8VISpVsg
         B3v/iZLMs3KHj/l/xkJEkR9hGb4VRjZc/0SdRhXW2pBACw/aYpLkV6yOTCfQzBbWB7+S
         YpPfJzCXznRxY4VeBxpn1ITEWVYRaZ8Em7LBrL/sDtRKt0nYCk1JQm8wc3eOEAP9TH0h
         FdfKUBPfWXdgVGTlq9tvrZAFaLsTSndTpB++vAkpknkV9J1vgP5e3WlPtzeXSDB+xNFA
         sTuHAGrVnSnX5f3jOa/AldFpR4PQMGXYSih1KmJ0Za/p2E01O143uYjjoNNzrUKeDBBL
         FE4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r1KEmh0q;
       spf=pass (google.com: domain of 3u6xmxqskcdgufgumlsgchuaiiafy.wigfchor-ggepuwe.ila@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u6xMXQsKCDgUfgUmlsgchUaiiafY.Wigfchor-ggepUWe.ila@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 197sor1812788vkg.17.2019.08.08.16.14.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 16:14:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3u6xmxqskcdgufgumlsgchuaiiafy.wigfchor-ggepuwe.ila@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=r1KEmh0q;
       spf=pass (google.com: domain of 3u6xmxqskcdgufgumlsgchuaiiafy.wigfchor-ggepuwe.ila@flex--almasrymina.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3u6xMXQsKCDgUfgUmlsgchUaiiafY.Wigfchor-ggepUWe.ila@flex--almasrymina.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=M6cyBd5hA6OsVmAelGzV5tX+uF9n4OBWzNC5c9d9ybI=;
        b=r1KEmh0qrOpvBm1/+0oF0sFMH6EQNPOKTvWW1271fb2M52m+iVMsdTPIGKzfVVpgj5
         x+Nc7IcNm8URXfh6TYEay9WEJj4RCDbRjTAMgdrTcpePccY/hODxMK3rNh/znjoVcOBh
         LHTQpfT5/V4EZ7R6N+KMldgXBUoH0DykmWZx9LJEzyLnRFCME7SC3gsq4nP41UK1D3az
         fXXxpAnfQK8rjWMgzEd+dqkIbR5A5/BX9N3Fv+dnJlUU3lDtlUjaBsCblfohOv1PHDlw
         HoFX3WEegCMRRcW1gySNo8nwEMo4BRcSGuyQWrwBWkybGT21t/g38QCSjpGUG2swlQU/
         vkZA==
X-Google-Smtp-Source: APXvYqw//j8PX12o0jMJ/sTXdB0ZGAaXDk7In1PyTrMUN50VA3e5H4NhBHXZpX/7PJT5SedxTsS+zxmp8Csw1EfK6w==
X-Received: by 2002:ac5:c853:: with SMTP id g19mr100310vkm.60.1565306043479;
 Thu, 08 Aug 2019 16:14:03 -0700 (PDT)
Date: Thu,  8 Aug 2019 16:13:38 -0700
In-Reply-To: <20190808231340.53601-1-almasrymina@google.com>
Message-Id: <20190808231340.53601-4-almasrymina@google.com>
Mime-Version: 1.0
References: <20190808231340.53601-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.rc1.153.gdeed80330f-goog
Subject: [RFC PATCH v2 3/5] hugetlb_cgroup: Add reservation accounting for
 private mappings
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

Normally the pointer to the cgroup to uncharge hangs off the struct
page, and gets queried when it's time to free the page. With
hugetlb_cgroup reservations, this is not possible. Because it's possible
for a page to be reserved by one task and actually faulted in by another
task.

The best place to put the hugetlb_cgroup pointer to uncharge for
reservations is in the resv_map. But, because the resv_map has different
semantics for private and shared mappings, the code patch to
charge/uncharge shared and private mappings is different. This patch
implements charging and uncharging for private mappings.

For private mappings, the counter to uncharge is in
resv_map->reservation_counter. On initializing the resv_map this is set
to NULL. On reservation of a region in private mapping, the tasks
hugetlb_cgroup is charged and the hugetlb_cgroup is placed is
resv_map->reservation_counter.

On hugetlb_vm_op_close, we uncharge resv_map->reservation_counter.

---
 include/linux/hugetlb.h        |  8 ++++++
 include/linux/hugetlb_cgroup.h | 11 ++++++++
 mm/hugetlb.c                   | 47 ++++++++++++++++++++++++++++++++--
 mm/hugetlb_cgroup.c            | 12 ---------
 4 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 6777b3013345d..90b3c928d16c1 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -46,6 +46,14 @@ struct resv_map {
 	long adds_in_progress;
 	struct list_head region_cache;
 	long region_cache_count;
+ #ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * On private mappings, the counter to uncharge reservations is stored
+	 * here. If these fields are 0, then the mapping is shared.
+	 */
+	struct page_counter *reservation_counter;
+	unsigned long pages_per_hpage;
+#endif
 };
 extern struct resv_map *resv_map_alloc(void);
 void resv_map_release(struct kref *ref);
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 0725f809cd2d9..1fdde63a4e775 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -25,6 +25,17 @@ struct hugetlb_cgroup;
 #define HUGETLB_CGROUP_MIN_ORDER	2

 #ifdef CONFIG_CGROUP_HUGETLB
+struct hugetlb_cgroup {
+	struct cgroup_subsys_state css;
+	/*
+	 * the counter to account for hugepages from hugetlb.
+	 */
+	struct page_counter hugepage[HUGE_MAX_HSTATE];
+	/*
+	 * the counter to account for hugepage reservations from hugetlb.
+	 */
+	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
+};

 static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
 {
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c153bef42e729..235996aef6618 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -711,6 +711,16 @@ struct resv_map *resv_map_alloc(void)
 	INIT_LIST_HEAD(&resv_map->regions);

 	resv_map->adds_in_progress = 0;
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * Initialize these to 0. On shared mappings, 0's here indicate these
+	 * fields don't do cgroup accounting. On private mappings, these will be
+	 * re-initialized to the proper values, to indicate that hugetlb cgroup
+	 * reservations are to be un-charged from here.
+	 */
+	resv_map->reservation_counter = NULL;
+	resv_map->pages_per_hpage = 0;
+#endif

 	INIT_LIST_HEAD(&resv_map->region_cache);
 	list_add(&rg->link, &resv_map->region_cache);
@@ -3192,7 +3202,19 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)

 	reserve = (end - start) - region_count(resv, start, end);

-	kref_put(&resv->refs, resv_map_release);
+#ifdef CONFIG_CGROUP_HUGETLB
+	/*
+	 * Since we check for HPAGE_RESV_OWNER above, this must a private
+	 * mapping, and these values should be none-zero, and should point to
+	 * the hugetlb_cgroup counter to uncharge for this reservation.
+	 */
+	WARN_ON(!resv->reservation_counter);
+	WARN_ON(!resv->pages_per_hpage);
+
+	hugetlb_cgroup_uncharge_counter(
+			resv->reservation_counter,
+			(end - start) * resv->pages_per_hpage);
+#endif

 	if (reserve) {
 		/*
@@ -3202,6 +3224,8 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 		gbl_reserve = hugepage_subpool_put_pages(spool, reserve);
 		hugetlb_acct_memory(h, -gbl_reserve);
 	}
+
+	kref_put(&resv->refs, resv_map_release);
 }

 static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
@@ -4516,6 +4540,7 @@ int hugetlb_reserve_pages(struct inode *inode,
 	struct hstate *h = hstate_inode(inode);
 	struct hugepage_subpool *spool = subpool_inode(inode);
 	struct resv_map *resv_map;
+	struct hugetlb_cgroup *h_cg;
 	long gbl_reserve;

 	/* This should never happen */
@@ -4549,11 +4574,29 @@ int hugetlb_reserve_pages(struct inode *inode,
 		chg = region_chg(resv_map, from, to);

 	} else {
+		/* Private mapping. */
+		chg = to - from;
+
+		if (hugetlb_cgroup_charge_cgroup(
+					hstate_index(h),
+					chg * pages_per_huge_page(h),
+					&h_cg, true)) {
+			return -ENOMEM;
+		}
+
 		resv_map = resv_map_alloc();
 		if (!resv_map)
 			return -ENOMEM;

-		chg = to - from;
+#ifdef CONFIG_CGROUP_HUGETLB
+		/*
+		 * Since this branch handles private mappings, we attach the
+		 * counter to uncharge for this reservation off resv_map.
+		 */
+		resv_map->reservation_counter =
+			&h_cg->reserved_hugepage[hstate_index(h)];
+		resv_map->pages_per_hpage = pages_per_huge_page(h);
+#endif

 		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 119176a0b2ec5..06e99ae1fec81 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -19,18 +19,6 @@
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>

-struct hugetlb_cgroup {
-	struct cgroup_subsys_state css;
-	/*
-	 * the counter to account for hugepages from hugetlb.
-	 */
-	struct page_counter hugepage[HUGE_MAX_HSTATE];
-	/*
-	 * the counter to account for hugepage reservations from hugetlb.
-	 */
-	struct page_counter reserved_hugepage[HUGE_MAX_HSTATE];
-};
-
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
 #define MEMFILE_IDX(val)	(((val) >> 16) & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
--
2.23.0.rc1.153.gdeed80330f-goog

