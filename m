Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 096ACC31E47
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:20:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF8742084D
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:20:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mengyan1223.wang header.i=@mengyan1223.wang header.b="X6WUvQ6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF8742084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mengyan1223.wang
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3DF6B0003; Sat, 15 Jun 2019 04:20:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 474A16B0005; Sat, 15 Jun 2019 04:20:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3636B8E0001; Sat, 15 Jun 2019 04:20:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEA846B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 04:20:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l184so3565094pgd.18
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 01:20:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:user-agent:mime-version:content-transfer-encoding;
        bh=bqks99JML0mByy8FjY6xU4G7QtZG+ZkGbWODY0s995M=;
        b=hSMrCNlbrxKpePa76PUbgn+kkr8u95Q73Chme+k+5iqvccBKB8Ko4i6a7LT9DlKj6L
         RjAp91lRFnBaHmvvr5kI00aH1FRqgbZ+wo2UxBNW7ipVq6qSXjJF5L8eZ8m4fckN4uX2
         1o81bzUQMgQ7BEZ0g15YV6QtQwgOfgj/edANSE/kUM0Y5cUK9Yk3Ke7gCbfMAE47Y+sA
         rhHG08FcsQVRJx40p60Q484ZOBcvW9po1sfnCk1Z6tC1KZ18ivVDQZ8s7JRvetuSF517
         5TIAXT6C/DPuma9I48nfwHv4zyVbqKI+lKAzSKijVbLhOgQ2TLfkpbOrRnA/9hLE5Uyc
         KRjA==
X-Gm-Message-State: APjAAAWI5eul68oGKSd8d/U0gJQlWFVik8Tv+XWrf5S2Xt4ChFPurm/o
	MuXgngSMumYWZpMs9pgyXBlEbA1PpwMBfAz4Doy3FA7DML1oJLOTiKFS23cW82Vd4FuSSLnBjZb
	psRBk1iK50qpS0OwRHMU+8lQllvwH+Yv6RHVDnxOZHV9pH0gsvXLq4/MPRMnm2AVDnA==
X-Received: by 2002:a63:5b0e:: with SMTP id p14mr39060129pgb.353.1560586819545;
        Sat, 15 Jun 2019 01:20:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwllQtZN4LYsBqspEjcB6/8yK05Bv5KWU52yLdO5NA6trtREN3hyS/7VG113OnBVTtlWt8G
X-Received: by 2002:a63:5b0e:: with SMTP id p14mr39060065pgb.353.1560586818353;
        Sat, 15 Jun 2019 01:20:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560586818; cv=none;
        d=google.com; s=arc-20160816;
        b=LcXEm1Fe8/2B0A2kjcEnsaq1LaehZ6oV92G6CN1BfyTiheKKrRVbwpGhdDAM0JaPqN
         kHIarws4qktDfleFvuuN1Xz8IxAeoQ68l//6fVZYrqHpOGkFPkLho5MGIOUnepqmc9TD
         o40XkmnNU9dC1wYozxontfbk3vrIZWnvYNo1w8LkvLqhhEYe8g3fq4EaRk3o4TYeG7a2
         1SChSRm5uq3Ryv3TKoTSRoJA2B9zpXIb5MPf5Cv8HGiteHJDvMKfNSwkwHHWvvuNoxnD
         KzqVxlNUblly09yjqK9vPeI3QdGK+V1zkmalTvdFtW0750Hohq7tDeG5xUHwEIJLnI+G
         0cYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:date:cc:to:from
         :subject:message-id:dkim-signature;
        bh=bqks99JML0mByy8FjY6xU4G7QtZG+ZkGbWODY0s995M=;
        b=vG+Hz3f/BI13xTAwhMmiDBh/+lx11W0vXuXCGsImvpV6lk38VmqYYRZ4C01q/nLvmN
         qfFs7zDCm5wL2O6DQ2dqUemi9CAnGU2wF+DJ7C/Zbr/MYkxFuGsFpy7BICOBeIu0oM5L
         RDb9cSHohxNcSPXOUxMKVyU2i56Vj5aepl9fkZmMFaWxhBvLLcMc4QqoI9dgd1++shj2
         edVOw6MG9vMxUwNEXD4V64OMPwIVc8QmvXmskFVksfGK9GWRILRG86iv2P0cE1Kk8FIX
         CCZIb+xmHUNcJ1fPEKVPtfOoMqdgyBvTzkwBV/gpb6TkLMmFTkgCT7G7J0MZ9/GAcV1U
         A3Zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mengyan1223.wang header.s=mail header.b=X6WUvQ6A;
       spf=pass (google.com: domain of xry111@mengyan1223.wang designates 89.208.246.23 as permitted sender) smtp.mailfrom=xry111@mengyan1223.wang;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mengyan1223.wang
