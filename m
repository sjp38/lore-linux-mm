Return-Path: <SRS0=MSKp=Q7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CE87C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 13:13:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C764206B6
	for <linux-mm@archiver.kernel.org>; Sun, 24 Feb 2019 13:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="D2f8pTKa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C764206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB1488E0166; Sun, 24 Feb 2019 08:13:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEFE38E015B; Sun, 24 Feb 2019 08:13:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B66F78E0166; Sun, 24 Feb 2019 08:13:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 602A78E015B
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 08:13:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u12so2798871edo.5
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 05:13:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=vpNmAJGfNaAbucE9at8ymMaSSbS6S7aVICsihO7VzvQ=;
        b=huS4qxaIFcNM85t3/+KPepqSo0YUQdQGVa2kbaMUwidPHc9jqz85284YCidpqT7Sva
         y810NLCPqw/8OsCQPRm+4twbfo3X7nfb9WCaJUPYl8jA8D0EZWTJ9qK67XetELIlETiz
         rAXPmsuPYI21TcLgpH/Mhzkks9cEI08TY0EAOFHgzlOFpJS8Anohnj/3NKOZR5k8WcP/
         7+lnAUusdQyuU6g2YYxjwYqKjk44JoGPqZZGAZQeuRuwnvpl0HW5C7HDr5zyL/hMI8dF
         Z3n0kkCe3ti0cgmeS/vb6xwKouR7BJG41Mwm30DGpyfXkiYKVBfscBNHIyjCrzXWmshq
         78MQ==
X-Gm-Message-State: AHQUAub4bKmye8Xj9So7y5G7RL6Grrkz3J/DNnqJuCeqHyzh/KUGIfmt
	BYiWD2P+05iQOXjYSjcyn8Jigpfxi98NicvIFZuVAUJ+ONFaZ0+D/iiTZV5d+DAtHPjlltuoAyi
	gu6QSKnjff91Wl2dbM40rkI+fWbjGD7jF6+/LWr+HV9L/nrp4Wa11t1sIXayw/xNhVw==
X-Received: by 2002:a50:81e4:: with SMTP id 91mr10686003ede.274.1551014032767;
        Sun, 24 Feb 2019 05:13:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IblJQmtVF8c2nITaue3u3Nl0kWuAAOnVfsqfwD3cVsTBVy59teMMv1k4Vh003Ienm/ZWj1i
