Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DC32C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:24:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59B8720896
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:24:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59B8720896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E13B66B0005; Fri, 10 May 2019 12:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9CF46B0006; Fri, 10 May 2019 12:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F096B0007; Fri, 10 May 2019 12:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8838B6B0005
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:24:04 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j1so4487122pff.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=DWP3CuFvwLywBdvqvxPMztsApfsmH+MmhD4ndRJ3k4g=;
        b=cYuGC+I+YZCHC8rxM85thUloaOEPqf6kD5HlQshZpTKUZ0BFKXBNkzTm2eEPO1Ch/w
         jNIM8h1gmRJ0Dun1hmUmQmfdibQavGzL/gDqF3Uh/Lg7Z50EtkpHySlcHrcbUnaVGWFM
         Af0MypKqXVNwFVB2fhC3wxr2HYIBSP3n0YgGCyUb7NiRmplTBYj4g7aB81DEJl2vBNkA
         8eV7qaFD8xPq1ww+NSKq9O3cSOY59O8rxYRvtv6fCFtkmoAjQqD6UsJ3WkjB2d5GHNrh
         h0SHornp9h2YuGuspFM8SlGZfXsAAhkZRaOKaE5e3DscJOYh/HE1yfkS6RtGOFvNiQyU
         LpXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXMMrAg7vYKx2Ce8QSkjn5eWiPgJ43gqdgIzaBTsIZJ7y5N77fP
	OIR6FISbsq9KsPlhHt1S6yavAwf4wc80cwSyuJ0z+zicT8aDUtN3IroYO4w6CkgNSZKWZRwKE+u
	5BwdKSJ+0Q5wUGbloAK3DLjfKMwtIXEXUtTHNMws4GErCcTVOywQYYb4A/XxirW4W/g==
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr13956983plt.59.1557505444212;
        Fri, 10 May 2019 09:24:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzr0c5WJV92LDn1wf+uIrAUXWz+eWHNij2V1yfXyvtEAJO75bSLTngmFh+WAIOESvbBSJkt
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr13956850plt.59.1557505442897;
        Fri, 10 May 2019 09:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557505442; cv=none;
        d=google.com; s=arc-20160816;
        b=KtPDRB6IfJmiOFIvH1cA5tOdDWdPgoC4cYiYdcTGk0zcr6xn83LigQtTkJci0UB7kX
         E1G91agjoldIlNSX1X9QS5BYSFv+ZcGS8YEI53Q3/Mmsvs3uDeM2y3EldGhNUZccpRyY
         T/5UPDneFmtvn739QzvAfZ5MkvsIs/RXjBEFen929tgZTGt6M22h/lpRuEysMN5fWe4P
         BP8YCxMQygv1l9mywMS2A4Zf9MMm9F2+BgEtgLzAJPlQYAwJFVLEFd2oN8Rvh41hyZEe
         iuh2fcL7sHkuffE4rTfHGUrFbQy1OpHHje4tsI9YANWp7gzRLK7dc7VJXJbIYEdt/2kM
         ziGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=DWP3CuFvwLywBdvqvxPMztsApfsmH+MmhD4ndRJ3k4g=;
        b=im4cj423bS345zO136oaCziWZZsjQqoS2TUoHjBGVwlZulLGINI3p50IBR2O5p/iNA
         t454krL1WVf6vsXUesDvEi2ntdF7r665w2Q0cDYA3bDuzjsiH0EaLMv+knIyu3fiAcXu
         Ha7H7eMukg3p+87Jt+suY7JZRtqIN4apURvheFovcM6mN+eV78oAUXA2fEZdIMa16ggZ
         Z1fQydsiqUqxxnT52wjEDEyCDuM2BKwQItP46FpghdKBeqOis/UVy18aELb27lQqr5Nu
         KqvuggPt+XhU1ix0nq0+k1vwhUTug25inC/0IPBcEsElDF6aH9zQkrlBtoK6eWY2qDd3
         lmMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 64si8231260ple.157.2019.05.10.09.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 09:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R621e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0TRMJ8gS_1557505420;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRMJ8gS_1557505420)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 11 May 2019 00:23:47 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: ying.huang@intel.com,
	hannes@cmpxchg.org,
	mhocko@suse.com,
	mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com,
	hughd@google.com,
	shakeelb@google.com,
	william.kucharski@oracle.com,
	akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
Date: Sat, 11 May 2019 00:23:40 +0800
Message-Id: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
still gets inc'ed by one even though a whole THP (512 pages) gets
swapped out.

This doesn't make too much sense to memory reclaim.  For example, direct
reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
could fulfill it.  But, if nr_reclaimed is not increased correctly,
direct reclaim may just waste time to reclaim more pages,
SWAP_CLUSTER_MAX * 512 pages in worst case.

This change may result in more reclaimed pages than scanned pages showed
by /proc/vmstat since scanning one head page would reclaim 512 base pages.

Cc: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Hugh Dickins <hughd@google.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
v2: Added Shakeel's Reviewed-by
    Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski

 mm/vmscan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fd9de50..4226d6b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		unlock_page(page);
 free_it:
-		nr_reclaimed++;
+		/* 
+		 * THP may get swapped out in a whole, need account
+		 * all base pages.
+		 */
+		nr_reclaimed += hpage_nr_pages(page);
 
 		/*
 		 * Is there need to periodically free_page_list? It would
-- 
1.8.3.1

