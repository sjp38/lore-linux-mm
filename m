Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 652CAC43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:31:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05A4620880
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 03:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="J08A5mJb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05A4620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BCE66B0005; Mon,  1 Apr 2019 23:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96CE56B0007; Mon,  1 Apr 2019 23:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85B776B0008; Mon,  1 Apr 2019 23:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66C0E6B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 23:31:17 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s26so3093795qkm.19
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 20:31:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qS74YLv32TK4OdRxyP79l+k5LQKLZkF6HF7u7XLPsVY=;
        b=IeUYizvvgvczrK3Hu4UEFynXphtmjLmKDAgxI+SMoNfMWM6gzbRNAgj4xq9DE2aq2K
         SvmRlIozMpH/un1WBRAl6wsABBoYYtXmel01EymTt0JLYaV0E2iMMODiINOuPY19WPaz
         uFY5eJCv9yN6LR+yI4liPMTRibKDiq0w3UvoQ1ydmKB8hzRXRbR5Iztustetue9TRtV4
         WgyoV9DYJ0rdDDtQ05NQGePmAUVPdRrr5JP3MwwwBaUQ3M/sXggk555zmTSfvJqCE8cY
         56CNwF93v+yWSL9N/2/ArXdkDAVOxtsHlVXuxYmiSvwkNt08Ji66NNa+CXMn9x07PChg
         /Oqg==
X-Gm-Message-State: APjAAAXxWVcfH0Q90N+YiFWRar1x5WXXkWHnOYXFMf5SvzhI8roEP+jl
	teSZKGxlIouJFNjnFHqSoecPBfGVAv0jFbXowWJvxoL8wm2YPU4paz6rqtCyEXDpNF0sTM/sfZl
	Wyji8T8FN/FsuUyTFVbIw37wzxa+URfWWzAuMQE+9ehoYHCwAivtsqwXeA2LpieU=
X-Received: by 2002:a37:6748:: with SMTP id b69mr54221276qkc.79.1554175877104;
        Mon, 01 Apr 2019 20:31:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRNsaPeJe4MjM3GXgKagIB9effkkgOWIzyNgUBRzuSnbBNgfiwxLF6xkg32ZLMWkhWWxyW
X-Received: by 2002:a37:6748:: with SMTP id b69mr54221206qkc.79.1554175875729;
        Mon, 01 Apr 2019 20:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554175875; cv=none;
        d=google.com; s=arc-20160816;
        b=Oyji5CT6ecyF084DP2afctS74CoHYIOvXuO9jCwTxgzyxXjs1ibJ/iDK5Bn64jclg+
         h2U3GZGwzjgBjR5qDTVtXpLe2U3Erkkc5dvRKM7f+awa4AYyU0Loi3bKO/kVRFyPBeTl
         /0EIVd1nCVwkvc4pEveJeUbC5jTezB660KMGxC8Gv2D7l8OG5pV0G22IXSBuBV0Y0uTj
         oQYr54VW9sweABQaxBr5l7mNroqAz3XOicFw39LUg5uOGBAMZcP8Qq/CwvM1DeiBoOZ2
         uLXliEsuJ6QjgfO6NIMzENBPkgFFkAAVyFVBU3pAKTn9m3Ds57rhPAJtYS5FIjBrQruZ
         xJcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=qS74YLv32TK4OdRxyP79l+k5LQKLZkF6HF7u7XLPsVY=;
        b=CFDw/Lmb1Sro38A0LVfKP1lJQxlljMuarJC86MDmd5qF5j566wyURZGWVJzG9qLFnn
         RgrVDD+Xcg70iOJnawvJHlulxxjSb5W+chO4NZskAH5sk7VZAvCjOb0li2mBSUTPvNMo
         9QzlqVaDOA4idYdgocwlDmhRzm4rNeTi4uukWKr5JevQ9cdmpypRDNd99AZyfQO2OnZX
         PYgZMvlSH9KwuhhQsBEg6ymsI/H+eYDOt6dl/IOvSEXvloPaZAvnbsnRF0wdjpbfpZQn
         QGeiSXQ5jRr6HgkX3UQNlahSdmuIp1IRpkxa2+qwav9pDN0/qCjCOmg7vw4dxo530S1x
         hH0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J08A5mJb;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id n4si6789448qkg.43.2019.04.01.20.31.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 20:31:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=J08A5mJb;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 7444822246;
	Mon,  1 Apr 2019 23:31:15 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Mon, 01 Apr 2019 23:31:15 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=qS74YLv32TK4OdRxyP79l+k5LQKLZkF6HF7u7XLPsVY=; b=J08A5mJb
	UVl31TB6lBjTNCDo3r2bk4xwTFtJIQ9a+1YCHSkj1oQGYW7B3uWXxsbHyGIoyaY6
	1cSMIi8SOQdEFgMG3V1puLlXCNvSlftMGeu4BP1PPbcyeVt1+CFXp/GljiqrGZ0Y
	hsuDAsRcHfDYGAaJCmkVuwj1wU9Kg+588EQPWr8MFpUTH8BJA8/JDQ0Ldap/S9F8
	+yTfqCBElrEHZlrL72Ngk6jd6gw9WFdY65Fvbrr8mHQB5yd/8MwpBE6rPxOMQUsW
	z2l/Jb4UG2O/9BpRfOnjSdL9RQYz4oP30CF+IwA0i1PCrw/JeY5J69iOE9vfwE8H
	EQpqkROtgrjsDQ==
