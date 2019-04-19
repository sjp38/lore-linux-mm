Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B6ECC282E2
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:34:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77D8A20663
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:34:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="KVdoONVT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77D8A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 837166B0003; Fri, 19 Apr 2019 18:34:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E5626B0006; Fri, 19 Apr 2019 18:34:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6603F6B0007; Fri, 19 Apr 2019 18:34:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 240746B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 18:34:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b7so2569308plb.17
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=U1ChUgeZBy6ysBqXTqfVa5bLBQo6eZNlwnFBkTjynF0=;
        b=IuGfO4aB4iGvsIFsvjtZbqrYF7b8QBPfHFBM7YWHikINdGTj5aigR1GYQ+t+L25K0/
         rToJMIN6OZ0HgiNbsxD9yP9dOprVNeqFNC4g/ch8QF8zkmUZP8Kwyt1AKkURBMjjfK/q
         p194y9JDS7qhzwaZWLpNr5b9hkcbYIeGINxLsy1SOqxoDXQae6+ud6JTFz0n4ocNj7Oe
         E3C6SlQ0AzJIDspuR4ZHXC8talfbD4OiMa1Z8hFTtoCjt/tnjtSI6NfBWh3UyNdo+tf8
         DHLi3n0Qsjn6cE+zQIkyTjHfZxKp6g2dMIm+StfshnwJvxoxD+zNU3ov8pfY59CD7zVO
         X4qg==
X-Gm-Message-State: APjAAAX3baITLs7+8Mi33dz51RnPH60/H1+ubGP7BT21LcDUT6R2IrpF
	JNmihUPdT4CduLcQNUnLGkSvEuGPfaMB8lgr2xoDJVF6qVbvbtrNhgu5Q+AwdfuuHcGLSmdyzpN
	f+ZqWUeRAmGSRC6ZzVnFESO2NwpL458t20VdY+G2oUXEndAoTiv9nezyewkLdSgxJxQ==
X-Received: by 2002:a63:2c09:: with SMTP id s9mr6089880pgs.411.1555713255448;
        Fri, 19 Apr 2019 15:34:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz98h6kFXawDeDmbVZ3yrbfHGXuzEyuY5/+PJKJAM7YFdNDhVOYTdgd5QPDGHzM8ECgijzk
X-Received: by 2002:a63:2c09:: with SMTP id s9mr6089803pgs.411.1555713254486;
        Fri, 19 Apr 2019 15:34:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555713254; cv=none;
        d=google.com; s=arc-20160816;
        b=xduLPCdoXm/o3gG+xNWcmhCZBKMIdKcpWAHiXI18TSxofqrnvdZejDg9HHlhu4TL+X
         QGhwlJ9/Lkq6lQmXSTaPUdnvTYW8nQ09CZOHAxqAxYaNuIT5hAG4fBG6tW4W7uKOrgyG
         F6R3S+0zvDZ+GYZipDaC/djuq2lvbs6YaF5Znk5X2mSnhA2lzxsjUtHlPf1aMqgXoqYn
         VZlzw16BN6CGT7X3fa/U+JkJh20wAVB95hteGlpm/xNWKJ6Xz9RzPbRqKnTi7DY+uC4c
         U0QJpXyR7i2L7P5YKwUYwNzR8nqNgqGX+ZtNS8YT5vMmjW8NLNMPMxHeihIEJDfloKfY
         U/nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=U1ChUgeZBy6ysBqXTqfVa5bLBQo6eZNlwnFBkTjynF0=;
        b=XPr80bIsZM8RhFmchq+5GkoekuWg+aT5PlG+XWfy0sr0Tr9QBVNYIUx3oVPCvx0iGo
         HAXgM5YywraK3Cl3ykVg2b279vnNnfpDY/Fjfk9MElzRWHnmWUWI0NNzc9aN1iRz+N+A
         EHTyVmYbxNTVuyEgvtTb/Wv54kufgkNXU/SqSgMaJ5ZGfsX4EJI43pb9GSoL8GBkE9pp
         kUDnZwuCQ1+kOBe5Xa9eBKPTcEOwdnUIOpE5IzpFiXyH3UsnzSudWb13eNpHOQVL2tRz
         C28XTJf74Qn/8mMEMnMwZR3G7xBnGWCFy/4s4Z+TB0xSVxDKja+AJqW2+Nh1Pn1cMCSd
         ryKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=KVdoONVT;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.72.78 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720078.outbound.protection.outlook.com. [40.107.72.78])
        by mx.google.com with ESMTPS id n12si5954549pgm.191.2019.04.19.15.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Apr 2019 15:34:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.72.78 as permitted sender) client-ip=40.107.72.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=KVdoONVT;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.72.78 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=U1ChUgeZBy6ysBqXTqfVa5bLBQo6eZNlwnFBkTjynF0=;
 b=KVdoONVTgO6jLOb+gKGjuc0fKh7s5nw8WmcVWsqvl2mPkH7zvHcShnWPbcpZ7z3OLRgd3sMhgeDmmwQcrFoF3jiBfOhElf722OB7si7yp7Y1pQRN2fiI+lF8NPGnwOMiP3RN4YQmjYqnq8Qt4RRt66udkkiHQp5BlY3XnZE/eH8=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6424.namprd05.prod.outlook.com (20.178.232.212) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.12; Fri, 19 Apr 2019 22:34:05 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1813.011; Fri, 19 Apr 2019
 22:34:05 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>, Jason Wang <jasowang@redhat.com>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Pv-drivers <Pv-drivers@vmware.com>, Julien
 Freche <jfreche@vmware.com>