X-Received: by 2002:a50:81e4:: with SMTP id 91mr10685971ede.274.1551014031979;
        Sun, 24 Feb 2019 05:13:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551014031; cv=none;
        d=google.com; s=arc-20160816;
        b=lt73DteSPNRWHVSmf2MhcdZQP5A8upoNBBKlyJxeXTlUa4pZDmtVIOvmPWh5kuK9Mh
         teDi2J35Q3eS7bVJPgAIRsfyE9T8/VLkPB6DrLo0ctqSxA/PH45W35WKftQu1UBgDW9r
         I+rZR94K1RO1W0RxcewM16N0MRxI3iJGqqrY2EoIqA2bLstVm1SbeC3HDBIt1BVImONi
         YWQsBnO47guWgzMOQzwMJrq40pd2EKlxj0JGXBeiLeceaXFWdQOw9MN4NEtXbbPrXyu5
         oklmj8G2AimNMtqvTX/QGKTGp88kWiO4Jo3HF68cEs1+8ffMcpVH6Y7hABlPJ6Dz+eFE
         3ydA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=vpNmAJGfNaAbucE9at8ymMaSSbS6S7aVICsihO7VzvQ=;
        b=qSI8nXGx73aFUlymJ+VkDfQXNnKBdr7h0SnctT96JTxkqvJJlHkgr9AhbX94krKO7J
         F0hKgOOXVC3G2MnvqGpY0fso2mc2W/xO8KgC5cMOncN5575KGGbPCp14RstvcL6aMZPs
         LjtPrh8ie9zOX/+OtGjtz6SeHaJvKf9B3H9hbP4SOvi7om2POkSSg0uCXheNHF4F1Wuj
         9ewpebN7oyk9AHKVmnl5AQdxMmUcVMnQiNxeiLzbjdecbwfPElSHvQZ5Q/iGeFYT17el
         vCHN1/oxEGu+bGgmcKZhdnN2QMWXtkbZaE/5IsR6gaIQVDN0W3e489JPmk11saQXjnCD
         SDNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=D2f8pTKa;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.44 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140044.outbound.protection.outlook.com. [40.107.14.44])
        by mx.google.com with ESMTPS id n2si2722734edi.135.2019.02.24.05.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 24 Feb 2019 05:13:51 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.44 as permitted sender) client-ip=40.107.14.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=D2f8pTKa;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.44 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vpNmAJGfNaAbucE9at8ymMaSSbS6S7aVICsihO7VzvQ=;
 b=D2f8pTKa+M+LNCtAizGstJZ2Db2D7c96itlmOHob8s8EVwXoPr859Bs5O6nyqbpCLOagwxjh+O5HMUs1N7TN6xe24FJIrhA3oHu+VAtiC4sVyhmjkCiBFzrASpxCgY2c0DupwnnQaZkG4jzezhIKCAyXfJ3p0zPKPNbMDU6/whE=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5651.eurprd04.prod.outlook.com (20.178.118.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.20; Sun, 24 Feb 2019 13:13:50 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1643.019; Sun, 24 Feb 2019
 13:13:50 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "dennis@kernel.org" <dennis@kernel.org>, "tj@kernel.org" <tj@kernel.org>,
	"cl@linux.com" <cl@linux.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>, Peng Fan <peng.fan@nxp.com>
Subject: [PATCH 2/2] percpu: km: no need to consider pcpu_group_offsets[0]
Thread-Topic: [PATCH 2/2] percpu: km: no need to consider
 pcpu_group_offsets[0]
Thread-Index: AQHUzELI99orDQmet0qADTSfLzpSUQ==
Date: Sun, 24 Feb 2019 13:13:50 +0000
Message-ID: <20190224132518.20586-2-peng.fan@nxp.com>
References: <20190224132518.20586-1-peng.fan@nxp.com>
In-Reply-To: <20190224132518.20586-1-peng.fan@nxp.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-mailer: git-send-email 2.16.4
x-clientproxiedby: HK2PR02CA0131.apcprd02.prod.outlook.com
 (2603:1096:202:16::15) To AM0PR04MB4481.eurprd04.prod.outlook.com
 (2603:10a6:208:70::15)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6348761f-7961-49e4-f8b6-08d69a59eac8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5651;
x-ms-traffictypediagnostic: AM0PR04MB5651:
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;AM0PR04MB5651;23:wqjxN6jLGDsg0Vq9FnyEweRo7y7akEJU5QtmbMh?=
 =?iso-8859-1?Q?eP+YH8FtXVshIYy0hsfRQlisrJ451zQ2/PM9g3QDLTcHJ0+GE4J7Aw7DEt?=
 =?iso-8859-1?Q?+ULoDOWJ6CJBQs+6KYqeDrdvBDLE0cf41hyTbx7yD2lQ3HLYUzobaOoCJH?=
 =?iso-8859-1?Q?xpIsx+pIoLDh9V+gU13ItxnuYznd24AzVJOALZWWX3zHbRdNGf+CpTILvR?=
 =?iso-8859-1?Q?2kGhTaj42AaYR2bGOXetZYOy6VPhjhhsvJIC7X1hRkXfl/vWExREzHnFlc?=
 =?iso-8859-1?Q?Q5OGzOaXS4aoXEWkN1pS897zW6jF/3mUKucwbUAYvkIKLOHij/uL4e4tFy?=
 =?iso-8859-1?Q?z3KZ/aV6OkUME5rw+qVjK0HoYmNlMgZhKgLb1zudj7FUs9OrrhTYrgaWTI?=
 =?iso-8859-1?Q?M6Xd6LhSxt94mHme3oUqCYyMo9uaCtjsVO4ZDUL+QbWPBZEk5qYuR/pe4H?=
 =?iso-8859-1?Q?LQRt83ETt4ICQRkPk5Kn+9PNk8iH/CB7HF7TYcceVakU+ttoeUptHPA83b?=
 =?iso-8859-1?Q?HjqF22IUs40jJqn1K7tgy+K8yQNxrDNDcb2W4rnN2P8VEYGuygaI2bniDf?=
 =?iso-8859-1?Q?YTfx2AXltxpp6lVmhgnQEqSB2sf2plXG06/e9CqF5ZuHWuLQQbp54N9EZ6?=
 =?iso-8859-1?Q?topoWoSpMm/JXXR5CkDFVm5YzPnWaSrMtHUayWFktf5qA8DcpWHChXDTQ9?=
 =?iso-8859-1?Q?Hu+NLJ4ECCCBYaUOwunzhojW1URp4Lr8Yo62aA5OFE9JEcE9mkJO4pHK3t?=
 =?iso-8859-1?Q?uyJiPpkABg+I2cPuRrEQsdRvzknCCi+UclNedeDYzUdu8xjbxel6O+i5wz?=
 =?iso-8859-1?Q?sGXFTkfhdFieaAPJkqB9KBK1aPDfUSA/tIoAnk4RBy8SDuUBUsrer1+avY?=
 =?iso-8859-1?Q?fi01rx6XaNrfMllcN8zx+ZAUXna3IitglKX5xWVrwCAcAtQ1RZ/zmXgB2D?=
 =?iso-8859-1?Q?l/Ou5jH5OZK/k197hnwU05/K/g8xG9rTMzl+jFsx2KV36yFEdyNGFVeOha?=
 =?iso-8859-1?Q?XxM7J/X4SZbbdF1b8VcrqQdiHC6ThAtjazdpVmjPZCctIE+l/et6UF4OfD?=
 =?iso-8859-1?Q?nLYhuEACc3SF5k9GtZPOv818VMMiN7PvioIYROmtGCAnOfaSRMtFf3WeAP?=
 =?iso-8859-1?Q?tNqilBOs7nIF7nelRqIUY6Ow69xWhJ+46pPB0ymKt0PRMI2eRyZ1lEOUi8?=
 =?iso-8859-1?Q?igkObpqUxZihV9tW2KyrklPhjLq5WHttgNS+OxgIPF8Vf90Q9wBZWOU81d?=
 =?iso-8859-1?Q?BS7UG0AdzoBwM/ASM4l2O6l6LCGDNtfHE0bIukef+AIFh17PnDpsvAjq13?=
 =?iso-8859-1?Q?tuNNmCdnlinTKSYJ6KJsExMGqQaGno1GcsyBUlw5yupsQVUto61qsLGyWv?=
 =?iso-8859-1?Q?wsZXcTQU=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB56510436CA3A8B61A4781FEB88790@AM0PR04MB5651.eurprd04.prod.outlook.com>
x-forefront-prvs: 09583628E0
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(136003)(376002)(346002)(396003)(39850400004)(189003)(199004)(8936002)(8676002)(81166006)(44832011)(81156014)(486006)(97736004)(7736002)(6436002)(11346002)(446003)(476003)(110136005)(68736007)(305945005)(2616005)(53936002)(6512007)(54906003)(316002)(2906002)(26005)(186003)(2501003)(4744005)(14454004)(1076003)(50226002)(256004)(478600001)(52116002)(76176011)(66066001)(99286004)(71190400001)(71200400001)(386003)(6506007)(5660300002)(106356001)(36756003)(105586002)(2201001)(6116002)(4326008)(3846002)(6486002)(14444005)(102836004)(86362001)(25786009);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5651;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 ZlgEQcSPGQTUfjrCx6CeqTSgsM1y7qKUgDLM0l8C6SYqoltT3GUTSSDwgDtD5m4jOOXEcqsAp2NM2sIi1rd0Qyel7C7dEh2Q7WTK0H6423BLqRdT+YB7zIMcBG3l0gKdUvImpP692UQsPzvYLlZzXGhjV93U+N+4Cuvfbmr7NIUpYegeP7uB0UGYdWJ1009NIA2cYnIke+QqpHTNKd5ixb8aHcLf54yZwMaEIcxJyp1h+OrETnYhyHiz4P+uhYs9dT3H+UgDx7A5/b6ffDWZRPRyKVIm3guN+npFtvx1kLaW3MqcN8+egdkF3EtxMG1kbWFswWwLis9j+ELSIbqlaxckwpnjgd6ZfUj8L4JN+39fjlCMZMLALE5L1D6Og40Rtltf23oHgZs3GdJR6TrY+LqqRbg4GhKSSEaXop1ymCw=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6348761f-7961-49e4-f8b6-08d69a59eac8
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Feb 2019 13:13:47.7133
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5651
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

percpu-km is used on UP systems which only has one group,
so the group offset will be always 0, there is no need
to subtract pcpu_group_offsets[0] when assigning chunk->base_addr

Signed-off-by: Peng Fan <peng.fan@nxp.com>
---
 mm/percpu-km.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 66e5598be876..8872c21a487b 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -67,7 +67,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 		pcpu_set_page_chunk(nth_page(pages, i), chunk);
=20
 	chunk->data =3D pages;
-	chunk->base_addr =3D page_address(pages) - pcpu_group_offsets[0];
+	chunk->base_addr =3D page_address(pages);
=20
 	spin_lock_irqsave(&pcpu_lock, flags);
 	pcpu_chunk_populated(chunk, 0, nr_pages, false);
--=20
2.16.4

