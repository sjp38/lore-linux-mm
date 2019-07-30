Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5112C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BB62206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 12:32:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="U4ULND1I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BB62206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E87578E0003; Tue, 30 Jul 2019 08:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E380F8E0001; Tue, 30 Jul 2019 08:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFFED8E0003; Tue, 30 Jul 2019 08:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81CF08E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:32:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so40223271edx.10
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 05:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=UFQB2S6xecD2wMGU1nLejn6fYEEMo3CNtrkz2XQC/vU=;
        b=YLKwexDJ8//94yWDVcTjXvPUL7+pDg8Jisvr2f69rOWTL9iU189T3quGT7Wm6RqOzq
         AwF57Zvw8f7seKC9DjxvnGMFGUkLS3qnxi932ALwUA1ZuHMAqT3pPldfAY9y9+iUHFcB
         BIQPKMF2i7s1mgH50mK7apdQb8LqGxUpuOC0QGevajH976sjTpiiQlzb/SBWTyLJ7J25
         ynVSUhiUknGJMTXQRxkz3Zg8vFTSYZKXVO5/9jJ3WolAhQnUDnpBEbrGtiU+u8ZK0FHS
         FNLLbncu7yVQXFktDz/Dh+AvcfsT9F8Jv8w7/wPquxbxvHPySX7CjFuj9+4aHigyJKj/
         OylQ==
X-Gm-Message-State: APjAAAX5N2MBkndbybMbbxzLw2QNqHdGGtc+bMoxdLRW6Q7NKK05qUjG
	CgoJHgYucLAzwR8897NXpbX75OQANfgGgY63tCu8B3gMvQZZKJRa8jeZapRxCDS5qUdBlWog6eE
	fvezOAUixTRZnLIfoD4oVm/Scz6W+qu/MmOU7I+CcpgfANZ6Ln29NIztvuNdngJuZgA==
X-Received: by 2002:a17:906:b6c6:: with SMTP id ec6mr90813382ejb.183.1564489947976;
        Tue, 30 Jul 2019 05:32:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXOKsdsEuypSbdTLyoIXuG8hEgKcy5mq1Iqgyscd0cDAIrc2nVkNVtOxgin1+3NngrG6dv
X-Received: by 2002:a17:906:b6c6:: with SMTP id ec6mr90813326ejb.183.1564489947203;
        Tue, 30 Jul 2019 05:32:27 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564489947; cv=pass;
        d=google.com; s=arc-20160816;
        b=Gu81vl/KFr9DcwaqHmU9iYx8ug5ajUvcJD6nnp55xvDMedDktAl3dka+6E0zmyoA9U
         AksPFivvO4oeSsZnssf30J4R8kKiuVRgh3aXFuzY3LCFbv58XaZGTrJB/MtePL/3lZjr
         U3xh+90eUBQKGor6OuUJRkQAOUXT8GDNxuck7uhxjDtxiTFXtP/gn6UyLOCSEOK5+VNV
         9MlWb/CAwq3PGhjRoQact/zkEiYp9iA90ry8eoLgpC8FLYnRXSC8VnzBL6rfxZfCEqpO
         y6mhea2uSIih1u1XLyqKPJW4MfmX6dw69QEjGcrOiG/g9oUl5UwfwRG8ke3kEg99LnrL
         okoQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=UFQB2S6xecD2wMGU1nLejn6fYEEMo3CNtrkz2XQC/vU=;
        b=C+s6elx2seA/uDb1CC9rNwggE0UxapQADaXmsGDat/yB4X9ypsHmw6fyaHOdVXZj37
         xonew/gnnxZdjVLx1D5B29ooYiVPjED7kV78yg4mu+kK6hgLAEga5c9qtT+6a2ZNkCgM
         5Sss4ziYZ8Du5ghfSc/RNAEZUjKnJyT1vw79eNy73Xtz1H5dsHo99Y01TYkRMYmUyQ/j
         RG7RR4WKoB2SUMWwatvHhVu+MUW0igiDkeKyBRK+PQ9MzhyAn5oZ6sr22CGRWDFpgGFk
         /p2NriYo0M3UxBaFe5jJCOCvexutmVNu4jvp7pgLbeLXUgHlZhxwPempcup+BcLGQ33+
         Bdrg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=U4ULND1I;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.81 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140081.outbound.protection.outlook.com. [40.107.14.81])
        by mx.google.com with ESMTPS id w19si19175129edb.426.2019.07.30.05.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 05:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.14.81 as permitted sender) client-ip=40.107.14.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=U4ULND1I;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.14.81 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=lbmvjhBRzTFVkny1Frjd0si1jvRJYzXi3kkSt7QCGbiRqNy831pRHPEA4GZquR77JWJ7qaMgSqM5Yn00dT0OyG9XerTn1JAK8Rj1ub1M5uudsfrtmJQl3yDLqq/fMZajcSm6rqs/uEhSsKK5KD7St9K1RD7PazgUXYKal6SegKrZHHRTok+479FCSV02QYf6X+ptzhi0ydyIow2KRVthi7+pkBBinwXG7UezMuZOwF1nAbrOxmwosOy54fgTvwbyJDWy6C6hLO/czyelW0gjPfOecFot9NyNzo4Yr6gTjFtzeySFvQFg6wd5ojoViMhuMXwJdEEYsUvNGY8PDfsupQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UFQB2S6xecD2wMGU1nLejn6fYEEMo3CNtrkz2XQC/vU=;
 b=oCUkNidF8RodlBQy2tuty+1R0ZSRUI7w2F2qTn9p+rl497t/G6XbwlYq+5lgcQlwvmTiwbziXoZ00m5fU22Ildb9goPiD/VryI+ucDtUxMNbO0hLt6gLxbJEGco+srav2A71uMk0VvMem4Z7Y7JRuNhB8S7h6/EV9+Kq9bBMry2RAlqqqXl1Yl8u+CyZVSdjXbvupb9Y7Zo9R6tfl7hK2XaqeUcIrGHMRP4dyF+beBT6JKNs+Y8ss7NIs3mytmrsJheFfHFAdPLqkKVCDXnsPyoZB+cDTcOS9slj3tsXlpavNKku3SrTHwi806Y1uRsYo/Rz143NvrckUE3fU0FnQg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UFQB2S6xecD2wMGU1nLejn6fYEEMo3CNtrkz2XQC/vU=;
 b=U4ULND1ISlyXvfnH6NSyG9KQxcq/imViTjbbwhAoeCxDdBpKTwt3p3jUXogNOeeq8nfsPzst00/yfbBhWgxWVKfgd1gksM+suP8ypPHilyo09S/Jmqoyd6Hl1GGEQV6COlChJP7h/k+T9CJ6asyavcPgWlPXlu/G294/TSKCzD8=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1SPR01MB0364.eurprd05.prod.outlook.com (20.178.120.75) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.14; Tue, 30 Jul 2019 12:32:25 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 12:32:24 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, Bharata B Rao
	<bharata@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: turn the hmm migrate_vma upside down
