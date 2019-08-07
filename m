Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C78EDC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:16:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F15021BE3
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:16:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="nKfaGar1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F15021BE3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F260B6B0003; Wed,  7 Aug 2019 15:16:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED6236B0006; Wed,  7 Aug 2019 15:16:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9E436B0007; Wed,  7 Aug 2019 15:16:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 881246B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 15:16:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a15so63369edv.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 12:16:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=pMOHoPa07aXfVJpE5Faowks/FP6FWc28xgM4je0v0MM=;
        b=jghzGG9CoGoScMtH4JOYre0WyOzY6k2SGx6Ns0YKdx4q49ksvgXxaN142Pol3VJlOm
         qrkaHzRVdndoJrImlG1JaBHGCOJZXSxvMr/CitL2ycnRwlQ1t6TbYnwIF78bRhVbrWjS
         r9Q0gEPPF962b8ntPBS/bTnTg2/LjpZb89SbrMebtO2w2hpZ2kinI7rZ8vHZlbrq++F4
         qSRWMHEQvmeeQxV667794CTo4ZHxu1Z8CdwhRofIiExfA9ofSDq6HsqK0AfA0o4SEYVs
         h9F4dgz8iw2CLVvDoJi7aMatNpQz/4sFQ7O8nG39yoipR6F3p1ywarzBM2kERmdX50Lj
         etHw==
X-Gm-Message-State: APjAAAURZGDwFjzhZ+tzl071D1ulSOS0cJ+0nBAV/xUG1QCpY0TxjFny
	7SQ1IswbXEkQuBMozgYlzskcfvlmldnqEPFsWvnhODevO2otwsRvcWOpjE9b8TjlYinKfOQRIwA
	KD50j2eYIML+Ee9Q1CA9GfN0Op/1nYLxzzSd9qaqDBYLeniYLOyH1Uk52Fi8beTjovg==
X-Received: by 2002:a50:91ae:: with SMTP id g43mr11678320eda.279.1565205395116;
        Wed, 07 Aug 2019 12:16:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxP1rC6heHlTDJNIKDC4eP4hlfSSGkPklCmcEk7tSzmjCxT0Uyyq5wkUYKjoyudf6LdJSOV
