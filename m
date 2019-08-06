Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D47C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B69C20651
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:11:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B69C20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F36366B0005; Tue,  6 Aug 2019 04:11:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE6266B0008; Tue,  6 Aug 2019 04:11:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE5B6B000A; Tue,  6 Aug 2019 04:11:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5BC56B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:11:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id w5so54462231pgs.5
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:11:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=tKyFaqoYLiLE8zFE9yQm610ngJHuDZlGyPi6JHiIzME=;
        b=QUdu46Yv8Hq3LBSIOHxBh6Y5GJWx78NioAc16oIR4xscBtwu/EcP/YOlI/cEXQlRrf
         VrKoYm9xma73w9cBLyXsqCXIbHz/bSTZAZsIEvOVxHfnWc2Ss3plW4WzczIeHioUSZv0
         S3dgT6i9nfHRW5NKkqZ3qY8Y+eyCiiXpftj/dtpMqXhYzC5PdtcxeoAWVEWiDIEFvuIT
         3GnIRVn1yrwHhBgPqTzwiKB5hsxkzgNDbux08IPs4s6QVoF93qeRaiFdDg0XexFLCY3Z
         ruf0zww9EJs+Vski2o8//VbuNr2pXho6IXhb0wGOApHtrkjAkz0LdtqPZWvJchF0u0X4
         QURg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXf17aPQEQ1rYiYz1QGHaVQbC+LYHcTkfiXH4fisnp0OjbK5wQ7
	39lNIaf+VCEfhQrRrem4oZaW0L6ZmA9JeKohkUsi18ECBZL1BeriEnwP5UC/LejdQt31XcXBOtA
	ERDsqNjbJKbE5KdYDrZBlwTLsTXWXavQF4ZX3TIc4wjntefk113mesx7bNm+z36op9Q==
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr1885068pjn.133.1565079112371;
        Tue, 06 Aug 2019 01:11:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPGxt7H27/vQ7sQkraYAUGOe9GwV6a6m2QvNEACyz7CaJLJb4GGMbSVzX2ZmVAzb2CsF+k
X-Received: by 2002:a17:90a:8984:: with SMTP id v4mr1885032pjn.133.1565079111690;
        Tue, 06 Aug 2019 01:11:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565079111; cv=none;
        d=google.com; s=arc-20160816;
        b=BgnBR1u6Zz/Y5f8I6nfkBVaXfsSq4uA3f2eM19UEc6Zb5r1GN8viKHuAOaOXwa2J2V
         ClmUUtCJnRfwR0BiNH1RDZcnQBNbetxl9SNCTXjA7dzG03HKIJ8FWIapMMFtyxYm2uL6
         JvF4lfduVUR46dGGLaEtqiZuXIIeEKFp+CVs1kmrk+CDK9orABDpq5zmBxCB4MSe4bzC
         SJopkNYt79EkHigAe2NHjjkFBkjYVhYp0CL7u9gqfj4B5cMTvBZR4yjI/GmYDM0xCHmL
         E3hHkhjKMmArN1XtRSotKCxHeDTDb0zdqaLFT300AWnPDo5gtKb50JBotCUGwk9odJf4
         2KXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=tKyFaqoYLiLE8zFE9yQm610ngJHuDZlGyPi6JHiIzME=;
        b=0fUswuL3tszpSzaDmjIG5cVTch/IrqmVYZRDjpECtcbUT5fIcuM+rddEj9VYBfUUp+
         WncsSvrctyKNko0y1kcXtEeF88a3RFowlDktzM57wHKjMKw+1FZ0wWGO4ujVyp+TvxPE
         t3wOFKekaNXBZnC1SVVEI1Kjm/NOFcYmMO/Iud/c0Z5lGUZUeSXzUZBza1hua86+r5o0
         eLNsjcLIojbwoNsr/6AgZBv6jzI+9bAY2AMVndCnBNfuI2jchPt8QdpIUubHL2kEpPc2
         UMGvnzq4UvGrc5rb49K7W/0V2068U0TdCyJ9WGrCLae+jcHGEn05g0nH61dFOCx5FxU5
         UtOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 24si43691938pfp.107.2019.08.06.01.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:11:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 01:11:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,352,1559545200"; 
   d="scan'208";a="176561599"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga003.jf.intel.com with ESMTP; 06 Aug 2019 01:11:48 -0700
From: Wei Yang <richardw.yang@linux.intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	vbabka@suse.cz,
	kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Wei Yang <richardw.yang@linux.intel.com>
Subject: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Date: Tue,  6 Aug 2019 16:11:23 +0800
Message-Id: <20190806081123.22334-1-richardw.yang@linux.intel.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When addr is out of the range of the whole rb_tree, pprev will points to
the biggest node. find_vma_prev gets is by going through the right most
node of the tree.

Since only the last node is the one it is looking for, it is not
necessary to assign pprev to those middle stage nodes. By assigning
pprev to the last node directly, it tries to improve the function
locality a little.

Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
---
 mm/mmap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 7e8c3e8ae75f..284bc7e51f9c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2271,11 +2271,10 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
 		*pprev = vma->vm_prev;
 	} else {
 		struct rb_node *rb_node = mm->mm_rb.rb_node;
-		*pprev = NULL;
-		while (rb_node) {
-			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+		while (rb_node && rb_node->rb_right)
 			rb_node = rb_node->rb_right;
-		}
+		*pprev = rb_node ? NULL
+			 : rb_entry(rb_node, struct vm_area_struct, vm_rb);
 	}
 	return vma;
 }
-- 
2.17.1

