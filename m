Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19203C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87E66218EA
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="I2VmR7Ga"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87E66218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CCEC6B0003; Tue,  2 Jul 2019 17:44:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17DE98E0003; Tue,  2 Jul 2019 17:44:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01E8F8E0001; Tue,  2 Jul 2019 17:44:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCD6F6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 17:44:02 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id 20so205618otv.1
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 14:44:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=bXV5m5/kWL0UTx0rffDnbnfr99W18VuHp36gZ6xXldk=;
        b=LlKNS79tVLtdH/TTZ03N2BVh+KS4uS5wBitzTT70RX8RL4WLM+scQaSJFrStXmSPcw
         JsRI5yjESFLE5649nO7mxWympat0lHY1bblrYR3OZtGKSZ8LaJjZODOwlZxrLbPDhKHu
         s8TC/qDsyWxWI5tCbElFtLSsedXDAXTh97jUP7rkp637K68TlarrewR32utSJw5l1AGM
         i7TNzzEfw90exAKjxBLc1sezpEYAVuZ98/QNh5i6sLFfo/PuzmYq9a/7IpXu4YA4gGKs
         v5W9OG3Bm3ptIyzgII+v9iSdYJEw6awBPFCoa3eatdpK2MM3++NQXIz8dDIV3MDv66kg
         xNKA==
X-Gm-Message-State: APjAAAWu6sbHadh0USaRiaXI5vvEhuV88tYe/8JV60Scw7kCdOuFYOzQ
	3tssjJ3lo/fsN36A29Y+Y8viRIbmsTbUv+ZnZBeLPSf6osPeanfrUFAq2zwNl01Hn6kyeKqv5eb
	fhGx/k8+UWWPkOHXu3QNLqPuqZyoerGDBxlQQ6h8SOaJsFcjzHYz2MNjuhr9ogo4=
X-Received: by 2002:aca:fd57:: with SMTP id b84mr4384204oii.150.1562103842472;
        Tue, 02 Jul 2019 14:44:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxueizepMUAsZZbvaEmvpUyUBAMFq5lZ1yCQFwYK7ymVGfnv8BrIXexbljOhRVBDb4UmTSd
X-Received: by 2002:aca:fd57:: with SMTP id b84mr4384179oii.150.1562103841706;
        Tue, 02 Jul 2019 14:44:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562103841; cv=none;
        d=google.com; s=arc-20160816;
        b=FOgUwBOKq2NZZdWyICNE1Nya3bJtG3yzWB7RzMO/dsZcznyqZCrhTYNhjbMTayhU46
         dDUom2SmP9ytOa6veCB7AAsh+g1RnjNGNXbE5ws9JEbxYHgTvBo8I6tQPkBNOAIHtItM
         v1VUll6GvGRzrMmv0Q/9zKnhKjfcf6ZcTfjw6o+m0eWAZf8Yq6VTwtcryd+RCIMIdX6L
         AskAz/Le10xSO5bh2ZhEmJ/yZ+8PrcmWMuBsC5QEzaIXRn+Ry1IEIJELPHWEPv09MQWz
         lP/DS7TB4dCFfedhYP9ZYfGko62uwklvU7slh+LCcBYPxp1tKJU0e/goeP8ZR0MH0sG+
         s+/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=bXV5m5/kWL0UTx0rffDnbnfr99W18VuHp36gZ6xXldk=;
        b=rjTDcW9SMXxuz/EgthLy/G5FgPB/CAG9MvGGOArlABOPKzMhdNY0MnmBE9jZMNXbSt
         Oc8y3gAa3RRzjT+5Je8bPow1Cqhzt+v2OVvRWbDz+ileKcetxslRDMTr1FQjnFs6Zauf
         7+8FB/PSoux0t8X4ulIUPfdS6lJkWcLiuWNyVpzPLFcDaG0kMLcST8mJQuGvLPpRx72Q
         XkmVbp49uSKDazjpQ5G/BCsPjRRbwASHIMXo3svFq9qHiAseCwrU0TNWVZsKi0WRqiC9
         puBmTY5mDQqyS58jYTAXr53XITzwv9Q2V2Ukr8IoOzfHtLgtrvcSjii9RX0ebNl7YGzm
         H8gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=I2VmR7Ga;
       spf=neutral (google.com: 40.107.76.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760057.outbound.protection.outlook.com. [40.107.76.57])
        by mx.google.com with ESMTPS id z51si188945otb.229.2019.07.02.14.44.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 14:44:01 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.76.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.76.57;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=I2VmR7Ga;
       spf=neutral (google.com: 40.107.76.57 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=bXV5m5/kWL0UTx0rffDnbnfr99W18VuHp36gZ6xXldk=;
 b=I2VmR7GaVUgrTx3BAhLw9gTSGN99h0fegBzuNaGRakfcNLzWWMVvDPwiH25Ed6kRRZWK7jwJ+Wkc4HAEgy8qCeSHo1hnjGfVCHF47S6AH5knIs8Ze4jaK4tAhax64gSold0HYRVowbsRYACwaMYkwtOCo1sS+MjODN0yChOyxGE=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB3227.namprd12.prod.outlook.com (20.179.105.95) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Tue, 2 Jul 2019 21:43:58 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927%7]) with mapi id 15.20.2032.019; Tue, 2 Jul 2019
 21:43:58 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jason Gunthorpe
	<jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, "Yang, Philip"
	<Philip.Yang@amd.com>
