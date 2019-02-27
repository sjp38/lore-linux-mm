Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0A27C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:48:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C5B72184A
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:48:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="gyr+m8nx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C5B72184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D5998E0005; Wed, 27 Feb 2019 13:48:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05A9B8E0001; Wed, 27 Feb 2019 13:48:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3C798E0005; Wed, 27 Feb 2019 13:48:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE2468E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:48:33 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id u132so7812519oif.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:48:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=pcC0WodsyPtlkFlQ1r59TyEXiKb7vA1Ox4/dKw09grg=;
        b=ueEO5SvZY5rOi/EfccDcs89R4JfwgLjnsw3LVcyQVrD4X8I90dAFv7XYOy7kzLXqux
         jlZ3VJbRO5q5kzTSvBs0/MFZi8unsAR4ILGM+JC+NiLqDEQodpXPgrUCCKVJXoJPKZJ6
         g8UsKaY5oaentxCglcfDsHGHcndtqW0xdtS/t5bgfip24ba73DLammjwECDXZ2M+0h07
         QSNLILssFQ46JSXqrUaaZFutdxUaK7UuEx4G1VW5p0vxyXtPjuNHX6M2r34v5plPevdZ
         yIclyniJD4SPpFnNUMzlSkXxCi4CWYa2wVRhhwI7bdHVXQUY1VwhY71Y+zBGmFxesa+X
         p0gA==
X-Gm-Message-State: AHQUAuaKhBXwgNNbTmPOzMz1AYvPXVEO71Csi2KaqLrP8bvyjt1qXyQ4
	xdjrNibTeTGf6Nyx0rc/A6sAqeY/0H9gr7Zmo2r2xf40oVmVAl311wL/lKzLfP7RBvy9yok3wsb
	SnnMLuE6dKn/IUIpb0Q6IFk+/+QxcTRbkdRtylOrAbB4jn9PhNYz+b1KIPqufm08=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr3100481ota.229.1551293313270;
        Wed, 27 Feb 2019 10:48:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaFNLRMPCqDLlz90DKp68TEpu0hrvAMfeGuDwAmFgIZvOgMM7B91VVP1FzWuTP/GwmVTYaM
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr3100441ota.229.1551293312122;
        Wed, 27 Feb 2019 10:48:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551293312; cv=none;
        d=google.com; s=arc-20160816;
        b=Y2hInTvW3FIMp/P0C2KLEyhly4rSojMnZw3HgpWwJzGpgtWIzla22EMzhXFeXlMJVU
         C/Oo8Jiv9tYxwKr00opuE/xYDvg7ZZrSHQLVWAuNvQMegKWUyJFwquUARzTkPSO5BllM
         LiVO9HStmNjynqAEVsOjSRc3DeZex+ga5LJT9ljdLHfrP//yPymyGNvtBoChHtsaaktd
         Nech/S1rXhXsjnFwknFyWENajl+exzWdbqkciZdX9CSPP5e++1Myex4bSl4HhHeJS5C3
         d0amZGRDizDK5NJymcQuTtotMca+tXAOwPvhFGOzZaObkwEc3s/TP8sQrQll+U0w9l+Q
         HpUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=pcC0WodsyPtlkFlQ1r59TyEXiKb7vA1Ox4/dKw09grg=;
        b=GwosDGcAWfZYl0O7GnI2PxCi8f9FlC3t/vAjHRaeybBMESZ82xDRiTk+9aHvlQQeqY
         C6uLtDISqzRjol0EEHVJHCaAW5bjGj3qa0hkFTYzM2kttsWR2PwQQ/UBUyEwqMtk4Dzg
         lJXLyP5BG+Xg3ffM7GxW+YlQDkmdgniAdFbqEpGkuRsuQlnOg2azbTx73B8N2wJzI9Tc
         24Nhsvi+olLxRj25qmp8tBxJSgzJa6b7Z74LAMKoho2ZuGbwbQx29Y07QMiq1HT3I2AU
         2JKv2uRRKVbYXi0DTO+yeI06SJn2wfQ5fWkwFIxAZxZdWl/1hzn6yXlKL100DEtPv9tj
         FSMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=gyr+m8nx;
       spf=neutral (google.com: 40.107.81.87 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810087.outbound.protection.outlook.com. [40.107.81.87])
        by mx.google.com with ESMTPS id g7si6713962otp.306.2019.02.27.10.48.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 10:48:32 -0800 (PST)
