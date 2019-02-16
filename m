Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B113C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 17:19:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDDFE222D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 17:19:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDDFE222D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66FFE8E0002; Sat, 16 Feb 2019 12:19:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61EA38E0001; Sat, 16 Feb 2019 12:19:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 533738E0002; Sat, 16 Feb 2019 12:19:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12FFD8E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 12:19:42 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f5so9066344pgh.14
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 09:19:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=RI6FofuL33Yj7WLN3PhAI5fLbrjHkKVIbAD3zJkG8Hg=;
        b=fz+pOxczwtAJkrC5CmYm2j3YuiNnQG0zyZg6LV5GAgeMGYZDWuT3+1ZlBL3klnrH4J
         HjmmkELF46VC+BJ9O3aYwpqAq5HDIa+jxr/Z4UkZDMdW0iujyOrw3L0caxmdgpgsPNYg
         B1NCMjv2YTa6IcDm8PN07/wztSYOKYo5Brp2Wt7gJkovHn2G9cikM2YfIcVPiXkfbSKf
         EmagNHNi+1tv51T2xwvev9XWjTPvJJyBM7etQCC1J/U7Og16oKmTRgUxnrjzsNObQZZu
         RFrwso+OsQd1ZqW2fbTLzSva5CgwJpvTYWCw1WM0Esqa73QwkceVYwhTyig2E28q/xS9
         WtGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZb0BE2Kp8BBxnZHvLrZ8fbo0xqn395LG7+9XxvvhRtC6BrzcsO
	2Ee/+qmi+HhgoOB++PHzFzUzd1JUEtAmAOv6y0OnqGYhwWKEsSkmBIi7OapWFBhe1GzFUBI+jSY
	FPqKASzQ+FWdnaCt8uYBD4ukN6TbNtPAX5O46NpoUj/C82EjzYvOArL+v3fAsILHLLA==
X-Received: by 2002:aa7:92da:: with SMTP id k26mr690915pfa.216.1550337581678;
        Sat, 16 Feb 2019 09:19:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYI3X9bFZ8//oBm1vCT6cL0OCzt6sj57+ZbB+D8jmccZe6eD/UC2yjvCQxa+YDm+o7eP8FB
X-Received: by 2002:aa7:92da:: with SMTP id k26mr690840pfa.216.1550337580664;
        Sat, 16 Feb 2019 09:19:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550337580; cv=none;
        d=google.com; s=arc-20160816;
        b=ru5O0FXEGhtRYndZk+QtOv8yMDLRmj4MlTkmhiVMWcR5NaVSDqlv/5E9ytss+v36jq
         oSJNDqaoPpVWhIlwS+CIuNAznEbtOdDhiYtucoBSj523oUVDJPhoRfmMSxqNMEZVNurF
         dukagNyydPKhEtIUWBlwyKpUGWutW+Tc2D4au+DSWU+Xfg2X2s9jMgQyBSl8+wPcak0O
         es9nWaSd5Z+zUXta1VluOL9zuZRi/KKMQEFhmfPKrC6m9Q31MnFxikvGeklAHMevFiub
         +s8hwVwDZ1MtChYOaJkgPk4imhcyI723I6sMv3xMjdA8PFmRjW1afnnYG4FdPi5nXXCa
         u+TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=RI6FofuL33Yj7WLN3PhAI5fLbrjHkKVIbAD3zJkG8Hg=;
        b=Dg+L9USvoNdqJOUSETIuSMHIC8almJ1XIsYvBktISiiXqVJ4mNBA9CPu9NlHEZoIfq
         gsaPrDqgoSKT6j1q+n9zLPa4LWfWjDLs2JG1kZYdyRxA6tI43lpnPK8hihKC98v4lyRJ
         i/dpazEUDwGUKbZt8zvP+bcT1UPPZNaXOTOeE+VKTp7960XWYAFscIgmGY4yBzep9SoA
         mmJODnUgyXwrPKC5lKX2pS1eG3sXAPzrJkwTdktWvCXNMWDMfbZmZytUyLbmgoQFwV5V
         lDZTIRbmtSNd5AjZJS7fz1gUAJ7nTEPTs/cVmQhHk0nuA42DqHm+/6vVGg12A5UKZwR+
         NQJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 187si8312181pgj.348.2019.02.16.09.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Feb 2019 09:19:40 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Feb 2019 09:19:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,377,1544515200"; 
   d="scan'208";a="320958358"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005.fm.intel.com with ESMTP; 16 Feb 2019 09:19:39 -0800
Subject: [PATCH] mm: Fix buddy list helpers
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Sat, 16 Feb 2019 09:07:02 -0800
Message-ID: <155033679702.1773410.13041474192173212653.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tetsuo reports that free page statistics are not reporting correctly,
and Vlastimil noticed that "mm: Move buddy list manipulations into
helpers" botched one of its conversions of add_to_free_area(). Fix the
double-increment of ->nr_free.

Reported-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Reported-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>
Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Hi Andrew,

Please fold this into
mm-move-buddy-list-manipulations-into-helpers.patch.

 mm/page_alloc.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2a0969e3b0eb..da537fc39c54 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1851,7 +1851,6 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 
 		add_to_free_area(&page[size], area, migratetype);
-		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
 }

