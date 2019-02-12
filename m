Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A83DC282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5E46217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:50:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5E46217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AF758E0006; Tue, 12 Feb 2019 11:50:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55E2D8E0001; Tue, 12 Feb 2019 11:50:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 474238E0006; Tue, 12 Feb 2019 11:50:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 181CC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:50:42 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id s143so773244vke.7
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:50:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=22u2nzQfQfmqHyKDhVuCSOwYEX716Xpo/VCkQkdinJ0=;
        b=gdLpQ1/0cHK3LAIIz0S6UTIDcHda2ichg/6P5hOGvjcIghDTX8VZbfgRQQxp4Al6gf
         U6e4lahb/xuVqFwAJ4ia913aPVlxnAtridB0Dc1T98YD5WCvELHwwOtkquphe9K2+dI6
         oetjygU8iG4oObqk6ZEXDj9auf1AKhPkxDOjBfBkCevU2atq4ZSNS/jAQH6XsdpZvhKy
         sfMMSsMEh5tqJtyBAiN7P0fOS99ipoF2o00jKRLde1lHRv6iR7awxMCD7sd801CLq/pI
         lMhAWHb2WqNylE9nslUbiMBWr3aejmRKTCnlF1DOqEo55Kjuk2jbAdlDQaK/K6QeUwHz
         k3CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuYX0O+8WENPoKCV+nw/efT1AMoJwRIwmC44nAa+qmjnmcQUOR3t
	K4JvyUpTPh2YrPaciZkaI5qJmhVOuV3ct4OMvd65QEPamcBYOSmgYVCGHJZAotXS7MtdlGvv9tA
	SGBmV5915wE8KyM29/Z8avr80t3FWDMYkMZAgAmnfyKUhJzpCmOVGq50LdQ9AZEz77w==
X-Received: by 2002:a67:485:: with SMTP id 127mr1936070vse.54.1549990241802;
        Tue, 12 Feb 2019 08:50:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbpCm6Dv03DWu3FjKeCQK/PlOobYmjQTshD8sCPY9cSeSgBefR6kkZfoZpFxpJGfyMFnv0F
X-Received: by 2002:a67:485:: with SMTP id 127mr1936052vse.54.1549990241045;
        Tue, 12 Feb 2019 08:50:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549990241; cv=none;
        d=google.com; s=arc-20160816;
        b=su7SnIaHDz/1GpHSwihxyeeYygkGxbjx7TS6N0XHMYf3+HUFmaNaVGtrkSR1KQBa0B
         nIDivN9gl9ocNLyN6VbAj0n/FkFTZc9M/Ii5XKB6ILhAAOCx7IULUpq4ueQTlNe2g28j
         ksVn7CuNkO+hIZKrV8psfGYaVr71hm39bzmmnRber2awpWeqSQvFSMQi1mEjQ/kY98Vu
         8Cmok2d7EVMKYVrYAR/Ez+IwS4Rna7HSNk3+oQcl6Qilzw/DhQbESwfdsJzBM8b/pQ3c
         h+NhCBLzRdQsRMP7+QkA5MSUnOAF+ozinv42lLi/0XacBywOGTEbAHiEQeP03A+r/+9q
         6oxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=22u2nzQfQfmqHyKDhVuCSOwYEX716Xpo/VCkQkdinJ0=;
        b=EoqmWbqrvpAERVBo2ew8/cBat3IZ3z7FO0CETzBtjPqywA4Jfy5hejQAQZBY+xDpJC
         H8jRuo0I46CdL7vCoR689wUKAWaxTyoWa3gg7FdcSdwJswcyZ9jCNsb2otEVnw/K+1NM
         uVRxflkc7yqkZY0GZhYq9YQDfSAtqX3CQZ8n3bueO6zPKNjQHnZvQ9tgQG7fNZRkulzE
         mINeGXOs0owVsUDZLpJi1y9gxmqNzbPsEEx0bI587Jv5XyC6bGT9Wm44X48T9+tzymxc
         gyO/dXxAjQSXwXYqSw4YdTzACQkm67l7/mhkuVcZEmUdECRrgnx6Na2UGstoWNTHuI2h
         O1lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id g133si6248737vsd.297.2019.02.12.08.50.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:50:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id DBF00DF7E33A091663B7;
	Wed, 13 Feb 2019 00:50:36 +0800 (CST)
Received: from j00421895-HPW10.huawei.com (10.202.226.61) by
 DGGEMS414-HUB.china.huawei.com (10.3.19.214) with Microsoft SMTP Server id
 14.3.408.0; Wed, 13 Feb 2019 00:50:26 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <jonathan.cameron@huawei.com>, <linux-mm@kvack.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>
CC: <linuxarm@huawei.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, Keith Busch <keith.busch@intel.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, Michal Hocko <mhocko@kernel.org>,
	<jcm@redhat.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 3/3] ACPI: Let ACPI know we support Generic Initiator Affinity Structures
Date: Tue, 12 Feb 2019 16:49:26 +0000
Message-ID: <20190212164926.202-4-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
References: <20190212164926.202-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Until we tell ACPI that we support generic initiators, it will have
to operate in fall back domain mode and all _PXM entries should
be on existing non GI domains.

This patch sets the relevant OSC bit to make that happen.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---

Note that this will need platform guards unless we make generic initiators
work on all ACPI platforms from the start.

 drivers/acpi/bus.c   | 1 +
 include/linux/acpi.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 5c093ce01bcd..461fb393346a 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -315,6 +315,7 @@ static void acpi_bus_osc_support(void)
 
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_HOTPLUG_OST_SUPPORT;
 	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_PCLPI_SUPPORT;
+	capbuf[OSC_SUPPORT_DWORD] |= OSC_SB_GENERIC_INITIATOR_SUPPORT;
 
 #ifdef CONFIG_X86
 	if (boot_cpu_has(X86_FEATURE_HWP)) {
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 87715f20b69a..760c6f3d57f0 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -498,6 +498,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct acpi_osc_context *context);
 #define OSC_SB_PCLPI_SUPPORT			0x00000080
 #define OSC_SB_OSLPI_SUPPORT			0x00000100
 #define OSC_SB_CPC_DIVERSE_HIGH_SUPPORT		0x00001000
+#define OSC_SB_GENERIC_INITIATOR_SUPPORT	0x00002000
 
 extern bool osc_sb_apei_support_acked;
 extern bool osc_pc_lpi_support_confirmed;
-- 
2.18.0


