Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7543BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D30B218A2
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D30B218A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E49E8E0008; Wed, 27 Feb 2019 21:18:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943FB8E0001; Wed, 27 Feb 2019 21:18:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85BDB8E0008; Wed, 27 Feb 2019 21:18:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 586748E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k1so17385493qta.2
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=k81wrdCLr8miUfd7ykySbkmm4/3UN7J8vKeD0uvtXrQ=;
        b=X+FA7StT2C6iwOSuqF4nOaSAE9U2ak3VDwnwgoPqK1uRBY7l1v8agPnXt2OoCC+01g
         ldx29oYIDbGOVp+1wsOPxeqVtN8BPikzdALWxIycbJ+J5roV2ooGKNqlhX0ledAh5AdR
         6fHpJLYxQ9w0LXMyMig9YOjo1OY2/ick+fLvlCcNKsTvk05d9jXnZOgkTjYBtWs8AB1N
         mVLVaa+dx8revQEsFaHhm/P6IKngCTl78bh9p5XZvjDZH+7EL1zMOhlt0Vvl17RVy5Ut
         3WpeEXZZWRxTsQBWwjVLcBjfDGUqBsw9a3PeiNMf5ZYgBRIqOnwAyUIFOJZceAER2cl2
         iX/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXAvhRPq1V8VOPdBWtdfK3UvT0nFXpzfk7CpRUpyDlLqHKL5028
	HqcQim/vzpCdebXGTYdflViBTHNMWqPkJ6K6vFYPFN/3Uuwh+SOv0YvL6ttK2nMiRtophcVjYjy
	LTCnR+VpjrXnalKo4m3iYP8I8+skp4jsPy8gUVFFYjk01yU+5iBRDPnUeeC0xITn9NIz0/XU+eW
	O2TiHDcaEUxvoONOV6Yx6P23eed64ISwAO8mDCuJ0IV82rU1OEqwOu5P305loCYpKBa3yarzYjX
	1+TcyotEnK+uoaXgtgfAU8F2yzhEvXPsqDa8nFmracNmyDPPv1Nkr3gpKnQhtSRWK55kXoFyoH5
	1XfmtdsPw6dE7HXyUVDp82dtWfFYFox6U85qb57DSU4GGRCxKsOhv2kV8StZ9xJWu30TQ0OrmQ=
	=
X-Received: by 2002:aed:3b13:: with SMTP id p19mr4477578qte.128.1551320331147;
        Wed, 27 Feb 2019 18:18:51 -0800 (PST)
X-Received: by 2002:aed:3b13:: with SMTP id p19mr4477528qte.128.1551320329959;
        Wed, 27 Feb 2019 18:18:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320329; cv=none;
        d=google.com; s=arc-20160816;
        b=A2+HlmvqzvcWObvblMNG+pwExGnvP7XUEaioOnu5Rv6nhwz0HQOXiiAw5ZhS7BM0kW
         oJVvlTEi1OjFw6mCLWUol59uv7v6xxgD3unUSVPqyVO6fuFRXdHcsp67ae343iUQdvjl
         16ujBnpjDFqYivha3BLCOBXZWGqtQGLP2BvpUtInnoRCtMIKA63FtozzxQMz4DPVJBfl
         v+3e+EULOuSlkPCgzhxcGoWTa/uQPK24czF4hNi6bCXMIoguJPZuLfvkTi0d2uYd31BJ
         1XlhatFZIH+qpav9nhzdra0oJuypIgLIZI0y0J/+X/nbSlxlUv14fidSWhc9JWU9Hk3T
         RLaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=k81wrdCLr8miUfd7ykySbkmm4/3UN7J8vKeD0uvtXrQ=;
        b=sACfi5a28gTRNw3OCvk7EMwMHTw4YSSSUf0eGXI4pvzGN70yAQGzShCca1tuH6oUF7
         wFTO4I5oZkhC+dojhhacuXHmCf/csd6VfFCjoysOfzQBamrRpXX5REjXpJ59rSVOsn7d
         60hxFXn40HLl7D6kee6lPg8CAAfK87lnf/FFbPsqethAsDu3pl4StbUPf/r4fZBA2w46
         jMbGruAR2zf0jmA5DIQkqlVsHEDlgZKaPZjdF1gfQZUonimNXKeOR0YZgq6x+HSFmWT3
         hMpAURMWWCJHpo+HoxQczwPp1mIzKN0IbKZ5aoWztj2UPqOfLwCfdf9uR2Vccz3/22SO
         7yTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor10735730qka.48.2019.02.27.18.18.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IaWHXCkHr163XI+GDm51zWvCsu6nT3A6974OMkRlq4SeFTjwbzw7uDMT4aauozctk1ouUES3A==
X-Received: by 2002:a37:e40f:: with SMTP id y15mr4725411qkf.230.1551320329706;
        Wed, 27 Feb 2019 18:18:49 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:48 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 04/12] percpu: manage chunks based on contig_bits instead of free_bytes
Date: Wed, 27 Feb 2019 21:18:31 -0500
Message-Id: <20190228021839.55779-5-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a chunk becomes fragmented, it can end up having a large number of
small allocation areas free. The free_bytes sorting of chunks leads to
unnecessary checking of chunks that cannot satisfy the allocation.
Switch to contig_bits sorting to prevent scanning chunks that may not be
able to service the allocation request.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index b40112b2fc59..c996bcffbb2a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -234,7 +234,7 @@ static int pcpu_chunk_slot(const struct pcpu_chunk *chunk)
 	if (chunk->free_bytes < PCPU_MIN_ALLOC_SIZE || chunk->contig_bits == 0)
 		return 0;
 
-	return pcpu_size_to_slot(chunk->free_bytes);
+	return pcpu_size_to_slot(chunk->contig_bits * PCPU_MIN_ALLOC_SIZE);
 }
 
 /* set the pointer to a chunk in a page struct */
-- 
2.17.1

