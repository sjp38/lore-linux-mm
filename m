Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E66BC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F17B020866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 08:12:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F17B020866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859C16B0003; Thu, 13 Jun 2019 04:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 809F16B0005; Thu, 13 Jun 2019 04:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F87C6B0006; Thu, 13 Jun 2019 04:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E64E6B0003
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:12:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o13so4900132edt.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:12:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=vKzIZbnFKp1vRa+ElT0H/kedeGFA+7nn25bKXmXMbDA=;
        b=a3Pd1avBtUK9mN7vhmi3b3Nq7eNIJrKuHvk1hMOoPEzcgPfogjAd6xX8RlLc5o7IYb
         ty/sYFZ0i/QdRGCeyOONBOeFvoIVwqoFmyK95MQOTE1htzUo9eqjp9TbwwcS1A6vn8Eb
         ulmKh17ezOts6/olDCT8M+ae3EYql5ltoO2UGD9wVq1F4/TMDq5ItDAq7nyLHYDiTDSq
         RnOnaQN5/ABCr33Zr/oOO9PpvVHanp1uKsP31FtkwlVkKm5X6xU3XM0ZspU08jMBEaiK
         P14/vsaVvtaJJFh5EQdJIP3rsq/48eXtmWoqUuC57jA38X9oSAhZ/orHAQs35NqgNA8q
         sq1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXK4aj0E+easYgYgjQdW8l58HApAWT+zE1DY5kzrwwc4djbYie2
	DnvI1ySOv6l8Kpxwqpxa7v5QmYHNGxnlJ1Jzk2Gt1Alh8E2iCWnJnF7Mg6yKVZ6An8cfqLoIlHs
	RbgCpvJzVup6w1K1r157Q/z0aojBS0G5jHGbo938IR1kHmn749owJgct4Mu/Fglc07Q==
X-Received: by 2002:a17:906:76c8:: with SMTP id q8mr72092844ejn.229.1560413557587;
        Thu, 13 Jun 2019 01:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxrpklPNPIayTkIJgApFsNP6perMbMutXODX9eXrVPedYS+0CjPd3cwZji+D4on4Ml/XpO
X-Received: by 2002:a17:906:76c8:: with SMTP id q8mr72092797ejn.229.1560413556813;
        Thu, 13 Jun 2019 01:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560413556; cv=none;
        d=google.com; s=arc-20160816;
        b=nfkgSgKAUFNi6o2YwuHUZjaysqkc8qSBUatULrNgrwu3VA5FfD+e/P62N6TFtsh3PP
         yYn/30Y6iYcgVbiuJIF9NtwzuRQDC1Om1AjOFL3ldZ3ktJO7W8TUuJG80Y2t6Ym9Ilq7
         TKKSFiuwDBH7uD1+AwIDZUWIjuiJM141ipJWXKzynyBAgPUxHqh7hBrUZ1M67m3h+hDJ
         HBkemL5MbzK/ZiVKW8ljL454yRVvRR3OGfZYtPgi6ImEh6LiSGTHNYhDtsO6fpNVe1j9
         nOl+n3lU8Vyy6+AdBo0cl2lMemY2NWuusKOAEAZa9PUN79ef19DD6CjvQ7lfFevsJWZn
         LOUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=vKzIZbnFKp1vRa+ElT0H/kedeGFA+7nn25bKXmXMbDA=;
        b=0LdSlJpHLtmAqXIy9xUKNtofv5imgmDe7qPd2phlTTo2jF4SByL3UuDD08cTiCmwvX
         RGliiYxF+SrCCFAy+520oc0QHJWnPvpPK0Cht/MefwuGZOWMOLkPoSqXTOg5UF2OlP/5
         yoF81YYxInDXRq+Jqsj9eISQwHPISA8NY1GYXRWZZ0UCr8bJIfb+yMOpGcvbHlLW6fMX
         X9doUd+ojuKNokMCD+MXDaQ+P+uF8wFSIZWw/vo8rGmMKkuDdhiQze7X5xo4nw5GSrp4
         S7O9vpNY0lfpZ7pobUBEJRSsFh+hTQEWCYAMItC8so40ccqFg/8g6XT5ZsPlkzGIrDpR
         g3EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id m3si1474164ejb.288.2019.06.13.01.12.36
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 01:12:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 43A7C367;
	Thu, 13 Jun 2019 01:12:35 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.191])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id A42093F557;
	Thu, 13 Jun 2019 01:12:31 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Roman Gushchin <guro@fb.com>,
	Michal Hocko <mhocko@suse.com>,
	Roman Penyaev <rpenyaev@suse.de>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] mm/vmalloc: Check absolute error return from vmap_[p4d|pud|pmd|pte]_range()
Date: Thu, 13 Jun 2019 13:42:31 +0530
Message-Id: <1560413551-17460-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

vmap_pte_range() returns an -EBUSY when it encounters a non-empty PTE. But
currently vmap_pmd_range() unifies both -EBUSY and -ENOMEM return code as
-ENOMEM and send it up the call chain which is wrong. Interestingly enough
vmap_page_range_noflush() tests for the absolute error return value from
vmap_p4d_range() but it does not help because -EBUSY has been merged with
-ENOMEM. So all it can return is -ENOMEM. Fix this by testing for absolute
error return from vmap_pmd_range() all the way up to vmap_p4d_range().

Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Roman Penyaev <rpenyaev@suse.de>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 mm/vmalloc.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7350a124524b..6c7dd8df23c3 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -165,14 +165,16 @@ static int vmap_pmd_range(pud_t *pud, unsigned long addr,
 {
 	pmd_t *pmd;
 	unsigned long next;
+	int err = 0;
 
 	pmd = pmd_alloc(&init_mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
-			return -ENOMEM;
+		err = vmap_pte_range(pmd, addr, next, prot, pages, nr);
+		if (err)
+			return err;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
@@ -182,14 +184,16 @@ static int vmap_pud_range(p4d_t *p4d, unsigned long addr,
 {
 	pud_t *pud;
 	unsigned long next;
+	int err = 0;
 
 	pud = pud_alloc(&init_mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
-			return -ENOMEM;
+		err = vmap_pmd_range(pud, addr, next, prot, pages, nr);
+		if (err)
+			return err;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
@@ -199,14 +203,16 @@ static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
 {
 	p4d_t *p4d;
 	unsigned long next;
+	int err = 0;
 
 	p4d = p4d_alloc(&init_mm, pgd, addr);
 	if (!p4d)
 		return -ENOMEM;
 	do {
 		next = p4d_addr_end(addr, end);
-		if (vmap_pud_range(p4d, addr, next, prot, pages, nr))
-			return -ENOMEM;
+		err = vmap_pud_range(p4d, addr, next, prot, pages, nr);
+		if (err)
+			return err;
 	} while (p4d++, addr = next, addr != end);
 	return 0;
 }
-- 
2.20.1

