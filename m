Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 543D0C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:37:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F36020835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:37:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tXGc0NZh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F36020835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E4A86B0008; Wed, 17 Apr 2019 04:37:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 868CA6B000A; Wed, 17 Apr 2019 04:37:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E046B000D; Wed, 17 Apr 2019 04:37:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 052BD6B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:37:38 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id h25so3344569lfc.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:37:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=dfeo8YOu8JjnJy9clvCWn7qfnWgfhPDYSBPAI45324J0caWc7FKO2e0Pox5OF7XtQS
         16aHYXqobfZ1d0s/+rS09X3tp0UB6BTXGskEZ7YReC3YafR9L1dNB+0xxmFaLKYJ2Rme
         sYTetJTFesUl1Hvz1JS5eiMwiQUAvn4rL6PNyAzGtAcLf1+WJ07BML/ekooqzR9rICkX
         poHukCqs2MdfJu5UcAtBAn2EzYqdN2qgBQ8RUwC5occayaY3QNWEFDWsmpw7rw9CNzho
         COmc/HdHaJ6LAiocwguOLu157afrLcvit5i5/Z0tXMp27QrMwd3w0yArM8RO6stIaE7F
         fazw==
X-Gm-Message-State: APjAAAW/mO8qw+BuzhhGT0eY1omTzFCs9sopCTtnk7Aaxpv1CwfoFw2/
	gJtaOuVS+piSGgYSxCV1xad+qe1ODrksv8dRm20RVtrOdrMXAeUSFBsr9r2JEljP2de4xEJFrcw
	WzMcHXCoiovaOSbgaQ1lyp88y2A8UTaU5bV1xtkZ73FnAtWPqE0qKEIxltHwPpGuZYw==
X-Received: by 2002:a2e:7f13:: with SMTP id a19mr46417703ljd.35.1555490257346;
        Wed, 17 Apr 2019 01:37:37 -0700 (PDT)
X-Received: by 2002:a2e:7f13:: with SMTP id a19mr46417621ljd.35.1555490255996;
        Wed, 17 Apr 2019 01:37:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490255; cv=none;
        d=google.com; s=arc-20160816;
        b=v24oTk7NMzSEAuKkdeOzjfYqGKGCRJOHf0+T7igodVy6p8BLWiUhzt2Axu4qJUaYMB
         0Z60ljYQc69BYVUGFoucMJW57LwMi1AFi7/AV/liWtjzPd8gafb0lzfbhJcMJA/KQ3VQ
         9OqraK4ubnQ9R9yzimxrppwxlzM9C3PGmtkA1fTHjHVVaFY1ucI3VuyWaNCw9ZYQ3/i5
         sEwnIp5kR7CYdtBhBYaoXULT1v8P55oSwYVEJZn3VouNJOqhdH+qBotixKBwI66hiW0W
         fXCEo8zSG+YWIbKy7jMvNXuHtipr8KmvRFbXxPtcj23x0bf/MPaaI1PLSm+Rkm24Lo5Z
         xTdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=JRQNofssgiz3dnCs+rqI6bdCejLujQGVcN+pxe6Tjj81+AO8Fz3UnA3jai1t7flyFA
         OiGaQRwfMQM+2aMGnLG+3c6ZTGCUXHK7JVm5asNcU42k0qlAIhPgiTDcwcexqfz+pzLX
         cNipSeSm74DzgPTQCNlhLZI3J1J1kP685YelN2t/F85GUa6EqJlnKB2FCGV/qIKRL7jG
         4/sqUbslzmKo+aEvTR7UEX934/2WGfnJZOq+vLPBdy24ipTd3fwY1/vZNTgAsaNgrJJx
         70sFC4H371XamIZHDaWmayP0NlokwIhcuXhtkvHePh1AoqEkt2ob0OF6QN13uls/EunN
         gfMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tXGc0NZh;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3sor14750621lfp.45.2019.04.17.01.37.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 01:37:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tXGc0NZh;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=eracmwt7PPl4AZZBoOATyO/9W4GSvbRyS4J/dbiNmIA=;
        b=tXGc0NZhjaZsco2x643feyLYfETk7tP69DmsmI1ukNlFcsqVxOZPgNTDgtFTsGpGei
         zDp0VmDlpdSIaiqE58MDXrAFrLOcsd2ZgUb40kf8v9PBhD3bI8ob/4WqnZcnPTB8Wjts
         D7UFfdJOdF4zoWWmRJgX3/VMH+om5tlrkb9WVaRuRnzgsLKBZ0zjusQF991pOWXNXSdV
         sUz8cyhwdpR8nh6Ub/i3hfNLgjfq3zCYmsmTmXt2YZ7it6U5BtPhVIOCvnYGYbn5Ga+c
         271dvA3vLMLYL7XdQfGgABhH7twTe7Z7PNeLa/lsXSITTNjU0Bnh7AWc/ZTyEmfCoxDY
         AysQ==
