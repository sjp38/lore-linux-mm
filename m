Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62167C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 12:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2DAF2173B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 12:36:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="WCygyQGv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2DAF2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C1E06B027C; Fri, 10 May 2019 08:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34A916B0280; Fri, 10 May 2019 08:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EBCC6B0281; Fri, 10 May 2019 08:36:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C10E86B027C
	for <linux-mm@kvack.org>; Fri, 10 May 2019 08:36:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h2so3950113edi.13
        for <linux-mm@kvack.org>; Fri, 10 May 2019 05:36:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=zVdM6pJsyCQ+uqTjnKp+JgNxujdwU/jtU+C/gCATsb4=;
        b=lYrx79t7wEQEt+eFGGPIV8U05cfEOy4rK7PuiSDiWG8iTDLdaGqhiUU3WhkSNNxbG6
         vBgLEneDuuapGOf2LSLWStaUwBbuz88HEop9cMiyH2DwXTtZCVVfpKjDwTyVRf4ZcjvG
         pH/Q99lZ/ZTx2bhylXEBTf+d2ModHkVYrbuSmxmsEweB1IxL5fMneQ9GMV6k9ylKvlll
         eJcoC+kMbjv0xoeISRzIN/dnY1gFUjh4qQ0ooGOSMsFEeWq386g8SjGZDns0IA3tOW07
         uQGyBhIbJCx9kMXOmzeUgBZgiN6a9Bx9/TU1IRYdVHyczedTPU+mVuFOK8yYXmJtDqSX
         3Z6w==
X-Gm-Message-State: APjAAAXQGhEMlh6ILGZu65lNCxU2pxKyhDcq9F5lUxrwmd0N48Be7X4d
	wbSifZ2mP1SW0Aj/WzaXXP3ebqcoKpDhJA/XX87mqxmGyTx4YFNo2ehfrtCitjes9dTQx9WyptA
	4a9jkkpPr3ZdBaj9aa1HK0C7bFjJpgpZQNaeH861ivc3SHTVTiWWW3Blb1tf5oez7zg==
X-Received: by 2002:a17:906:6a8e:: with SMTP id p14mr8028383ejr.295.1557491812193;
        Fri, 10 May 2019 05:36:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPQDlb+7QQp5OGkidtJAMNeC4nxGazDAEXxuMjAXNZMhHTF6gslh2XjjvKuk3ou4ud52uc
X-Received: by 2002:a17:906:6a8e:: with SMTP id p14mr8028297ejr.295.1557491811223;
        Fri, 10 May 2019 05:36:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557491811; cv=none;
        d=google.com; s=arc-20160816;
        b=tTY2hstFx4Rkhr+mVoW3as7tya/opnmWxcZNHiN8y8eWwby2SawAbRUoed9qtY655Z
         qgIiIbIhZ+a7RrIwigwPk8UlTdV0DTdqAEpV07Ru3LikAEJdwRspuXU0mLCqvvsqcQcK
         7kuAarlP7Va3ycxCsff103GfhV/73/VPgFy/IVhEunIV9GDv1vzRz22UUrMvGbAuiW9Z
         NJjlxwngbn7LcJgcA9Rc355/ww3kgWsAilkXydxn082Yb/CQgPhzcSlOm5fYj9Dw0Y1G
         FM4M4E/THSBmfv3jGEqm5fF9PGbrz44bASA1W1HyihBsrHb+G+95t+AH7TOu7QiHJc1R
         TRGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=zVdM6pJsyCQ+uqTjnKp+JgNxujdwU/jtU+C/gCATsb4=;
        b=1EK/o4Q2u95r+EQZsJ4C74Ynr63JKgWHoSVJpyEtp3GIIiDy5BFPUXX5QKlX/MRmRi
         PrjlbvUBvZ5ae6c/dOgMC5MMpQS9HHIILfyNFvPnLeX56Ma7RbqPLOA7Y/M+b9zx/Zf0
         zJhRnrL3sGLyNemDDcxoJOv5zExw9ExORkRugRXJrJaLE5dChZnj5AwcicoszSN7Ek1b
         X8erIp7wK+pTE/WdczofA1fEoPNmlhIY7ZbznHZ9bAwW1yhQeS6xI8U8trsO7TjaSKyq
         VI2CBI55CtLav1+K8gO38qfxhtRL9484zyfGc6/N4VIe431c9RAJGLQuQ4jSVFyvdt8s
         0U6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector2 header.b=WCygyQGv;
       spf=pass (google.com: domain of bo.zhang@nxp.com designates 40.107.14.73 as permitted sender) smtp.mailfrom=bo.zhang@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140073.outbound.protection.outlook.com. [40.107.14.73])
        by mx.google.com with ESMTPS id u47si1241236edm.352.2019.05.10.05.36.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 05:36:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of bo.zhang@nxp.com designates 40.107.14.73 as permitted sender) client-ip=40.107.14.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector2 header.b=WCygyQGv;
       spf=pass (google.com: domain of bo.zhang@nxp.com designates 40.107.14.73 as permitted sender) smtp.mailfrom=bo.zhang@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zVdM6pJsyCQ+uqTjnKp+JgNxujdwU/jtU+C/gCATsb4=;
 b=WCygyQGv+sIo3hAfNP5oUyIVGZSVGdoghu/5LFnzVII2owZ9Us92xR0swytu0FeYEzO0w+EZe7qIk3eAiJtJphAPp0NpQPVhhd4WwRgWUK18WhIcepCG88gXN57PAm1Y+IzB4fIAKdxbsGGu482u0+uxqwadxOOrCldX1VVnw6s=
