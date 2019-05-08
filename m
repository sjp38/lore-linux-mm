Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1136EC46460
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9C3214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="uLO3LXwd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9C3214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622956B0283; Wed,  8 May 2019 07:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D28B6B0284; Wed,  8 May 2019 07:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49ABB6B0285; Wed,  8 May 2019 07:30:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE0B6B0283
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:50 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u15so21371408qkj.12
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=1pGxpqtswe0uDTJtCA9b8Plg8X12C8ZZ/KC5tO0ZuVQ=;
        b=YsjxDNyIVSn0+VXXH074gTLFhRyj02XobftaeFo3jLzWElw5Fjekkk5d/1CAQRCfbW
         nFc9r2/R2P6Z6nP73jzVILDfK2theyVstXhJFZtz31RDGiznYrE6GxrKMQDmrOW9fb7A
         kfgf25ezIRiyfQe10GxsEUVcd4QV0MFDb7WQUVppr6Wcq8BO73t/1K6oHq4HUU+MFGEc
         NrnEUJY1k1M/nmBwmdhUjMRYyYJ2MxkZGcAw8R3wNhU7JoRfR55WrGjyM5F6feRvYVog
         tf5khyz18QJUqeH315bGVwjDRx3qFKIU7IPZJQB/0ckPSc37/knApjB//o5UoagxFTM+
         uXLA==
X-Gm-Message-State: APjAAAWJAHjXk7jxv+GpDUFV55+89t4EWVrsFn8ToHg/povg2ljHoVqO
	Uro0MLOqFvxPTry1pt1BvLspqmrocJ9ObYsIB/KV4AwZ0NH0smKVbCVR5darjW6Mqq0AgmwHGxe
	/s37JO0+F/RwMUGD2f3KSCQmlmd/joo3/fgr3EN3lZDOvdVR1OyDJvA8GvUvKbb+I7g==
X-Received: by 2002:a37:b8c:: with SMTP id 134mr11443446qkl.121.1557315049865;
        Wed, 08 May 2019 04:30:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydfxT42I57yMdiG65TSBeka0GtKcBBAEJG1Ij/7B58nWIeUiYzV0Tg33/LyfYrxUyF7Rrp
X-Received: by 2002:a37:b8c:: with SMTP id 134mr11443371qkl.121.1557315048961;
        Wed, 08 May 2019 04:30:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315048; cv=none;
        d=google.com; s=arc-20160816;
        b=v1iG0egDidjIrmJS/J2tnSqTq+XmyBzCYyNg4bkK+oEFzd9bv+lm4TuEL5w+fZ+ZL0
         4Fce8LUOMowe0XTWZofJriSr6RhWLgRx4PVOyDHpe9foC6ZXWnOYGO/0tb7CYjFQBQp7
         HQ9uU0OQw/v2xz6bmkyWjIKw3FV4eR15swRiUlTYmFxkAHFvz1F07jOGVuO+JoNEDY1t
         4/2jbZne6RaUsUHutS3KqEoDvSBArXfXI/WcrJpDYQCgywQAk9J5XVtWmIIQXLjJ3G8n
         EekTWsrPgq9c+ahHdpvseX8cz6lLha8ODXrbd21rCb5osDiKNW3J4yvN+ghTuGXG6gVZ
         CB9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=1pGxpqtswe0uDTJtCA9b8Plg8X12C8ZZ/KC5tO0ZuVQ=;
        b=PgB+MSlrw4gDj3uIQeSbyIgvzOPUFwq2hrBQWo2YA3OHLn2M01MY2Cj0kUB8VCVOwc
         Gaj0lb/taiGsbK/WJjsV2vB9K6v0tPBu0XfBKdEN9OUZtjeXgSdzJbqnPvdQeZre71Gc
         HiWJkIO92L4H0o0+u/x9QQC/vfvffM0WrDommi71EAp1IPXki+fIip6x7cXCfXlwtYpe
         AG5enF337KOHv38EaVwUjSbApKMB/xRMBiBpKgicf65wJi9Q/Ek6C+7QsUFtsouH+UK3
         ddzc8jdr0reJL7K68mpCWFynise6oYf+v75Ktv/fev9G/vUowNH9RYa9iio5/1eGzxtx
         NyuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=uLO3LXwd;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.40 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680040.outbound.protection.outlook.com. [40.107.68.40])
        by mx.google.com with ESMTPS id a2si9271662qta.5.2019.05.08.04.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.40 as permitted sender) client-ip=40.107.68.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=uLO3LXwd;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.68.40 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=1pGxpqtswe0uDTJtCA9b8Plg8X12C8ZZ/KC5tO0ZuVQ=;
 b=uLO3LXwdd1BWamWiK4r+Hw5jvJyCV00LM1cyhqNBKocozKsQvw+ovIXID7g91gMIvPgSp0VMC7EhKj6CA5gnlmoJcz4HY1qoPHGRgatiggRcisFhgTqP51Zl+L8WhLodnCQ/qLq5WxXaZ64lgglcD6lX1+C8qGWvddWXlxnm3bA=
