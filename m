Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05D28C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66DC1217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 14:35:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="XQ2F1o0t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66DC1217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B062A8E0003; Wed, 27 Feb 2019 09:34:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8B048E0001; Wed, 27 Feb 2019 09:34:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 906368E0003; Wed, 27 Feb 2019 09:34:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 37B7F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:34:59 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i20so7017445edv.21
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 06:34:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=ydPKA5bYPG4oJWewMmo9KXUQqkLI9/V32BgyLDEghQg=;
        b=lBGqnz4eS+72ClaNg8/SbEo3f1E3RqIBtwqstUjkUgX9TN+MGp7RSLgDVpPO14fml0
         Hy4gERtx5x9CpL2kkJfg+3jAuSn1OcgsFnwkZbP+qguoZ964is4NQzFAC+IeALVUZ5Yw
         AoINB88UiTlGEWyIowPRQWEdjMhJ2EyXHes2HiHhaccleawGgxWJcQ/xnE3Ocxqhhjip
         an6BbEf9Q8W4oGwq11XEneQTkrUsgjuVqNNzG4vxcWm/gr0jHCc5vfeOj6i/5wnHjvTk
         CdmPvrcfDARR6X3gZ86PH/RQOSImxAP92BjZfIVK5SA+ASBwcu/tXBW19SGI5z+pcjdZ
         2Qjg==
X-Gm-Message-State: AHQUAuYECljNRX+hIA7zEBG+UkMxpqpH1mjBDMwERqnTbciZ3QXOpqhy
	67708YhNOGLJ/PPSelLBgf2rhsnB29PrcZ+TnoHXa155qrOjFPRv5sZByJ5IUNbgAIzbF6ehCEg
	4mII3g2mrZU1BnCo9sjqbaHrvTtqH4wVLtWZCkc2kj84TDnKNCvmf0o4wa7EQe1i99g==
X-Received: by 2002:a50:9012:: with SMTP id b18mr2676431eda.30.1551278098469;
        Wed, 27 Feb 2019 06:34:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSH7qzukT6KMLIomIw+ziwtawXvqQtSmd6qxbWWILu9z0xCMJ7qhP4kXnhuRNu6JOR6NNf
