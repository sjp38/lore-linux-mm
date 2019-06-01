Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52ECFC28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18B72272E2
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:20:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="y9GkeMhN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18B72272E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F62D6B0289; Sat,  1 Jun 2019 09:20:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A5A56B028B; Sat,  1 Jun 2019 09:20:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396406B028C; Sat,  1 Jun 2019 09:20:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0AA96B0289
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:20:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s25so4616053pfd.21
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:20:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Olle9xQljGas3XNrVqvm1GBkXaQ4T6hhKOwDmwI0ujA=;
        b=sa2qdqWGKx3cbZWfGZI6Yt6DfXj8Pi90lxw9LTDj25lk00/bPPAipZx8cy4lz/Nu7I
         2KQoZVAV7FLYWoU9+nVALud12WKmyZ8qfei5aLaD07sUtvUggAjbpqr8ZcIFfSY3dm6J
         v5XpgWi4XDKAq+Hp8Ii2btYWZV9nnCWTrE/Z3jSch6x0OgZqwxP7BGxzO4goVaqBpjaO
         YhhcSuXwbYG4ihNMBoze5403xR5hmup61RKtNYf0+91CTXRv0J7e7iGeGrf8C24E7/7Q
         Pbd8CgGGMy2gJozD104aPIwGpzt0g/0M/HXyRKesOY9oR6PqCATE2huW63YWuAYDHh3r
         hFFA==
X-Gm-Message-State: APjAAAUusxMFfkNQIaq29xU0pzL2he5AIAuIowuTvidlJ7ZLrYLTU2cJ
	wmmFbZtKTk49qeLu5FG/h3Kg6a7b2ZNMJuvB4f3tmXWoGHWHqR2HVcfAcOQcdNS4eJq0izo0us3
	5kHRHRmrzVfYhP+F8AmlELf1gIyeQ4pc6mwApV7gs7o8sm7fgGQ28u+Rv/LBPpy4NLQ==
X-Received: by 2002:a63:2844:: with SMTP id o65mr14933184pgo.297.1559395239624;
        Sat, 01 Jun 2019 06:20:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4COI9WnfME7lVC0vcMnplCS0GtPSTDuKDX9hF5paoeStWyr3OdjevGJKTW94pjsS9fDBy
X-Received: by 2002:a63:2844:: with SMTP id o65mr14933140pgo.297.1559395239017;
        Sat, 01 Jun 2019 06:20:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395239; cv=none;
        d=google.com; s=arc-20160816;
        b=MoxhVvmB0jXlBknKG6J3gKYBn9rcIQtwEJte4A/Gqoh6seF7cJDirfk+tAjtlj7gP8
         ea9Cp1shUxHyvNS1BLyo1BKO2mc3c090jdrfxxXkhP/1udHW1eqxuawRtjsdQsIEj6+3
         FHr6hgvy4zK1uRDyzCkUMkwCGTJKMUxkEGWG8/UrXczWxH5aLRX7Ole9pMxL6Kjk0VDL
         3eQSES10QA+I2PV1kmIj0T50/L5xRAGLHLP31m1i8ZlzBM2R0DXhZnxkpVG0xdYJG5j5
         y6+zlFC6Emx5khTK4/NnELu6MDLKHJa64ac8MAesEEr2FCcxtC/AvSG0PzsKV5ObId4V
         +PZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Olle9xQljGas3XNrVqvm1GBkXaQ4T6hhKOwDmwI0ujA=;
        b=a3zzeI7eYFvvVbUapTQfV6ONiUWMZSn5IbKx8rEUE5YJ4lX8DH6HXKKYjEEjmqgztm
         LpmSLV6ar4VIWH586NFpBP2ZxG1+Tkgx5EE/m35A6JE/07vpg5uUcXES5GJKcfOwEpoS
         h9A+KMvZwT1jFqgASEItzj6h4CXwUg8eiQZtQaukAdSu/GWx45gctbzVPzPrPqBYC9UP
         HnHY5gRXJ62YURGO2B1jEgnLaNfjejTTleRhUIiaPTjpHoNNbpqEoao45gHNhXQEi/aA
         zebFzZkGTfV39eq2/Hi7Cw7hKnRuK5OcQxNrsacFyvocRx4NIsNtSJfyES/rAgSlfdom
         aZBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=y9GkeMhN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s97si10606227pjc.9.2019.06.01.06.20.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:20:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=y9GkeMhN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 86666272D8;
	Sat,  1 Jun 2019 13:20:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395238;
	bh=ySSBzNCHE8z5+w8tkOcIZjG4dIlaAl6/E1llUlc4oNg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=y9GkeMhNso9hEr1R8CrY6u/RMNcr4BNYWv/a/qwKITJKSwkEGlYITFTJF2r7ufnZ8
	 wPuhYJr+D5KzVhBM8QY6VAbxKO93y7CUuGBce93OgUsEIfG+gBUJABAw+w9WQZLhqV
	 jgnf5MXwA5ZXMArOaCy+vD6osALWZigMyOKd9cUY=
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
Subject: [PATCH AUTOSEL 5.0 019/173] mm/cma_debug.c: fix the break condition in cma_maxchunk_get()
Date: Sat,  1 Jun 2019 09:16:51 -0400
Message-Id: <20190601131934.25053-19-sashal@kernel.org>
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
index ad6723e9d110a..3e0415076cc9e 100644
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

