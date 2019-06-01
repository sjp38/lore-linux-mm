Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34D4EC28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB46827378
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="t6wU7aRd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB46827378
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 394576B02AC; Sat,  1 Jun 2019 09:24:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D0C36B02AE; Sat,  1 Jun 2019 09:24:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121EE6B02AF; Sat,  1 Jun 2019 09:24:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C14716B02AC
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:19 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f9so9634052pfn.6
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X0qCunRTk5Z3hKyFYOEn1a/dpGkM82H2Ghje9aS25VA=;
        b=oDSyzEPmt0VvS+nU6smWYt8xFFMxebkekfljZYsxQjIJW/GRps3tmmiwxMhOjA2x8g
         EApS7VCKVngpcCJwUHDkwKpup8gWH10KOXsniz9CWogU4P/AcyBKj9yPT+AvlXda8pla
         YTgzwq5wfZryErf9rgdo9z92UZZyZNrYlbdVO3jkTR3/Vuaaqs6dKLhwskt80+08MaMF
         CRPgkC7R94Xtbrx8pytQQI/OFl6z4iyiwmdIewF2giSO2UJCxnPaJu6V0/suj6gv3BnC
         uQf9/2pk6vL8ygOb5r+7PNEdb7SIL2Vrfh6IoLXQtL6NhVNmnIQ2Ozwe5b9biE3asa/a
         9sHg==
X-Gm-Message-State: APjAAAUKplHB1Tds3I9R7YDLBRs1OXW3J1FClK7XsxkFtKWCzSGLCtQ3
	ay8dFakp2iD9RbWQZWbGA3PqZ3CYZjLAEcLw4MJE3bue+GeJ5JfUGL8O7qFkMvt8L7KvM+MxO3o
	pbEqmGVQKJPUGtvT1Kfo6cKc7UNTJiQrLesRW+euvaTZ2TWf7hGUm9zfJh0B+IpPx2g==
X-Received: by 2002:a17:902:1126:: with SMTP id d35mr16493916pla.82.1559395459462;
        Sat, 01 Jun 2019 06:24:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyURRqbuxXZj/2DSFHpSicY6FfBEYhlr2r7m6eE/jB9WHsyZn2RxZkBHtrHRjkL/vhn00Jc
X-Received: by 2002:a17:902:1126:: with SMTP id d35mr16493854pla.82.1559395458874;
        Sat, 01 Jun 2019 06:24:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395458; cv=none;
        d=google.com; s=arc-20160816;
        b=ZXzIX3rElbaKa2uhx8+Ufp/0oA/fiiSajrTBd908lJaZIZIZcfxDNvO9v99W82+W8G
         w+Z0CFS00f2w/eg7d5fqvtj9Y4IL1qtw1muwfsQLdi+NVV7v7H0gXiv1xPnWZApp1r8u
         fupXlfJOV0OY/W0z7X2UikjOEzzjmQqJzFnE76o7MEbarfgqoTdhOBa2NO8czFimjvBn
         4SiNgk1QDmT4VmWFg5FViyg2gBn02ZOJqsn0RLS2o7hOu0svqtdP6baZy1OCuxMpSERa
         ILGDmACwFSexkScB3x3AgAbrlqQ70mP1G7W7E2Xh3lqKOgnhymWQI3kkrkvetghekELF
         oO3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=X0qCunRTk5Z3hKyFYOEn1a/dpGkM82H2Ghje9aS25VA=;
        b=LH+obIhvMrL8hawEnhI5o9AF0WUibfa4WsUeUOG0ojFBgYZnbTtEedlI16hIihnell
         zjHzpvfzD95iZ8TR0F1apZgBH2KFm2RUG6e0br3oc3/alaJnxWh0HiHus7S9UCupOVnW
         ToiFMYE5B+L0P5Rr+5NkEZ3DFBrVdq8PtyGaUNFbrlGAy9KKrdOzn0OawwShzmDxJ2Z+
         bsHn9P7KDl2CU61i1WHjNITm24kBlfDFkzAKMCrzBuLHfCpPEWwwEPBGUWM0S8u43fRp
         8h7b6F4gcUA3GvMdIB37vHHsT+IFZJLqgZqHNvFxbyOrp/P1FlzF9ycWe9Hx8T5kunKa
         ej9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=t6wU7aRd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n2si5562461pgq.129.2019.06.01.06.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=t6wU7aRd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 61ECB27358;
	Sat,  1 Jun 2019 13:24:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395458;
	bh=khdRBGEtI4IRSX0deEmUgTpUYXoqbn3SdHYvyHZ05aU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=t6wU7aRdzc61UPq4vhQJTuqrwuvxlgXeBsb3qoK/RqMZB/6SpFlTFm5NwzG/xZt1m
	 iuTfeSmh0tb6A53kNCNpkr5k9GHXI1Qp82qgGz04/0xcQTMeH9x5oDFHAQLO6LmI2Z
	 8HTkjOkxANIhlrBKSTsrHMtmUswSm9Tpo2ouQDUE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	Dmitry Safonov <d.safonov@partner.samsung.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 11/99] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:22:18 -0400
Message-Id: <20190601132346.26558-11-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132346.26558-1-sashal@kernel.org>
References: <20190601132346.26558-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit f0fd50504a54f5548eb666dc16ddf8394e44e4b7 ]

If not find zero bit in find_next_zero_bit(), it will return the size
parameter passed in, so the start bit should be compared with bitmap_maxno
rather than cma->count.  Although getting maxchunk is working fine due to
zero value of order_per_bit currently, the operation will be stuck if
order_per_bit is set as non-zero.

Link: http://lkml.kernel.org/r/20190319092734.276-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Joe Perches <joe@perches.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma_debug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 275df8b5b22e7..c47ea3cfee791 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -58,7 +58,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
 	mutex_lock(&cma->lock);
 	for (;;) {
 		start = find_next_zero_bit(cma->bitmap, bitmap_maxno, end);
-		if (start >= cma->count)
+		if (start >= bitmap_maxno)
 			break;
 		end = find_next_bit(cma->bitmap, bitmap_maxno, start);
 		maxchunk = max(end - start, maxchunk);
-- 
2.20.1

