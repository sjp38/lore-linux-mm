Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3827C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E1B121537
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EVMKiUDv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E1B121537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 213B66B000A; Fri, 26 Apr 2019 21:43:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C2B66B000C; Fri, 26 Apr 2019 21:43:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B28A6B000D; Fri, 26 Apr 2019 21:43:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8D8C6B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:43:55 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 33so3153059pgv.17
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:43:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q1QhSrhbtls56sYhZj8eg0Qyev1Vd4R+ik6+AkXIUI8=;
        b=i7OifdIULqrBpWT+PBtq1FGR6mYfRYqQaUn9T3TpBs5G19iB9dd2iQ4xwazaVaDK7Q
         3QamIBdV0CcLU0DDp5RtLCIQoX2KnpH2g1La7p+oc/CYaiEWS3rSdxBSL2UqzfpAbmJZ
         LL5b0+TEDiM22Y/UnohOfWz6fAm0eLGJDNDPKjL3RIw4uHngRGRUNZHfxZZ4mfh++xe4
         dcAxyfDfFgHkizFZHI7xFc3uBlpnEYZes0KDFFM/iKny/XGvpK4W3z7SPlW81IVKdd0J
         KfryYxgxAzlw5Rwnw9Pc9Cge4g/YbCMpdb78dusPUidiskK1X71/p4rLVN4ihCaame5f
         Of8w==
X-Gm-Message-State: APjAAAVko5UftBZRZ8b//Zn/P9wL920/0eWE56uMF/dZf/GW9V3p8sUt
	UevsSOVjHpoJLHR75DUDqbB+/fGecd3Jp4aou7W2EKV03UMgXpuc5O9v7LOSHJ7IgdDvEi3hhCp
	QeeKSIlEgkHEaeSivrHbPf1nkrquMqV6rFaXtOAeSHh1l/rfMBavSHwPgyaoGbWJfRQ==
X-Received: by 2002:a62:2603:: with SMTP id m3mr11512261pfm.232.1556329435473;
        Fri, 26 Apr 2019 18:43:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwE3LiXK5d4r0xaKRZXNgW4M3Pm5nd0lAC86Aon737y08H8VrGuleFBlKeREYmDYWeP4n1
X-Received: by 2002:a62:2603:: with SMTP id m3mr11512223pfm.232.1556329434776;
        Fri, 26 Apr 2019 18:43:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329434; cv=none;
        d=google.com; s=arc-20160816;
        b=rTsyp6QjHRG4cdHBi+SHAhH+h0R97ZF0l7SOF+a43Eqhm9d8A99Pt96iPQ79O0ouEE
         h0BRZIC/iNbEz/l2pH+xI75wnTCi2m/taZZY7Keo8s/wmWj9wy+eFLGgBfJiRZFCnTpT
         Ab0wq5XUePaWgDvP0S6x3VCWDralQSd51so5f/iwK/u/z3FJuufnnN0/atscJXgWLS+K
         7nkhTkYlOFyTog0s9zBACV0Zw//F8OyxydochsRLiGgQpy+88tNF83zGAx1w4LjNnNh2
         W3BbRRnKC0qAx8KGlCRMcm3Y9h08qmUDkVGrRN01eZPqDW15L/2U+CzRFfUQO04xl5cL
         wKCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=q1QhSrhbtls56sYhZj8eg0Qyev1Vd4R+ik6+AkXIUI8=;
        b=maNDHx1fMBS0MRFudi/V2XLJupEtp1WQ8MnGiuN78B/mN8k5bQwtn777YX82AWcG3q
         cw2ocJLn7Ep4ka8SteOzN1wD4nJ0DPSR6NQRxUcJpwg7tf0qjHDUNNohrOVLFyGyApn6
         JCG6JDsExcjRDiQVMAw7tEj6kzyPewWFv2rSUjGmEpXdIseADZs6OPhoK5zEb1hI1Cwb
         7IflpBZ+FrIHSzSHce/mFy0zGJ0e/Wh8O3XSEPwmN+qjqULczgSAgwlYbWhp89Nk893w
         OQ3avXDtK+/JcwACRUIix7ZxyRaedI3p3tQklLSu2u87w47AZNH3Yk1p60a2oxMzcTgN
         qtZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EVMKiUDv;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b3si28402473plc.236.2019.04.26.18.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:43:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EVMKiUDv;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A76A0215EA;
	Sat, 27 Apr 2019 01:43:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329434;
	bh=HB86TdKubOitt8MMA3LIoAod3tgHlFxwZHUSCaArdFo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=EVMKiUDvl5OH5gWiLrtx1OkqvcgRfFFjm6HMQouc8UHw5ZXOMrsCEHcB0cKCojL7y
	 xGQeKTPuO3tu7r4UHZbAIP/ElUOeJLs66S6BonpZOtHySNLmLHlMoO+i0+K+uRf12c
	 2sBLqc5MOJyPLoYe8L+ouW0SocaIwcPQN7qZO0Es=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 16/16] mm: add 'try_get_page()' helper function
Date: Fri, 26 Apr 2019 21:43:24 -0400
Message-Id: <20190427014325.8704-16-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014325.8704-1-sashal@kernel.org>
References: <20190427014325.8704-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

[ Upstream commit 88b1a17dfc3ed7728316478fae0f5ad508f50397 ]

This is the same as the traditional 'get_page()' function, but instead
of unconditionally incrementing the reference count of the page, it only
does so if the count was "safe".  It returns whether the reference count
was incremented (and is marked __must_check, since the caller obviously
has to be aware of it).

Also like 'get_page()', you can't use this function unless you already
had a reference to the page.  The intent is that you can use this
exactly like get_page(), but in situations where you want to limit the
maximum reference count.

The code currently does an unconditional WARN_ON_ONCE() if we ever hit
the reference count issues (either zero or negative), as a notification
that the conditional non-increment actually happened.

NOTE! The count access for the "safety" check is inherently racy, but
that doesn't matter since the buffer we use is basically half the range
of the reference count (ie we look at the sign of the count).

Acked-by: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: stable@kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/mm.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 11a5a46ce72b..e3c8d40a18b5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -777,6 +777,15 @@ static inline void get_page(struct page *page)
 		get_zone_device_page(page);
 }
 
+static inline __must_check bool try_get_page(struct page *page)
+{
+	page = compound_head(page);
+	if (WARN_ON_ONCE(page_ref_count(page) <= 0))
+		return false;
+	page_ref_inc(page);
+	return true;
+}
+
 static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
-- 
2.19.1

