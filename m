Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12973C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDC28214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC28214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B33E6B000C; Sun, 17 Mar 2019 22:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A3786B0266; Sun, 17 Mar 2019 22:36:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0BB46B000C; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67CBA6B0266
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 73so17080598pga.18
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=PCRFsPB7z4+vh85z0kFbXk2AvU4psX7iRsA0G8aRedr2aUFBGERaB0ZPzl0dkRFk7y
         i3YjLpd0bDx6+Mfqtxsyppiy6k9qMUHG7ftMNiVAu4VsZmgLCuhd2D5kRe2UNwPEUpVA
         +djZHzh4UzQOGztkPe9NV8fcujlQr6tHvfNc6jTXn1tlZ7z2mJshXLFE1ZzlZdUOAjqK
         jW3sWwN8VO7eRxTut8LMRAhxGlXcrMqXSHf333XUDFSq+UMwKMpG+o71o0jQMIlS4+vM
         /dUfHA1rnC+7kORHkL6/FR9RE2DddWp56tZ5OOuhRw6J4kc1GeSMtJraJKsRmxFv0qZo
         OTUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW+vli90CDd698jgkDIZzMa8XJSo5RGJFv0NKM1eRVTrWGDjEaV
	dVTMMlsfLafm/bdeNcHzRxAas5/CYyxEv8p3ftGhP6WOjg/ET5RKsAARfP5UrxwNB1PGYsaq0sr
	v5af7gzybBPMUReIsGMraBMM4JnYZKzpDXa8XbP1RZtJQW6qu4QKe2oPJuIe/+n5AqA==
X-Received: by 2002:a63:1f61:: with SMTP id q33mr2131351pgm.325.1552876567093;
        Sun, 17 Mar 2019 19:36:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxudIwXzghdab5aeee0ESffb3P0i9bEXQ7EuXDiVYpYA9kY6lS8f2DKmGdxSXbOfI1l5fDI
X-Received: by 2002:a63:1f61:: with SMTP id q33mr2131292pgm.325.1552876566164;
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876566; cv=none;
        d=google.com; s=arc-20160816;
        b=kCBx3J95Tw/64DqNB5+cOIi02J+ojh04lDZRxxzLGclZNZABR1i3EqfsFWhgQS+OYE
         RdzLP0HjFAik+Bb4smV6ABLmNjYTm+/ut12imhv+FWZweCq1hLi9591NK2Qo9P3V0qCb
         nt5iClGjjmk3sdQv0et9kmEJU6s8Ak24KFz+eJsOo1gfoQxVQi3TPGdPEysHHeIYKuIb
         qiY6VRmNYWaKngXgA37fzBGhai00GgApmGs4AaKq3GU08bpR42CvqfBKbLiTL+dfr4Fy
         x+IikncUH9ls+fRpNFMkO6VhquiLxbwYf1YHeLQb1nk2zaQ8zeQwBoVHVUWhuVJBLF3i
         LUYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=ScxfUVPfnTxjIpR+gcRynQpbbJLz61xWo4e6H08UpmKyHDBjk5yrUCNRkO9xrW9S7G
         wCct8nAFuVqDDs9KInSund4Z4QwTjPavf51LQRJkWpMeDZAWmPmRV6sGGE0D+/IwfEO6
         w5oFurqOIhickIdHM86t6PDjafydc7qjSqryWdJQA4tKn3EfC770Qitv2Rmj9AwGeaUc
         uDNU3gLfvEmMfB6YR98vw9et4rBH31+m8+DbBSK1ruZn7YlvoWCwoKlWczWo0Oa06YBN
         fVfjzLcancYbroB4AnLLO/kB4EZpLICZyvchPlt/kdWNrtML37kXXXirVcjMY13TrEgA
         IkOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b2si2253465pgw.161.2019.03.17.19.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877430"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:05 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [RESEND 7/7] IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Sun, 17 Mar 2019 11:34:38 -0700
Message-Id: <20190317183438.2057-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317183438.2057-1-ira.weiny@intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
FS DAX pages being mapped.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 drivers/infiniband/hw/mthca/mthca_memfree.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 112d2f38e0de..8ff0e90d7564 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,8 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
+	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1,
+				  FOLL_WRITE | FOLL_LONGTERM, pages);
 	if (ret < 0)
 		goto out;
 
-- 
2.20.1

