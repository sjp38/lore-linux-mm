Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D27FC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:40:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD9442075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 07:40:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="ug3p+80+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD9442075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65CAB6B0275; Tue, 28 May 2019 03:40:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60DFB6B0276; Tue, 28 May 2019 03:40:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4876E6B0278; Tue, 28 May 2019 03:40:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFE06B0275
	for <linux-mm@kvack.org>; Tue, 28 May 2019 03:40:04 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id k63so4242772oih.15
        for <linux-mm@kvack.org>; Tue, 28 May 2019 00:40:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EVygfSY8hqy/DBUvsHRCgGvieeoiCENlb8QcgTW8Qa0=;
        b=d2nNjV9VKw5mJ7dVXTjkOiBWv4bAX0SeEj0TRGPY3D5VgWrJQS8Nq58X98+1uh3dRh
         CcYrSkE3TL3hE9ojYYpSQclx7ywujWhiSkpe9LTxggrUe5lZC5Khch7HdQk50lPWP12a
         WvwAJDFsqtVz85XFP7j/tj5avYF6NW94xmkAw8AUDtnRDdnZGfGxCDq1zvlgxxsE7A7u
         Lwc35xkV0RCYbiFQzcAlUQae+3PoojIy9nj7n7lREH3B7otAMXqvoAYwS448J40m/US7
         Y0HCxeVp0rLruuiRhPpwp7s3kJBvo/NUzuQB92T+FfaQ0/IGM0/WToYq760fuYCZf3Q+
         bMtw==
X-Gm-Message-State: APjAAAXcaeV9eWqjjaIhEaRSTTrteHnUJ+Z5CpFeLZdQgGmOY1zGAjtN
	l0Zo+VzHMO/NPRpvCHR0A5Eg8YnSWzqZ1jSk4z9zv4CiQeM/+jfmv0/hsDXZFKuwjIlqzob+IPu
	aScNlunw3aq4YdLngmpmPdqdeRRKbEKJZLLU2xIHiHqmP3goShLykHHRU9/L2eegmig==
X-Received: by 2002:a9d:2785:: with SMTP id c5mr70076184otb.301.1559029203762;
        Tue, 28 May 2019 00:40:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1nz4t3l6vaIJ4xCvZCvgdpLGnmvQOkVkCEcYR2YD7Xg0gp1hrTd+4vdi+25pVfthZBj7/
X-Received: by 2002:a9d:2785:: with SMTP id c5mr70076161otb.301.1559029203177;
        Tue, 28 May 2019 00:40:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559029203; cv=none;
        d=google.com; s=arc-20160816;
        b=oOkWIyLQ/7YZSxSeYiTjNE26K2ryPW9Jcd/IAJsrKu/ncWrQWJAHc0cHt9JhhazMtB
         42VA6gmGEdJyARHW6V9G9cHk2bELsRO6Gxq7hG4A7wn0wEKrJnaOjeMEqCDyTjSyiPG5
         TKyI7J2nnraVmgKI/d675EYx3fI5toe6BroSjfM69ASNPAcmTMNKRTVb/9LRN6sULrlh
         VAOeLv35/L2B7KcAPJc5sY2HpEYayp5Fwa0ugd+xn91ZCrHGjLGZBKpjodaOJgEDd91S
         n8zyMeCSBjq1DlG0AX2eYJWnHyqsbZfjcgKOD/0y5GLSXjVPCrgn8U4McKEMi1W8hmGn
         XE4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=EVygfSY8hqy/DBUvsHRCgGvieeoiCENlb8QcgTW8Qa0=;
        b=xBAY2QdKEtB+YXiwJWtlP/rvg4LA0wdZZ6fG5Hi5FWSIL9MDByyVJqH1acc5i8Upao
         5ZXUPT7Rjhgei+rBnezQSWYbAZeRexgebru4Z8P8lsGq6h6QD0vwE0a/VYDWWvY6ShD+
         eHQe09Q05UwxtMKiDBgt3lmG7x0LGyBzpUh05FedJKwbWozbKdCLFLKZmPdZAhmk1xJd
         JQb6NmqUvXzbh43uhQpSQz94PY5PH2fmWJMXfDGVHSV/TkuFZzPwR/6zypd9D9G6MgWg
         0eHVDPi3BiUblvF/SjHX7o/jkiC8CuDVW826ujppEY2iC2pY3D1oMhl7tz1l7JF+EsUj
         JwBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-onmicrosoft-com header.b=ug3p+80+;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.70 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770070.outbound.protection.outlook.com. [40.107.77.70])
        by mx.google.com with ESMTPS id v129si7327205oib.188.2019.05.28.00.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 28 May 2019 00:40:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.70 as permitted sender) client-ip=40.107.77.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-onmicrosoft-com header.b=ug3p+80+;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.77.70 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EVygfSY8hqy/DBUvsHRCgGvieeoiCENlb8QcgTW8Qa0=;
 b=ug3p+80+pta3QSOyYVopWCIPknnTa/9XApeIFW+44+SXRahs8pvbg98CvxDZWD2q7UoHIhgUD6Sn7ZbGyOWHdj4WAzkhg9cumlMLts6dyltoEMjlw9eglOAVG8lj96mIW2ArwyzQcb/gVfwCJxWUUom9Q8RHLT+KaOaucx79tQQ=
