Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ABAFC43381
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:41:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E933E20836
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 08:41:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="bmQ9uzaC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E933E20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DEE08E000B; Sun,  3 Mar 2019 03:41:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78BF08E0001; Sun,  3 Mar 2019 03:41:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62C348E000B; Sun,  3 Mar 2019 03:41:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07D728E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 03:41:18 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u25so1152728edd.15
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 00:41:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=Wvke2D39si7LOcH3Sc8zdzYKGjzai9N8Qy8g4geGiDA=;
        b=huRggEau+n8YwvkjqNZD24u+2+7uuESC2b/5tx4+i8dEfCjtRC12iF6O41YN3o0N9P
         XmrBRikLY2hF9SKNNSVvwVw5EGNpIKTnqRpOTOeG4RX0B+ZeT7GklY7Cfo9V7ZPPX1XJ
         gERlKiYOCZDdtbmh6qrG4LJKcP4GkzHn1UU4uBPNGaU4eBM2CGaeNT4mt4752ENbR6UP
         /Hwap6mWBxqzRaP6Wml/sLImuTjRUFGICR9cRevlLt31NUbnEVJVWOTOtBlwUHuaoa0d
         MEeCFTfU2cV1XJlYnJZxdis9Q8SOb5PBW0sfzLdZ6iwwjPFokniIDAdhV+RBeUZurusQ
         pmRw==
X-Gm-Message-State: APjAAAVydR6DWIdKqP44aIt12Eyk8LypPW7Kc7sHVCwUY1Y2hibd269e
	Cq/hxZDITJxF/JhemWewJQLu38RzRElCEWliQRAPZ9ATYI5mu5N8uePy5XpeZyHd5ZXb49TcNit
	z/Z2H8nEsoayUZQbnLGKURR9kzoAGznkiu53Ez1DGZ/UDheOQu7UJZCO8bWpstcYclw==
X-Received: by 2002:a50:b36b:: with SMTP id r40mr11288582edd.12.1551602477597;
        Sun, 03 Mar 2019 00:41:17 -0800 (PST)
X-Google-Smtp-Source: APXvYqwdrdvUGrEK/kIP2/4WQJwL1yN73eSNY8No6yevRe0qOQ9knYwczRLxqwccV/aTJapGMHB3
X-Received: by 2002:a50:b36b:: with SMTP id r40mr11288545edd.12.1551602476823;
        Sun, 03 Mar 2019 00:41:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551602476; cv=none;
        d=google.com; s=arc-20160816;
        b=TxI4Z4dNqwFhJz8Fqv0fy12hvPKhcDuQGJ6wMQLEc5F83GK7551BpQIQ/eZyiJo+uy
         6tQq0DPl0ovEdoaJ/0PDqyIvl7kGhX0dxvgA/b2pGUVKhTaQUpbHzh2U4UJ1wziexnPQ
         eJEtQd7EiGDO17yyT39F2X78qFHkuG+NPRDAtSMxOQHWdTHmq5+zNiBzbnD6KMkZsddz
         GZ5Sk0E1cZUGP9la6Ev0kwnIQLsULQ4P5WYDHWy0YpGCfH7/KENCynIl5Oke+KfXraAR
         fT0L+Se6CqoOsmt01mdOB5ZUntlQeuh2HXjXhEv6yrQPp4cM8HpPZgy+ptF2ysSEfevU
         qM4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Wvke2D39si7LOcH3Sc8zdzYKGjzai9N8Qy8g4geGiDA=;
        b=Z8JUcORcXmJqshKKhXyz51Pw8N3h/VXdxWYjAD9//ZOnzsFVt8QdOeE/ym0NrF/SmX
         gnWcUAAhq6usDQEzd4eYzwSY7eqeO9waGNHEHCORICq1NpPjG3kS2VzEmY+3vwFz7WW+
         8xoGaDAzgFaM5DtO05FBkT+P9JUYDRhS4SJlDtzJOtdnTUYSYCF+Gngw7TUKijVes8EQ
         t8YovElCRDBDitH4UTAHoKTbcJScilFqzfvqhqSPkVucjOW+llLvWYtFE3CaGuLzH6YR
         Ur5TSIGLlzHESQNzV5qVfzHUg+10uLv0LwQwDr30qH585nqW/H0dRaF1OufRBMj8ne1U
         pOGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=bmQ9uzaC;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.74 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80074.outbound.protection.outlook.com. [40.107.8.74])
        by mx.google.com with ESMTPS id l12si867932ejz.77.2019.03.03.00.41.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 03 Mar 2019 00:41:16 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.74 as permitted sender) client-ip=40.107.8.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=bmQ9uzaC;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.8.74 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Wvke2D39si7LOcH3Sc8zdzYKGjzai9N8Qy8g4geGiDA=;
 b=bmQ9uzaCEjsgoDUAp7hIuRM4PxsJfP9GnzPnKcPIxKhZnEvTLRxvvonyrw/JB0rEg33zAKAFVxYWttaYubIHqOiKoF5L6SASJxjjV7JvxoJCb1V4MQEhJjER1rWugPvhGBh75+dGshKIOx9neHQNdkTR1H5WeLeQ0UBUKdVtCJ8=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB5988.eurprd04.prod.outlook.com (20.178.115.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.17; Sun, 3 Mar 2019 08:41:15 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1665.019; Sun, 3 Mar 2019
 08:41:15 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Vlad Buslov
	<vladbu@mellanox.com>, "kernel-team@fb.com" <kernel-team@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH 02/12] percpu: do not search past bitmap when allocating
 an area