CC: Ira Weiny <ira.weiny@intel.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 19/22] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Thread-Topic: [PATCH 19/22] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Thread-Index: AQHVL9U3BN0CaVdL806tAThCwvVuZKa33tOA
Date: Tue, 2 Jul 2019 21:43:58 +0000
Message-ID: <fedf75d4-4ce2-e0cc-3c77-73ba31bed653@amd.com>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-20-hch@lst.de>
In-Reply-To: <20190701062020.19239-20-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
x-clientproxiedby: YTOPR0101CA0031.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:15::44) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 13f473c3-5730-48c1-f95f-08d6ff366354
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3227;
x-ms-traffictypediagnostic: DM6PR12MB3227:
x-microsoft-antispam-prvs:
 <DM6PR12MB32277E4745008E9B86DBD5E692F80@DM6PR12MB3227.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 008663486A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(366004)(39860400002)(346002)(396003)(136003)(376002)(189003)(199004)(6116002)(3846002)(68736007)(476003)(2616005)(486006)(6486002)(36756003)(72206003)(478600001)(66066001)(64126003)(64756008)(66446008)(66946007)(66476007)(73956011)(14444005)(256004)(66556008)(8676002)(65956001)(65806001)(102836004)(86362001)(71200400001)(53936002)(229853002)(8936002)(110136005)(316002)(6436002)(6506007)(81166006)(5660300002)(53546011)(31696002)(65826007)(58126008)(305945005)(186003)(71190400001)(54906003)(7416002)(386003)(14454004)(6512007)(99286004)(7736002)(11346002)(4326008)(25786009)(6636002)(2906002)(76176011)(31686004)(52116002)(446003)(26005)(81156014)(6246003)(142933001);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3227;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sMk9L56Wb8xff3fa0UYNwsl9h+hrIYZNmWjZ2sZDOyWhgc5H+orKgzntdXV+43yWl4Lr3U4nKoyq+847Jyb1LO7jtF/utnCV/yhFNbUpoClgimWeyEW1AfwIxb1AbfTDFJ81dfCLN7d1C6JKhszrqEz69czVaywl62W2iiv2ZsBx1M78T3Kk8/Q3H8WtxPPbof/9Ll5wm58jel7AN2JeO8FBGM7JoD3HVlg6nqebp3T6ukDzHKWAKGVT7ItJfD/8XTkhqmPwRzGOd7AxvfYipQ9hPwAzZfdrFp7OCGSLNKDF/CC9Kp+yDd6w1rGGvYppl2NucncmXRzCmiFh9ivHN47pfj9UgYWZNbJcnc6XVH1bOnlXWAqOSDvoSm9qrF0zVD8TRE8BtixlMseu5AYRmAhTf7vXX2h43mFy4AgGm1c=
