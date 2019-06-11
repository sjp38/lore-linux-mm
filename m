Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00E51C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 02:05:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A75292086D
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 02:05:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A75292086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 112F26B000D; Mon, 10 Jun 2019 22:05:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C47E6B0266; Mon, 10 Jun 2019 22:05:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1B8D6B0269; Mon, 10 Jun 2019 22:05:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA3656B000D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 22:05:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s3so8096297pgv.12
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 19:05:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=LG5SlxU8Oc8Q3qAf12aVUVPOQdkgYmY8CA0ELwPZeZ0=;
        b=ajKQyRgipqu5JQG5AbCfhOtIKPb2PsKxupIX9uL/zP2nTLXlHZiNKMw4QsGUl+Acty
         jrFYp6d/aRTzCLAoOUX6Ry1+Bya9W6Q4R8er22ihxd2bRM5Kb+HQKqIjUSZVePJ1W+6b
         lO5jSZ2/nKIBCZprfH0WT2tpEqsDUeBonxQUvkDH/WK1JJNWRMV49Aa+1IXrt1tKVTbx
         OXc1gVaEVMnm7g7TNgwhqolc/dsOuDMAAZoIgg+niUhcQx5e2UCcYO/CZL1smtd5jyNT
         PJS8kZbtRRlKUWcYoD6HlnEUUKUflDELgiX063qf92hptStEDtT21DLg8lgFFOjpGx45
         aaNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUBvyAhH397V2kKMrd6LcJkoeHlhjn95lylqr53itwmX9vb5E3m
	wclEGMJI+NpyWxX5bJ8TSATZpKtAe55sGXWfhK/OirqnWaWnHxtwnUjCrFSC1UzfeQzQC7JORB0
	QJoStPtMVVvMb169Q3lSnyJkOmjp7LM4aeG+lpzz5O9EY1RdG3xjzNbQLocapVinAYA==
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr73272300plf.176.1560218729279;
        Mon, 10 Jun 2019 19:05:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxC2tjQ2Co+diGVnHNWSiHYQYv+pXk7BpTvouIALeOijgojBu71jh3WMruaf0atgVyTuRZ0
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr73272224plf.176.1560218728120;
        Mon, 10 Jun 2019 19:05:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560218728; cv=none;
        d=google.com; s=arc-20160816;
        b=vp7ubJEzuo4IQzaqlO07+1AtnRaH3K6mcZo98b4pW2zzFonO9eh3LrEOMaRZ6lnUgS
         LS+gxY/5MD1ddaJVuYHt4MmV+Y1kjhAa/RwDckobamkhdFVzl5yHo9hCl4XeikwJlxhj
         aL+tQzMqCrBKwmt5yIdFty7RbNBE2rTJ+jE5A7kUCSAxVoN+QIUjkF4It3vEnuFu23k7
         pJCVp+TmeWS4VO+R5OcNQSbckixOHlRhbzLr1/nnijvVsnaALyvNcCJnYCVXCTsD5UFc
         0k6dqqnwR6y21L1C4pKIAaNnRfeJs6Ebt+mtR1MqYQ5Y9QNj7DcC1kv1HSvLu1S5BQAm
         j1uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=LG5SlxU8Oc8Q3qAf12aVUVPOQdkgYmY8CA0ELwPZeZ0=;
        b=zEtQ+E/6bjGssXJiifmSHW7AwtKq+X9F7k52JHTKO5Ry8mWxqV1HTmyo2RaNDx/5iO
         b9mSlVXm54HCsE0Kd+B0+FsN3T2+bI69DVv+GzaFB0ZMFKGUHy+Jt4C2/UNWXm8TT8D9
         3c7ykZCfeL+Bbr3XxJbL1HY19ONORE6EjabmW7bflWyOd7tRuFVNnc4gJEU2G9A+LfHl
         /GZ/ODxExp/leQPKJbbvLcd1EaRSw3JMfrU5KkKX4M44yDUYOkosKL98W8ZZ+sVaEsfd
         1rT7IQ6L0pl1ZcnAopEsRfw3wsUJCUAcju7dzPoj2IZy/irIzdzsvYeThpfWdAUx03Ui
         KP8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id c16si11454293pfr.94.2019.06.10.19.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 19:05:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jun 2019 19:05:27 -0700
X-ExtLoop1: 1
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by fmsmga001.fm.intel.com with ESMTP; 10 Jun 2019 19:05:23 -0700
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
Subject: [PATCH -mm RESEND] mm: fix race between swapoff and mincore
Date: Tue, 11 Jun 2019 10:05:10 +0800
Message-Id: <20190611020510.28251-1-ying.huang@intel.com>
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

