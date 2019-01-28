Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4389CC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:10:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02A1721738
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:10:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="FC+tjslz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02A1721738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76CD08E0007; Mon, 28 Jan 2019 11:10:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71D578E0001; Mon, 28 Jan 2019 11:10:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4188E0007; Mon, 28 Jan 2019 11:10:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF6D8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:10:45 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so11817558pgc.20
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:10:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9tWbXjPx+ylNQqVYDh1Ju/QGShmOIh48UEWicfqbXlc=;
        b=udf6VO1kFtSEpz1xInrWotUO3W1BTkXKYBZh/1tgyrk6QO7vQdP5jSmlV2aHniJkLK
         4Om7psynkPpaM+K9Nxi4lmOJlTsKUkQeaBAcZ6BFP15RU84jBND9UjF3bDB81NK2MRfq
         ryfVsfzis7VWLBITWc9NcqvDixvfHdt7QD9I9B9/M0HDKG/W6pezKgFGCDp8QqcrY9Xs
         RTN3s7lul4bfb5ckwdymcFgOIKDe16cPxNCVTf9pZJCePIB/wWMxiP0q6qIlj9pYtP22
         SwHfcSo8epruk6eDxv/2q/1DDuwSvgC8eVXyyieVptHwfo/NN66C2U49wCLs6BEBbd/X
         J75w==
X-Gm-Message-State: AJcUukeITAzZtgW4i5hpS7ecIjNUmlnVPWUB1I0uaTZsPhsrhgLyhwQ0
	jpl2DIKuOjijREtTIURYNVURLkB+oOY8DgXS/x76xlv+xiV1e/PQI41Lp4w//BfdEKT2H/H7fTt
	ZKvdFHuCLyEyP2y2gOtD1mZFZSkS35w7CNsc4sS2hy/ByIyX0b4gf8dEdQvFY2JkA0A==
X-Received: by 2002:a65:514c:: with SMTP id g12mr20252748pgq.169.1548691844701;
        Mon, 28 Jan 2019 08:10:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5K0JwwR0or2Rgab1cnQTMPhgIda8DWjxhEIhqOky5SqJHVBLfHqTiQ0i/sqQnhYWfSczqW
X-Received: by 2002:a65:514c:: with SMTP id g12mr20252719pgq.169.1548691844099;
        Mon, 28 Jan 2019 08:10:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548691844; cv=none;
        d=google.com; s=arc-20160816;
        b=fdSGYsFTsTYtiIlUfq1c09UYAORHRm3qUzMmj1mEFBreuaRITgYZmOqr5tQy+oWJ4+
         NGQVNoafqqVwFd0DzoyH8zAMOgFeCH6unuiVnHUN4pb1lDXa+p6K8zbowLs1cVudVegE
         4kC3AXmRx8YiJUFhbxcM8QmU0RZW5pULcSjOCERVhvMgAp9CEY7BkgI6sFLKAkNZVToO
         1oJKcp0VNYXxH7Gr66EkOzhNRDWxrnup4/KlSgQEF/zDLGXERS5d1EFLlUmkmrT3Mybp
         KY+Ng0ayvTQSE0FnUZAmivgQ+3ul298oSMG5dMBX2mQusRpq4+el5WbBmasyYHCoQR2c
         ffcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=9tWbXjPx+ylNQqVYDh1Ju/QGShmOIh48UEWicfqbXlc=;
        b=pCAnM/ASjNiWq/pQc56GnR4wKSJJCzppfstUL857D4FuwLoT4r4YciA4hp0Asv45BX
         LX1SYcAAwZW+bsCI0awAQ3oX6uDb0t5CTdF+Uu+vZyInLMTLvbmooY73e1PpD1F5x4q5
         Y0Uz7qgb0x2O9dMFy6EdTCfguGylgeNiy0tzqprCzK5nX+QEsFcH4xQEIlMprQxxpGV2
         8wvUbnFu434GgMPg4qvIORiPpmrCDPWoB454/fruDPEtZaQwxGcgL0FUdWLUgH75CiVa
         wJpZ2Fn7WDuhfc5EP8ab0rYCy08gTgVbhTeaAwBB/IdFTsbV5UhH5iGclZCW+HvAct43
         TKEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FC+tjslz;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n3si18267438pgk.405.2019.01.28.08.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:10:44 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=FC+tjslz;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8DF8A2084A;
	Mon, 28 Jan 2019 16:10:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548691843;
	bh=iMPET4x1Ri3FMmeFZ87YAw+rJQU9OwKtkcfiyE1nWo8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=FC+tjslzyI5EGb9RLk2BMcsJ16icWWiZPVjxrPaypOhQUTQEQD8FCx7QeLTnqmhi4
	 T4RD5T+kKtrclpPuoFGhSOmlRYGHh90nG1A+dQVvknFB4RO7Uyi2G1nTdhQnuu/lS4
	 nKHAcgeU4lMQH1K0WqMqpWDiWI1FIh/BYXKUD80Y=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Miles Chen <miles.chen@mediatek.com>,
	Joe Perches <joe@perches.com>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 235/258] mm/page_owner: clamp read count to PAGE_SIZE
Date: Mon, 28 Jan 2019 10:59:01 -0500
Message-Id: <20190128155924.51521-235-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128155924.51521-1-sashal@kernel.org>
References: <20190128155924.51521-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190128155901.ldFAbGdyX-I2-oraKjLUmkDMgIARvpwUkUrmPgSsTSA@z>

From: Miles Chen <miles.chen@mediatek.com>

[ Upstream commit c8f61cfc871fadfb73ad3eacd64fda457279e911 ]

The (root-only) page owner read might allocate a large size of memory with
a large read count.  Allocation fails can easily occur when doing high
order allocations.

Clamp buffer size to PAGE_SIZE to avoid arbitrary size allocation
and avoid allocation fails due to high order allocation.

[akpm@linux-foundation.org: use min_t()]
Link: http://lkml.kernel.org/r/1541091607-27402-1-git-send-email-miles.chen@mediatek.com
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/page_owner.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index d80adfe702d3..9ad588444671 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -351,6 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
+	count = min_t(size_t, count, PAGE_SIZE);
 	kbuf = kmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
-- 
2.19.1

