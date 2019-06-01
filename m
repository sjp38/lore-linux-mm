Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792C9C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EFC2272D6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="fTRpmZ9M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EFC2272D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D81376B027B; Sat,  1 Jun 2019 09:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63096B027C; Sat,  1 Jun 2019 09:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C487C6B027C; Sat,  1 Jun 2019 09:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7886B027A
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q6so5817110pll.22
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gSHAWGi2Bw2uuD96dbx9euRXJ4Ov19DWyrwW3pERR1Q=;
        b=MV6OVS11qVxEZGDgwsUUYqAQT0seI91oNeLoJTs+rUd8cPgtbnWVNaN/vlrtX1Pgsa
         /cRTurFo+L/mdIQJFoD2DYx+cW9aB5Dnz9hqX1m7qjYaLD5V981tYZWnDkQ8d9mJrIOf
         Y4z5qy5RrqfhQ9gSM/UcF1AEtzKdDSuVEyVuq7YwHphtFNWIQRo4j/HVlLV5X2QsCvGk
         MfgF/75iX7GLrNERZukQisvIDynCBfmlRBrm7rrce5H3w1wBEO2huw2BK0o2diqpsrgF
         6JhGaRHn4MGBmsrSkkvMtrFN1YUN0tfRh3gkK/p/NeJz08YrjvyiX2G6E1w4akhETFs4
         Ltcw==
X-Gm-Message-State: APjAAAV79rVw5QA/rziphLBCyYpBIBUEP6w1KPjhZpMbtI3gqvjhZFNp
	QQVUhY1viByvbTWAhCSEyGxuRu2kAZw570ojHqTHMrd1jviFlCFyNr/CY7Kw0yypmFxyWn2H0pz
	q+b2bmQwhgfHwMleBOWG+awawVoVbeOI/PzaMuDlYE2xLtjSxtW+mE3f2hIYkGTNpYQ==
X-Received: by 2002:a17:90a:a516:: with SMTP id a22mr16440601pjq.27.1559395217231;
        Sat, 01 Jun 2019 06:20:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqKkxTc7OOgRyws2Ae90qeoHi6QUkmeRiDOvKAKXBr6MjR39nq1WaduiOax5EF9ytBRufP
X-Received: by 2002:a17:90a:a516:: with SMTP id a22mr16440527pjq.27.1559395216542;
        Sat, 01 Jun 2019 06:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395216; cv=none;
        d=google.com; s=arc-20160816;
        b=m8TblKbBD2q8rUrao0X4Bjz6+9SuEhNh+7ZRZj9l7a37vBPHw26zP3gRTl2fyW8zmr
         Whou6Y8fzIUTpWuhrA2Go4ZCpWAGYPVGZBPW4DMSp+f5IGZoMhF5mWweqPwY2lYDoX7/
         Yfqt6+RFF/uhjy5zQLytG04A65eiL4aERbdUqn8lOM45N3rZuII+VO70/l88UavlcEiC
         m9jdLvEISmjGl12m7Oc27FcMSEdnzpwW6mLOFT8i2K6WAFOsvdVDAJfmPKpRtkmfbak/
         8aCu8ZMjy9VDOvpMS3xjMdNfI9zk92WrEuPPJh59qWikuKXNzIjhi1Y9yNhiG3UQhgjF
         guoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=gSHAWGi2Bw2uuD96dbx9euRXJ4Ov19DWyrwW3pERR1Q=;
        b=sKARv9+pupAmbqowImn7ox7QsF9ODVHgR91ep3jqOy6BWiF45xYYAtDJ7APbepxGX6
         9HQSkTyR+HrZ6tj0CP1WFS8fU+nap8zn5ZugcW/H8EcBjBQZgZpdtKtowmP7wwb2APHK
         MNtJqOA5WuNjZr+hPD53Wh0s1yuu6VpPvLsfdpffyxZkD9V6czA6T3wL9l3d3gdDWGbC
         T+zhvLUZkonetKBE/qlA30mwkFUwlIWbbHDPHo45hQkIf0mJnal8zFA+uG2m/uLdb0g4
         0aLGaLV68FicmMpH7lb1U6BPNU39MuihZM6E8zma/UVRYCCIO22hrPMtkiw7LUilHLAr
         lEaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fTRpmZ9M;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f59si10737074plb.107.2019.06.01.06.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=fTRpmZ9M;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F4026272D0;
	Sat,  1 Jun 2019 13:20:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395208;
	bh=8YaGq8+wExRIEeT0ouEk9b4OzKYM5LOfBqeGXXrKZPg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=fTRpmZ9MuRHRjHn5V/lvYbpLQ2bqtJrCb5MlDKAURkdraa4rocsZACRw5eq+cO7EY
	 uKjowb6k9mt7gOfzMJCOJ759QBBiMT5dQmjR1y1Sm/yxicDcZRViSTn6F1rjSQfoaL
	 ko5jjEY2x6Jb71aq5JgDMKVJ3mUVi0/jRZik0EAA=
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
Subject: [PATCH AUTOSEL 5.0 011/173] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:16:43 -0400
Message-Id: <20190601131934.25053-11-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131934.25053-1-sashal@kernel.org>
References: <20190601131934.25053-1-sashal@kernel.org>
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
index c161069bfdbc9..3880deb5f8a4c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1257,12 +1257,23 @@ void free_huge_page(struct page *page)
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

