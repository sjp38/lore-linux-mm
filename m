Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CC90C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BD4F273CA
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:26:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qm01W1DE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BD4F273CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D3C6B02C0; Sat,  1 Jun 2019 09:26:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A95936B02C2; Sat,  1 Jun 2019 09:26:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960E36B02C3; Sat,  1 Jun 2019 09:26:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF006B02C0
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:26:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 61so8222528plr.21
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:26:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wvRNJqh7r6tQHZDAM384f5hhC5mXuxiJjJH1rckLOuA=;
        b=HJSo5NrsivENmnAPYOK/vbh4cCM43qH41rwYVzOD9AfhDyu2BsJy93Hg/Wock7HbUO
         2HpUn/6s9mOuPCqaMT3RmiYZCkplk1hBaI1MmKMBbRKIeNlM3XBUGVufG37SZYmh5KiA
         iy8Ai9bJ2pEU1eH0x/ufTg6JNqYapsnPRkwsuQgWS0NuiX8qLQ3Ek0+qwERXEXiL6lED
         KLwYP3UXn3SppsZBJ+mx1qZEgkfBx8acWCEoQqtRFIHArn8EA8LomnxA8W3T7gC9u34D
         /IX8tb50TnN8YY+I8PicAFVxFCiMhrmtvVkeT5AoUh2iqZqKJ/inZQ/8RHm9DVzGZIqn
         V6NA==
X-Gm-Message-State: APjAAAXJ5dmzOdxVzHI7FWl4ohdlmjwy5/NMcNProkaLkA/lUaRgC+Qc
	OE/BFVpsCWD4ZvmCL7OuqWvNajc9IsQZoX7cm6bYiKzjFq0b4kr2eDIVo5hY09aJHylRPRPcW3S
	HfVAc3C9Df2RTqd5up3i0SVl5PAENJbONELtuzlJDPQXTk2+IuBBKn/MyjHhMJr4x+Q==
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr16227407pla.101.1559395577049;
        Sat, 01 Jun 2019 06:26:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoPB+Dl7ZI4YvtTuRmsFDhqLRHdSfROvax3Tt9kjlnRWuGh9gW9NcJuoAlBk7XvXUKhETj
X-Received: by 2002:a17:902:1125:: with SMTP id d34mr16227347pla.101.1559395576500;
        Sat, 01 Jun 2019 06:26:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395576; cv=none;
        d=google.com; s=arc-20160816;
        b=oJDy4fF4KyQAiSget6UqPmNoejzkL4GMEE48m8QM+LhAlPtRH/McwdehM/NN8JxupC
         6Im7lgWj53asClaJYfNsLkXa+rH68KcGejLPj6sM1aGR1tuHaHGRmVB3HfXSAlh/0nnv
         5M+Z7MkqRNx8pw6eDxQiNsT9mqp0f186y/9yOUUJmCpGdcCSj/8uI3RxGNzr8y0ROt2K
         Gc8Cou504TQ7ZrdzuBFKfAAXHBsvyj2oKiODa+VZghsg1gxBcFuaAi6DL+zmCgeG1kh/
         ee3GW2mmYWZRMPFOwzgAR7VIkgdCzZzFIHttsrhhV0xYLTw0IFyTUZ/dnLDsg1lG5dNb
         ahSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wvRNJqh7r6tQHZDAM384f5hhC5mXuxiJjJH1rckLOuA=;
        b=uefkcEdg3TT+nroft75V9qUd0vOyvWCwxdAwiWqPZsz7h0Lb38WniMJrN8JJNSFtXH
         EaZJQeha9YFGF27Rkzt4dLdIU1BMe6vNeODnyJxtiCtNUTSfTuAIgnz05hExS54CP1Su
         xt4Ook2Q2BI4GZE6Dso9GMif8MWG5ow4+FO0zy6RvikLHvNNqDHpotkVbHIGykcmlhvP
         eql44Yptu2obTyrXXrH7eWYhD+agcZkYusylfbBjfLKgTf/pdtvi5Nhs1UTNWcz5QG5h
         YHJD0j2zbHI7+qOUOt5LKGbz8U/s7oybX7He8vFyIqisEQKU0snLSjXA5UXI01sce2c1
         MhGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qm01W1DE;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o61si11037000pld.82.2019.06.01.06.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:26:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qm01W1DE;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E0375273B8;
	Sat,  1 Jun 2019 13:26:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395576;
	bh=W+mXVN4o7qdgu7foKIesICoUXtgOLDULDim6bbYHyBQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=qm01W1DEWjd/oBg3hjfXX+xFRoN+IvPJvvfCu3to2bTN8Ccmpj/BMLe7AORBjxlq+
	 nNHG5KKUMdzM6PdTHzMJSZNcJjD44PbgYzEBEV23jOW/qJEN6FWy6AE7bpI3xxFQ/t
	 QIappIyfV/FlnPYKlbFOA468bO/Jnv8r8+D6MSBw=
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
Subject: [PATCH AUTOSEL 4.4 06/56] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:25:10 -0400
Message-Id: <20190601132600.27427-6-sashal@kernel.org>
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
index f8e4b60db1672..da50dab56b700 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -57,7 +57,7 @@ static int cma_maxchunk_get(void *data, u64 *val)
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

