Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00260C5AE5C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:32:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADD37222C9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 23:32:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RhQSqz9G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADD37222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B2D46B000D; Tue, 10 Sep 2019 19:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 564246B000E; Tue, 10 Sep 2019 19:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42C036B0010; Tue, 10 Sep 2019 19:32:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id 2221D6B000D
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 19:32:06 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id B93AE181AC9C9
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:32:05 +0000 (UTC)
X-FDA: 75920611410.07.jail67_2f5335d81323a
X-HE-Tag: jail67_2f5335d81323a
X-Filterd-Recvd-Size: 7505
Received: from mail-pg1-f201.google.com (mail-pg1-f201.google.com [209.85.215.201])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 23:32:05 +0000 (UTC)
Received: by mail-pg1-f201.google.com with SMTP id a9so11559041pga.16
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 16:32:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Vuvev8Yzxd1RQX7GlTnFg8u8KyDaWAzEg+D+vv41AFA=;
        b=RhQSqz9Gow9lf3iCQJh2cOagmx6FazRfMH4sEChocwKkK/jGnMsp1AZ1niK495fZrk
         sRn6d4YWN5J1bh6nFGxjKVP6G70zs3olWAaKHpNaedsb8FuwOty0ywehJVRiG/7DofuX
         uybmLEFmUYZJPwpF8twlZl/gSn9fMdKVTRsNU2DY5f5Z7PJW2tnVVgvxa0y6o8jkZ7NH
         vIPd/YYOZ5iS9r3YloHvde/PPsjmoWSn60tdpD3/VYzKfrgcSL93m01RYogrTr6HiyuK
         m+iM8PVusjQYRgOXRPxj3Y66nWWhVOkQhQFehH/jJ0Ro7yxbajdQz+YsKWWPpBRb5CZi
         gQFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:in-reply-to:message-id:mime-version
         :references:subject:from:to:cc;
        bh=Vuvev8Yzxd1RQX7GlTnFg8u8KyDaWAzEg+D+vv41AFA=;
        b=PToASOspTxkOd+PN9LlnkO0mA6D30l9l9z46hHOt88DFWLJpJccPXjl76R066bIfBK
         +K0YBikeI48PSi5WUKbcVAwHHdyWHQfpXSUTzu06Go5q7p4Lz2arm6QfmCGeO4G2esfI
         aMZw6ImPNpcFrpp8DZI8lPy27IeVCHYxER99BrUnrxOAP/0pLg12EgMoUj9apfjbEFp2
         sIJUZpL+VNhAL/O59nG9E/kUd+HMnFrtaYulxaAifKqeFAXS0YId0pG1s0/Jh3DhmVmk
         xv9BxEyuxbkiha0SZ0vlGwc6cSxuk1V7zv1gux16wrSHQnnA5+FXQTgiMNTAm7uk205X
         FFVg==
X-Gm-Message-State: APjAAAWEf4r7ExbqUg6X+xfq8+zWXZr4s2qgXn3b4IWU2fXdxvY1pRfA
	STzzaYlWzRvm9cgq3ff71C0bsLt2Uly+jpfWQg==
X-Google-Smtp-Source: APXvYqyXGgdGxEdLLOLogNOyiNYauXGQNpF8G1qrcyLi9ZKsCxGrBA4ZsS4UbIa1HhG6T+/TP2q13PknIdsiZKtDLg==
X-Received: by 2002:a65:60d3:: with SMTP id r19mr30472526pgv.91.1568158323822;
 Tue, 10 Sep 2019 16:32:03 -0700 (PDT)
Date: Tue, 10 Sep 2019 16:31:42 -0700
In-Reply-To: <20190910233146.206080-1-almasrymina@google.com>
Message-Id: <20190910233146.206080-6-almasrymina@google.com>
Mime-Version: 1.0
References: <20190910233146.206080-1-almasrymina@google.com>
X-Mailer: git-send-email 2.23.0.162.g0b9fbb3734-goog
Subject: [PATCH v4 5/9] hugetlb: remove duplicated code
From: Mina Almasry <almasrymina@google.com>
To: mike.kravetz@oracle.com
Cc: shuah@kernel.org, almasrymina@google.com, rientjes@google.com, 
	shakeelb@google.com, gthelen@google.com, akpm@linux-foundation.org, 
	khalid.aziz@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org, 
	aneesh.kumar@linux.vnet.ibm.com, mkoutny@suse.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove duplicated code between region_chg and region_add, and refactor it into
