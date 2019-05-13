Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1EF2C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:26:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86608208C3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:26:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86608208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1536B000D; Mon, 13 May 2019 18:26:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 083186B000E; Mon, 13 May 2019 18:26:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8AF86B0266; Mon, 13 May 2019 18:26:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B03126B000D
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:26:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so4112086plb.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 15:26:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=hPNtgjETyicYnU0GDPaMUO/Z09dYodfqqFAzhcuzKpo=;
        b=e7+2zZAm5pMpp91/OZobJvRWltoqeef9Tfk7tVe9y+10WykkxoWbyx5eSStIavq3i8
         PvtIaCQu3bFq8vmvRPc5agET3YynCZLDS3B+SfQgJyBJNKCb8pS+IHoQMeW7fKY56Kf6
         tCTc2XvbQBrV1N5lnWSgYTAaoMOlsR6uw4grqYqHVpC9L/IysX9CMFUOwtuW2aA5W7BQ
         sAAfCVMGZG6N1uqmpgfxsyjGhSdLsNG6wBHZNz5YGxyyX28MDSMEMZEAXzXOfqDrNQg+
         asV0mg/g08WfigkYEBNoZ3NxeIsDDz/peYVzQy9cqy6vOct7rN6H36RYnA5w1zS3oJuj
         /jcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
X-Gm-Message-State: APjAAAXIKDgmwV+Pzpz6dXNpmaY8jInG0zmwCZDAdJNd5tDyzC2pkFyo
	0QrRvil37+uvw3h4Hz2Bc94fyS+rILkEPtaHp18Hb8kni1RBEuUfsCpQzh4GiCyo+qp9kQfBeY6
	IuDgsD/Kvd9JyTSWWKxp+pddJcx+qMefXv9p0lgOlV2DYKJ5Ck3ahzw0d5bwAgOKJcg==
X-Received: by 2002:a17:902:6b8b:: with SMTP id p11mr33450084plk.225.1557786399358;
        Mon, 13 May 2019 15:26:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/3rEIbXn/TeBhXcJ72/RGt9x2wO+J/wKZcbKQ4+9D2+xj6WXLm7mAnxxniQMrDPfwRjd9
X-Received: by 2002:a17:902:6b8b:: with SMTP id p11mr33450023plk.225.1557786398320;
        Mon, 13 May 2019 15:26:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557786398; cv=none;
        d=google.com; s=arc-20160816;
        b=IbTJJ/WSQvgmmE2jA6NriWL7ArdR9t3SF8YaUKPGOCX7ubHkOJ5AQhTtTuxNL0SizT
         CRO9jlvPXP752SZ/x9KhUJ9S2Bk9PebTqBqv23ad1FumX/V0qedj2+dJ6CzLbk/pHYtJ
         3q4J7ZHeEAbJj7VETrjX7vwcuZYIs1krrBcUTbELzpwXhTXZJuuqkycpitBuL29WwkSZ
         eNpu/KYqwMSOhWVSXcAuMXDYA2ATXJQZRAidNZGa0o8lTaAHfggO9pm1h1TNygc+c+YO
         mpLA1O+JvqHxzEjw9f+VDznDYR1dyPHOWIXX9ZW10RptojLkKJhkPyys+RECSAL+eDcR
         BTAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=hPNtgjETyicYnU0GDPaMUO/Z09dYodfqqFAzhcuzKpo=;
        b=tc7bLnyXSGjyDySw13FjJIJLZWK6u7fS6VrZyB6sJO/Ymv/hrrqAlALwTutqg7sOSv
         kd9FNx2uZgnMOrbc4Y8OWGDEyluml81/E1mTtK9bLp8/incxe5oqjd8uerOs573OOOpT
         L7m9956KboUGqZzqfj5lWaKfDb3okFTsA+1kky/9K7iZJvRLiTCdy8c8s3SRfKwjfJL/
         POxnWjOk4Qw1L8fvb72Me/cgIMiXqHKJi8eQT09ky5Xha4G0fyZjg9ZvixMfjrrkcLLk
         e9Gc500TORr3qijBrNGudTD30ZXm4AjZQy2XWrMSxTGeq5tfSXjKf2gybl9MNO25iSkD
         l9+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
Received: from mx0a-002e3701.pphosted.com (mx0a-002e3701.pphosted.com. [148.163.147.86])
        by mx.google.com with ESMTPS id c72si19259447pfb.93.2019.05.13.15.26.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 15:26:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of toshi.kani@hpe.com designates 148.163.147.86 as permitted sender) client-ip=148.163.147.86;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of toshi.kani@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=toshi.kani@hpe.com
Received: from pps.filterd (m0148663.ppops.net [127.0.0.1])
	by mx0a-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4DMQXXT004060;
	Mon, 13 May 2019 22:26:33 GMT
Received: from g2t2354.austin.hpe.com (g2t2354.austin.hpe.com [15.233.44.27])
	by mx0a-002e3701.pphosted.com with ESMTP id 2sfcw79wxf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 13 May 2019 22:26:33 +0000
