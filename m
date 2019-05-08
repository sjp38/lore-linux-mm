Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73F7FC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 299F6214C6
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 11:30:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=analog.onmicrosoft.com header.i=@analog.onmicrosoft.com header.b="Z7XBk7n5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 299F6214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=analog.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDA136B027B; Wed,  8 May 2019 07:30:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB0D36B027C; Wed,  8 May 2019 07:30:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B78A16B027D; Wed,  8 May 2019 07:30:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8F26B027B
	for <linux-mm@kvack.org>; Wed,  8 May 2019 07:30:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i123so7986314pfb.19
        for <linux-mm@kvack.org>; Wed, 08 May 2019 04:30:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=u5hQTyFwHo/VxRdFALVMYiR+QOhFLU+yQ1fnnnSWX8Q=;
        b=Kje3XqkF+BwDWBrTJUNMLnGEs7nfBPoDXt5mFE/V9G+aowlkWIuKTWGz7wFDFqvM3h
         YVZQTEUJ87PxDOYJA4xFqDeIWbRB9gCpHHlxTvQ7XrryuxTKItgdvDnGFG/Sbgm1tlQ6
         MjBJ+ItW/EVH2gxuEy/PgRpXGA+p8MuHwa722Wa3Zxdez36jsV7xV5fxTr6VNPu3r2sV
         kD/o9fy8urE+Rhbr3wkBeIoJKT3hE10bgTGjKk+FSmcdWre5c54YhLmwQj/fF12j2i79
         gNfT6e30rbMx6pdNCVg4bSldHp/Kr8B9KbzpH7SCibaU1Be7hmnxktRkR8cBsBLAlgdc
         tdfA==
X-Gm-Message-State: APjAAAXVfrvJtJtQ098TCEOz6HkLgeoBjQWVebzewNvFL+5nUeGh7tf/
	4w45T+dbYgO6gUCOcr4cRKqHHEiCTDLp912KKRwrVt5TFlR0+vUb7pchK0Jw5w2dohVjT0uc+jt
	DWnJ6jt34+iRRlsZVopZ10QRNyy0VJNP8e/SOhkYYURwOg2iqFraP83weZN7y3YpA6w==
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr46136702pls.171.1557315031189;
        Wed, 08 May 2019 04:30:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+sDYSM02iFV8O1MydMiT8dTnQXmn3TA+YuYR38xqvDE7wUlZRaxEAM0fJDspxUobxb0fw
X-Received: by 2002:a17:902:bf44:: with SMTP id u4mr46136614pls.171.1557315030257;
        Wed, 08 May 2019 04:30:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557315030; cv=none;
        d=google.com; s=arc-20160816;
        b=JrVM5tgofHOnLB5kwFtq4dad7Fzz8XPUwQoEriWUT+EwRmnbTI6lgSKAUVtRgs9Dte
         FqApUQ3VSCWq9nJq35KEQsR3NknkQXkpBAxo+SAwjFEAWjaVDoIl7eO0spd1BoWpjeHU
         qnyLPmSqM5I+AskbqCsWlHAHsfE/eYst00L3TY0dQ7zTZMQ5KMS9sQ8g1QQbMQ7uPG0S
         Qk1HEg4MjZV1+V1rW9zx1P5mCwcCf7054+/W8UhobCcV4TPt00u1ufWzk51OqOseSkTd
         XEaXv72jbmf+BTHw9yqnk1LiETAZ1fIpM6+fD36p7el41dgbzDqp8+Euw488Ya1G0PH4
         OBGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=u5hQTyFwHo/VxRdFALVMYiR+QOhFLU+yQ1fnnnSWX8Q=;
        b=byLMjAjAHNZs1NnFsQOFBDh9hN/BnF/uSoOWmpWFq2tg/SiFGaWgxbfpV4ipYW0RHb
         2PhN3mqa/CL4rjDCDiRnBjm91ZEF7+qf5N6VoNtf93h7xPvECq4uAGx2y3e62TqIbHLC
         U0BBytWwOixBNdbnjXvm5eDolTbNnrQGqKwqvRO8hIT2NjNCeqcCrmHjGVVjTuoUQLYH
         LHA4xNp/Luic6EYyTSruGp5Mx/ebzTqtflQt9twqQzBcpJbAk0/z9ra6hNxP7pZyUzwI
         gKiVG8tRZMY9IUclNJ+8yoh70xO7bIIZkseo7f+xSYGwkoBEeAiaMnZ3AK/GDaquxqrJ
         Cvfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Z7XBk7n5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.86 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710086.outbound.protection.outlook.com. [40.107.71.86])
        by mx.google.com with ESMTPS id t26si21806030pgu.327.2019.05.08.04.30.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 May 2019 04:30:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.86 as permitted sender) client-ip=40.107.71.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@analog.onmicrosoft.com header.s=selector1-analog-com header.b=Z7XBk7n5;
       spf=pass (google.com: domain of alexandru.ardelean@analog.com designates 40.107.71.86 as permitted sender) smtp.mailfrom=alexandru.Ardelean@analog.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=analog.onmicrosoft.com; s=selector1-analog-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=u5hQTyFwHo/VxRdFALVMYiR+QOhFLU+yQ1fnnnSWX8Q=;
 b=Z7XBk7n5vKKBDgXCP897D+5V1Y0FLQdRTDHnUWULRUnoOrwQ2xkh9EzaEl0pwQeruiqUJOD9GIv3hXLd9F5aq1UqHCVFSPaWFY19RldYDESvUrqGCU74eR8dJ/StDdxc+q9DTKHUAlBb+h9/h5TGntoeFTD9ZXAJpweCEH/OhDc=
