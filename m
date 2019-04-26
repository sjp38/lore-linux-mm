Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D330C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 20:29:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1D082077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 20:29:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="g6IwIPNY";
	dkim=pass (1024-bit key) header.d=sharedspace.onmicrosoft.com header.i=@sharedspace.onmicrosoft.com header.b="F9VWz34b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1D082077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9C16B0003; Fri, 26 Apr 2019 16:29:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6591B6B0005; Fri, 26 Apr 2019 16:29:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521446B0006; Fri, 26 Apr 2019 16:29:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 161896B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 16:29:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f64so2888395pfb.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 13:29:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:wdcipoutbound:content-id
         :content-transfer-encoding:mime-version;
        bh=HNM2W8SJG84FZ/v1RIln/6hNqIOXm6lImV3TLBaLJtU=;
        b=Ah7jX6LwKZp58gcL+qkxkp/gUKjE9HRuehYn1rfShJauKeAovyCTwS6T2hFAx8X7m/
         m4cV6VkvZLFZEm7vZgddu1uPl9m5iPlPZX2r6F0Q9s13rCBAgKpf7OKQelEIvXImVWD+
         aXAeEbW8COoOL/9/s1qcZZuMnMTw99HZiVxz8chfWKLiRo4HJPdh4kpXUWoisuME6+9A
         68h4bGFfsfY1B0mvhOFUli7WTJ49gQxUHXMYR9DfEEpE57Wg2nzC5thgcpQbALL+bFHo
         I4Vb24R0Td3Mj2i4r8XewAP3eI1GErTp3s96SS59NtBV53en7ya+Wasb9Q3A32X+E32g
         mtEw==
X-Gm-Message-State: APjAAAVpsgcfPmOuGQA+7Z7uxhVqjoLkOakYLqQzDDetaJf9//XtYkZp
	B8BDziuKTOj9KjZYAMm6ZD1ryf3N9tNIBNLzmAz5c4E+/j9YParvLxVJ7RU5V1wDiKtWj/IPo19
	OqVPreu8+dfqAk0c9PHluLpucY+QSTKAAf6WATRYrV0vJ8LSX5hFlgI47YpdPwD4H8g==
X-Received: by 2002:aa7:8ac8:: with SMTP id b8mr5209855pfd.234.1556310554601;
        Fri, 26 Apr 2019 13:29:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoLXV1nmB8rDAOh1pslK30zulpEN4q2e9dHkkayIRHSFrZ/K82BiCfYbufrAfMXJphLi8H
