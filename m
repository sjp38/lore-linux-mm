Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C42AAC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7556521479
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="HmsHAFlj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7556521479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 279846B0275; Wed,  8 May 2019 07:30:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 251626B0276; Wed,  8 May 2019 07:30:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F1466B0277; Wed,  8 May 2019 07:30:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B24906B0275
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:15 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so7468925edc.4
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=J2kUTxOBDW7W13uwOdmuJPQDQWhKkMs+dI0VfMHNhcs=;
        b=Esd7REmVmKkANTsLkUkVP5v6eMtgxMztPeAqqxfXdweGrBggpA7675I2B6VgxkpmQN
         4KvRPaPP+T0ctvgZ9Tvju9HedGdiAxXQIt9BLokuSRevAhyZyG6pnBOTOTXv3BadQt5V
         KjD4xaOmz1yM0BMmvgtaD7mUXOPfKsI/teT7g03C20OXrrZ7jNyGHEj/VBFpQVzOpzg+
         GgVOjCs/bRbr9CrPUt/SXBK0FRa28H1WNNa/H3Nz8nDGQhbFLLR9Ud3d4iUX3YHbj3bO
         R5vrFgs+8xwQu/YQUYDGB55/IgpeHDWEJnOj5emj9UWTRX/QYlXU7NUkGnV3yBZFFuy3
         TxxQ==
X-Gm-Message-State: APjAAAVPY92MFJ8x0ctvo/A6O25MW7yyZ7GPhIcZPiw9LaxypeYBdeE2
	kiXhEDWn0EdKTNuVRocKJZEjs/9XWCeVoK+FO9N3P+booVpPWaEuuSExr0DDZSjwjrl02RslhIc
	rVPYCeAVsIfkXf0ur5CyJ+2Za0iMXSV5lj3js6HD2FGKabt5NHjvWcldPb0O87ISW1Q==
X-Received: by 2002:aa7:d28e:: with SMTP id w14mr39794097edq.119.1557315015162;
        Wed, 08 May 2019 04:30:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn05vYgoQrR4zhWPRNjO6YroGw5orUZu4jsQw/tC+JIs/13ScUvNNbywJ8Zq2zxIvFV+1H
X-Received: by 2002:aa7:d28e:: with SMTP id w14mr39794012edq.119.1557315014300;
        Wed, 08 May 2019 04:30:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315014; cv=none;
        d=google.com; s=arc-20160816;
        b=hC0gAtdcPIpNhCVofzkbWKcMChdZcvI2uFIxUfyu9Ema0QAKtCXlOBfw3NO4pVA/ho
         dC1eCwofilGRZmKqtre4t3V0ziOechTKq32uOIUX9nuHjaC9MXjrB1qSWOhFUR11PW57
         uHQnIOZnUHa74GNSFWys4wwuelh0Jcp0Ce0eugKYdlj0dGXqLAg7sJmPx5a16e/6pMIi
         TZQYCgHcIU4eI0JOs4M1CSVRa9tC4IUvcE8XHmHk9SOVIylPIivX4Bo8z/wquBhpRu/n
         aCnAlStCd0vKowU6kKy7QZPq/rW+cj4MmnJFVyuZnyCHHr8dTDK8wkM735MPzdA0quuO
         OgTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=J2kUTxOBDW7W13uwOdmuJPQDQWhKkMs+dI0VfMHNhcs=;
        b=QEbXfPPF2qfaSF3Pl52cw+YzYc802j/ZEJ7jhAYQjVA+ucc3qKyXnZngBbNY0sEA7t
         GDfJ5H5TH7q0BZsQBNkf5IIVkfJwXbmArT8etQW+iAj0zbduLSuWp1E7ya9z9jufkEfd
         PsTKc8IYto03Bi/GEtpgK3+/F2S6uJMYdUgpO7lbsbFQSmA5UKzqjBnYF0NfltrEIrep
         hT8A68SMSKyedV2cE1FndH2glUBW/WjPMy2F2ZAHTidLwvPMGMV1F0YKGzg/cMlJpCos
         PqW7Biqt3MZ4UfUas+zWXv1oedNT9Z/KfpenWT1JcPX1emTBu8v9pShjPvObCMzSZBXO
         8dCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=HmsHAFlj;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.82.45 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820045.outbound.protection.outlook.com. [40.107.82.45])
        by mx.google.com with ESMTPS id w18si3098920ejz.371.2019.05.08.04.30.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.82.45 as permitted sender) client-ip=40.107.82.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=HmsHAFlj;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.82.45 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J2kUTxOBDW7W13uwOdmuJPQDQWhKkMs+dI0VfMHNhcs=;
 b=HmsHAFljmcbaN1BpAlIGHCpGcJ5jk39AUEqf/6w5Fch3rgS9LrOHdDkTRid4twIc316F2MrfuNLVkUGQ1NWLbgumQMbITyYa+XILsOarTTI+P/wjFyGQgnt0YjzNFAD0f6jVnTLQ0U3CRal0YHtfYbnJ7fVybRtPPhSGo+MDAbc=
Received: from BN3PR03CA0078.namprd03.prod.outlook.com
 (2a01:111:e400:7a4d::38) by CO2PR03MB2262.namprd03.prod.outlook.com
 (2603:10b6:102:e::25) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.11; Wed, 8 May
 2019 11:30:10 +0000
