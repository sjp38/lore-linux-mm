Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B200FC5B578
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C7BC21852
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 21:03:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="Tlcu+sif"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C7BC21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D93A68E0022; Wed,  3 Jul 2019 17:03:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D43828E0019; Wed,  3 Jul 2019 17:03:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BBE008E0022; Wed,  3 Jul 2019 17:03:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCDC8E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 17:03:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q26so4644888qtr.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 14:03:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=cou+QGq/6QrzCUvbcpEGYduHx74lUtRh7TlfmoWpawY=;
        b=rE8/n/0AcupidfnpyD1fsNQNCCUJ1orxI7xfYVQzxIRbqmLp2CzV9kFczjIBmP896f
         bgjVqjZJeDFyDZdBt2XTkX3rlOh6LxsYQMHWkatfjz9KNP+5XasUA2SJlHj/dRkHXaSW
         mbpbQde0e1lmpq1wfi7iXU/vh73hsw1zwvvD/UvYenPh+HgiXcr3GCXwGyCLpBVErycQ
         ryWc4To0dQoAvlH9/uVr/RJ4uZ9sjs2EJwolArkRd7dht+2WnqYThOYHkSOJDPNmjmhZ
         w8IBz7cdLAmwCoC6kRK3dzmyVWt2sl7IXe7LcG2cNbifTpw/8fzYOxBFBGnAPTMeFBL9
         jCMQ==
X-Gm-Message-State: APjAAAXkXKUsyJPWCDKFwaNfecYOD7av/1RZGroTeDEadkrQiWUsb4Fr
	NnMYIl2bq2Ik5XVTHyxkrjIbETVe9sWbR9SBDvLMNoJwOmcrj2J7KyEMm/hh3tByO+MDOMI2Lm5
	nVlSqyBkIRESmGnCBgQ5mYmQ0FUSq6RtxL+vhchPQ6IGrlJvhuT5uulksJfdE9L4=
X-Received: by 2002:a37:490c:: with SMTP id w12mr32360164qka.327.1562187814395;
        Wed, 03 Jul 2019 14:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4pxa4Uhzaay3gjOT+udn7Skfa/Oj/0vBJhNznW/74ezU9fBJD2kSzyDYjMrOeBqxepFMa
X-Received: by 2002:a37:490c:: with SMTP id w12mr32360122qka.327.1562187813768;
        Wed, 03 Jul 2019 14:03:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562187813; cv=none;
        d=google.com; s=arc-20160816;
        b=MoU1v35JerLmD+4F/INSWOD5LrZruESvBMRlW8o9OUV/By0YUxQy64veFkjTnUZv+8
         HTjRLiej8k//EacwG/pvi+UodrqvLbd4DeFF3h0igkb5Iu3kemX+7tmO0CkY6+Q0Le23
         PM4EjUZzX3t+fVCvrdnX6DjLi+olfUkfs8b3DbNm9sYPCU2OXw4q2cCFGHPwoAc4Nby8
         cGzyJAkweXCplCpQy77tJL0KNAGKeF17DpbDeV+G+Pspv93oWuT1IbwVwjK/zcE2aX/z
         zZbzZ6Qeqx+KlWnMQHOS9b85UMwRCvFtS2/q2EmsQaQOeIECSMQm59RkOtmcACNupuMw
         T6qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=cou+QGq/6QrzCUvbcpEGYduHx74lUtRh7TlfmoWpawY=;
        b=I+wWqOewjj2nZ+EpvAFxf+Gne7V6CByjs/cAGFi/937wbdwUrEmLjboWeNBU9Eywzf
         gvNmYDPTurJF+aVlecKpdiKVNSjyufe6sKZvYTtP7rDsjhxzG8IAJ5/mwjyyN0v4vyr3
         59daAXwOf84a70ZdXabA4RZZaEDzflT8X2YySxMghuHkDVFljNsbvP+YUQWV/5iTGG0w
         DAj/UYZ0pAg7666wGFnm+kAXZ8NAUnGO6SGI8uQNdpW/t9RfV0bgL5isN/6u1kQPioBN
         Gf7E9ZwvLnmgth/gQPWUiwRJEhYqfj56+0BU29cpTXxIJNpv6nJIFloGo/+ANFsmNwTb
         6VYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=Tlcu+sif;
       spf=neutral (google.com: 40.107.75.79 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750079.outbound.protection.outlook.com. [40.107.75.79])
        by mx.google.com with ESMTPS id w16si2545496qki.79.2019.07.03.14.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 03 Jul 2019 14:03:33 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.75.79 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.75.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=Tlcu+sif;
       spf=neutral (google.com: 40.107.75.79 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cou+QGq/6QrzCUvbcpEGYduHx74lUtRh7TlfmoWpawY=;
 b=Tlcu+sifDmaGQkyxYU6hivHpR6AUrjNRxnFQrbt4UGPmZQDRlpefqkhs8HnSiii4P6t6+qWNlBGgoUOTPC0OWXnT3I236sjZopqu0w98YXblwwm2KyExKvCIXEFLzW/jT2tf+LlZs74Xvvj7CyP/vWCdZYNVbFB+H3Jj4LEpYXE=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB4043.namprd12.prod.outlook.com (10.141.185.142) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.18; Wed, 3 Jul 2019 21:03:32 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927%7]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 21:03:32 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Jason Gunthorpe <jgg@mellanox.com>
