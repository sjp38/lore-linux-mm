Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E33EBC282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 08:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA172075E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 08:54:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA172075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F6E76B0007; Thu, 23 May 2019 04:54:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D7016B0008; Thu, 23 May 2019 04:54:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BF146B000A; Thu, 23 May 2019 04:54:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 062726B0007
	for <linux-mm@kvack.org>; Thu, 23 May 2019 04:54:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so3072560pll.17
        for <linux-mm@kvack.org>; Thu, 23 May 2019 01:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=LG5SlxU8Oc8Q3qAf12aVUVPOQdkgYmY8CA0ELwPZeZ0=;
        b=YS3C8aBZxUZdLAxZ7ZV+uB9rHFxEjtiF2cxbKaFqsW/H2BgdM43kFdTwGU6LoMxABd
         J/KcEcn5jQWu8y1lDvUVUzJDV0AJqQ2EjAk0ubIXlwmq2OQu2aqSDkyrhl8NlbDPvYJn
         5CrxAPdGAD/mpX6xqy6UT5jm7ignBd9u3u6B9k0dmcUU8PQcmx4dSBI88be5aQ4MFzxy
         pjKfBFj453pXsjaMQHGyOJEAP+OBmCxahMkga6qL10tFrmbqXIYpDcey2OHJ7f+1dQET
         WEj6TG+W6NHCVPoOFQKzK8UAclgcWwNNT/kxHTFTcI3RZolczrJcpcHWaffS+36kGodS
         8iOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX2C2J0dcRHxTJ5PMbEhQjvVqsfHLL0VUMrvtdUdDrG3K8O/FnO
	lpET5mFMSB20EPWMoxWNCgj1JtXsyAj6NkgxugolKby1IKmn2ofu0q7mm5XKgoVLT3hBn3prtUT
	c8WPFGY4zyTWNGeBFZz0OxavO4Ll4h1mL+DN1z/sAUExFMxZf9h2RUiyKG5dSjW2E5Q==
X-Received: by 2002:a17:90a:3848:: with SMTP id l8mr238040pjf.142.1558601658242;
        Thu, 23 May 2019 01:54:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyayewvjqrVY5xRrFG/e8s9JqhsbvHsd9+iSKaboAq0n6OHzBHSvs1H9fmZCZNPUQn0K/fl
X-Received: by 2002:a17:90a:3848:: with SMTP id l8mr238016pjf.142.1558601657042;
        Thu, 23 May 2019 01:54:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558601657; cv=none;
        d=google.com; s=arc-20160816;
        b=SsmE685gfJuKdCJEST4/zQq+WKZsMEjwNdy7WTBP0t/xybgy68LdilG614E0m45tIn
         t9Fp/GuY+UF0H0Crhk+u8C/geOff2f10/+/OOWljzp+wpQsoTXhtsq5Veg0x8lUAcWsz
         uIManXdacU1HRTyLncPD1SQSMhQTrRT803Gwz2f+iR6FQxCAAdgTeFnB3cfPzxr4IOB8
         8J1IwRLKeRQq9l0OLAJ30WGvKQH3rA7SbzJNzXio+xEAMPnzlLFNJHzQeFrHLkbNHNcQ
         qC8Q0aL16YfIyURzZ4K3WA3PLNC1VyWz8kTmGJ7qoUqEaXswS9uisqJaboDeViZ5dx87
         YHwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=LG5SlxU8Oc8Q3qAf12aVUVPOQdkgYmY8CA0ELwPZeZ0=;
        b=OE/n62+dQRknf92QhNcJ8k77R9G1XWangAJ9TE2AkV1QE5KZRb2WyyoYkYa96TdKYe
         rc1mdiCHg12qcB/V52cFBJisjSdo/1sVSIeYzCqi0WHnasRp9jIO2o+6Ljg0HP++jHRq
         Bhi65U48LS28oVr7zK3uot3dAl713ra4sqjBCy2mbWaynUoNpFwU5YNP8BhkyGGlNnk+
         VTcI/35eyn5N7QYBXUhxdv0EcvC3qY+D4XkupsqA8CP3pG+W6rLCFKu1HyBjGq/6BdOD
         1WJxmRqaehUoKYRtc7WFPibOsl+3uuZB4gdN6MTkFPT/21XOjyrAnEwSGHIROtqUEZN3
         uKLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h1si23326490pgs.290.2019.05.23.01.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 01:54:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 May 2019 01:54:16 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by orsmga002.jf.intel.com with ESMTP; 23 May 2019 01:54:12 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>,
	Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: [PATCH -mm] mm: fix race between swapoff and mincore
Date: Thu, 23 May 2019 16:53:47 +0800
Message-Id: <20190523085347.14498-1-ying.huang@intel.com>
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

Via commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB trunks") on,
after swapoff, the address_space associated with the swap device will be
freed.  So swap_address_space() users which touch the address_space need
some kind of mechanism to prevent the address_space from being freed
during accessing.

When mincore process unmapped range for swapped shmem pages, it doesn't
hold the lock to prevent swap device from being swapoff.  So the following
race is possible,

CPU1					CPU2
do_mincore()				swapoff()
  walk_page_range()
    mincore_unmapped_range()
      __mincore_unmapped_range
        mincore_page
	  as = swap_address_space()
          ...				  exit_swap_address_space()
          ...				    kvfree(spaces)
	  find_get_page(as)

The address space may be accessed after being freed.

To fix the race, get_swap_device()/put_swap_device() is used to enclose
find_get_page() to check whether the swap entry is valid and prevent the
swap device from being swapoff during accessing.

Fixes: 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB trunks")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
---
 mm/mincore.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index c3f058bd0faf..4fe91d497436 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -68,8 +68,16 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 		 */
 		if (xa_is_value(page)) {
 			swp_entry_t swp = radix_to_swp_entry(page);
-			page = find_get_page(swap_address_space(swp),
-					     swp_offset(swp));
+			struct swap_info_struct *si;
+
+			/* Prevent swap device to being swapoff under us */
+			si = get_swap_device(swp);
+			if (si) {
+				page = find_get_page(swap_address_space(swp),
+						     swp_offset(swp));
+				put_swap_device(si);
+			} else
+				page = NULL;
 		}
 	} else
 		page = find_get_page(mapping, pgoff);
-- 
2.20.1