Received: from CY1NAM02FT020.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::209) by BN3PR03CA0078.outlook.office365.com
 (2a01:111:e400:7a4d::38) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 11:30:09 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 CY1NAM02FT020.mail.protection.outlook.com (10.152.75.191) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:07 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BU7gu023733
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:07 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:06 -0400
From: Alexandru Ardelean <alexandru.ardelean@analog.com>
To: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	<linux-ide@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-rpi-kernel@lists.infradead.org>,
	<linux-arm-kernel@lists.infradead.org>, <linux-rockchip@lists.infradead.org>,
	<linux-pm@vger.kernel.org>, <linux-gpio@vger.kernel.org>,
	<dri-devel@lists.freedesktop.org>, <intel-gfx@lists.freedesktop.org>,
	<linux-omap@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <linux-tegra@vger.kernel.org>,
	<devel@driverdev.osuosl.org>, <linux-usb@vger.kernel.org>,
	<kvm@vger.kernel.org>, <linux-fbdev@vger.kernel.org>,
	<linux-mtd@lists.infradead.org>, <cgroups@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-security-module@vger.kernel.org>,
	<linux-integrity@vger.kernel.org>, <alsa-devel@alsa-project.org>
CC: <gregkh@linuxfoundation.org>, <andriy.shevchenko@linux.intel.com>,
	Alexandru Ardelean <alexandru.ardelean@analog.com>
Subject: [PATCH 09/16] mmc: sdhci-xenon: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:35 +0300
Message-ID: <20190508112842.11654-11-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(396003)(39860400002)(376002)(346002)(136003)(2980300002)(189003)(199004)(356004)(6666004)(36756003)(5660300002)(50466002)(48376002)(2616005)(126002)(426003)(336012)(107886003)(51416003)(44832011)(2906002)(47776003)(486006)(2201001)(4326008)(476003)(11346002)(446003)(86362001)(76176011)(26005)(16586007)(246002)(478600001)(2441003)(50226002)(53416004)(1076003)(7696005)(70586007)(70206006)(7636002)(305945005)(7416002)(106002)(77096007)(8676002)(316002)(186003)(110136005)(8936002)(54906003)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:CO2PR03MB2262;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 8666f1cf-9df3-40da-2f35-08d6d3a88708
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:CO2PR03MB2262;
X-MS-TrafficTypeDiagnostic: CO2PR03MB2262:
X-Microsoft-Antispam-PRVS:
	<CO2PR03MB226289536B8045C7EF017BB5F9320@CO2PR03MB2262.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:6430;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	7rCCvmL00MJBmcDTDIesTQyTH/FNWfXEsju68ENrTwxg/JIcze2MSJ12BbCQi4KSrgLnc1A1T6oXYLKYxlqmijCkcIwNL4E9xzrBeXjIFArc3gJbJYEsik3rWIiMQrmNac8NKVSXbLpB/o4OjBebxyfuuKkkNtQJJAndo0715UIZuDMc1ZdvuMrceL8LElXSfQiRCtrBNnkB/KWkSmtT8hsShWBcIskk5FP30zXoYxV/z2dgb6eFA53PQRv7N/xDDavBCp9yNUm4NynSE3PGnYKIawmDQ1m2K8VQatJsc8AN1TyPmq9PF1A8pLI6egBZrXN35GHe2/ZpHJhBxPEZoVlVwSfSUS96GPx1sw2lCVmgt88RgJFlddOoDGa3f1+TOqJw2fXL5R0yGXI+tAlczYBs61mJT3hH1NvT9TI8S+8=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:07.6794
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 8666f1cf-9df3-40da-2f35-08d6d3a88708
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO2PR03MB2262
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The change is also cosmetic, but it also does a tighter coupling between
the enums & the string values. This way, the ARRAY_SIZE(phy_types) that is
implicitly done in the match_string() macro is also a bit safer.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/mmc/host/sdhci-xenon-phy.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/mmc/host/sdhci-xenon-phy.c b/drivers/mmc/host/sdhci-xenon-phy.c
index 59b7a6cac995..2a9206867fe1 100644
--- a/drivers/mmc/host/sdhci-xenon-phy.c
+++ b/drivers/mmc/host/sdhci-xenon-phy.c
@@ -135,17 +135,17 @@ struct xenon_emmc_phy_regs {
 	u32 logic_timing_val;
 };
 
-static const char * const phy_types[] = {
-	"emmc 5.0 phy",
-	"emmc 5.1 phy"
-};
-
 enum xenon_phy_type_enum {
 	EMMC_5_0_PHY,
 	EMMC_5_1_PHY,
 	NR_PHY_TYPES
 };
 
+static const char * const phy_types[NR_PHY_TYPES] = {
+	[EMMC_5_0_PHY] = "emmc 5.0 phy",
+	[EMMC_5_1_PHY] = "emmc 5.1 phy"
+};
+
 enum soc_pad_ctrl_type {
 	SOC_PAD_SD,
 	SOC_PAD_FIXED_1_8V,
@@ -821,7 +821,7 @@ static int xenon_add_phy(struct device_node *np, struct sdhci_host *host,
 	struct xenon_priv *priv = sdhci_pltfm_priv(pltfm_host);
 	int ret;
 
-	priv->phy_type = __match_string(phy_types, NR_PHY_TYPES, phy_name);
+	priv->phy_type = match_string(phy_types, phy_name);
 	if (priv->phy_type < 0) {
 		dev_err(mmc_dev(host->mmc),
 			"Unable to determine PHY name %s. Use default eMMC 5.1 PHY\n",
-- 
2.17.1