Thread-Topic: [PATCH 02/12] percpu: do not search past bitmap when allocating
 an area
Thread-Index: AQHUzwvyQrNOCAGGWES+BJaA5orrJqX4VbWggACZYICAAKwpoA==
Date: Sun, 3 Mar 2019 08:41:15 +0000
Message-ID:
 <AM0PR04MB4481E4E07A8A16BC3C2F296F88700@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190228021839.55779-1-dennis@kernel.org>
 <20190228021839.55779-3-dennis@kernel.org>
 <AM0PR04MB4481E8B4E51EB7FCFA72ABF088770@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190302222341.GA1196@dennisz-mbp.home>
In-Reply-To: <20190302222341.GA1196@dennisz-mbp.home>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c04becae-f92f-428e-0f60-08d69fb3ff83
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5988;
x-ms-traffictypediagnostic: AM0PR04MB5988:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtBTTBQUjA0TUI1OTg4OzIzOm5yMXV6NXBQR1dqNkdLb3kzTWJuVUZjQTlI?=
 =?utf-8?B?bWJHQ0lnaWZzYVZGWGVmY09mSzdUZ3BqS3NpcEJGZnM5ZmFHSEVhOHZkV0tp?=
 =?utf-8?B?Z0FwYUhyb1c0TjkzYVEyRU40ZE5Cb28zYTh2UzBxSmRZd3ZicmxZOGtLa0tY?=
 =?utf-8?B?cTFwanNtdllkbkFPdkJNZkdBTGdMdnRwTXAvU2F6c3lzdjFiVG5LNG9BVnBw?=
 =?utf-8?B?Ny9Zem5qSHBITW5SNjFLTi9GbTF6VUNhZTZmQytmQkVEMG9mejZ6bEMrSnUr?=
 =?utf-8?B?TkFWY21sWU5rT3YvcjFTUllSbUZ5Rnh2ekErbXFENnVsNWxiYmhPaFhab1Ru?=
 =?utf-8?B?ZS9pSjcvMFJlNXRXTUdoRmtocEVTcHN3NGE3MXFWQXNRREU4aXorY1NtT3pk?=
 =?utf-8?B?QW9MMXBGWm40Ri9EMVBIOC94VUF4ejZvbEtiUjdPNlRNMHFidEFpY2F6ODBs?=
 =?utf-8?B?MzNqRFNHa1lSYjNqaGZUc3pPcnRBeWIzY0syU0g5ZHdNOE9CVjl3OGdhWXdP?=
 =?utf-8?B?VjR3TmhqTXcxRTZRY1ZJNFJmQUpBbHVYSEpSMFhIRTRXRWExL0h4Y2tVdzk5?=
 =?utf-8?B?SGFhZ3lJVmpMVWp3YXdnMGVZbm5KQUNsNnNxL2IrL00vYzVCTkh6ZkRtanBL?=
 =?utf-8?B?U0t0dmFKL1hXcSsvRnZGbXNHOGg0WkFWcjJDSzFtZWR6MlN1R0QxQ0t6ZHlZ?=
 =?utf-8?B?V2U1WjZzN2tKREp0cG53TlAzRU1UYUEzOFpSckkveS9ESGl1TldTZ0J2eVc1?=
 =?utf-8?B?cDBnMUlHbExuajdMZjdkOFNweTM1T3BVdjRHckE4MlJtTzVXRnAzSzZXZFY1?=
 =?utf-8?B?S0QvZWpMbTAwWEt5djJ1TnBmWlN1V3lIbWhpTVNkRTFmS05HMnJ3c0dUNytv?=
 =?utf-8?B?RzZTK2FrZjJhbHI1UFJOWFVsdkxOd1Q4T3dueS8xM3FBVlc2M25ENkRYVC9S?=
 =?utf-8?B?cjVSTjh2VGoxRlNHVXlIZHJITWp1VDJhRU5CR1QrY3dSbU1ZNXc4cUpKYzg3?=
 =?utf-8?B?MHE3eWdLTnBJTGYxY2ZYQjJTN3R2d3hWZlVPalk2YzVDQ3pkVTFnTWtWNUF2?=
 =?utf-8?B?K25EeVJVSTRXNlR3NHV0T2Z5OWFGazNuVUFub0dEVVFiTTY5c2dSL3p1cVRR?=
 =?utf-8?B?NGxPYnhxWkNDbDlpdExuQTRHeGEvVlBha1A1clU1U1VveEFCOUVWMWFRQzVR?=
 =?utf-8?B?TWpQM3N6R2NJWHpxblZiK0lDdnY3c0VpWCtHcDZIWlI4ZzhGMTVIby9aQlYv?=
 =?utf-8?B?aXp1VnlwQWxEVjVOMXNabjFYeUxoLzdzU2phZkoxVFZxNzR4QkVhamhtUG54?=
 =?utf-8?B?VVZ5bm1JdklIakJ0Zk5EOHcxWmdZaXhZNUF4dDN6c1Z4TzJDWVdZTExuK3VY?=
 =?utf-8?B?UnNYa0dRMUtjaTJ0STY2ZmtDWHBPc1BlNVh2KzhySGp1cWZ0M25iM29scWd3?=
 =?utf-8?B?RmJyMTZzWGlqNVpqeWcyaTMxaEZwRDZZTExyR0pkc3kxem4wMmRKYWhzQkZZ?=
 =?utf-8?B?OC92eVRiZVZIbm8yY3B3OTZnYWdCaXVHY1RjRzNRSldFMmovMWgxcE1hMXdP?=
 =?utf-8?B?TVc5cUNRQkgrNCtXQmFpTzhjSlBSUEMwQ1dFMnUvdzRRQTNNMkw0dkNlVjBl?=
 =?utf-8?B?SFZxNmZSYWkvb08zQmRRbXJzZlRmT2Z6UWNzNm1sclJudU85Z0FsdUM4NXh2?=
 =?utf-8?B?WENvK0xtTVUvTkNTWDZtcFpTc1kzWmRaWDV6MWwwRk9vYmpTL3dDYURMSGFH?=
 =?utf-8?Q?DKzkIZvQDQFw8X6pyELX1GEW85j1UXxk7CDE0=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB59884FDC8F11F4418DB9B5E988700@AM0PR04MB5988.eurprd04.prod.outlook.com>
