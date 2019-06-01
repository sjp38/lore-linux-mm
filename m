Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80778C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B7DA273C4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Iq00m0vD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B7DA273C4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D647E6B02BC; Sat,  1 Jun 2019 09:26:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDFDD6B02BE; Sat,  1 Jun 2019 09:26:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA8316B02BF; Sat,  1 Jun 2019 09:26:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 800926B02BC
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:26:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so6562087pgo.14
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:26:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zrFojBGxOCbHE/MGRRox7g27NCe5aG01jBEKz2hdAoA=;
        b=DaqO3Hxr9Hdx/vKR1U7IJIHXZVaObyfff6M18hxAE50snFPlWsGhxTUMPGxQEN+XpC
         VKgMJ5ydR+789t+krVVudk5Dnn21XhIOEaQgel7G9dIXefxjuUnq4bOfcPMAZj/qawGM
         8MyCgEKq/FUMX/lVT13dfrDgjNJP0z9oyaHZ/Z+E8iamT4VbTsvIcD8+kRQG+6ZXpLQq
         spmipRDcZAijk6SbRKyvMQBCpsRgXYA0JSSiS4B0l7JpN8na4JTuDDvXbpiMCiB2c9ai
         HkLuaIpqKOitxzeTx7UmNTwHa3muatJZrOc3pKIHuhxvtIisieHnLvCBUt5MlijJPUM8
         nxIQ==
X-Gm-Message-State: APjAAAUcNQxWsTXfvmoWQYLj1oeMGS2xtqeOSdNgVjJNvFKR+RRHnsdt
	0V8V4scu0Z/H7YrO+00VKDShdnwTDKWFxUYVdQqMoCRYmhz4EKInmHHJu5YtjMBy1qCZTkg3NMP
	ySJ+hhQl6abhdX5SwwNLglUhl7gPbF3a9kfwS9tVWW8d4iANtEdTSMoo37wCPZboyZQ==
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr16414635ple.45.1559395571182;
        Sat, 01 Jun 2019 06:26:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlOZnNNlZDzBnwHJdmP5mKJsuXUFfz/D4YjcqpJA7G0yeOs2XQECZt43dnV7fqsvU7NVsR
X-Received: by 2002:a17:902:1347:: with SMTP id r7mr16414564ple.45.1559395570594;
        Sat, 01 Jun 2019 06:26:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395570; cv=none;
        d=google.com; s=arc-20160816;
        b=EvwoR8P/P/zRD/Tz7wEPM6iNUlUXNacmfKRfyH6vTld6a9ep0vOr98OWEYFxRncf14
         jK1XWNirwdEu8gF9Gr4d99MWQIhAEBj9o3mDg4CwjHRB/HJ1p0rCycelESHvwN0F+gmn
         uXIN95nfMgbdAqoWdwrTw6fXAHqrDQZH/PYIBbcBhc6BEvTtBT+AJjMrVwtHmy8nOCwI
         msUpDdNGGF4/cOR+fkLrjbEiC+qBFebr5mDjqX9lOnT040C38imAMgBGutFrV8fefsm1
         szFPcEHDLO7pEF9rIMYCBuNoU84mZ5JoS2bYdYGoCqLhgqlpnSMUTzD8QAWn5NbyQfOK
         sqew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zrFojBGxOCbHE/MGRRox7g27NCe5aG01jBEKz2hdAoA=;
        b=VvhCF1Zc76fjTEc7zoQ5e48TUFw1fxHxR4g7oVNv21ZpJn093axaZt62K81gBogThX
         AkgHsYZiE9aK0tCo/Krkdab9NoEBqnXfg/NgWDgnARNmnMEZ/KfSaoLQcLMcA0LiqTos
         uOhmoPndvxh1CBYoHKwi94ryEdpk+rK672pR94P+dguxlTw8dUXL7JbO9iHcJxHfsmH/
         Pe/VCsdyo79ykW/W0eske0B9+wWwIbFlHEZ87iodJQiLgWl43KbEaYyh8ZKsCvlOl1Zk
         Uh3bQ3qg0HASQczBTkKZvzQxrEdZqHHo4XZCMmsQX2iklc8yRaa+bHaHw5OdyOwMxPPL
         +eew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Iq00m0vD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g23si11152734pfi.153.2019.06.01.06.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:26:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Iq00m0vD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 19FF72739A;
	Sat,  1 Jun 2019 13:26:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395570;
	bh=me0jHZ4okS1/tGNFwIDuP/a8uqOaFJTeahlh8eX/lQo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Iq00m0vDFEnvXuJMWFm6+xE3RS7cMzVSIqdSkYfn3WFT70VcOXdbErjh/U7Qabqc0
	 d8h7pxH5Yf0sjlu2IZqyaRX6u5+4L2MQOJPqyrWViLUWiwYiHZDemMYfQmrnKK8Bgz
	 rbpxqJ3tc7ILnG4npup7DTERmlBFDVm5rXJ1qYwM=
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
Subject: [PATCH AUTOSEL 4.4 04/56] hugetlbfs: on restore reserve error path retain subpool reservation
Date: Sat,  1 Jun 2019 09:25:08 -0400
Message-Id: <20190601132600.27427-4-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132600.27427-1-sashal@kernel.org>
References: <20190601132600.27427-1-sashal@kernel.org>
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
index 324b2953e57e9..0357ad53af368 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1221,12 +1221,23 @@ void free_huge_page(struct page *page)
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

