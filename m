Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDA2BC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 17:57:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5073E204EC
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 17:57:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="GrgU7Gzr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5073E204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B49096B0003; Tue, 30 Apr 2019 13:57:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF9B96B0005; Tue, 30 Apr 2019 13:57:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99AD96B0006; Tue, 30 Apr 2019 13:57:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6B26B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 13:57:19 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id z6so5859075oid.8
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 10:57:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=KGMOo9hxDN2TGCpphgofoTTq2FGSY18AP6DIbhxAE34=;
        b=N+l0TezlD4VaqOvUFql90d8+bqID+Fdh0aHV57Ry3oeLNgeDYPBPVXHPTagW4ay+th
         MORkbA/l78NDLtrmTaWkEr11X52MkapXP9QCRg1w3O81B2W/hlvxw/kYeTdFF5RYYfQX
         Fr72bY1HFRMrMDSQ6GVv8+jM9nTmgA3O/+8i3BlOztbzOwUi0MpwBOLHLw02HouB8fPd
         lBHFzXW7FXsqAVzWNtiXShYxIbQxPwUTgQ4ATSXrA2/Bibz/a9VvTfxYldStFlzlLgPK
         sqoZJ2Fgl/7IOYrPLhgcvV29AytW7zidKtXuqaQ4CShWWCPioQ2bF3NsHBNvlBmipRXG
         qluQ==
X-Gm-Message-State: APjAAAWPV9pX5/aKzN8I1N2bv2i75NKvwZnuIcKzFWsSYnp57zKJs0H2
	Qub4kjV5JbJdyBYqXU9cKGpj/1Ys0BWjqCk4DgeE4rN+lyrx0+WZ9YRu7lLVXxPgUV9QOEqdaGq
	AVtvcpxAnyAfwy0AHHWEqhJq5ASVNiirTLK1BNXDsuRBHsnwz/9da0TV0ICxUyeY=
X-Received: by 2002:aca:3556:: with SMTP id c83mr4036040oia.89.1556647038931;
        Tue, 30 Apr 2019 10:57:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiSH2ocUXNLhPjQIcx+v3CcTPHujhnwjhTOUKiujgpOM8Aqkmk7hXVYefk/1QdklOtYJTr
X-Received: by 2002:aca:3556:: with SMTP id c83mr4036002oia.89.1556647037970;
        Tue, 30 Apr 2019 10:57:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556647037; cv=none;
        d=google.com; s=arc-20160816;
        b=toy5Zc/TFl/EnXP3bxk2xDZc87i0/BoZXjV6qQdl3+o5f6HtJpD9sdvajTuyPnkppE
         YrVZ/nTeJb1hC2HJMXKtVnwFzgvzttYJeWkV6q758BkHTDl4C/3kCEvffuPQ7qeH1oEc
         hZG9Lj1D6uRb7Plk2+i8lo9Vv9WGhwYHWr2zVSEU/46AeLYs2LiwpisJrKRDKnSMaFmK
         rai/qYDWx8XyyAXodfSt2z8uKxBlJn7KaGd7QYiGyc8FKkbLi9NcygWeFr/4ZRG5Y1Ua
         gmOWsbDfYy8dkB5CGVyECWE/0W+hU0W+52zakqJEjGA0aF58GkAgomYX8hwfDtFoht7z
         LBhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=KGMOo9hxDN2TGCpphgofoTTq2FGSY18AP6DIbhxAE34=;
        b=J1KqrhpilIYBK+XBzGSEPmE8hGmsNlNLqMP4EhuL/M3EfDAy3BULWpf+yQg6mjPknj
         kF53T3xtMOyHZdnaAW3otWZYQdV0pt2M1Eimk+yQYeUr7KAeLCf305or4myiQC45vs4e
         auiMn/d4MoA7FkHHgkfh4k0YN6sJcreQgQlJe4s1i3tFTyOEyzKHb16sTu/37nV3DO2X
         QbqXegjmQhXqwi4vGCPRVW3IKDWDo7SJow1bk3R4taxUdz6fpoaQx/yhqrEjVp3/0KMC
         g/nIZG35asKa6wXklU2U7GZh9IBEHLcv9TcuHSMzB75t64RqSUHSxa759+EGlU6w7lsa
         HUQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=GrgU7Gzr;
       spf=neutral (google.com: 40.107.81.78 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-eopbgr810078.outbound.protection.outlook.com. [40.107.81.78])
        by mx.google.com with ESMTPS id n25si18800989otk.139.2019.04.30.10.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Apr 2019 10:57:17 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.81.78 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.81.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=GrgU7Gzr;
       spf=neutral (google.com: 40.107.81.78 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KGMOo9hxDN2TGCpphgofoTTq2FGSY18AP6DIbhxAE34=;
 b=GrgU7Gzr6rD3u2XxX//FKLycBUmC2Bx7+ZJDh4UToM1Wfs1WllsVD0vpVCG/jjrlwKrhGDrlfjHAgt2aJEHIfb+4zrRker9/LdsWRbSghUkzbt7NMb2r8TfCj5Ddowg6IPwCXMufrA1317YaYcb00GpwIVeA4OQUZdPTSqZ6eb8=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3494.namprd12.prod.outlook.com (20.178.196.220) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.15; Tue, 30 Apr 2019 17:57:12 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7%4]) with mapi id 15.20.1835.010; Tue, 30 Apr 2019
 17:57:12 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Andrey Konovalov <andreyknvl@google.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-media@vger.kernel.org"
	<linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>
CC: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino
	<vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland
	<mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook
	<keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>,
	"Kuehling@google.com" <Kuehling@google.com>, "Deucher@google.com"
	<Deucher@google.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>,
	"Koenig@google.com" <Koenig@google.com>, "Koenig, Christian"
	<Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Alex Williamson
	<alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, Dmitry
 Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy
 Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana
 Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley
	<Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin
 Murphy <robin.murphy@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, Luc
 Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin
	<Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy
	<Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v14 12/17] drm/radeon, arm64: untag user pointers
