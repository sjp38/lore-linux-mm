Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91F64C28CBF
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E73C206C1
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 08:27:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E73C206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C925D6B026D; Mon, 27 May 2019 04:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C43956B026E; Mon, 27 May 2019 04:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B32F56B026F; Mon, 27 May 2019 04:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8021B6B026D
	for <linux-mm@kvack.org>; Mon, 27 May 2019 04:27:23 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m12so10800268pls.10
        for <linux-mm@kvack.org>; Mon, 27 May 2019 01:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=s658wFeksNRFSKjgZoYcRljTvH0m7MCJR8yA+py9GLU=;
        b=ZWKLGxd4cOJLh91/fvGvoQG6MSDXE8vkw0Q5+zF1I86tLbWpzKpkK1TAAof3e0YqSx
         XjU8M3+s2I+ZEWeZDZhGcjDKX9GqcYiV5NUOdGShUMAQ7lRNFKmBda9UrA+5U0ewhxfg
         /S27VXTYcCsH/v4uXvt+6eDE8+qOtqBjSjt9+RDiTCr13ZJijkU2fseyVa6ZawOQb1kS
         d/k7ovc69pOoSr0IUHmd3JRGBgJxl/Msa03QUPnXQukpZzHwViqM+/ohBUJJ4mglzqCk
         4Ea7Zfg7pF2vK9UnMGcQBUIkrZzg3/6iYmStOTdXHTdqIsTS3/+XxCMAf5Y6NrVpOTq8
         fWMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW4JIu6KGLi5OKSLcAkcT6lGULKZFI10MIhcF/odW+fTeOF0b2F
	+QRZEm/MeOw+TEi8HT+s5lF1hmd4FkgIiTg4pyNtDy3+s7e7P0isgLJUcBKfNB3jJ9PkKFPHo7s
	kd+ud+ctJekflqqYdSYzXR1VcHyujy3ice9ElK7t1pe5IYxw8x5NKyF6hpXpfmZ6ivA==
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr121741842pgi.84.1558945643157;
        Mon, 27 May 2019 01:27:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtmSgRO3THpdIdEg9xo8TDTfE93juMCwABmGwOfUSX6QG1bNhpSW5I8Z3iogj/A6vX2EQm
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr121741766pgi.84.1558945642356;
        Mon, 27 May 2019 01:27:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558945642; cv=none;
        d=google.com; s=arc-20160816;
        b=pPwjZJ4o332uF2c7UaDetH24yq3uEtjS1SaDFPmpdGCGkIqkBxC3I4trQpEEcBfnP7
         Kpw00cPANb3RQ0zDxARzraxeqvt+BCU6OFCbFpQWDh4WKlef9cPPlqUZIMRFkH2H+vMH
         7+wcbn3dKJZx3UxQn/1g2xXuH6pRWcDgTsMDt1rsYxtVu52ko3vCzAl9Md3L2ODD+ATL
         kqMJlwVS+VRqhbwyIy4yPGzz5+k4eHZfoGw11fmwpnVH8m5ZJ5O9l5Lu4XdB+bI2VRx4
         xMyvU6bMkpuCyJEiLMkndymMm8Up92cl3OdR6owMKyMkm39xYXFdHEaHVdpHtR3friyL
         7jjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=s658wFeksNRFSKjgZoYcRljTvH0m7MCJR8yA+py9GLU=;
        b=kWfb7tsoVOlhZhepKQ2ealG6C6C/wdmbclY2CX8FwOFUjdEJM+JAtGb6ut1HwvShJe
         57EnuvtsXMeCT4qcO4ZB/NTmVnb6DRTChPl46jNYITVTmB83gT9NIlrPaR4NOJaYCmxa
         Zj4bTwRpzhZgpYzsv0BpzN/e/2uHj+PA//MW0rIJP72ADhvt44EJaicelyyXew8phpbw
         Lex30waw7znrPIylqyb8yMkhisBtxC5fNzXLlWqjy+9QSM9lRp8VI4TtgWcz+xFKBveh
         5GzemBUSobzsuY19EbD5TOE9RKBPGy1JXBesNL67CykbZQgLWjQaWuj7renB23aB1kDe
         0HcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g129si18580850pfb.181.2019.05.27.01.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 01:27:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 May 2019 01:27:21 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 27 May 2019 01:27:18 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: [PATCH -mm] mm, swap: Simplify total_swapcache_pages() with get_swap_device()
Date: Mon, 27 May 2019 16:27:14 +0800
Message-Id: <20190527082714.12151-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

total_swapcache_pages() may race with swapper_spaces[] allocation and
freeing.  Previously, this is protected with a swapper_spaces[]
specific RCU mechanism.  To simplify the logic/code complexity, it is
replaced with get/put_swap_device().  The code line number is reduced
too.  Although not so important, the swapoff() performance improves
too because one synchronize_rcu() call during swapoff() is deleted.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
---
 mm/swap_state.c | 28 ++++++++++------------------
 1 file changed, 10 insertions(+), 18 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index f509cdaa81b1..b84c58b572ca 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -73,23 +73,19 @@ unsigned long total_swapcache_pages(void)
 	unsigned int i, j, nr;
 	unsigned long ret = 0;
 	struct address_space *spaces;
+	struct swap_info_struct *si;
 
-	rcu_read_lock();
 	for (i = 0; i < MAX_SWAPFILES; i++) {
-		/*
-		 * The corresponding entries in nr_swapper_spaces and
-		 * swapper_spaces will be reused only after at least
-		 * one grace period.  So it is impossible for them
-		 * belongs to different usage.
-		 */
-		nr = nr_swapper_spaces[i];
-		spaces = rcu_dereference(swapper_spaces[i]);
-		if (!nr || !spaces)
+		/* Prevent swapoff to free swapper_spaces */
+		si = get_swap_device(swp_entry(i, 1));
+		if (!si)
 			continue;
+		nr = nr_swapper_spaces[i];
+		spaces = swapper_spaces[i];
 		for (j = 0; j < nr; j++)
 			ret += spaces[j].nrpages;
+		put_swap_device(si);
 	}
-	rcu_read_unlock();
 	return ret;
 }
 
@@ -611,20 +607,16 @@ int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 		mapping_set_no_writeback_tags(space);
 	}
 	nr_swapper_spaces[type] = nr;
-	rcu_assign_pointer(swapper_spaces[type], spaces);
+	swapper_spaces[type] = spaces;
 
 	return 0;
 }
 
 void exit_swap_address_space(unsigned int type)
 {
-	struct address_space *spaces;
-
-	spaces = swapper_spaces[type];
+	kvfree(swapper_spaces[type]);
 	nr_swapper_spaces[type] = 0;
-	rcu_assign_pointer(swapper_spaces[type], NULL);
-	synchronize_rcu();
-	kvfree(spaces);
+	swapper_spaces[type] = NULL;
 }
 
 static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
-- 
2.20.1