X-Received: by 2002:aa7:8ac8:: with SMTP id b8mr5209804pfd.234.1556310553635;
        Fri, 26 Apr 2019 13:29:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556310553; cv=none;
        d=google.com; s=arc-20160816;
        b=f+GKHAqnzC8ugidDT1OJPPaRWOmAAkuwO4VaryAp/R2vco4X2GNwAeFmI+/9EDrEpf
         XsfleDHjgFjnuHi1aTTAOhFYKquCy905UAtn+Szw6kDA4EJAc+Roe4WZTBbmjk4hCBR/
         GDoiEakYhuHDpR2N3AgfuFGTZHblNoIB2ua+qFmvX74GrNQi/cBLJlEsJcIdNTA8oMxC
         //QX+8ono9rUcFUi6zNgvwFUVki1Eq8BYNCr9GtDDTGubziV4E31v9BAtG7gwwiS2CZ2
         sBxdUgdNb9Xkd0twMimHdORhiL/D0LfafYMrNAXhFWhrHLxHbygs+LzIn9A0L8k2zdrJ
         Y5dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:wdcipoutbound
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=HNM2W8SJG84FZ/v1RIln/6hNqIOXm6lImV3TLBaLJtU=;
        b=s1l8V7hGSV56BDLBFfrH26N3THGX34lV2htxX9NjikquoN7VyEnwiAqUk0+fByzz44
         3gUH4OoCupLN+cH6wMMFSkRobXlzH7ntktKzmTcW6gid3XGpZzTM6ehN2QMRX/5JtsOe
         GutbPhyxHXiK05REPYxavh6zLLVHosPyXyc6eSjMZZvo42mGpoqYRRkHMWziaMvjjKol
         rBy7ifpKC51mQQdjmobBqry/ve6PE0LekziLitFFNwA/oM2yAttaZolC1GWji68nEZRy
         0HeUKHOvWz9mf5wXo/yRikO78+Xg4wMo7KgRn+nVAcWvesQaAFOFo2veV31lnja9NCe+
         L3IA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=g6IwIPNY;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=F9VWz34b;
       spf=pass (google.com: domain of prvs=01278abb0=adam.manzanares@wdc.com designates 68.232.143.124 as permitted sender) smtp.mailfrom="prvs=01278abb0=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id bi3si20592634plb.427.2019.04.26.13.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 13:29:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=01278abb0=adam.manzanares@wdc.com designates 68.232.143.124 as permitted sender) client-ip=68.232.143.124;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=g6IwIPNY;
       dkim=pass header.i=@sharedspace.onmicrosoft.com header.s=selector1-wdc-com header.b=F9VWz34b;
       spf=pass (google.com: domain of prvs=01278abb0=adam.manzanares@wdc.com designates 68.232.143.124 as permitted sender) smtp.mailfrom="prvs=01278abb0=Adam.Manzanares@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556310587; x=1587846587;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:content-transfer-encoding:
   mime-version;
  bh=HNM2W8SJG84FZ/v1RIln/6hNqIOXm6lImV3TLBaLJtU=;
  b=g6IwIPNYUopu051DRbfuGSgKEaYH93rLfq8hPkvNaytgLyz72u/6gKkt
   mUyovxrv+xecapwMwKTAhslfmcmrC9el3E2VuY3MDCmyzs+OD1hlUU2+s
   AxgM2R2pRGwlo7kDN5FC/TfHvgwBoTjt/qS4xtQBEw1b912mAzfOv7/c/
   EeSQ8rmBi3Ip8kbyT/pmrCIgZuCcX7+jRuZIOxdRRZMwHOxs1UkYPAD/Y
   frLNBkT9IluUmC0ConaVGAwdcBmlBi/+HIuzOPbzZ4xU5XixMG4cUZvS1
   IBoHNQa979AarjpFeFjil9W1fk/o1MVA871DjF25XJ0Acw36G4+InqK+R
   A==;
X-IronPort-AV: E=Sophos;i="5.60,398,1549900800"; 
   d="scan'208";a="206100344"
Received: from mail-bn3nam01lp2051.outbound.protection.outlook.com (HELO NAM01-BN3-obe.outbound.protection.outlook.com) ([104.47.33.51])
  by ob1.hgst.iphmx.com with ESMTP; 27 Apr 2019 04:28:49 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=sharedspace.onmicrosoft.com; s=selector1-wdc-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HNM2W8SJG84FZ/v1RIln/6hNqIOXm6lImV3TLBaLJtU=;
 b=F9VWz34bjrYyWfTfbuKJSP5bNAHHxw7Glmq88bK9EM8awQmxscNgmCcdkDbBu0V9DNuxhYYLhuvCG4F1GQId0NsktSEERvRf4nFg8lVvmTiltf/gyTXB44RuyVsspgjzZGwb1ogezZ4UMfFthIV0Vt/WWAqtgSe6seKdY1lg/ws=
Received: from BYAPR04MB4357.namprd04.prod.outlook.com (20.176.251.147) by
 BYAPR04MB3832.namprd04.prod.outlook.com (52.135.214.27) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.13; Fri, 26 Apr 2019 20:28:33 +0000
Received: from BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::cd90:ee8f:e618:321a]) by BYAPR04MB4357.namprd04.prod.outlook.com
 ([fe80::cd90:ee8f:e618:321a%2]) with mapi id 15.20.1813.017; Fri, 26 Apr 2019
 20:28:33 +0000
