Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE800C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:20:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 886A52173C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:20:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="L4eF81bC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 886A52173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A04B6B0010; Tue, 16 Jul 2019 13:20:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329306B0266; Tue, 16 Jul 2019 13:20:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A2848E0003; Tue, 16 Jul 2019 13:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B44A36B0010
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:20:52 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id m25so5680825wml.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:20:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=lIOGFJb8MDLQSpSCG7n2MSAc9iySzj60JiBibgrXuOY=;
        b=jYAGpnXFYItnFqB464TyDbVvMEknEhiQZPrOy45a8BFKgtJRSf3ZIND4bmCLrbJQMY
         LBFDaQsHI14c+qZ4Yp86RjKgH4pvnwxkJPpXr244yxTTz8+IPBJe5OiFeeiQ3+J4FIkH
         wIGujuKpLwJ8/yX8WIb4mVeM1uUaHBcupMPd3zqDlUsc8pfmGQh9YYXfnEGXIvVP2M5Z
         FxOXhSYmVtCNvEefdSduXmD+dGRgatGl8GPrzmk4FWrXRiOQQ6cWgoZQNH6lDZHug0t2
         2qv83CEdRaEVciC7wCBJJwozDO5FMJMisvp9xnCMbPoH3wGYJgB4jKMyWURY3jhQijWP
         41Fw==
X-Gm-Message-State: APjAAAVABywt5csgKJsGEAIXwjAMoWxS86b1hc4HAOF80gtpim/5QG1R
	zKhszOJzDGbpYTWGoaeEeXcswaIcYvQLaFDwP9204anYeTFHesr79VEJywHR6dhPDZt7/7WNfpg
	BuzQKMRNXCuaCOUsT1wVgppoQ2Lx9lFkzK+Tw0LU96C7J1PM2yLEHitlRWiz2UNc3VQ==
X-Received: by 2002:adf:b1cb:: with SMTP id r11mr35065356wra.328.1563297652280;
        Tue, 16 Jul 2019 10:20:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdbPL65uaBUJh1olgfQYjCNwm8qtr73a9EM4HZjFXHZ+qcbICyciRzGwXQO6Yc+yOmspkz
