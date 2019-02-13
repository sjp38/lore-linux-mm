Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6304C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A76B222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:42:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PNVepkl6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A76B222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A9208E0007; Wed, 13 Feb 2019 17:42:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 15AA78E0001; Wed, 13 Feb 2019 17:42:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06F398E0007; Wed, 13 Feb 2019 17:42:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4D1D8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:42:18 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id b8so1423895wru.10
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:42:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=NYLcPf4PhDTfluHGTJ2dshFnd/hJDB1aj6PZ9aFFDduSj290pEv8sCG5Kau+LHhs+2
         s0euHu8yTiOeeens+bqmEteR/NMaMfx07ikIpm48zTbIUE2Krvr+oNKHVDMP1MMR1Q+I
         nrP0FGsUJYCBYabq+wXwLr+awG061Rgim7WAiilgnpnYKcJJJdJs9jV51KPSdwr72/lx
         Sei6xA13c2ex2VuPXsTMCfITxKDpnSVrMZiYUGXHkMcxXrSD96J7Gk1zEoTXsTdRozGO
         yeDRobV8j9Bpy264RdHMRmKffkkklZkZrIpYiHGm1SAOwYY10M1cKg2jLFlQG1c8q7Je
         hWfQ==
X-Gm-Message-State: AHQUAuaOTkxbXhif7MdifNgHRVDwAx5dnseaXG49lw6azlIK4qPgOobg
	lh+LjN2aOszAVGJmZGiwUM5kaktEL9ly12Wr2hhhXHxDMTBylgd+com4tD884qzs2udIgK9Niz/
	dlaksUif86MJ2K+MofbfvR9Un7eUlabEy3NCqmt+X/QgaeakVsdygHsjzka4CLp4jWFSbZrPv+C
	9hvpScOXq7lvytW5Wd/xYQquo92eyUiTZNIpsN+YgV3kUYS2MTmr6ldPhFOq7cLPZvPoC+uI95h
	kg3+GlIH1Y8Kzt2MiKIuakgEO1UcjbsIKHMJox/dD/f6P+MHMeNT1O5bQonnyw0BYN3SFOG4hPg
	WrR9kCYSYs9ltPGZXIPusmGmsNaiDv/tt4hL4jv48VXoh+t2MuQGSOOyS2/AYuh6dBbj1w7ce1T
	2
X-Received: by 2002:a1c:7304:: with SMTP id d4mr274752wmb.136.1550097738173;
        Wed, 13 Feb 2019 14:42:18 -0800 (PST)
