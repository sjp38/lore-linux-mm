Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D21C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD45420850
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 19:36:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="kK7wIRhm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD45420850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 040206B0007; Mon, 13 May 2019 15:36:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F33D76B0008; Mon, 13 May 2019 15:36:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFBA06B000A; Mon, 13 May 2019 15:36:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEB3E6B0007
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:36:47 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so10639541ioa.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 12:36:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=HABMcRelqMS5oBSAN5KyvNh36xqRR1P2RUklZ7s8lVQ=;
        b=FsRx1JFpypwLVbWn7A+jXS1aJ8iNHU4vS23qd2aD8sF10+jKGE1wGnnBYWb3ohdM8l
         oFqzCzFAB7Iz7lNRjmd5ZL+PSwq+q/Fl4HG9WGVxE1kT2Nui1n+9jLkOKqTwi0UBhDM4
         mfPSEnlO2FkZJVb7OfGMWJom4Zewt8TG5Vb8PKqubuFmhP9lVky55I+G8FLRq7RzK+VY
         Wgaq9QA+fGnaw25cIu/xPxDxH87FOSPQgJgyWThG7Hfd7jZ2HiOTO1KusFuz66S1S+gg
         mU7RZKwzsEQhn6Dkkp/BC/IxmxnBTecNu24xfKg5GaTdzZxFHUe/GXxgUgng7KY4XwrF
         RAOQ==
X-Gm-Message-State: APjAAAVdjm1iEOS4QOjAAHP4oOGSJqOi30LGUoMpBUhEeke4r46ryU7i
	sDnvR+vtUWBTQI11Gwp9y+0CDMb1YVotG1TOW6Tg2KBAQLA6DoxcXTPgdql5zQeRSBzHYkpgUOH
	Fsqy2Ll6oabBD9nryGVHFfrUkDnCYDViXS7qGG4gRK0fMLWnryjcpLAcj2YTGF6k=
X-Received: by 2002:a5e:9313:: with SMTP id k19mr1367867iom.239.1557776207494;
        Mon, 13 May 2019 12:36:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9iKVkGZ5rJSAZMs/cvt6jz1fu+7CgaMLC2+blYbwri61IGHTRLdA2xEgXc0xGo8HujnG6
X-Received: by 2002:a5e:9313:: with SMTP id k19mr1367828iom.239.1557776206710;
        Mon, 13 May 2019 12:36:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557776206; cv=none;
        d=google.com; s=arc-20160816;
        b=KH/sDHGGDhEXiHECuHPXa/VqIMGYGiupuBhiF/jm87Yurd4RtzYKTm1D7xfvkFyjeD
         QZB7+0tsdNDaZCeDUOR6nkDL2ju2X8UNkCTDy/w+DabCH0n6ksxt38ZzmxIfp92BLhCB
         kjHxh7aQpRLLw6pVYebFYq+euwwBXmV6gW02EOS5GhfpK0AIuZnRuqx1U45hF3DwHXKL
         NQwrZTgJsFNR+WQFCu2yf2ETovkb21cLC13ODezPj3S32EgUR6uqOz4varEHY9glX/lR
         SeEAnbY4jU3bwXsU1btRGdbjpDr+5m268J31QZ0Eoq2Tce1JJkMH3nmZOt8TAnEGviZ1
         ut0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=HABMcRelqMS5oBSAN5KyvNh36xqRR1P2RUklZ7s8lVQ=;
        b=aeJc4smXUH1TxUCxJz5QJjA7irELGOliDUKIUwn5EbnUCGHSA+vbwXwofBtS1s5M6h
         ShUVcI65OhROuMfi7wCwtoy+Ag42fycIL2V9jtgTPD7HyRG3x2C9AxN2743olBUF5kRp
         ZuANRXwjuZ9Cz9ZXVC8cwLcTVRb0+KjaPtFt6DYaV1ygeG3Xw2Bf5Y3YrAaKN2qrHU0j
         FSKPr/MyQp72pAHJxRggdbVLEx5gxYIa6iAgmT9AP13muMiTJ5oZiaNSRg5fTljJSY3N
         eLQQ5nfYHdce7Nid5p6IOFLWhUmXe7JyWfVcksPKT+DcWfgLPzw8KfmGJ6RFfszMHJou
         rF+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=kK7wIRhm;
       spf=neutral (google.com: 40.107.74.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740042.outbound.protection.outlook.com. [40.107.74.42])
        by mx.google.com with ESMTPS id o192si248327itb.38.2019.05.13.12.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 May 2019 12:36:46 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.74.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.74.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=kK7wIRhm;
       spf=neutral (google.com: 40.107.74.42 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HABMcRelqMS5oBSAN5KyvNh36xqRR1P2RUklZ7s8lVQ=;
 b=kK7wIRhmkTZ53DvHPuSxa61ylKDxfYsvznye6cJqIXxfxdz8piiNKua8vFP9TXPqD8wNTB9JGZkFrYuVowCj8xFUsotFlF/uAwmwYw9FTEoDtzAXyT5lvuquzYhH2w1LPoyFii5jUEMN2Wlses07Md4T2KUkS1dIMPnSCGzaUiU=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB3147.namprd12.prod.outlook.com (20.178.31.93) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.22; Mon, 13 May 2019 19:36:44 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::588b:cfef:3486:b4e8]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::588b:cfef:3486:b4e8%3]) with mapi id 15.20.1878.024; Mon, 13 May 2019
 19:36:44 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: "alex.deucher@amd.com" <alex.deucher@amd.com>, "airlied@gmail.com"
	<airlied@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Thread-Topic: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Thread-Index: AQHVB2oH3gumKK8uVkW/G1cJvzIbZqZkyv6AgASsjwA=