a common function, add_reservation_in_range. This is mostly done because
there is a follow up change in this series that disables region
coalescing in region_add, and I want to make that change in one place
only. It should improve maintainability anyway on its own.

Signed-off-by: Mina Almasry <almasrymina@google.com>
---
 mm/hugetlb.c | 116 ++++++++++++++++++++++++---------------------------
 1 file changed, 54 insertions(+), 62 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bea51ae422f63..ce5ed1056fefd 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -244,6 +244,57 @@ struct file_region {
 	long to;
 };

+static long add_reservation_in_range(
+		struct resv_map *resv, long f, long t, bool count_only)
+{
+
+	long chg = 0;
+	struct list_head *head = &resv->regions;
+	struct file_region *rg = NULL, *trg = NULL, *nrg = NULL;
+
+	/* Locate the region we are before or in. */
+	list_for_each_entry(rg, head, link)
+		if (f <= rg->to)
+			break;
+
+	/* Round our left edge to the current segment if it encloses us. */
+	if (f > rg->from)
+		f = rg->from;
+
+	chg = t - f;
+
+	/* Check for and consume any regions we now overlap with. */
+	nrg = rg;
+	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
+		if (&rg->link == head)
+			break;
+		if (rg->from > t)
+			break;
+
+		/* We overlap with this area, if it extends further than
+		 * us then we must extend ourselves.  Account for its
+		 * existing reservation.
+		 */
+		if (rg->to > t) {
+			chg += rg->to - t;
+			t = rg->to;
+		}
+		chg -= rg->to - rg->from;
+
+		if (!count_only && rg != nrg) {
+			list_del(&rg->link);
+			kfree(rg);
+		}
+	}
+
+	if (!count_only) {
+		nrg->from = f;
+		nrg->to = t;
+	}
+
+	return chg;
+}
+
 /*
  * Add the huge page range represented by [f, t) to the reserve
  * map.  Existing regions will be expanded to accommodate the specified
@@ -257,7 +308,7 @@ struct file_region {
 static long region_add(struct resv_map *resv, long f, long t)
 {
 	struct list_head *head = &resv->regions;
-	struct file_region *rg, *nrg, *trg;
+	struct file_region *rg, *nrg;
 	long add = 0;

 	spin_lock(&resv->lock);
@@ -287,38 +338,7 @@ static long region_add(struct resv_map *resv, long f, long t)
 		goto out_locked;
 	}

-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-
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
-	}
-
-	add += (nrg->from - f);		/* Added to beginning of region */
-	nrg->from = f;
-	add += t - nrg->to;		/* Added to end of region */
-	nrg->to = t;
+	add = add_reservation_in_range(resv, f, t, false);

 out_locked:
 	resv->adds_in_progress--;
@@ -345,8 +365,6 @@ static long region_add(struct resv_map *resv, long f, long t)
  */
 static long region_chg(struct resv_map *resv, long f, long t)
 {
-	struct list_head *head = &resv->regions;
-	struct file_region *rg;
 	long chg = 0;

 	spin_lock(&resv->lock);
@@ -375,34 +393,8 @@ static long region_chg(struct resv_map *resv, long f, long t)
 		goto retry_locked;
 	}

-	/* Locate the region we are before or in. */
-	list_for_each_entry(rg, head, link)
-		if (f <= rg->to)
-			break;
-
-	/* Round our left edge to the current segment if it encloses us. */
-	if (f > rg->from)
-		f = rg->from;
-	chg = t - f;
-
-	/* Check for and consume any regions we now overlap with. */
-	list_for_each_entry(rg, rg->link.prev, link) {
-		if (&rg->link == head)
-			break;
-		if (rg->from > t)
-			goto out;
+	chg = add_reservation_in_range(resv, f, t, true);

-		/* We overlap with this area, if it extends further than
-		 * us then we must extend ourselves.  Account for its
-		 * existing reservation. */
-		if (rg->to > t) {
-			chg += rg->to - t;
-			t = rg->to;
-		}
-		chg -= rg->to - rg->from;
-	}
-
-out:
 	spin_unlock(&resv->lock);
 	return chg;
 }
--
2.23.0.162.g0b9fbb3734-goog