Received: from CY4PR03CA0081.namprd03.prod.outlook.com (2603:10b6:910:4d::22)
 by CO2PR03MB2264.namprd03.prod.outlook.com (2603:10b6:102:b::24) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.1856.11; Wed, 8 May
 2019 11:30:25 +0000
Received: from CY1NAM02FT033.eop-nam02.prod.protection.outlook.com
 (2a01:111:f400:7e45::206) by CY4PR03CA0081.outlook.office365.com
 (2603:10b6:910:4d::22) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.20.1856.11 via Frontend
 Transport; Wed, 8 May 2019 11:30:25 +0000
Authentication-Results: spf=pass (sender IP is 137.71.25.55)
 smtp.mailfrom=analog.com; lists.freedesktop.org; dkim=none (message not
 signed) header.d=none;lists.freedesktop.org; dmarc=bestguesspass action=none
 header.from=analog.com;
Received-SPF: Pass (protection.outlook.com: domain of analog.com designates
 137.71.25.55 as permitted sender) receiver=protection.outlook.com;
 client-ip=137.71.25.55; helo=nwd2mta1.analog.com;
Received: from nwd2mta1.analog.com (137.71.25.55) by
 CY1NAM02FT033.mail.protection.outlook.com (10.152.75.179) with Microsoft SMTP
 Server (version=TLS1_0, cipher=TLS_RSA_WITH_AES_256_CBC_SHA) id 15.20.1856.11
 via Frontend Transport; Wed, 8 May 2019 11:30:23 +0000
Received: from NWD2HUBCAS7.ad.analog.com (nwd2hubcas7.ad.analog.com [10.64.69.107])
	by nwd2mta1.analog.com (8.13.8/8.13.8) with ESMTP id x48BUNwe023807
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=OK);
	Wed, 8 May 2019 04:30:23 -0700
