Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFE0DC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:17:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0EC7206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:17:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="spp6+pbv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0EC7206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3145E8E000C; Wed, 31 Jul 2019 13:17:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24FBE8E0001; Wed, 31 Jul 2019 13:17:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 052508E000C; Wed, 31 Jul 2019 13:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8E798E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:17:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so37938170pgl.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:17:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=KaVjUWTTnVdkOk2Zg6cPSfY2fDbbbTfB5zwO5s7DZ4s=;
        b=UqhWI1+siZdhamq8KKJMxvQdyuGOp+KAan7TdmDYjrDR8m3o2GDL5mRFsOlVlRj1vg
         pawQbqYfJdSJ0jAU4yrGlSCR2v8Q7A7Fwyautf+93SUfuUMCnpX/1n4ODwCZhFJEYwIs
         9atRqJPWfkteGycD1PKbL9VHeGUiBtw608FnEtsP4HxFymSIh6QHUkeDM94ENufPfZx1
         gWbYS+FYr4Dww9L/JUj6gN8R8JtsX4yCyKfUROA5vyr1g161f7yFtAdDZ6ryLFFyOPDJ
         Mks3u4zpUAFKGm3Q/J0FCBgE8hk8gGF6uRjkLYFuMjgtt4Y9oPRJ/9mTsW5KS9yUSvVb
         Yq3Q==
X-Gm-Message-State: APjAAAWPBBbS2lESYuiQ11vS2MzalZ2gePAj+g6ftgKyYGXYp3OURTGz
	VHzrJ4Br0v5zchXJ/i3IrAoTJoq0CbXkN75y1tSqDh4ZZR5qVARX+74NqCHMAphYF/7uo3RgsQp
	esPBAP03e1haCcF5sgGDK/xBMRGCrocWS67uhPl9e37ZhIC+SiM3PzOFVjG31yak2zQ==
X-Received: by 2002:a17:902:2889:: with SMTP id f9mr115159915plb.230.1564593463523;
        Wed, 31 Jul 2019 10:17:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyENYNutJp2BR9ufuoRHOPMAXBTKzJtDpXtDc0MBzxO25Dp4pb7mH+Ie0ZYwmHGYlibWKHc
X-Received: by 2002:a17:902:2889:: with SMTP id f9mr115159873plb.230.1564593462902;
        Wed, 31 Jul 2019 10:17:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564593462; cv=none;
        d=google.com; s=arc-20160816;
        b=LKOpFrgG58t8vcaLfzpgicYDacIHHb6BldllGJRusZaDvNkCC+6U2TADPjiQPDG2UE
         igpvdSkNKgB59RthHUzB/laN/+my6p49t7SScGb9NDMJNIxrlCCPFHUJdsJI3KeDjDYy
         3EPDp4g8pbEgBPcjHYLtJPT8zmhH2Hs4B9caFgBMqvLkuIFdL0mKnDdDrhjN7Z26bzSn
         tp3oaw/P0XGo4u2VMMn28StLfuD+aJpo3SFnQh86oF3ydg4nZDdirNefjb6SnFpcpR3P
         6Czfw0knoigFYRaenojHi8aKHcjNWv3ezyzT+5HBbU2KWotV1X8NoplnxtP/uivni5Ek
         Df1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=KaVjUWTTnVdkOk2Zg6cPSfY2fDbbbTfB5zwO5s7DZ4s=;
        b=I4x7iv7pugs75WNfodAE3vEX5fpTWEI1YyESdIFey/L1hyhPVuIsNTOFF1W7q/5MBG
         0unSxNunn9nqz+argjcvztUMy+6dG+lkU6LG4jibDjxR1FFMg1TMsMqBEjFEURfguR8r
         4WTazyDLz4g45S5XBN9a9tz5r26/sjs634dwmMcL8nCnrOEfqwyFloleQ2smv8jfnjWg
         lPmmc931s5fO3drxowjGH3JngplmoXI7LkfYtslv5VD8c/gaEyQu4Oryt+RoWcSsCmPn
         F/0IgQ9+wCqWqcHVNUI5XrH1IixVu322N9PwHUxdQVypb8B1CMQIJpA6bhq5dFLhKHKt
         LYew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=spp6+pbv;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l14si31716292pgh.205.2019.07.31.10.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 10:17:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=spp6+pbv;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=KaVjUWTTnVdkOk2Zg6cPSfY2fDbbbTfB5zwO5s7DZ4s=; b=spp6+pbvnz834aJ0eeqzIUdla
	6LkY/AxjVqEWXayDIBWYlkJMgNSdt8GGK3rcxtNCitA6xWOhQsfebCrSWviHjrF9WT2yQgOZzfxEN
	/VKiqn3cvhV6zchKXV0AO6jV4GTZIikIdS8L54ILQ3TkmpR8Prsx3pr+bR8P0VArNZQhNeY7mWwaF
	H61ldCoLvU+v3nRQsoxInhNY1zeca5psJ+wB0sfPo7cVM7BCdp0N1BCDaBNrQY/kF4+w/+l4oMxjP
	kHtMmn3rj60gliJ5IDfuWCVEQJ6x3TB1p7rm7jWJilqYIVXrP1O4p/uz+qQesKUUQRHV9p57NcO4a
	idSPZw8lg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hssEN-0005dG-3z; Wed, 31 Jul 2019 17:17:39 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RFC 0/2] iomap & xfs support for large pages
Date: Wed, 31 Jul 2019 10:17:32 -0700
Message-Id: <20190731171734.21601-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Christoph sent me a patch a few months ago called "XFS THP wip".
I've redone it based on current linus tree, plus the page_size() /
compound_nr() / page_shift() patches currently found in -mm.  I fixed
the logic bugs that I noticed in his patch and may have introduced some
of my own.  I have only compile tested this code.

Matthew Wilcox (Oracle) (2):
  iomap: Support large pages
  xfs: Support large pages

 fs/iomap/buffered-io.c | 82 ++++++++++++++++++++++++++----------------
 fs/xfs/xfs_aops.c      | 37 +++++++++----------
 include/linux/iomap.h  |  2 +-
 3 files changed, 72 insertions(+), 49 deletions(-)

-- 
2.20.1