Received: from G1W8106.americas.hpqcorp.net (g1w8106.austin.hp.com [16.193.72.61])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t2354.austin.hpe.com (Postfix) with ESMTPS id 50CFC81;
	Mon, 13 May 2019 22:26:32 +0000 (UTC)
Received: from G9W8676.americas.hpqcorp.net (16.220.49.23) by
 G1W8106.americas.hpqcorp.net (16.193.72.61) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Mon, 13 May 2019 22:26:31 +0000
Received: from G9W9209.americas.hpqcorp.net (2002:10dc:429c::10dc:429c) by
 G9W8676.americas.hpqcorp.net (2002:10dc:3117::10dc:3117) with Microsoft SMTP
 Server (TLS) id 15.0.1367.3; Mon, 13 May 2019 22:26:30 +0000
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (15.241.52.13) by
 G9W9209.americas.hpqcorp.net (16.220.66.156) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3 via Frontend Transport; Mon, 13 May 2019 22:26:31 +0000
Received: from DF4PR8401MB0601.NAMPRD84.PROD.OUTLOOK.COM (10.169.84.9) by
 DF4PR8401MB1193.NAMPRD84.PROD.OUTLOOK.COM (10.169.92.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.25; Mon, 13 May 2019 22:26:30 +0000
Received: from DF4PR8401MB0601.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::f0d9:104c:cc02:ecc9]) by DF4PR8401MB0601.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::f0d9:104c:cc02:ecc9%10]) with mapi id 15.20.1878.024; Mon, 13 May
 2019 22:26:30 +0000
From: "Kani, Toshi" <toshi.kani@hpe.com>
To: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>
CC: "tglx@linutronix.de" <tglx@linutronix.de>,
        "cpandya@codeaurora.org"
	<cpandya@codeaurora.org>,
        "catalin.marinas@arm.com"
	<catalin.marinas@arm.com>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>
Subject: Re: [PATCH V3 1/2] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Thread-Topic: [PATCH V3 1/2] mm/ioremap: Check virtual address alignment while
 creating huge mappings
