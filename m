Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFFCBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4D47206DF
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 01:08:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="2EJQ+BG+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4D47206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4662C8E0007; Sun, 10 Mar 2019 21:08:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 419948E0002; Sun, 10 Mar 2019 21:08:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28FCC8E0007; Sun, 10 Mar 2019 21:08:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1EC78E0002
	for <linux-mm@kvack.org>; Sun, 10 Mar 2019 21:08:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id i21so3883007qtq.6
        for <linux-mm@kvack.org>; Sun, 10 Mar 2019 18:08:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zLp9xmyRL5FGSf3lybn7avPXaeiP5CieRjoPUWOw1UY=;
        b=b/iZV6bQqme1ay3k+kcbrwAUBmtr7dkCMc6QcNmh4/rl7jYgwce34bHirZcIl1hG3Y
         Kj02jSeOOCDkZepK6amjjtVcuRA0T/j29JfK4WkGN77iL6srerYySy1uiclIP68QncKO
         vkKaNf6IRi0Y3UG7QYZ9Us1SQI1PXpK7trardvBuv3sBes+UedPimuyNQYCtwcdMuMDa
         RLXAnbgk9NwlP4OT2M8oJ8egQ9j1CyQVpfvfgkyfHr7f8HjyT4vcBu2uqtYdhJ2/cQwl
         la6lB3+3t//zzo2WazfYysuhvxCoYf+qMIUZ42rYHMbZf7V1GIUEek3wjfgsJwYbY2Kw
         tJzg==
X-Gm-Message-State: APjAAAViJ57lSnJW7QUmRpLvGETzNfvwB7GGgwtvnF4XdwDm2OOEpolf
	iorECwrjDmOCMMsVVAHXXfelis5kkYK8JlGXLVuGkQBUWXDZF0NVRzoHgqJpufGbDMduIxK/uql
	fuRZNmcnyWWX3guThTbpVASc6exw8JGlhrP4Fp5rOqh4adgP7+lmE7G/aQbTXfGI=
X-Received: by 2002:a37:3087:: with SMTP id w129mr21456616qkw.255.1552266513776;
        Sun, 10 Mar 2019 18:08:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyieVjuOTswNwETquxA473LnBI825lAi2HRFP0+f5pUk2P3iH78q4v3ABOCPc4kfyYSOwK2
X-Received: by 2002:a37:3087:: with SMTP id w129mr21456582qkw.255.1552266512726;
        Sun, 10 Mar 2019 18:08:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552266512; cv=none;
        d=google.com; s=arc-20160816;
        b=hWRbi2zrusUQDemDyZHl9KAV/6Rdwp75ynDu5izgZ+un5ecCH9yFDpRD+75xR7g7Rc
         se60ee62wlX2GM1IcHiXWyuj3vuraJIqApEq+5/oE0/fJbrJkCWYdoHujoiJ3sOUlUmy
         NJpTniNG5Zd3JsbPR2B9a45pfL14IdQR0WJnMNgFDwtyAqVcXhrZIKtzTzVDgXAAnGW7
         WzI3i4vF3VuFKDn9okNsaelW3/neU7f2DjRhf3oLi5ptjhOMiVfXYseQsWJATX5v791L
         tu4sKeLQMJzOodDJBl7eMkeJnRPKWJBx7tWrlTuOP5wmvI7YHAYMAWoMzuku7x+dwaYn
         DWuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zLp9xmyRL5FGSf3lybn7avPXaeiP5CieRjoPUWOw1UY=;
        b=xnZfwIIsdYDYnTC1onh2gL1eWSNIaWXipbx1ZFFSjQVNLZecmvzIzwHnVOGUJgh1QZ
         JN5YLC1YdRUJqDRSiho0wqAFEhE/OkMvyrtLB9njxIbey+F+Q5W+Rv6KwDYtwV0zQqhd
         SKiVHG8hqwjvcNsNiK+EHZcl+oVZaYZls4JK2KOUK6bitnVBCLX8CDlea7/JIfWoYWrk
         vnDvjdwCMYPTdHCK4UwSo4WTU0+4DxKKRBdI05VWQw9t/V/qVxDahbhKYZU661JSFW7e
         G1gOY+oH4qrgk8etFN5hNfkOBpsgimRlpxpjRmqL89qcM3H6db1y89Rw7oFbAy1ldF6Y
         xNKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2EJQ+BG+;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id b51si2506961qtc.224.2019.03.10.18.08.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Mar 2019 18:08:32 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=2EJQ+BG+;
       spf=softfail (google.com: domain of transitioning tobin@kernel.org does not designate 66.111.4.26 as permitted sender) smtp.mailfrom=tobin@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 52BC521F86;
	Sun, 10 Mar 2019 21:08:32 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Sun, 10 Mar 2019 21:08:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:subject:to
	:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=zLp9xmyRL5FGSf3lybn7avPXaeiP5CieRjoPUWOw1UY=; b=2EJQ+BG+
	Wfxvf5TF8zZb4G4z2IhbAoh5oBkt3SQlgxYO3tIAq+MxHR08gW+uZZ8AAfTd69o5
	3ykj1DSQCSs0smdS8cJ+CUxT5d1IijEGr+UEjS03bkm1vFfsQQWUxQKAbVskNLKN
	mRzUbFBzHZIpGP7N2eC5Uf4GFQcefWMD7QOEVUmZOfAQLOxJUh0BrmuUInXhfF5T
	5Dur9NdWoOTWxukjO+CTE+XJ+HMZy4TrXiN8k/wuhYLk1+QeE37r40TPgeOgBMhP
	co69JcKtfJWuM7VW/puE7lOdFRkjmXp6+Ef6zG3rIa73lrgbdGb8ATZX7zJR81Mb
	p4oO0l0FDrCXTw==