Received: from CY4PR03CA0098.namprd03.prod.outlook.com (2603:10b6:910:4d::39)
 by BN3PR03MB2259.namprd03.prod.outlook.com (2a01:111:e400:7bba::20) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.12; Wed, 8 May
 2019 11:30:44 +0000
Received: from SN1NAM02FT012.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::207) by CY4PR03CA0098.outlook.office365.com
 (2603:10b6:910:4d::39) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1878.20 via Frontend
 Transport; Wed, 8 May 2019 11:30:44 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 SN1NAM02FT012.mail.protection.outlook.com (10.152.72.95) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:43 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BUgbC023898
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:42 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:42 -0400
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
Subject: [PATCH 15/16] video: fbdev: pxafb: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:41 +0300
Message-ID: <20190508112842.11654-17-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(136003)(396003)(346002)(376002)(39860400002)(2980300002)(199004)(189003)(50466002)(2906002)(426003)(478600001)(126002)(2441003)(2616005)(476003)(51416003)(26005)(8936002)(7696005)(48376002)(77096007)(186003)(50226002)(7416002)(246002)(47776003)(356004)(11346002)(36756003)(70586007)(70206006)(8676002)(446003)(336012)(16586007)(2201001)(76176011)(1076003)(86362001)(4326008)(107886003)(486006)(5660300002)(44832011)(106002)(305945005)(110136005)(316002)(54906003)(7636002)(53416004)(921003)(83996005)(2101003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:BN3PR03MB2259;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 19467b0d-82a0-4414-fd3d-08d6d3a89be6
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:BN3PR03MB2259;
X-MS-TrafficTypeDiagnostic: BN3PR03MB2259:
X-Microsoft-Antispam-PRVS:
	<BN3PR03MB2259B45DC5D8696943CC04CAF9320@BN3PR03MB2259.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:120;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	ica2HYRZM4fdZtkxNTO9Gb+CKac0B/LUwaOW4nL6nYW79SYpz0JOGfZuZgqcdALu4tIifExiLGAs6sD77WVSTjIN3M+20mtkK8wI+pBL9/p1PoBSKfZAmfP2KGJVvCgSEHf32wy3PDodr1lg8Yuu8eqBBpgNfg053BOMOeCaI7HFr/B1OJTsQBX/ceRy48at5Iy5hIl80/NoESGq+ZAk5cvin1INqYY3Mb1qILEP4XIZVdGoHNJeTgIM/V0FqkN7/zCsxIYOu/80TBgJdrmS/t2+/MSfdRVyy3pcjddO6858KbsH4xUnc6kYGOjPaFpLAaL+RTif6KsJe22eNbSvhw8CkJVq6PtH4EXETBQCnvcVhQzisGb4TvfZgmQsWRjNXcqE9FtzT+5/kc2FZNz3c0T+2Bori5rG0j1zDojL+ig=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:43.2658
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 19467b0d-82a0-4414-fd3d-08d6d3a89be6
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN3PR03MB2259
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The `lcd_types` array is a static array of strings.
Using match_string() (which computes the array size via ARRAY_SIZE())
is possible.

This reduces the array by 1 element, since the NULL (at the end of the
array) is no longer needed.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 drivers/video/fbdev/pxafb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/video/fbdev/pxafb.c b/drivers/video/fbdev/pxafb.c
index 0025781e6e1e..e657a04f5b1d 100644
--- a/drivers/video/fbdev/pxafb.c
+++ b/drivers/video/fbdev/pxafb.c
@@ -2114,7 +2114,7 @@ static void pxafb_check_options(struct device *dev, struct pxafb_mach_info *inf)
 #if defined(CONFIG_OF)
 static const char * const lcd_types[] = {
 	"unknown", "mono-stn", "mono-dstn", "color-stn", "color-dstn",
-	"color-tft", "smart-panel", NULL
+	"color-tft", "smart-panel"
 };
 
 static int of_get_pxafb_display(struct device *dev, struct device_node *disp,
@@ -2129,7 +2129,7 @@ static int of_get_pxafb_display(struct device *dev, struct device_node *disp,
 	if (ret)
 		s = "color-tft";
 
-	i = __match_string(lcd_types, -1, s);
+	i = match_string(lcd_types, s);
 	if (i < 0) {
 		dev_err(dev, "lcd-type %s is unknown\n", s);
 		return i;
-- 
2.17.1

