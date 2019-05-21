Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1910BC18E7C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBEF8217F9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 20:53:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBEF8217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15F256B0007; Tue, 21 May 2019 16:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04F066B000D; Tue, 21 May 2019 16:53:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB7106B0003; Tue, 21 May 2019 16:53:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D64F6B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 16:53:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y1so12133122plr.13
        for <linux-mm@kvack.org>; Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qq5XpzPoyzrxc7VeunrLCYkiPjJ8tOqQGgXIagmQiCM=;
        b=MobiiCZGFAvLN16xlOFJsSG4kqAxXfK0VGm5R11fEV7YXVYUl7R7nfyTT+rV6Nbn13
         BnW3VdfjsKONFJe9mQ0FzGtMtRr4/t1hHKvjT9Zljszjw5/eC8uCcurcJiIc9HChthE0
         IF36s+4aQLynWG78x4MtrFc8DdHFzjSOJi7Hrm/FaQuuBUh7zCRT2LqgOWzJ8ElBa168
         cpxijHQVKkpolicrDkNVbgwpmIiEssTAyNe/mF6EX91GrWFK1zg8Fo3ix0rrMV2iJOsl
         9AOf45jhgPhUj6mudMv000u+75LYe9k+2QN4DPnLZhGdB7sx0vFarZaE9xeyWs1UCACc
         eUGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXGk0a5HfcoC/HTT7y8jSC0HRDKVisQhWFZaBt2pBD3ZUzpyjdt
	TXPzBRAhrvkEaee6iwR2gJPjz36CZXeVTS9RFKiUG04bS19FyAmChzSdBwNTZgMGOJKLImPMuuz
	jhkpJ1RRB3g4LuIjeeca80aD8TxAwbuPMfkpRKRBB54OioisjcF+91SUVC7PsuIf1CA==
X-Received: by 2002:a65:628d:: with SMTP id f13mr33306166pgv.177.1558471998200;
        Tue, 21 May 2019 13:53:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIpJ7DKuVnnyOkaMDYu+Ux9lXl7Q1pEd79jJ6fKexvS2Z+d9Q1AhHW2qwqQPF8MCSd+VEO
X-Received: by 2002:a65:628d:: with SMTP id f13mr33306104pgv.177.1558471997405;
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558471997; cv=none;
        d=google.com; s=arc-20160816;
        b=ECUJOaFtVNniDy0MD7N3r+fsZhwstG2b+Y82Qjpu1l+5GrHMRrpPUwRad7YDUIyHQ4
         7qnB8SiapxAzpZtR2oZkXlC4MjLvyGhBqHHljrDcxZzsPeh/QnpgBr+qDOmHlhwtxEn0
         gmO22hZcdVBMavm6NA+mK7m7mAy9KnXFzWKo9y/H7lAJ55QE3a8AqOQ4HSgZ07kRXvj4
         V8/5qbAkkWk8/Y1hYnim9jV/RBaa54Cc1tnoQrlc4q6rnre04FWHmuNC9UjYZL3hXwui
         81g8mPHpeEL9n8zD2JP9/FeeAwaaAISLsMW/UpFhAX33DnRC7/rDMuy9HExQBJQY2y3B
         447A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=qq5XpzPoyzrxc7VeunrLCYkiPjJ8tOqQGgXIagmQiCM=;
        b=PpFqN58F5jGW4qI6/JBXlU9dXjtBkr1FXzuF5S2WhWyHPPS+YcVqW7Ww9mxcoiNrq2
         MVxzIfNw6thg7AMDQgmAZwqRDudZSm4YhuDZsZouRLnowC9zLPOTbNv+sr2r96adc2O6
         g+pKPI6q9bZP1vQPMO9I1q2TZXnbSjzg50vJ66tXOAHb4FtPg6ZZyug9bFvUwaSr8RVe
         wgrip+MKYb0Sn8/CpkJ89DvnEozwtKuReFYGUgX045rLJrN2+jfQIz61c2FxiNhNt2eg
         VNqcFQPgevFqTyUdsLg/rFDBc4j8IhAN3uQkqM8DkvjoakNhr2kIalJVFCit+hoA2cC7
         pBQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 7si24611937pll.99.2019.05.21.13.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 13:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 13:53:16 -0700
X-ExtLoop1: 1
Received: from rpedgeco-mobl.amr.corp.intel.com (HELO localhost.intel.com) ([10.254.91.116])
  by orsmga001.jf.intel.com with ESMTP; 21 May 2019 13:53:16 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: linux-kernel@vger.kernel.org,
	peterz@infradead.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	luto@kernel.org
Cc: dave.hansen@intel.com,
	namit@vmware.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Meelis Roos <mroos@linux.ee>,
	"David S. Miller" <davem@davemloft.net>,
	Borislav Petkov <bp@alien8.de>,
	Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v4 1/2] vmalloc: Fix calculation of direct map addr range
Date: Tue, 21 May 2019 13:51:36 -0700
Message-Id: <20190521205137.22029-2-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
References: <20190521205137.22029-1-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The calculation of the direct map address range to flush was wrong.
This could cause problems on x86 if a RO direct map alias ever got loaded
into the TLB. This shouldn't normally happen, but it could cause the
permissions to remain RO on the direct map alias, and then the page
would return from the page allocator to some other component as RO and
cause a crash.

So fix fix the address range calculation so the flush will include the
direct map range.

Fixes: 868b104d7379 ("mm/vmalloc: Add flag for freeing of special permsissions")
Cc: Meelis Roos <mroos@linux.ee>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 mm/vmalloc.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index c42872ed82ac..836888ae01f6 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2159,9 +2159,10 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
 	 * the vm_unmap_aliases() flush includes the direct map.
 	 */
 	for (i = 0; i < area->nr_pages; i++) {
-		if (page_address(area->pages[i])) {
+		addr = (unsigned long)page_address(area->pages[i]);
+		if (addr) {
 			start = min(addr, start);
-			end = max(addr, end);
+			end = max(addr + PAGE_SIZE, end);
 		}
 	}
 
-- 
2.20.1