Thread-Index: AQHVBiJHPf8OzupKLkK42fmk5iIjc6ZpqIUA
Date: Mon, 13 May 2019 22:26:30 +0000
Message-ID: <f56ab0da9e9f20a7c4c019e629052d0e1aa2ffff.camel@hpe.com>
References: <1557377177-20695-1-git-send-email-anshuman.khandual@arm.com>
	 <1557377177-20695-2-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1557377177-20695-2-git-send-email-anshuman.khandual@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [15.219.163.3]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d0b0cfad-6be8-44bb-5595-08d6d7f20c00
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:DF4PR8401MB1193;
x-ms-traffictypediagnostic: DF4PR8401MB1193:
x-microsoft-antispam-prvs: <DF4PR8401MB1193A8B052B371F32F125877820F0@DF4PR8401MB1193.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0036736630
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(136003)(366004)(346002)(39860400002)(199004)(189003)(36756003)(6116002)(186003)(305945005)(7736002)(2906002)(5660300002)(6506007)(102836004)(26005)(66066001)(8676002)(14454004)(110136005)(118296001)(8936002)(81156014)(81166006)(54906003)(86362001)(71200400001)(476003)(446003)(11346002)(316002)(486006)(71190400001)(76116006)(2616005)(2201001)(25786009)(66556008)(64756008)(66446008)(6246003)(229853002)(66476007)(73956011)(66946007)(256004)(68736007)(2501003)(4326008)(6512007)(3846002)(99286004)(478600001)(53936002)(76176011)(6436002)(6486002)(14583001);DIR:OUT;SFP:1102;SCL:1;SRVR:DF4PR8401MB1193;H:DF4PR8401MB0601.NAMPRD84.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hpe.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: U94EnbKDpOInV46Uq62YHYSwJcAX4jRX/AYXTzXyz15yPLdvmW5hC146a01gh4VtrljNs6gzLSijHxPyL1aUNrWYI55hslDvqFxswkEW7f0EkhutGRYJ23aS5raJoboDHSYyCtmA3HXfW1y0MnQ38imxlIS8g+lEt4rjW6RBPvql4ndYu95LlFXy6lxdIFUafrWN8qe1+jJH0E02rp6R3F1WRhc964EE9hgJg1pb4iZEYY4Nmg/Aty0cdI0HNTvybmqa1qbJZcnfMmTHMQ0wlU7r17KXHXfH9x3Abie1KVISeR5gmoWbOVFDKvDMaPu8a4NqG2J/ZUEHww/hW/QIKraO62F7ywZyak5H3wiPnNvC5hNeUq1ONBQrA8uZesEWgFd6kJ3yXmRj30+96H6PyfNkQHUq8h+kIoPsQ0IsUQw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <35470E155100F04188EE8F12E1958374@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d0b0cfad-6be8-44bb-5595-08d6d7f20c00
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 May 2019 22:26:30.1838
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DF4PR8401MB1193
X-OriginatorOrg: hpe.com
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-13_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905130150
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA1LTA5IGF0IDEwOjE2ICswNTMwLCBBbnNodW1hbiBLaGFuZHVhbCB3cm90
ZToNCj4gVmlydHVhbCBhZGRyZXNzIGFsaWdubWVudCBpcyBlc3NlbnRpYWwgaW4gZW5zdXJpbmcg
Y29ycmVjdCBjbGVhcmluZyBmb3IgYWxsDQo+IGludGVybWVkaWF0ZSBsZXZlbCBwZ3RhYmxlIGVu
dHJpZXMgYW5kIGZyZWVpbmcgYXNzb2NpYXRlZCBwZ3RhYmxlIHBhZ2VzLiBBbg0KPiB1bmFsaWdu
ZWQgYWRkcmVzcyBjYW4gZW5kIHVwIHJhbmRvbWx5IGZyZWVpbmcgcGd0YWJsZSBwYWdlIHRoYXQg
cG90ZW50aWFsbHkNCj4gc3RpbGwgY29udGFpbnMgdmFsaWQgbWFwcGluZ3MuIEhlbmNlIGFsc28g
Y2hlY2sgaXQncyBhbGlnbm1lbnQgYWxvbmcgd2l0aA0KPiBleGlzdGluZyBwaHlzX2FkZHIgY2hl
Y2suDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBBbnNodW1hbiBLaGFuZHVhbCA8YW5zaHVtYW4ua2hh
bmR1YWxAYXJtLmNvbT4NCj4gQ2M6IFRvc2hpIEthbmkgPHRvc2hpLmthbmlAaHBlLmNvbT4NCj4g
Q2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+IENjOiBXaWxs
IERlYWNvbiA8d2lsbC5kZWFjb25AYXJtLmNvbT4NCj4gQ2M6IENoaW50YW4gUGFuZHlhIDxjcGFu
ZHlhQGNvZGVhdXJvcmEub3JnPg0KPiBDYzogVGhvbWFzIEdsZWl4bmVyIDx0Z2x4QGxpbnV0cm9u
aXguZGU+DQo+IENjOiBDYXRhbGluIE1hcmluYXMgPGNhdGFsaW4ubWFyaW5hc0Bhcm0uY29tPg0K
PiAtLS0NCj4gIGxpYi9pb3JlbWFwLmMgfCA2ICsrKysrKw0KPiAgMSBmaWxlIGNoYW5nZWQsIDYg
aW5zZXJ0aW9ucygrKQ0KPiANCj4gZGlmZiAtLWdpdCBhL2xpYi9pb3JlbWFwLmMgYi9saWIvaW9y
ZW1hcC5jDQo+IGluZGV4IDA2MzIxMzY4NTU2My4uOGI1YzhkZGE4NTdkIDEwMDY0NA0KPiAtLS0g
YS9saWIvaW9yZW1hcC5jDQo+ICsrKyBiL2xpYi9pb3JlbWFwLmMNCj4gQEAgLTg2LDYgKzg2LDkg
QEAgc3RhdGljIGludCBpb3JlbWFwX3RyeV9odWdlX3BtZChwbWRfdCAqcG1kLCB1bnNpZ25lZCBs
b25nIGFkZHIsDQo+ICAJaWYgKChlbmQgLSBhZGRyKSAhPSBQTURfU0laRSkNCj4gIAkJcmV0dXJu
IDA7DQo+ICANCj4gKwlpZiAoIUlTX0FMSUdORUQoYWRkciwgUE1EX1NJWkUpKQ0KPiArCQlyZXR1
cm4gMDsNCj4gKw0KPiAgCWlmICghSVNfQUxJR05FRChwaHlzX2FkZHIsIFBNRF9TSVpFKSkNCj4g
IAkJcmV0dXJuIDA7DQo+ICANCj4gQEAgLTEyNiw2ICsxMjksOSBAQCBzdGF0aWMgaW50IGlvcmVt
YXBfdHJ5X2h1Z2VfcHVkKHB1ZF90ICpwdWQsIHVuc2lnbmVkIGxvbmcgYWRkciwNCj4gIAlpZiAo
KGVuZCAtIGFkZHIpICE9IFBVRF9TSVpFKQ0KPiAgCQlyZXR1cm4gMDsNCj4gIA0KPiArCWlmICgh
SVNfQUxJR05FRChhZGRyLCBQVURfU0laRSkpDQo+ICsJCXJldHVybiAwOw0KPiArDQo+ICAJaWYg
KCFJU19BTElHTkVEKHBoeXNfYWRkciwgUFVEX1NJWkUpKQ0KPiAgCQlyZXR1cm4gMDsNCg0KTm90
IHN1cmUgaWYgd2UgaGF2ZSBzdWNoIGNhc2UgdG9kYXksIGJ1dCBJIGFncmVlIHRoYXQgaXQgaXMg
cHJ1ZGVudCB0bw0KaGF2ZSBzdWNoIGNoZWNrcy4gIElzIHRoZXJlIGFueSByZWFzb24gbm90IHRv
IGFkZCB0aGlzIGNoZWNrIHRvIHA0ZCBmb3INCmNvbnNpc3RlbmN5Pw0KDQpUaGFua3MsDQotVG9z
aGkNCg0K

