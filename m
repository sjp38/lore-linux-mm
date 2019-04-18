Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 703F7C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BA9220869
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:17:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BA9220869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEA366B0266; Thu, 18 Apr 2019 16:17:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9A436B0269; Thu, 18 Apr 2019 16:17:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB1026B026A; Thu, 18 Apr 2019 16:17:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72EC46B0266
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:17:16 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f7so2047469pfd.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:17:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=4jPhGwjHunFWeSDK39fXDa38YqpMigqthqO4oi8UR94=;
        b=c2cuJzfAfnJqlfXvcLBfNBrhr06bW8WOvWp0q4KxJ/MexOLKYlw0rAuhAGQMhqy4Fd
         5Nx9wFmukdsJoCyrKm9CwOHsNkVb088ob5iUMVAwIhTbl2Lv2FLvHHz2kJcO7h7OpoY9
         z4PI8mJeCPRYQFGj2aUD/1H/oSENadVuzW/koaBRAnDDSO4iLWnzcTgsbrR6qj6CLVtE
         McjhAtuJFgspz+9wKtpsp5vFOvQgQcsFfDmjRG+RRtX2PFofLdeJ55pOk8Cea04f/8iL
         YcXFQjSNtwbGQY1R7EdJFHhuq3QIrfHaIfgX8exouRsvuFCpt9HdG0QEPYWlVGdU124m
         Pokg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVHseUkzU8NemTNBflGnqEG6r6BU0B+pUQbFvkfl2BmVH+vZrEm
	rSTwHkROAGqHYShB3uaH1/3yalzpJ7M6F42RY1cmPIjU+bkah45xSl5JSET6AevpqKuFUrAE0li
	+bvzhROPvM2/jNNlNwHBimHeR/lbhrYXPU7NYc0O6u/N6bAhJKtAYuaC2ei1/D7UkwQ==
X-Received: by 2002:a17:902:2b89:: with SMTP id l9mr7813548plb.329.1555618636116;
        Thu, 18 Apr 2019 13:17:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFhlp1tP1B9MxcMD00RsR3cDaxwStNT4Gxry+eI3PPUsg3taIUn+lv2zzduXHAB117nLZI
X-Received: by 2002:a17:902:2b89:: with SMTP id l9mr7813477plb.329.1555618635080;
        Thu, 18 Apr 2019 13:17:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555618635; cv=none;
        d=google.com; s=arc-20160816;
        b=YO/njEc6s2uCm79CbN9e5jrvkMkjDWOfCxEoAriuJAcVa+Kl6TBRIpcM2zjbSGHgbo
         B0/Mpwi4QPqrLzSVwCCMrEd9aW/jQeWzz6QhjJg6j1iGyQGgpdLD5UF9N8Hv0P4BSast
         7DQ2EwDcW5aCFiuYto11z8F2EzfxcPx1nnTXwHSCC9phBkz9WzFcaljbsdpT3OBz5D7G
         uStETehP6wFLMMICwOO9MdZVgN/OYoysZj+5E4wMzI/MFwHRMXmkP6BNZyjKErrqIk9Y
         wh6Tyv4Yx36TQGnA0x6yRE/+Vk/7tiU99bvBi4J3r1istWDXN2fS15x2H5H22fZq30Uz
         JsdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=4jPhGwjHunFWeSDK39fXDa38YqpMigqthqO4oi8UR94=;
        b=e4+jUlHK/VXIlpjM2gbrCPMCp/QvhBGXk3i7W2q+wMcAGF/0Gz0Z4uF29sYVRkgVLM
         RxeFS7jim6GXjfBA+4jbcKh9zFW7lRN2306KUONHqX1VRVWdYOSrB4TWTfkiRTvASqB6
         rhxbGbku2kkvddMMR5w84h1B1DWcQxgxJPxxsHo2DONd9EdaMPWW3ZnT97X56fn4S4MR
         m0ZbNufZFJ6EFoa5KDl2ACqGh1II+Xcz44v8kHAct/156/D9UA/LpS4onfSym9n5FONA
         WMR+zNu9OSP68aBzeODYSloM5Gmqwh/Iq5atBrNp4vhTx9K4q8oMnQKoOhNCxbcEl4TE
         EQ/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id s2si3065435plr.110.2019.04.18.13.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:17:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TPfSgC1_1555618625;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPfSgC1_1555618625)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 04:17:13 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	ziy@nvidia.com,
	rppt@linux.vnet.ibm.com,
	corbet@lwn.net,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] doc: mm: migration doesn't use FOLL_SPLIT anymore
Date: Fri, 19 Apr 2019 04:17:04 +0800
Message-Id: <1555618624-23957-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When demonstrating FOLL_SPLIT in transhuge document, migration is used
as an example.  But, since commit 94723aafb9e7 ("mm: unclutter THP
migration"), the way of THP migration is totally changed.  FOLL_SPLIT is
not used by migration anymore due to the change.

Remove the obsolete example to avoid confusion.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Zi Yan <ziy@nvidia.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/vm/transhuge.rst | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
index a8cf680..8df3806 100644
--- a/Documentation/vm/transhuge.rst
+++ b/Documentation/vm/transhuge.rst
@@ -55,13 +55,7 @@ prevent page from being split by anyone.
 In case you can't handle compound pages if they're returned by
 follow_page, the FOLL_SPLIT bit can be specified as parameter to
 follow_page, so that it will split the hugepages before returning
-them. Migration for example passes FOLL_SPLIT as parameter to
-follow_page because it's not hugepage aware and in fact it can't work
-at all on hugetlbfs (but it instead works fine on transparent
-hugepages thanks to FOLL_SPLIT). migration simply can't deal with
-hugepages being returned (as it's not only checking the pfn of the
-page and pinning it during the copy but it pretends to migrate the
-memory in regular page sizes and with regular pte/pmd mappings).
+them.
 
 Graceful fallback
 =================
-- 
1.8.3.1