Received: from BN3PR03CA0110.namprd03.prod.outlook.com (2603:10b6:400:4::28)
 by BLUPR03MB552.namprd03.prod.outlook.com (2a01:111:e400:883::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1922.22; Tue, 28 May
 2019 07:39:58 +0000
Received: from SN1NAM02FT022.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e44::202) by BN3PR03CA0110.outlook.office365.com
 (2603:10b6:400:4::28) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1943.16 via Frontend
 Transport; Tue, 28 May 2019 07:39:58 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 SN1NAM02FT022.mail.protection.outlook.com (10.152.72.148) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1922.16
 via Frontend Transport; Tue, 28 May 2019 07:39:57 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x4S7duOZ023275
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Tue, 28 May 2019 00:39:56 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Tue, 28 May 2019
 03:39:56 -0400
From: Alexandru Ardelean <alexandru.ardelean@analog.com>
To: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <linux-ide@vger.kernel.org>, <linux-clk@vger.kernel.org>,
        <linux-rpi-kernel@lists.infradead.org>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-rockchip@lists.infradead.org>, <linux-pm@vger.kernel.org>,
        <linux-gpio@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
        <intel-gfx@lists.freedesktop.org>, <linux-omap@vger.kernel.org>,
        <linux-mmc@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-pci@vger.kernel.org>,
        <linux-tegra@vger.kernel.org>, <devel@driverdev.osuosl.org>,
        <linux-usb@vger.kernel.org>, <kvm@vger.kernel.org>,
        <linux-fbdev@vger.kernel.org>, <linux-mtd@lists.infradead.org>,
        <cgroups@vger.kernel.org>, <linux-mm@kvack.org>,
        <linux-security-module@vger.kernel.org>,
        <linux-integrity@vger.kernel.org>, <alsa-devel@alsa-project.org>
CC: <heikki.krogerus@linux.intel.com>, <gregkh@linuxfoundation.org>,
        <andriy.shevchenko@linux.intel.com>,
        Alexandru Ardelean
	<alexandru.ardelean@analog.com>
Subject: [PATCH 3/3][V2] lib: re-introduce new match_string() helper/macro
Date: Tue, 28 May 2019 10:39:32 +0300
Message-ID: <20190528073932.25365-3-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190528073932.25365-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
 <20190528073932.25365-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(136003)(39860400002)(346002)(396003)(376002)(2980300002)(199004)(189003)(126002)(2441003)(86362001)(44832011)(5660300002)(2201001)(478600001)(446003)(476003)(2616005)(53416004)(47776003)(316002)(11346002)(2870700001)(2906002)(6666004)(356004)(50226002)(51416003)(7696005)(7416002)(76176011)(48376002)(4326008)(305945005)(70586007)(70206006)(336012)(26005)(77096007)(186003)(1076003)(7636002)(246002)(486006)(426003)(7406005)(110136005)(54906003)(106002)(107886003)(50466002)(36756003)(8936002)(8676002)(921003)(83996005)(1121003)(2101003);DIR:OUT;SFP:1101;SCL:1;SRVR:BLUPR03MB552;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 9f7495c6-88de-4750-c0e9-08d6e33faf63
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(4709054)(1401327)(2017052603328);SRVR:BLUPR03MB552;
X-MS-TrafficTypeDiagnostic: BLUPR03MB552:
X-Microsoft-Antispam-PRVS:
	<BLUPR03MB5526A3F85F374B6EF9329F1F91E0@BLUPR03MB552.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:1443;
X-Forefront-PRVS: 00514A2FE6
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	MswgKhZP9m+ZsGUEhWl3phwXCL8yuqzj7xcxpK+dGlJBf9m5zMl51gqC3LUtKdWQ8Os49FCltfeNbu6Phw/B8l5WNlH00oAhRzdjikewQHYUEmLqJ6/urfczkkAV7S6v3P1UMtUMTOYDySCPLD3RO66kjwZftNeRvVV3dsDqCax4qYOjNj2PWP5gkM5PjRZmJWiCQ5YjWYviSRnNrXmzdalwSZTQ416f6pMfl95WCkKeJFuhdayQMWJGsRNhTOHuxm5bGOp4NnJa6ZTV5K+ilvVE4Xb082rHyJdnAOFnjmjlMMgU1yiCJ2yKYrrmhTGSsWl7mABejle5Gq03Z59rpn0+AbER3kkbBxVnYXW8nX3mrHd8Gqzr89K0YpmuIcGMyscsEWrsfpd9tI6dbYg4W4+zRy2MwWGNPPr9JWXwDBM=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 28 May 2019 07:39:57.3627
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 9f7495c6-88de-4750-c0e9-08d6e33faf63
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BLUPR03MB552
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This change re-introduces `match_string()` as a macro that uses
ARRAY_SIZE() to compute the size of the array.

After this change, work can start on migrating subsystems to use this new
helper. Since the original helper is pretty used, migrating to this new one
will take a while, and will be reviewed by each subsystem.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 include/linux/string.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/string.h b/include/linux/string.h
index 7149fcdf62df..34491b075449 100644
--- a/include/linux/string.h
+++ b/include/linux/string.h
@@ -198,6 +198,15 @@ static inline int strtobool(const char *s, bool *res)
 int __match_string(const char * const *array, size_t n, const char *string);
 int __sysfs_match_string(const char * const *array, size_t n, const char *s);
 
+/**
+ * match_string - matches given string in an array
+ * @_a: array of strings
+ * @_s: string to match with
+ *
+ * Helper for __match_string(). Calculates the size of @a automatically.
+ */
+#define match_string(_a, _s) __match_string(_a, ARRAY_SIZE(_a), _s)
+
 /**
  * sysfs_match_string - matches given string in an array
  * @_a: array of strings
-- 
2.20.1

