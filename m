Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD7BEC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 19:33:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EB1E217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 19:33:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EB1E217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B22A6B0003; Fri, 24 May 2019 15:33:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03C9A6B000A; Fri, 24 May 2019 15:33:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1E7F6B000C; Fri, 24 May 2019 15:33:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFCD16B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 15:33:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6so6946509pgl.1
        for <linux-mm@kvack.org>; Fri, 24 May 2019 12:33:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=rr9eyG9c3UkghPPisctB+sekmhxXHST/VsHjCEXm0H4=;
        b=IzhzR7zHIqbSHQxE1Cr9sIKrW1YE5K/X6lKIK0DELunptpPy34PAWBPHd+dEMGUlTb
         kh9JybDoejStZb/C4yJ/WRfcN5972E1PZEfORm54K3kd5R0RmC84TIBSKAmWxvw1ldgT
         L/19PGR30M48SvzazQDFuIQsctD09mF/4kIdUmgcU45Egnj+bSG89T//fgB6nXoyNj5n
         kNcKOHpzYJ/OGASL0SigV3/hA7y1iY2mzjl7Hfn2XcXP9t/TlpBZMYL29RAlwglJi1Kf
         EU5yDl2+JAXtKebYynI2Vg8lKrNub/Ogktk1P8K0mcJQZ09/sYZNI6Hl/3y0eJacth/z
         wqYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU1IZOuNlVQQNaZxxNKXyWPJx06j6wcFB1b61givxll8IZkir6t
	UG1U5P1OmiRYT6oX6O1AaJmeyJ7LXDE3mzjtE/fOULBPJDao7fmCDLM6eifVwF5BcQOJNwNJF0B
	Oxhcwsc2i0EgN5zW+x5H1CAMVCCyncpMgsY9zgX7/UIjPtYlLGzjVrBNJYmOQdthn4A==
X-Received: by 2002:a63:c750:: with SMTP id v16mr106582292pgg.409.1558726410232;
        Fri, 24 May 2019 12:33:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEHt21QdFFn9GvFpuY5dfZah285tFGFGnjQ1meAGvtAZfZeC7ilP+vvbUYH07j9S7Dbbn5
X-Received: by 2002:a63:c750:: with SMTP id v16mr106582180pgg.409.1558726409194;
        Fri, 24 May 2019 12:33:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558726409; cv=none;
        d=google.com; s=arc-20160816;
        b=CnOqi7wfTCr9N7rEQXZIhvHsW0ROKb9kpC/Ko4hgIdjwVOA8Wa0R+wDAfOfqeQEEMp
         NlU5SnN5hHupPDbLhoM1CyNMpVUreP7o1AkX4jYKyww6z9QLETAb0wWdMvvm23l/9/JT
         j1MAirUvRI1xW/TJzzL+tWvTI9Src7CF4OyTEnoBvKE0RowKAPZnTor828gleSsWZOzb
         BsYAjZvkpoBbeH+ZBPV8FpBTViIHRkRVLrSZBhfVzGuoZrSwgo5UarFk5DUXGBC7eqgm
         OKseH5DG+B2TEeFmCC7pfo8BHFftLAgqgTFjGF9IVfmJ+eARQzl5xss7P5LypH219Lcr
         b6+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=rr9eyG9c3UkghPPisctB+sekmhxXHST/VsHjCEXm0H4=;
        b=wMFEKn9hX6wix1RlV+wMtVphVRq9eT5t1L6mBFLRfT4tGF7+Zw0mL7G3RnBl0kbcfx
         hut3qUTp3/SrIP9UaMivU+VK61/9ek+Uh2MuQUJEpZwCPxBID6SIxaAWqC5Iqy79fZdA
         5wX+AltNiPxKzmvr7Nmd5dnhzLWisg7yRUmPONDxBuW8m1hJ7BO3BaU4AnZqdeVR8y9c
         SdvVPK2ZNW/sQ1ufrTHUUObTF0DWYI1UssqhF93Z2bUZgx5Qv/vM+Hrl7IkHNyjJ1fqf
         e8AOjoFYiOCvGPdCqN1ZQaD0Mifw+OX3+7gJAVekQi814ix7DZ+4V+Ie1fAoNwMKP7aN
         f87g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t8si5668060pgh.235.2019.05.24.12.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 12:33:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 May 2019 12:33:28 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 24 May 2019 12:33:28 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [PATCH RFC] mm/swap: make release_pages() and put_pages() match
Date: Fri, 24 May 2019 12:34:15 -0700
Message-Id: <20190524193415.9733-1-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

RFC I have no idea if this is correct or not.  But looking at
release_pages() I see a call to both __ClearPageActive() and
__ClearPageWaiters() while in __page_cache_release() I do not.

Is this a bug which needs to be fixed?  Did I miss clearing active
somewhere else in the call chain of put_page?

This was found via code inspection while determining if release_pages()
and the new put_user_pages() could be interchangeable.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 mm/swap.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/swap.c b/mm/swap.c
index 3a75722e68a9..9d0432baddb0 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -69,6 +69,7 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru_list(page, lruvec, page_off_lru(page));
 		spin_unlock_irqrestore(&pgdat->lru_lock, flags);
 	}
+	__ClearPageActive(page);
 	__ClearPageWaiters(page);
 	mem_cgroup_uncharge(page);
 }
-- 
2.20.1