X-ME-Sender: <xms:g9eiXCHV__yzzZ4dYncfoCwTDXxYKKqFVUVI1ZtzwIsUjJdJEor6WA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrleehgdeikecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddvgedrudejuddrvdefrdduvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:g9eiXA1IwyQqtEnT7rMxLhFSYTAYY4Uk3HXvutL05cjcw8FiG7Ma4w>
    <xmx:g9eiXOxOo2l5ZMyZEBeDEA5jJdFenChkeDY_TfKSoxghmCD5vBFleQ>
    <xmx:g9eiXBjwd-RlVNhHmI9SHrSWUgvXthaKe8RyCy4NstFCi9iazAzT8g>
    <xmx:g9eiXAr0-Wuk57VBwwiHYe4poMe5AbqzVM_rWxW9QfdpD9ehnSzNdg>
Received: from eros.localdomain (124-171-23-122.dyn.iinet.net.au [124.171.23.122])
	by mail.messagingengine.com (Postfix) with ESMTPA id 549AC100E5;
	Mon,  1 Apr 2019 23:31:11 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	LKP <lkp@01.org>,
	Roman Gushchin <guro@fb.com>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel test robot <lkp@intel.com>
Subject: [PATCH 1/1] slob: Only use list functions when safe to do so
Date: Tue,  2 Apr 2019 14:29:57 +1100
Message-Id: <20190402032957.26249-2-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402032957.26249-1-tobin@kernel.org>
References: <20190402032957.26249-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we call (indirectly) list_del() then we manually try to combat
the fact that the list may be in an undefined state by getting 'prev'
and 'next' pointers in a somewhat contrived manner.  It is hard to
verify that this works for all initial states of the list.  Clearly the
author (me) got it wrong the first time because the 0day kernel testing
robot managed to crash the kernel thanks to this code.

All this is done in order to do an optimisation aimed at preventing
fragmentation at the start of a slab.  We can just skip this
optimisation any time the list is put into an undefined state since this
only occurs when an allocation completely fills the slab and in this
case the optimisation is unnecessary since we have not fragmented the slab
by this allocation.

Change the page pointer passed to slob_alloc_page() to be a double
pointer so that we can set it to NULL to indicate that the page was
removed from the list.  Skip the optimisation if the page was removed.

Found thanks to the kernel test robot, email subject:

	340d3d6178 ("mm/slob.c: respect list_head abstraction layer"):  kernel BUG at lib/list_debug.c:31!

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slob.c | 50 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 30 insertions(+), 20 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 21af3fdb457a..c543da10df45 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -213,10 +213,18 @@ static void slob_free_pages(void *b, int order)
 }
 
 /*
- * Allocate a slob block within a given slob_page sp.
+ * slob_page_alloc() - Allocate a slob block within a given slob_page sp.
+ * @spp: Page to look in, return parameter.
+ * @size: Size of the allocation.
+ * @align: Allocation alignment.
+ *
+ * Tries to find a chunk of memory at least @size within page.  If the
+ * allocation fills up page then page is removed from list, in this case
+ * *spp will be set to %NULL to signal that list removal occurred.
  */
-static void *slob_page_alloc(struct page *sp, size_t size, int align)
+static void *slob_page_alloc(struct page **spp, size_t size, int align)
 {
+	struct page *sp = *spp;
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
@@ -254,8 +262,11 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
 			}
 
 			sp->units -= units;
-			if (!sp->units)
+			if (!sp->units) {
 				clear_slob_page_free(sp);
+				/* Signal that page was removed from list. */
+				*spp = NULL;
+			}
 			return cur;
 		}
 		if (slob_last(cur))
@@ -268,7 +279,7 @@ static void *slob_page_alloc(struct page *sp, size_t size, int align)
  */
 static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
-	struct page *sp, *prev, *next;
+	struct page *sp;
 	struct list_head *slob_list;
 	slob_t *b = NULL;
 	unsigned long flags;
@@ -283,6 +294,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
 	list_for_each_entry(sp, slob_list, slab_list) {
+		struct page **spp = &sp;
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -295,27 +307,25 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		if (sp->units < SLOB_UNITS(size))
 			continue;
 
-		/*
-		 * Cache previous entry because slob_page_alloc() may
-		 * remove sp from slob_list.
-		 */
-		prev = list_prev_entry(sp, slab_list);
-
 		/* Attempt to alloc */
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(spp, size, align);
 		if (!b)
 			continue;
 
-		next = list_next_entry(prev, slab_list); /* This may or may not be sp */
-
 		/*
-		 * Improve fragment distribution and reduce our average
-		 * search time by starting our next search here. (see
-		 * Knuth vol 1, sec 2.5, pg 449)
+		 * If slob_page_alloc() removed sp from the list then we
+		 * cannot call list functions on sp.  Just bail, don't
+		 * worry about the optimisation below.
 		 */
-		if (!list_is_first(&next->slab_list, slob_list))
-			list_rotate_to_front(&next->slab_list, slob_list);
-
+		if (*spp) {
+			/*
+			 * Improve fragment distribution and reduce our average
+			 * search time by starting our next search here. (see
+			 * Knuth vol 1, sec 2.5, pg 449)
+			 */
+			if (!list_is_first(&sp->slab_list, slob_list))
+				list_rotate_to_front(&sp->slab_list, slob_list);
+		}
 		break;
 	}
 	spin_unlock_irqrestore(&slob_lock, flags);
@@ -334,7 +344,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
-		b = slob_page_alloc(sp, size, align);
+		b = slob_page_alloc(&sp, size, align);
 		BUG_ON(!b);
 		spin_unlock_irqrestore(&slob_lock, flags);
 	}
-- 
2.21.0