CC: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "Yang, Philip"
	<Philip.Yang@amd.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Dave Airlie
	<airlied@linux.ie>, "Deucher, Alexander" <Alexander.Deucher@amd.com>
Subject: Re: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Topic: [PATCH 1/1] drm/amdgpu: adopt to hmm_range_register API change
Thread-Index: AQHVMUJXWs8sf5cAOUS0d/4NvIH/Saa473yAgABzhwA=
Date: Wed, 3 Jul 2019 21:03:32 +0000
Message-ID: <a9764210-9401-471b-96a7-b93606008d07@amd.com>
References: <20190703015442.11974-1-Felix.Kuehling@amd.com>
 <20190703141001.GH18688@mellanox.com>
In-Reply-To: <20190703141001.GH18688@mellanox.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
x-clientproxiedby: YTXPR0101CA0046.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::23) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 844d0a74-3248-4a15-4456-08d6fff9e7c7
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB4043;
x-ms-traffictypediagnostic: DM6PR12MB4043:
x-microsoft-antispam-prvs:
 <DM6PR12MB4043BB0F7CCBCCD0F6125EEB92FB0@DM6PR12MB4043.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(39860400002)(396003)(366004)(376002)(346002)(189003)(199004)(256004)(25786009)(53936002)(14444005)(66066001)(65956001)(65806001)(6512007)(64126003)(3846002)(6116002)(6436002)(4326008)(14454004)(86362001)(65826007)(6916009)(6246003)(36756003)(6486002)(6506007)(386003)(58126008)(31696002)(2906002)(102836004)(316002)(68736007)(486006)(31686004)(73956011)(26005)(66556008)(186003)(66946007)(66446008)(53546011)(72206003)(478600001)(54906003)(76176011)(64756008)(66476007)(52116002)(229853002)(99286004)(71200400001)(71190400001)(7736002)(305945005)(2616005)(476003)(5660300002)(446003)(8936002)(81166006)(81156014)(11346002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB4043;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 dP0ttaLr0dIjvmtJPj24LWE8GDtdGEm15pwABWYTr49IJyS5F0L9z6++C3VQ6NyUAPrsyvO5Nuv6PjIAvphKDJYxDT6JZ8rNArLR+Wkhw2Y6iSLw4hCbOf6aIJptnzK1v60ToAkyDBqIVhbqx5QSmj9y3SsX8iPjhaxuPu7+Ocrnwg6dh6CmUBkjxyT1zr6nWHusWpXeQy7bCpA/7jbWYBD1xXcYHbcnpQcdVKELuuBGMSKvv06Ef9OD1+IroSA46jBB3Ynjt0L4UfrXZXXQlGkk7PmeXSH/h1d5Ixk4ZALQqT6iZNRtMUAmpnOl8JFDRGJC8FrtreL+d4jxAURD2QBHTO4JcQMKKO1DgmsPkGXNDhy6miadMEHiNSNv0ysO5wCPPSDPaAiuP/cWrsWZaq8uvVB1rlV0yErnRfS7WG4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0E65351505BF7E408334A64F225F3BC0@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 844d0a74-3248-4a15-4456-08d6fff9e7c7
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 21:03:32.2927
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB4043
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNy0wMyAxMDoxMCBhLm0uLCBKYXNvbiBHdW50aG9ycGUgd3JvdGU6DQo+IE9uIFdl
ZCwgSnVsIDAzLCAyMDE5IGF0IDAxOjU1OjA4QU0gKzAwMDAsIEt1ZWhsaW5nLCBGZWxpeCB3cm90
ZToNCj4+IEZyb206IFBoaWxpcCBZYW5nIDxQaGlsaXAuWWFuZ0BhbWQuY29tPg0KPj4NCj4+IElu
IG9yZGVyIHRvIHBhc3MgbWlycm9yIGluc3RlYWQgb2YgbW0gdG8gaG1tX3JhbmdlX3JlZ2lzdGVy
LCB3ZSBuZWVkDQo+PiBwYXNzIGJvIGluc3RlYWQgb2YgdHRtIHRvIGFtZGdwdV90dG1fdHRfZ2V0
X3VzZXJfcGFnZXMgYmVjYXVzZSBtaXJyb3INCj4+IGlzIHBhcnQgb2YgYW1kZ3B1X21uIHN0cnVj
dHVyZSwgd2hpY2ggaXMgYWNjZXNzaWJsZSBmcm9tIGJvLg0KPj4NCj4+IFNpZ25lZC1vZmYtYnk6
IFBoaWxpcCBZYW5nIDxQaGlsaXAuWWFuZ0BhbWQuY29tPg0KPj4gUmV2aWV3ZWQtYnk6IEZlbGl4
IEt1ZWhsaW5nIDxGZWxpeC5LdWVobGluZ0BhbWQuY29tPg0KPj4gU2lnbmVkLW9mZi1ieTogRmVs
aXggS3VlaGxpbmcgPEZlbGl4Lkt1ZWhsaW5nQGFtZC5jb20+DQo+PiBDQzogU3RlcGhlbiBSb3Ro
d2VsbCA8c2ZyQGNhbmIuYXV1Zy5vcmcuYXU+DQo+PiBDQzogSmFzb24gR3VudGhvcnBlIDxqZ2dA
bWVsbGFub3guY29tPg0KPj4gQ0M6IERhdmUgQWlybGllIDxhaXJsaWVkQGxpbnV4LmllPg0KPj4g
Q0M6IEFsZXggRGV1Y2hlciA8YWxleGFuZGVyLmRldWNoZXJAYW1kLmNvbT4NCj4+IC0tLQ0KPj4g
ICBkcml2ZXJzL2dwdS9kcm0vS2NvbmZpZyAgICAgICAgICAgICAgICAgICAgICAgICAgfCAgMSAt
DQo+PiAgIGRyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9hbWRrZmRfZ3B1dm0uYyB8
ICA1ICsrLS0tDQo+PiAgIGRyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9jcy5jICAg
ICAgICAgICB8ICAyICstDQo+PiAgIGRyaXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9n
ZW0uYyAgICAgICAgICB8ICAzICstLQ0KPj4gICBkcml2ZXJzL2dwdS9kcm0vYW1kL2FtZGdwdS9h
bWRncHVfbW4uYyAgICAgICAgICAgfCAgOCArKysrKysrKw0KPj4gICBkcml2ZXJzL2dwdS9kcm0v
YW1kL2FtZGdwdS9hbWRncHVfbW4uaCAgICAgICAgICAgfCAgNSArKysrKw0KPj4gICBkcml2ZXJz
L2dwdS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfdHRtLmMgICAgICAgICAgfCAxMiArKysrKysrKysr
LS0NCj4+ICAgZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X3R0bS5oICAgICAgICAg
IHwgIDUgKysrLS0NCj4+ICAgOCBmaWxlcyBjaGFuZ2VkLCAzMCBpbnNlcnRpb25zKCspLCAxMSBk
ZWxldGlvbnMoLSkNCj4gVGhpcyBpcyB0b28gYmlnIHRvIHVzZSBhcyBhIGNvbmZsaWN0IHJlc29s
dXRpb24sIHdoYXQgeW91IGNvdWxkIGRvIGlzDQo+IGFwcGx5IHRoZSBtYWpvcml0eSBvZiB0aGUg
cGF0Y2ggb24gdG9wIG9mIHlvdXIgdHJlZSBhcy1pcyAoaWUga2VlcA0KPiB1c2luZyB0aGUgb2xk
IGhtbV9yYW5nZV9yZWdpc3RlciksIHRoZW4gdGhlIGNvbmZsaWN0IHJlc29sdXRpb24gZm9yDQo+
IHRoZSB1cGRhdGVkIEFNRCBHUFUgdHJlZSBjYW4gYmUgYSBzaW1wbGUgb25lIGxpbmUgY2hhbmdl
Og0KPg0KPiAgIC0JaG1tX3JhbmdlX3JlZ2lzdGVyKHJhbmdlLCBtbSwgc3RhcnQsDQo+ICAgKwlo
bW1fcmFuZ2VfcmVnaXN0ZXIocmFuZ2UsIG1pcnJvciwgc3RhcnQsDQo+ICAgIAkJCSAgIHN0YXJ0
ICsgdHRtLT5udW1fcGFnZXMgKiBQQUdFX1NJWkUsIFBBR0VfU0hJRlQpOw0KPg0KPiBXaGljaCBp
cyB0cml2aWFsIGZvciBldmVyb25lIHRvIGRlYWwgd2l0aCwgYW5kIHNvbHZlcyB0aGUgcHJvYmxl
bS4NCg0KR29vZCBpZGVhLg0KDQoNCj4NCj4gVGhpcyBpcyBwcm9iYWJseSBhIG11Y2ggYmV0dGVy
IG9wdGlvbiB0aGFuIHJlYmFzaW5nIHRoZSBBTUQgZ3B1IHRyZWUuDQoNCkkgdGhpbmsgQWxleCBp
cyBwbGFubmluZyB0byBtZXJnZSBobW0uZ2l0IGludG8gYW4gdXBkYXRlZCBkcm0tbmV4dCBhbmQg
DQp0aGVuIHJlYmFzZSBhbWQtc3RhZ2luZy1kcm0tbmV4dCBvbiB0b3Agb2YgdGhhdC4gUmViYXNp
bmcgb3VyIA0KYW1kLXN0YWdpbmctZHJtLW5leHQgaXMgc29tZXRoaW5nIHdlIGRvIGV2ZXJ5IG1v
bnRoIG9yIHR3byBhbnl3YXkuDQoNCg0KPg0KPj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvZ3B1L2Ry
bS9hbWQvYW1kZ3B1L2FtZGdwdV9tbi5jIGIvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1k
Z3B1X21uLmMNCj4+IGluZGV4IDYyM2Y1NmExNDg1Zi4uODBlNDA4OThhNTA3IDEwMDY0NA0KPj4g
LS0tIGEvZHJpdmVycy9ncHUvZHJtL2FtZC9hbWRncHUvYW1kZ3B1X21uLmMNCj4+ICsrKyBiL2Ry
aXZlcnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV9tbi5jDQo+PiBAQCAtMzk4LDYgKzM5OCwx
NCBAQCBzdHJ1Y3QgYW1kZ3B1X21uICphbWRncHVfbW5fZ2V0KHN0cnVjdCBhbWRncHVfZGV2aWNl
ICphZGV2LA0KPj4gICAJcmV0dXJuIEVSUl9QVFIocik7DQo+PiAgIH0NCj4+ICAgDQo+PiArc3Ry
dWN0IGhtbV9taXJyb3IgKmFtZGdwdV9tbl9nZXRfbWlycm9yKHN0cnVjdCBhbWRncHVfbW4gKmFt
bikNCj4+ICt7DQo+PiArCWlmICghYW1uKQ0KPj4gKwkJcmV0dXJuIE5VTEw7DQo+PiArDQo+PiAr
CXJldHVybiAmYW1uLT5taXJyb3I7DQo+PiArfQ0KPiBJIHRoaW5rIGl0IGlzIGJldHRlciBtYWtl
IHRoZSBzdHJ1Y3QgYW1kZ3B1X21uIHB1YmxpYyByYXRoZXIgdGhhbiBhZGQNCj4gdGhpcyB3cmFw
cGVyLg0KDQpTdXJlLiBJIGNhbiBkbyB0aGF0LiBJdCB3b24ndCBtYWtlIHRoZSBwYXRjaCBzbWFs
bGVyLCB0aG91Z2gsIGlmIHRoYXQgDQp3YXMgeW91ciBpbnRlbnRpb24uDQoNCkl0IGxvb2tzIGxp
a2UgU3RlcGhlbiBhbHJlYWR5IGFwcGxpZWQgbXkgcGF0Y2ggYXMgYSBjb25mbGljdCByZXNvbHV0
aW9uIA0Kb24gbGludXgtbmV4dCwgdGhvdWdoLiBJIHNlZSBsaW51eC1uZXh0L21hc3RlciBpcyBn
ZXR0aW5nIHVwZGF0ZWQgDQpub24tZmFzdC1mb3J3YXJkLiBTbyBpcyB0aGUgaWRlYSB0aGF0IGl0
cyBoaXN0b3J5IHdpbGwgdXBkYXRlZCBhZ2FpbiANCndpdGggdGhlIGZpbmFsIHJlc29sdXRpb24g
b24gZHJtLW5leHQgb3IgZHJtLWZpeGVzPw0KDQpSZWdhcmRzLA0KIMKgIEZlbGl4DQoNCj4NCj4g
SmFzb24NCj4NCg==

