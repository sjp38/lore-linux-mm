Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE693C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F8120872
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="gFNzdADj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F8120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC7B6B027B; Thu,  6 Jun 2019 15:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89BDF6B027C; Thu,  6 Jun 2019 15:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 763C16B027D; Thu,  6 Jun 2019 15:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 567B06B027B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:16:52 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z19so879528ioi.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=Dl28ERR4B1qNKjC3grRteB0hkgU9TBAofV9QLwC2OdQ=;
        b=riflnPYMUjBjgWBMrB8K/WYx230fn3XIGmgXkcF1wfgA4CgdFxD2xqvTs1xwysxNTE
         DVWtc9VD63NfyVsM7sJoOXUOGlVECjjGQxr3lIYUua7stV/z+LNLatBed1ANmRli41sC
         xtfWAbA6ReyXs3YJF/KL9rZZmM4Ah+IBwQrGUvT27BBW8UvcascgVmcWLAqTyCwSwxcV
         +im8gc2+KOVo+g0+2DGpsDhw4NschV8OFo8wPhWPeICGUU2fag+7WBIWUW8yX7VvTwIr
         9bLUC8EWS2bZZS2PdnGTeP/XviabYgacsXaIQOORk0mJHeEufQvCYTsqShTUXiP+XWhI
         n/Ow==
X-Gm-Message-State: APjAAAV+u82WdEHPTWX74iD797++LkdRoV8Cfwt/ygh6iqwyJ3SEaL7P
	QClNjlxdjFlnmiMMFlzJlGBDQLAVk13nQEF5XEfJ9CLgDIiVH+LU5s+xMirp4+5deBiDsJzJYX3
	NfsXNHMdGnxAvNzTgyJEyD5K+Z78RO+6g9o1kv+uuamyjP9spPoEv5mFtdty09sw=
X-Received: by 2002:a05:6602:220d:: with SMTP id n13mr17396202ion.104.1559848612043;
        Thu, 06 Jun 2019 12:16:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynQA0LG61ZneOfZ88eifpWfu94/GzWdWtTg77cje2XP7qUgw866n8F10ziocjBxCDGK9fJ
X-Received: by 2002:a05:6602:220d:: with SMTP id n13mr17396150ion.104.1559848611309;
        Thu, 06 Jun 2019 12:16:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559848611; cv=none;
        d=google.com; s=arc-20160816;
        b=mFI36NiPxhmnw34wpBwa/XCwt/cjVWfS0chHMQNRSEmCKlMSh9rMj088MpdmzHRiFa
         RkD93dtw20a5JvM/2LdvacHP+km4IHyvPiPhxrbXUJd83GCynnbJndG/cue4x3TXQDDd
         qh1ueQqQEUKZS0sFrpLlQubLf8TV3VnqK1pacUqsbYkrEB/h4zlUqXfrxJb2YqCar/bh
         PRBwOSBGZ0CqOdmMXDU5S1nMPp54PIyC87gHWh4HcqrvAxsAoipii7ovNXTDhK2v5ogh
         5qFZ+vwscHJHswIqWe0FxcRO2uIlDIo2RD+G/t4S0pwPoWPjtHFrSAiWSXuxkgel8ZnT
         idCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=Dl28ERR4B1qNKjC3grRteB0hkgU9TBAofV9QLwC2OdQ=;
        b=qWftiP5Gth+zCmTCLm8vKHzsraV+W6IWFtAjrMBPLSemAb25SsvZElo5ZloirA/rTn
         MDwoDFNdhmLwManqaiXFpu8+aT0eRxRHygPMYjzDl6mPAcer+aH0wPvXawA/ZAUfImxS
         R6/cpz9ytP4fXgFx3O8uhWhIQ57kmeS6oxS6fHMVrxH5eGGVKSmyDnDqOTGEn29NzxAy
         ZMA2V2Q/QBTA54Gbw+0dBGdTd9Ahg6nPG258hlNUigp7B1+XRFYVTgYeZ62kAXzi8xQG
         muOs6PKcxc9o55p9QSpyePZk5UqHBkkD6b8ZVj4RTzQgca8z6IJ0X6RHfKZVN1R9FRP0
         S2Mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=gFNzdADj;
       spf=neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780041.outbound.protection.outlook.com. [40.107.78.41])
        by mx.google.com with ESMTPS id y136si2331728itb.13.2019.06.06.12.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Jun 2019 12:16:51 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.78.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=gFNzdADj;
       spf=neutral (google.com: 40.107.78.41 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Dl28ERR4B1qNKjC3grRteB0hkgU9TBAofV9QLwC2OdQ=;
 b=gFNzdADjQfwCI5ricYHbcY/Q3k29A4JYb+Og3NNhA8+REGr9kNXFJY/Iyd1M94asE58iQBDyaI5eHCGA71GvA2kRIqRD8DuIzCE6mFOThgBtj5PvtNKTjv4Ls6Oe1Vu5VTXGSqqeAQbTmNIq5SaU7R/oV0QCCIcLWHb4JIinLCY=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB4027.namprd12.prod.outlook.com (10.255.175.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Thu, 6 Jun 2019 19:16:48 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::5964:8c3c:1b5b:c480]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::5964:8c3c:1b5b:c480%2]) with mapi id 15.20.1965.011; Thu, 6 Jun 2019
 19:16:48 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>