Subject: Re: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Topic: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Thread-Index: AQHU5L/fQHqTTJNOzkOghmdzHIOs1aZELwsAgAAHcIA=
Date: Fri, 19 Apr 2019 22:34:04 +0000
Message-ID: <B2DD0CC3-DA8D-408C-986F-130B4B00A892@vmware.com>
References: <20190328010718.2248-1-namit@vmware.com>
 <20190328010718.2248-2-namit@vmware.com>
 <20190419174452-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190419174452-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5041deee-7e57-4dec-8596-08d6c5172133
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB6424;
x-ms-traffictypediagnostic: BYAPR05MB6424:
x-ms-exchange-purlcount: 1
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB6424BFB5FFDAC350D96AB348D0270@BYAPR05MB6424.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0012E6D357
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(136003)(396003)(376002)(366004)(39860400002)(189003)(199004)(229853002)(486006)(86362001)(76176011)(2616005)(6436002)(64756008)(66556008)(66446008)(11346002)(66946007)(6916009)(476003)(7736002)(305945005)(68736007)(66476007)(446003)(966005)(82746002)(71200400001)(5660300002)(478600001)(6486002)(83716004)(71190400001)(66066001)(6306002)(99286004)(6512007)(6246003)(33656002)(107886003)(36756003)(102836004)(97736004)(6116002)(14454004)(25786009)(4326008)(26005)(3846002)(81166006)(14444005)(8676002)(81156014)(53546011)(54906003)(316002)(76116006)(53936002)(186003)(256004)(2906002)(8936002)(6506007)(73956011);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6424;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 P5gHgXt5wNijmtzGz6NVN10NJjV7oFGR2r7SB0O5EWmq+kMEs10M4ZaLbpw+2i//XFJCFcJzu7KRlpjCSzb9sTTnpY9BizmkkB9OVsRdNqog9zWEIsR0dsvbt0KKvifr8nUnCeNCScuItiSvkuIzrD9MYUJY6PWqsjo+ABR9t93JrZynXodH129hqn6r2d4JLiz24PNzDQmw3L/dZSwaFtk7GzIk/h9FxxV/5XGbH1aKP2S0cJfUhDzYNRs1YTh4WY6gaofdR+qLlDSI56hpzgjV2BKbYPYQKSDu3+ktUVFIWcbnOmwKIwG83fEg5mBwfHgCNKA7TbZdNMYa1RdyVoqLUOHQ2oJOXZN9HsYRb1XQaXnSxqkaGpt/yEBCUJqRxcG/P3d4N3HzO8/WXw4vivoPghl21YmOLdfQP8zfc6Q=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2426529FD9E287428CF4ED6F78570C13@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5041deee-7e57-4dec-8596-08d6c5172133
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Apr 2019 22:34:05.0097
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6424
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBBcHIgMTksIDIwMTksIGF0IDM6MDcgUE0sIE1pY2hhZWwgUy4gVHNpcmtpbiA8bXN0QHJl
ZGhhdC5jb20+IHdyb3RlOg0KPiANCj4gT24gVGh1LCBNYXIgMjgsIDIwMTkgYXQgMDE6MDc6MTVB
TSArMDAwMCwgTmFkYXYgQW1pdCB3cm90ZToNCj4+IEludHJvZHVjZSBpbnRlcmZhY2VzIGZvciBi
YWxsb29uaW5nIGVucXVldWVpbmcgYW5kIGRlcXVldWVpbmcgb2YgYSBsaXN0DQo+PiBvZiBwYWdl
cy4gVGhlc2UgaW50ZXJmYWNlcyByZWR1Y2UgdGhlIG92ZXJoZWFkIG9mIHN0b3JpbmcgYW5kIHJl
c3RvcmluZw0KPj4gSVJRcyBieSBiYXRjaGluZyB0aGUgb3BlcmF0aW9ucy4gSW4gYWRkaXRpb24g
dGhleSBkbyBub3QgcGFuaWMgaWYgdGhlDQo+PiBsaXN0IG9mIHBhZ2VzIGlzIGVtcHR5Lg0KPj4g
DQo+PiBDYzogIk1pY2hhZWwgUy4gVHNpcmtpbiIgPG1zdEByZWRoYXQuY29tPg0KPj4gQ2M6IEph
c29uIFdhbmcgPGphc293YW5nQHJlZGhhdC5jb20+DQo+PiBDYzogbGludXgtbW1Aa3ZhY2sub3Jn
DQo+PiBDYzogdmlydHVhbGl6YXRpb25AbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcNCj4+IFJl
dmlld2VkLWJ5OiBYYXZpZXIgRGVndWlsbGFyZCA8eGRlZ3VpbGxhcmRAdm13YXJlLmNvbT4NCj4+
IFNpZ25lZC1vZmYtYnk6IE5hZGF2IEFtaXQgPG5hbWl0QHZtd2FyZS5jb20+DQo+PiAtLS0NCj4+
IGluY2x1ZGUvbGludXgvYmFsbG9vbl9jb21wYWN0aW9uLmggfCAgIDQgKw0KPj4gbW0vYmFsbG9v
bl9jb21wYWN0aW9uLmMgICAgICAgICAgICB8IDE0NSArKysrKysrKysrKysrKysrKysrKystLS0t
LS0tLQ0KPj4gMiBmaWxlcyBjaGFuZ2VkLCAxMTEgaW5zZXJ0aW9ucygrKSwgMzggZGVsZXRpb25z
KC0pDQo+PiANCj4+IGRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2JhbGxvb25fY29tcGFjdGlv
bi5oIGIvaW5jbHVkZS9saW51eC9iYWxsb29uX2NvbXBhY3Rpb24uaA0KPj4gaW5kZXggZjExMWM3
ODBlZjFkLi4xZGE3OWVkYWRiNjkgMTAwNjQ0DQo+PiAtLS0gYS9pbmNsdWRlL2xpbnV4L2JhbGxv
b25fY29tcGFjdGlvbi5oDQo+PiArKysgYi9pbmNsdWRlL2xpbnV4L2JhbGxvb25fY29tcGFjdGlv
bi5oDQo+PiBAQCAtNjQsNiArNjQsMTAgQEAgZXh0ZXJuIHN0cnVjdCBwYWdlICpiYWxsb29uX3Bh
Z2VfYWxsb2Modm9pZCk7DQo+PiBleHRlcm4gdm9pZCBiYWxsb29uX3BhZ2VfZW5xdWV1ZShzdHJ1
Y3QgYmFsbG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+IAkJCQkgc3RydWN0IHBhZ2UgKnBh
Z2UpOw0KPj4gZXh0ZXJuIHN0cnVjdCBwYWdlICpiYWxsb29uX3BhZ2VfZGVxdWV1ZShzdHJ1Y3Qg
YmFsbG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbyk7DQo+PiArZXh0ZXJuIHNpemVfdCBiYWxsb29u
X3BhZ2VfbGlzdF9lbnF1ZXVlKHN0cnVjdCBiYWxsb29uX2Rldl9pbmZvICpiX2Rldl9pbmZvLA0K
Pj4gKwkJCQkgICAgICBzdHJ1Y3QgbGlzdF9oZWFkICpwYWdlcyk7DQo+PiArZXh0ZXJuIHNpemVf
dCBiYWxsb29uX3BhZ2VfbGlzdF9kZXF1ZXVlKHN0cnVjdCBiYWxsb29uX2Rldl9pbmZvICpiX2Rl
dl9pbmZvLA0KPj4gKwkJCQkgICAgIHN0cnVjdCBsaXN0X2hlYWQgKnBhZ2VzLCBpbnQgbl9yZXFf
cGFnZXMpOw0KPiANCj4gV2h5IHNpemVfdCBJIHdvbmRlcj8gSXQgY2FuIG5ldmVyIGJlID4gbl9y
ZXFfcGFnZXMgd2hpY2ggaXMgaW50Lg0KPiBDYWxsZXJzIGFsc28gc2VlbSB0byBhc3N1bWUgaW50
Lg0KDQpPbmx5IGJlY2F1c2Ugb24gdGhlIHByZXZpb3VzIGl0ZXJhdGlvbg0KKCBodHRwczovL2xr
bWwub3JnL2xrbWwvMjAxOS8yLzYvOTEyICkgeW91IHNhaWQ6DQoNCj4gQXJlIHdlIHN1cmUgdGhp
cyBpbnQgbmV2ZXIgb3ZlcmZsb3dzPyBXaHkgbm90IGp1c3QgdXNlIHU2NA0KPiBvciBzaXplX3Qg
c3RyYWlnaHQgYXdheT8NCg0KSSBhbSBvayBlaXRoZXIgd2F5LCBidXQgcGxlYXNlIGJlIGNvbnNp
c3RlbnQuDQoNCj4gDQo+PiBzdGF0aWMgaW5saW5lIHZvaWQgYmFsbG9vbl9kZXZpbmZvX2luaXQo
c3RydWN0IGJhbGxvb25fZGV2X2luZm8gKmJhbGxvb24pDQo+PiB7DQo+IA0KPiANCj4+IGRpZmYg
LS1naXQgYS9tbS9iYWxsb29uX2NvbXBhY3Rpb24uYyBiL21tL2JhbGxvb25fY29tcGFjdGlvbi5j
DQo+PiBpbmRleCBlZjg1OGQ1NDdlMmQuLjg4ZDVkOWEwMTA3MiAxMDA2NDQNCj4+IC0tLSBhL21t
L2JhbGxvb25fY29tcGFjdGlvbi5jDQo+PiArKysgYi9tbS9iYWxsb29uX2NvbXBhY3Rpb24uYw0K
Pj4gQEAgLTEwLDYgKzEwLDEwNiBAQA0KPj4gI2luY2x1ZGUgPGxpbnV4L2V4cG9ydC5oPg0KPj4g
I2luY2x1ZGUgPGxpbnV4L2JhbGxvb25fY29tcGFjdGlvbi5oPg0KPj4gDQo+PiArc3RhdGljIGlu
dCBiYWxsb29uX3BhZ2VfZW5xdWV1ZV9vbmUoc3RydWN0IGJhbGxvb25fZGV2X2luZm8gKmJfZGV2
X2luZm8sDQo+PiArCQkJCSAgICAgc3RydWN0IHBhZ2UgKnBhZ2UpDQo+PiArew0KPj4gKwkvKg0K
Pj4gKwkgKiBCbG9jayBvdGhlcnMgZnJvbSBhY2Nlc3NpbmcgdGhlICdwYWdlJyB3aGVuIHdlIGdl
dCBhcm91bmQgdG8NCj4+ICsJICogZXN0YWJsaXNoaW5nIGFkZGl0aW9uYWwgcmVmZXJlbmNlcy4g
V2Ugc2hvdWxkIGJlIHRoZSBvbmx5IG9uZQ0KPj4gKwkgKiBob2xkaW5nIGEgcmVmZXJlbmNlIHRv
IHRoZSAncGFnZScgYXQgdGhpcyBwb2ludC4NCj4+ICsJICovDQo+PiArCWlmICghdHJ5bG9ja19w
YWdlKHBhZ2UpKSB7DQo+PiArCQlXQVJOX09OQ0UoMSwgImJhbGxvb24gaW5mbGF0aW9uIGZhaWxl
ZCB0byBlbnF1ZXVlIHBhZ2VcbiIpOw0KPj4gKwkJcmV0dXJuIC1FRkFVTFQ7DQo+IA0KPiBMb29r
cyBsaWtlIGFsbCBjYWxsZXJzIGJ1ZyBvbiBhIGZhaWx1cmUuIFNvIGxldCdzIGp1c3QgZG8gaXQg
aGVyZSwNCj4gYW5kIHRoZW4gbWFrZSB0aGlzIHZvaWQ/DQoNCkFzIHlvdSBub3RlZCBiZWxvdywg
YWN0dWFsbHkgYmFsbG9vbl9wYWdlX2xpc3RfZW5xdWV1ZSgpIGRvZXMgbm90IGRvDQphbnl0aGlu
ZyB3aGVuIGFuIGVycm9yIG9jY3Vycy4gSSByZWFsbHkgcHJlZmVyIHRvIGF2b2lkIGFkZGluZyBC
VUdfT04oKSAtIA0KSSBhbHdheXMgZ2V0IHB1c2hlZCBiYWNrIG9uIHN1Y2ggdGhpbmdzLiBZZXMs
IHRoaXMgbWlnaHQgbGVhZCB0byBtZW1vcnkNCmxlYWssIGJ1dCB0aGVyZSBpcyBubyByZWFzb24g
dG8gY3Jhc2ggdGhlIHN5c3RlbS4NCg0KPj4gKwl9DQo+PiArCWxpc3RfZGVsKCZwYWdlLT5scnUp
Ow0KPj4gKwliYWxsb29uX3BhZ2VfaW5zZXJ0KGJfZGV2X2luZm8sIHBhZ2UpOw0KPj4gKwl1bmxv
Y2tfcGFnZShwYWdlKTsNCj4+ICsJX19jb3VudF92bV9ldmVudChCQUxMT09OX0lORkxBVEUpOw0K
Pj4gKwlyZXR1cm4gMDsNCj4+ICt9DQo+PiArDQo+PiArLyoqDQo+PiArICogYmFsbG9vbl9wYWdl
X2xpc3RfZW5xdWV1ZSgpIC0gaW5zZXJ0cyBhIGxpc3Qgb2YgcGFnZXMgaW50byB0aGUgYmFsbG9v
biBwYWdlDQo+PiArICoJCQkJIGxpc3QuDQo+PiArICogQGJfZGV2X2luZm86IGJhbGxvb24gZGV2
aWNlIGRlc2NyaXB0b3Igd2hlcmUgd2Ugd2lsbCBpbnNlcnQgYSBuZXcgcGFnZSB0bw0KPj4gKyAq
IEBwYWdlczogcGFnZXMgdG8gZW5xdWV1ZSAtIGFsbG9jYXRlZCB1c2luZyBiYWxsb29uX3BhZ2Vf
YWxsb2MuDQo+PiArICoNCj4+ICsgKiBEcml2ZXIgbXVzdCBjYWxsIGl0IHRvIHByb3Blcmx5IGVu
cXVldWUgYSBiYWxsb29uIHBhZ2VzIGJlZm9yZSBkZWZpbml0aXZlbHkNCj4+ICsgKiByZW1vdmlu
ZyBpdCBmcm9tIHRoZSBndWVzdCBzeXN0ZW0uDQo+IA0KPiBBIGJ1bmNoIG9mIGdyYW1tYXIgZXJy
b3IgaGVyZS4gUGxzIGZpeCBmb3IgY2xhcmlmeS4NCj4gQWxzbyAtIGRvY3VtZW50IHRoYXQgbm90
aGluZyBtdXN0IGxvY2sgdGhlIHBhZ2VzPyBNb3JlIGFzc3VtcHRpb25zPw0KPiBXaGF0IGlzICJp
dCIgaW4gdGhpcyBjb250ZXh0PyBBbGwgcGFnZXM/IEFuZCB3aGF0IGRvZXMgcmVtb3ZpbmcgZnJv
bQ0KPiBndWVzdCBtZWFuPyBSZWFsbHkgYWRkaW5nIHRvIHRoZSBiYWxsb29uPw0KDQpJIHByZXR0
eSBtdWNoIGNvcHktcGFzdGVkIHRoaXMgZGVzY3JpcHRpb24gZnJvbSBiYWxsb29uX3BhZ2VfZW5x
dWV1ZSgpLiBJDQpzZWUgdGhhdCB5b3UgZWRpdGVkIHRoaXMgbWVzc2FnZSBpbiB0aGUgcGFzdCBh
dCBsZWFzdCBjb3VwbGUgb2YgdGltZXMgKGUuZy4sDQpjN2NkZmYwZTg2NDcxIOKAnHZpcnRpb19i
YWxsb29uOiBmaXggZGVhZGxvY2sgb24gT09N4oCdKSBhbmQgbGVmdCBpdCBhcyBpcy4NCg0KU28g
bWF5YmUgYWxsIG9mIHRoZSBjb21tZW50cyBpbiB0aGlzIGZpbGUgbmVlZCBhIHJld29yaywgYnV0
IEkgZG9u4oCZdCB0aGluaw0KdGhpcyBwYXRjaC1zZXQgbmVlZHMgdG8gZG8gaXQuDQoNCj4+ICsg
Kg0KPj4gKyAqIFJldHVybjogbnVtYmVyIG9mIHBhZ2VzIHRoYXQgd2VyZSBlbnF1ZXVlZC4NCj4+
ICsgKi8NCj4+ICtzaXplX3QgYmFsbG9vbl9wYWdlX2xpc3RfZW5xdWV1ZShzdHJ1Y3QgYmFsbG9v
bl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+ICsJCQkgICAgICAgc3RydWN0IGxpc3RfaGVhZCAq
cGFnZXMpDQo+PiArew0KPj4gKwlzdHJ1Y3QgcGFnZSAqcGFnZSwgKnRtcDsNCj4+ICsJdW5zaWdu
ZWQgbG9uZyBmbGFnczsNCj4+ICsJc2l6ZV90IG5fcGFnZXMgPSAwOw0KPj4gKw0KPj4gKwlzcGlu
X2xvY2tfaXJxc2F2ZSgmYl9kZXZfaW5mby0+cGFnZXNfbG9jaywgZmxhZ3MpOw0KPj4gKwlsaXN0
X2Zvcl9lYWNoX2VudHJ5X3NhZmUocGFnZSwgdG1wLCBwYWdlcywgbHJ1KSB7DQo+PiArCQliYWxs
b29uX3BhZ2VfZW5xdWV1ZV9vbmUoYl9kZXZfaW5mbywgcGFnZSk7DQo+IA0KPiBEbyB3ZSB3YW50
IHRvIGRvIHNvbWV0aGluZyBhYm91dCBhbiBlcnJvciBoZXJlPw0KDQpIbW3igKYgVGhpcyBpcyBy
ZWFsbHkgc29tZXRoaW5nIHRoYXQgc2hvdWxkIG5ldmVyIGhhcHBlbiwgYnV0IEkgc3RpbGwgcHJl
ZmVyDQp0byBhdm9pZCBCVUdfT04oKSwgYXMgSSBzYWlkIGJlZm9yZS4gSSB3aWxsIGp1c3Qgbm90
IGNvdW50IHRoZSBwYWdlLg0KDQo+IA0KPj4gKwkJbl9wYWdlcysrOw0KPj4gKwl9DQo+PiArCXNw
aW5fdW5sb2NrX2lycXJlc3RvcmUoJmJfZGV2X2luZm8tPnBhZ2VzX2xvY2ssIGZsYWdzKTsNCj4+
ICsJcmV0dXJuIG5fcGFnZXM7DQo+PiArfQ0KPj4gK0VYUE9SVF9TWU1CT0xfR1BMKGJhbGxvb25f
cGFnZV9saXN0X2VucXVldWUpOw0KPj4gKw0KPj4gKy8qKg0KPj4gKyAqIGJhbGxvb25fcGFnZV9s
aXN0X2RlcXVldWUoKSAtIHJlbW92ZXMgcGFnZXMgZnJvbSBiYWxsb29uJ3MgcGFnZSBsaXN0IGFu
ZA0KPj4gKyAqCQkJCSByZXR1cm5zIGEgbGlzdCBvZiB0aGUgcGFnZXMuDQo+PiArICogQGJfZGV2
X2luZm86IGJhbGxvb24gZGV2aWNlIGRlY3JpcHRvciB3aGVyZSB3ZSB3aWxsIGdyYWIgYSBwYWdl
IGZyb20uDQo+PiArICogQHBhZ2VzOiBwb2ludGVyIHRvIHRoZSBsaXN0IG9mIHBhZ2VzIHRoYXQg
d291bGQgYmUgcmV0dXJuZWQgdG8gdGhlIGNhbGxlci4NCj4+ICsgKiBAbl9yZXFfcGFnZXM6IG51
bWJlciBvZiByZXF1ZXN0ZWQgcGFnZXMuDQo+PiArICoNCj4+ICsgKiBEcml2ZXIgbXVzdCBjYWxs
IGl0IHRvIHByb3Blcmx5IGRlLWFsbG9jYXRlIGEgcHJldmlvdXMgZW5saXN0ZWQgYmFsbG9vbiBw
YWdlcw0KPj4gKyAqIGJlZm9yZSBkZWZpbmV0aXZlbHkgcmVsZWFzaW5nIGl0IGJhY2sgdG8gdGhl
IGd1ZXN0IHN5c3RlbS4gVGhpcyBmdW5jdGlvbg0KPj4gKyAqIHRyaWVzIHRvIHJlbW92ZSBAbl9y
ZXFfcGFnZXMgZnJvbSB0aGUgYmFsbG9vbmVkIHBhZ2VzIGFuZCByZXR1cm4gaXQgdG8gdGhlDQo+
PiArICogY2FsbGVyIGluIHRoZSBAcGFnZXMgbGlzdC4NCj4+ICsgKg0KPj4gKyAqIE5vdGUgdGhh
dCB0aGlzIGZ1bmN0aW9uIG1heSBmYWlsIHRvIGRlcXVldWUgc29tZSBwYWdlcyB0ZW1wb3Jhcmls
eSBlbXB0eSBkdWUNCj4+ICsgKiB0byBjb21wYWN0aW9uIGlzb2xhdGVkIHBhZ2VzLg0KPj4gKyAq
DQo+PiArICogUmV0dXJuOiBudW1iZXIgb2YgcGFnZXMgdGhhdCB3ZXJlIGFkZGVkIHRvIHRoZSBA
cGFnZXMgbGlzdC4NCj4+ICsgKi8NCj4+ICtzaXplX3QgYmFsbG9vbl9wYWdlX2xpc3RfZGVxdWV1
ZShzdHJ1Y3QgYmFsbG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+ICsJCQkJIHN0cnVjdCBs
aXN0X2hlYWQgKnBhZ2VzLCBpbnQgbl9yZXFfcGFnZXMpDQo+PiArew0KPj4gKwlzdHJ1Y3QgcGFn
ZSAqcGFnZSwgKnRtcDsNCj4+ICsJdW5zaWduZWQgbG9uZyBmbGFnczsNCj4+ICsJc2l6ZV90IG5f
cGFnZXMgPSAwOw0KPj4gKw0KPj4gKwlzcGluX2xvY2tfaXJxc2F2ZSgmYl9kZXZfaW5mby0+cGFn
ZXNfbG9jaywgZmxhZ3MpOw0KPj4gKwlsaXN0X2Zvcl9lYWNoX2VudHJ5X3NhZmUocGFnZSwgdG1w
LCAmYl9kZXZfaW5mby0+cGFnZXMsIGxydSkgew0KPj4gKwkJLyoNCj4+ICsJCSAqIEJsb2NrIG90
aGVycyBmcm9tIGFjY2Vzc2luZyB0aGUgJ3BhZ2UnIHdoaWxlIHdlIGdldCBhcm91bmQNCj4+ICsJ
CSAqIGVzdGFibGlzaGluZyBhZGRpdGlvbmFsIHJlZmVyZW5jZXMgYW5kIHByZXBhcmluZyB0aGUg
J3BhZ2UnDQo+PiArCQkgKiB0byBiZSByZWxlYXNlZCBieSB0aGUgYmFsbG9vbiBkcml2ZXIuDQo+
PiArCQkgKi8NCj4+ICsJCWlmICghdHJ5bG9ja19wYWdlKHBhZ2UpKQ0KPj4gKwkJCWNvbnRpbnVl
Ow0KPj4gKw0KPj4gKwkJaWYgKElTX0VOQUJMRUQoQ09ORklHX0JBTExPT05fQ09NUEFDVElPTikg
JiYNCj4+ICsJCSAgICBQYWdlSXNvbGF0ZWQocGFnZSkpIHsNCj4+ICsJCQkvKiByYWNlZCB3aXRo
IGlzb2xhdGlvbiAqLw0KPj4gKwkJCXVubG9ja19wYWdlKHBhZ2UpOw0KPj4gKwkJCWNvbnRpbnVl
Ow0KPj4gKwkJfQ0KPj4gKwkJYmFsbG9vbl9wYWdlX2RlbGV0ZShwYWdlKTsNCj4+ICsJCV9fY291
bnRfdm1fZXZlbnQoQkFMTE9PTl9ERUZMQVRFKTsNCj4+ICsJCXVubG9ja19wYWdlKHBhZ2UpOw0K
Pj4gKwkJbGlzdF9hZGQoJnBhZ2UtPmxydSwgcGFnZXMpOw0KPj4gKwkJaWYgKCsrbl9wYWdlcyA+
PSBuX3JlcV9wYWdlcykNCj4+ICsJCQlicmVhazsNCj4+ICsJfQ0KPj4gKwlzcGluX3VubG9ja19p
cnFyZXN0b3JlKCZiX2Rldl9pbmZvLT5wYWdlc19sb2NrLCBmbGFncyk7DQo+PiArDQo+PiArCXJl
dHVybiBuX3BhZ2VzOw0KPj4gK30NCj4+ICtFWFBPUlRfU1lNQk9MX0dQTChiYWxsb29uX3BhZ2Vf
bGlzdF9kZXF1ZXVlKTsNCj4+ICsNCj4+IC8qDQo+PiAgKiBiYWxsb29uX3BhZ2VfYWxsb2MgLSBh
bGxvY2F0ZXMgYSBuZXcgcGFnZSBmb3IgaW5zZXJ0aW9uIGludG8gdGhlIGJhbGxvb24NCj4+ICAq
CQkJICBwYWdlIGxpc3QuDQo+PiBAQCAtNDMsMTcgKzE0Myw5IEBAIHZvaWQgYmFsbG9vbl9wYWdl
X2VucXVldWUoc3RydWN0IGJhbGxvb25fZGV2X2luZm8gKmJfZGV2X2luZm8sDQo+PiB7DQo+PiAJ
dW5zaWduZWQgbG9uZyBmbGFnczsNCj4+IA0KPj4gLQkvKg0KPj4gLQkgKiBCbG9jayBvdGhlcnMg
ZnJvbSBhY2Nlc3NpbmcgdGhlICdwYWdlJyB3aGVuIHdlIGdldCBhcm91bmQgdG8NCj4+IC0JICog
ZXN0YWJsaXNoaW5nIGFkZGl0aW9uYWwgcmVmZXJlbmNlcy4gV2Ugc2hvdWxkIGJlIHRoZSBvbmx5
IG9uZQ0KPj4gLQkgKiBob2xkaW5nIGEgcmVmZXJlbmNlIHRvIHRoZSAncGFnZScgYXQgdGhpcyBw
b2ludC4NCj4+IC0JICovDQo+PiAtCUJVR19PTighdHJ5bG9ja19wYWdlKHBhZ2UpKTsNCj4+IAlz
cGluX2xvY2tfaXJxc2F2ZSgmYl9kZXZfaW5mby0+cGFnZXNfbG9jaywgZmxhZ3MpOw0KPj4gLQli
YWxsb29uX3BhZ2VfaW5zZXJ0KGJfZGV2X2luZm8sIHBhZ2UpOw0KPj4gLQlfX2NvdW50X3ZtX2V2
ZW50KEJBTExPT05fSU5GTEFURSk7DQo+PiArCWJhbGxvb25fcGFnZV9lbnF1ZXVlX29uZShiX2Rl
dl9pbmZvLCBwYWdlKTsNCj4gDQo+IFdlIHVzZWQgdG8gYnVnIG9uIGZhaWx1cmUgdG8gbG9jayBw
YWdlLCBub3cgd2UNCj4gc2lsZW50bHkgaWdub3JlIHRoaXMgZXJyb3IuIFdoeT8NCg0KVGhhdOKA
mXMgYSBtaXN0YWtlLiBJ4oCZbGwgYWRkIGEgQlVHX09OKCkgaWYgYmFsbG9vbl9wYWdlX2VucXVl
dWVfb25lKCkgZmFpbHMuDQoNCg0K

