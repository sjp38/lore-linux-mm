Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 515D5C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC01A208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 16:56:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="mTC4ddt/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC01A208C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A1988E0002; Mon, 17 Jun 2019 12:56:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 752088E0001; Mon, 17 Jun 2019 12:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6198B8E0002; Mon, 17 Jun 2019 12:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1242A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:56:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so17172193edd.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:56:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:nodisclaimer:content-id
         :content-transfer-encoding:mime-version;
        bh=/NluDOww/9QtED5RypDgBZ8QjDmwGLivZAqJWjCsam0=;
        b=JVVzoUMIbpOdiHg32Kvh8blPXN6iZPK8E4HUatTawsUCbkCqb0SYEvZs267GQKHaVR
         ccjNy4M/WZzMekmpF+Wp1LjVwWIVqJ+apbnqc3nXBBISMahbmFRl3mfO1HCZkzL2jnP+
         bZOiEuEWU9KNlpC2+uGhX2YntFaxX0Lz9hi4dd26Dj98Uwgx5cVMcg2W/pwe3Hhn+AKy
         PnOEUDjCzEP/y1ph9uApYDHS4lznIaTUre1ax6Hnvg9+xMQpoU/d9CMyPI4ecPMYmP/a
         k1uC0UffNPovNQzShkXw6HAen6OAtXJ7VNi5C4cnEoIpIua/AE4FLoQ3eFdHYIsCGFFm
         lJYQ==
X-Gm-Message-State: APjAAAXMSF2BZZ09LMOv7MAj1LL6XIf9mCyxknK8bn18Ym/jQ5Aa33lw
	jIn8obXO5MtnY6EyFMumKdgzCu12so8QlcJ1qQfy/nGg0rRf2ofne6/maN/Bm9m4KMMAeUrzetR
	IsCmUP6+FmaR2LKSLQdEkZSCLAxZo7MZtcS2bTbhNDei+j2oHPdKhl++O818CTBY1wQ==
X-Received: by 2002:a17:906:c106:: with SMTP id h6mr49492321ejz.112.1560790601524;
        Mon, 17 Jun 2019 09:56:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypV2+NZ94++BNiqukGsnX7QK+IlSVdJvHVD8HVuXycbCFPUTNKrp751p+jKfBdt1zG0ea+
X-Received: by 2002:a17:906:c106:: with SMTP id h6mr49492280ejz.112.1560790600801;
        Mon, 17 Jun 2019 09:56:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560790600; cv=none;
        d=google.com; s=arc-20160816;
        b=qP+dXV+f27n3u8Mu/FTMUC9PZmKdCd8UX0p8LjjhjXw5eNCc4veVCQUQ78nP3Hq/EB
         Pl4a88ZQTJYU4Ps+Luc0B4W6pw+4Giy5GQoRbza9X/Hlxcv8qGfqVp8/blvLqvg/5Ryw
         tkgCcqM9R4KNXpPGlQoiQiEhos+q8g9A9GEPRDeK5Yu19v2osepDNPnDVpI8BEqDHzq1
         HPvSG9HQijKlZCBxERQO7Ewsr8HkvtxwCi9yrMZnkOmw1OJ8V8lB9lKa2oDPF/McEPun
         +Eo4oKAr0oD7B5tSwlkz8CkcrCRyMqZ1ZNyz+c1gIDywrRDcNht94h6GRtVU9U/EC7E7
         YMbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:nodisclaimer
         :user-agent:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from
         :dkim-signature;
        bh=/NluDOww/9QtED5RypDgBZ8QjDmwGLivZAqJWjCsam0=;
        b=AqanQmLxY1xI6x/ygZhmijLCNbd6WE8Aeg78cLgiPAs9vVef5eoIlrAlR+LzQthVpT
         bX3Q3g6GCdXHAbsLg2opl48qI05tB7BD6lAgHEivwcbBeREk4Xnfr4idvCOrv2NxF73o
         Kcrn3TQq5ktYBqY1Fhhbfu4ImHSAmehiPH5FAIckdhKOFKuOmlimvq/bnfwaClFbEuyQ
         vIA1vVDDWFIOzC7bwkOwQ6VyUVSzo6BwhDwSRRuV/aeKcZa0HlN8oo9r8cnKaPYsX8+2
         2mJGZE6pOZWT6DVfqYC6aBexGVZna3JYlCPkzCZZGa3vZdi+7lZ9VLhaiftEuidLIgik
         UGMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b="mTC4ddt/";
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.51 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140051.outbound.protection.outlook.com. [40.107.14.51])
        by mx.google.com with ESMTPS id b24si8593453ede.402.2019.06.17.09.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 09:56:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.51 as permitted sender) client-ip=40.107.14.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector2-armh-onmicrosoft-com header.b="mTC4ddt/";
       spf=pass (google.com: domain of szabolcs.nagy@arm.com designates 40.107.14.51 as permitted sender) smtp.mailfrom=Szabolcs.Nagy@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector2-armh-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/NluDOww/9QtED5RypDgBZ8QjDmwGLivZAqJWjCsam0=;
 b=mTC4ddt/iuoTJOn9P7MI1uGLYpakoEe+cfGYzfVX2kaRn80xUBtMsWUS49GjE4YWG7n5GWxqX7lZ47Akttx2hI1kJSCYe3XopCJA/NpArAkJtzv3wRERFkqNWWpgTe2kFHV7E7lFfpn22YEpvOO0jitq9eKfD35/FS4xqtPxGOE=