Received: from saturn.analog.com (10.50.1.244) by NWD2HUBCAS7.ad.analog.com
 (10.64.69.107) with Microsoft SMTP Server id 14.3.408.0; Wed, 8 May 2019
 07:30:22 -0400
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
Subject: [PATCH 12/16] rdmacg: use new match_string() helper/macro
Date: Wed, 8 May 2019 14:28:38 +0300
Message-ID: <20190508112842.11654-14-alexandru.ardelean@analog.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508112842.11654-1-alexandru.ardelean@analog.com>
References: <20190508112842.11654-1-alexandru.ardelean@analog.com>
MIME-Version: 1.0
Content-Type: text/plain
X-ADIRoutedOnPrem: True
X-EOPAttributedMessage: 0
X-MS-Office365-Filtering-HT: Tenant
X-Forefront-Antispam-Report:
	CIP:137.71.25.55;IPV:NLI;CTRY:US;EFV:NLI;SFV:NSPM;SFS:(10009020)(1496009)(39860400002)(396003)(346002)(376002)(136003)(2980300002)(199004)(189003)(7636002)(316002)(106002)(4326008)(50466002)(126002)(2616005)(486006)(48376002)(478600001)(36756003)(54906003)(476003)(186003)(110136005)(11346002)(107886003)(16586007)(77096007)(426003)(51416003)(7696005)(76176011)(4744005)(47776003)(305945005)(44832011)(446003)(336012)(70206006)(1076003)(70586007)(14444005)(8676002)(86362001)(7416002)(53416004)(246002)(356004)(6666004)(2441003)(2201001)(50226002)(2906002)(5660300002)(26005)(8936002)(921003)(1121003)(2101003)(83996005);DIR:OUT;SFP:1101;SCL:1;SRVR:CO2PR03MB2264;H:nwd2mta1.analog.com;FPR:;SPF:Pass;LANG:en;PTR:nwd2mail10.analog.com;A:1;MX:1;
X-MS-PublicTrafficType: Email
X-MS-Office365-Filtering-Correlation-Id: 3ea226c7-d664-4182-eb25-08d6d3a890b6
X-Microsoft-Antispam:
	BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4709054)(2017052603328);SRVR:CO2PR03MB2264;
X-MS-TrafficTypeDiagnostic: CO2PR03MB2264:
X-Microsoft-Antispam-PRVS:
	<CO2PR03MB2264CA36634DECF7B647076FF9320@CO2PR03MB2264.namprd03.prod.outlook.com>
X-MS-Oob-TLC-OOBClassifiers: OLM:883;
X-Forefront-PRVS: 0031A0FFAF
X-MS-Exchange-SenderADCheck: 1
X-Microsoft-Antispam-Message-Info:
	9+T9KOQ5N1uqSNzRRgplR6sHTKQb7qlY+DBPxxdCSaJYco/p4QFiyK/dDR0hB1IOFmQXuX5mxyj18B28K6d93VjxihCj+rCmQnGHG+YCO6GrqNFnq/R+gtspHAUOD35K6bnQr18zajdkHnsgf+QKRbi3AQukLYK3xBiqqryjbGYGjjRlCqPYQrzhbT+v7t96Pxm0FHxoT7kykMNu+1w4N2KbrJMgDpMtY1XAHVueHSW/1Hrp3kOm+CFYWu5LQ+2t5MTCEOfBhm2wbNLLQTpoyj0DhQHzLCeF6FRFDnPnJNhXTBEOEJdYK6LFjoWOnt1QNXc3j/TxDqk5WgHs+pPuEg7e3rtTvXcq/rVdNvuTndv5eIO1qBO51WfXuWrhJnCT8Sl23SmiUZfSUI8Vpzk+y9G/FLbIygwUT4rW+hoQ81g=
X-OriginatorOrg: analog.com
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 08 May 2019 11:30:23.9644
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 3ea226c7-d664-4182-eb25-08d6d3a890b6
X-MS-Exchange-CrossTenant-Id: eaa689b4-8f87-40e0-9c6f-7228de4d754a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=eaa689b4-8f87-40e0-9c6f-7228de4d754a;Ip=[137.71.25.55];Helo=[nwd2mta1.analog.com]
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: CO2PR03MB2264
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The `rdmacg_resource_names` array is a static array of strings.
Using match_string() (which computes the array size via ARRAY_SIZE())
is possible.

The change is mostly cosmetic.
No functionality change.

Signed-off-by: Alexandru Ardelean <alexandru.ardelean@analog.com>
---
 kernel/cgroup/rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/cgroup/rdma.c b/kernel/cgroup/rdma.c
index 65d4df148603..71c3d305bd1f 100644
--- a/kernel/cgroup/rdma.c
+++ b/kernel/cgroup/rdma.c
@@ -367,7 +367,7 @@ static int parse_resource(char *c, int *intval)
 	if (!name || !value)
 		return -EINVAL;
 
-	i = __match_string(rdmacg_resource_names, RDMACG_RESOURCE_MAX, name);
+	i = match_string(rdmacg_resource_names, name);
 	if (i < 0)
 		return i;
 
-- 
2.17.1

