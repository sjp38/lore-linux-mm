Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39425C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E570022CE4
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="BlCXobIu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E570022CE4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EDAD6B0007; Fri, 26 Jul 2019 09:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69FDF8E0003; Fri, 26 Jul 2019 09:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58F648E0002; Fri, 26 Jul 2019 09:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22BE96B0007
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:45:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so33246740pfi.6
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1TCF9OQMDMQzaASZOjKYAM5EiWgEgl+WCL5ugcjuEHw=;
        b=VPR1zmqhMYWxCxvpknbRF3cCcQ3MHHZ8nb/gCKFFdeKNuDFpc5LiXHwSnseBVmSx3B
         yPlzOygQ1urnLVXBJHJW1OWyQuCcfax1f+xo6maVYPYdgiJ9vhWjGKWvCq8fbmqWa/+G
         PKsPClACNEfXWzBMkwFxRvdn7mZs9RA/MfDIRhyZkgoaP6tNEP+Mj1YudwU18LA8vrAO
         13VjDCO5oGdKO3obUdCz5UiwMi/WZod1U3WQhcnsqRjY1Y5BVcY7S5aKatME8iv01sxW
         V4fwTThpMQiPH61tWYs7ym+DNwbXyc3wSglCDWiNKOWbIZp2gGPVEDN1ObOURpnFJQKe
         e6ag==
X-Gm-Message-State: APjAAAWXNHfJlafhKzT+le8sBLclZADnVXRSY+6eTdTzuvNn+/9zLUq1
	5tPdqfVFhz9TOO3KzSbwKta9aPAxMqDQwj1Xnq5U3+gNwKjRvWoM0k93iHk9nhabu0o2DYes0i7
	3LVJnArozU7+PtGBckVSzD6xe01ieLQ2nJnijNc5aK9GIPlBE3yki3sZ91jxhL/0+oQ==
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr92856161plb.317.1564148702815;
        Fri, 26 Jul 2019 06:45:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGkCqIwEu+vhU3OqAFynUWF0SZYLumLxUp9+HZMW0wqFZyn67Fl2AIIBn+W6hSuroU67hU
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr92856130plb.317.1564148702130;
        Fri, 26 Jul 2019 06:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148702; cv=none;
        d=google.com; s=arc-20160816;
        b=qsUzRV5gs762RBaVcNYp13pvfL7HQWJ390MBY0cRFh6TUT0NvUI2P16/9osvjGkn6Z
         cRU9PuHbmJp4RHBXgc9gOz9nEpM1F9v+yLYc0Pop+SOKJDlV0z9bFauGyxxCt9nmAkFc
         K0sGMUSh/v8F7klOkvdinrIaFqx14+EjssY5Ei1MEBpygE0dGjQi9zK65Cx9rveY1Z0e
         4d1vNLr+5llVPVSDc3DxH0PMhZUz1/kYSePjF6U0tF41LJOsznRS3YxNRjPjRyiZIAUD
         pWiBe56dED79CDhU6EmKie7FrPCPXCN0vRmZPXRuQK++IIKgfhool3+BIQlqrZhWdYx5
         CTiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1TCF9OQMDMQzaASZOjKYAM5EiWgEgl+WCL5ugcjuEHw=;
        b=jb7Jw8TDQ6yXzEQnYaxEkwA1B5/dn7yNRdBNNC3vSS774xcqPdLQSHVzH2I47UpAqD
         krZNRVgKL/hRJyvHqly2YlU41Mka/D/cEV/ckC2zC0MMXxDb79XoXqs/xqBcW2MHuz0C
         +nv7vGQRhfVXOvENMzE94QYP7QnQde/auI6K5eGpO4iJB6KZ8zlpa9B84g99EaGzd+L7
         ofgSdbIgPIg6hEWS6AvxPYOb3FQ13You/gu2af2jSI3VaEgJVsXWUZ4gwnYWP+GhKqXK
         nCtcwtDiJv1telzMryRKv3Xj1JV5YCMexvltrxkth8cGBB+UsbZrGdP4FLDLy975hoab
         pwIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BlCXobIu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 4si18932014pfg.55.2019.07.26.06.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=BlCXobIu;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 627FA22CC2;
	Fri, 26 Jul 2019 13:45:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148701;
	bh=tTGj7TxV+qZskt12DE672FS4M46Bp/vOTZu0gwHaCJc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=BlCXobIu8+RczhbEEY7jpHStrKYS6/h19C8/SFl4LBMq98IciOZGv5aojBtYEK5/v
	 uHcOkcv2I1WlCAPbGZ/dg99qy1IGtGPPexZYGFp+YOjA0uBcRNXS4j6x51WKLAGwUC
	 1bpAYUHJJDGwn+uREgTzJ08uz68YsKDdzBu3HASc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Doug Berger <opendmb@gmail.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	Yue Hu <huyue2@yulong.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Laura Abbott <labbott@redhat.com>,
	Peng Fan <peng.fan@nxp.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.9 19/30] mm/cma.c: fail if fixed declaration can't be honored
Date: Fri, 26 Jul 2019 09:44:21 -0400
Message-Id: <20190726134432.12993-19-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726134432.12993-1-sashal@kernel.org>
References: <20190726134432.12993-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Doug Berger <opendmb@gmail.com>

[ Upstream commit c633324e311243586675e732249339685e5d6faa ]

The description of cma_declare_contiguous() indicates that if the
'fixed' argument is true the reserved contiguous area must be exactly at
the address of the 'base' argument.

However, the function currently allows the 'base', 'size', and 'limit'
arguments to be silently adjusted to meet alignment constraints.  This
commit enforces the documented behavior through explicit checks that
return an error if the region does not fit within a specified region.

Link: http://lkml.kernel.org/r/1561422051-16142-1-git-send-email-opendmb@gmail.com
Fixes: 5ea3b1b2f8ad ("cma: add placement specifier for "cma=" kernel parameter")
Signed-off-by: Doug Berger <opendmb@gmail.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: Yue Hu <huyue2@yulong.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Laura Abbott <labbott@redhat.com>
Cc: Peng Fan <peng.fan@nxp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 4ea0f32761c1..7cb569a188c4 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -268,6 +268,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	 */
 	alignment = max(alignment,  (phys_addr_t)PAGE_SIZE <<
 			  max_t(unsigned long, MAX_ORDER - 1, pageblock_order));
+	if (fixed && base & (alignment - 1)) {
+		ret = -EINVAL;
+		pr_err("Region at %pa must be aligned to %pa bytes\n",
+			&base, &alignment);
+		goto err;
+	}
 	base = ALIGN(base, alignment);
 	size = ALIGN(size, alignment);
 	limit &= ~(alignment - 1);
@@ -298,6 +304,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	if (limit == 0 || limit > memblock_end)
 		limit = memblock_end;
 
+	if (base + size > limit) {
+		ret = -EINVAL;
+		pr_err("Size (%pa) of region at %pa exceeds limit (%pa)\n",
+			&size, &base, &limit);
+		goto err;
+	}
+
 	/* Reserve memory */
 	if (fixed) {
 		if (memblock_is_region_reserved(base, size) ||
-- 
2.20.1