Received-SPF: neutral (google.com: 40.107.81.87 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) client-ip=40.107.81.87;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=gyr+m8nx;
       spf=neutral (google.com: 40.107.81.87 is neither permitted nor denied by best guess record for domain of philip.yang@amd.com) smtp.mailfrom=Philip.Yang@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pcC0WodsyPtlkFlQ1r59TyEXiKb7vA1Ox4/dKw09grg=;
 b=gyr+m8nxGuHjCVcNfXZ9zudAiv/Abe6xtzGqAb7v7IswC+l4YiF7yYLwQPX04Nj+LA1+SJazDuHnAu8AtVX/ePhwapXqnBWHfxdmfiI895iw9//5JEJ0F1IJdEw6rwwnx1NH7/O1V8QAydA9X57sEMOfCZJmIXhkkBrOw14anUY=
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com (10.174.106.148) by
 DM5PR1201MB2555.namprd12.prod.outlook.com (10.172.91.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Wed, 27 Feb 2019 18:48:30 +0000
Received: from DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7]) by DM5PR1201MB0155.namprd12.prod.outlook.com
 ([fe80::5464:b0a9:e80e:b8c7%8]) with mapi id 15.20.1643.022; Wed, 27 Feb 2019
 18:48:30 +0000
From: "Yang, Philip" <Philip.Yang@amd.com>
To: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
	=?utf-8?B?TWljaGVsIETDpG56ZXI=?= <michel@daenzer.net>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: KASAN caught amdgpu / HMM use-after-free
Thread-Topic: KASAN caught amdgpu / HMM use-after-free
Thread-Index: AQHUzr5Iv9fZwgvZtkOvi9fDH0RyfqXzjl0AgABZOYD//7UigIAAW0yAgAAEjQA=
Date: Wed, 27 Feb 2019 18:48:30 +0000
Message-ID: <b81bd33a-0041-392e-2c85-19036fc1c91d@amd.com>
References: <e8466985-a66b-468b-5fff-6e743180da67@daenzer.net>
 <83fde7eb-abab-e770-efd5-89bc9c39fdff@amd.com>
 <c26fa310-38d1-acba-cf82-bc6dc2f782c0@daenzer.net>
 <35d7e134-6eef-9732-8ebf-83256e40eb65@amd.com>
 <BN6PR12MB18090BDFE1DD800785C5ED76F7740@BN6PR12MB1809.namprd12.prod.outlook.com>
In-Reply-To:
 <BN6PR12MB18090BDFE1DD800785C5ED76F7740@BN6PR12MB1809.namprd12.prod.outlook.com>
Accept-Language: en-ZA, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR0101CA0043.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:14::20) To DM5PR1201MB0155.namprd12.prod.outlook.com
 (2603:10b6:4:55::20)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Philip.Yang@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [165.204.55.251]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ac510608-6f5e-43e7-bad1-08d69ce42aa3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:DM5PR1201MB2555;