X-Received: by 2002:a50:9012:: with SMTP id b18mr2676369eda.30.1551278097418;
        Wed, 27 Feb 2019 06:34:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551278097; cv=none;
        d=google.com; s=arc-20160816;
        b=gF6VDIa4Q6oBuLAaoSgbhx+oJOZ7JmkGPxdQpTOgFb0miFJxkKJezPktMy6rW/oNsN
         KohP9klgaWwIyAvGKGWBEHVLKnH27INdbhYOMCzmPiL1xZK5IQwKlIDnaJc6xkHpQfgV
         na66OA9tNDxJt8LFPdR3Ed6DVAfqGvjULk6hjYbrCxdPel9B1uJMD/ppz+1BK7AZz29G
         UXaK5We6WJOfFjhqNztAU4OWQi0rebR8RPxSypj09i4+6vIB2NfrlQoCHlqvDxl/Sm/v
         yfsFMwiUTIpITrbjn8kI7EOYdP0ibuobQ1ef1smnshMl4s8qmrRBbPQFRNf+0je+x3eV
         cICQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=ydPKA5bYPG4oJWewMmo9KXUQqkLI9/V32BgyLDEghQg=;
        b=x+l+Z7fGXHp+2oYuBVV/YfXXS9JUqDnXbRSwdnZjY15xpgYF6U7wf434mbcoFF7crw
         EW3tJPlxeiGr3E9/7LreG4LQwgawP4c8hzWO/5HT8xwTxBiYJ4GupAWVgUzi2ULT6aqi
         1Tkja2Hn9+VyQlVCw9Ni2keU1Au5aahZlTetEr4W4nwyUqxg4iwd70OFj4Buy1yLY3RF
         91v9vBu6buLKs10m0Ke1WRS4ewillK8F3KmSzvH6D032WQ3UnY5RLgFv/uH99Zkxo8S6
         0qfIYX8zbwA8SB0njDRaZUrRJALiSuNSy/4COhgnkYMPj4yfLXU5o6SjXdWr0EfxjG6a
         /YLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=XQ2F1o0t;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.75 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140075.outbound.protection.outlook.com. [40.107.14.75])
        by mx.google.com with ESMTPS id y15si3742410edd.290.2019.02.27.06.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 06:34:57 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.75 as permitted sender) client-ip=40.107.14.75;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=XQ2F1o0t;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.75 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ydPKA5bYPG4oJWewMmo9KXUQqkLI9/V32BgyLDEghQg=;
 b=XQ2F1o0t/ldbkVL6p9C67OWuVdSsZ58a5cwp25mBexMrRriEr7BLSCIaY4d6IdImFrgTHqjxirh015qfpnnVjQ2hk+I2PMze3QupSNzEKTGMqWouBcohbJXj6uCOe/D3IsanNnOHpi9lezydZPHIipgOyz07/BQbRft0K/U0tNQ=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB4387.eurprd04.prod.outlook.com (52.135.148.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Wed, 27 Feb 2019 14:34:55 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1643.019; Wed, 27 Feb 2019
 14:34:55 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"labbott@redhat.com" <labbott@redhat.com>, "iamjoonsoo.kim@lge.com"
	<iamjoonsoo.kim@lge.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"vbabka@suse.cz" <vbabka@suse.cz>, "rppt@linux.vnet.ibm.com"
	<rppt@linux.vnet.ibm.com>, "m.szyprowski@samsung.com"
	<m.szyprowski@samsung.com>, "andreyknvl@google.com" <andreyknvl@google.com>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>, Peng Fan <peng.fan@nxp.com>
Subject: [PATCH V2] mm/cma: cma_declare_contiguous: correct err handling
Thread-Topic: [PATCH V2] mm/cma: cma_declare_contiguous: correct err handling
Thread-Index: AQHUzqmb2gOP19YBOEqDLHalEnAZ9g==
Date: Wed, 27 Feb 2019 14:34:55 +0000
Message-ID: <20190227144631.16708-1-peng.fan@nxp.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-mailer: git-send-email 2.16.4
x-clientproxiedby: HK0P153CA0037.APCP153.PROD.OUTLOOK.COM
 (2603:1096:203:17::25) To AM0PR04MB4481.eurprd04.prod.outlook.com
 (2603:10a6:208:70::15)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8bc17a3f-4e3b-4dc1-e998-08d69cc0bdc4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB4387;
x-ms-traffictypediagnostic: AM0PR04MB4387:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;AM0PR04MB4387;23:y6ljAC1GU2xbUvOeSDE1klbwV7PpK2frWB0TKaR?=
 =?iso-8859-1?Q?7HaciBCqWYx4u27n9lSHkF0uOAtM8gOJLu0qCwXX7mNPWYa88W4yE/4WDq?=
 =?iso-8859-1?Q?ZNEJV8QC7c11oDf2Pd6yt6mjcE/oh0AZeMHcI+RlJUOTuyFcjzrStK84ep?=
 =?iso-8859-1?Q?u88mRb7dfF2eIa3AUZ9dqi0lFWHfJCK29LXD89m33PAsHZ64iFx6eEjLpS?=
 =?iso-8859-1?Q?RfPxejujnlbQwq6b2tvhpnPkonU4sSdA1UF79/iTbamzauWAqPzIEt2Obv?=
 =?iso-8859-1?Q?+H833xy5OsKqsV+BaVwZE1LX8wtjTp/1DyjpLuJI6vx7MB/J302c+v5Ng3?=
 =?iso-8859-1?Q?ms9Gpzr+Wvqg7TcwcrnUXu1GzC+Ki+rBDEawnZGZJqBuDDPDJgULAnoBaT?=
 =?iso-8859-1?Q?3FDq5tLfujniR8ApsjvbHc+c7JWY8sE/e4js5J7X28AXo7U+R8rCQocjf+?=
 =?iso-8859-1?Q?3f9Ntfzmo/kAFOQ9OFdObMv8irm3PqKoOdIKx0u6aRtjiIOIfUJmCZdrqi?=
 =?iso-8859-1?Q?HFfatlS6rHjk0968uk3ksdI//rRK9jcAc/TR2kq87YwwXh2/wxOgZXiFEo?=
 =?iso-8859-1?Q?NHX9Y/Kbv27IW8qoUm9n9lFSXMaSvobGrlwKacTmdc25VfEFO3YILFQVbR?=
 =?iso-8859-1?Q?EOJV/baQb8Qb4JvLYcioB+Onzd6oBB85tilpivI+2sQkkh32SbK/YDlrLJ?=
 =?iso-8859-1?Q?WHW3OWWSfmcLt4kB+sSnQAlZXECDRC4ijEWRZY6lOMMxs7i6qOju3gRo7v?=
 =?iso-8859-1?Q?Shn8gCHdR3bQpGuqv8itBjxFPZ+9cTALNRlP0Zz9p+nXV6jqbcluGzEXwf?=
 =?iso-8859-1?Q?3VU+HuXgncv3mX/vRB9Jdspd/DMDuS4fE37+X9WTtVI98okpY1OAvfsOBX?=
 =?iso-8859-1?Q?SLyZbecKcNafoLCvn2ZAZRcW2Kz7pJ+v+qEbXnTf7ZGFbqc9daulnbHS8+?=
 =?iso-8859-1?Q?fX+0T+Cdl+ozz8XOIqNdA6fEGY3Ztek/bBSTypZoHGc35640wjEbyHXDtU?=
 =?iso-8859-1?Q?4vU4/ysvTEaBKwHIe6omkVRXHTZ6QcSTRFG7sppWJlbzMh75ctMHNn6CY8?=
 =?iso-8859-1?Q?9Rv+ry1V/43UgvvbFWiAzHK0dw5SmXF4+XwyIDB+7qBuFc7iY14L9d3jWt?=
 =?iso-8859-1?Q?nDY51id8BaQRNKVu7ofpPw3O86nMRJs27uCwFmRco/5rh3Z/MIBt53hBlp?=
 =?iso-8859-1?Q?Mz9SPAb4aZ5hIAWRVi/ARDo0gpR42hpbi4mVNiqm4EWyMRatB6Hmcc0znk?=
 =?iso-8859-1?Q?P9gsDMuQZmaJXtHj6MC6n+6tfM4vg0dROxE5+9hkiZwy8GUS3zwnpuTEaL?=
 =?iso-8859-1?Q?szDlU8DtUA+BRJ8AgchXWbMzdGMAFdzmkZ7y3RkvYIm8g=3D=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB43873FC1EEFC654ABE903DD288740@AM0PR04MB4387.eurprd04.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(366004)(39860400002)(376002)(136003)(396003)(199004)(189003)(256004)(97736004)(8936002)(7416002)(99286004)(52116002)(966005)(71190400001)(71200400001)(68736007)(486006)(26005)(14444005)(14454004)(478600001)(186003)(2616005)(476003)(2501003)(81166006)(8676002)(81156014)(7736002)(44832011)(36756003)(305945005)(106356001)(105586002)(5660300002)(1076003)(66066001)(53936002)(6306002)(2906002)(102836004)(6512007)(386003)(6506007)(6486002)(110136005)(316002)(54906003)(2201001)(6436002)(86362001)(4326008)(3846002)(25786009)(6116002)(50226002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB4387;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 64NH0bMY1y0xSNMIiVr9w1CMjnecvCr+0IJWiZ82vQVUP7MBreS9MHZUK7wgXAJ/uFw8izpPixWqQlzYuiu+AKO11BYkrfEh+uQTrJgCFjnFYvEAjz86RKUxGEePDhqeFF5ARtmXVThVTicew1xHI7Rx4Anke9ItyT6aEiIjndA21q9FWmQVeZgwSZsvMvtQWaGSfyuYW74zp24Vr4pkvfC/UThdCUiqvFobMD/zt+yC7kD8WgfNjqtr+3+8AKMMy5iolZh9cGso3JhN8NK0BuWGl3sOGvrfRf1ls/F7BFeE6e1Z+1CrbTO4rGysqAOR8crB1hbrYxEVVG8SDzPXasBBpruURs9sscizT5VUhK9d8UKQItCmY6tWPb7EZLtDQqSTUjNoEjRPhYpXbPUnqd5HHoBqUcjTLXdltw2gv8U=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8bc17a3f-4e3b-4dc1-e998-08d69cc0bdc4
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 14:34:50.8506
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB4387
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In case cma_init_reserved_mem failed, need to free the memblock allocated
by memblock_reserve or memblock_alloc_range.

Quote Catalin's comments:
https://lkml.org/lkml/2019/2/26/482
Kmemleak is supposed to work with the memblock_{alloc,free} pair and it
ignores the memblock_reserve() as a memblock_alloc() implementation
detail. It is, however, tolerant to memblock_free() being called on
a sub-range or just a different range from a previous memblock_alloc().
So the original patch looks fine to me. FWIW:

Signed-off-by: Peng Fan <peng.fan@nxp.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---

V2:
 Per Mike's comments, add more information in commit log
 Add R-B

 mm/cma.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index c7b39dd3b4f6..f4f3a8a57d86 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
=20
 	ret =3D cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
 	if (ret)
-		goto err;
+		goto free_mem;
=20
 	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
 		&base);
 	return 0;
=20
+free_mem:
+	memblock_free(base, size);
 err:
 	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
 	return ret;
--=20
2.16.4