X-Received: by 2002:a50:91ae:: with SMTP id g43mr11678255eda.279.1565205394320;
        Wed, 07 Aug 2019 12:16:34 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565205394; cv=pass;
        d=google.com; s=arc-20160816;
        b=eK3zfGXPKnt7dcfZMCCr9K8iRX259rNW5VCXT4JA8EpZJIz/yP9I3I+uw5XA52Df6z
         /WCtyNe0ieZX5vvXHBXdt9Sf2U4zwgX+JlFsdd+t4AYeS5k1RCiftG0rWPmcLbzdoxd2
         G/DQ53dTwUdo5zqUJMVgYOcLqUho9jhCWhW3ZTJHCxS1v7nYrbyFcjN3OuDbPxePm2Oz
         /n9HZaX7E19OKWEV7BCDhWqbD8yRjvFhgxGEOQlSyoO0jOd1fi0ArVcqCy/Ho/c4UY+B
         mycjbG9UqmgmQud5vUWEOgdf1vb1/cXyciz7BzGvJODWW3gZDWwnFpYn3DIG6k4SCzqi
         Pziw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=pMOHoPa07aXfVJpE5Faowks/FP6FWc28xgM4je0v0MM=;
        b=jgha4GkxJSxniay+nfmpkJxplbEWrUyNwYmf6VRD2T0CrIQudE0RTrZ416OGNQuVZ5
         VhaGoLO94HJMRmfoWboI+TYU8YK1GwGVV+4Nztx+ZQp+KrMWC3rZxRnQdO4Kyjp/Ck8X
         KEIsQx9kcsjLOllHC9vW2i2LbdfNmnYnf71Mnq8SiU29RZZzADGg+AzcBV8DXXUCkH9R
         Sc59qwdeXsIBN0EqgkjW0V+77L1q9A1aVPKzd/gxWcn+0dvWZCaBlG4cTvsZhrNYvFad
         XdH0LeIJmXR/nI02tCG1RxArJpUraxmDuQzhOvd6Jre6oqSKR6s5z2JXoHcJLo7CPIrh
         nl7A==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nKfaGar1;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20078.outbound.protection.outlook.com. [40.107.2.78])
        by mx.google.com with ESMTPS id i3si32905668eda.107.2019.08.07.12.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 12:16:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.2.78 as permitted sender) client-ip=40.107.2.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=nKfaGar1;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.2.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mXd5FNGqs7qd3AZEhl3hyGKFIeHoA39ge7hC81JNHBhE3EjZMIX+SqYs0Pvr6qQTIHB0z6f8KGnYi0Ow30cIsLzqYbMHRkrzObCYNQBkyVKc2zgdyjRSmkO+SS+fztUfiJfXfUrvNJ+WuPKKYKUA0PfnAWucxIwiQcvJNc9TXGcGyops6nLyDYrbbzYND3H1AQyzFc3+G3pHruaPNqsUCjma4WfDqmNyMa3w9ApqrY/zmh/+tJZijn/d0ZVfqkFU5iDGuuC2L/B4GEwRtqw/vI0z0NhP4MlHIdD0/hemG/9ej340+wjxQrw+fTUOtTYM1RoNS7x17asH5CeJ3HElow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pMOHoPa07aXfVJpE5Faowks/FP6FWc28xgM4je0v0MM=;
 b=h0RMBb9urnAV5LePmx6m8FyIQqmzn6r9/Q1Pq2f0qthpCVH3D3kCP+O3k7NMBD3jbue+HdE/HKExPlvun2NL7QQx3fy+v2j7dYl2yEKSEtfmbwRtybzfQLXNfiQ+ILNGq9ChP1BPfQRFA/rqaMNNRlv42K1cCkYx57lIaoDhQIS0/yKaSKpSSQC713zs1REmhT88lA1YLTZF8tNIgntvCB2m4gdKPhSQsntwIH6UXIxdP9l9+rlkZLYG0aiUoUw+lY2+u3zeBRlyRAcreCMi5vAu/ru4VFnpW3TjnytX7Xp8to9+dLNB92C+L4S3fcumY+asofTvXkNvWpz9Gt+WHg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pMOHoPa07aXfVJpE5Faowks/FP6FWc28xgM4je0v0MM=;
 b=nKfaGar1+2N77EAD+X/SKWjo9xRYRyAa5xPuxrQSuhYAvdmQ8Y4YJz47WSY5fQ8sHaqUaT3mlgFTJEKyyOo+MaPv7FOS15HqKS3ASoAepromIHQ2zYpbV7HlBdaPfD+P3yxSBVfyCF5f4D5DdRYqB2gNnIu1/N3p0R5StJ8P22E=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6064.eurprd05.prod.outlook.com (20.178.204.74) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.14; Wed, 7 Aug 2019 19:16:33 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 19:16:33 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrea Arcangeli
	<aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mm/mmn: prevent unpaired invalidate_start and invalidate_end
 with non-blocking
Thread-Topic: [PATCH] mm/mmn: prevent unpaired invalidate_start and
 invalidate_end with non-blocking
Thread-Index: AQHVTVSfVNc5Iz/dOkyoKdT7iQpJSw==
Date: Wed, 7 Aug 2019 19:16:32 +0000
Message-ID: <20190807191627.GA3008@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0072.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::49) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a44207ad-0643-4da2-30b9-08d71b6bc218
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6064;
x-ms-traffictypediagnostic: VI1PR05MB6064:
x-microsoft-antispam-prvs:
 <VI1PR05MB606439BB6C33853BC1EEAD5BCFD40@VI1PR05MB6064.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(136003)(396003)(39860400002)(346002)(366004)(199004)(189003)(305945005)(7736002)(53936002)(36756003)(2501003)(8936002)(256004)(6116002)(66066001)(14444005)(71190400001)(3846002)(14454004)(71200400001)(66476007)(66446008)(66556008)(64756008)(66946007)(6506007)(386003)(25786009)(2906002)(102836004)(476003)(33656002)(486006)(99286004)(86362001)(52116002)(478600001)(8676002)(26005)(186003)(5660300002)(66574012)(6486002)(54906003)(110136005)(6512007)(9686003)(6436002)(316002)(81156014)(4326008)(81166006)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6064;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xWmf52uy9DhMeZjJxftnTdQrncXLB9Mrf1xtWptO4rQtfp1rlibG3v6Ei8Lr0t2sAepjolqkY69z/k1+hza99+k19XP9nwvzZtkchpLQxiDuZCGtd+QlSHcL/B95mF19jynCwQNFWWo8//8hBu1DdR/9WQq02rnccMLci5MLrvY66SR4012WaYZa2GvYP/DdtXVj5JnijLgLcXMuP/CD7ZqEgffHqcf/nSw8TpHR7NLicFLjOPtNGyC5JCJdOjqdqrV0/H0mmtXaGP6TlfV/0UMkVh9pPTf2Oot2shD2fQLHynG2bXSLMY9doU/cGfYMT61IVZ5xfphPv0fO5mMLEqKFTgGf7ocncypXK1TwiCn3jxfyh1djeyzPmMQbzqTDF+fZp+HbZmN8MLsfBmeiDJcz9x4hri/1gtNacDXd5Ko=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2C39424E4A67374A9FD32E0888EAEE0A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a44207ad-0643-4da2-30b9-08d71b6bc218
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 19:16:32.9519
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6064
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