X-Received: by 2002:a1c:7304:: with SMTP id d4mr274713wmb.136.1550097737138;
        Wed, 13 Feb 2019 14:42:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550097737; cv=none;
        d=google.com; s=arc-20160816;
        b=ea32TTZfql8fA90Xe9wvpcC0GBtxCzQtcMoPrZe6ClqqOfHx3Dvp4PjLnIWnfpkRr0
         W9cfo/mGQdP6Pe71eszCAQFcLw3M8gquGe6IJIXVWip5fpKZUre455TiQxF0I5v9biBs
         R1yDGwtgGG9ZhWr8cL5ZDA+ok4P7fxTsu4WcmQJrjybbY0YVGsIeRHGgiYoQM7WfiJCu
         H+GnGD9OH8BSS/lC/VPk2BkcSOpBnl9/+MbLdmSnoDf0Eoy1TXrzLvH8NcQ5bIpcF5eg
         JIsHCJOiq+OQ3yvVEZxw9AV8A2RU0jj3aGBcSZ3NrHGxg9rZK1LvojOnp3Qlovq0gxLa
         oJCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=FhM+gWRprXsj4d/x1afJa2lx/TvegK5T5ka7PCSpj+C9ezeaG+aWo6JMhWns35P0tV
         TLNY2rj3xbPoutU/JAyr6Tm9MP8/jn3SttDbXgstH3Nj4SD7BaT+Efytr7y0Y8D3skVk
         dLA3JKtWXmt6rEmThFMR9K3w2JYvfPChsWyuVEe0F/4wJAerV0MP3Uv/J6qh0Fus8xMD
         PwW3dzUfUM6OSf6ePUJkuKgJJP7/LZBesLh0tSsKgF6gGHruOcCOcp17au8QgBQC8A/c
         l8L13rxI3IaPI6RJncQxpI4II8v21SGnGNLmQsd6pex5QJxKKIY+yi+2KB5vVMxoONGU
         b3TA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PNVepkl6;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e5sor376952wru.29.2019.02.13.14.42.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 14:42:17 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PNVepkl6;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=hnmNnr9YQbwfaI93UrUGE24zBu/XKqtY3CcuY5KmkdU=;
        b=PNVepkl6wnUM5Gny5FQUy8cW58lk/9t/2MXulvttnDMJYmFIRT1s7OQDhJgy7JoYKr
         RENLyyEJtlADc4C3wWCABbcBNHnXBcoU97GOP46rTUOZi8pzqVZgUHorFtxsx6S0m9bo
         8cwStO91nzWS2kMGecQlHxxNYgZSEJk8564FrYQFFBKN79k5hsgwSqoR6L1SUgrG5STy
         6DnBXrTS5lCwPxLO7pNI8vjUAOAOL0lBgIhfFj90qFIvbvWhy2EvSEM+VEn4kc13PxnL
         G3vVyv/a1nxVe44l0Mz6WkwSBr5iEs3AxGCQ+65TWE7c0BkrHQtenb7WOy6oPPulyMcA
         vpRg==
X-Google-Smtp-Source: AHgI3IY2zZ/s+/of06qs5oz7e3UG5TRwg7xiFolsJ/mC0V02SnY5LJL9Knhh3oBwoWb72MhgeMlbNw==
X-Received: by 2002:a5d:5289:: with SMTP id c9mr284768wrv.11.1550097736697;
        Wed, 13 Feb 2019 14:42:16 -0800 (PST)
Received: from localhost.localdomain ([91.75.74.250])
        by smtp.gmail.com with ESMTPSA id f196sm780810wme.36.2019.02.13.14.42.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:42:16 -0800 (PST)
From: Igor Stoppa <igor.stoppa@gmail.com>
X-Google-Original-From: Igor Stoppa <igor.stoppa@huawei.com>
To: 
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Nadav Amit <nadav.amit@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	Thiago Jung Bauermann <bauerman@linux.ibm.com>,
	Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
	linux-integrity@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [RFC PATCH v5 06/12] __wr_after_init: arm64: enable
Date: Thu, 14 Feb 2019 00:41:35 +0200
Message-Id: <c81c8be7d5bfcc234dce969b8be7efad3d18d1b8.1550097697.git.igor.stoppa@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <cover.1550097697.git.igor.stoppa@huawei.com>
References: <cover.1550097697.git.igor.stoppa@huawei.com>
Reply-To: Igor Stoppa <igor.stoppa@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Set ARCH_HAS_PRMEM to Y for arm64

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

CC: Andy Lutomirski <luto@amacapital.net>
CC: Nadav Amit <nadav.amit@gmail.com>
CC: Matthew Wilcox <willy@infradead.org>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Kees Cook <keescook@chromium.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>
CC: Mimi Zohar <zohar@linux.vnet.ibm.com>
CC: Thiago Jung Bauermann <bauerman@linux.ibm.com>
CC: Ahmed Soliman <ahmedsoliman@mena.vt.edu>
CC: linux-integrity@vger.kernel.org
CC: kernel-hardening@lists.openwall.com
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 arch/arm64/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..7cbb2c133ed7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -66,6 +66,7 @@ config ARM64
 	select ARCH_WANT_COMPAT_IPC_PARSE_VERSION
 	select ARCH_WANT_FRAME_POINTERS
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
+	select ARCH_HAS_PRMEM
 	select ARM_AMBA
 	select ARM_ARCH_TIMER
 	select ARM_GIC
-- 
2.19.1