CC: "jglisse@redhat.com" <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 0/2] Two bug-fixes for HMM
Thread-Topic: [PATCH 0/2] Two bug-fixes for HMM
Thread-Index: AQHVB2oFymYy9x0alkiQIwO1y+NKl6aO5X+AgABEcAA=
Date: Thu, 6 Jun 2019 19:16:48 +0000
Message-ID: <c42a620d-ce5f-def3-32e3-1e5482a2540e@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190606151149.GA5506@ziepe.ca>
In-Reply-To: <20190606151149.GA5506@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
x-clientproxiedby: YTXPR0101CA0013.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::26) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 23a128ae-d38f-406b-c7ca-08d6eab385d4
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB4027;
x-ms-traffictypediagnostic: DM6PR12MB4027:
x-ms-exchange-purlcount: 3
x-microsoft-antispam-prvs:
 <DM6PR12MB402768CB7E99D8494D6F8AD692170@DM6PR12MB4027.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 00603B7EEF
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(136003)(396003)(346002)(366004)(39860400002)(199004)(189003)(52116002)(14454004)(64126003)(446003)(2616005)(6486002)(6246003)(186003)(110136005)(11346002)(36756003)(476003)(54906003)(53936002)(8676002)(81166006)(5660300002)(4326008)(81156014)(8936002)(229853002)(58126008)(31686004)(7736002)(316002)(71190400001)(305945005)(25786009)(71200400001)(72206003)(68736007)(966005)(66446008)(99286004)(86362001)(478600001)(2501003)(66556008)(65826007)(66946007)(73956011)(66476007)(2906002)(3846002)(26005)(6306002)(31696002)(65956001)(6116002)(386003)(64756008)(76176011)(6506007)(6436002)(53546011)(14444005)(256004)(102836004)(486006)(65806001)(66066001)(6512007);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB4027;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 QpG9T5HUFKMJHNAVDlvCtxmyvRw7IXvZGKHdvxqbq+rM06vbLMjL8xqOb5w8jH4JxE5Pk45hgWn6HNBBdI0ndJDfTuYP/0j3a0LEZ2ZUrk7j2ANjjlcHUJb2Sxj5ZKIAxTWQtkpEindV4lHeK4TiEJ798aNGrb+XOkP8o9oq98/gesXWfsDy2DhSA6LVY7d7BSyjH+mTPMNmmM4a7pREEZGl+mhInvLpEB+5w716/OPPafCwcfq8YC4Ml1YnIrt6NCgOOQGQQakBIUbl7EsrbY6qxTevQJo55PypcawH2MunxKXmX+EB7sM3RRPCu5e0rXCccdEdgbcSy36dZUjDfszKANCvVM5wbceGT+Ta96aW+lmQQ5nyCh4TgEDVcJZl0/MowTZUXCSXtCRUb//3DMn2bUXsJmxlbG5eMpAIKKc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <79C2832BC9AA964E8E8B7E20866316B4@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 23a128ae-d38f-406b-c7ca-08d6eab385d4
X-MS-Exchange-CrossTenant-originalarrivaltime: 06 Jun 2019 19:16:48.8082
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB4027
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

