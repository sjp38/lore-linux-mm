Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33971C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E72632737A
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:25:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="l6r+31vs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E72632737A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 911CD6B02B2; Sat,  1 Jun 2019 09:25:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C9556B02B4; Sat,  1 Jun 2019 09:25:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78A376B02B5; Sat,  1 Jun 2019 09:25:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41D906B02B2
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:25:19 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d19so8262978pls.1
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vLPTCQQrDhuHf+GHDOBloKl1uofMgSWCdUAMsl81gzc=;
        b=Sc7/XOlkHzJsDE5H9UH495JVOjf5hKoatAjliTc66bxwnYxngR8J+JSV5Jkj/C3E5f
         fL37Rj5C+r7rCAfjGBKKMyxMpG3otsAcSj67Rc3ofv/Xrprm9TKKlnxlf+WXsTyogXqH
         eD9Po2hWJO+FWuJLXaEnfrRGhAaFQfVC8P6PZ5zpLYAwWSlUmZV0LmOf76p4Cdr/lNna
         1mgyrmUd+L1yfMgl7irSdMJmM29l+LwnsJA0A61EY0hgWcbUqc+VaAmJL8Mu+B3K0HEl
         nxHXJEeQmsFA0dieGkZG/hFkRCZUgf/IVqnZsjXFrPEO8LYZNlXskckx1TXXm0uQX5TO
         G4iA==
X-Gm-Message-State: APjAAAUmoaT1E5WZol4WR9L5m+vdcKBDaR8gGeVYriVIJ1XPJBL4zuIa
	5slKDm+urR+pWIZ5nXFzcholnAXwmrDO9IJGMHq8CfNBpo7vftkudMXkuJ+E1jZzjE9+970tAd8
	gLahJZFkvihJKO+/MK+GpiunlTyg7oQLZbIyU/NaE5I5J4B29iO395wratNPIfVY/BQ==
X-Received: by 2002:a17:902:7618:: with SMTP id k24mr16597778pll.78.1559395518890;
        Sat, 01 Jun 2019 06:25:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYkIeJCe5/42Wh/wsY6zC61OiYGWifvUIu2KueUTgv+8v8p2ubZHZHxryj2FZ5HMw13YEw
X-Received: by 2002:a17:902:7618:: with SMTP id k24mr16597710pll.78.1559395518213;
        Sat, 01 Jun 2019 06:25:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395518; cv=none;
        d=google.com; s=arc-20160816;
        b=ZFY1WxCP6/S/3dNQ0yP8ZkAdQx4hamBW6dKTwd7aRseArkT8BVNpczBofm/XsEWAtw
         OwqubVEkMQAO86i6Fh/7D73L8Xko/M8waTZGjmGBfjsALvCye7r5SWWT8PoxmPbcYqTW
         d3YwnBqDbFd0AMI6g5p1NutKyg+ODoj+jINNzg2sx0cz5MpEvfvosmkfzaMqnXAuGXSF
         WVbs3/0oojiYCproi1bkDk+Obh2/hMtd7qXrUrml8nij9MQOq+PXTqGIOv0HAuTW9VZt
         +0R361oFr23ic1bDBFUUc1ga5hF1NXz5Mc6miwfEeKc7J5e1oXjuCRDGYUY6fubqWXlk
         hp5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=vLPTCQQrDhuHf+GHDOBloKl1uofMgSWCdUAMsl81gzc=;
        b=IGMkdndTTxx7REvIbJBtOCbLPIF4HU1FRKkBam9XxpKwx6zG9Vf3hbpo2bbd4rfrxQ
         3pP/pe9lEZwuIsn620nV6JSLflc+9GfzaeySMtZ2JLrdy/xFLRnOmgdpvzJtaPWWXMUy
         kFG48wWRbMBUObRUeDGZmNRbZDhqt570T6wnwcPtXGHkorAJBSiPUMN3hjMn0Gh2Rn4O
         josb+YfpY9tIwtezA/zpEa/iJtrf4qqfdPYX3eEEp2rSSR6oqST1vQ176eTaYDD10VdH
         P9MfO8jG6qY/ZWd4mP3DV9Z8IoG63O2ca0VGFOB5isUv8djtJJpDiEFmk0aE3E5kNn55
         JnwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l6r+31vs;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q29si4865256pfg.28.2019.06.01.06.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:25:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=l6r+31vs;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AD4512739B;
	Sat,  1 Jun 2019 13:25:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395517;
	bh=yaP2hH6CpFvO7MSIngyl9hWVZPMdRMnYHGCQ+0vGdPE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=l6r+31vsTtPoxXz+ZE2x/6JyaHv8CWtW63wMRyBuvvYyRJJy2KdYZsu25qOQ9Zw7g
	 uJbWDuyqdTKSYQZXhXsgTjiow8VbC3G3LgKkLTkuqtMLxHm8DFAPiAu+tG8DDh+x2b
	 +74Y9F6kIOqfoqh0YeQzTrmH9vpnO1xaOBhYqIDY=
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
Subject: [PATCH AUTOSEL 4.9 06/74] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:23:53 -0400
Message-Id: <20190601132501.27021-6-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132501.27021-1-sashal@kernel.org>
References: <20190601132501.27021-1-sashal@kernel.org>
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
index 8b682da98d95b..6d40bd1759cf2 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1247,12 +1247,23 @@ void free_huge_page(struct page *page)
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

