Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2B39C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3A4626162
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 02:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3A4626162
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A8696B0280; Thu, 30 May 2019 22:41:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 259F96B0281; Thu, 30 May 2019 22:41:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149566B0282; Thu, 30 May 2019 22:41:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE31B6B0280
	for <linux-mm@kvack.org>; Thu, 30 May 2019 22:41:32 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d2so5236619pla.18
        for <linux-mm@kvack.org>; Thu, 30 May 2019 19:41:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=+OLMXcEs3qrKGR0MjG5Pet6MFnocpP6ohXP1uelfhvQ=;
        b=ek73qlQ+kxPfSWbwMnJ3lX8nKEcfQdFm1YTum1ldjahe9S4T59WyWM1L5zGeF2U9LB
         9e0tYW7UYKNWioX90fCPcJ1JEAIGCbHuBst4XChjwKNgtWr3Qhekc2UTNVdyI4QNOLI8
         Qoz1huWj4tGFAcArdOD5cPb3TSewfVeVDKcg9L6fFHVPZbxXoDJk+sLMa8d630LPe+Yb
         bgdyzjK1y4xp5n72UZoq89IRBQh+8cTxMAJkYOsTBFQBDpdegbPbuy/CsjsyygYwswxY
         Ar2l/iXA4Zr6uxjMf55S5R3hYzt8gwHc9i3kdRqalMuvPmlAV55yaTy/YtbYWOrHQuL9
         JKEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVeIMbA+Vkrq1ooSRm5KLl51EkZ/2Czts5P34aBQLwOWpb1Uslx
	PDYAiUqy8m02a01vIsxb5074tylg9T7ZZ5dDi+hH1fHyyXYbqnOkE9pweiHc7UKdjrV1JLXGdcg
	GOKtAy6kd1Qd5Cwz5GBgxLVAN6lLVecCkVFyhH8lfGg8mqG4+Wpx9RRnna14cLKMWrg==
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr6416835plb.203.1559270492501;
        Thu, 30 May 2019 19:41:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpaNxT6lbeis2IRMYYcDT1r1yDqLEdlkLmIpP8OnmqDkR0OwWoyTKEtD51wcllO4mqv023
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr6416786plb.203.1559270491527;
        Thu, 30 May 2019 19:41:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559270491; cv=none;
        d=google.com; s=arc-20160816;
        b=uqrnhYN0He1/abIoC/E1pSh/IFXYz+OQgeuLonxuXg3QPDzfz5TJGzPTP8r2cpX27n
         SrfsIY/uSIdNKGSS+W9ixfJfuQz3KJ12QdpOl/IA/Ak5M/BzmeX2yfegcm8Bbv341Z/j
         /VboN0QUt0fJq8daIRSf/KGGciXpqqzglDkIhbNTXWfruJctC2bnS2KdhgWr7MAJcHWO
         6l29TWqcJjxvGpxGZ6mh0K7wm5cZ/UU3FUhsOmVGM7z9rGTMEC+cyYSUtcSZb135I0gg
         3idFWoG2zJMQzUvzMsIYmjqsFziAoRVEcKCKFSABUBFxoHjcs+XK6hHK8brAzYzupCQW
         zYuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=+OLMXcEs3qrKGR0MjG5Pet6MFnocpP6ohXP1uelfhvQ=;
        b=GUhSyq8W/pkCM4/IKZ6j74xojpaij/6b/y5SduhBbzhxGIAiIz7DQWk5UEi3pGrkUF
         2RqsYY/TNAUt8XlVqPa/ttusyBxeGMZgYEF8SYxsKJz0OVsny8R5rKvJMZGRYgED/EvA
         756RPkJzzJE5EC5BpvYRMKWQVSW/PrLL4W7JjouHnII61+8nHrpKcZwQcPPO67Gfay/H
         MYrIX2R7Zzgxdzz2EpGV/4yItxmySiOFJUN2JuatxJhSwc+ZXKfBi7wgwJ/PtcY6PLgs
         vStIAFp2DtBa+DsxtgiPmKRB1HpX3Qi2/eVnH5eVBjFQsw5FPRoIWfVduiRy1nU3ifEa
         EG7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id p7si3375484pls.253.2019.05.30.19.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 19:41:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 19:41:30 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 30 May 2019 19:41:28 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Minchan Kim <minchan@kernel.org>,
	Hugh Dickins <hughd@google.com>
Subject: [PATCH -mm] mm, swap: Fix bad swap file entry warning
Date: Fri, 31 May 2019 10:41:02 +0800
Message-Id: <20190531024102.21723-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

Mike reported the following warning messages

  get_swap_device: Bad swap file entry 1400000000000001

This is produced by

- total_swapcache_pages()
  - get_swap_device()

Where get_swap_device() is used to check whether the swap device is
valid and prevent it from being swapoff if so.  But get_swap_device()
may produce warning message as above for some invalid swap devices.
This is fixed via calling swp_swap_info() before get_swap_device() to
filter out the swap devices that may cause warning messages.

Fixes: 6a946753dbe6 ("mm/swap_state.c: simplify total_swapcache_pages() with get_swap_device()")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
---
 mm/swap_state.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index b84c58b572ca..62da25b7f2ed 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -76,8 +76,13 @@ unsigned long total_swapcache_pages(void)
 	struct swap_info_struct *si;
 
 	for (i = 0; i < MAX_SWAPFILES; i++) {
+		swp_entry_t entry = swp_entry(i, 1);
+
+		/* Avoid get_swap_device() to warn for bad swap entry */
+		if (!swp_swap_info(entry))
+			continue;
 		/* Prevent swapoff to free swapper_spaces */
-		si = get_swap_device(swp_entry(i, 1));
+		si = get_swap_device(entry);
 		if (!si)
 			continue;
 		nr = nr_swapper_spaces[i];
-- 
2.20.1

