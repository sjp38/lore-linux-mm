Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EDF0C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 667882083D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:19:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 667882083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B0FC8E000D; Wed, 27 Feb 2019 21:19:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 462188E0001; Wed, 27 Feb 2019 21:19:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380708E000D; Wed, 27 Feb 2019 21:19:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0865A8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:19:00 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id c9so17119350qte.11
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:19:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=a1MxtiVBC/R1K9jFEg6/xTwsmtYqOsSXFAxjGkPQwuE=;
        b=bxIST4VLQNHspPLzpg5/bBW4qhquhDoEkazIHdfcQmgdeJSxwgGNckdadQDXxb9us5
         rAU/FjedKTHzYnH86OiOx/cuBQ+bnZCpviIXAH9r+khzfm3Ti4vfHy5blZA5eR2os/aq
         hr2qkijyLLrAloYjCKnrviljztwqsw/iEdzqpAyHMTLTGsFAl2lEByVVARDYADwGtCkH
         gv2ckXzy6dgLHM8ACqYqkp7wuMwcpRC2boXeRo7wGHkrcGXYJd5/AyGkCR4LE6BfBYHe
         lFJPybruQ/GkRp86iZvzaMzyY/QIALDiq7qxZaAu6jb+urJ5HYbJts7rz0lKdWWdU9EE
         K/8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWsnXbA4P8PILFQ9p/U6lOnLuNqEr37vTkDzawIb9x/OYrlvmF8
	2+Fct0kol1tPa5gGus1TzigZpirKgNioEXiO0kklwLeXPGpLPSYhoIlqAuJonn+vVTy3g8R+kZi
	xNhCM1n/vcAXuMy1ZAGtHiQt4S0KxWgYY02RSVF4kCj8dzuwCDf5as0dipD2e6+kIzFbDmE3l2+
	0mwzj/k6SvvS1me+jUQdvhb58kSMD3Cyq27snT9jeuK4CLbnnhLWitMwiZWHtkBLz/noECl8ubg
	P4XbOFBYbugMBHwScDP2WcTg2zBX9DNZL6/uyQp8R937eD1vWoClWdWm59Fsl/4rHvLtGiT3wzg
	E8WaV7ItrJErVv6ip0PJI4uXccgKdFka8eWkDDpknyuol/kwqcNyj0pdFfUdpNmCy1bA0qFSAg=
	=
X-Received: by 2002:a0c:b98f:: with SMTP id v15mr4504072qvf.60.1551320339806;
        Wed, 27 Feb 2019 18:18:59 -0800 (PST)
X-Received: by 2002:a0c:b98f:: with SMTP id v15mr4504040qvf.60.1551320339036;
        Wed, 27 Feb 2019 18:18:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320339; cv=none;
        d=google.com; s=arc-20160816;
        b=0MMqXX1dPmyzC+yFn4gMKPrDUXiLD11KDlYvGjvqrirPJB0GLD0skMwypv2omAyvYv
         9UJRqhlChl5q1t4CWhQwQXvxYHJM6K5Q7aNfE1e8NgIwMZeCdoSbBTmgA+G9p4hiGoLX
         GTSagkkFZqhKjFGPT6JU+r+wjk+qQnvY3YRuxuBK7qA8qDAteZN3/xoTkwlC2uaikOQ4
         +SihiNteoidKPPDuwoxYSdHcnqSORNektQegp8ioKqopBcvEx+AypQXKm7hGYKkawIZK
         tgyxeh/LWlQyzbsNOQOTZ9PpDz9gkL8DfEJJcBWC7Xf9qHDo6ykMKDBx3M2/MrwiCD+N
         FK9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=a1MxtiVBC/R1K9jFEg6/xTwsmtYqOsSXFAxjGkPQwuE=;
        b=Wy4TNsEFjpNV156aMnRQfPt2SjsOYlORwUNdI+/6VrMlb+djoEri+hVCaKtuZtPL3z
         9FQQ7SCBLuQvadaq4rAHGL6xnaoRhuKyisMI1xqVrEmlp3UmTMrNm8NRvws51P1CUJkk
         u2lvRlr+3lcU58mNDyKGvGnWyQbraMCrlYKubDDmzW4hYWW70TD1YkWqGwHUHBMN3nZA
         fqXZqetgJoHKztOQzgK0sXsyDpbVvEQzbvCHuU7QNutIc718jMvJmEDheMG+HOTWi/XP
         R/DFgrTyQH1V0UjG7qswQ11iIHwnlWVrcSFJwJUrlaMdIaBcDlUztFiSolnglQ/hGEvk
         7CuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g66sor3153231qkb.134.2019.02.27.18.18.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:59 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwPqhzmoh6GEfoGzQtsXP/iOmZeY0a+Lec5XpOorPIszYP54avqBFyXUbatJXA0jjRU7OtQYg==
X-Received: by 2002:a37:e30b:: with SMTP id y11mr4833349qki.25.1551320338781;
        Wed, 27 Feb 2019 18:18:58 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:57 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 10/12] percpu: make pcpu_block_md generic
Date: Wed, 27 Feb 2019 21:18:37 -0500
Message-Id: <20190228021839.55779-11-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In reality, a chunk is just a block covering a larger number of bits.
The hints themselves are one in the same. Rather than maintaining the
hints separately, first introduce nr_bits to genericize
pcpu_block_update() to correctly maintain block->right_free. The next
patch will convert chunk hints to be managed as a pcpu_block_md.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu-internal.h |  1 +
 mm/percpu.c          | 20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index ec58b244545d..119bd1119aa7 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -28,6 +28,7 @@ struct pcpu_block_md {
 	int                     right_free;     /* size of free space along
 						   the right side of the block */
 	int                     first_free;     /* block position of first free */
+	int			nr_bits;	/* total bits responsible for */
 };
 
 struct pcpu_chunk {
diff --git a/mm/percpu.c b/mm/percpu.c
index e51c151ed692..7cdf14c242de 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -658,7 +658,7 @@ static void pcpu_block_update(struct pcpu_block_md *block, int start, int end)
 	if (start == 0)
 		block->left_free = contig;
 
-	if (end == PCPU_BITMAP_BLOCK_BITS)
+	if (end == block->nr_bits)
 		block->right_free = contig;
 
 	if (contig > block->contig_hint) {
@@ -1271,18 +1271,24 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int off)
 	pcpu_chunk_relocate(chunk, oslot);
 }
 
+static void pcpu_init_md_block(struct pcpu_block_md *block, int nr_bits)
+{
+	block->scan_hint = 0;
+	block->contig_hint = nr_bits;
+	block->left_free = nr_bits;
+	block->right_free = nr_bits;
+	block->first_free = 0;
+	block->nr_bits = nr_bits;
+}
+
 static void pcpu_init_md_blocks(struct pcpu_chunk *chunk)
 {
 	struct pcpu_block_md *md_block;
 
 	for (md_block = chunk->md_blocks;
 	     md_block != chunk->md_blocks + pcpu_chunk_nr_blocks(chunk);
-	     md_block++) {
-		md_block->scan_hint = 0;
-		md_block->contig_hint = PCPU_BITMAP_BLOCK_BITS;
-		md_block->left_free = PCPU_BITMAP_BLOCK_BITS;
-		md_block->right_free = PCPU_BITMAP_BLOCK_BITS;
-	}
+	     md_block++)
+		pcpu_init_md_block(md_block, PCPU_BITMAP_BLOCK_BITS);
 }
 
 /**
-- 
2.17.1