Content-Type: text/plain; charset="utf-8"
Content-ID: <30B65ABE32E43E43B44DF7426B589C07@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 13f473c3-5730-48c1-f95f-08d6ff366354
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Jul 2019 21:43:58.3251
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3227
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNy0wMSAyOjIwIGEubS4sIENocmlzdG9waCBIZWxsd2lnIHdyb3RlOg0KPiBXZSBz
aG91bGQgbm90IGhhdmUgdHdvIGRpZmZlcmVudCBlcnJvciBjb2RlcyBmb3IgdGhlIHNhbWUgY29u
ZGl0aW9uLiAgSW4NCj4gYWRkaXRpb24gdGhpcyByZWFsbHkgY29tcGxpY2F0ZXMgdGhlIGNvZGUg
ZHVlIHRvIHRoZSBzcGVjaWFsIGhhbmRsaW5nIG9mDQo+IEVBR0FJTiB0aGF0IGRyb3BzIHRoZSBt
bWFwX3NlbSBkdWUgdG8gdGhlIEZBVUxUX0ZMQUdfQUxMT1dfUkVUUlkgbG9naWMNCj4gaW4gdGhl
IGNvcmUgdm0uDQoNCkkgdGhpbmsgdGhlIGNvbW1lbnQgYWJvdmUgaG1tX3JhbmdlX3NuYXBzaG90
IG5lZWRzIGFuIHVwZGF0ZS4gQWxzbyANCkRvY3VtZW50YXRpb24vdm0vaG1tLnJzdCBzaG93cyBz
b21lIGV4YW1wbGUgY29kZSB1c2luZyANCmhtbV9yYW5nZV9zbmFwc2hvdCB0aGF0IHJldHJpZXMg
b24gLUVBR0FJTi4gVGhhdCB3b3VsZCBuZWVkIHRvIGJlIA0KdXBkYXRlZCB0byB1c2UgLUVCVVNZ
IG9yIHJlbW92ZSB0aGUgcmV0cnkgbG9naWMgYWx0b2dldGhlci4NCg0KT3RoZXIgdGhhbiB0aGF0
LCB0aGlzIHBhdGNoIGlzIFJldmlld2VkLWJ5OiBGZWxpeCBLdWVobGluZyANCjxGZWxpeC5LdWVo
bGluZ0BhbWQuY29tPg0KDQpQaGlsaXAsIHRoaXMgbWVhbnMgd2Ugc2hvdWxkIHJlbW92ZSBvdXIg
cmV0cnkgbG9naWMgYWdhaW4gaW4gDQphbWRncHVfdHRtX3R0X2dldF91c2VyX3BhZ2VzLiBBY2Nv
cmRpbmcgdG8gdGhlIGNvbW1lbnQgYWJvdmUgDQpobW1fcmFuZ2VfZmF1bHQsIGl0IGNhbiBvbmx5
IHJldHVybiAtRUFHQUlOIGlmIHRoZSBibG9jayBwYXJhbWV0ZXIgaXMgDQpmYWxzZS4gSSB0aGlu
ayB0aGlzIHN0YXRlbWVudCBpcyBub3cgYWN0dWFsbHkgdHJ1ZS4gV2Ugc2V0IGJsb2NrPXRydWUs
IA0Kc28gd2UgY2FuJ3QgZ2V0IC1FQUdBSU4uIE9uIC1FQlVTWSB3ZSBjYW4gbGV0IA0KYW1kZ3B1
X2FtZGtmZF9yZXN0b3JlX3VzZXJwdHJfd29ya2VyIHNjaGVkdWxlIHRoZSByZXRyeSAod2hpY2gg
aXQgZG9lcyANCmFscmVhZHkgYW55d2F5KS4NCg0KUmVnYXJkcywNCiDCoCBGZWxpeA0KDQoNCj4N
Cj4gU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBsc3QuZGU+DQo+IC0tLQ0K
PiAgIG1tL2htbS5jIHwgOCArKystLS0tLQ0KPiAgIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlv
bnMoKyksIDUgZGVsZXRpb25zKC0pDQo+DQo+IGRpZmYgLS1naXQgYS9tbS9obW0uYyBiL21tL2ht
bS5jDQo+IGluZGV4IGM4NWVkN2Q0ZTJjZS4uZDEyNWRmNjk4ZTJiIDEwMDY0NA0KPiAtLS0gYS9t
bS9obW0uYw0KPiArKysgYi9tbS9obW0uYw0KPiBAQCAtOTc0LDcgKzk3NCw3IEBAIGxvbmcgaG1t
X3JhbmdlX3NuYXBzaG90KHN0cnVjdCBobW1fcmFuZ2UgKnJhbmdlKQ0KPiAgIAlkbyB7DQo+ICAg
CQkvKiBJZiByYW5nZSBpcyBubyBsb25nZXIgdmFsaWQgZm9yY2UgcmV0cnkuICovDQo+ICAgCQlp
ZiAoIXJhbmdlLT52YWxpZCkNCj4gLQkJCXJldHVybiAtRUFHQUlOOw0KPiArCQkJcmV0dXJuIC1F
QlVTWTsNCj4gICANCj4gICAJCXZtYSA9IGZpbmRfdm1hKGhtbS0+bW0sIHN0YXJ0KTsNCj4gICAJ
CWlmICh2bWEgPT0gTlVMTCB8fCAodm1hLT52bV9mbGFncyAmIGRldmljZV92bWEpKQ0KPiBAQCAt
MTA2OSwxMCArMTA2OSw4IEBAIGxvbmcgaG1tX3JhbmdlX2ZhdWx0KHN0cnVjdCBobW1fcmFuZ2Ug
KnJhbmdlLCBib29sIGJsb2NrKQ0KPiAgIA0KPiAgIAlkbyB7DQo+ICAgCQkvKiBJZiByYW5nZSBp
cyBubyBsb25nZXIgdmFsaWQgZm9yY2UgcmV0cnkuICovDQo+IC0JCWlmICghcmFuZ2UtPnZhbGlk
KSB7DQo+IC0JCQl1cF9yZWFkKCZobW0tPm1tLT5tbWFwX3NlbSk7DQo+IC0JCQlyZXR1cm4gLUVB
R0FJTjsNCj4gLQkJfQ0KPiArCQlpZiAoIXJhbmdlLT52YWxpZCkNCj4gKwkJCXJldHVybiAtRUJV
U1k7DQo+ICAgDQo+ICAgCQl2bWEgPSBmaW5kX3ZtYShobW0tPm1tLCBzdGFydCk7DQo+ICAgCQlp
ZiAodm1hID09IE5VTEwgfHwgKHZtYS0+dm1fZmxhZ3MgJiBkZXZpY2Vfdm1hKSkNCg==

