Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49869C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0B1C21721
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 16:42:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="HopT+E6P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0B1C21721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DF208E0001; Thu,  4 Jul 2019 12:42:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18FFB6B0005; Thu,  4 Jul 2019 12:42:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 057A98E0001; Thu,  4 Jul 2019 12:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC1E86B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 12:42:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m23so4143690edr.7
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 09:42:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=wgsSYVqWAN7zpRQYvB8rkaDe+yXFBCGV3KXoYay916E=;
        b=SIWVw+9JgS+UVQqoVRjdP6lKI53m2S8g1cATPm6qdJ1Hbb6jECsVgXHt99A1npn16V
         KMJN6yo0L8x+U8wfkynT2iQix4YVe7E5Ft8X6CXS43Fzggk5bHiIXaDAJ855RTL+hMsN
         E5kOy0Tv6Ti/wzeQtcndKXpc/YWdqyO/IRc5cAzZlHkBqXG0F2DRe9BUUlWKfa2Ucfvw
         s1DVZ800z74URjaq/uRCJrRjo3x1evZXHa0p5/U8EbB/xeh6Z+l5vrbXHkIUahgBCetO
         +tNwlJSVu4rm90tmGKhl5S/apiPd/jlsuzUDhuShRgGfRFEMIDZaKw3pLW7Gy24ogAR7
         CvPw==