Received: from AM5PR0801MB1763.eurprd08.prod.outlook.com (10.169.247.17) by
 AM5PR0801MB1699.eurprd08.prod.outlook.com (10.169.247.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Mon, 17 Jun 2019 16:56:39 +0000
Received: from AM5PR0801MB1763.eurprd08.prod.outlook.com
 ([fe80::9987:96a6:6dd9:f4a2]) by AM5PR0801MB1763.eurprd08.prod.outlook.com
 ([fe80::9987:96a6:6dd9:f4a2%4]) with mapi id 15.20.1987.014; Mon, 17 Jun 2019
 16:56:39 +0000
From: Szabolcs Nagy <Szabolcs.Nagy@arm.com>
To: Catalin Marinas <Catalin.Marinas@arm.com>, Andrey Konovalov
	<andreyknvl@google.com>
CC: nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Vincenzo
 Frascino <Vincenzo.Frascino@arm.com>, Will Deacon <Will.Deacon@arm.com>, Mark
 Rutland <Mark.Rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling
	<Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab
	<mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, Alex
 Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave P Martin
	<Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh
	<enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig
	<hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany
	<kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith
	<Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan
	<Ruben.Ayrapetyan@arm.com>, Robin Murphy <Robin.Murphy@arm.com>, Kevin
 Brodsky <Kevin.Brodsky@arm.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control the
 tagged user addresses ABI
Thread-Topic: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Thread-Index: AQHVIRQaew9kvIS1Ckaj+pLQDxCqx6af5s2AgAAyS4A=
Date: Mon, 17 Jun 2019 16:56:38 +0000
Message-ID: <fdf49115-2167-af8b-6078-48ac571f5aed@arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <20190617135636.GC1367@arrakis.emea.arm.com>
In-Reply-To: <20190617135636.GC1367@arrakis.emea.arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
x-originating-ip: [217.140.106.49]
x-clientproxiedby: LO2P265CA0333.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a4::33) To AM5PR0801MB1763.eurprd08.prod.outlook.com
 (2603:10a6:203:3b::17)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Szabolcs.Nagy@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 815c0a5d-ca3a-4da2-0285-08d6f344c3b1
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:AM5PR0801MB1699;
x-ms-traffictypediagnostic: AM5PR0801MB1699:
nodisclaimer: True
x-microsoft-antispam-prvs:
 <AM5PR0801MB16991563AA1F4801EE00DD29EDEB0@AM5PR0801MB1699.eurprd08.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(136003)(376002)(396003)(346002)(199004)(189003)(14454004)(8936002)(305945005)(7736002)(6512007)(54906003)(36756003)(110136005)(3846002)(2906002)(64126003)(65826007)(6436002)(81166006)(7416002)(6486002)(8676002)(476003)(229853002)(486006)(446003)(71190400001)(71200400001)(11346002)(2616005)(6116002)(68736007)(44832011)(31686004)(25786009)(4326008)(81156014)(66556008)(66476007)(6246003)(66446008)(64756008)(256004)(66946007)(316002)(58126008)(31696002)(72206003)(478600001)(99286004)(102836004)(53546011)(6506007)(386003)(186003)(26005)(5660300002)(76176011)(52116002)(73956011)(86362001)(66066001)(65956001)(65806001)(53936002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM5PR0801MB1699;H:AM5PR0801MB1763.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 m1NHKP05ubT3GY4iHJWeLbp6cbl4CcWI0TTV1gGwSxDxMxdWYegH9gGiumLcaEXSoGIjNK67JSY4bNtoglFctVNIg6O2TyNBMqDA+0rehgsICCbSytwvDcn2g5/ql0+Sn0u6q3GwJrqtx1L0be2KFdVe1nRwglzLdlubEdZ5SIAGwHSdheTrRVEpOZLqabc8QUrJ77fhsGeW8wb6tDwdPZXrdE5J8BLZO2KYmI/DnOzU4JA/1NILAnERVbAt6HO6whub6o97OC/261TFA7+pb4EdJtvdvT6lkFZeE9ThtsDGxbx3E08YiPHxErosfDOSfs8IxTqCKPkVMZZM1kyqu3qbl+pvRvYiT88C8Jt+bIYmIrv0GA5dHasKmdpoIeo4MNrT1BqZQdaP+m3F86V+LbzQBShcAa/1bXD5fTGmyPc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <6EB5105BE008A9488F6CD71841425FF5@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 815c0a5d-ca3a-4da2-0285-08d6f344c3b1
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 16:56:38.9960
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Szabolcs.Nagy@arm.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM5PR0801MB1699
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMTcvMDYvMjAxOSAxNDo1NiwgQ2F0YWxpbiBNYXJpbmFzIHdyb3RlOg0KPiBPbiBXZWQsIEp1
biAxMiwgMjAxOSBhdCAwMTo0MzoyMFBNICswMjAwLCBBbmRyZXkgS29ub3ZhbG92IHdyb3RlOg0K
Pj4gRnJvbTogQ2F0YWxpbiBNYXJpbmFzIDxjYXRhbGluLm1hcmluYXNAYXJtLmNvbT4NCj4+DQo+
PiBJdCBpcyBub3QgZGVzaXJhYmxlIHRvIHJlbGF4IHRoZSBBQkkgdG8gYWxsb3cgdGFnZ2VkIHVz
ZXIgYWRkcmVzc2VzIGludG8NCj4+IHRoZSBrZXJuZWwgaW5kaXNjcmltaW5hdGVseS4gVGhpcyBw
YXRjaCBpbnRyb2R1Y2VzIGEgcHJjdGwoKSBpbnRlcmZhY2UNCj4+IGZvciBlbmFibGluZyBvciBk
aXNhYmxpbmcgdGhlIHRhZ2dlZCBBQkkgd2l0aCBhIGdsb2JhbCBzeXNjdGwgY29udHJvbA0KPj4g
Zm9yIHByZXZlbnRpbmcgYXBwbGljYXRpb25zIGZyb20gZW5hYmxpbmcgdGhlIHJlbGF4ZWQgQUJJ
IChtZWFudCBmb3INCj4+IHRlc3RpbmcgdXNlci1zcGFjZSBwcmN0bCgpIHJldHVybiBlcnJvciBj
aGVja2luZyB3aXRob3V0IHJlY29uZmlndXJpbmcNCj4+IHRoZSBrZXJuZWwpLiBUaGUgQUJJIHBy
b3BlcnRpZXMgYXJlIGluaGVyaXRlZCBieSB0aHJlYWRzIG9mIHRoZSBzYW1lDQo+PiBhcHBsaWNh
dGlvbiBhbmQgZm9yaygpJ2VkIGNoaWxkcmVuIGJ1dCBjbGVhcmVkIG9uIGV4ZWN2ZSgpLg0KPj4N
Cj4+IFRoZSBQUl9TRVRfVEFHR0VEX0FERFJfQ1RSTCB3aWxsIGJlIGV4cGFuZGVkIGluIHRoZSBm
dXR1cmUgdG8gaGFuZGxlDQo+PiBNVEUtc3BlY2lmaWMgc2V0dGluZ3MgbGlrZSBpbXByZWNpc2Ug
dnMgcHJlY2lzZSBleGNlcHRpb25zLg0KPj4NCj4+IFNpZ25lZC1vZmYtYnk6IENhdGFsaW4gTWFy
aW5hcyA8Y2F0YWxpbi5tYXJpbmFzQGFybS5jb20+DQo+IA0KPiBBIHF1ZXN0aW9uIGZvciB0aGUg
dXNlci1zcGFjZSBmb2xrOiBpZiBhbiBhcHBsaWNhdGlvbiBvcHRzIGluIHRvIHRoaXMNCj4gQUJJ
LCB3b3VsZCB5b3Ugd2FudCB0aGUgc2lnY29udGV4dC5mYXVsdF9hZGRyZXNzIGFuZC9vciBzaWdp
bmZvLnNpX2FkZHINCj4gdG8gY29udGFpbiB0aGUgdGFnPyBXZSBjdXJyZW50bHkgY2xlYXIgaXQg
ZWFybHkgaW4gdGhlIGFybTY0IGVudHJ5LlMgYnV0DQo+IHdlIGNvdWxkIGZpbmQgYSB3YXkgdG8g
cGFzcyBpdCBkb3duIGlmIG5lZWRlZC4NCg0KdG8gbWUgaXQgbWFrZXMgc2Vuc2UgdG8ga2VlcCB0
aGUgdGFnIGluIHNpX2FkZHIgLyBmYXVsdF9hZGRyZXNzLg0KDQpidXQgaSBkb24ndCBrbm93IGlu
IGRldGFpbCBob3cgdGhvc2UgZmllbGRzIGFyZSB1c2VkIGN1cnJlbnRseS4NCg0Ka2VlcGluZyB0
aGUgdGFnIGlzIGNlcnRhaW5seSB1c2VmdWwgZm9yIE1URSB0byBkZWJ1ZyB3cm9uZyB0YWcNCmZh
aWx1cmVzIHVubGVzcyB0aGVyZSBpcyBhIHNlcGFyYXRlIG1lY2hhbmlzbSBmb3IgdGhhdC4NCg0K

