Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE2C7C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9129F2133D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:06:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fY5GcgBj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9129F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 362FA6B0272; Tue,  2 Apr 2019 19:06:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 313CD6B0274; Tue,  2 Apr 2019 19:06:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18F206B0275; Tue,  2 Apr 2019 19:06:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC12E6B0272
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:06:34 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id q127so13061923qkd.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DgIYnn/fssjAlV/t8WH3LwNCV6/gchODyjSyz2g47Ag=;
        b=Z9M/pasNnt2hqDhQAyIV+tZ06I1vNKNYuWUSIBVMsmK43dk5/x8N8UAFzIzSRR3A/B
         Agr8v7fPRjsROc8xp2JbfqtWn9tePmrEUWBqrFdeNEua0HSJO89grDRq9dSl1wpUcYZM
         itBpGi2syNs8IrOWSJUgQNPCU/2rfD0oF6kaL0qjtGH2Oz/0beQpPdNXP/vCkcyZSWLg
         E2God0zIAyvnMO1DEB1uRKLZCj5+P+6i/PSv0Ys6AVGAVQtNMGLrlL7ppxhUhdGB+sOI
         /krUufR/+YTUlM49qhTOg0ANaPJpvPN2Mkys6W6n5SUZZ1H7vCNogfsAAb3ORV9Dbdta
         4vdQ==
X-Gm-Message-State: APjAAAW2+azi2VcFeFPEvlJu/O7ZdOMZ72YQGMQ4O4Ei0yHxfhk0wuXN
	46QGjpCWKlkS7TOIpCM/4E+UtrgGsOddLznFYlL11sdfH93414JWQk/sVresrjMA229KuIGI69h
	lpnRBRRljRk6+frG1BaK6e/AV94pKBDUOhD96NWAhHGwl2OlqsDfusMvRhQwoNaE=
X-Received: by 2002:a37:5088:: with SMTP id e130mr33666571qkb.206.1554246394711;
        Tue, 02 Apr 2019 16:06:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1Ge2MbfIe8DNX1MkJE1pP3JepQ9/KjZqkA+X6vtP26g1HDRqkrIOGMNXwJW45sCNRoXLM
X-Received: by 2002:a37:5088:: with SMTP id e130mr33666521qkb.206.1554246393852;
        Tue, 02 Apr 2019 16:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554246393; cv=none;
        d=google.com; s=arc-20160816;
        b=JFuniKwm9rUBkzR9muCOktQIlewPs7K83df9jB568xesDWnrZ5B0il9kfuHzetzJ0x
         GVv7FIlIKHf3l3s/ZeIYziYv9aHjm7BnM74XqpXHtitOIYEKo4tM+m3iEU7/QaPdkPWj
         oSmMN7R3u8LcPGBcaOyYK9PZDL6b0DZyfsy3QyizE0Km7N+E3By/dX1Jj9WGymGdep0Q
         sFY4l+qb2IdgreI3h4Tg64HzfISMwIfvTMPudweMYTvvSNDLNOyiD+WE590wFQ05B1VR
         nr3UhvpUZebFF+BC5pe7meM1TeuFiF6RuCHaP+4Lc37MuCTpC8lfc5tJOErNH10ONocv
         e40A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DgIYnn/fssjAlV/t8WH3LwNCV6/gchODyjSyz2g47Ag=;
        b=cCKwosP6bnSdU7t/Uo74Q5YGxnCCNPMT2muL0Q9+YyDtbmz9uf281lFQ/loHYO42fb
         MP7F3jrYGzVLpeHQTXMAiFL4GZsPIvysGtZe2ZRJm7rKPeEGI59/uA1e/Z5a5/tTzkba
         SqMkDCC25MzSt1CWukZbePh++uskN5kw7SaMO2c6tpXdfj75//E8k4n94LVqpGTesXkJ
         WVIQJPvMipBShOTHV9D5//bF7d1vIAnt4dXv3vwOd6vzcJJgWfALVmfywzBd21XVx21M
         7I7ixdFiYxeuN8b0nupluwn2enxznn0vNBSunyTIxMOzb8YCoNRC/koeepm3gNckQAJD
         kDTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=fY5GcgBj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id q39si1648087qtc.321.2019.04.02.16.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:06:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=fY5GcgBj;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 92E3F21F4F;
	Tue,  2 Apr 2019 19:06:33 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Tue, 02 Apr 2019 19:06:33 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=DgIYnn/fssjAlV/t8WH3LwNCV6/gchODyjSyz2g47Ag=; b=fY5GcgBj
	A5RmmSax0s7ajf0TNyjjdaOe6cLvx0pgrb3jofsE3nCice4TPLerLhcX5/2ABdgU
	2K+GTTOPLBMXz8+bCLgI9peLM9xjggKKl6Qm78+9feW7pEFv5G7xiejTWshm22bQ
	d0m+b6cFQhg+Z1Muyhlk1dZdXfZUs3RC+DxmW6f9+hTW7h/Yr29bdYL4nha7POyB
	ZBvS6jZkanocSqY10uSiaHPH0fSUzWt8VF4ae4kUZu/C8GDdwlwocI8IZweV5N2K
	Wl8OhPY5BNQ7HMIvu9r+k6k7Kt/yrk/3kHNxQG0uZGRsHv0Ifc1xrzgdwrwc7Ifw
	+TOc3UJrPUmNuA==
