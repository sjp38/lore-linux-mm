Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53FA9C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FCB6268D2
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="F7RoYFZN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FCB6268D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91BFD6B000A; Sat,  1 Jun 2019 09:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82BD86B000C; Sat,  1 Jun 2019 09:17:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4B76B000D; Sat,  1 Jun 2019 09:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 317D86B000A
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:30 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k23so4282594pgh.10
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DO0P/NqpWaxU8vXSAVfvUgsQrfX5X5DHsidBEuTbznE=;
        b=OlRGuX1/BghRrt3WLYf3gFLlRsnddmb1Y64G4gfyJn5+tmmHOX5D3PYGDI3XEHud9i
         uH8aSK1P6eLLdoOvwN1hKJJBmUEoLzPfYfoDQLcCBN03cktEKIUtdFGIiER3f0zZDzs/
         VUeWh/WFm2cekUeJMDB5BUivDuEHQXgBzWh5DKxMrmZZMrKacXMlN5zP27DP9mRyU4Qu
         fnMZZAvc/p8bxXirIRgBMStDzDIUPejIFiNffPtKjVZWdEqfvL3igor7xM7UfNA9CjSO
         1+K/mx4nhWUPYXB9DluwUGyh/rw3NoZdQlmmXvCWUs1NA37dihpv6L5YP8ERmDnL/bEy
         3RVg==
X-Gm-Message-State: APjAAAXolcQLoQRtNeZ5DecA8Mmyvc/DLF1Qz9KC3n8v0hq/Irbrh4kG
	QYCDLm6GCY6eTrTvV8LrsOr5iEGVsctf8MXN6FX8KMJ8ZOT9LWEHyMuqfZWnxgMfqjS46qgNX9N
	0rmyBD1bdxLpinfONA99MWRKXJf6Q30BGhUq0/stnZu49bJiMQAr4iV43NZl0O6+Fgg==
X-Received: by 2002:a63:ee0a:: with SMTP id e10mr15271211pgi.28.1559395049742;
        Sat, 01 Jun 2019 06:17:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDd987xdCWMujxhokPP+/hz4c07+HCreOza2I/B8MAjJjqht6meV9DrGcau9huSTQx5APo
X-Received: by 2002:a63:ee0a:: with SMTP id e10mr15271114pgi.28.1559395048733;
        Sat, 01 Jun 2019 06:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395048; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2d/hY7ZhBY4TvLgWeqfPLGkqlDGE0bkg8lR577G5540RpVhZ9yVPrOhCYrZRTVffW
         iDp61bhkPTZYQb1O4Uw9knEpVK76hVY2GjFiavmsyoUl3yzSYxA0GY/EtPXkEuiMi/+6
         +0vxp9AdNodzNQ2l7C6ejZ7PKEif4So58Sz1SHFOR2dFIj1oJVe5LChL2avA45mzbtnh
         I/+BVWf912tQshE1vjIqPmefYGBQycItAWJD0uBqjEV407QxxTpDSg7KwNKO0k9aZKKY
         nAGGwB8QSNfkiUHrtmnVZqc4lXkmBQn9PLtKcBD640hNsBE5iZAzM2dJwSSCjqB0WV4q
         hDXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DO0P/NqpWaxU8vXSAVfvUgsQrfX5X5DHsidBEuTbznE=;
        b=xxi8fQz9Lhlg3BebaucCwJoQalRmwlNOGkJqOQKojrK2BQ9lX1oj8tbHrTdgA1UJNy
         XlFEW95qrkjI52NrMDLo0Z6LtSi9QqgUOOQ7LBMnvhthxJXKCZLYUOLcuC47BlbFtvjj
         KvkLsT4blHQfq8DzyRUBUcE9Xqd/hNWn1spg/7adIkBQxjDahccP9+3XH2BgcQnDJv7r
         /vqBSDJMUL+2XtstwSZWn8r1kQS74W6fGWmBDN5UuDP+ovDcYdIQ8a6I1XHnkpOUQiRz
         zLr4Rhd1skZhWQPqZ9xi5e1WfHJLDtO1aXY+nY8QRUDrBqbahSYfJmNmnYXLDWoOe1U+
         huaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F7RoYFZN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i11si10934529plb.416.2019.06.01.06.17.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=F7RoYFZN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 38FB523B55;
	Sat,  1 Jun 2019 13:17:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395048;
	bh=adYvW22iqvVHA34DPtYAqlnX/zQXWKyEMfkrJ54DvBg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=F7RoYFZNb+Cbu6HlQ2I7BjeCmGbC7jxcXKSq+0fzI4WvhHYpIaVgH2LpkSZRLsdK1
	 Hr2ETIBWIHMK3Nm0oJLrcN6OR5jTjHXb17MslFhVEPbla1Tq230IarzIzYplk+Zd0f
	 rKrVDjlEyCBPcBMoOXOUoEabBAT0CwhS9kq5UdCg=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 012/186] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:13:48 -0400
Message-Id: <20190601131653.24205-12-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mike Kravetz <mike.kravetz@oracle.com>

[ Upstream commit 0919e1b69ab459e06df45d3ba6658d281962db80 ]

When a huge page is allocated, PagePrivate() is set if the allocation
consumed a reservation.  When freeing a huge page, PagePrivate is checked.
If set, it indicates the reservation should be restored.  PagePrivate
being set at free huge page time mostly happens on error paths.

When huge page reservations are created, a check is made to determine if
the mapping is associated with an explicitly mounted filesystem.  If so,
pages are also reserved within the filesystem.  The default action when
freeing a huge page is to decrement the usage count in any associated
explicitly mounted filesystem.  However, if the reservation is to be
restored the reservation/use count within the filesystem should not be
decrementd.  Otherwise, a subsequent page allocation and free for the same
mapping location will cause the file filesystem usage to go 'negative'.

Filesystem                         Size  Used Avail Use% Mounted on
nodev                              4.0G -4.0M  4.1G    - /opt/hugepool

To fix, when freeing a huge page do not adjust filesystem usage if
PagePrivate() is set to indicate the reservation should be restored.

I did not cc stable as the problem has been around since reserves were
added to hugetlbfs and nobody has noticed.

Link: http://lkml.kernel.org/r/20190328234704.27083-2-mike.kravetz@oracle.com
Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/hugetlb.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5baf1f00ad427..5b4f00be325d7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1258,12 +1258,23 @@ void free_huge_page(struct page *page)
 	ClearPagePrivate(page);
 
 	/*
-	 * A return code of zero implies that the subpool will be under its
-	 * minimum size if the reservation is not restored after page is free.
-	 * Therefore, force restore_reserve operation.
+	 * If PagePrivate() was set on page, page allocation consumed a
+	 * reservation.  If the page was associated with a subpool, there
+	 * would have been a page reserved in the subpool before allocation
+	 * via hugepage_subpool_get_pages().  Since we are 'restoring' the
+	 * reservtion, do not call hugepage_subpool_put_pages() as this will
+	 * remove the reserved page from the subpool.
 	 */
-	if (hugepage_subpool_put_pages(spool, 1) == 0)
-		restore_reserve = true;
+	if (!restore_reserve) {
+		/*
+		 * A return code of zero implies that the subpool will be
+		 * under its minimum size if the reservation is not restored
+		 * after page is free.  Therefore, force restore_reserve
+		 * operation.
+		 */
+		if (hugepage_subpool_put_pages(spool, 1) == 0)
+			restore_reserve = true;
+	}
 
 	spin_lock(&hugetlb_lock);
 	clear_page_huge_active(page);
-- 
2.20.1