X-Gm-Message-State: APjAAAWAsZN9EF7jvm8n7nLoFTGA7gcSgN0ks66M6JQmMtC+12gJIf+n
	tk+zQGqCO5S1BqxfPeCx8lZT88YrSwhyTG1IgS7CxWgJLf5BCVs6V10TdG/hydhwfNHgmHMmmZl
	FSi/8PvexhC/Gip11nzL/26WY5OPVstH7uKLvvE1MYjI5Y1VqhNONAVOuf2vuiMw+Yw==
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr40691326ejb.267.1562258564193;
        Thu, 04 Jul 2019 09:42:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt/4fDuAjiS0SbBUmzW3uDxEjhPDy8RLheaH8YIwLX43FjPIvAeGLLsYX4lNxv7mbYSmqj
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr40691278ejb.267.1562258563472;
        Thu, 04 Jul 2019 09:42:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562258563; cv=none;
        d=google.com; s=arc-20160816;
        b=WrcUEaC1KVv9IJIehgQpKe1XLAbNQ4SLeCDtc1HtvytZYBN8VIGkzIXzUiokOcyuXh
         VsAjoZAU5Zro3lScn5rA72F66bqaqWsVIdtpsbwBYzcMUcLXWzewzUABmuoWBmQIJRB3
         2K1UJ9QIhQ5rSh6DGPM8kGQWWQpMTOlEaTRTV+toaM15/puYiV57/yTHBEXDBBMhrHrU
         EK9uGo8oxHyHW0zXZPMVmUQtfllVrvCqBq4emhyWHaWLYYeVNoKwJ3Zvtfs6CMGEYyW8
         zaegsKyD/ZfXKhncNUAH/0/Cz1+Of4+ak1kxhnN6auABecrzeLJ6RHD5eSq7DNKtQDuK
         JzNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=wgsSYVqWAN7zpRQYvB8rkaDe+yXFBCGV3KXoYay916E=;
        b=YEaAagaq+FRJpGfEPRDIshN2G0wNWSyR3L1/rjMIOe6i66DYtcdoviG1PHHVRnI/sN
         I3NVO/wAdtNNiuCxxDvrhgc7jg63F5iwmZ44NJXe7DHD3LiApKy5lzv1/qHSdcSoE8lL
         Nm67APXjvi9/r0U//5kJu3tHD5LK5VKFeSpBpF87acMQgbQ41uFBPzLamQe6A3+PI4qn
         1WYxV517Mo7FGiEHQvzWM3X8ui2uT87Vza5dwI8HTHMxI6VvpYRJxEx68Ns2+N3ferB+
         13vvidSW8Wd+H7cUqoKWcB5jfD8iCJXTG5r5J54FO83ZbOyzVHYc9YYy7owabJn1dvtR
         rsbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HopT+E6P;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.51 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150051.outbound.protection.outlook.com. [40.107.15.51])
        by mx.google.com with ESMTPS id b14si4017877ejb.289.2019.07.04.09.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 09:42:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.51 as permitted sender) client-ip=40.107.15.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HopT+E6P;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.51 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wgsSYVqWAN7zpRQYvB8rkaDe+yXFBCGV3KXoYay916E=;
 b=HopT+E6PwjgEz4sSI6VfRou/qjWczQYExeWvDdTfR3K+YFM7bRYHh2lSkC9QB107D3jYzaK8cCllupyYuIEyPT0RbxLxX3eB+2AjPiB8npdxginhRh0A3CMcMd74IdijBtMwY82ygNYdANkAOCWSn1QSAHUk+JHMV0UjxzXsirA=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5567.eurprd05.prod.outlook.com (20.177.202.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Thu, 4 Jul 2019 16:42:41 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2032.019; Thu, 4 Jul 2019
 16:42:41 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: hmm_range_fault related fixes and legacy API removal v2
Thread-Topic: hmm_range_fault related fixes and legacy API removal v2
Thread-Index: AQHVMer7t/tGwC82LkyVSWCA9HbG9qa6qyIA
Date: Thu, 4 Jul 2019 16:42:41 +0000
Message-ID: <20190704164236.GP3401@mellanox.com>
References: <20190703220214.28319-1-hch@lst.de>
In-Reply-To: <20190703220214.28319-1-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR13CA0014.namprd13.prod.outlook.com
 (2603:10b6:208:160::27) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d777add8-1034-4a02-2894-08d7009ea152
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5567;
x-ms-traffictypediagnostic: VI1PR05MB5567:
x-microsoft-antispam-prvs:
 <VI1PR05MB5567FDCECF3917DF8168379ACFFA0@VI1PR05MB5567.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0088C92887
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(346002)(39860400002)(136003)(396003)(376002)(189003)(199004)(66556008)(54906003)(66946007)(64756008)(66476007)(26005)(36756003)(33656002)(386003)(14454004)(6506007)(102836004)(66066001)(66446008)(5660300002)(3846002)(86362001)(305945005)(186003)(6116002)(4744005)(6512007)(8936002)(7736002)(256004)(4326008)(478600001)(66574012)(73956011)(6436002)(81156014)(71190400001)(1076003)(8676002)(6486002)(99286004)(25786009)(53936002)(52116002)(6246003)(486006)(71200400001)(316002)(476003)(2616005)(229853002)(76176011)(68736007)(81166006)(2906002)(446003)(11346002)(6916009);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5567;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 qfd6DQ3O9lVmXBhzL6fZ+XuCwJs9t9/P5U344ddNKLuPom7Rmm68yw1qMQBHEIrkHXqXQzm1fevCer2xP0wcMMXo+9/Ewpfhgm1Ptht9YIbRs8Av5yUnb8+T2lprvJDFxhhGdYn+V2g5sSYXyntD589feGEfajxJ2j47A8mjQ+DEwzvYvAKZaoY0wxG0ogxuL2V9tBdSjmriI3S+fKmRlPqhdFYfGx9YGfCvmBevPGHukIjvQQxe1ZbFjeZfZRVNdqIm48GyiVpnnZJ2UijtzmLJOZKMFp6tmO+fcOzxctP3DzGxrIsAoVULMyD0f5IZbvgotwrId4dWM5VEMK8N4+LWGggNvwLEegiD5te5D4WPzffEGf2DFak04gumVAT0SLzOQyPEoB3otcyDsFblfS49Ol+UzQapWUxTQcpuRj8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <6E2A6AFC2F28DA408E71977260C54358@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d777add8-1034-4a02-2894-08d7009ea152
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Jul 2019 16:42:41.2830
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5567
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCBKdWwgMDMsIDIwMTkgYXQgMDM6MDI6MDhQTSAtMDcwMCwgQ2hyaXN0b3BoIEhlbGx3
aWcgd3JvdGU6DQo+IEhpIErDqXLDtG1lLCBCZW4gYW5kIEphc29uLA0KPiANCj4gYmVsb3cgaXMg
YSBzZXJpZXMgYWdhaW5zdCB0aGUgaG1tIHRyZWUgd2hpY2ggZml4ZXMgdXAgdGhlIG1tYXBfc2Vt
DQo+IGxvY2tpbmcgaW4gbm91dmVhdSBhbmQgd2hpbGUgYXQgaXQgYWxzbyByZW1vdmVzIGxlZnRv
dmVyIGxlZ2FjeSBITU0gQVBJcw0KPiBvbmx5IHVzZWQgYnkgbm91dmVhdS4NCj4gDQo+IENoYW5n
ZXMgc2luY2UgdjE6DQo+ICAtIGRvbid0IHJldHVybiB0aGUgdmFsaWQgc3RhdGUgZnJvbSBobW1f
cmFuZ2VfdW5yZWdpc3Rlcg0KPiAgLSBhZGRpdGlvbmFsIG5vdXZlYXUgY2xlYW51cHMNCg0KUmFs
cGgsIHNpbmNlIG1vc3Qgb2YgdGhpcyBpcyBub3V2ZWF1IGNvdWxkIHlvdSBjb250cmlidXRlIGEN
ClRlc3RlZC1ieT8gVGhhbmtzDQoNCkphc29uDQo=

