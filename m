Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86680C28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4213E27381
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:24:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TKZzINyd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4213E27381
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A1EB6B02AA; Sat,  1 Jun 2019 09:24:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 652BE6B02AC; Sat,  1 Jun 2019 09:24:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CD3D6B02AD; Sat,  1 Jun 2019 09:24:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05D466B02AA
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:24:17 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bc12so2106002plb.0
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:24:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Rdh9tUnZDaqppozv811KEwOS+oGVGZzC9/3hd+ZUUAM=;
        b=NsyIzJlA+4GsTUZW/9DCODv9rry95biKL5yw8GM9Xfx7DvIy+R49h3ciiymaA6Z3YH
         ypzw+PgUix/ogdaCPw7DzH1zOcaT/BqLVVI5yoU13crqTWV0Z8uhLQvtOW1si+ZLWQWp
         ANkL3qPtB4bV4GtTwHc+ah9FDmNyU7zrT/sRSzqjjGk3KJp+t6v0VjU0w8KT7aaCsjp4
         souKvfUzkkULKbjfXt7ilSTJI0wdLFysNbJj24q52Ax7BfRcabMEPgRkOhDrIRy/zKnl
         oAhzleI/+JMhA5eij3K5ZAUzhTlLPuYslXBLzmpDE3gklPUGhe0gkuzkAgD2gAqtUEZy
         bB4g==
X-Gm-Message-State: APjAAAUPZJgNsvNDi8B/GmbpS+Jxxbo1SDLUmN8dpzdAB5u58T1Lj+31
	0L7N1Oau+Y41arFFbo47WQQeaOZGRKav3DcYLA0wmHaILwTdyPdwHa+PQPJafCf1xWLarGbm+uG
	km5wf4BA1ya73JrRKQcLlGQ/pTWC8SaWdP3hUV9G9R5PShtzJ5vY57nDry/F5DsYrBA==
X-Received: by 2002:a17:90a:cf0b:: with SMTP id h11mr9656998pju.90.1559395456666;
        Sat, 01 Jun 2019 06:24:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaz/ik1NHv8NIm0ig/ertSKz5NLj3AD3baYIWFmBgDLRUyudbsyFDFU9AyqAS8CVH89QsR
X-Received: by 2002:a17:90a:cf0b:: with SMTP id h11mr9656919pju.90.1559395455996;
        Sat, 01 Jun 2019 06:24:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395455; cv=none;
        d=google.com; s=arc-20160816;
        b=SivyeAOtOjJGgybH1OABmX5ZClkwBb62eRGbcfWVe3rXbkuJN8EnBapm5nkv8WRYRA
         MrOcKIpwTB2wsMhZCHYQfqlPJN6oHjd12LNtX5fdh0g/tDUrSTjl1Rlj+PxJ9vE4tK3I
         q5hA147Lcuw5/oKOawBXHo1dr4gxRp6DmhRoMfAfd8SOqTXgdCZPOSfQgzWRoHOu0TG9
         jLRRIaw3CG9uM60EXOaDpbDCD6TD9TDVj6EaKPB1DetgiXt4L4WJBDkU6n1Q8iSQpqaI
         DiuTVrv8AZgYZQIj2aOaa8v3O0l6r2r3rb1cGZjDmZ0sO1O4Pt+F9IRSpUqpHWCn5KNd
         Q2FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Rdh9tUnZDaqppozv811KEwOS+oGVGZzC9/3hd+ZUUAM=;
        b=IOQxxEZX4RO1f0LrNG/lWZ72WqxqRHN3vRKyguwgUJN7FHAZihhoagZ51GfobiD3EE
         naYwWL9GSOMVFAFxXbV7o7UzKzprPOAXRDlKXZbI7H59B9sGdKfg6KVkT22wDNH9hmgx
         4PWGD+SeXpSXFwE02TQMFueUbUB34yTpUvBg27xd9ohbT8b59IQ/+Y92+XBdB6rB3GZY
         aFVkJ0uEwYJ0VwQCSvW6Lp/1Rh7IN5hrOACWZk49Opp8xW4H2fq03TpREe/CJRsf+TF0
         xQdrVWsogV1bDs2lVq8y6MEf99uiRuM5uUTogAWWfPOmRnGzNL0hetfCT7UaE2kvtsHx
         wC6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TKZzINyd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n14si11115305pgs.34.2019.06.01.06.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:24:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=TKZzINyd;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5C8D527355;
	Sat,  1 Jun 2019 13:24:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395455;
	bh=Jcm5SfVYuW2yOBT11lf+b1i2YQGYQcG71NXf7y3Ktnc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=TKZzINyd9BDzgPDOM/42yQ3VHVH3hPNPLVXX2qB6MUoT/AScy2GZZGhn0c2xkqXbR
	 nMY5oGNoquAKe87SI2E90kq2QPvShgtj9dtr+zfj3gnkdRrL4G7gmov3txPUoMLfaW
	 eBjN8rB4LC+S7GUilS0lIM15E0VYF7+MDHrqHiWw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ingo Molnar <mingo@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Laura Abbott <labbott@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 10/99] mm/cma.c: fix the bitmap status to show failed allocation reason
Date: Sat,  1 Jun 2019 09:22:17 -0400
Message-Id: <20190601132346.26558-10-sashal@kernel.org>
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

[ Upstream commit 2b59e01a3aa665f751d1410b99fae9336bd424e1 ]

Currently one bit in cma bitmap represents number of pages rather than
one page, cma->count means cma size in pages. So to find available pages
via find_next_zero_bit()/find_next_bit() we should use cma size not in
pages but in bits although current free pages number is correct due to
zero value of order_per_bit. Once order_per_bit is changed the bitmap
status will be incorrect.

The size input in cma_debug_show_areas() is not correct.  It will
affect the available pages at some position to debug the failure issue.

This is an example with order_per_bit = 1

Before this change:
[    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=> 638 free of 1024 total pages

After this change:
[    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=> 252 free of 1024 total pages

Obviously the bitmap status before is incorrect.

Link: http://lkml.kernel.org/r/20190320060829.9144-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index cba4fe1b284c8..56761e40d1918 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -366,23 +366,26 @@ int __init cma_declare_contiguous(phys_addr_t base,
 #ifdef CONFIG_CMA_DEBUG
 static void cma_debug_show_areas(struct cma *cma)
 {
-	unsigned long next_zero_bit, next_set_bit;
+	unsigned long next_zero_bit, next_set_bit, nr_zero;
 	unsigned long start = 0;
-	unsigned int nr_zero, nr_total = 0;
+	unsigned long nr_part, nr_total = 0;
+	unsigned long nbits = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	pr_info("number of available pages: ");
 	for (;;) {
-		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
-		if (next_zero_bit >= cma->count)
+		next_zero_bit = find_next_zero_bit(cma->bitmap, nbits, start);
+		if (next_zero_bit >= nbits)
 			break;
-		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		next_set_bit = find_next_bit(cma->bitmap, nbits, next_zero_bit);
 		nr_zero = next_set_bit - next_zero_bit;
-		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
-		nr_total += nr_zero;
+		nr_part = nr_zero << cma->order_per_bit;
+		pr_cont("%s%lu@%lu", nr_total ? "+" : "", nr_part,
+			next_zero_bit);
+		nr_total += nr_part;
 		start = next_zero_bit + nr_zero;
 	}
-	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	pr_cont("=> %lu free of %lu total pages\n", nr_total, cma->count);
 	mutex_unlock(&cma->lock);
 }
 #else
-- 
2.20.1

