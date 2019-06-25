Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C18BC4646C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:22:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38AC520644
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:22:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iaZcsMGU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38AC520644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D90B68E0005; Mon, 24 Jun 2019 20:22:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D425F8E0002; Mon, 24 Jun 2019 20:22:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C09C88E0005; Mon, 24 Jun 2019 20:22:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D32C8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:22:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t2so10374979pgs.21
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:22:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=T7DwszIH6Vg5Lzuq4GDQX3dAFFq7h/uJlY/TUYoAObM=;
        b=tIP6BY+4O3iHieRTSshXGYtupu0PBIhgUA1/espuMYi7k8wEuDqZR+pN3S611/Gihg
         jZGKhL6hUy8AQkEKXBlySyCFt9JpIYW0rgRC7R6VGpXhz1xJ6kCDzKXIDZb+sVkUcUEQ
         g4E1RqIgOJx77JG7TcAyFr3mgRFXqVgJDPEBD2SLERRVqllK4LQ406J4eXQXh/zpev/i
         HGPSLiNMRByC4FTFbxm4WtWB7fKuIZjCw33nUh7xifa9YqnUmvlz7La+cuc4QGjC9+w1
         GHvblRfPGq2WjttGk7uTrYJwFP8cDav0B33M/L4WwQJPTCnbNM+XtlMVNlTHUce2cRsZ
         i7mA==
X-Gm-Message-State: APjAAAVpkxJo9zduRo+csRMBrab3Yj927pzVK6Y9g7kawupQq3b6SW2M
	Ejo1cyeTXwzZqAvMvpPg2ZNt54jGKXGli7k8CzYeH6heTs04EDVKu8UCIoKbfmtmWx6LJeejf8i
	GH2PTPuIq8HhPp6/0JzMNh0VsTYcEPakptT2+Cwblr2nNtGlpQMF8427xJUgwvj1Rog==
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr14758746plb.25.1561422124163;
        Mon, 24 Jun 2019 17:22:04 -0700 (PDT)
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr14758694plb.25.1561422123419;
        Mon, 24 Jun 2019 17:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561422123; cv=none;
        d=google.com; s=arc-20160816;
        b=PTeSFlfhm59RBiF/9b82QeLsX4ZD/nxYtE9niQAi//UXVdNqrMR+pbcdN36/jDChbR
         auJKNNX+NvoGigujb09KL8e5ue3BtSWNE61uOWQH3V/X7+s5toElcGTSZE0BSV77uN99
         n4BtY1WFjjqqmb7SYLms9IY1S0VGsrBSkPkEqbRZY8WfDxL1HNUGB8K/b6urZYJJCWSI
         ZxO2f4v5k6YcUugmrMHfLUjH0+ZT57R011MurTJPzqj4m/DoQZh73hslN15EZ9c9nUxq
         KOLmOJvlQLR+xFbyJtlXYZ+8bs1oZ22Vlpakgzxih+hY9fZYZYLz1v9dPxoZUMt48FOf
         KGjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=T7DwszIH6Vg5Lzuq4GDQX3dAFFq7h/uJlY/TUYoAObM=;
        b=UZhuOpDiUL8vV0Wim7FlEbQZqcZdoTYPKwnYD2SD3Hx85zy9NINxjgnZodK78VFgFc
         TEIyokVt2dOseE/CcKQRtIHFq9MVij+QuufCk8/VrV7cu+SDvJ6J1MocKJJfNyssvaln
         rzk+5PVfFLUM6JxBo4r0gAiLQP75Oi+CpIMrxZFmFapGg7HVa0+b8RBNLZYhbYD6fLdv
         0kJrsEw5ZN7Y3nYsU1L9uwh8J4oP7oKFd4DvJ7afD87fs3O/cERF62vE10n0+HxNgj3U
         TG6fG0HUdEMgClZJsvDeDWIrFD8Ry/DcZ0pej1T1ePG1v4oTNPx8f7ZyEMgBYEWe2Jr7
         bcNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iaZcsMGU;
       spf=pass (google.com: domain of opendmb@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=opendmb@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor809934pgj.57.2019.06.24.17.22.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 17:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of opendmb@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iaZcsMGU;
       spf=pass (google.com: domain of opendmb@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=opendmb@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=T7DwszIH6Vg5Lzuq4GDQX3dAFFq7h/uJlY/TUYoAObM=;
        b=iaZcsMGUqQlurRX0i3Xesu0XzlVzbmR1e9NkBBm1eOP2eQKwMuaEkCSwig0P4FZA1t
         4XzmWPIUy2ZbU000oUTQiitUAOOVWQUDLAFXAkqVTiB/BOKhCTI8l7kUvmlifG64c3rW
         G0doKdrgaZxuLaqKGtytqAggvIYEbeKgbUQaThyWcgqe1gL6JQrN48jCBIoLKcrN0Uyf
         BCfszognm0RtgIViZIrmPms1Au/eYGN9HSCvx49DyOu7ICf/HjihDNDZI3f6sS7tE7Yd
         fuoYkr2lhZOhiaTAZFVY2EVM02mWpVULVolelLGF1+VCm0qaivdvGy/gwxEll+Mu77MY
         SwaA==
X-Google-Smtp-Source: APXvYqzPM49rOZ8vmVvwAtovOCK0SCaWGfo4w+Ak62VDZnpyFCw2j0kqppwfk3cfPTPcxEwFsSdKIQ==
X-Received: by 2002:a63:a506:: with SMTP id n6mr30915336pgf.161.1561422122677;
        Mon, 24 Jun 2019 17:22:02 -0700 (PDT)
Received: from stbirv-lnx-3.igp.broadcom.net ([192.19.223.252])
        by smtp.gmail.com with ESMTPSA id f197sm12607324pfa.161.2019.06.24.17.22.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jun 2019 17:22:02 -0700 (PDT)
From: Doug Berger <opendmb@gmail.com>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Yue Hu <huyue2@yulong.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	=?UTF-8?q?Micha=C5=82=20Nazarewicz?= <mina86@mina86.com>,
	Laura Abbott <labbott@redhat.com>,
	Peng Fan <peng.fan@nxp.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	linux-kernel@vger.kernel.org,
	Doug Berger <opendmb@gmail.com>
Subject: [PATCH] cma: fail if fixed declaration can't be honored
Date: Mon, 24 Jun 2019 17:20:51 -0700
Message-Id: <1561422051-16142-1-git-send-email-opendmb@gmail.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The description of the cma_declare_contiguous() function indicates
that if the 'fixed' argument is true the reserved contiguous area
must be exactly at the address of the 'base' argument.

However, the function currently allows the 'base', 'size', and
'limit' arguments to be silently adjusted to meet alignment
constraints. This commit enforces the documented behavior through
explicit checks that return an error if the region does not fit
within a specified region.

Fixes: 5ea3b1b2f8ad ("cma: add placement specifier for "cma=" kernel parameter")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 mm/cma.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/cma.c b/mm/cma.c
index 3340ef34c154..4973d253dc83 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -278,6 +278,12 @@ int __init cma_declare_contiguous(phys_addr_t base,
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
@@ -308,6 +314,13 @@ int __init cma_declare_contiguous(phys_addr_t base,
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
2.7.4