X-ME-Sender: <xms:-eqjXFS1l0QkshLEkPLnUyXddayY3w6OB5je24bA5QKGpmRjSJDfFw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtddugdduieculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhgggfestdekredtredttden
    ucfhrhhomhepfdfvohgsihhnucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrh
    hnvghlrdhorhhgqeenucfkphepuddvgedrudeiledrvdejrddvtdeknecurfgrrhgrmhep
    mhgrihhlfhhrohhmpehtohgsihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghruf
    hiiigvpedu
X-ME-Proxy: <xmx:-eqjXNKWZNYWlNe2yx4DSl-eHPAJpQlhD-F1YxBBO_0jFHGZGopi5w>
    <xmx:-eqjXG2cWElsHtE8IFgcgqFty_Rk7YbhvB-Wbd-XAexQ6lB4XsSODA>
    <xmx:-eqjXAIfHFI53Em0abjWfaFj_acmGAkv0q4P_-kWfvYDcaDE7BIvDg>
    <xmx:-eqjXN2-L09x1CtWlz3eW2J8LtjBc0G2GsqGn7lMFdNBNX6kkCXWug>
Received: from eros.localdomain (124-169-27-208.dyn.iinet.net.au [124.169.27.208])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0362C10391;
	Tue,  2 Apr 2019 19:06:29 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Date: Wed,  3 Apr 2019 10:05:40 +1100
Message-Id: <20190402230545.2929-3-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402230545.2929-1-tobin@kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we reach inside the list_head.  This is a violation of the
layer of abstraction provided by the list_head.  It makes the code
fragile.  More importantly it makes the code wicked hard to understand.

The code reaches into the list_head structure to counteract the fact
that the list _may_ have been changed during slob_page_alloc().  Instead
of this we can add a return parameter to slob_page_alloc() to signal
that the list was modified (list_del() called with page->lru to remove
page from the freelist).

This code is concerned with an optimisation that counters the tendency
for first fit allocation algorithm to fragment memory into many small
chunks at the front of the memory pool.  Since the page is only removed
from the list when an allocation uses _all_ the remaining memory in the
page then in this special case fragmentation does not occur and we
therefore do not need the optimisation.

Add a return parameter to slob_page_alloc() to signal that the
allocation used up the whole page and that the page was removed from the
free list.  After calling slob_page_alloc() check the return value just
added and only attempt optimisation if the page is still on the list.

Use list_head API instead of reaching into the list_head structure to
check if sp is at the front of the list.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slob.c | 51 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 37 insertions(+), 14 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..07356e9feaaa 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -213,13 +213,26 @@ static void slob_free_pages(void *b, int order)
 }
 
 /*
- * Allocate a slob block within a given slob_page sp.
+ * slob_page_alloc() - Allocate a slob block within a given slob_page sp.
+ * @sp: Page to look in.
+ * @size: Size of the allocation.
+ * @align: Allocation alignment.
+ * @page_removed_from_list: Return parameter.
+ *
+ * Tries to find a chunk of memory at least @size bytes big within @page.
+ *
+ * Return: Pointer to memory if allocated, %NULL otherwise.  If the
+ *         allocation fills up @page then the page is removed from the
+ *         freelist, in this case @page_removed_from_list will be set to
+ *         true (set to false otherwise).
  */
-static void *slob_page_alloc(struct page *sp, size_t size, int align)
+static void *slob_page_alloc(struct page *sp, size_t size, int align,
+			     bool *page_removed_from_list)
 {
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
+	*page_removed_from_list = false;
 	for (prev = NULL, cur = sp->freelist; ; prev = cur, cur = slob_next(cur)) {
 		slobidx_t avail = slob_units(cur);
 
@@ -254,8 +267,10 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 			}
 
 			sp->units -= units;
-			if (!sp->units)
+			if (!sp->units) {
 				clear_slob_page_free(sp);
+				*page_removed_from_list = true;
+			}
 			return cur;
 		}
 		if (slob_last(cur))
@@ -269,10 +284,10 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
 	struct page *sp;
-	struct list_head *prev;
 	struct list_head *slob_list;
 	slob_t *b = NULL;
 	unsigned long flags;
+	bool _unused;
 
 	if (size < SLOB_BREAK1)
 		slob_list = &free_slob_small;
@@ -284,6 +299,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
 	list_for_each_entry(sp, slob_list, lru) {
+		bool page_removed_from_list = false;
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -296,18 +312,25 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		if (sp->units < SLOB_UNITS(size))
 			continue;
 
-		/* Attempt to alloc */
-		prev = sp->lru.prev;
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(sp, size, align, &page_removed_from_list);
 		if (!b)
 			continue;
 
-		/* Improve fragment distribution and reduce our average
-		 * search time by starting our next search here. (see
-		 * Knuth vol 1, sec 2.5, pg 449) */
-		if (prev != slob_list->prev &&
-				slob_list->next != prev->next)
-			list_move_tail(slob_list, prev->next);
+		/*
+		 * If slob_page_alloc() removed sp from the list then we
+		 * cannot call list functions on sp.  If so allocation
+		 * did not fragment the page anyway so optimisation is
+		 * unnecessary.
+		 */
+		if (!page_removed_from_list) {
+			/*
+			 * Improve fragment distribution and reduce our average
+			 * search time by starting our next search here. (see
+			 * Knuth vol 1, sec 2.5, pg 449)
+			 */
+			if (!list_is_first(&sp->lru, slob_list))
+				list_rotate_to_front(&sp->lru, slob_list);
+		}
 		break;
 	}
 	spin_unlock_irqrestore(&slob_lock, flags);
@@ -326,7 +349,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		INIT_LIST_HEAD(&sp->lru);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(sp, size, align, &_unused);
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-- 
2.21.0

