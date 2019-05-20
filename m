Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F04C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F6DA216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F6DA216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9C7C6B0266; Mon, 20 May 2019 10:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A74C66B0269; Mon, 20 May 2019 10:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEFC6B026A; Mon, 20 May 2019 10:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28A986B0266
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:34 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id k27so2626708lfj.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Lzk/TJG16V8mXaPrVAS/SPcGg77NW4YCV5EqRztW4Nw=;
        b=Ws9xIL9pHUbJ+K9/eFSwTAKGrr4Vvc6XVV9gJQuI+/XUHaHSoy6jMvP7I9EJYMvBCc
         caW8rAZEtSX7WJA74yFP7v1QhuAh/MB7kisg24pu5yZ+iLfCiPA0Ya2Ijdrux37gDBcc
         64uP2mUaDg2GtDP9sr2M+qq9iDrH2Fvb0S4J1OQJkhFessE0ZDc94Wn7MInvHAABlCZS
         R1wjJTp7M8Mj9aQIZmZLzkrrsNobBe0tw6CGY01IwPtbm2o7ORX7C+lOlLX3eY1kmS1T
         W5WeQwpZzuQGPr2CMIQMlR9QpjnOkMMkTxuqwP/XjHxj11jxdF2MzJNlC8UeaM+mK5zA
         qBvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAURlYOqJlUup6vUNKlxL0xbGs8QPDeDA3BVvAuBCl8S4LjOMtMp
	xUM+M8XICc2OTDbCxgHYdDYrp3Pz3CAy/A/wy+Dah+fKGtQT26bjli1AclPT29hOetLHgpp3PId
	ogocH6XIzXjKHU7gxyEqaMYd0eaQ3OcPnqSu9Ny+c607W+PTih4QQfM5N56HlfGY3ww==
X-Received: by 2002:ac2:494f:: with SMTP id o15mr22584342lfi.22.1558360833555;
        Mon, 20 May 2019 07:00:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEUJWkFQoQZUHjCkKN2Fn025WPJpGHGGfCjunBwh2t+3OFN2S17anJMnRXBL2GPB7e4bNF
X-Received: by 2002:ac2:494f:: with SMTP id o15mr22584266lfi.22.1558360832042;
        Mon, 20 May 2019 07:00:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360832; cv=none;
        d=google.com; s=arc-20160816;
        b=e+/ZtapWkkDVgTk7UDWxJ5FFTfhvaXI7TE2dOrahW12XCYMGrnT385zCryKlwg4lRf
         tLia1w293OKCpcIQQWFYk1XRt0Vl1UyC8TEIgb5OGbNWQELOQzK+9VVvcr/fDe37YBI0
         eekpM66LqSphm0n/8q4aj5scEkFI4iikFdJJUtw0SP9JHJD2AUCaaZv2+A5ooHf988ri
         nrn08z71HrpjNAzGDYzE6rhchvyKjS5XLMpJ5zf5M8BYPlFFW23qT9kGziyIa66o7F9W
         r9+wGbpGrhybsYPKvBQI+nXdy5doDcwrexg2NifWAkUjz9ZFhJ6Jtd7xJGto+lGAFJ9a
         wNDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=Lzk/TJG16V8mXaPrVAS/SPcGg77NW4YCV5EqRztW4Nw=;
        b=bdz7l9YTiafDSlUB0o3wANZK8N6JuFrRZNOgX29qn+/eMk75w0ZoiUN6jokb3jGOIn
         4PKHITnrpJxmGRdP4UoUrtQIFaH2wj3orSSBjmKimT8FG205/ACFCD0J4xCMhrFmliA0
         HSVngTWUlqvQ0+9ZZjW0tuRZFRXdQUMjAqS2u1stOQ0tbuyKF4MM425wzXx/4zqEIxcD
         F2ogLM7pTOpTm5dHw1kJOue3KlW9sAN+VJ/u346VUDIWcr/furIjb5yeCD/ZvVAeLNjA
         X9m5Q1pk7RDy66KuVyy+ExQ4qdTQ2DpQ7EEG15kdurlEoEmdGVNHv67dhToU/drF6tRh
         turQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m13si5851967ljh.20.2019.05.20.07.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSiq4-00083Y-T0; Mon, 20 May 2019 17:00:29 +0300
Subject: [PATCH v2 5/7] mm: Introduce may_mmap_overlapped_region() helper
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:28 +0300
Message-ID: <155836082877.2441.3415778176783960096.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Extract address space limit check for overlapped regions
in a separate helper.

v2: New

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/mmap.c |   33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index e4ced5366643..260e47e917e6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -583,6 +583,24 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 	return nr_pages;
 }
 
+/*
+ * Check against address space limit, whether we may expand mm
+ * with a new mapping. Currently mapped in the given range pages
+ * are not accounted in the limit.
+ */
+static bool may_mmap_overlapped_region(struct mm_struct *mm,
+		unsigned long vm_flags, unsigned long addr, unsigned long len)
+{
+	unsigned long nr_pages = len >> PAGE_SHIFT;
+
+	if (!may_expand_vm(mm, vm_flags, nr_pages)) {
+		nr_pages -= count_vma_pages_range(mm, addr, addr + len);
+		if (!may_expand_vm(mm, vm_flags, nr_pages))
+			return false;
+	}
+	return true;
+}
+
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
@@ -1697,19 +1715,8 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long charged = 0;
 
 	/* Check against address space limit. */
-	if (!may_expand_vm(mm, vm_flags, len >> PAGE_SHIFT)) {
-		unsigned long nr_pages;
-
-		/*
-		 * MAP_FIXED may remove pages of mappings that intersects with
-		 * requested mapping. Account for the pages it would unmap.
-		 */
-		nr_pages = count_vma_pages_range(mm, addr, addr + len);
-
-		if (!may_expand_vm(mm, vm_flags,
-					(len >> PAGE_SHIFT) - nr_pages))
-			return -ENOMEM;
-	}
+	if (!may_mmap_overlapped_region(mm, vm_flags, addr, len))
+		return -ENOMEM;
 
 	/* Clear old maps */
 	while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,

