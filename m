Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ECF6C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 10:33:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C93A20449
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 10:33:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="bLI76z9U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C93A20449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71838E0004; Mon,  4 Mar 2019 05:33:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E22168E0001; Mon,  4 Mar 2019 05:33:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D638E0004; Mon,  4 Mar 2019 05:33:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F9B18E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 05:33:58 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so2436095edd.6
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 02:33:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=/KM+MtVV1D34gBxCpxxnyDqGqHRLFY+ZFtpAF++e86o=;
        b=Yqoq+kk2Dgqj33DlSovvDxlOZqijPzahyxUpGPVC7Q+43oaFuZOTAhuya3otiYdp6h
         Ck212KvAtUQWZkoizvFqc6R32+lJhTwKQ6YlSiJx077AsmZIconFjp8mo9hiCOUZwQRn
         ELZ2M3x8uYhUXYCc69tNFmrNYsLfiux5rPrNyVQvien7m8JLLWoNymycGSS/aEqB/1+U
         eQcXngj9IhJ7doPYkPw15FxIdclxBGRITGI7IWKhuJflHfdJhRtb75WBMUDx8enlMgA4
         MOS1ck+WUCetTGyLoI+EWSruTzxpay3YwsVDua1pZd8hcigCgUxyaCDOOd9/6GOMNG6t
         ucng==
X-Gm-Message-State: APjAAAX/V/v2GI3PU9JnvKhoZkpwouhyTXs60fZIO6DfMTDjL5DvdcM0
	06QG1k3voKHJMxmaWccSFIPwQZOvGOlR9u1rk9YT9yFdOyTp3+k88M9S+pe6LIhB2zMIywWEKkq
	z4VaviH7oNvPt2wqV+Q1XnGuXpLA8eMUC992oiWcqy45N/SwDUgc9DglFsslI7PaQ/Q==
X-Received: by 2002:a50:d508:: with SMTP id u8mr15077837edi.51.1551695637987;
        Mon, 04 Mar 2019 02:33:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqz0nzE1GJSUxttw+zt4Op4Poe+PRGTHoIU3PHZWPR7TtRFHBsCsnQNfq/Q67vOjgE7V9oh8
