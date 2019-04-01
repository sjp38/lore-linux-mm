Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DF37C4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4722A20880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:37:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4722A20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDE316B000C; Mon,  1 Apr 2019 11:37:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB4376B000D; Mon,  1 Apr 2019 11:37:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCA016B000E; Mon,  1 Apr 2019 11:37:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B759D6B000C
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 11:37:18 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 64so6721776ota.18
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 08:37:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8RCKlxZLig/j8+KvzSyfS11/XgCNzk3sasMHjNb2h1g=;
        b=Gi7cyTms8J3lzyMQHnYLSlpl7OlgKl9uK5ipZrgeKEewzbHf7pvmBsrX43cKS7RmFp
         roLCMsP1hv/nLOm3zJRkMzKlojdxsc2+IwEwF5P9fli/qS+ZtfMEkANh3DVKS5yjf9Lx
         FIYnVFcunbe3Lln09F1Zf3u/PvIwtYIs8y/xDKRUJBM32teM/bOXpu+CMyhW0+il1ZQD
         oP0AfMM0ue36cEPEAW6cVQuXN5VxxJkV50YyIo/jFiRhUjiFCOJiEuztVMLCQ1HIPuCl
         tOsl4OtTfJwg74yigCIPrriR7d77ny5WAlnD2rEHtTMN8v3GUfZK7Vs0Kj3GVOhK61vh
         wtQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAVe9JiH9x+EnhgLVmsy2rW5Zi0U+P+m0aFE+jNSL98wuR4v7GZI
	myMoKaLtZPLx1bDgMwQ821xUou4Ig31g5ETosaedDJyKXUNAGgJPrBLULIj+Iz8r5tg5BRGviSb
	XbtMOk/60X6P9KMoKYIvD0ekBcbuIQgl9v/Xr38c611mQshqqL01QPlMgl/dnZePXJA==
X-Received: by 2002:aca:ecc5:: with SMTP id k188mr12459937oih.125.1554133038317;
        Mon, 01 Apr 2019 08:37:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyv57GVsIxc4znep9PbyVT60jSKWefIQkclVooysibTPnpS/gabxRhejuPNjzW2Um/cdmlu
X-Received: by 2002:aca:ecc5:: with SMTP id k188mr12459840oih.125.1554133037099;
        Mon, 01 Apr 2019 08:37:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554133037; cv=none;
        d=google.com; s=arc-20160816;
        b=MVp0c053pq71AnBw2yuo3H3fRsNfH7418uejiixwMlrFJM62mNDVmG8uvAe8kvzuB8
         TO1B6ljEQBDbdXMRsKdx4PnPGMzbaYAJXoWOAk+bn3nHGsIS6SBkj+WMUOBCb2DEY7pO
         sTRr/eQegI2eog37Qdphc/rdmvM9oHJVQdnS4WNI20r6XBSHSb0kBJxWf0C+wTcVBlSC
         p1l6UAXmHVyWpxj7RUyUGzs7MgievEYtOZd8LO+5p080hoJPFnvyag2fec/gEwQWIfGY
         zla2XlbFw/fvBKjsdiavr268jLWk7/zkuTrHmHAS83OuUc2XVNpNBLXDIXHYf/gXkXHZ
         Eyag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8RCKlxZLig/j8+KvzSyfS11/XgCNzk3sasMHjNb2h1g=;
        b=XVI0NDVgPDO68HrKuuwZ4GylI7sKjwelF4Y+GcNLTRkx9DttsMvTqcWmbI5P9Ey6zW
         TBw04FLTu2xWYaX9iS/n7TzVV1fT9TaZjBnQ13onLfVKzAiZQFf+LnNsSoclXsRPi4EN
         Atz7JYus9c67w3ZWsYXqxqJi4orwNYnZ04XC0t4eH4bOoTeGLxdg0AdTy0KkWBo3PLm6
         FjGqS2WDQlFaww2Arwzscs8DdG5kI9xk8iKebp1mPQT+iQUUvXcuGBEPs4uz+z6APUr8
         Ihqu9DaunqCG8jmp6tQnPB5jgU0ckDSHf2OH4zxm/zUdTzugqAhFcdg/xWvjT7JVjxn7
         fu4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id k133si4312489oia.185.2019.04.01.08.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 08:37:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [10.3.19.214])
	by Forcepoint Email with ESMTP id 98D9D3E39DD5515E0BB5;
	Mon,  1 Apr 2019 23:37:11 +0800 (CST)
Received: from FRA1000014316.huawei.com (100.126.230.97) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Mon, 1 Apr 2019 23:37:01 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
CC: <rjw@rjwysocki.net>, <keith.busch@intel.com>, <linuxarm@huawei.com>,
	<jglisse@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [RFC PATCH v2 3/3] ACPI: Let ACPI know we support Generic Initiator Affinity Structures
Date: Mon, 1 Apr 2019 23:36:03 +0800
Message-ID: <20190401153603.67775-4-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
References: <20190401153603.67775-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [100.126.230.97]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Until we tell ACPI that we support generic initiators, it will have
to operate in fall back domain mode and all _PXM entries should
be on existing non GI domains.

This patch sets the relevant OSC bit to make that happen.

Note that this currently doesn't take into account whether we have the relevant
setup code for a given architecture.  Do we want to make this optional, or
should the initial patch set just enable it for all ACPI supporting architectures?

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/bus.c   | 1 +
 include/linux/acpi.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 6ecbbabf1233..0ebc4722d83e 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -315,6 +315,7 @@ static void acpi_bus_osc_support(void)
 
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_HOTPLUG_OST_SUPPORT;
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_PCLPI_SUPPORT;
+	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_GENERIC_INITIATOR_SUPPORT;
 
 #ifdef CONFIG_X86
 	if (boot_cpu_has(X86_FEATURE_HWP)) {
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index d5dcebd7aad3..cc68b2ad0630 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -503,6 +503,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct acpi_osc_context *context);
 #define OSC_SB_PCLPI_SUPPORT			0x00000080
 #define OSC_SB_OSLPI_SUPPORT			0x00000100
 #define OSC_SB_CPC_DIVERSE_HIGH_SUPPORT		0x00001000
+#define OSC_SB_GENERIC_INITIATOR_SUPPORT	0x00002000
 
 extern bool osc_sb_apei_support_acked;
 extern bool osc_pc_lpi_support_confirmed;
-- 
2.18.0