X-Google-Smtp-Source: APXvYqx4ExKeIMbFg9T9tX6SZdDS0Cbp3kgvlbWCD26SsYSpLy2UMegfsoPIlI9gnvs8kofXCRRpow==
X-Received: by 2002:ac2:43d8:: with SMTP id u24mr23190693lfl.94.1555490255103;
        Wed, 17 Apr 2019 01:37:35 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id d192sm1649933lfg.79.2019.04.17.01.37.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:37:34 -0700 (PDT)
Date: Wed, 17 Apr 2019 10:37:33 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton
 <akpm@linux-foundation.org>, Oleksiy.Avramchenko@sony.com, Bartlomiej
 Zolnierkiewicz <b.zolnierkie@samsung.com>, Krzysztof Kozlowski
 <k.kozlowski@samsung.com>
Subject: [PATCHv2 2/4] z3fold: improve compression by extending search
Message-Id: <20190417103733.72ae81abe1552397c95a008e@gmail.com>
In-Reply-To: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
References: <20190417103510.36b055f3314e0e32b916b30a@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The current z3fold implementation only searches this CPU's page
lists for a fitting page to put a new object into. This patch adds
quick search for very well fitting pages (i. e. those having
exactly the required number of free space) on other CPUs too,
before allocating a new page for that object.

Signed-off-by: Vitaly Wool <vitaly.vul@sony.com>
---
 mm/z3fold.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 7a59875d880c..29a4f1249bef 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -522,6 +522,42 @@ static inline struct z3fold_header *__z3fold_alloc(struct z3fold_pool *pool,
 	}
 	put_cpu_ptr(pool->unbuddied);
 
+	if (!zhdr) {
+		int cpu;
+
+		/* look for _exact_ match on other cpus' lists */
+		for_each_online_cpu(cpu) {
+			struct list_head *l;
+
+			unbuddied = per_cpu_ptr(pool->unbuddied, cpu);
+			spin_lock(&pool->lock);
+			l = &unbuddied[chunks];
+
+			zhdr = list_first_entry_or_null(READ_ONCE(l),
+						struct z3fold_header, buddy);
+
+			if (!zhdr || !z3fold_page_trylock(zhdr)) {
+				spin_unlock(&pool->lock);
+				zhdr = NULL;
+				continue;
+			}
+			list_del_init(&zhdr->buddy);
+			zhdr->cpu = -1;
+			spin_unlock(&pool->lock);
+
+			page = virt_to_page(zhdr);
+			if (test_bit(NEEDS_COMPACTING, &page->private)) {
+				z3fold_page_unlock(zhdr);
+				zhdr = NULL;
+				if (can_sleep)
+					cond_resched();
+				continue;
+			}
+			kref_get(&zhdr->refcount);
+			break;
+		}
+	}
+
 	return zhdr;
 }
 
-- 
2.17.1

