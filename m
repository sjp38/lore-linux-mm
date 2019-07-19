Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3E9DC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C04621882
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tG6QkiUH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C04621882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 278D26B000A; Fri, 19 Jul 2019 00:02:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 227EC8E0003; Fri, 19 Jul 2019 00:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EEB18E0001; Fri, 19 Jul 2019 00:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C97C06B000A
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:02:00 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s21so15117557plr.2
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:02:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wbxyyTpECoi0BxM7wh994IW5M0Tb/ffskGFKaTEeXkA=;
        b=TWGt6WAphhTm98sWzUJfziBZjHUXamnrk3A/WYyC2lNyvAafF4zp6HN9jDCBdNrmbU
         laKZzyKkphuTrO1UoPc0Z/br8F0nXLdzzk9Hpxn84ndQ8KxMHB7M4yUoMZ4eiub0oCy0
         RIDg4Qtb8EPZOuoOJkNPtQ9OoRz5Xu/r9PiOr9b+n6Dj4AWsg+KfTnwvJCVJ7Y0i1WCJ
         SDEFpeci4qlBgtf7rHxJXONdwF+NHGSHpvmbDOHYiYJ31PgtJmXPUlHQMFVPZ8P1Yluj
         8XJk6tpyk7N7OWvspb+Zq5UdIpK6jPRZ9iEH3BSF7QCew+cOUHQGugxKjFYRoqQreNzw
         SZbQ==
X-Gm-Message-State: APjAAAURtzyu71cQ0mFaGQPhT9s0oKskv9vPK6iGS7Pn+Q5YlBY/DBiR
	/VDP5BNeaql+osTRPtADAJ+fZz+TLXmr292h/YamkuEnhPGDX9iVR2OXgvUETdj+4oLkMrFtWTK
	U81wic7Vof9xeMHdvuGC8TajyETGEzZlkxnLjewZ42ILvxfVIT/yUlUKj2WgD8IPmXw==
X-Received: by 2002:a17:90a:bc42:: with SMTP id t2mr54962950pjv.121.1563508920282;
        Thu, 18 Jul 2019 21:02:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVhRgWhpVdMjee+U2/Qc8sRx5zcGg8beYos1Mwci8N5cSvZNBsKkImURAofJWsKuQIYj+W
X-Received: by 2002:a17:90a:bc42:: with SMTP id t2mr54962870pjv.121.1563508919457;
        Thu, 18 Jul 2019 21:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508919; cv=none;
        d=google.com; s=arc-20160816;
        b=a45Tc5l7fE5k080LBeya7la3XfpNhAT7m+3QS2CalnDLa1q5s3lvO/CKErhsPlTVPZ
         89mypo6oLUYjJrGHQnhDcDQiX/V/K7vZgG+93FbNLI8Uy944yB641aPRAV0WoH0ZdSId
         40GR3Tm1EcyKG1Wx25mATSII2uJx3lpKWibtc3FJBoUrBU5BwQMZhYyTG7ar8uVjZB+J
         u82i+umAOG4ceKnpGcEmfA6g+BJinEdqjhCa0V1i9cQ5ebnyrrmLv5/f2Agc62xPZ8du
         5AayMXV4KoLDNCJvekv9N95ntiyZ5gOJiqqB6u5nuLgqb8Sn5DIiqWXOnPqWooM7aoK5
         AbvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wbxyyTpECoi0BxM7wh994IW5M0Tb/ffskGFKaTEeXkA=;
        b=OC1/5FY0vfP5Gie9l/PHgqx1hN1nazMfTlsdSEYpAahiIvcSK9qG//smpo+fQdABRd
         yf4gBHxL85sV7g79nkNGzK+1fFQib+nk0Xkhto+tH1kfTR0tYUI0oF28vnGc90ynnIgi
         inU6Vwqjb2fNCuwMHDN6Y+la2F6bms9Qq/hEYjqC5YusZ/4nlWADLxPVcgR5nXUU+yHw
         4fVhTBkYN94iiJ1MTdZ7e0QuRY67b3RBRtGcm4CNl5nUzTx+W2MIW6chT/gkz77JEVOH
         mC5YkaDO+1PupsrFA5sM28bI0v5SM+yBndsN1xATk3ofFUAG/MuoBBn+dTnwzM5nkQCF
         V4lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tG6QkiUH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k11si134196pll.377.2019.07.18.21.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:01:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tG6QkiUH;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 014FA21851;
	Fri, 19 Jul 2019 04:01:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508919;
	bh=hd3faQ3NjDa7987x5ieUJyMgS5PrMg+h5OFV8vUuDas=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=tG6QkiUH0qtVSPFmuzV7qsEUFaGrl9xhD6GIffsJTLPEiJo/dKYvARlAqWE8J/su1
	 puKv24BAxPl5r3ThTtsFUr01x4SqaCXGa9b06pjsC16JjQ4nMP+ErLVToAtM5UlG6Q
	 4Sndwi6lUKKP7xxRd0qJ4ktgtqnzh5rVzpWzbep8=
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
Subject: [PATCH AUTOSEL 5.2 158/171] mm/mincore.c: fix race between swapoff and mincore
Date: Thu, 18 Jul 2019 23:56:29 -0400
Message-Id: <20190719035643.14300-158-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
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