Received: from mengyan1223.wang (mengyan1223.wang. [89.208.246.23])
        by mx.google.com with ESMTPS id k137si4917803pga.59.2019.06.15.01.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 15 Jun 2019 01:20:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of xry111@mengyan1223.wang designates 89.208.246.23 as permitted sender) client-ip=89.208.246.23;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mengyan1223.wang header.s=mail header.b=X6WUvQ6A;
       spf=pass (google.com: domain of xry111@mengyan1223.wang designates 89.208.246.23 as permitted sender) smtp.mailfrom=xry111@mengyan1223.wang;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mengyan1223.wang
Received: from [IPv6:2408:8270:a51:2470:fdc9:19d4:d061:dd4f] (unknown [IPv6:2408:8270:a51:2470:fdc9:19d4:d061:dd4f])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: xry111@mengyan1223.wang)
	by mengyan1223.wang (Postfix) with ESMTPSA id C3F06665D2;
	Sat, 15 Jun 2019 04:20:10 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mengyan1223.wang;
	s=mail; t=1560586815;
	bh=bqks99JML0mByy8FjY6xU4G7QtZG+ZkGbWODY0s995M=;
	h=Subject:From:To:Cc:Date:From;
	b=X6WUvQ6Am7IOROADt2MULQT0N6H5XyrHdIjWhdgp66wkT9D8yJ03fRRJg/E8IzSug
	 gP0aGKnrhRYQxaiRYYbPD+FNjl+mcGY+DcnnpYHZJat/mcn3+jv+6UuxSAFkQC/7Fm
	 J6Yf0nJeFn/Rq0SXJrgMZDo0dMHERBp4NR1yps8ewLikCwHpT1K9ZW7KAC5AHOJDxE
	 MmIP//2o1N12q/4eljFk+jD8otsc+oigSiisbEjPqxj+3G/Utn+HpXRQLdbZvtl5zs
	 EYW60BWEROdja3ZcdxvD1EgO9YE768kPQwCJJCK/G5PEiAsYo1EaNILfCRAvT7uhUf
	 eHr2f/ibTrg5A==
Message-ID: <0f1be041f8de95603753ffe989bd25069efa13bb.camel@mengyan1223.wang>
Subject: [PATCH RFC] mm: memcontrol: add cgroup v2 interface to read memory
 watermark
From: Xi Ruoyao <xry111@mengyan1223.wang>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Sat, 15 Jun 2019 16:20:04 +0800
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a control file memory.watermark showing the watermark
consumption of the cgroup and its descendants, in bytes.

Signed-off-by: Xi Ruoyao <xry111@mengyan1223.wang>
---
 mm/memcontrol.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..b1d968f2adcd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5495,6 +5495,13 @@ static u64 memory_current_read(struct cgroup_subsys_state
*css,
 	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
 }
 
+static u64 memory_watermark_read(struct cgroup_subsys_state *css,
+				 struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	return (u64)memcg->memory.watermark * PAGE_SIZE;
+}
+
 static int memory_min_show(struct seq_file *m, void *v)
 {
 	return seq_puts_memcg_tunable(m,
@@ -5771,6 +5778,11 @@ static struct cftype memory_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.read_u64 = memory_current_read,
 	},
+	{
+		.name = "watermark",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_u64 = memory_watermark_read,
+	},
 	{
 		.name = "min",
 		.flags = CFTYPE_NOT_ON_ROOT,
-- 
Xi Ruoyao <xry111@mengyan1223.wang>
School of Aerospace Science and Technology, Xidian University

