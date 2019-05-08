Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C457C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5DF121019
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:29:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="WJZTSX1a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5DF121019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB65E6B0010; Wed,  8 May 2019 07:29:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3E5C6B0269; Wed,  8 May 2019 07:29:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 930366B0266; Wed,  8 May 2019 07:29:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41BE46B000E
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:29:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y12so1356000ede.19
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:29:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=Kj953YF77LM2a2dlESbeNeZmoXGMTjr2NXsCZOuqlCs=;
        b=nayTlChAqff81UOQam4uIUNxlJmjxt+FVqQO9ZdhVt08TJfCaw27vw+PkzV1LP3lPL
         rfo/VoNE8awlYSfWD0vFewY/r3wJBFHyrC/x/M8nLEWmQ7O2hVKBF4uvLdDDm8ARN2bP
         qwEndRqnMzEPgJJ0eNsc84sA2FjzRutziJX/630BR7nF6GTH1Kax0HMjArsudneXPKy+
         Ud75aN5euXnlpj76nBHM3THfGr6xXhi5/Aw/CMLOl9ixMSpR/kXdhJPnLEtKvqkoezXs
         5kOVN/idjbH6GaXOoJSLt0qnaMdoiF2cIPKxz6kBVwLdSZBHBVKvripT9N5US0WwNTF8
         sPxA==
X-Gm-Message-State: APjAAAX31Zz7+C0n+qotQnRz5wZ7WSqr9VMtl1hpUl5uR1ilJWK/5PQo
	IqOm8qX2ETdPto1LHpUHK67koDmve8DFNFrX/84F4fO0RJixnN4/YCgLClYMYJW/hj+rAJ95QoI
	3auy+979OOwqTu4Cg92CtjleZGwRQKek4QheH7bTIYwSZK2U+SCTyRaEykv0Xj44qtQ==
X-Received: by 2002:a17:906:22d1:: with SMTP id q17mr7515170eja.67.1557314969737;
        Wed, 08 May 2019 04:29:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjEg21dK7Fw16lURnpyIBf3yXryNNxlgkEvemPpWWwZ+ciFKKLkH/Ve3/lYyqys/Roh/Ps
X-Received: by 2002:a17:906:22d1:: with SMTP id q17mr7515126eja.67.1557314968897;
        Wed, 08 May 2019 04:29:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557314968; cv=none;
        d=google.com; s=arc-20160816;
        b=Q+GA4nsngWi0lwEJjuMJgeyGcsrHBiiaJyPn5Tz3wIfIh3gDjzd/EOLFMsadZqFdLs
         nt7jCE1jAkGEO6lIpDOKiBW2eYCeUjYKqAki3BMnB2BJrHDxk11Cci8YhLDQ5VuhrhI8
         lAzUgGkgv1TFsZAOgDbtCmi2mfq7JbzRE/6f+qHIVZsc9jE6ylA1ykBMJeIj2OaXpt12
         TWVK5KuAEcEgskG9W5he1QK27Wh6+D7RNaWm+B/7FS9ttLbi3b0kL3eDYhgVVd3FxpCm
         ITpz1R2ldkBJP45RL6eMUexXKCrmEofecF4gJmMeVDu7zLKVmzPd3p4AXBLQnlxxrIzr
         mSGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=Kj953YF77LM2a2dlESbeNeZmoXGMTjr2NXsCZOuqlCs=;
        b=q0mmRr1/tEM2uqSJxT3TP5IPf4CfjTVWWQ+lltbSp2OfzHV24e2lldN+mdjsN+Xrgs
         iOamELuWzLw6GKaVbOnkttJ5XTXUmWsicb5XbFrOVwxcvPiYQENzlXXJyFDLZmL5dwfM
         pzxRn/eZYcuvSymz8f4y7BAc0DOjysbkwoaOFlDPFGuf2XMTiPkT6ud4fpA62rwGmp3d
         qq7usyV4aVXv3FRk9cFr4dBt1FWK2IhA5GFGI1+E5hZ2ZSJMckpO6A4fY9MM4chRmw5U
         h8DIbLxegb6AvIUspsldflpedetNP2cl0SIOK/HJ+4Q8BfsbuVxUD7uCR3le+74c0zav
         GMZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=WJZTSX1a;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.88 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800088.outbound.protection.outlook.com. [40.107.80.88])
        by mx.google.com with ESMTPS id f18si3495366eje.304.2019.05.08.04.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:29:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.88 as permitted sender) client-ip=40.107.80.88;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=WJZTSX1a;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.80.88 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Kj953YF77LM2a2dlESbeNeZmoXGMTjr2NXsCZOuqlCs=;
 b=WJZTSX1adtoqETj2TRceeLRWIxGQHvR1dID/kkYqIH0ExRMXx3PLDqNgFViju8AN0Sz4+kTjFvxDA6O1mxZkwUmRmezZRNZAXeQ+vpJItNYiEeDHKz8yRyy/Sh9wqu8SJNX7ewmBgovN1EDi11UgAewByNzm7zb+uYfUd6bPxPY=
