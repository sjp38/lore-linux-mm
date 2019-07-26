Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97AEDC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:12:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A4F422BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 15:12:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="ZNuO6j75"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A4F422BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2B216B0006; Fri, 26 Jul 2019 11:12:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDD706B0007; Fri, 26 Jul 2019 11:12:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA4D58E0002; Fri, 26 Jul 2019 11:12:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55F2B6B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 11:12:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m23so34258928edr.7
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:12:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=guDTCP/M//u6anzpc/1QhmrqiJYuZRYf9Jq6+WNGuco=;
        b=llt/yCb/0fTOrqTFDEZ6q0tyC2Dvr+5D4F3pvwgcikbFu3D+Yh7XIwgB7BfCg4URpu
         05Aa42GM02NYhxAOh61K0csWO6dRKjBSNhA9zC0wWPOCJlpizJ0G1G5T0b4koBeoJNAb
         JelBbGJUl8gqLbOS3+OrW3v35Uoqr/BdZJxk1V2kiw86V5mtGGMRDEekBhmAlgSAX3+U
         1pbsgy1SqHD5XMzOcBXkuacuwxXRqdMHj7Sl+1nfAJwu3gHxsxAWDffVc0ffj7cMLelt
         /Uq81qCQ6SXfZSp9c5ZIm30KD/MJj9Loc1TRwINYtjbf3hi15fLOx+8YnQVu15xwjJ3n
         v8tQ==
X-Gm-Message-State: APjAAAUKqHK7NiGpvGwh0J1uqvBwQ09HBcMRTTFYP+UnXz+z3wge33Ru
	lg20ZkIAkky/BUcRISEnQkXTHRACMDDJ5+I/OU17FPk1OibVcX6e8TyTS49oHEASisYwGPZsrWH
	alF5KScNNQ28Sn8flf2H75pDe6WN4g/VnoQvUiwh5NMVagK0kUfAeQODbsCEmzbYYTQ==
X-Received: by 2002:aa7:d1da:: with SMTP id g26mr83008714edp.198.1564153950862;
        Fri, 26 Jul 2019 08:12:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2CGtI0HMABFkj7eqfG8FuBzrFU5xkgphh8M6XFsUODbt/LOzMjuikATqQgUY2eWC0IWGw