Thread-Topic: turn the hmm migrate_vma upside down
Thread-Index: AQHVRhn28oqImcObYUq1zSBrPKZAdqbjGXIA
Date: Tue, 30 Jul 2019 12:32:24 +0000
Message-ID: <20190730123218.GA24038@mellanox.com>
References: <20190729142843.22320-1-hch@lst.de>
In-Reply-To: <20190729142843.22320-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YT1PR01CA0033.CANPRD01.PROD.OUTLOOK.COM (2603:10b6:b01::46)
 To VI1PR05MB4141.eurprd05.prod.outlook.com (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c18f707b-6880-4b17-a36c-08d714e9f9bd
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1SPR01MB0364;
x-ms-traffictypediagnostic: VI1SPR01MB0364:
x-microsoft-antispam-prvs:
 <VI1SPR01MB03645AFA980727C42C0389D2CFDC0@VI1SPR01MB0364.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(39860400002)(366004)(376002)(346002)(136003)(189003)(199004)(7736002)(102836004)(3846002)(6116002)(305945005)(54906003)(4326008)(2906002)(6436002)(229853002)(26005)(71190400001)(316002)(256004)(6916009)(71200400001)(14454004)(6246003)(11346002)(386003)(25786009)(2616005)(446003)(76176011)(7416002)(36756003)(52116002)(6486002)(186003)(478600001)(53936002)(6512007)(66476007)(81166006)(81156014)(66946007)(8676002)(1076003)(8936002)(66556008)(66066001)(6506007)(476003)(486006)(5660300002)(4744005)(33656002)(66446008)(99286004)(64756008)(86362001)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1SPR01MB0364;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 msbywfwkvnpnsvMndsoiuFCLEUQHJ+XtoRCAMwEqU0NJ7StslpBWur8p/UBIozFDR4WcUXWot7YOtTKTQpPuFAHZ2MNsUPuBx1llsDUl+viBOY7+g8Z5jdno6/6uXm1l8Xyf84OfUq2UF4pXDIM5WI0GFGOk2SuJttUnGAAc8MiocpNl1tfAmkVapc9/RE3QULgIwpXlBo4PC/53akjoH7LmKvbPDXX0taZZrP7cN+PC2pf4htGu/Nit0Y5uVZbyvnbqd8Hk5SF3rk9SumSeybRmg7ok8NopimmSf+8TBfsRhZiJJUCZiemFD8FPw8Z4fVJJjCMa+fk7T08K/q5pKU/ko51lMNfi65+sxFYyC8jHl7nXpb1tuSAVBrWbcIBbAFmfrJ8T8MiH1qm7P09YNv6WhLEdGyQxZRhqRhrzK6M=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FE2AEDB2FC12424C805E7D754CCE4C1A@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c18f707b-6880-4b17-a36c-08d714e9f9bd
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 12:32:24.8223
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1SPR01MB0364
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCBKdWwgMjksIDIwMTkgYXQgMDU6Mjg6MzRQTSArMDMwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIErDqXLDtG1lLCBCZW4gYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgYWdhaW5zdCB0aGUgaG1tIHRyZWUgd2hpY2ggc3RhcnRzIHJldmFtcGluZyB0aGUN
Cj4gbWlncmF0ZV92bWEgZnVuY3Rpb25hbGl0eS4gIFRoZSBwcmltZSBpZGVhIGlzIHRvIGV4cG9y
dCB0aHJlZSBzbGlnaHRseQ0KPiBsb3dlciBsZXZlbCBmdW5jdGlvbnMgYW5kIHRodXMgYXZvaWQg
dGhlIG5lZWQgZm9yIG1pZ3JhdGVfdm1hX29wcw0KPiBjYWxsYmFja3MuDQoNCkkgZG9uJ3QgZmVl
bCBJIGNhbiBjb250cmlidXRlIGEgd29ydGh3aGlsZSByZXZpZXcgZm9yIHRoaXMgcGFydCBvZiB0
aGUNCmNvZGUgcmlnaHQgbm93Lg0KDQpEb2VzIHRoaXMgb25seSBpbXBhY3QgaG1tIHVzZXJzLCBv
ciBkb2VzIG1pZ3JhdGUuYyBoYXZlIGEgYnJvYWRlcg0KdXNhZ2U/DQoNCldobyBkbyB3ZSBuZWVk
IG9uIHJldmlldyB0byBwcm9ncmVzcyBvbiB0aGlzPw0KDQpUaGFua3MsDQpKYXNvbg0K

