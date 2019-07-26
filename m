Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21393C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D067722CD0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:44:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="V7jx6t4v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D067722CD0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6531F6B0006; Fri, 26 Jul 2019 09:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 604188E0003; Fri, 26 Jul 2019 09:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F2EF8E0002; Fri, 26 Jul 2019 09:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 198CF6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:44:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f2so28425950plr.0
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j8crT+4ifklZpVE5EKM0I6dEV8w4rPboWHXBEeO3gpE=;
        b=H1cxYgjuABrMnDGKCr0Hyl3qLqSkc1t0LsHT1KgrbFNNAGGTwazfGPH0XoRYQ1Zil/
         7DS7O4QgbrS7f5XPS3H+NZre/Q7bgAkK3xehg0j9zr7kOd11+DFLtWpU02TI+MdlG58T
         tOtb3r6SeVIwaeHGtkefR9KgVu7ZlXxwHwdNYvLmoFFTACN3DCh6PliZfM/9Ub20FDma
         Up6S7Sr+aMrIQhpiiy2h+FlyInbt78BUiBAEk/qtiwN0KFMRHnCpy3og+oCaPvqDovmW
         IQP7ENe5d1MlCptgkLftm1d5qleUGQmsqea4/L1E61EfXJ2MgbbcxMeepC//DE0eCzcd
         yD1Q==
X-Gm-Message-State: APjAAAVbs5hjA/hz9emx1V6OpRQfZRqODxeX/zL2+wMo4DCv4C5N2yIO
	rqIIKpi5xAuQI+3nh78l+eW+i+vy7edylr0LHDXHvUITPlM9b609YzpwdL7UUlNYPHrE1/mVvc1
	Bz3Jsyp9UaMYqPXdxGFr2kq7dquSQ6NDVJWujiGs0S36DQ7wWODfUR4MsJY3mjD+16A==
X-Received: by 2002:a65:62cd:: with SMTP id m13mr25905286pgv.437.1564148647716;
        Fri, 26 Jul 2019 06:44:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVPw6CDcVU8L442TjgUeaQ+yhwtXM2wUmcsDRcX8EJE2axGgpuIYixHLNaSJMUruUQdMpg
X-Received: by 2002:a65:62cd:: with SMTP id m13mr25905234pgv.437.1564148647030;
        Fri, 26 Jul 2019 06:44:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148647; cv=none;
        d=google.com; s=arc-20160816;
        b=dqqfPCtqX3+yvGDoa81LX92oAurFwclICiLFmn+1wOD1Hzv7J5dchyuMjdb+alcdHI
         nSgifUAp/EoeWqWLOFvTocuRzAB6Ng8T48lPq0FbGRpcEQR+dtejTzIyAUe7Y8OIkjQ/
         83FR5ljpUD5dQBsnTXQVWQMHTupzECVDmW8+mnlg/+q95FhUTLsC3i46VjbbIS0L0kJy
         PKGH9dA1VXT/LWnUVuIbaNN8dHK9PrZq9OR1qKxllP3O3vojfdSiYQPmqcsBBq+J4nLE
         H1wdiy3iwNu1fj7VCyjaCYRjiyiEWE8cbYtDkKIykrVVGpTkDQbWO/d60RAuaZC5r75M
         QKCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j8crT+4ifklZpVE5EKM0I6dEV8w4rPboWHXBEeO3gpE=;
        b=zTOUBRw+xU2ihKE3qN/s/dEYdu+nZOsVvnYacUYpGIhI090PUCETR0pIolACVtYQpg
         ZfBYzTjHiuT+/aU4jaa7hWydiENUMsOvGoCHrRn8ShVvOZhFjqAWxsXNSuziE6kNbgL6
         ydy2jkwXSiBSFlM2vxgLSntiPEuA6+ni7J02eX74wxUYdqD2qnj58VSiQVYbL67OXIuf
         46tgkMOaUUwC84eh9rrLZNj8Dw+vPlAnNyRb+SUnTiTtgg57bWwumEo0BT8FSot0VV91
         WLEBGQ2IXAuW9hzALmZPFzPDRhwuysHahO2n4T7KWC3Y6PVlJk6KXLnUfgXjOwVBMuHy
         jG5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V7jx6t4v;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id gb4si19036531plb.429.2019.07.26.06.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:44:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=V7jx6t4v;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4E74622CC2;
	Fri, 26 Jul 2019 13:44:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148646;
	bh=ItV/L+YqpHgl/KAEB0KZea0d2qVCwzkzhqwD8RJx8cU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=V7jx6t4vWtqHHt59KrWRICnzspkZfmSGLjwyDlSzrzzyl4iL56qUBep2u8Tdph1rh
	 n0mso3R83KiTGBm1/CPYm3WYsVYZNijew/ZR+hT8b6qA7z6z8LMrywDBTMEIaVwJrM
	 SUY7l5Dqt+SREEzLtHo0dMUFOnliVIIPQpo9RADM=
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
Subject: [PATCH AUTOSEL 4.14 23/37] mm/cma.c: fail if fixed declaration can't be honored
Date: Fri, 26 Jul 2019 09:43:18 -0400
Message-Id: <20190726134332.12626-23-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726134332.12626-1-sashal@kernel.org>
References: <20190726134332.12626-1-sashal@kernel.org>
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
index 56761e40d191..c4a34c813d47 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -277,6 +277,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
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
@@ -307,6 +313,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
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