X-Received: by 2002:adf:b1cb:: with SMTP id r11mr35065328wra.328.1563297651606;
        Tue, 16 Jul 2019 10:20:51 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563297651; cv=pass;
        d=google.com; s=arc-20160816;
        b=gsN6dhIyk/+3G7I3XqeagXHjERW/x/U/YGA17o61CpZXUmazCRppZZnFI6RjF/zKX9
         8r3akrFGAHtUvOe7EG2XEc3jMrqV7oJyvXDCs8QbYGYtKvSd5hlwQOwWYov7e74j+jzY
         Q5uHm/p2Ib5l71MXmV+gSAqgkX4XpdF4BB7r+E8W2IYEzrgPyCLsTHgMrxmbfFQoVC1B
         TrghDE9ndee2X8otOcFo1NmPDAjuj6DKUHhgl64TjxUa8HB35UDpy9w0qhW4j8PWvYdR
         HcIBRYFY+FgTJ+n5Mz+74VmWjdcxuYR4sbSEs9JHJnIdftOft2qO1HfMWal+kQKZD2SQ
         pWQw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=lIOGFJb8MDLQSpSCG7n2MSAc9iySzj60JiBibgrXuOY=;
        b=h6tB8LNmsbDX48mgH4BgwaWwZrW6v6/vLnI/hYoYEkG3L8ZCGdLfbwBgiBY4Aa9eVL
         9IeEDfOaIYinhOWPaMFOrEkUKEp5gEix4T3+1OVFUkwUJ7tCe6FItKIDu8zDbFQYZPEO
         Y9ENpZfPX/o+LyqZwY9iyWzoJAf2zo+33y1cE+0E8YnHsE5rJyysjrHI2kBsOS2gGJyD
         G0clLmkfZyEKAuJm6Hc0XypeuBKo/CA1EdXkpuhjisJ7gZAAo9s3j6Nzx9WM2zPZILKk
         5j6k2VX5dbv+zLK8fuRWLXTcq5nYVN/uuu14m4vRWvY7QkjOrba6tzkCP5PO9UBEUQ2p
         pnNQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L4eF81bC;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150078.outbound.protection.outlook.com. [40.107.15.78])
        by mx.google.com with ESMTPS id e6si19470725wrs.455.2019.07.16.10.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Jul 2019 10:20:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.15.78 as permitted sender) client-ip=40.107.15.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=L4eF81bC;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.15.78 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=CmhCMvmqn/z9HRu+H+batwSfjAU8XvNiOhOr+WmThavbZztel293C/TAIxh3ZhRjXXzEYzcRgmOfzMul3tn2z0iGWJ1eq2g9OcOIXvk1A895DlV0xusE1+ZhcBc2UsCMIndnLJ2ZH0oS2Hc/t3rXizVhcdKhocA8BUiCBxkCMXbg7GVjVk6SOcReDjEV0Uvn2EJbXF7t1VemQes+xAma9+wNv0ds+XWKf7r1lmr/eoTh7awYYLnLA3/5F2fuC1JyVydjDyLl4qUgtrEY1iewE2pVa2K93k26nbqoDi4eO/yPtgs+IIn2wzvYLhvb1f+BAyOferfibNuktVHVtHUnyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lIOGFJb8MDLQSpSCG7n2MSAc9iySzj60JiBibgrXuOY=;
 b=dC+EF6+AsITeMWx/nvjLcUh84QZDHQJBsDix+Ft6GHlWEM8hGjZ9S+rnr73xJo8ckwnZYbdR715xU04kY7uxgk4YYM3WC6lg4YXYCQT+nrHZ3nUgdrARXJtX20xZsmyNgOF3xtz71aiZes3wuME/kRgh89YfSN2rocysEJPMKm/LeRAIY/prxr+IFUFZHoG5RhYWL6dOhdFWKDFw1W7LZqLwodNGSgKIYEb78/gCvhbW6skYswlRA7rWDpLGNQLaGnPC94j897XGMFmYhAkjD8BFUNnAYNtY/CARP2lzjlbnYEE/Lktlw6F9Mlr5G5dCx09A6RSk02YQFIGHf10hxA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lIOGFJb8MDLQSpSCG7n2MSAc9iySzj60JiBibgrXuOY=;
 b=L4eF81bCQ8SZVVXfgtxwuMaevA8wdXjafzMFnW8IzT7oG3+cGfRJ+WBwroK9A7wAHtq8RI0om8/6FGl/Ne0HNziubSik0btPrXZ3XNGdVhH4hIs/3ea7+/4vsvEpmj0SXZEt/XEwlEY2p3q6EaRIceibZiwp6LxAniOJnj89zMI=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4703.eurprd05.prod.outlook.com (20.176.4.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Tue, 16 Jul 2019 17:20:50 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2073.012; Tue, 16 Jul 2019
 17:20:50 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: =?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: HMM related use-after-free with amdgpu
Thread-Topic: HMM related use-after-free with amdgpu
Thread-Index: AQHVOy2BuBeOBwIpPkyfmkDLpwDNk6bL7iyAgAGDN4CAAAFJgIAACCMAgAAEcIA=
Date: Tue, 16 Jul 2019 17:20:50 +0000
Message-ID: <20190716172045.GG29741@mellanox.com>
References: <9a38f48b-3974-a238-5987-5251c1343f6b@daenzer.net>
 <20190715172515.GA5043@mellanox.com>
 <823db68e-6601-bb3a-0c1f-bfc5169cb7c9@daenzer.net>
 <20190716163545.GF29741@mellanox.com>
 <cc010b8d-0018-783a-648f-01099fc63352@daenzer.net>
In-Reply-To: <cc010b8d-0018-783a-648f-01099fc63352@daenzer.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: QB1PR01CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e1e0f5c2-fd4d-43fe-d094-08d70a11f2ed
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4703;
x-ms-traffictypediagnostic: VI1PR05MB4703:
x-microsoft-antispam-prvs:
 <VI1PR05MB4703930B1FED201DCDD25E44CFCE0@VI1PR05MB4703.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0100732B76
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(136003)(396003)(346002)(376002)(39860400002)(189003)(199004)(52116002)(229853002)(6436002)(53936002)(478600001)(6512007)(6486002)(476003)(2616005)(68736007)(2906002)(486006)(6246003)(11346002)(446003)(386003)(7736002)(305945005)(25786009)(36756003)(4326008)(6506007)(26005)(102836004)(33656002)(76176011)(3846002)(8676002)(81156014)(53546011)(6916009)(81166006)(6116002)(186003)(1076003)(71190400001)(71200400001)(8936002)(66066001)(86362001)(5024004)(316002)(256004)(14454004)(5660300002)(66946007)(99286004)(66446008)(64756008)(66556008)(66476007)(54906003);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4703;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 AYsx6VYfk6nLADxIAYW/pzrUnBjWG464F7t3CAXPN8R5/7Kx7zCMz6/j/XqsKg9nCqIaH2CDQI77r2yQZB+jbpAW0RRgn85XHic77EhxgJ1EU7ip5IFiE5B/BqBjyWSoMkjEUS6pgAa1VTzWAyqhpIlJJe0sjofNKVLYj+9CJc8Nf0MLz5nv6GXmQ3I45zz+IqFwfaD5qY9R03uWIdqQGcxsAiNgwvGgozV4Rrzobn+XwV27lSfOm33OEEhYYRf6Qx6ugzMcCST9Dehd80sjOX0z6SbUNcW/81WA3fQZ4Gx5UCKy1rzRQRVN/GKwjP+S9TluJlu4Gf6Bsah8eFNN0LfTps2+rqa1mIEukqe7BHrUbx+64TuqAGvi/LvLrGsE5mQ1TNA1OPaTBefxkkT36qMHTz17cb+UaPnkU1ulFQM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <39D6CAD110CBBA4D856BF26456B82915@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e1e0f5c2-fd4d-43fe-d094-08d70a11f2ed
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Jul 2019 17:20:50.3797
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4703
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCBKdWwgMTYsIDIwMTkgYXQgMDc6MDQ6NTJQTSArMDIwMCwgTWljaGVsIETDpG56ZXIg
d3JvdGU6DQo+IE9uIDIwMTktMDctMTYgNjozNSBwLm0uLCBKYXNvbiBHdW50aG9ycGUgd3JvdGU6
DQo+ID4gT24gVHVlLCBKdWwgMTYsIDIwMTkgYXQgMDY6MzE6MDlQTSArMDIwMCwgTWljaGVsIETD
pG56ZXIgd3JvdGU6DQo+ID4+IE9uIDIwMTktMDctMTUgNzoyNSBwLm0uLCBKYXNvbiBHdW50aG9y
cGUgd3JvdGU6DQo+ID4+PiBPbiBNb24sIEp1bCAxNSwgMjAxOSBhdCAwNjo1MTowNlBNICswMjAw
LCBNaWNoZWwgRMOkbnplciB3cm90ZToNCj4gPj4+Pg0KPiA+Pj4+IFdpdGggYSBLQVNBTiBlbmFi
bGVkIGtlcm5lbCBidWlsdCBmcm9tIGFtZC1zdGFnaW5nLWRybS1uZXh0LCB0aGUNCj4gPj4+PiBh
dHRhY2hlZCB1c2UtYWZ0ZXItZnJlZSBpcyBwcmV0dHkgcmVsaWFibHkgZGV0ZWN0ZWQgZHVyaW5n
IGEgcGlnbGl0IGdwdSBydW4uDQo+ID4+Pg0KPiA+Pj4gRG9lcyB0aGlzIGJyYW5jaCB5b3UgYXJl
IHRlc3RpbmcgaGF2ZSB0aGUgaG1tLmdpdCBtZXJnZWQ/IEkgdGhpbmsgZnJvbQ0KPiA+Pj4gdGhl
IG5hbWUgaXQgZG9lcyBub3Q/DQo+ID4+DQo+ID4+IEluZGVlZCwgbm8uDQo+ID4+DQo+ID4+DQo+
ID4+PiBVc2UgYWZ0ZXIgZnJlZSdzIG9mIHRoaXMgbmF0dXJlIHdlcmUgc29tZXRoaW5nIHRoYXQg
d2FzIGZpeGVkIGluDQo+ID4+PiBobW0uZ2l0Li4NCj4gPj4+DQo+ID4+PiBJIGRvbid0IHNlZSBh
biBvYnZpb3VzIHdheSB5b3UgY2FuIGhpdCBzb21ldGhpbmcgbGlrZSB0aGlzIHdpdGggdGhlDQo+
ID4+PiBuZXcgY29kZSBhcnJhbmdlbWVudC4uDQo+ID4+DQo+ID4+IEkgdHJpZWQgbWVyZ2luZyB0
aGUgaG1tLWRldm1lbS1jbGVhbnVwLjQgY2hhbmdlc1swXSBpbnRvIG15IDUuMi55ICsNCj4gPj4g
ZHJtLW5leHQgZm9yIDUuMyBrZXJuZWwuIFdoaWxlIHRoZSByZXN1bHQgZGlkbid0IGhpdCB0aGUg
cHJvYmxlbSwgYWxsDQo+ID4+IEdMX0FNRF9waW5uZWRfbWVtb3J5IHBpZ2xpdCB0ZXN0cyBmYWls
ZWQsIHNvIEkgc3VzcGVjdCB0aGUgcHJvYmxlbSB3YXMNCj4gPj4gc2ltcGx5IGF2b2lkZWQgYnkg
bm90IGFjdHVhbGx5IGhpdHRpbmcgdGhlIEhNTSByZWxhdGVkIGZ1bmN0aW9uYWxpdHkuDQo+ID4+
DQo+ID4+IEl0J3MgcG9zc2libGUgdGhhdCBJIG1hZGUgYSBtaXN0YWtlIGluIG1lcmdpbmcgdGhl
IGNoYW5nZXMsIG9yIHRoYXQgSQ0KPiA+PiBtaXNzZWQgc29tZSBvdGhlciByZXF1aXJlZCBjaGFu
Z2VzLiBCdXQgaXQncyBhbHNvIHBvc3NpYmxlIHRoYXQgdGhlIEhNTQ0KPiA+PiBjaGFuZ2VzIGJy
b2tlIHRoZSBjb3JyZXNwb25kaW5nIHVzZXItcG9pbnRlciBmdW5jdGlvbmFsaXR5IGluIGFtZGdw
dS4NCj4gPiANCj4gPiBOb3Qgc3VyZSwgdGhpcyB3YXMgYWxsIFRlc3RlZCBieSB0aGUgQU1EIHRl
YW0gc28gaXQgc2hvdWxkIHdvcmssIEkNCj4gPiBob3BlLg0KPiANCj4gSXQgY2FuJ3QsIGR1ZSB0
byB0aGUgaXNzdWUgcG9pbnRlZCBvdXQgYnkgTGludXMgaW4gdGhlICJkcm0gcHVsbCBmb3INCj4g
NS4zLXJjMSIgdGhyZWFkOiBEUk1fQU1ER1BVX1VTRVJQVFIgc3RpbGwgZGVwZW5kcyBvbiBBUkNI
X0hBU19ITU0sIHdoaWNoDQo+IG5vIGxvbmdlciBleGlzdHMsIHNvIGl0IGNhbid0IGJlIGVuYWJs
ZWQuDQoNClNvbWVob3cgdGhhdCBtZXJnZSByZXNvbHV0aW9uIGdvdCBtaXNzZWQsIGJ1dCBJIHRo
aW5rIHRoZSBBTUQgZm9sa3MNCm11c3QgaGF2ZSBpbmNsdWRlZCBpdCB3aGVuIHRoZXkgZGlkIHRo
ZWlyIG1lcmdlICYgdGVzdC4NCg0KSmFzb24NCg==