x-ms-traffictypediagnostic: DM5PR1201MB2555:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 1;DM5PR1201MB2555;20:ST78E47sIvkNFO92/LBz02KRvzlTtfItrLh9ExvRrNy8sHJZroeaofMRCBNpd2FmbWPet1MERO52625Hbm6d1i+lzcHocWVjnZCHL8l74ysxMUR7ID7zDD5Uv2/1RQbUXRuEMW2A4Z3XWdC1kBsm7sAlkUlyVBZpP1Slj6TmzOi2FM1rd/RvOufLVu9OQ5NBEYmkL6tTZDJo3EUL7cYymplyumOLjk7nj+I+Y7M88PrtQvXwpeKPArshGbQfWEMy
x-microsoft-antispam-prvs:
 <DM5PR1201MB25553136F9788FEEADD8F60AE6740@DM5PR1201MB2555.namprd12.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(366004)(136003)(39860400002)(189003)(199004)(52116002)(25786009)(72206003)(53546011)(229853002)(2906002)(102836004)(110136005)(3846002)(36756003)(7736002)(6116002)(316002)(6246003)(6436002)(386003)(6506007)(105586002)(14454004)(305945005)(31686004)(6512007)(4326008)(53936002)(93886005)(6306002)(106356001)(6486002)(68736007)(99286004)(486006)(86362001)(31696002)(256004)(81166006)(81156014)(54906003)(11346002)(8936002)(186003)(5660300002)(97736004)(476003)(71200400001)(71190400001)(2616005)(66066001)(8676002)(478600001)(76176011)(26005)(966005)(446003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR1201MB2555;H:DM5PR1201MB0155.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 tD/iJyKeBuP8JY6ZmGcj0UZXpSshhmqbqofo08TdxMcqg80uXNbJTlHcqUPd7JO1StzJMYgeFrzzqiGoerzVoDWJ/l8/wAIE4TwEYEX3Gl64nLRLhAs/S1WOIIsDGRaB18h9Vh8IhjbHcj3HnC2nsq98Verlh/yZ434Nj77gxM/stMkDwfSBExhhbtrebo412Cm0BHXrBCy7aNPGAyBSWEYZDwAYrAnbaK5HmkSIv68OFXClPlyr1KF8BmuCi0CmNk1g1DgWdH7JIPqdJAn7eKj7l6ZYyBsixr8KeD2Kwf8sRtOkZceiLH510ipZ3g/qVWp9Twht19nrOlgbATn3zG2wlZdNW+RCUjco/eAlkaZ/X6n4rJ2VaoLLzBs1lKiSJ8IrNbAbzRx49kqj8i0dLtNa02pDCfGhO10HVdLfwsQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2FDBB79ACD9146418B8BD5AB22E9D254@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ac510608-6f5e-43e7-bad1-08d69ce42aa3
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 18:48:29.7660
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR1201MB2555
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQWxleCwNCg0KUHVzaGVkLCB0aGFua3MuDQoNCm1tL2htbTogdXNlIHJlZmVyZW5jZSBjb3Vu
dGluZyBmb3IgSE1NIHN0cnVjdA0KDQpQaGlsaXANCg0KT24gMjAxOS0wMi0yNyAxOjMyIHAubS4s
IERldWNoZXIsIEFsZXhhbmRlciB3cm90ZToNCj4gR28gYWhlYWQgYW4gYXBwbHkgaXQgdG8gYW1k
LXN0YWdpbmctZHJtLW5leHQuwqAgSXQnbGwgbmF0dXJhbGx5IGZhbGwgb3V0IA0KPiB3aGVuIEkg
cmViYXNlIGl0Lg0KPiANCj4gQWxleA0KPiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4gKkZyb206KiBhbWQt
Z2Z4IDxhbWQtZ2Z4LWJvdW5jZXNAbGlzdHMuZnJlZWRlc2t0b3Aub3JnPiBvbiBiZWhhbGYgb2Yg
DQo+IFlhbmcsIFBoaWxpcCA8UGhpbGlwLllhbmdAYW1kLmNvbT4NCj4gKlNlbnQ6KiBXZWRuZXNk
YXksIEZlYnJ1YXJ5IDI3LCAyMDE5IDE6MDUgUE0NCj4gKlRvOiogTWljaGVsIETDpG56ZXI7IErD
qXLDtG1lIEdsaXNzZQ0KPiAqQ2M6KiBsaW51eC1tbUBrdmFjay5vcmc7IGFtZC1nZnhAbGlzdHMu
ZnJlZWRlc2t0b3Aub3JnDQo+ICpTdWJqZWN0OiogUmU6IEtBU0FOIGNhdWdodCBhbWRncHUgLyBI
TU0gdXNlLWFmdGVyLWZyZWUNCj4gYW1kLXN0YWdpbmctZHJtLW5leHQgd2lsbCByZWJhc2UgdG8g
a2VybmVsIDUuMSB0byBwaWNrdXAgdGhpcyBmaXgNCj4gYXV0b21hdGljYWxseS4gQXMgYSBzaG9y
dC10ZXJtIHdvcmthcm91bmQsIHBsZWFzZSBjaGVycnktcGljayB0aGlzIGZpeA0KPiBpbnRvIHlv
dXIgbG9jYWwgcmVwb3NpdG9yeS4NCj4gDQo+IFJlZ2FyZHMsDQo+IFBoaWxpcA0KPiANCj4gT24g
MjAxOS0wMi0yNyAxMjozMyBwLm0uLCBNaWNoZWwgRMOkbnplciB3cm90ZToNCj4+IE9uIDIwMTkt
MDItMjcgNjoxNCBwLm0uLCBZYW5nLCBQaGlsaXAgd3JvdGU6DQo+Pj4gSGkgTWljaGVsLA0KPj4+
DQo+Pj4gWWVzLCBJIGZvdW5kIHRoZSBzYW1lIGlzc3VlIGFuZCB0aGUgYnVnIGhhcyBiZWVuIGZp
eGVkIGJ5IEplcm9tZToNCj4+Pg0KPj4+IDg3NmI0NjIxMjBhYSBtbS9obW06IHVzZSByZWZlcmVu
Y2UgY291bnRpbmcgZm9yIEhNTSBzdHJ1Y3QNCj4+Pg0KPj4+IFRoZSBmaXggaXMgb24gaG1tLWZv
ci01LjEgYnJhbmNoLCBJIGNoZXJyeS1waWNrIGl0IGludG8gbXkgbG9jYWwgYnJhbmNoDQo+Pj4g
dG8gd29ya2Fyb3VuZCB0aGUgaXNzdWUuDQo+PiANCj4+IFBsZWFzZSBwdXNoIGl0IHRvIGFtZC1z
dGFnaW5nLWRybS1uZXh0LCBzbyB0aGF0IG90aGVycyBkb24ndCBydW4gaW50bw0KPj4gdGhlIGlz
c3VlIGFzIHdlbGwuDQo+PiANCj4+IA0KPiBfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXw0KPiBhbWQtZ2Z4IG1haWxpbmcgbGlzdA0KPiBhbWQtZ2Z4QGxpc3Rz
LmZyZWVkZXNrdG9wLm9yZw0KPiBodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2FtZC1nZngNCg==

