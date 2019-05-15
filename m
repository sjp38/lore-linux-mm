Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 303BEC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D837F20843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b4tRdBqZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D837F20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 850DC6B0007; Wed, 15 May 2019 09:21:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801DB6B0008; Wed, 15 May 2019 09:21:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3396B000A; Wed, 15 May 2019 09:21:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 328116B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 09:21:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d21so1679134pfr.3
        for <linux-mm@kvack.org>; Wed, 15 May 2019 06:21:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UuF5JmpoANujb+aVXS9mdWRXSQPbwJ+7x1JTARJZaCI=;
        b=puPwESufVBCwjPHOxf56/SmSg0SzgBUvqvbNYtjkTnDZq6PNgzZyFmlTiqiz+Dw2J9
         kXpGHrFzNpIS4mNpfei91XK48dtN2YOjsf//a6RQEjAefRt+LsazUNYFBMiM51/fTNPb
         AyqalvC+BQ+g1we3059dhCRq3yGz0DaJ0ofeWY1b6iPtkWtF3IsBXK0jWiaWIZ7VCVB2
         0Ey+HQXYOhMZF/vYyVbmIadcOVrvDX/dZbHWlHhlWmy7aDFvSFWPksEkdnEjLF9Q2/Ga
         CM0YOi3kZdBE1rGlU9+f2v96XlgtWSMcwUOexLfBZLTJYScduQBiXCaLlkWEN2jGKPPt
         pwaA==
X-Gm-Message-State: APjAAAVhygK3FtaqejfwT0XY9oeyHRKyMgRwYwbFqw1VeQhT97Z+9VOO
	jagImR4FwHQiustosAL6uzN1Y961bvhGXLAsnDC6XMq6/iJeMTsvS6bN+Qm9H4SnHBG3J9zbDem
	fL6PBU5bIOcIB1FD2VCAh6KEiU0uPpV+T379ADJAu6YfsmJzKLoHA6JiBY4TaVpB+1g==
X-Received: by 2002:a65:4246:: with SMTP id d6mr1400805pgq.156.1557926481046;
        Wed, 15 May 2019 06:21:21 -0700 (PDT)
X-Received: by 2002:a65:4246:: with SMTP id d6mr1400724pgq.156.1557926480044;
        Wed, 15 May 2019 06:21:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557926480; cv=none;
        d=google.com; s=arc-20160816;
        b=PDwOfDjNhg22BYM6tBNHaCRyI20sO+HmBl1VZIVX+lbx6Gv8ssqTBa8Ktq53ODlx+Y
         6vTLTls9hJnQ3hnejo70yuLihtWTRlPCGFmT+vLob69OnwK9VKyyu1kLh2iYWilonzw/
         U+UMna5WUrgYA5vy2SU42baUVVgZUWWzDkTFo8lMSvRlIjTgqLlv4Np6aKG/sz82TaSA
         QxUbklQ1Tr4z2c2qsLlSsUK+VJOqxCUMFQlsThIpfdqlHh9TfwEm/prPo/WoizcFu57e
         82pJSzmQ9iPD5o1BlJMVX7ACigNDrSSY2s+lQRdqf7IoVjWcgIPa9Ba5ZzLRmOK7oy2A
         RZ1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=UuF5JmpoANujb+aVXS9mdWRXSQPbwJ+7x1JTARJZaCI=;
        b=O85zJYf0owFbr4hkCkuZ7sdt06Q3wJqYbRqObIx4j7zXbfLRUBrKH6SygjqOR3du24
         6EXSbegJ0bTSSMK3zVeop3eDb8aQy+6Lcxx09dfE7t/NmYdSXHc1bJWKRT+ONOAp1FVe
         I/jq3efS750AkuQFN8gn2mqeWE8ScpEHJZjxKBn4FxJIDsnLpdG6EJ4r5R9BBB4ws8qW
         c7ZaUF3O4m7HW8um8H/zJfitawXzY51y0PS1LnfnTSMjwttYyZENmQj/QYBEc/ZxIQpW
         FobGrBh7ENd4l2UIJC82Q5ZzcSyero0/1+9ULgwEXMp7vrpfkv4Eisf4UvSi27bTKNix
         bD8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b4tRdBqZ;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z134sor1963363pgz.86.2019.05.15.06.21.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 06:21:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=b4tRdBqZ;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UuF5JmpoANujb+aVXS9mdWRXSQPbwJ+7x1JTARJZaCI=;
        b=b4tRdBqZOnTV18iCcCZa7NI9wBo8DwPblHdIVe4RYrU0u2KifznkLqFV/iHZ93/I2j
         Nm+VCQWRfhC3NlNqs05EzSO8FETyO3wR8RGFbw040/MwXNM739LLrzWe6gErbtdEHc6l
         wYGGaK6mm0B/Ow8oFu+4Tt/qCuAF8w7Zw7QMPqxQhn21yOpPC/H+kyB9ntng4/E6lFl5
         MdrET+qd6g7B5rX9AlwU61oF41qg35xCdO3NgmxaWSol1vxFlSaIGlTlYFGXqYIcik8G
         K+JBpFvT/VGrD0SLLfiWDahMevjQhfaB8Wml5Pux8zBujGhMAoAbtoS0dLW/63y+l9FF
         kq9Q==
X-Google-Smtp-Source: APXvYqw37IsZcBf13+bcc6eMW9pqha/YVVnPh5EBfP+6sp+7xg2XlzfvmxEuPyF4yfFGXkhrQEPTEg==
X-Received: by 2002:a63:d949:: with SMTP id e9mr43714694pgj.437.1557926479788;
        Wed, 15 May 2019 06:21:19 -0700 (PDT)
Received: from bobo.local0.net (115-64-240-98.tpgi.com.au. [115.64.240.98])
        by smtp.gmail.com with ESMTPSA id a19sm2784459pgm.46.2019.05.15.06.21.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 06:21:19 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFC PATCH 2/5] mm: large system hash avoid vmap for non-NUMA machines when hashdist
Date: Wed, 15 May 2019 23:19:41 +1000
Message-Id: <20190515131944.12489-2-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190515131944.12489-1-npiggin@gmail.com>
References: <20190515131944.12489-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hashdist currently always uses vmalloc when hashdist is true. When
there is only 1 online node and size <= MAX_ORDER, vmalloc can be
avoided.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 mm/page_alloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1683d54d6405..1312d4db5602 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7978,7 +7978,8 @@ void *__init alloc_large_system_hash(const char *tablename,
 			else
 				table = memblock_alloc_raw(size,
 							   SMP_CACHE_BYTES);
-		} else if (get_order(size) >= MAX_ORDER || hashdist) {
+		} else if (get_order(size) >= MAX_ORDER ||
+				(hashdist && num_online_nodes() > 1)) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
 			/*
-- 
2.20.1