X-Received: by 2002:a50:d508:: with SMTP id u8mr15077790edi.51.1551695637195;
        Mon, 04 Mar 2019 02:33:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551695637; cv=none;
        d=google.com; s=arc-20160816;
        b=uhKp7uUgMEtcMlEZUjXmGjhC3vti7K7ED1Lz8udMm0nPzH6mnRe4c83YBmbUeZjvwT
         m80LN4nl96u9bZGWgfQn4f+VcUvJvwa8teIS4rpWiudDWh/nHutcoWT2fYHTKDFAi9JO
         r/+WnH7bdYsYzOkBU+IsuFauH5Om3wNMmXNC1NmbNOD2qXYUxBbaLY84atBwqctcXCqn
         e3U3kCXTE82tmTNeIYD0SrrUor/emYHZLjJlIsAEeOUps33JPsRwAq5VWApfbrTvh4kU
         uei4eozpwjVrxIhL88Do/9Un/GTkWGtd+S+Vm19d8YQNHhcq86uBFTEBkQP7twg78gEF
         u/gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=/KM+MtVV1D34gBxCpxxnyDqGqHRLFY+ZFtpAF++e86o=;
        b=Bas3ZRUBsowmvdD2uEl78kbtYB7Yp6u2krSlLiFVLyaBp56ty3kyjaze3CtjDO9XYi
         98TvTE1hKoEbTCV8b8v0WZO0haPESQoIs3B2sEckGk/9cO0XBes7yhsbCaMaWj3s7DFG
         4slO+WdtA1vPRTmNTstc/vgwSuM5ZlZDm+ejMne1br2ZlwNA3cUM0F5PRxlNkseR98yp
         R22K5rfb4FMG+287Xm6ZIrjQc9LN9Ozy53XqRCWvEgU8BZe2ED0XpNZSpa4nZoMGe7fl
         FsAhXbYSIlXSRaBehZSPWu5prC9Xf9Q5M9TPoVP4VAAv+MIbsZ0VSBhqqLTzJaBThy2S
         2zgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=bLI76z9U;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.55 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140055.outbound.protection.outlook.com. [40.107.14.55])
        by mx.google.com with ESMTPS id t4si2138489eds.319.2019.03.04.02.33.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 02:33:57 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.55 as permitted sender) client-ip=40.107.14.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=bLI76z9U;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.55 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/KM+MtVV1D34gBxCpxxnyDqGqHRLFY+ZFtpAF++e86o=;
 b=bLI76z9UPh2vjaHHuHksaAd/qx8WM/IFY8xUppsmhf+1Gc5olz1J6N5qbRwQZW9+vzE3PMIUpRcy0T+mNDD6EQ4N5SAamy1fnH+yeG62ZK7gtTyUzLpok8HJo12FaMYR7qD59HOcs9vS8kqVFumyJ7v/2JgyNLRuIc1MXDHiCwg=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5476.eurprd04.prod.outlook.com (20.178.115.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.16; Mon, 4 Mar 2019 10:33:55 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Mon, 4 Mar 2019
 10:33:55 +0000
From: Peng Fan <peng.fan@nxp.com>
To: "dennis@kernel.org" <dennis@kernel.org>, "tj@kernel.org" <tj@kernel.org>,
	"cl@linux.com" <cl@linux.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>, Peng Fan <peng.fan@nxp.com>
Subject: [PATCH 2/2] percpu: pcpu_next_md_free_region: inclusive check for
 PCPU_BITMAP_BLOCK_BITS
Thread-Topic: [PATCH 2/2] percpu: pcpu_next_md_free_region: inclusive check
 for PCPU_BITMAP_BLOCK_BITS
Thread-Index: AQHU0nXEG16tPwZG4EKC+VpW/1eojw==
Date: Mon, 4 Mar 2019 10:33:55 +0000
Message-ID: <20190304104541.25745-2-peng.fan@nxp.com>
References: <20190304104541.25745-1-peng.fan@nxp.com>
In-Reply-To: <20190304104541.25745-1-peng.fan@nxp.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-mailer: git-send-email 2.16.4
x-clientproxiedby: HK0PR04CA0001.apcprd04.prod.outlook.com
 (2603:1096:203:36::13) To AM0PR04MB4481.eurprd04.prod.outlook.com
 (2603:10a6:208:70::15)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 80740493-6a98-45d2-529b-08d6a08ce722
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5476;
x-ms-traffictypediagnostic: AM0PR04MB5476:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;AM0PR04MB5476;23:dRavUPOn/ZJMu8g2wvXPXFLkkCdOvT6B+YIPDap?=
 =?iso-8859-1?Q?IbD+GY1fZsrSGSSOjtpcEayF9J46LiO9PKJzwlu23kzknBzDL0w0jcQ0M+?=
 =?iso-8859-1?Q?I5pRlIb892VZtc9o51yAjIPfmIBxRJA0uPJL7LmSxmKGM02yMYff3kYZXY?=
 =?iso-8859-1?Q?xGaugjjPmQmrlnvD6aZQjzM0R+aU8vhU6xD5CbmMO7HNWJ1Fh9PhZvxHUp?=
 =?iso-8859-1?Q?B9nu5DxQdd0wxJSbwNInnXnaION4hvphMrd5Y1tDzlQq28uD5au7LRyAl7?=
 =?iso-8859-1?Q?pPjn0Hp36qqQj6q5kyvKK0DswpInBPCWrvVbiwG4FXOcA8z8NNExK0E7MJ?=
 =?iso-8859-1?Q?lIeV90cjzKYSjcMyrqJ7lM7x79mkMToUj4AmiTKWyU3cjet+Sd36HuVii7?=
 =?iso-8859-1?Q?+ulKjBd2DX0EjOZ1oBUDMVU8oY3ABZqbUptJ6Zg2q+ZfIE+IJBLaIEWCSk?=
 =?iso-8859-1?Q?C0GhSBAbEmK3KEcWMBupb7lHs6sVw/1AhHvO/ZofJuAcZeXV3RqhA4Thzv?=
 =?iso-8859-1?Q?DqgyUOc38rnWTysk/29iWwtMA32DK2zm0wySDcV/lPTOsN43e04VE3zMOv?=
 =?iso-8859-1?Q?TPo1qAzRQI9XQsdDZ3aGj5rChXHyj0oZ7Ns4FB5TPhpL1WHrreLNJYIdIt?=
 =?iso-8859-1?Q?Xf65cKxbRJpSxrEPuQTN/V3ww2+8XIx+bcX6owivrNldgdCJFDrmodI+Ea?=
 =?iso-8859-1?Q?ydaWYrLUBLDouNMpGyr2r29a901TZxrqfAK1cZQakdbdbMpmuAosRRbYk/?=
 =?iso-8859-1?Q?o6X6d2oEPVY8xrlQ5Ao975VN1VAunZT8j6tZvnew9N78VUGFcEz6P/cKxd?=
 =?iso-8859-1?Q?iej27The5w7JvU5JU+bBX8y+ftt/Xxa8ytr5DaUdFGfi7kAByIzzdUCa+x?=
 =?iso-8859-1?Q?tWC/xou63cIAkfEjyyVknXAjS+wQC872x5LS37+PRgNxWw05/18asUCC8c?=
 =?iso-8859-1?Q?3spQX+0fudHFoaehx5HE2j4JbinvHmA6tcdCAU8rCo9HCz8qO96qD5vSnW?=
 =?iso-8859-1?Q?YQkazyLBxCzyYgI3WoNMJ8oc3SqUhmC5G5onbl1QVvgI/t/7NJbKFPKTB2?=
 =?iso-8859-1?Q?wD1qChhzsiFhE7Iitn0+EyS0UKircEEAuDGcg6FVqorLBaKIyL43rTHSay?=
 =?iso-8859-1?Q?aCALe4mmXccqyYE1KFT0QOqJktUu3n3Fzc7KITqG/u3uy2ihwdep1fgzPw?=
 =?iso-8859-1?Q?fnaYW4b4N3h58AR1Q17xBDsNBXYieYj2MqGIKNJEC8WNMOG6hqVtZTxc+k?=
 =?iso-8859-1?Q?04xD9JARRbE+T/VxK/9ABkdUYOTETentYS7zaRgKe9YPsl1zkxbx47Wcxp?=
 =?iso-8859-1?Q?Hprg1uvRDG6fABGszW0duLXMwCMOIQc3f6BEuwxp3E4TUHY4PwA3xFuKrX?=
 =?iso-8859-1?Q?kRoODZDK/76oAyxHn1BCaxSV/8ehP?=
x-microsoft-antispam-prvs:
 <AM0PR04MB5476EDEB5E0FB8DBC9B217D688710@AM0PR04MB5476.eurprd04.prod.outlook.com>
x-forefront-prvs: 09669DB681
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39860400002)(396003)(136003)(366004)(376002)(189003)(199004)(446003)(6512007)(6306002)(102836004)(186003)(2501003)(386003)(76176011)(6506007)(99286004)(71200400001)(71190400001)(4744005)(476003)(68736007)(36756003)(2906002)(1076003)(486006)(6436002)(5660300002)(11346002)(6486002)(66066001)(26005)(53936002)(2616005)(14444005)(256004)(44832011)(52116002)(106356001)(478600001)(7736002)(105586002)(25786009)(305945005)(4326008)(86362001)(97736004)(966005)(14454004)(8936002)(2201001)(316002)(50226002)(81166006)(81156014)(54906003)(110136005)(3846002)(6116002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5476;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 UfX2wIOmZPbHRqkW3BpATValWGvohh7I1J5b0CEz1H3me2AvHlQPeMzfwmuIkJxXUQs0iosnyLLtvcy0SNEV0i/nKJGHSPIhOLOMalPf7+Bb1DMNIF2p3UL4W/1Z1yXn97u4rSdhg5suEoAAvySNmiofvJTe8YxmUQRSjdGlGg5sUfgveHD+q188cdkpWK+yQf0YoeZLWgh+JMs71W0oMDvc/7t6xOD4OndObxuNZp6IjQwlZGV8ONNR3pgYpdeh7AqChvMXjvptM8tGIUKr4KJD+UodiqlU/CI9tkjDN4KpvznWEyphvTHjPTjabgqBw1rNSdzvbaSz5Jw5MfJLk93qUpB4Hdk9mnDhXFBFmIK/6bI3BlCL7Rjsn7bMp1Y7/yngq2IZQRfLBASMkfo8yON5iJkHpuWETS9ko3Ic1iQ=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 80740493-6a98-45d2-529b-08d6a08ce722
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Mar 2019 10:33:55.7829
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5476
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If the block [contig_hint_start, contig_hint_start + contig_hint)
matches block->right_free area, need use "<=3D", not "<".

Signed-off-by: Peng Fan <peng.fan@nxp.com>
---

V1:
  Based on https://patchwork.kernel.org/cover/10832459/ applied linux-next
  boot test on qemu aarch64

 mm/percpu.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 5ee90fc34ea3..0f91f1d883c6 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -390,7 +390,8 @@ static void pcpu_next_md_free_region(struct pcpu_chunk =
*chunk, int *bit_off,
 		 */
 		*bits =3D block->contig_hint;
 		if (*bits && block->contig_hint_start >=3D block_off &&
-		    *bits + block->contig_hint_start < PCPU_BITMAP_BLOCK_BITS) {
+		    *bits + block->contig_hint_start <=3D
+		    PCPU_BITMAP_BLOCK_BITS) {
 			*bit_off =3D pcpu_block_off_to_off(i,
 					block->contig_hint_start);
 			return;
--=20
2.16.4