W3Jlc2VudCB3aXRoIGNvcnJlY3QgYWRkcmVzcyBmb3IgQWxleF0NCg0KT24gMjAxOS0wNi0wNiAx
MToxMSBhLm0uLCBKYXNvbiBHdW50aG9ycGUgd3JvdGU6DQoNCj4gT24gRnJpLCBNYXkgMTAsIDIw
MTkgYXQgMDc6NTM6MjFQTSArMDAwMCwgS3VlaGxpbmcsIEZlbGl4IHdyb3RlOg0KPj4gVGhlc2Ug
cHJvYmxlbXMgd2VyZSBmb3VuZCBpbiBBTUQtaW50ZXJuYWwgdGVzdGluZyBhcyB3ZSdyZSB3b3Jr
aW5nIG9uDQo+PiBhZG9wdGluZyBITU0uIFRoZXkgYXJlIHJlYmFzZWQgYWdhaW5zdCBnbGlzc2Uv
aG1tLTUuMi12My4gV2UnZCBsaWtlIA0KPj4gdG8gZ2V0DQo+PiB0aGVtIGFwcGxpZWQgdG8gYSBt
YWlubGluZSBMaW51eCBrZXJuZWwgYXMgd2VsbCBhcyBkcm0tbmV4dCBhbmQNCj4+IGFtZC1zdGFn
aW5nLWRybS1uZXh0IHNvb25lciByYXRoZXIgdGhhbiBsYXRlci4NCj4+DQo+PiBDdXJyZW50bHkg
dGhlIEhNTSBpbiBhbWQtc3RhZ2luZy1kcm0tbmV4dCBpcyBxdWl0ZSBmYXIgYmVoaW5kIGhtbS01
LjItdjMsDQo+PiBidXQgdGhlIGRyaXZlciBjaGFuZ2VzIGZvciBITU0gYXJlIGV4cGVjdGVkIHRv
IGxhbmQgaW4gNS4yIGFuZCB3aWxsIA0KPj4gbmVlZCB0bw0KPj4gYmUgcmViYXNlZCBvbiB0aG9z
ZSBITU0gY2hhbmdlcy4NCj4+DQo+PiBJJ2QgbGlrZSB0byB3b3JrIG91dCBhIGZsb3cgYmV0d2Vl
biBKZXJvbWUsIERhdmUsIEFsZXggYW5kIG15c2VsZiB0aGF0DQo+PiBhbGxvd3MgdXMgdG8gdGVz
dCB0aGUgbGF0ZXN0IHZlcnNpb24gb2YgSE1NIG9uIGFtZC1zdGFnaW5nLWRybS1uZXh0IHNvDQo+
PiB0aGF0IGlkZWFsbHkgZXZlcnl0aGluZyBjb21lcyB0b2dldGhlciBpbiBtYXN0ZXIgd2l0aG91
dCBtdWNoIG5lZWQgZm9yDQo+PiByZWJhc2luZyBhbmQgcmV0ZXN0aW5nLg0KPiBJIHRoaW5rIHdl
IGhhdmUgdGhhdCBub3csIEknbSBydW5uaW5nIGEgaG1tLmdpdCB0aGF0IGlzIGNsZWFuIGFuZCBj
YW4NCj4gYmUgdXNlZCBmb3IgbWVyZ2luZyBpbnRvIERSTSByZWxhdGVkIHRyZWVzIChhbmQgUkRN
QSkuIEkndmUgY29tbWl0ZWQNCj4gdG8gc2VuZCB0aGlzIHRyZWUgdG8gTGludXMgYXQgdGhlIHN0
YXJ0IG9mIHRoZSBtZXJnZSB3aW5kb3cuDQo+DQo+IFNlZSBoZXJlOg0KPg0KPiBodHRwczovL2xv
cmUua2VybmVsLm9yZy9sa21sLzIwMTkwNTI0MTI0NDU1LkdCMTY4NDVAemllcGUuY2EvDQo+DQo+
IFRoZSB0cmVlIGlzIGhlcmU6DQo+DQo+IGh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9s
aW51eC9rZXJuZWwvZ2l0L3JkbWEvcmRtYS5naXQvbG9nLz9oPWhtbQ0KPg0KPiBIb3dldmVyIHBs
ZWFzZSBjb25zdWx0IHdpdGggbWUgYmVmb3JlIG1ha2luZyBhIG1lcmdlIGNvbW1pdCB0byBiZQ0K
PiBjby1vcmRpbmF0ZWQuIFRoYW5rcw0KPg0KPiBJIHNlZSBpbiB0aGlzIHRocmVhZCB0aGF0IEFN
REdQVSBtaXNzZWQgNS4yIGJlYWNhdXNlIG9mIHRoZQ0KPiBjby1vcmRpbmF0aW9uIHByb2JsZW1z
IHRoaXMgdHJlZSBpcyBpbnRlbmRlZCB0byBzb2x2ZSwgc28gSSdtIHZlcnkNCj4gaG9wZWZ1bCB0
aGlzIHdpbGwgaGVscCB5b3VyIHdvcmsgbW92ZSBpbnRvIDUuMyENCg0KVGhhbmtzIEphc29uLiBP
dXIgdHdvIHBhdGNoZXMgYmVsb3cgd2VyZSBhbHJlYWR5IGluY2x1ZGVkIGluIHRoZSBNTSB0cmVl
IA0KKGh0dHBzOi8vb3psYWJzLm9yZy9+YWtwbS9tbW90cy9icm9rZW4tb3V0LykuIFdpdGggeW91
ciBuZXcgaG1tLmdpdCwgDQpkb2VzIHRoYXQgbWVhbiBITU0gZml4ZXMgYW5kIGNoYW5nZXMgd2ls
bCBubyBsb25nZXIgZ28gdGhyb3VnaCBBbmRyZXcgDQpNb3J0b24gYnV0IGRpcmVjdGx5IHRocm91
Z2ggeW91ciB0cmVlIHRvIExpbnVzPw0KDQpXZSBoYXZlIGFsc28gYXBwbGllZCB0aGUgdHdvIHBh
dGNoZXMgdG8gb3VyIGludGVybmFsIHRyZWUgd2hpY2ggaXMgDQpjdXJyZW50bHkgYmFzZWQgb24g
NS4yLXJjMSBzbyB3ZSBjYW4gbWFrZSBwcm9ncmVzcy4NCg0KQWxleCwgSSB0aGluayBtZXJnaW5n
IGhtbSB3b3VsZCBiZSBhbiBleHRyYSBzdGVwIGV2ZXJ5IHRpbWUgeW91IHJlYmFzZSANCmFtZC1z
dGFnaW5nLWRybS1uZXh0LiBXZSBjb3VsZCBwcm9iYWJseSBhbHNvIG1lcmdlIGhtbSBhdCBvdGhl
ciB0aW1lcyBhcyANCm5lZWRlZC4gRG8geW91IHRoaW5rIHRoaXMgd291bGQgY2F1c2UgdHJvdWJs
ZSBvciBjb25mdXNpb24gZm9yIA0KdXBzdHJlYW1pbmcgdGhyb3VnaCBkcm0tbmV4dD8NCg0KUmVn
YXJkcywNCiDCoCBGZWxpeA0KDQoNCj4NCj4+IE1heWJlIGhhdmluZyBKZXJvbWUncyBsYXRlc3Qg
SE1NIGNoYW5nZXMgaW4gZHJtLW5leHQuIEhvd2V2ZXIsIHRoYXQgbWF5DQo+PiBjcmVhdGUgZGVw
ZW5kZW5jaWVzIHdoZXJlIEplcm9tZSBhbmQgRGF2ZSBuZWVkIHRvIGNvb3JkaW5hdGUgdGhlaXIg
cHVsbC0NCj4+IHJlcXVlc3RzIGZvciBtYXN0ZXIuDQo+Pg0KPj4gRmVsaXggS3VlaGxpbmcgKDEp
Og0KPj4gbW0vaG1tOiBPbmx5IHNldCBGQVVMVF9GTEFHX0FMTE9XX1JFVFJZIGZvciBub24tYmxv
Y2tpbmcNCj4+DQo+PiBQaGlsaXAgWWFuZyAoMSk6DQo+PiBtbS9obW06IHN1cHBvcnQgYXV0b21h
dGljIE5VTUEgYmFsYW5jaW5nDQo+IEkndmUgYXBwbGllZCBib3RoIG9mIHRoZXNlIHBhdGNoZXMg
d2l0aCBKZXJvbWUncyBSZXZpZXdlZC1ieSB0bw0KPiBobW0uZ2l0IGFuZCBhZGRlZCB0aGUgbWlz
c2VkIFNpZ25lZC1vZmYtYnkNCj4NCj4gSWYgeW91IHRlc3QgYW5kIGNvbmZpcm0gSSB0aGluayB0
aGlzIGJyYW5jaCB3b3VsZCBiZSByZWFkeSBmb3IgbWVyZ2luZw0KPiB0b3dhcmQgdGhlIEFNRCB0
cmVlLg0KPiBSZWdhcmRzLA0KPiBKYXNvbg0K