X-Received: by 2002:aa7:d1da:: with SMTP id g26mr83008634edp.198.1564153949998;
        Fri, 26 Jul 2019 08:12:29 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564153949; cv=pass;
        d=google.com; s=arc-20160816;
        b=yzdgomyLOwFUeW+PO5gm8TZd/KT0Ayd+Olh2EoyOeV2L9uKK2oWFVg7UqkIUWcykDg
         22md68LqLfbDBnTxGw3poifYCwsJPpispCbg4CghknlXsssu3igBqh9a8qyanisFx0aa
         LjdMbVQzYuKO7dpDa8hscFBMdjS08tN3hLg+6siQarwsicaMNi7XnA4NP0V4n8idWzTQ
         Lx3OutXPiWvsTYjjk9hPc0GVbv6etSPmWjKFlxoA4n4iWvucO7FQUgTG0jjuT4ieYDk+
         Udu+ix2tPZRP53RdMvR9aFnDzYhvZT6pL+z5Z8RT7tpYaWGXl9D72Y8tNy4wD0WtX8H+
         Ae+w==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=guDTCP/M//u6anzpc/1QhmrqiJYuZRYf9Jq6+WNGuco=;
        b=0cMrKdGWctJgeUWzJbC5fgpP98QBbYGlZR+d8f3nOSNHltpYJ+WGEpVd5jbMrfJ3kM
         qyyf4JAbijetSsXzXXSlir7z8jZIdTtNNFEJ2wclVGPYMr1pMFmMP0++Fbb7yH/9q4NI
         /G/slMA4i5ieBnoC4KyKoLs7zE6rbKOv6VqX9gvTEMoPLXlyLW+acvjKwZT8cVqpKnHZ
         FQOJtVW2xIJZRbI08Vvjjft+eKeEdsUojxbpJBvZ+gDF6Xw8x6asyX4EDPmQPFF9QZI+
         EAf4OAOJEHuwq1xehQB4pwY+z62tdraWJot8l2nkACSs0Te9pezueSq5uN+w/5xKBBev
         J7ZQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ZNuO6j75;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.46 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10046.outbound.protection.outlook.com. [40.107.1.46])
        by mx.google.com with ESMTPS id h16si13138324ede.44.2019.07.26.08.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Jul 2019 08:12:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.46 as permitted sender) client-ip=40.107.1.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=ZNuO6j75;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.46 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=SxdfTHbSJ6j/nX56bxMM26ojtbIy644E6neTv6KgnXus8TcXTdgRV04EOFwG2wSiyO7w4idGFDP1PzSECajs3Eg8J5iNlIVmrWtJDgiYm0Qf+FaMdo27c3Cme5YA7sXYbSJz0O84n8A9c8ldXc2BnltqxVgmR+7RsSQ3nR8/2HtkrJDWWAZeC6bu1qZfWZfLiXx9LAfCbJCToriGTufW+RzakGt7IlqBi6JFFrlrr/tj9MTZD+UI06/SSO96dKZVGRc/gghwE4kIQMPqjWY+CF2+HWiGaP0LxkdHOiyGB95NY/+Oktd0vtUcWpRSZ4P+CjR8XE9POLYBhjofUf772Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=guDTCP/M//u6anzpc/1QhmrqiJYuZRYf9Jq6+WNGuco=;
 b=RuKXU0w1Rc9JXeMJJssb9pTyYZbjeUlMLpYn0ZXWXeytL2Ko0XbyNtcaH41bKnUM5bq3eSAKpVu/7kYgTaWTZ5m5Qn6bB2YyphBzQ63pyBg/de6fH0Xk6xyqC5/IFXE5uPa/pHIY/Qf0BcX4+NXNO5c3Y5Xkw1ToDMeQhujj1ovxonSJapEcCCITr2Aj5SOLnXVqqhsLAwUZtwnT3ltloE1cMVEtV+mYM2xZ8pWPkSLKv/Fpu8HMteAna135xWU570wOZRGRHitugjyUvd+X6jOwc9bnRC2m9z8TG1sPtrJpCE3eVNCIrQCWi7TopXWp0V4BxB2IYQJhNvTzZ4v0Ew==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=guDTCP/M//u6anzpc/1QhmrqiJYuZRYf9Jq6+WNGuco=;
 b=ZNuO6j755OOWN6jcfPR+YqUj46AMMiwQjKIPp2219bqL4tbYXWhJtBnojh2koX3fg0+iaGw5VNGWkTZpsbkVFHIfdwBeDfTQ/mSlIERjGinGVB1IhBrYA6pyB2g5vU6TL6lAk+1PXgcejFPmoEz9Pq/LuojnEeaKvvygPED/R4U=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4240.eurprd05.prod.outlook.com (52.133.12.17) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.17; Fri, 26 Jul 2019 15:12:28 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Fri, 26 Jul 2019
 15:12:27 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 5/7] mm/hmm: make full use of walk_page_range()
Thread-Topic: [PATCH v2 5/7] mm/hmm: make full use of walk_page_range()
Thread-Index: AQHVQ00O/Bid1fgONUm4ZfIe8GdLfqbdAnIA
Date: Fri, 26 Jul 2019 15:12:27 +0000
Message-ID: <20190726151222.GA12280@mellanox.com>
References: <20190726005650.2566-1-rcampbell@nvidia.com>
 <20190726005650.2566-6-rcampbell@nvidia.com>