X-ME-Sender: <xms:ELWFXGuYUpdG__mG4R7_mE-NQQp32ROSIxvotozOPmzIp11Sbf4Fiw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeehgdeftdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefhvffufffkofgjfhgggfestdekredtredttdenucfhrhhomhepfdfvohgsihhn
    ucevrdcujfgrrhguihhnghdfuceothhosghinheskhgvrhhnvghlrdhorhhgqeenucfkph
    epuddukedrvdduuddrudelvddrieeinecurfgrrhgrmhepmhgrihhlfhhrohhmpehtohgs
    ihhnsehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedv
X-ME-Proxy: <xmx:ELWFXOpXnO07wEEAZG9LB9fay5XP41VtwW7zkCD_D5W_20mU87gVrg>
    <xmx:ELWFXN7GnxWF1fQyrisYc2ES2POZ0T0raJRznE4RyVbuWfsTTb7qNA>
    <xmx:ELWFXLokIx1EpLqGCdYscuq8YMmFe-86FqjoCp_CTp2Vi34MR87yEQ>
    <xmx:ELWFXNSxYNI_9q7Vb2wUI5KpLqCAx3CsGaxqTuaq71AGqoFJVV1-VQ>
Received: from eros.localdomain (ppp118-211-192-66.bras1.syd2.internode.on.net [118.211.192.66])
	by mail.messagingengine.com (Postfix) with ESMTPA id 327CB10310;
	Sun, 10 Mar 2019 21:08:28 -0400 (EDT)
From: "Tobin C. Harding" <tobin@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] slob: Use slab_list instead of lru
Date: Mon, 11 Mar 2019 12:07:44 +1100
Message-Id: <20190311010744.5862-5-tobin@kernel.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190311010744.5862-1-tobin@kernel.org>
References: <20190311010744.5862-1-tobin@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently we use the page->lru list for maintaining lists of slabs.  We
have a list in the page structure (slab_list) that can be used for this
purpose.  Doing so makes the code cleaner since we are not overloading
the lru list.

Use the slab_list instead of the lru list for maintaining lists of
slabs.

Signed-off-by: Tobin C. Harding <tobin@kernel.org>
---
 mm/slob.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb44..ee68ff2a2833 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -112,13 +112,13 @@ static inline int slob_page_free(struct page *sp)
 
 static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->lru, list);
+	list_add(&sp->slab_list, list);
 	__SetPageSlobFree(sp);
 }
 
 static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->lru);
+	list_del(&sp->slab_list);
 	__ClearPageSlobFree(sp);
 }
 
@@ -283,7 +283,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, lru) {
+	list_for_each_entry(sp, slob_list, slab_list) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
@@ -297,7 +297,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 			continue;
 
 		/* Attempt to alloc */
-		prev = sp->lru.prev;
+		prev = sp->slab_list.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
@@ -323,7 +323,7 @@ static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
 		sp->freelist = b;
-		INIT_LIST_HEAD(&sp->lru);
+		INIT_LIST_HEAD(&sp->slab_list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
-- 
2.21.0