Thread-Topic: [PATCH v14 12/17] drm/radeon, arm64: untag user pointers
Thread-Index: AQHU/1g/U8dIq5nkhEqd9cb6Xh0v56ZU/Y2A
Date: Tue, 30 Apr 2019 17:57:12 +0000
Message-ID: <bfe5e11e-6dc4-352f-57eb-d527f965a2ef@amd.com>
References: <cover.1556630205.git.andreyknvl@google.com>
 <9a50ef07d927cbccd9620894bda825e551168c3d.1556630205.git.andreyknvl@google.com>
In-Reply-To:
 <9a50ef07d927cbccd9620894bda825e551168c3d.1556630205.git.andreyknvl@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YQBPR0101CA0032.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00::45) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: df48562d-e8cb-453d-9fd3-08d6cd95455a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR12MB3494;
x-ms-traffictypediagnostic: BYAPR12MB3494:
x-microsoft-antispam-prvs:
 <BYAPR12MB34949EFAD9F4EA1EA885C289923A0@BYAPR12MB3494.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 00235A1EEF
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(376002)(366004)(396003)(136003)(346002)(199004)(189003)(6512007)(6436002)(53936002)(81156014)(81166006)(8936002)(65826007)(6506007)(36756003)(8676002)(53546011)(386003)(97736004)(7416002)(6246003)(7406005)(26005)(2501003)(5660300002)(102836004)(64126003)(76176011)(256004)(14444005)(2906002)(31696002)(2201001)(66946007)(229853002)(66446008)(64756008)(66556008)(66476007)(71190400001)(86362001)(71200400001)(73956011)(486006)(65806001)(65956001)(446003)(66066001)(11346002)(316002)(2616005)(476003)(68736007)(6486002)(31686004)(25786009)(52116002)(99286004)(54906003)(14454004)(72206003)(4326008)(478600001)(110136005)(3846002)(58126008)(305945005)(7736002)(6116002)(186003)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3494;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 6nnnZ/u6xr1JXr6Nj7I1N2kzpDbGKjEmjnWSIc/x56iEXiclrQpemMYVSzx5viG4KsCPgAF0cHpwmKumTrjCA77FQvvny29TUHoLoe6vqloMyRgr5LfovFuMsCigj9yb6t5569mYIwY1MmJLrLGIBbKL/uvh/mP/wW4v6EJr8BKk/YcW1lomju+jAjMKFUWcCD3boecVehoFnrYEtNsjdeoCOKUGv6zeiGvXc/1JKhPr24/4BRHjlFgqtXa0Mw7z+YsBAiWjDiNwa/gAyuDDaN2Fvat4/xLlXxhKURv/Lg13P2nyxOItAWbIYAZHVNuE6H4z2HOrUPHngLiJHQ+gwu3JHMUaTpBtGxREZa+h5EpBYnMxK0WLZsZAuLxmCERKh+/dY/YybIwK/uvAgY/6B7IXMeZs1MAk54ASCu4wb1Q=
Content-Type: text/plain; charset="utf-8"
Content-ID: <ABB2DFC9857E044B9516BE64C1265F1E@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: df48562d-e8cb-453d-9fd3-08d6cd95455a
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Apr 2019 17:57:12.1585
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3494
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNC0zMCA5OjI1IGEubS4sIEFuZHJleSBLb25vdmFsb3Ygd3JvdGU6DQo+IFtDQVVU
SU9OOiBFeHRlcm5hbCBFbWFpbF0NCj4NCj4gVGhpcyBwYXRjaCBpcyBhIHBhcnQgb2YgYSBzZXJp
ZXMgdGhhdCBleHRlbmRzIGFybTY0IGtlcm5lbCBBQkkgdG8gYWxsb3cgdG8NCj4gcGFzcyB0YWdn
ZWQgdXNlciBwb2ludGVycyAod2l0aCB0aGUgdG9wIGJ5dGUgc2V0IHRvIHNvbWV0aGluZyBlbHNl
IG90aGVyDQo+IHRoYW4gMHgwMCkgYXMgc3lzY2FsbCBhcmd1bWVudHMuDQo+DQo+IHJhZGVvbl90
dG1fdHRfcGluX3VzZXJwdHIoKSB1c2VzIHByb3ZpZGVkIHVzZXIgcG9pbnRlcnMgZm9yIHZtYQ0K
PiBsb29rdXBzLCB3aGljaCBjYW4gb25seSBieSBkb25lIHdpdGggdW50YWdnZWQgcG9pbnRlcnMu
IFRoaXMgcGF0Y2gNCj4gdW50YWdzIHVzZXIgcG9pbnRlcnMgd2hlbiB0aGV5IGFyZSBiZWluZyBz
ZXQgaW4NCj4gcmFkZW9uX3R0bV90dF9waW5fdXNlcnB0cigpLg0KPg0KPiBJbiBhbWRncHVfZ2Vt
X3VzZXJwdHJfaW9jdGwoKSBhbiBNTVUgbm90aWZpZXIgaXMgc2V0IHVwIHdpdGggYSAodGFnZ2Vk
KQ0KPiB1c2Vyc3BhY2UgcG9pbnRlci4gVGhlIHVudGFnZ2VkIGFkZHJlc3Mgc2hvdWxkIGJlIHVz
ZWQgc28gdGhhdCBNTVUNCj4gbm90aWZpZXJzIGZvciB0aGUgdW50YWdnZWQgYWRkcmVzcyBnZXQg
Y29ycmVjdGx5IG1hdGNoZWQgdXAgd2l0aCB0aGUgcmlnaHQNCj4gQk8uIFRoaXMgcGF0Y2ggdW50
YWdzIHVzZXIgcG9pbnRlcnMgaW4gcmFkZW9uX2dlbV91c2VycHRyX2lvY3RsKCkuDQo+DQo+IFNp
Z25lZC1vZmYtYnk6IEFuZHJleSBLb25vdmFsb3YgPGFuZHJleWtudmxAZ29vZ2xlLmNvbT4NCj4g
LS0tDQo+ICAgZHJpdmVycy9ncHUvZHJtL3JhZGVvbi9yYWRlb25fZ2VtLmMgfCAyICsrDQo+ICAg
ZHJpdmVycy9ncHUvZHJtL3JhZGVvbi9yYWRlb25fdHRtLmMgfCAyICstDQo+ICAgMiBmaWxlcyBj
aGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkNCj4NCj4gZGlmZiAtLWdpdCBh
L2RyaXZlcnMvZ3B1L2RybS9yYWRlb24vcmFkZW9uX2dlbS5jIGIvZHJpdmVycy9ncHUvZHJtL3Jh
ZGVvbi9yYWRlb25fZ2VtLmMNCj4gaW5kZXggNDQ2MTdkZWM4MTgzLi45MGViNzhmYjVlYjIgMTAw
NjQ0DQo+IC0tLSBhL2RyaXZlcnMvZ3B1L2RybS9yYWRlb24vcmFkZW9uX2dlbS5jDQo+ICsrKyBi
L2RyaXZlcnMvZ3B1L2RybS9yYWRlb24vcmFkZW9uX2dlbS5jDQo+IEBAIC0yOTEsNiArMjkxLDgg
QEAgaW50IHJhZGVvbl9nZW1fdXNlcnB0cl9pb2N0bChzdHJ1Y3QgZHJtX2RldmljZSAqZGV2LCB2
b2lkICpkYXRhLA0KPiAgICAgICAgICB1aW50MzJfdCBoYW5kbGU7DQo+ICAgICAgICAgIGludCBy
Ow0KPg0KPiArICAgICAgIGFyZ3MtPmFkZHIgPSB1bnRhZ2dlZF9hZGRyKGFyZ3MtPmFkZHIpOw0K
PiArDQo+ICAgICAgICAgIGlmIChvZmZzZXRfaW5fcGFnZShhcmdzLT5hZGRyIHwgYXJncy0+c2l6
ZSkpDQo+ICAgICAgICAgICAgICAgICAgcmV0dXJuIC1FSU5WQUw7DQo+DQo+IGRpZmYgLS1naXQg
YS9kcml2ZXJzL2dwdS9kcm0vcmFkZW9uL3JhZGVvbl90dG0uYyBiL2RyaXZlcnMvZ3B1L2RybS9y
YWRlb24vcmFkZW9uX3R0bS5jDQo+IGluZGV4IDk5MjBhNmZjMTFiZi4uZGNlNzIyYzQ5NGMxIDEw
MDY0NA0KPiAtLS0gYS9kcml2ZXJzL2dwdS9kcm0vcmFkZW9uL3JhZGVvbl90dG0uYw0KPiArKysg
Yi9kcml2ZXJzL2dwdS9kcm0vcmFkZW9uL3JhZGVvbl90dG0uYw0KPiBAQCAtNzQyLDcgKzc0Miw3
IEBAIGludCByYWRlb25fdHRtX3R0X3NldF91c2VycHRyKHN0cnVjdCB0dG1fdHQgKnR0bSwgdWlu
dDY0X3QgYWRkciwNCj4gICAgICAgICAgaWYgKGd0dCA9PSBOVUxMKQ0KPiAgICAgICAgICAgICAg
ICAgIHJldHVybiAtRUlOVkFMOw0KPg0KPiAtICAgICAgIGd0dC0+dXNlcnB0ciA9IGFkZHI7DQo+
ICsgICAgICAgZ3R0LT51c2VycHRyID0gdW50YWdnZWRfYWRkcihhZGRyKTsNCg0KRG9pbmcgdGhp
cyBoZXJlIHNlZW1zIHVubmVjZXNzYXJ5LCBiZWNhdXNlIHlvdSBhbHJlYWR5IHVudGFnZ2VkIHRo
ZSANCmFkZHJlc3MgaW4gdGhlIG9ubHkgY2FsbGVyIG9mIHRoaXMgZnVuY3Rpb24gaW4gcmFkZW9u
X2dlbV91c2VycHRyX2lvY3RsLiANClRoZSBjaGFuZ2UgdGhlcmUgd2lsbCBhZmZlY3QgYm90aCB0
aGUgdXNlcnB0ciBhbmQgTU1VIG5vdGlmaWVyIHNldHVwIGFuZCANCm1ha2VzIHN1cmUgdGhhdCBi
b3RoIGFyZSBpbiBzeW5jLCB1c2luZyB0aGUgc2FtZSB1bnRhZ2dlZCBhZGRyZXNzLg0KDQpSZWdh
cmRzLA0KIMKgIEZlbGl4DQoNCg0KPiAgICAgICAgICBndHQtPnVzZXJtbSA9IGN1cnJlbnQtPm1t
Ow0KPiAgICAgICAgICBndHQtPnVzZXJmbGFncyA9IGZsYWdzOw0KPiAgICAgICAgICByZXR1cm4g
MDsNCj4gLS0NCj4gMi4yMS4wLjU5My5nNTExZWMzNDVlMTgtZ29vZw0KPg0K