Received: from CY1PR03CA0035.namprd03.prod.outlook.com (2603:10b6:600::45) by
 BY2PR03MB555.namprd03.prod.outlook.com (2a01:111:e400:2c37::27) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.10; Wed, 8 May
 2019 11:29:22 +0000
Received: from BL2NAM02FT016.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e46::205) by CY1PR03CA0035.outlook.office365.com
 (2603:10b6:600::45) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.10 via Frontend
 Transport; Wed, 8 May 2019 11:29:21 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.57)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.57 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.57; helo=nwd2mta2.analog.com;
Received: from nwd2mta2.analog.com (137.71.25.57) by
 BL2NAM02FT016.mail.protection.outlook.com (10.152.77.171) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:29:21 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta2.analog.com (8.13.8/8.13.8) with ESMTP id x48BTLLf016976
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:29:21 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:29:20 -0400
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
Subject: [PATCH 01/16] lib: fix match_string() helper on -1 array size
Date: Wed, 8 May 2019 14:28:26 +0300
Message-ID: <20190508112842.11654-2-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.57;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(376002)(136003)(346002)(396003)(39860400002)(2980300002)(189003)(199004)(316002)(50466002)(110136005)(106002)(76176011)(36756003)(70206006)(70586007)(86362001)(7696005)(2201001)(14444005)(51416003)(478600001)(7416002)(47776003)(5660300002)(54906003)(2906002)(48376002)(2441003)(16586007)(186003)(446003)(1076003)(77096007)(26005)(356004)(44832011)(486006)(11346002)(126002)(476003)(2616005)(8676002)(107886003)(50226002)(246002)(4326008)(8936002)(53416004)(336012)(426003)(305945005)(7636002)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:BY2PR03MB555;H:nwd2mta2.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail11.analog.com;MX:1;A:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 70d6917f-f215-4387-ffab-08d6d3a86a83
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:BY2PR03MB555;
X-MS-TrafficTypeDiagnostic: BY2PR03MB555:
X-Microsoft-Antispam-PRVS:
	<BY2PR03MB55532426C65B1246DCD69A2F9320@BY2PR03MB555.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:8273;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	EkinRue+oHsKHGU9xDPLwqOdJf0rruOZsQl/MCUDoHLxNCdgn+nCd693zRNYU/ul1uHwi/NkPHY62bVRycjk68l9ukT0lp/PIvbvAeGJuTyMBkoJ3LpwJP8AA+6sLGnOa8vypJGw5A8ov1fhv+lnNuk1SC4UW2SeilXkocHeKVTMVkRDO7wzTR6RAbvOq3Phku6T4Mqk2uNO2cTYTiWtoVqA5zyZilUa02oDdwvX2fN0a6JKWMc78cXM7mRR6ztmm/mvcHmERSY8EOpP5AiLIlza+si/G6jqjYxnnCbUx4RESiHtbIqq5bHx5HK13JjNtN5Ds4dH99JuuG6yIO7bb3t3mX15z/334BxveeoKGCgniaZZ1TMVBIT/ECNdU5U8sORBD+6hB+zyeFXFq3pz2/N8I/LejN9R3O2T8knNZfU=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:29:21.3354
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 70d6917f-f215-4387-ffab-08d6d3a86a83
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.57];Helo=[nwd2mta2.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BY2PR03MB555
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation the `_match_string()` helper mentions that `n`
should be:
 * @n: number of strings in the array or -1 for NULL terminated arrays

The behavior of the function is different, in the sense that it exits on
the first NULL element in the array, regardless of whether `n` is -1 or a
positive number.

This patch changes the behavior, to exit the loop when a NULL element is
found and n == -1. Essentially, this aligns the behavior with the
doc-string.

There are currently many users of `match_string()`, and so, in order to go
through them, the next patches in the series will focus on doing some
cosmetic changes, which are aimed at grouping the users of
`match_string()`.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 lib/string.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/lib/string.c b/lib/string.c
index 3ab861c1a857..76edb7bf76cb 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -648,8 +648,11 @@ int match_string(const char * const *array, size_t n, const char *string)
 
 	for (index = 0; index < n; index++) {
 		item = array[index];
-		if (!item)
+		if (!item) {
+			if (n != (size_t)-1)
+				continue;
 			break;
+		}
 		if (!strcmp(item, string))
 			return index;
 	}
-- 
2.17.1

