Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1426C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA03F218BA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="oZAQptQd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA03F218BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A88A8E000A; Fri, 19 Jul 2019 00:06:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 530CF8E0001; Fri, 19 Jul 2019 00:06:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 383DE8E000A; Fri, 19 Jul 2019 00:06:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 009A18E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:06:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n9so14533288pgq.4
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wbxyyTpECoi0BxM7wh994IW5M0Tb/ffskGFKaTEeXkA=;
        b=KNEZCHxWYMf8riRwcwRD9Xk8aDbR9Rkmbp1lH280n+fv6V3FBiBfmtwCwNCUkcREcF
         bYS4H/JiLzy3vkCprNqFcBPi0hRomHwqtNOvpK4h/qzFDi37gMfSxQ3TslHBbkmummxK
         iARvF0iGDyB9vxZZUEpVJSMj/cAXWlUHN2aGh/0JSAIvRUMrTA8hR6iT6rU7ax09vHJL
         H/hfIjQMU1zilz98tro1NYqnI/yqJwkvcs9EBHG8RKRc95LMW7axKKW1HHGAo/5bPhyB
         4k59LK8rDV9iqurJFRs9I2MTrHgbzKWJen99U8Mn4ku+bYLlCENROMEFFcojuEyHygn7
         qU7Q==
X-Gm-Message-State: APjAAAVk3bnbiTzfZRgne+w39Zoc5EsyyA2I3ck553XBrblnIY7IXZtZ
	Gkx0Mxl5Pbq5b3cfvPa4pXYP8Jmi5s6sS6iJaencqMIhTDvYqxusRgPqeiezIdX9P9SxFQf8WQu
	aeQJP2Gu+OROA1PQszh4PR/revLTRqK2ZzgFtOwkphfeekueVMKs1VwJISpiDCbguzA==
X-Received: by 2002:a17:902:112a:: with SMTP id d39mr54997872pla.254.1563509209666;
        Thu, 18 Jul 2019 21:06:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIP3lAYQVHi6y5f80bsuimCc+4dROftuiEmr11ZHn5r4kgQy217ZyGKKD/upaOepf8bOUf
X-Received: by 2002:a17:902:112a:: with SMTP id d39mr54997813pla.254.1563509208975;
        Thu, 18 Jul 2019 21:06:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509208; cv=none;
        d=google.com; s=arc-20160816;
        b=hIyBMmMm7ATm4tKcCka4DOAozvPQvgu35RngVTPvHb8mayud/Hv0d2YW6qzBtN49qf
         QTUvUH3JkNqwHkBacQy0kIMhvzMvVI7nXYZHDDiGrpsTlpXwmWAHgPDwS20otyvlFw3y
         u21R/bWB3vEBkw/PMiOhgtrYQ/lAqO7oOTcEQSCZ6EmTscqWooNtVM5hiG2F+ZDWH2Ze
         gNVt90hB9rv0L/e3My4ZeZZ3Y48/OWLSrftwgeoBIiMFW1DY6kPSaYu8UvYxPmICx+f4
         oaACnx4O09Up0acQaesG3nc7IqFFkrjpAItgHDFn+KpHon/d8UMqwBDPRlhDCIUM4ZEb
         8yrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wbxyyTpECoi0BxM7wh994IW5M0Tb/ffskGFKaTEeXkA=;
        b=JqtHUwj8IKdi9VfcyNIvLQlqRDJT8aMid4srk2Jyq5oxnbEYWGk7bf+f4C75Va6VwW
         91nkWrAV39wD22qbYVOGf6WbZJ0wX4rvaRx/x6NJSnf/uF7L4cKFQBQgbELZF8QHKGfC
         QaAxscd8vt2XZTQ54UXdu/bQWnpF6ryHuXjw6ZJ2O4gL8yq+RLMGZREdLwxDruMNx+h9
         yEvOvAD7jkfB1ebilM7270Fkwj+fQmZw1LW3JEkEtnHSjRGdCbX2stqPZOOB9alTWZWm
         gyQMNQqMMoBm/TkvVV6xwfN1TM5kE12WxFoDMbNRK/hZEpeV7rA/0orqejhyq6xQNdLi
         NHQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oZAQptQd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t5si359405plr.124.2019.07.18.21.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:06:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=oZAQptQd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 82F4A2189F;
	Fri, 19 Jul 2019 04:06:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509208;
	bh=hd3faQ3NjDa7987x5ieUJyMgS5PrMg+h5OFV8vUuDas=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=oZAQptQdF5QYsyKkEdqiasH2VX1m8RpNu77ZIGr92ZWmxyzvae0T6y8bOoBJtL7TT
	 Zm5oa/65Vh5sUwDbhpRTs5dnxrJFpMcMBcRmp6xXW452X/niVv3l8R6uQseVGqX7va
	 2KY0X2BRAwe855TTfg+1/gCx925+u88clMF3rwOg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Huang Ying <ying.huang@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 128/141] mm/mincore.c: fix race between swapoff and mincore
Date: Fri, 19 Jul 2019 00:02:33 -0400
Message-Id: <20190719040246.15945-128-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040246.15945-1-sashal@kernel.org>
References: <20190719040246.15945-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

[ Upstream commit aeb309b81c6bada783c3695528a3e10748e97285 ]

Via commit 4b3ef9daa4fc ("mm/swap: split swap cache into 64MB trunks"),
after swapoff, the address_space associated with the swap device will be
freed.  So swap_address_space() users which touch the address_space need
some kind of mechanism to prevent the address_space from being freed
during accessing.

When mincore processes an unmapped range for swapped shmem pages, it
doesn't hold the lock to prevent swap device from being swapped off.  So
the following race is possible:

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

Link: http://lkml.kernel.org/r/20190611020510.28251-1-ying.huang@intel.com
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
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
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