From: Adam Manzanares <Adam.Manzanares@wdc.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org"
	<linux-block@vger.kernel.org>
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Thread-Topic: [LSF/MM TOPIC] Direct block mapping through fs for device
Thread-Index: AQHU+/FIGwzRMarUD0ilz403o/BcAKZO5VgA
Date: Fri, 26 Apr 2019 20:28:32 +0000
Message-ID: <b24c6f711d2e23792d6577a4ca508d75b0af4d9e.camel@wdc.com>
References: <20190426013814.GB3350@redhat.com>
In-Reply-To: <20190426013814.GB3350@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Adam.Manzanares@wdc.com; 
x-originating-ip: [199.255.44.173]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 6dd75ba4-1034-4521-affd-08d6ca85c0b4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR04MB3832;
x-ms-traffictypediagnostic: BYAPR04MB3832:
wdcipoutbound: EOP-TRUE
x-microsoft-antispam-prvs:
 <BYAPR04MB38329BBB705EBF474D519FA3F03E0@BYAPR04MB3832.namprd04.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 001968DD50
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(396003)(39860400002)(346002)(199004)(189003)(305945005)(53936002)(7736002)(6246003)(25786009)(8676002)(6512007)(86362001)(229853002)(6486002)(5660300002)(256004)(66574012)(6436002)(14444005)(97736004)(4326008)(71200400001)(71190400001)(3846002)(6116002)(2616005)(486006)(6506007)(11346002)(446003)(76176011)(14454004)(2906002)(26005)(478600001)(66066001)(72206003)(186003)(102836004)(8936002)(110136005)(316002)(118296001)(99286004)(66476007)(66446008)(64756008)(66556008)(66946007)(73956011)(76116006)(2501003)(36756003)(81156014)(81166006)(68736007)(54906003)(476003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR04MB3832;H:BYAPR04MB4357.namprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 v1USip/7YhZGyUnK5YJYPZzLdd+uGKr87nJYDDuBpW5XIVvV019SNMoP3CZKsW7JdqcuuSVc9ddT/VN1e5bSbTnPNroVXNDocePbclV8auJlASYOdckZY/5OXICOk15HlLSsGiP9FonQ4N0HqnkYxl/6DpgCoVkYoGy6Ti8YxqnJ9nto2q1Auywzxv9S1mH1+o9hobiA1R1qw/C+v1UldZxlbh1cqyzt3t5M602lxVv9O26ZfxGAuBwdoDc6oTa7aKhVUVtI1p3hWvXfH95t7XoAALtoNioI6PxPY4lcOgN/KpIf3iPfRUbHOaiQGYxVXrtVKa6JeZs/Pwk+4yyJroOreEhb24RhYlRPY7T9cfpZEaDSCfeihAQ5YEocqpWdm6gb4SICwJUc20N9Gt1Ckr60SqWbxJFhdTfAqfdr+AI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F7617180EA7B7940928F12F11051F43A@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: wdc.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6dd75ba4-1034-4521-affd-08d6ca85c0b4
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Apr 2019 20:28:33.0040
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b61c8803-16f3-4c35-9b17-6f65f441df86
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR04MB3832
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA0LTI1IGF0IDIxOjM4IC0wNDAwLCBKZXJvbWUgR2xpc3NlIHdyb3RlOg0K
PiBJIHNlZSB0aGF0IHRoZXkgYXJlIHN0aWxsIGVtcHR5IHNwb3QgaW4gTFNGL01NIHNjaGVkdWxl
IHNvIGkgd291bGQNCj4gbGlrZSB0bw0KPiBoYXZlIGEgZGlzY3Vzc2lvbiBvbiBhbGxvd2luZyBk
aXJlY3QgYmxvY2sgbWFwcGluZyBvZiBmaWxlIGZvcg0KPiBkZXZpY2VzIChuaWMsDQo+IGdwdSwg
ZnBnYSwgLi4uKS4gVGhpcyBpcyBtbSwgZnMgYW5kIGJsb2NrIGRpc2N1c3Npb24sIHRob3VnaHQg
dGhlIG1tDQo+IHNpZGUNCj4gaXMgcHJldHR5IGxpZ2h0IGllIG9ubHkgYWRkaW5nIDIgY2FsbGJh
Y2sgdG8gdm1fb3BlcmF0aW9uc19zdHJ1Y3Q6DQo+IA0KPiAgICAgaW50ICgqZGV2aWNlX21hcCko
c3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsDQo+ICAgICAgICAgICAgICAgICAgICAgICBzdHJ1
Y3QgZGV2aWNlICppbXBvcnRlciwNCj4gICAgICAgICAgICAgICAgICAgICAgIHN0cnVjdCBkbWFf
YnVmICoqYnVmcCwNCj4gICAgICAgICAgICAgICAgICAgICAgIHVuc2lnbmVkIGxvbmcgc3RhcnQs
DQo+ICAgICAgICAgICAgICAgICAgICAgICB1bnNpZ25lZCBsb25nIGVuZCwNCj4gICAgICAgICAg
ICAgICAgICAgICAgIHVuc2lnbmVkIGZsYWdzLA0KPiAgICAgICAgICAgICAgICAgICAgICAgZG1h
X2FkZHJfdCAqcGEpOw0KPiANCj4gICAgIC8vIFNvbWUgZmxhZ3MgaSBjYW4gdGhpbmsgb2Y6DQo+
ICAgICBERVZJQ0VfTUFQX0ZMQUdfUElOIC8vIGllIHJldHVybiBhIGRtYV9idWYgb2JqZWN0DQo+
ICAgICBERVZJQ0VfTUFQX0ZMQUdfV1JJVEUgLy8gaW1wb3J0ZXIgd2FudCB0byBiZSBhYmxlIHRv
IHdyaXRlDQo+ICAgICBERVZJQ0VfTUFQX0ZMQUdfU1VQUE9SVF9BVE9NSUNfT1AgLy8gaW1wb3J0
ZXIgd2FudCB0byBkbyBhdG9taWMNCj4gb3BlcmF0aW9uDQo+ICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgLy8gb24gdGhlIG1hcHBpbmcNCj4gDQo+ICAgICB2b2lkICgqZGV2
aWNlX3VubWFwKShzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSwNCj4gICAgICAgICAgICAgICAg
ICAgICAgICAgIHN0cnVjdCBkZXZpY2UgKmltcG9ydGVyLA0KPiAgICAgICAgICAgICAgICAgICAg
ICAgICAgdW5zaWduZWQgbG9uZyBzdGFydCwNCj4gICAgICAgICAgICAgICAgICAgICAgICAgIHVu
c2lnbmVkIGxvbmcgZW5kLA0KPiAgICAgICAgICAgICAgICAgICAgICAgICAgZG1hX2FkZHJfdCAq
cGEpOw0KPiANCj4gRWFjaCBmaWxlc3lzdGVtIGNvdWxkIGFkZCB0aGlzIGNhbGxiYWNrIGFuZCBk
ZWNpZGUgd2V0aGVyIG9yIG5vdCB0bw0KPiBhbGxvdw0KPiB0aGUgaW1wb3J0ZXIgdG8gZGlyZWN0
bHkgbWFwIGJsb2NrLiBGaWxlc3lzdGVtIGNhbiB1c2Ugd2hhdCBldmVyDQo+IGxvZ2ljIHRoZXkN
Cj4gd2FudCB0byBtYWtlIHRoYXQgZGVjaXNpb24uIEZvciBpbnN0YW5jZSBpZiB0aGV5IGFyZSBw
YWdlIGluIHRoZSBwYWdlDQo+IGNhY2hlDQo+IGZvciB0aGUgcmFuZ2UgdGhlbiBpdCBjYW4gc2F5
IG5vIGFuZCB0aGUgZGV2aWNlIHdvdWxkIGZhbGxiYWNrIHRvDQo+IG1haW4NCj4gbWVtb3J5LiBG
aWxlc3lzdGVtIGNhbiBhbHNvIHVwZGF0ZSBpdHMgaW50ZXJuYWwgZGF0YSBzdHJ1Y3R1cmUgdG8N
Cj4ga2VlcA0KPiB0cmFjayBvZiBkaXJlY3QgYmxvY2sgbWFwcGluZy4NCj4gDQo+IElmIGZpbGVz
eXN0ZW0gZGVjaWRlIHRvIGFsbG93IHRoZSBkaXJlY3QgYmxvY2sgbWFwcGluZyB0aGVuIGl0DQo+
IGZvcndhcmQgdGhlDQo+IHJlcXVlc3QgdG8gdGhlIGJsb2NrIGRldmljZSB3aGljaCBpdHNlbGYg
Y2FuIGRlY2lkZSB0byBmb3JiaWQgdGhlDQo+IGRpcmVjdA0KPiBtYXBwaW5nIGFnYWluIGZvciBh
bnkgcmVhc29ucy4gRm9yIGluc3RhbmNlIHJ1bm5pbmcgb3V0IG9mIEJBUiBzcGFjZQ0KPiBvcg0K
PiBwZWVyIHRvIHBlZXIgYmV0d2VlbiBibG9jayBkZXZpY2UgYW5kIGltcG9ydGVyIGRldmljZSBp
cyBub3QNCj4gc3VwcG9ydGVkIG9yDQo+IGJsb2NrIGRldmljZSBkb2VzIG5vdCB3YW50IHRvIGFs
bG93IHdyaXRlYWJsZSBwZWVyIG1hcHBpbmcgLi4uDQo+IA0KPiANCj4gU28gZXZlbnQgZmxvdyBp
czoNCj4gICAgIDEgIHByb2dyYW0gbW1hcCBhIGZpbGUgKGVuZCBuZXZlciBpbnRlbmQgdG8gYWNj
ZXNzIGl0IHdpdGggQ1BVKQ0KPiAgICAgMiAgcHJvZ3JhbSB0cnkgdG8gYWNjZXNzIHRoZSBtbWFw
IGZyb20gYSBkZXZpY2UgQQ0KPiAgICAgMyAgZGV2aWNlIEEgZHJpdmVyIHNlZSBkZXZpY2VfbWFw
IGNhbGxiYWNrIG9uIHRoZSB2bWEgYW5kIGNhbGwgaXQNCj4gICAgIDRhIG9uIHN1Y2Nlc3MgZGV2
aWNlIEEgZHJpdmVyIHByb2dyYW0gdGhlIGRldmljZSB0byBtYXBwZWQgZG1hDQo+IGFkZHJlc3MN
Cj4gICAgIDRiIG9uIGZhaWx1cmUgZGV2aWNlIEEgZHJpdmVyIGZhbGxiYWNrIHRvIGZhdWx0aW5n
IHNvIHRoYXQgaXQgY2FuDQo+IHVzZQ0KPiAgICAgICAgcGFnZSBmcm9tIHBhZ2UgY2FjaGUNCj4g
DQo+IFRoaXMgQVBJIGFzc3VtZSB0aGF0IHRoZSBpbXBvcnRlciBkb2VzIHN1cHBvcnQgbW11IG5v
dGlmaWVyIGFuZCB0aHVzDQo+IHRoYXQNCj4gdGhlIGZzIGNhbiBpbnZhbGlkYXRlIGRldmljZSBt
YXBwaW5nIGF0IF9hbnlfIHRpbWUgYnkgc2VuZGluZyBtbXUNCj4gbm90aWZpZXINCj4gdG8gYWxs
IG1hcHBpbmcgb2YgdGhlIGZpbGUgKGZvciBhIGdpdmVuIHJhbmdlIGluIHRoZSBmaWxlIG9yIGZv
ciB0aGUNCj4gd2hvbGUNCj4gZmlsZSkuIE9idmlvdXNseSB5b3Ugd2FudCB0byBtaW5pbWl6ZSBk
aXNydXB0aW9uIGFuZCB0aHVzIG9ubHkNCj4gaW52YWxpZGF0ZQ0KPiB3aGVuIG5lY2Vzc2FyeS4N
Cj4gDQo+IFRoZSBkbWFfYnVmIHBhcmFtZXRlciBjYW4gYmUgdXNlIHRvIGFkZCBwaW5uaW5nIHN1
cHBvcnQgZm9yDQo+IGZpbGVzeXN0ZW0gd2hvDQo+IHdpc2ggdG8gc3VwcG9ydCB0aGF0IGNhc2Ug
dG9vLiBIZXJlIHRoZSBtYXBwaW5nIGxpZmV0aW1lIGdldA0KPiBkaXNjb25uZWN0ZWQNCj4gZnJv
bSB0aGUgdm1hIGFuZCBpcyB0cmFuc2ZlciB0byB0aGUgZG1hX2J1ZiBhbGxvY2F0ZWQgYnkgZmls
ZXN5c3RlbS4NCj4gQWdhaW4NCj4gZmlsZXN5c3RlbSBjYW4gZGVjaWRlIHRvIHNheSBubyBhcyBw
aW5uaW5nIGJsb2NrcyBoYXMgZHJhc3RpYw0KPiBjb25zZXF1ZW5jZQ0KPiBmb3IgZmlsZXN5c3Rl
bSBhbmQgYmxvY2sgZGV2aWNlLg0KPiANCj4gDQo+IFRoaXMgaGFzIHNvbWUgc2ltaWxhcml0aWVz
IHRvIHRoZSBobW1hcCBhbmQgY2FjaGluZyB0b3BpYyAod2hpY2ggaXMNCj4gbWFwcGluZw0KPiBi
bG9jayBkaXJlY3RseSB0byBDUFUgQUZBSVUpIGJ1dCBkZXZpY2UgbWFwcGluZyBjYW4gY3V0IHNv
bWUgY29ybmVyDQo+IGZvcg0KPiBpbnN0YW5jZSBzb21lIGRldmljZSBjYW4gZm9yZ28gYXRvbWlj
IG9wZXJhdGlvbiBvbiBzdWNoIG1hcHBpbmcgYW5kDQo+IHRodXMNCj4gY2FuIHdvcmsgb3ZlciBQ
Q0lFIHdoaWxlIENQVSBjYW4gbm90IGRvIGF0b21pYyB0byBQQ0lFIEJBUi4NCj4gDQo+IEFsc28g
dGhpcyBBUEkgaGVyZSBjYW4gYmUgdXNlIHRvIGFsbG93IHBlZXIgdG8gcGVlciBhY2Nlc3MgYmV0
d2Vlbg0KPiBkZXZpY2VzDQo+IHdoZW4gdGhlIHZtYSBpcyBhIG1tYXAgb2YgYSBkZXZpY2UgZmls
ZSBhbmQgdGh1cyB2bV9vcGVyYXRpb25zX3N0cnVjdA0KPiBjb21lDQo+IGZyb20gc29tZSBleHBv
cnRlciBkZXZpY2UgZHJpdmVyLiBTbyBzYW1lIDIgdm1fb3BlcmF0aW9uc19zdHJ1Y3QgY2FsbA0K
PiBiYWNrDQo+IGNhbiBiZSB1c2UgaW4gbW9yZSBjYXNlcyB0aGFuIHdoYXQgaSBqdXN0IGRlc2Ny
aWJlZCBoZXJlLg0KPiANCj4gDQo+IFNvIGkgd291bGQgbGlrZSB0byBnYXRoZXIgcGVvcGxlIGZl
ZWRiYWNrIG9uIGdlbmVyYWwgYXBwcm9hY2ggYW5kIGZldw0KPiB0aGluZ3MNCj4gbGlrZToNCj4g
ICAgIC0gRG8gYmxvY2sgZGV2aWNlIG5lZWQgdG8gYmUgYWJsZSB0byBpbnZhbGlkYXRlIHN1Y2gg
bWFwcGluZyB0b28NCj4gPw0KPiANCj4gICAgICAgSXQgaXMgZWFzeSBmb3IgZnMgdGhlIHRvIGlu
dmFsaWRhdGUgYXMgaXQgY2FuIHdhbGsgZmlsZQ0KPiBtYXBwaW5ncw0KPiAgICAgICBidXQgYmxv
Y2sgZGV2aWNlIGRvIG5vdCBrbm93IGFib3V0IGZpbGUuDQo+IA0KPiAgICAgLSBEbyB3ZSB3YW50
IHRvIHByb3ZpZGUgc29tZSBnZW5lcmljIGltcGxlbWVudGF0aW9uIHRvIHNoYXJlDQo+IGFjY3Jv
c3MNCj4gICAgICAgZnMgPw0KPiANCj4gICAgIC0gTWF5YmUgc29tZSBzaGFyZSBoZWxwZXJzIGZv
ciBibG9jayBkZXZpY2VzIHRoYXQgY291bGQgdHJhY2sNCj4gZmlsZQ0KPiAgICAgICBjb3JyZXNw
b25kaW5nIHRvIHBlZXIgbWFwcGluZyA/DQoNCkknbSBpbnRlcmVzdGVkIGluIGJlaW5nIGEgcGFy
dCBvZiB0aGlzIGRpc2N1c3Npb24uDQoNCj4gDQo+IA0KPiBDaGVlcnMsDQo+IErDqXLDtG1lDQo=