Date: Mon, 13 May 2019 19:36:44 +0000
Message-ID: <65328381-aa0d-353d-68dc-81060e7cebdf@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-3-Felix.Kuehling@amd.com>
 <20190510201403.GG4507@redhat.com>
In-Reply-To: <20190510201403.GG4507@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YTOPR0101CA0041.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::18) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 54db876f-28f8-447f-9813-08d6d7da54a0
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB3147;
x-ms-traffictypediagnostic: DM6PR12MB3147:
x-microsoft-antispam-prvs:
 <DM6PR12MB3147ED9719C9D099D3356EA7920F0@DM6PR12MB3147.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2150;
x-forefront-prvs: 0036736630
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(376002)(39860400002)(396003)(136003)(366004)(199004)(189003)(316002)(186003)(386003)(6506007)(99286004)(53546011)(486006)(54906003)(36756003)(476003)(2616005)(31686004)(4326008)(65826007)(26005)(446003)(81166006)(81156014)(8936002)(68736007)(305945005)(64126003)(102836004)(52116002)(11346002)(76176011)(66946007)(66446008)(7736002)(64756008)(8676002)(66556008)(66476007)(73956011)(58126008)(3846002)(31696002)(72206003)(66066001)(65956001)(65806001)(25786009)(14444005)(256004)(6916009)(2906002)(66574012)(53936002)(86362001)(478600001)(6512007)(14454004)(6116002)(5660300002)(6246003)(6486002)(6436002)(71200400001)(229853002)(71190400001);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3147;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xtCmRtRX8qvezYD0C/2KBsrrFqaEcen/9ducUxh5FKbClTQLZrhqok4DuVYPSgDweH3Cza3datDZbuzxJb0HuAlrZLUIhrdUaie9pZICviF1VeNWoi1mMZrMePRWCUAM+mBz7+H8uDE8y0wQlrJb15YSjZ/l0PnxxPXPzObsy19Cad7OqAGtIx7pZRaMfKbEQrt8c5VHf7Kz0foD9tafAQ+qh/iGTUUUS3SXLn8XhMgGidTo1qzepmDI4hfYpW5S9YpEPEycXQPcjRc9jIrBBoRHeM9/budQv34AUnDt9shkOI1mc5VGAo/5mlr+A3183afbO83ijaXIoy9bjqLiSMpjXkn8+AWuvtD3RmWfpAOtvVvx80ojDMNox+lWC9IxOd3TRePaLLMnhEBQ/u8DhyHaN3ZLQhAMQor60u7u/+Q=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F23F16F4B7922A47828A8106EEABCBED@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 54db876f-28f8-447f-9813-08d6d7da54a0
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 May 2019 19:36:44.6069
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3147
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgSmVyb21lLA0KDQpEbyB5b3Ugd2FudCBtZSB0byBwdXNoIHRoZSBwYXRjaGVzIHRvIHlvdXIg
YnJhbmNoPyBPciBhcmUgeW91IGdvaW5nIHRvIA0KYXBwbHkgdGhlbSB5b3Vyc2VsZj8NCg0KSXMg
eW91ciBobW0tNS4yLXYzIGJyYW5jaCBnb2luZyB0byBtYWtlIGl0IGludG8gTGludXggNS4yPyBJ
ZiBzbywgZG8geW91IA0Ka25vdyB3aGVuPyBJJ2QgbGlrZSB0byBjb29yZGluYXRlIHdpdGggRGF2
ZSBBaXJsaWUgc28gdGhhdCB3ZSBjYW4gYWxzbyANCmdldCB0aGF0IHVwZGF0ZSBpbnRvIGEgZHJt
LW5leHQgYnJhbmNoIHNvb24uDQoNCkkgc2VlIHRoYXQgTGludXMgbWVyZ2VkIERhdmUncyBwdWxs
IHJlcXVlc3QgZm9yIExpbnV4IDUuMiwgd2hpY2ggDQppbmNsdWRlcyB0aGUgZmlyc3QgY2hhbmdl
cyBpbiBhbWRncHUgdXNpbmcgSE1NLiBUaGV5J3JlIGN1cnJlbnRseSBicm9rZW4gDQp3aXRob3V0
IHRoZXNlIHR3byBwYXRjaGVzLg0KDQpUaGFua3MsDQogwqAgRmVsaXgNCg0KT24gMjAxOS0wNS0x
MCA0OjE0IHAubS4sIEplcm9tZSBHbGlzc2Ugd3JvdGU6DQo+IFtDQVVUSU9OOiBFeHRlcm5hbCBF
bWFpbF0NCj4NCj4gT24gRnJpLCBNYXkgMTAsIDIwMTkgYXQgMDc6NTM6MjRQTSArMDAwMCwgS3Vl
aGxpbmcsIEZlbGl4IHdyb3RlOg0KPj4gRG9uJ3Qgc2V0IHRoaXMgZmxhZyBieSBkZWZhdWx0IGlu
IGhtbV92bWFfZG9fZmF1bHQuIEl0IGlzIHNldA0KPj4gY29uZGl0aW9uYWxseSBqdXN0IGEgZmV3
IGxpbmVzIGJlbG93LiBTZXR0aW5nIGl0IHVuY29uZGl0aW9uYWxseQ0KPj4gY2FuIGxlYWQgdG8g
aGFuZGxlX21tX2ZhdWx0IGRvaW5nIGEgbm9uLWJsb2NraW5nIGZhdWx0LCByZXR1cm5pbmcNCj4+
IC1FQlVTWSBhbmQgdW5sb2NraW5nIG1tYXBfc2VtIHVuZXhwZWN0ZWRseS4NCj4+DQo+PiBTaWdu
ZWQtb2ZmLWJ5OiBGZWxpeCBLdWVobGluZyA8RmVsaXguS3VlaGxpbmdAYW1kLmNvbT4NCj4gUmV2
aWV3ZWQtYnk6IErDqXLDtG1lIEdsaXNzZSA8amdsaXNzZUByZWRoYXQuY29tPg0KPg0KPj4gLS0t
DQo+PiAgIG1tL2htbS5jIHwgMiArLQ0KPj4gICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24o
KyksIDEgZGVsZXRpb24oLSkNCj4+DQo+PiBkaWZmIC0tZ2l0IGEvbW0vaG1tLmMgYi9tbS9obW0u
Yw0KPj4gaW5kZXggYjY1YzI3ZDVjMTE5Li4zYzRmMWQ2MjIwMmYgMTAwNjQ0DQo+PiAtLS0gYS9t
bS9obW0uYw0KPj4gKysrIGIvbW0vaG1tLmMNCj4+IEBAIC0zMzksNyArMzM5LDcgQEAgc3RydWN0
IGhtbV92bWFfd2FsayB7DQo+PiAgIHN0YXRpYyBpbnQgaG1tX3ZtYV9kb19mYXVsdChzdHJ1Y3Qg
bW1fd2FsayAqd2FsaywgdW5zaWduZWQgbG9uZyBhZGRyLA0KPj4gICAgICAgICAgICAgICAgICAg
ICAgICAgICAgYm9vbCB3cml0ZV9mYXVsdCwgdWludDY0X3QgKnBmbikNCj4+ICAgew0KPj4gLSAg
ICAgdW5zaWduZWQgaW50IGZsYWdzID0gRkFVTFRfRkxBR19BTExPV19SRVRSWSB8IEZBVUxUX0ZM
QUdfUkVNT1RFOw0KPj4gKyAgICAgdW5zaWduZWQgaW50IGZsYWdzID0gRkFVTFRfRkxBR19SRU1P
VEU7DQo+PiAgICAgICAgc3RydWN0IGhtbV92bWFfd2FsayAqaG1tX3ZtYV93YWxrID0gd2Fsay0+
cHJpdmF0ZTsNCj4+ICAgICAgICBzdHJ1Y3QgaG1tX3JhbmdlICpyYW5nZSA9IGhtbV92bWFfd2Fs
ay0+cmFuZ2U7DQo+PiAgICAgICAgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEgPSB3YWxrLT52
bWE7DQo+PiAtLQ0KPj4gMi4xNy4xDQo+Pg0K