Received: from DB6PR04MB3030.eurprd04.prod.outlook.com (10.170.213.154) by
 DB6PR04MB3015.eurprd04.prod.outlook.com (10.170.216.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.21; Fri, 10 May 2019 12:36:48 +0000
Received: from DB6PR04MB3030.eurprd04.prod.outlook.com
 ([fe80::c826:713a:9ae7:b8d5]) by DB6PR04MB3030.eurprd04.prod.outlook.com
 ([fe80::c826:713a:9ae7:b8d5%6]) with mapi id 15.20.1878.022; Fri, 10 May 2019
 12:36:48 +0000
From: Bruce ZHANG <bo.zhang@nxp.com>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
CC: "guro@fb.com" <guro@fb.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"vbabka@suse.cz" <vbabka@suse.cz>, "jannh@google.com" <jannh@google.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Thread-Topic: [PATCH] mm,vmstat: correct pagetypeinfo statistics when show
Thread-Index: AQHVBy0IKUiylDx41kG86BTbOdN7wQ==
Date: Fri, 10 May 2019 12:36:48 +0000
Message-ID: <1557491480-19857-1-git-send-email-bo.zhang@nxp.com>
Accept-Language: zh-CN, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: HK2PR04CA0057.apcprd04.prod.outlook.com
 (2603:1096:202:14::25) To DB6PR04MB3030.eurprd04.prod.outlook.com
 (2603:10a6:6:b::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=bo.zhang@nxp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 1.9.1
x-originating-ip: [119.31.174.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0d00e93a-f2fa-4fc4-23b9-08d6d5442b0f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:DB6PR04MB3015;
x-ms-traffictypediagnostic: DB6PR04MB3015:
x-microsoft-antispam-prvs:
 <DB6PR04MB30157EF089AD4498809EF33B8A0C0@DB6PR04MB3015.eurprd04.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:4303;
x-forefront-prvs: 0033AAD26D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(376002)(346002)(366004)(136003)(39860400002)(199004)(189003)(25786009)(305945005)(66446008)(64756008)(66476007)(4326008)(14444005)(6512007)(478600001)(7736002)(73956011)(5660300002)(14454004)(53936002)(86362001)(256004)(71190400001)(2351001)(71200400001)(186003)(2501003)(2616005)(26005)(4744005)(36756003)(476003)(102836004)(316002)(52116002)(3846002)(6506007)(386003)(66946007)(5640700003)(8676002)(99286004)(1730700003)(81166006)(6436002)(81156014)(68736007)(6116002)(66556008)(6486002)(54906003)(486006)(8936002)(6916009)(2906002)(66066001)(50226002)(142933001);DIR:OUT;SFP:1101;SCL:1;SRVR:DB6PR04MB3015;H:DB6PR04MB3030.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 kFObS0Jyx4DQONcnwb6gfR2MX9Xw/h4rVa+Vfmi/8W3fOoySHUuA0U3YdAh3kE7By7/ciOGbBDQk4L3bdnfCWzxZmS0KMe4MIPssHsN28MhhoNT4IAI7Q102qJnFct3zJqKZHERhCObiF7jFtf/wC/JkPBaUYiz/0hx50SgJ+TAxP7LzTrdgmLfnhnw6IgcyPGVrH22oFOdqegZBZ9TarG4duf0iOCZbr/fp/9Gy2rvpQyeTzjkTuWavzWekFEDwyOalgSl17YK88bNTlPmU5HCC9AeowIwOMDPEnj7NBWhtaXOueYkuT23+xTH+lfKQdlxx4lSqXH3tytwL1Ebf5D7wBdtQWgBj0/7E3TglIl3/UV5gpoiaC/DYfciRPYgW7vGwK1Z2FZOtzpQnGNLRa+rDYeDCvSmpB5sX5bM9hts=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0d00e93a-f2fa-4fc4-23b9-08d6d5442b0f
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 May 2019 12:36:48.1815
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB6PR04MB3015
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000156, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VGhlICJGcmVlIHBhZ2VzIGNvdW50IHBlciBtaWdyYXRlIHR5cGUgYXQgb3JkZXIiIGFyZSBzaG93
biB3aXRoIHRoZQ0Kb3JkZXIgZnJvbSAwIH4gKE1BWF9PUkRFUi0xKSwgd2hpbGUgIlBhZ2UgYmxv
Y2sgb3JkZXIiIGp1c3QgcHJpbnQNCnBhZ2VibG9ja19vcmRlci4gSWYgdGhlIG1hY3JvIENPTkZJ
R19IVUdFVExCX1BBR0UgaXMgZGVmaW5lZCwgdGhlDQpwYWdlYmxvY2tfb3JkZXIgbWF5IG5vdCBi
ZSBlcXVhbCB0byAoTUFYX09SREVSLTEpLg0KDQpTaWduZWQtb2ZmLWJ5OiBaaGFuZyBCbyA8Ym8u
emhhbmdAbnhwLmNvbT4NCi0tLQ0KIG1tL3Ztc3RhdC5jIHwgNCArKy0tDQogMSBmaWxlIGNoYW5n
ZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL21tL3Zt
c3RhdC5jIGIvbW0vdm1zdGF0LmMNCmluZGV4IDYzODllODcuLmIwMDg5Y2YgMTAwNjQ0DQotLS0g
YS9tbS92bXN0YXQuYw0KKysrIGIvbW0vdm1zdGF0LmMNCkBAIC0xNDMwLDggKzE0MzAsOCBAQCBz
dGF0aWMgaW50IHBhZ2V0eXBlaW5mb19zaG93KHN0cnVjdCBzZXFfZmlsZSAqbSwgdm9pZCAqYXJn
KQ0KIAlpZiAoIW5vZGVfc3RhdGUocGdkYXQtPm5vZGVfaWQsIE5fTUVNT1JZKSkNCiAJCXJldHVy
biAwOw0KIA0KLQlzZXFfcHJpbnRmKG0sICJQYWdlIGJsb2NrIG9yZGVyOiAlZFxuIiwgcGFnZWJs
b2NrX29yZGVyKTsNCi0Jc2VxX3ByaW50ZihtLCAiUGFnZXMgcGVyIGJsb2NrOiAgJWx1XG4iLCBw
YWdlYmxvY2tfbnJfcGFnZXMpOw0KKwlzZXFfcHJpbnRmKG0sICJQYWdlIGJsb2NrIG9yZGVyOiAl
ZFxuIiwgTUFYX09SREVSIC0gMSk7DQorCXNlcV9wcmludGYobSwgIlBhZ2VzIHBlciBibG9jazog
ICVsdVxuIiwgTUFYX09SREVSX05SX1BBR0VTKTsNCiAJc2VxX3B1dGMobSwgJ1xuJyk7DQogCXBh
Z2V0eXBlaW5mb19zaG93ZnJlZShtLCBwZ2RhdCk7DQogCXBhZ2V0eXBlaW5mb19zaG93YmxvY2tj
b3VudChtLCBwZ2RhdCk7DQotLSANCjEuOS4xDQoNCg==