TWFueSB1c2VycyBvZiB0aGUgbW11X25vdGlmaWVyIGludmFsaWRhdGVfcmFuZ2UgY2FsbGJhY2tz
IG1haW50YWluDQpsb2NraW5nL2NvdW50ZXJzL2V0YyBvbiBhIHBhaXJlZCBiYXNpcyBhbmQgaGF2
ZSBsb25nIGV4cGVjdGVkIHRoYXQNCmludmFsaWRhdGVfcmFuZ2Ugc3RhcnQvZW5kIGFyZSBhbHdh
eXMgcGFpcmVkLg0KDQpUaGUgcmVjZW50IGNoYW5nZSB0byBhZGQgbm9uLWJsb2NraW5nIG5vdGlm
aWVycyBicmVha3MgdGhpcyBhc3N1bXB0aW9uDQp3aGVuIG11bHRpcGxlIG5vdGlmaWVycyBhcmUg
cHJlc2VudCBpbiB0aGUgbGlzdCBhcyBhbiBFQUdBSU4gcmV0dXJuIGZyb20gYQ0KbGF0ZXIgbm90
aWZpZXIgY2F1c2VzIGFsbCBlYXJsaWVyIG5vdGlmaWVycyB0byBnZXQgdGhlaXINCmludmFsaWRh
dGVfcmFuZ2VfZW5kKCkgc2tpcHBlZC4NCg0KRHVyaW5nIHRoZSBkZXZlbG9wbWVudCBvZiBub24t
YmxvY2tpbmcgZWFjaCB1c2VyIHdhcyBhdWRpdGVkIHRvIGJlIHN1cmUNCnRoZXkgY2FuIHNraXAg
dGhlaXIgaW52YWxpZGF0ZV9yYW5nZV9lbmQoKSBpZiB0aGVpciBzdGFydCByZXR1cm5zIC1FQUdB
SU4sDQpzbyB0aGUgb25seSBwbGFjZSB0aGF0IGhhcyBhIHByb2JsZW0gaXMgd2hlbiB0aGVyZSBh
cmUgbXVsdGlwbGUNCnN1YnNjcmlwdGlvbnMuDQoNCkR1ZSB0byB0aGUgUkNVIGxvY2tpbmcgd2Ug
Y2FuJ3QgcmVsaWFibHkgZ2VuZXJhdGUgYSBzdWJzZXQgb2YgdGhlIGxpbmtlZA0KbGlzdCByZXBy
ZXNlbnRpbmcgdGhlIG5vdGlmaWVycyBhbHJlYWR5IGNhbGxlZCwgYW5kIGdlbmVyYXRlIGFuDQpp
bnZhbGlkYXRlX3JhbmdlX2VuZCgpIHBhaXJpbmcuDQoNClJhdGhlciB0aGFuIGRlc2lnbiBhbiBl
bGFib3JhdGUgZml4LCBmb3Igbm93LCBqdXN0IGJsb2NrIG5vbi1ibG9ja2luZw0KcmVxdWVzdHMg
ZWFybHkgb24gaWYgdGhlcmUgYXJlIG11bHRpcGxlIHN1YnNjcmlwdGlvbnMuDQoNCkZpeGVzOiA5
MzA2NWFjNzUzZTQgKCJtbSwgb29tOiBkaXN0aW5ndWlzaCBibG9ja2FibGUgbW9kZSBmb3IgbW11
IG5vdGlmaWVycyIpDQpDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jb20+DQpDYzogIkrD
qXLDtG1lIEdsaXNzZSIgPGpnbGlzc2VAcmVkaGF0LmNvbT4NCkNjOiBBbmRyZWEgQXJjYW5nZWxp
IDxhYXJjYW5nZUByZWRoYXQuY29tPg0KQ2M6IENocmlzdG9waCBIZWxsd2lnIDxoY2hAbHN0LmRl
Pg0KU2lnbmVkLW9mZi1ieTogSmFzb24gR3VudGhvcnBlIDxqZ2dAbWVsbGFub3guY29tPg0KLS0t
DQogaW5jbHVkZS9saW51eC9tbXVfbm90aWZpZXIuaCB8ICAxICsNCiBtbS9tbXVfbm90aWZpZXIu
YyAgICAgICAgICAgIHwgMTUgKysrKysrKysrKysrKysrDQogMiBmaWxlcyBjaGFuZ2VkLCAxNiBp
bnNlcnRpb25zKCspDQoNCkhDSCBzdWdnZXN0ZWQgdG8gbWFrZSB0aGUgbG9ja2luZyBjb21tb24g
c28gd2UgZG9uJ3QgbmVlZCB0byBoYXZlIGFuDQppbnZhbGlkYXRlX3JhbmdlX2VuZCwgYnV0IHRo
YXQgaXMgYSBsb25nZXIgam91cm5leS4NCg0KSGVyZSBpcyBhIHNpbXBsZXIgc3RvcC1nYXAgZm9y
IHRoaXMgYnVnLiBXaGF0IGRvIHlvdSB0aGluayBNaWNoYWw/DQpJIGRvbid0IGhhdmUgYSBnb29k
IHdheSB0byB0ZXN0IHRoaXMgZmxvdyAuLg0KDQpUaGlzIGxpZ2h0bHkgY2xhc2hlcyB3aXRoIHRo
ZSBvdGhlciBtbXUgbm90aWZpZmVyIHNlcmllcyBJIGp1c3Qgc2VudCwNCnNvIGl0IHNob3VsZCBn
byB0byBlaXRoZXIgLXJjIG9yIGhtbS5naXQNCg0KVGhhbmtzLA0KSmFzb24NCg0KZGlmZiAtLWdp
dCBhL2luY2x1ZGUvbGludXgvbW11X25vdGlmaWVyLmggYi9pbmNsdWRlL2xpbnV4L21tdV9ub3Rp
Zmllci5oDQppbmRleCBiNmMwMDRiZDlmNmFkOS4uMTcwZmEyYzY1ZDY1OWMgMTAwNjQ0DQotLS0g
YS9pbmNsdWRlL2xpbnV4L21tdV9ub3RpZmllci5oDQorKysgYi9pbmNsdWRlL2xpbnV4L21tdV9u
b3RpZmllci5oDQpAQCAtNTMsNiArNTMsNyBAQCBzdHJ1Y3QgbW11X25vdGlmaWVyX21tIHsNCiAJ
c3RydWN0IGhsaXN0X2hlYWQgbGlzdDsNCiAJLyogdG8gc2VyaWFsaXplIHRoZSBsaXN0IG1vZGlm
aWNhdGlvbnMgYW5kIGhsaXN0X3VuaGFzaGVkICovDQogCXNwaW5sb2NrX3QgbG9jazsNCisJYm9v
bCBtdWx0aXBsZV9zdWJzY3JpcHRpb25zOw0KIH07DQogDQogI2RlZmluZSBNTVVfTk9USUZJRVJf
UkFOR0VfQkxPQ0tBQkxFICgxIDw8IDApDQpkaWZmIC0tZ2l0IGEvbW0vbW11X25vdGlmaWVyLmMg
Yi9tbS9tbXVfbm90aWZpZXIuYw0KaW5kZXggYjU2NzA2MjBhZWEwZmMuLjRlNTZmNzVjNTYwMjQy
IDEwMDY0NA0KLS0tIGEvbW0vbW11X25vdGlmaWVyLmMNCisrKyBiL21tL21tdV9ub3RpZmllci5j
DQpAQCAtMTcxLDYgKzE3MSwxOSBAQCBpbnQgX19tbXVfbm90aWZpZXJfaW52YWxpZGF0ZV9yYW5n
ZV9zdGFydChzdHJ1Y3QgbW11X25vdGlmaWVyX3JhbmdlICpyYW5nZSkNCiAJaW50IHJldCA9IDA7
DQogCWludCBpZDsNCiANCisJLyoNCisJICogSWYgdGhlcmUgaXMgbW9yZSB0aGFuIG9uZSBub3Rp
ZmlmZXIgc3Vic2NyaWJlZCB0byB0aGlzIG1tIHRoZW4gd2UNCisJICogY2Fubm90IHN1cHBvcnQg
dGhlIEVBR0FJTiByZXR1cm4uIGludmFsaWRhdGVfcmFuZ2Vfc3RhcnQvZW5kKCkgbXVzdA0KKwkg
KiBhbHdheXMgYmUgcGFpcmVkIHVubGVzcyBzdGFydCByZXR1cm5zIC1FQUdBSU4uIFdoZW4gd2Ug
cmV0dXJuDQorCSAqIC1FQUdBSU4gZnJvbSBoZXJlIHRoZSBjYWxsZXIgd2lsbCBza2lwIGFsbCBp
bnZhbGlkYXRlX3JhbmdlX2VuZCgpDQorCSAqIGNhbGxzLiBIb3dldmVyLCBpZiB0aGVyZSBpcyBt
b3JlIHRoYW4gb25lIG5vdGlmaWZlciB0aGVuIHNvbWUNCisJICogbm90aWZpZXJzIG1heSBoYXZl
IGhhZCBhIHN1Y2Nlc3NmdWwgaW52YWxpZGF0ZV9yYW5nZV9zdGFydCgpIC0NCisJICogY2F1c2lu
ZyBpbWJhbGFuY2Ugd2hlbiB0aGUgZW5kIGlzIHNraXBwZWQuDQorCSAqLw0KKwlpZiAoIW1tdV9u
b3RpZmllcl9yYW5nZV9ibG9ja2FibGUocmFuZ2UpICYmDQorCSAgICByYW5nZS0+bW0tPm1tdV9u
b3RpZmllcl9tbS0+bXVsdGlwbGVfc3Vic2NyaXB0aW9ucykNCisJCXJldHVybiAtRUFHQUlOOw0K
Kw0KIAlpZCA9IHNyY3VfcmVhZF9sb2NrKCZzcmN1KTsNCiAJaGxpc3RfZm9yX2VhY2hfZW50cnlf
cmN1KG1uLCAmcmFuZ2UtPm1tLT5tbXVfbm90aWZpZXJfbW0tPmxpc3QsIGhsaXN0KSB7DQogCQlp
ZiAobW4tPm9wcy0+aW52YWxpZGF0ZV9yYW5nZV9zdGFydCkgew0KQEAgLTI3NCw2ICsyODcsOCBA
QCBzdGF0aWMgaW50IGRvX21tdV9ub3RpZmllcl9yZWdpc3RlcihzdHJ1Y3QgbW11X25vdGlmaWVy
ICptbiwNCiAJICogdGhhbmtzIHRvIG1tX3Rha2VfYWxsX2xvY2tzKCkuDQogCSAqLw0KIAlzcGlu
X2xvY2soJm1tLT5tbXVfbm90aWZpZXJfbW0tPmxvY2spOw0KKwltbS0+bW11X25vdGlmaWVyX21t
LT5tdWx0aXBsZV9zdWJzY3JpcHRpb25zID0NCisJCSFobGlzdF9lbXB0eSgmbW0tPm1tdV9ub3Rp
Zmllcl9tbS0+bGlzdCk7DQogCWhsaXN0X2FkZF9oZWFkX3JjdSgmbW4tPmhsaXN0LCAmbW0tPm1t
dV9ub3RpZmllcl9tbS0+bGlzdCk7DQogCXNwaW5fdW5sb2NrKCZtbS0+bW11X25vdGlmaWVyX21t
LT5sb2NrKTsNCiANCi0tIA0KMi4yMi4wDQoNCg==

