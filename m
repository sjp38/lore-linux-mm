Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42FD9C10F0B
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:08:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 000592085A
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 21:08:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hwbzo9WY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 000592085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7958E0136; Sat, 23 Feb 2019 16:08:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A4A68E009E; Sat, 23 Feb 2019 16:08:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81F2D8E0136; Sat, 23 Feb 2019 16:08:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8C58E009E
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 16:08:31 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id f65so81159plb.3
        for <linux-mm@kvack.org>; Sat, 23 Feb 2019 13:08:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xj0h+jCsZ6lEZUsgZyFFwu1Ty3q3bWmXHRVFOAP4ESw=;
        b=mRLXfp5yWBBNtrvk1CLD25k2jMvd2FU8hb7/qmMSDjgoq1VXtcYZiTYUNXK00WFpbQ
         NfQJ9e/UagYl53z3Hb3o5o6yPhMeKX7rgcbXUwv6RAQ2FnMf0yKh+yIao75L2E/8gxj5
         Y6WwYyL1DyaE9TWVutpUftaPmcjOlsf3+aBTRhZR9X7kIpMTeWmOk5zjXIZop1mjK6nO
         lkpyKgSaM1VYu5fnQlPXiVvGqNruH4qBrpIMs1l9ynd2T875fQazmthuwkgoXO79QiPP
         h7nJUOjQMwl2TJu0XZ1RD0oIX0/cuD3TlONzhPDjArloPywjJimyXscQXQufAzf0Nbfk
         Hd6Q==
X-Gm-Message-State: AHQUAubXdyepkerKrO3AUnnLqjcosEO34w37XcbJG/P51eOwkSRG229i
	ZNKtBn6GXvB586x7VEVc2LLa9C3LOPRyFUpU2IxoSXBeyHlOBncym0mlWJIMfatiCCvcaFv/vLM
	aMVuLoY8168hHjOmBsq7YMuudNRn2wldZ2Ss39MvzRKvC177iIwm9gRmpbTq4dvl0cA==
X-Received: by 2002:a62:e216:: with SMTP id a22mr10994420pfi.20.1550956110936;
        Sat, 23 Feb 2019 13:08:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6eWTmr62OqvICOVep7J0F5KvJxEcin1tjGqIk8PH/uLb7lZoFVTl6Udkhz+ioLvQQcSEA
X-Received: by 2002:a62:e216:: with SMTP id a22mr10994374pfi.20.1550956110133;
        Sat, 23 Feb 2019 13:08:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550956110; cv=none;
        d=google.com; s=arc-20160816;
        b=p2kwwuMSc96C3tA4j5ajZ8DVwmbC7yUnh+QAo5skQiG8a6cQ6K3Y+pj05abDvTpj1w
         G7qF2DZfVSsNNYKLxmOFSSlZDIVY37c8BYEiHzy29cwkassSmJiwZ47JOSynELIPyVbi
         fEcuwYtKFjWm0iDUjWR44dhwbJq5GEyaDYqSdNB6NLpmIq93urvCyaQaDIyOg2gaVuLL
         C6Lo8d8xkhpmNA8VgWuFosyqEUEFQJSJt/UYOxKftJRQKyBhNWDvg7jRDgPsf/cudKt6
         09lbOFCJHwCd2MYhHN7QrV45PA+zr7ENZQ0g/iD8Be306FDuLjc9szMkYBx2OTEOCSW1
         UJyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xj0h+jCsZ6lEZUsgZyFFwu1Ty3q3bWmXHRVFOAP4ESw=;
        b=BvHp7w3cVXKi8m5mlfDn300OcJBFW6VFzHx9Kim6vUiBh7aFRA+NLXJYhwc0JIIeAx
         L2ElcbAD7nXcMNrY+gqd8ObXdwLNOY85mcVR/50K5gHtFCpseSTVPvtrtU/OVuPvBX10
         ZHRj6R07YHNKNq19v+iQcd8h/ikc5uKqsFHHyF57NgljGacZeXIGlH0S70bhsUHqHVZz
         RzHPfR0DNXE4maiUw79o+svbWxwcrXPIsVEdMJhsFiFk2tZXrVTAPJkzPYxUcnPbYXeQ
         KQzZb86uX2H9A3K9+UEriqUlADMR1yqf3FXzdsx2n1tEvqSvI+mumO9ynbNpWmWUpmAa
         HPzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hwbzo9WY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m5si4566671plt.12.2019.02.23.13.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 23 Feb 2019 13:08:30 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hwbzo9WY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 752C82085A;
	Sat, 23 Feb 2019 21:08:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1550956109;
	bh=c2i2Gyx1npLObHnijvE8ts1oBzX7LEDxGpKaceFI5tk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=hwbzo9WYlUfU1lH2YSXvr1Yiw4QkMUtrj2kQVcU6WsddfvRHqXZAfg0Fr/gcJV/zT
	 jNh8EQ3gQr1A92K6thh1/SmmcvW7eUGtlWNeaC7yr6P9dZ49h8qp4RzurjvWUWtwC0
	 tAKgZlJWE4xOpeuVxZRB5rmC55ZwJrGxtk9qQ9Xs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 61/65] mm, memory_hotplug: test_pages_in_a_zone do not pass the end of zone
Date: Sat, 23 Feb 2019 16:06:36 -0500
Message-Id: <20190223210640.200911-61-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190223210640.200911-1-sashal@kernel.org>
References: <20190223210640.200911-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Mikhail Zaslonko <zaslonko@linux.ibm.com>

[ Upstream commit 24feb47c5fa5b825efb0151f28906dfdad027e61 ]

If memory end is not aligned with the sparse memory section boundary,
the mapping of such a section is only partly initialized.  This may lead
to VM_BUG_ON due to uninitialized struct pages access from
test_pages_in_a_zone() function triggered by memory_hotplug sysfs
handlers.

Here are the the panic examples:
 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=2050M
 --------------------------
 page:000003d082008000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
   test_pages_in_a_zone+0xde/0x160
   show_valid_zones+0x5c/0x190
   dev_attr_show+0x34/0x70
   sysfs_kf_seq_show+0xc8/0x148
   seq_read+0x204/0x480
   __vfs_read+0x32/0x178
   vfs_read+0x82/0x138
   ksys_read+0x5a/0xb0
   system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
   test_pages_in_a_zone+0xde/0x160
 Kernel panic - not syncing: Fatal exception: panic_on_oops

Fix this by checking whether the pfn to check is within the zone.

[mhocko@suse.com: separated this change from http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Link: http://lkml.kernel.org/r/20190128144506.15603-3-mhocko@kernel.org

[mhocko@suse.com: separated this change from
http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com]
Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Mikhail Zaslonko <zaslonko@linux.ibm.com>
Tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Tested-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory_hotplug.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 34cde04f346d9..ff93a57e1694c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1299,6 +1299,9 @@ int test_pages_in_a_zone(unsigned long start_pfn, unsigned long end_pfn,
 				i++;
 			if (i == MAX_ORDER_NR_PAGES || pfn + i >= end_pfn)
 				continue;
+			/* Check if we got outside of the zone */
+			if (zone && !zone_spans_pfn(zone, pfn + i))
+				return 0;
 			page = pfn_to_page(pfn + i);
 			if (zone && page_zone(page) != zone)
 				return 0;
-- 
2.19.1