x-forefront-prvs: 096507C068
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(39860400002)(136003)(376002)(396003)(346002)(13464003)(189003)(199004)(14454004)(446003)(11346002)(33656002)(68736007)(102836004)(76176011)(53546011)(6506007)(476003)(7696005)(6246003)(486006)(2906002)(7736002)(81156014)(305945005)(74316002)(8676002)(81166006)(8936002)(71200400001)(71190400001)(99286004)(6916009)(44832011)(186003)(26005)(52536013)(478600001)(105586002)(106356001)(66066001)(97736004)(5660300002)(3846002)(9686003)(6116002)(229853002)(6436002)(93886005)(256004)(53936002)(25786009)(14444005)(86362001)(55016002)(4326008)(54906003)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5988;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 9JbIHKzFcS5bjT5xzLqsYcRJcZaygsxF7LZ3qL6g46BmgxVCfSmdDou6Q/Xc6LurM8L0D1lNVQ4pKJ7rFuLD53FwQgjkUi4bS35tPR47B/+Z2G15eiW7KLFq4AnK7UWB8Gyl7rrTXY1KMoXIOWqWUEdpN/2BF8Cv0S6ARmz6PHG2Gp18kcNJtMKAD7BXoQNZG0ActdQZwarfl6v1yEUk+5cG2qyaBBb7+e+QgXGRWWLP8n2rRGk5OeaFiiVWW+5ixjvnvmuugLwi73/OVI2kxIz+kdQXLVuD7kBmJB7DCkaq8PmvepNBwrGSS5bhFFRITTFup+iu8TeaYh0cuQFReR93TTum3wu31iLjJ8o3Q9oMxLRvQs8xjPZd5Wvcswz0MZH/FwWUpHGfCfbtHijyovW9xA9JrGRIyc+D9rS28UU=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c04becae-f92f-428e-0f60-08d69fb3ff83
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Mar 2019 08:41:15.2764
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5988
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRGVubmlzIFpob3UgW21h
aWx0bzpkZW5uaXNAa2VybmVsLm9yZ10NCj4gU2VudDogMjAxOeW5tDPmnIgz5pelIDY6MjQNCj4g
VG86IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiBDYzogVGVqdW4gSGVvIDx0akBrZXJu
ZWwub3JnPjsgQ2hyaXN0b3BoIExhbWV0ZXIgPGNsQGxpbnV4LmNvbT47IFZsYWQNCj4gQnVzbG92
IDx2bGFkYnVAbWVsbGFub3guY29tPjsga2VybmVsLXRlYW1AZmIuY29tOyBsaW51eC1tbUBrdmFj
ay5vcmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtQ
QVRDSCAwMi8xMl0gcGVyY3B1OiBkbyBub3Qgc2VhcmNoIHBhc3QgYml0bWFwIHdoZW4gYWxsb2Nh
dGluZw0KPiBhbiBhcmVhDQo+IA0KPiBPbiBTYXQsIE1hciAwMiwgMjAxOSBhdCAwMTozMjowNFBN
ICswMDAwLCBQZW5nIEZhbiB3cm90ZToNCj4gPiBIaSBEZW5uaXMsDQo+ID4NCj4gPiA+IC0tLS0t
T3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gPiBGcm9tOiBvd25lci1saW51eC1tbUBrdmFjay5v
cmcgW21haWx0bzpvd25lci1saW51eC1tbUBrdmFjay5vcmddDQo+IE9uDQo+ID4gPiBCZWhhbGYg
T2YgRGVubmlzIFpob3UNCj4gPiA+IFNlbnQ6IDIwMTnlubQy5pyIMjjml6UgMTA6MTgNCj4gPiA+
IFRvOiBEZW5uaXMgWmhvdSA8ZGVubmlzQGtlcm5lbC5vcmc+OyBUZWp1biBIZW8gPHRqQGtlcm5l
bC5vcmc+Ow0KPiA+ID4gQ2hyaXN0b3BoIExhbWV0ZXIgPGNsQGxpbnV4LmNvbT4NCj4gPiA+IENj
OiBWbGFkIEJ1c2xvdiA8dmxhZGJ1QG1lbGxhbm94LmNvbT47IGtlcm5lbC10ZWFtQGZiLmNvbTsN
Cj4gPiA+IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0K
PiA+ID4gU3ViamVjdDogW1BBVENIIDAyLzEyXSBwZXJjcHU6IGRvIG5vdCBzZWFyY2ggcGFzdCBi
aXRtYXAgd2hlbg0KPiA+ID4gYWxsb2NhdGluZyBhbiBhcmVhDQo+ID4gPg0KPiA+ID4gcGNwdV9m
aW5kX2Jsb2NrX2ZpdCgpIGd1YXJhbnRlZXMgdGhhdCBhIGZpdCBpcyBmb3VuZCB3aXRoaW4NCj4g
PiA+IFBDUFVfQklUTUFQX0JMT0NLX0JJVFMuIEl0ZXJhdGlvbiBpcyB1c2VkIHRvIGRldGVybWlu
ZSB0aGUgZmlyc3QgZml0DQo+ID4gPiBhcyBpdCBjb21wYXJlcyBhZ2FpbnN0IHRoZSBibG9jaydz
IGNvbnRpZ19oaW50LiBUaGlzIGNhbiBsZWFkIHRvDQo+ID4gPiBpbmNvcnJlY3RseSBzY2Fubmlu
ZyBwYXN0IHRoZSBlbmQgb2YgdGhlIGJpdG1hcC4gVGhlIGJlaGF2aW9yIHdhcw0KPiA+ID4gb2th
eSBnaXZlbiB0aGUgY2hlY2sgYWZ0ZXIgZm9yIGJpdF9vZmYgPj0gZW5kIGFuZCB0aGUgY29ycmVj
dG5lc3Mgb2YgdGhlDQo+IGhpbnRzIGZyb20gcGNwdV9maW5kX2Jsb2NrX2ZpdCgpLg0KPiA+ID4N
Cj4gPiA+IFRoaXMgcGF0Y2ggZml4ZXMgdGhpcyBieSBib3VuZGluZyB0aGUgZW5kIG9mZnNldCBi
eSB0aGUgbnVtYmVyIG9mDQo+ID4gPiBiaXRzIGluIGEgY2h1bmsuDQo+ID4gPg0KPiA+ID4gU2ln
bmVkLW9mZi1ieTogRGVubmlzIFpob3UgPGRlbm5pc0BrZXJuZWwub3JnPg0KPiA+ID4gLS0tDQo+
ID4gPiAgbW0vcGVyY3B1LmMgfCAzICsrLQ0KPiA+ID4gIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2Vy
dGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4gPiA+DQo+ID4gPiBkaWZmIC0tZ2l0IGEvbW0vcGVy
Y3B1LmMgYi9tbS9wZXJjcHUuYyBpbmRleA0KPiA+ID4gNTNiZDc5YTYxN2IxLi42OWNhNTFkMjM4
YjUgMTAwNjQ0DQo+ID4gPiAtLS0gYS9tbS9wZXJjcHUuYw0KPiA+ID4gKysrIGIvbW0vcGVyY3B1
LmMNCj4gPiA+IEBAIC05ODgsNyArOTg4LDggQEAgc3RhdGljIGludCBwY3B1X2FsbG9jX2FyZWEo
c3RydWN0IHBjcHVfY2h1bmsNCj4gPiA+ICpjaHVuaywgaW50IGFsbG9jX2JpdHMsDQo+ID4gPiAg
CS8qDQo+ID4gPiAgCSAqIFNlYXJjaCB0byBmaW5kIGEgZml0Lg0KPiA+ID4gIAkgKi8NCj4gPiA+
IC0JZW5kID0gc3RhcnQgKyBhbGxvY19iaXRzICsgUENQVV9CSVRNQVBfQkxPQ0tfQklUUzsNCj4g
PiA+ICsJZW5kID0gbWluX3QoaW50LCBzdGFydCArIGFsbG9jX2JpdHMgKyBQQ1BVX0JJVE1BUF9C
TE9DS19CSVRTLA0KPiA+ID4gKwkJICAgIHBjcHVfY2h1bmtfbWFwX2JpdHMoY2h1bmspKTsNCj4g
PiA+ICAJYml0X29mZiA9IGJpdG1hcF9maW5kX25leHRfemVyb19hcmVhKGNodW5rLT5hbGxvY19t
YXAsIGVuZCwNCj4gc3RhcnQsDQo+ID4gPiAgCQkJCQkgICAgIGFsbG9jX2JpdHMsIGFsaWduX21h
c2spOw0KPiA+ID4gIAlpZiAoYml0X29mZiA+PSBlbmQpDQo+ID4gPiAtLQ0KPiA+DQo+ID4gRnJv
bSBwY3B1X2FsbG9jX2FyZWEgaXRzZWxmLCBJIHRoaW5rIHRoaXMgaXMgY29ycmVjdCB0byBhdm9p
ZA0KPiA+IGJpdG1hcF9maW5kX25leHRfemVyb19hcmVhIHNjYW4gcGFzdCB0aGUgYm91bmRhcmll
cyBvZiBhbGxvY19tYXAsIHNvDQo+ID4NCj4gPiBSZXZpZXdlZC1ieTogUGVuZyBGYW4gPHBlbmcu
ZmFuQG54cC5jb20+DQo+ID4NCj4gPiBUaGVyZSBhcmUgYSBmZXcgcG9pbnRzIEkgZGlkIG5vdCB1
bmRlcnN0YW5kIHdlbGwsIFBlciB1bmRlcnN0YW5kaW5nDQo+ID4gcGNwdV9maW5kX2Jsb2NrX2Zp
dCBpcyB0byBmaW5kIHRoZSBmaXJzdCBiaXQgb2ZmIGluIGEgY2h1bmsgd2hpY2gNCj4gPiBjb3Vs
ZCBzYXRpc2Z5IHRoZSBiaXRzIGFsbG9jYXRpb24sIHNvIGJpdHMgbWlnaHQgYmUgbGFyZ2VyIHRo
YW4NCj4gPiBQQ1BVX0JJVE1BUF9CTE9DS19CSVRTLiBBbmQgaWYgcGNwdV9maW5kX2Jsb2NrX2Zp
dCByZXR1cm5zIGEgZ29vZCBvZmYsDQo+ID4gaXQgbWVhbnMgdGhlcmUgaXMgYSBhcmVhIGluIHRo
ZSBjaHVuayBjb3VsZCBzYXRpc2Z5IHRoZSBiaXRzDQo+ID4gYWxsb2NhdGlvbiwgdGhlbiB0aGUg
Zm9sbG93aW5nIHBjcHVfYWxsb2NfYXJlYSB3aWxsIG5vdCBzY2FuIHBhc3QgdGhlDQo+IGJvdW5k
YXJpZXMgb2YgYWxsb2NfbWFwLCByaWdodD8NCj4gPg0KPiANCj4gcGNwdV9maW5kX2Jsb2NrX2Zp
dCgpIGZpbmRzIHRoZSBjaHVuayBvZmZzZXQgY29ycmVzcG9uZGluZyB0byB0aGUgYmxvY2sgdGhh
dA0KPiB3aWxsIGJlIGFibGUgdG8gZml0IHRoZSBjaHVuay4gQWxsb2NhdGlvbnMgYXJlIGRvbmUg
YnkgZmlyc3QgZml0LCBzbyBzY2FubmluZyBiZWdpbnMNCj4gZnJvbSB0aGUgZmlyc3RfZnJlZSBv
ZiBhIGJsb2NrLiBCZWNhdXNlIHRoZSBoaW50cyBhcmUgYWx3YXlzIGFjY3VyYXRlLCB5b3UNCj4g
bmV2ZXIgZmFpbCB0byBmaW5kIGEgZml0IGluIHBjcHVfYWxsb2NfYXJlYSgpIGlmDQo+IHBjcHVf
ZmluZF9ibG9ja19maXQoKSBnaXZlcyB5b3UgYW4gb2Zmc2V0LiBUaGlzIG1lYW5zIHlvdSBuZXZl
ciBzY2FuIHBhc3QgdGhlDQo+IGVuZCBhbnl3YXkuDQoNClRoYW5rcyBmb3IgZXhwbGFuYXRpb24u
DQoNClRoYW5rcywNClBlbmcuDQoNCj4gDQo+IFRoYW5rcywNCj4gRGVubmlzDQo=

