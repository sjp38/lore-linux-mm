Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD33C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:43:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39FED22CD8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:43:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qcNcvHBa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39FED22CD8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0E876B000A; Fri, 26 Jul 2019 09:43:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC0748E0003; Fri, 26 Jul 2019 09:43:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939628E0002; Fri, 26 Jul 2019 09:43:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 587F16B000A
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:43:02 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so27661741pgl.3
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:43:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LKdFFQMw4QQuT34zm0Dt5TQOKgDDHwaTlkCS2gnGFk8=;
        b=VX/wm0sPaMCwrdmP62uirnUZ2V85yfcZ/EDWK8e0pwIVbok+vLJDDmkW9/OMKQY+ox
         LeONFYUDzUUX3rU2QOk8ZoAUDzDfSCuTm11Fc1FrAOr+18oMNTQeU14CUdJsUOL4lrWn
         /Y0HrtF8XeXtG0QG0GxhUC64s6I1AKS61nEkiTT8maZCEIT580OYqFAwZ+YEMc0Vatp6
         q5GJUiXhf+/Dp9vY/0SZKEUyAeE7hO16K7s3gh7pUww4cefucz3E3gDCayK1OHNtLbKY
         N86VzKEDZyTbi8tOgKHfPFmEyBlLXDLnNKPH2iRnJtXfcsD6F6lMbmcYKwIA/umXiTuM
         H8CA==
X-Gm-Message-State: APjAAAXBaT3oath1bBXkGZkzSGtwkpjAEJwsmJqxEJYDPzVPvPRT7RE9
	yiw+Hi0JJorFGAdJb0auTpG+xKjkiOq6ZjI75rbgEGrWYXxTkEN8XvSf2S4Mk3d3hZbybAaTzIM
	ruBKZna/cNxh93n1rYiWQshZecTb2Pun7tIl8uyzY1tv5XhEc9o8gdrqQzAnDzHeppw==
X-Received: by 2002:a17:902:4623:: with SMTP id o32mr94807003pld.112.1564148582048;
        Fri, 26 Jul 2019 06:43:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxDQ1xcOKyQOROOlVX9TR4LoVtCcGpqR8NgOZleNUByFPytdmrY6GvufDnCAxUJta6Cp8C
X-Received: by 2002:a17:902:4623:: with SMTP id o32mr94806954pld.112.1564148581365;
        Fri, 26 Jul 2019 06:43:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148581; cv=none;
        d=google.com; s=arc-20160816;
        b=O9tyLLlcuTDRY/sII8GRWhzVR1qOIwWvvDO71VlW0xzRLoSM4wO5G7NNuQXTs6IvDg
         B2OkYCKwg+maJGgaBK+cLUL6hov3ZDoia1FDU4pKk2YaIDfCZjXyue5q4YBn82m6y1FI
         d8+e2VkdjQCGbVTygIrZncIrJoAatmkHNTd5BHyZEn7v3EzuwS4NnkP8405syj97QSLC
         CZjNE+hYtHnh5uCx4YUZTKg5oPb+CtXZYpekP+v2BQyb4SV4LidOVvOVE2XQA6+zz52D
         T99hB1SZaaR7+7XeQIsWBc16oUM0b74uvMc96JIQUaDHmAvkdRYOj4VTeMRy5ssngQsv
         A/vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LKdFFQMw4QQuT34zm0Dt5TQOKgDDHwaTlkCS2gnGFk8=;
        b=cAoAhYEsOh0GyDOjFZYjGRKvuKUsDGddg1mW8IFc8S7u1fq3oISF4820jAlQNl6n5M
         dpxNhWVSiRRQO1xmcWnFm9wInShtewY3W/uBIHH2cTS3EkcrnEwl/ojxlsinOo4UWOkG
         teXZKU1NSu/fGC6aSp1xayhKH/WcwolpZoioF0VF6RvLN8PzxyBxhPrXPgmRsobQ6DWH
         JjS7DqxyiKsHmOmBoZiSYQPig/ztKX+68guvsHAVx/XP9hvpc8WKwJKzPiV598LgTdH3
         /dMzCKkujRBmDYNyWfv0lbDiuVaWXxax3cCqsQxaM7ZNxvwUErjEJL32vGcKa22T7gz5
         ITEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qcNcvHBa;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q11si20365204pjb.84.2019.07.26.06.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:43:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qcNcvHBa;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 99C2F22CC2;
	Fri, 26 Jul 2019 13:42:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148581;
	bh=Dtsfv0EZOJEzc6QLNhd9lF+93AxZR+meA54znWd8bGE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=qcNcvHBaSFSrMmukHuPwA17A/osRfNrPWM6dQ5b6GGi3skcym7ln2LLz6IgbE/UvA
	 VGDOnJnbxPUAX/NmpwWz2zqhkm2wDbO+s+I21KOwHZC/8fCRhDQxRTAUVDxh4Msm3O
	 m9BUMpaXuf//y21XMJzf9zyL2P4kB9Ei1SBNvLgo=
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
Subject: [PATCH AUTOSEL 4.19 30/47] mm/cma.c: fail if fixed declaration can't be honored
Date: Fri, 26 Jul 2019 09:41:53 -0400
Message-Id: <20190726134210.12156-30-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726134210.12156-1-sashal@kernel.org>
References: <20190726134210.12156-1-sashal@kernel.org>
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
index 476dfe13a701..4c2864270a39 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -282,6 +282,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
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
@@ -312,6 +318,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
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