In-Reply-To: <20190726005650.2566-6-rcampbell@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0007.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:15::20) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: be4e6cd6-6d82-4bcf-d248-08d711dbabe5
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4240;
x-ms-traffictypediagnostic: VI1PR05MB4240:
x-microsoft-antispam-prvs:
 <VI1PR05MB424072768901574CFF66D0D3CFC00@VI1PR05MB4240.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01106E96F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(396003)(346002)(39860400002)(376002)(136003)(189003)(199004)(6916009)(2906002)(54906003)(6116002)(4326008)(3846002)(71190400001)(316002)(68736007)(36756003)(52116002)(102836004)(305945005)(25786009)(8676002)(5660300002)(71200400001)(14454004)(99286004)(446003)(1076003)(2616005)(66066001)(6506007)(11346002)(476003)(386003)(53936002)(76176011)(486006)(26005)(64756008)(66574012)(6246003)(66446008)(229853002)(6486002)(66946007)(256004)(14444005)(81166006)(8936002)(33656002)(7736002)(6512007)(6436002)(86362001)(478600001)(81156014)(66556008)(186003)(66476007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4240;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 24PAAw4oyA+EBp2KuaxzMKvlqT4QIAcT+vBHyuq9qAL47dcAetx4UwYQQX+YAC91IiGbY8w+WUtx0jnmTsj8Z7hBXfArsI78yoTmhLiE0rULg1pHHc/Twr7Rwpl6tnum91jy+CyrwGJH7oKUifLkNJLYlu5jcyitu41MEfx9IcBM3mmsOFXjbCguTAkYJZzNYKzO/km8IY3cJSTvYBLc0Q8u1iG53xYovfJr+ZTWD6F7CoPkX1Vr0xKaiuheZwpxtPVt8cbUk+TzScsiOooWBNdwka0ovwRugx3JWlL50GR+KqArqDXkaQnnD7Prs0CGMvh9xkjqH56LgzYt1AQ/BI7W/FmG8N+6CT63/h6khKzojEBrOnKyrxgOyiqgHWsFyGLSl8rdR7buOWS8YAINjLBd/1WrcRHi1TMfJJrm/o4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F90DE2B4ED0D02498F2593B10870A52B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: be4e6cd6-6d82-4bcf-d248-08d711dbabe5
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Jul 2019 15:12:27.8518
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4240
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBKdWwgMjUsIDIwMTkgYXQgMDU6NTY6NDhQTSAtMDcwMCwgUmFscGggQ2FtcGJlbGwg
d3JvdGU6DQo+IGhtbV9yYW5nZV9mYXVsdCgpIGNhbGxzIGZpbmRfdm1hKCkgYW5kIHdhbGtfcGFn
ZV9yYW5nZSgpIGluIGEgbG9vcC4NCj4gVGhpcyBpcyB1bm5lY2Vzc2FyeSBkdXBsaWNhdGlvbiBz
aW5jZSB3YWxrX3BhZ2VfcmFuZ2UoKSBjYWxscyBmaW5kX3ZtYSgpDQo+IGluIGEgbG9vcCBhbHJl
YWR5Lg0KPiBTaW1wbGlmeSBobW1fcmFuZ2VfZmF1bHQoKSBieSBkZWZpbmluZyBhIHdhbGtfdGVz
dCgpIGNhbGxiYWNrIGZ1bmN0aW9uDQo+IHRvIGZpbHRlciB1bmhhbmRsZWQgdm1hcy4NCj4gDQo+
IFNpZ25lZC1vZmYtYnk6IFJhbHBoIENhbXBiZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNvbT4NCj4g
Q2M6ICJKw6lyw7RtZSBHbGlzc2UiIDxqZ2xpc3NlQHJlZGhhdC5jb20+DQo+IENjOiBKYXNvbiBH
dW50aG9ycGUgPGpnZ0BtZWxsYW5veC5jb20+DQo+IENjOiBDaHJpc3RvcGggSGVsbHdpZyA8aGNo
QGxzdC5kZT4NCj4gIG1tL2htbS5jIHwgMTMwICsrKysrKysrKysrKysrKysrKysrKysrKy0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCA1NyBpbnNlcnRp
b25zKCspLCA3MyBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9obW0uYyBiL21t
L2htbS5jDQo+IGluZGV4IDFiYzAxNGNkZGQ3OC4uODM4Y2QxZDUwNDk3IDEwMDY0NA0KPiArKysg
Yi9tbS9obW0uYw0KPiBAQCAtODQwLDEzICs4NDAsNDQgQEAgc3RhdGljIGludCBobW1fdm1hX3dh
bGtfaHVnZXRsYl9lbnRyeShwdGVfdCAqcHRlLCB1bnNpZ25lZCBsb25nIGhtYXNrLA0KPiAgI2Vu
ZGlmDQo+ICB9DQo+ICANCj4gLXN0YXRpYyB2b2lkIGhtbV9wZm5zX2NsZWFyKHN0cnVjdCBobW1f
cmFuZ2UgKnJhbmdlLA0KPiAtCQkJICAgdWludDY0X3QgKnBmbnMsDQo+IC0JCQkgICB1bnNpZ25l
ZCBsb25nIGFkZHIsDQo+IC0JCQkgICB1bnNpZ25lZCBsb25nIGVuZCkNCj4gK3N0YXRpYyBpbnQg
aG1tX3ZtYV93YWxrX3Rlc3QodW5zaWduZWQgbG9uZyBzdGFydCwNCj4gKwkJCSAgICAgdW5zaWdu
ZWQgbG9uZyBlbmQsDQo+ICsJCQkgICAgIHN0cnVjdCBtbV93YWxrICp3YWxrKQ0KPiAgew0KPiAt
CWZvciAoOyBhZGRyIDwgZW5kOyBhZGRyICs9IFBBR0VfU0laRSwgcGZucysrKQ0KPiAtCQkqcGZu
cyA9IHJhbmdlLT52YWx1ZXNbSE1NX1BGTl9OT05FXTsNCj4gKwlzdHJ1Y3QgaG1tX3ZtYV93YWxr
ICpobW1fdm1hX3dhbGsgPSB3YWxrLT5wcml2YXRlOw0KPiArCXN0cnVjdCBobW1fcmFuZ2UgKnJh
bmdlID0gaG1tX3ZtYV93YWxrLT5yYW5nZTsNCj4gKwlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSA9IHdhbGstPnZtYTsNCj4gKw0KPiArCS8qIElmIHJhbmdlIGlzIG5vIGxvbmdlciB2YWxpZCwg
Zm9yY2UgcmV0cnkuICovDQo+ICsJaWYgKCFyYW5nZS0+dmFsaWQpDQo+ICsJCXJldHVybiAtRUJV
U1k7DQo+ICsNCj4gKwkvKg0KPiArCSAqIFNraXAgdm1hIHJhbmdlcyB0aGF0IGRvbid0IGhhdmUg
c3RydWN0IHBhZ2UgYmFja2luZyB0aGVtIG9yDQo+ICsJICogbWFwIEkvTyBkZXZpY2VzIGRpcmVj
dGx5Lg0KPiArCSAqIFRPRE86IGhhbmRsZSBwZWVyLXRvLXBlZXIgZGV2aWNlIG1hcHBpbmdzLg0K
PiArCSAqLw0KPiArCWlmICh2bWEtPnZtX2ZsYWdzICYgKFZNX0lPIHwgVk1fUEZOTUFQIHwgVk1f
TUlYRURNQVApKQ0KPiArCQlyZXR1cm4gLUVGQVVMVDsNCj4gKw0KPiArCWlmIChpc192bV9odWdl
dGxiX3BhZ2Uodm1hKSkgew0KPiArCQlpZiAoaHVnZV9wYWdlX3NoaWZ0KGhzdGF0ZV92bWEodm1h
KSkgIT0gcmFuZ2UtPnBhZ2Vfc2hpZnQgJiYNCj4gKwkJICAgIHJhbmdlLT5wYWdlX3NoaWZ0ICE9
IFBBR0VfU0hJRlQpDQo+ICsJCQlyZXR1cm4gLUVJTlZBTDsNCj4gKwl9IGVsc2Ugew0KPiArCQlp
ZiAocmFuZ2UtPnBhZ2Vfc2hpZnQgIT0gUEFHRV9TSElGVCkNCj4gKwkJCXJldHVybiAtRUlOVkFM
Ow0KPiArCX0NCj4gKw0KPiArCS8qDQo+ICsJICogSWYgdm1hIGRvZXMgbm90IGFsbG93IHJlYWQg
YWNjZXNzLCB0aGVuIGFzc3VtZSB0aGF0IGl0IGRvZXMgbm90DQo+ICsJICogYWxsb3cgd3JpdGUg
YWNjZXNzLCBlaXRoZXIuIEhNTSBkb2VzIG5vdCBzdXBwb3J0IGFyY2hpdGVjdHVyZXMNCj4gKwkg
KiB0aGF0IGFsbG93IHdyaXRlIHdpdGhvdXQgcmVhZC4NCj4gKwkgKi8NCj4gKwlpZiAoISh2bWEt
PnZtX2ZsYWdzICYgVk1fUkVBRCkpDQo+ICsJCXJldHVybiAtRVBFUk07DQo+ICsNCj4gKwlyZXR1
cm4gMDsNCj4gIH0NCj4gIA0KPiAgLyoNCj4gQEAgLTk2NSw4MiArOTk2LDM1IEBAIEVYUE9SVF9T
WU1CT0woaG1tX3JhbmdlX3VucmVnaXN0ZXIpOw0KPiAgICovDQo+ICBsb25nIGhtbV9yYW5nZV9m
YXVsdChzdHJ1Y3QgaG1tX3JhbmdlICpyYW5nZSwgdW5zaWduZWQgaW50IGZsYWdzKQ0KPiAgew0K
PiAtCWNvbnN0IHVuc2lnbmVkIGxvbmcgZGV2aWNlX3ZtYSA9IFZNX0lPIHwgVk1fUEZOTUFQIHwg
Vk1fTUlYRURNQVA7DQo+IC0JdW5zaWduZWQgbG9uZyBzdGFydCA9IHJhbmdlLT5zdGFydCwgZW5k
Ow0KPiAtCXN0cnVjdCBobW1fdm1hX3dhbGsgaG1tX3ZtYV93YWxrOw0KPiArCXVuc2lnbmVkIGxv
bmcgc3RhcnQgPSByYW5nZS0+c3RhcnQ7DQo+ICsJc3RydWN0IGhtbV92bWFfd2FsayBobW1fdm1h
X3dhbGsgPSB7fTsNCj4gIAlzdHJ1Y3QgaG1tICpobW0gPSByYW5nZS0+aG1tOw0KPiAtCXN0cnVj
dCB2bV9hcmVhX3N0cnVjdCAqdm1hOw0KPiAtCXN0cnVjdCBtbV93YWxrIG1tX3dhbGs7DQo+ICsJ
c3RydWN0IG1tX3dhbGsgbW1fd2FsayA9IHt9Ow0KPiAgCWludCByZXQ7DQo+ICANCj4gIAlsb2Nr
ZGVwX2Fzc2VydF9oZWxkKCZobW0tPm1tLT5tbWFwX3NlbSk7DQo+ICANCj4gLQlkbyB7DQo+IC0J
CS8qIElmIHJhbmdlIGlzIG5vIGxvbmdlciB2YWxpZCBmb3JjZSByZXRyeS4gKi8NCj4gLQkJaWYg
KCFyYW5nZS0+dmFsaWQpDQo+IC0JCQlyZXR1cm4gLUVCVVNZOw0KPiArCWhtbV92bWFfd2Fsay5y
YW5nZSA9IHJhbmdlOw0KPiArCWhtbV92bWFfd2Fsay5sYXN0ID0gc3RhcnQ7DQo+ICsJaG1tX3Zt
YV93YWxrLmZsYWdzID0gZmxhZ3M7DQo+ICsJbW1fd2Fsay5wcml2YXRlID0gJmhtbV92bWFfd2Fs
azsNCj4gIA0KPiAtCQl2bWEgPSBmaW5kX3ZtYShobW0tPm1tLCBzdGFydCk7DQo+IC0JCWlmICh2
bWEgPT0gTlVMTCB8fCAodm1hLT52bV9mbGFncyAmIGRldmljZV92bWEpKQ0KPiAtCQkJcmV0dXJu
IC1FRkFVTFQ7DQoNCkl0IGlzIGhhcmQgdG8gdGVsbCB3aGF0IGlzIGEgY29uZnVzZWQvd3Jvbmcg
YW5kIHdoYXQgaXMgZGVsaWJlcmF0ZSBpbg0KdGhpcyBjb2RlLi4uDQoNCkN1cnJlbnRseSB0aGUg
aG1tX3JhbmdlX2ZhdWx0IGludm9rZXMgd2Fsa19wYWdlX3JhbmdlIG9uIGEgVk1BIGJ5IFZNQQ0K
YmFzaXMsIGFuZCB0aGUgYWJvdmUgcHJldmVudHMgc29tZSBjYXNlcyBvZiB3YWxrLT52bWEgYmVj
b21pbmcNCk5VTEwsIGJ1dCBub3QgYWxsIC0gZm9yIGluc3RhbmNlIGl0IGRvZXNuJ3QgY2hlY2sg
Zm9yIHN0YXJ0IDwgdm1hLT52bV9zdGFydC4NCg0KSG93ZXZlciwgY2hlY2tpbmcgaWYgaXQgY2Fu
IGFjdHVhbGx5IHRvbGVyYXRlIHRoZSB3YWxrLT52bWEgPT0gTlVMTCBpdA0KbG9va3MgbGlrZSBu
bzoNCg0KIHdhbGtfcGFnZV9yYW5nZQ0KICBmaW5kX3ZtYSA9PSBOVUxMIHx8IHN0YXJ0IDwgdm1f
c3RhcnQgLT4gd2Fsay0+dm1hID09IE5VTEwNCiAgX193YWxrX3BhZ2VfcmFuZ2UNCiAgICB3YWxr
X3BnZF9yYW5nZQ0KICAgICAgcHRlX2hvbGUgLyBobW1fdm1hX3dhbGtfaG9sZQ0KICAgICAgICBo
bW1fdm1hX3dhbGtfaG9sZV8NCiAgICAgICAgIGhtbV92bWFfZG9fZmF1bHQNCiAgICAgICAgICAg
IGhhbmRsZV9tbV9mYXVsdCh3YWxrLT52bWEsIGFkZHIsIGZsYWdzKQ0KICAgICAgICAgICAgICB2
bWEtPnZtX21tIDwtLSBPT1BTDQoNCldoaWNoIGtpbmQgb2Ygc3VnZ2VzdHMgdGhlIGZpbmRfdm1h
IGFib3ZlIHdhcyBhYm91dCBwcmV2ZW50aW5nDQp3YWxrLT52bWEgPT0gTlVMTD8gRG9lcyBzb21l
dGhpbmcgZWxzZSB0cmlja3kgcHJldmVudCB0aGlzPw0KDQpUaGlzIHBhdGNoIGFsc28gY2hhbmdl
cyBiZWhhdmlvciBzbyB0aGF0IG1pc3NpbmcgVk1BcyBkb24ndCBhbHdheXMNCnRyaWdnZXIgRUZB
VUxUICh3aGljaCBpcyBhIGdvb2QgdGhpbmcsIGJ1dCBuZWVkcyB0byBiZSBpbiB0aGUgY29tbWl0
DQptZXNzYWdlKQ0KDQpJIHN0cm9uZ2x5IGJlbGlldmUgdGhpcyBpcyB0aGUgY29ycmVjdCBkaXJl
Y3Rpb24gdG8gZ28gaW4sIGFuZCB0aGUgZmFjdA0KdGhhdCB0aGlzIGZ1bmN0aW9uIHJldHVybnMg
RUZBVUxUIGlmIHRoZXJlIGlzIG5vIFZNQS9pbmNvbXBhdGlibGUgVk1BDQppcyBhY3R1YWxseSBh
IHNlbWFudGljIGJ1ZyB3ZSBuZWVkIHRvIGZpeCBiZWZvcmUgaXQgaXMgYSB1c2FibGUgQVBJLg0K
DQpJZSBjb25zaWRlciB0aGUgdXNlciBkb2VzIHNvbWV0aGluZyBsaWtlDQogIHB0ciA9IG1tYXAo
MCwgUEFHRV9TSVpFIC4uKQ0KICBtciA9IGliX3JlZ19tcihwdHIgLSBQQUdFX1NJWkUsIHB0ciAr
IDMqUEFHRV9TSVpFLCBJQlZfQUNDRVNTX09OX0RFTUFORCkNCg0KVGhlbiBpbiB0aGUga2VybmVs
IEkgd2FudCB0byBkbyBobW1fcmFuZ2VfZmF1bHQoSE1NX0ZBVUxUX1NOQVBTSE9UKQ0KYWNyb3Nz
IHRoZSBNUiBWQSBhbmQgZ2V0IGEgcGZucyBhcnJheSB0aGF0IHNheXMgUEFHRSAwIGlzIEZBVUxU
LCBQQUdFDQoxIGlzIFIvVywgUEFHRSAyIGlzIEZBVUxULg0KDQpJbnN0ZWFkIHRoZSBlbnRpcmUg
Y2FsbCBmYWlscyBiZWNhdXNlIHRoZXJlIGlzIG5vIFZNQSBhdCB0aGUgc3RhcnRpbmcNCm9mZnNl
dCwgb3IgdGhlIFZNQSBoYWQgdGhlIHdyb25nIGZsYWdzLCBvciBzb21ldGhpbmcuDQoNCldoYXQg
aXQgc2hvdWxkIGRvIGlzIHBvcHVsYXRlIHRoZSByZXN1bHQgd2l0aCBGQVVMVCBmb3IgdGhlIGdh
cCBwYXJ0DQpvZiB0aGUgVkEgcmFuZ2UgYW5kIGNvbnRpbnVlIHRvIHRoZSBuZXh0IFZNQS4NCg0K
VGhlIHNhbWUgY29tbWVudCBhcHBsaWVzIHRvIHRoZSBpbXBsZW1lbnRhdGlvbiBvZiB0aGUgd2Fs
a2VyIHRlc3QNCmZ1bmN0aW9uLCBpdCBzaG91bGQgcmV0dXJuIDEgdG8gc2tpcCB0aGUgVk1BIGFu
ZCBmaWxsIFBGTlMgd2l0aCBGQVVMVA0Kd2hlbiB0aGVyZSBpcyBhIG1pc21hdGNoIFZNQSwgbm90
IGZhaWwgZW50aXJlbHkuDQoNClBlcmhhcHMgdGhlcmUgd2FzIHNvbWUgdGhvdWdodCB0aGF0IHRo
ZSBmYXVsdCB2ZXJzaW9uIHNob3VsZCBmYWlsIHRvDQp0ZWxsIHRoZSBwYWdlZmF1bHQgaGFuZGxl
ciB0aGVyZSBpcyBub3RoaW5nIHRvIERNQSwgYnV0IGV2ZW4gdGhhdCBpcw0Kbm90IGVudGlyZWx5
IGRlc2lyYWJsZSwgSSdkIGxpa2UgdG8gaGF2ZSAnZmF1bHQgYXJvdW5kJyBzZW1hbnRpY3MsIGlm
DQp3ZSBhcmUgZ29pbmcgdG8gYWxsIHRoZSB3b3JrIG9mIGRvaW5nIGEgZmV3IFBURXMsIGxldHMg
ZG8gYSBjaHVuay4gSQ0Kb25seSBjYXJlIGlmIHRoZSBjcml0aWNhbCBwYWdlKHMpIHRyaWdnZXJp
bmcgdGhlIGZhdWx0IGNvdWxkbid0IGJlDQpmYXVsdGVkIGluLCB0aGUgb3RoZXJzIGNhbiByZW1h
aW4gYXMgcGZuIEZBVUxULg0KDQpUbyBwcm9jZWVkIHdpdGggdGhpcyBwYXRjaCB3ZSBuZWVkIHRv
IGNvbmZpcm0vZGVueSB0aGUgYWJvdmUgdHJhY2UuIEkNCnRoaW5rIGl0IHByb2JhYmx5IGNhbiBi
ZSBmaXhlZCBlYXNpbHkgKGFzIGFub3RoZXIgcGF0Y2gpIGJ5IGNoZWNraW5nDQpmb3Igd2Fsay0+
dm1hID09IE5VTEwgaW4gdGhlIHJpZ2h0IHBsYWNlcy4NCg0KSSByZWFsbHkgd291bGQgbGlrZSB0
byBzZWUgYSB0ZXN0IGZvciB0aGlzIGZ1bmN0aW9uIHRvbyA6KCBJdCBoYXMgbG90cw0KYW5kIGxv
dHMgb2YgZWRnZSBjYXNlcyB0aGF0IG5lZWQgdGhlIGJlIGNvbXByZWhlbnNpdmVseSBleHBsb3Jl
ZA0KYmVmb3JlIHdlIGNhbiBjYWxsIHRoaXMgd29ya2luZy4uDQoNCkphc29uDQo=

