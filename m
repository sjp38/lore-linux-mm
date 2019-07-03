Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 481A7C5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:27:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E58A521873
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 02:27:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="c7vT3JqH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E58A521873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785316B0005; Tue,  2 Jul 2019 22:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 736A78E0003; Tue,  2 Jul 2019 22:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D8408E0001; Tue,  2 Jul 2019 22:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3D76B0005
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 22:27:25 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v4so731607qkj.10
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 19:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=wy8FO9Kpq0mYscU2pRZ988JGN5ZGYBRBcI9oCJCrgeY=;
        b=mr2iG6hz8Q33YRqMjwHKiXw0nH9Erxk+IbamWcJrUyRU3lAJhdelfJ968gy8rKQi/5
         YDZJe3bwAlUqMXYwB/1zv6e03CXMjfVJ86rsj7C5qn8Q/Tn6QtxhlnKNJygD1pFZKeAg
         6kvkri1kEzw7lkW6eGYJmtaJyGLzDRkABYNvtbJAoa7NiwjjneuS03LJ/sj9F15bRUyQ
         zh8gN47+K2MfZ0ni61Sv1jCKarq7Fyui8spuGrCOgNaAB6hkIjK848Gf9dSdYfbl2JyG
         HdHg6Y7J4R/Dhar8e6K64F+9KTRDgFVhH6HeA3oXYARdP2LkSA+W+J1BgO/z+dFi8yLm
         be5g==
X-Gm-Message-State: APjAAAWIDIU7ZbuE6SXNmZV+TRO2458MrHoESBAR0WUS2qTNdQ/uhpng
	/AT/1ZnZLpGSMt1WXZRrD8dE2eE2SsyVc2d69pD3b2/m7wXhN+SLCr/f/KXb9iUwEbBUbKW10mk
	P1rPDHQ0ZLfDBsCohjKXGViS8A4jiuEHEfd0DmK2BHt0MuOaoj5DJzv9PiFGVbT8=
X-Received: by 2002:a37:96c4:: with SMTP id y187mr28060209qkd.462.1562120844900;
        Tue, 02 Jul 2019 19:27:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUTtTjyD5mBKr86yu8g2SSQdK+RRDoqEkQqdASue8kj3TP972tRqxaf1vaxKMfsftYQ4Xx
X-Received: by 2002:a37:96c4:: with SMTP id y187mr28060170qkd.462.1562120844303;
        Tue, 02 Jul 2019 19:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562120844; cv=none;
        d=google.com; s=arc-20160816;
        b=yOoW0mX6T8/O4jFUBzngjE9KcpODzY3hSalvflG1qA72qbZpvw5sL6iHliApAibwQo
         h/0DOCvCZjcaHrHWPAL4MBIl0P3bgVFyPYYMKM9AkrYIux1xrtNT7l/OeDVZvCVWlU9w
         649uAZv0snhOrNLX/R3+l0qg7FtIMpD1KJP300zhdzzsCCBa/4Q1FWaxBXtSpl2SLK+A
         12wVrddJWV8RkJf/7DYDb9TDCRulSdDvHe1OWorpjANjvJiXCC2ifzHnyidSUHEr+ngf
         lQ5KFVrqMCLHL3XA1Zsb67stnAxlWKZV6hVFPr5kh/Xu9jpSSNJCgTEVTZS9EvrPTGtm
         Yp0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=wy8FO9Kpq0mYscU2pRZ988JGN5ZGYBRBcI9oCJCrgeY=;
        b=ua/KFx94gcyRFZGSKDF/z+TY5CuPiojC7VhhKaqXkGsWF7gsu4Ivc3voGfXKOgaQ14
         Rm6AUEkNLeIcSgscFrtQy+fjaC+bE0GJKMSdAsPt/dO2oERZPSMt37V5jZMVWMparBL/
         M0nvwaK8UZQ2Jgrk8wj55dDbzfog1Rd6OEPWEmEQKERTtZ54foYnPHGw3EtlqRSaWheN
         p3D/yrI4oBFCiBYgMKbPAHVnqThbDRmdv8Mct+uGj0vy1Stjs1xdf+qxohQ19rthS+fm
         VKBL6OeSUR4kJV3rwLI2oQ+ArOpdLtA3vs4A9X/d13UnBhTkIXE2qrMb8nBv68XLG1w4
         sXvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=c7vT3JqH;
       spf=neutral (google.com: 40.107.75.71 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750071.outbound.protection.outlook.com. [40.107.75.71])
        by mx.google.com with ESMTPS id b11si598851qvr.183.2019.07.02.19.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Jul 2019 19:27:24 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.75.71 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.75.71;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=c7vT3JqH;
       spf=neutral (google.com: 40.107.75.71 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=wy8FO9Kpq0mYscU2pRZ988JGN5ZGYBRBcI9oCJCrgeY=;
 b=c7vT3JqHuw5GLWBbDW+KTW8nsyMU+XPiZAj5jbIgC/Ke4rsXrkwaI4CY/X58owwLlI4pT3IPzHdc1BD0OcCVtz4lnqWodvOvvqe6Ceqsy46RoQBp30rTcYToq0d97i68u0BVTG2y2jGlJMPoUIcDUXld7eu8tGSSnKELVL6NEp4=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB2873.namprd12.prod.outlook.com (20.179.71.82) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2032.20; Wed, 3 Jul 2019 02:27:22 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::91a2:f9e7:8c86:f927%7]) with mapi id 15.20.2032.019; Wed, 3 Jul 2019
 02:27:22 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, David Airlie
	<airlied@linux.ie>
CC: Ralph Campbell <rcampbell@nvidia.com>, Jerome Glisse <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Topic: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Index: AQHVHY88L0Ra3sy2MEC8cRT/FiJ1Iqa35H2AgAAxIACAAALQAIAAOiIA
Date: Wed, 3 Jul 2019 02:27:22 +0000
Message-ID: <1dc82dc8-3e6f-1d6f-b14d-41ae3c1b2709@amd.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
 <20190702195317.GT31718@mellanox.com> <20190702224912.GA24043@lst.de>
 <20190702225911.GA11833@mellanox.com>
In-Reply-To: <20190702225911.GA11833@mellanox.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
x-clientproxiedby: YTXPR0101CA0037.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::14) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f4c43e91-ac3d-445c-4f9c-08d6ff5dfa93
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM6PR12MB2873;
x-ms-traffictypediagnostic: DM6PR12MB2873:
x-microsoft-antispam-prvs:
 <DM6PR12MB28738436ECA864445C0B152292FB0@DM6PR12MB2873.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1443;
x-forefront-prvs: 00872B689F
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(396003)(136003)(346002)(39860400002)(366004)(376002)(189003)(199004)(486006)(2906002)(4326008)(476003)(36756003)(256004)(99286004)(2616005)(65956001)(64126003)(446003)(71200400001)(11346002)(64756008)(66556008)(53546011)(6486002)(65826007)(66446008)(66946007)(110136005)(66476007)(86362001)(478600001)(3846002)(58126008)(31696002)(6116002)(5660300002)(71190400001)(66066001)(6246003)(25786009)(65806001)(73956011)(186003)(229853002)(7736002)(53936002)(52116002)(6436002)(7416002)(6512007)(26005)(8936002)(68736007)(6506007)(316002)(76176011)(102836004)(81156014)(8676002)(81166006)(31686004)(54906003)(386003)(14454004)(305945005)(72206003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB2873;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 T4A0SOEZuvMXDc2GJkaoVOja/4vmbBgDv1OJqL5jnyITlxTrHw/QCxACcsNEfaG5ELCf+S4PdsOwcmvxwy7ueYuhuwQ/YE/QSw6R7nwaGysRm8t3sNeJmVjbvNGkecAK7BTu1+S52Q4Zw1QqD0CP36p1De2eqy05E3XOfFty0OEgqJWFfDNXFh9gQ0+nNNFZz2cjKaH7C8TLsfNrS16JZtux4j8kh7hRy7JY2aJeBHEAXABU5nBpjUJXjaRs7aeNFKDGypocWd5pEWx0alb3pUFmeTpMpnn74Y0jCz3RYBQkGc4y8B0kYHC37wkqxAiYbHcmvOk53x/BvVO0t2BjjSKzKnP8mtWNBi7CKrKc9J39MoxF+0teiggKcPalSBQIlP28lGydZQJpdDTG/y+xbZkUAdOZEzJXlGyRT66pLoo=
Content-Type: text/plain; charset="utf-8"
Content-ID: <545ED388DC4B924F8D65E5F30ACEE5DA@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f4c43e91-ac3d-445c-4f9c-08d6ff5dfa93
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jul 2019 02:27:22.3841
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB2873
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNy0wMiA2OjU5IHAubS4sIEphc29uIEd1bnRob3JwZSB3cm90ZToNCj4gT24gV2Vk
LCBKdWwgMDMsIDIwMTkgYXQgMTI6NDk6MTJBTSArMDIwMCwgQ2hyaXN0b3BoIEhlbGx3aWcgd3Jv
dGU6DQo+PiBPbiBUdWUsIEp1bCAwMiwgMjAxOSBhdCAwNzo1MzoyM1BNICswMDAwLCBKYXNvbiBH
dW50aG9ycGUgd3JvdGU6DQo+Pj4+IEknbSBzZW5kaW5nIHRoaXMgb3V0IG5vdyBzaW5jZSB3ZSBh
cmUgdXBkYXRpbmcgbWFueSBvZiB0aGUgSE1NIEFQSXMNCj4+Pj4gYW5kIEkgdGhpbmsgaXQgd2ls
bCBiZSB1c2VmdWwuDQo+Pj4gVGhpcyBtYWtlIHNvIG11Y2ggc2Vuc2UsIEknZCBsaWtlIHRvIGFw
cGx5IHRoaXMgaW4gaG1tLmdpdCwgaXMgdGhlcmUNCj4+PiBhbnkgb2JqZWN0aW9uPw0KPj4gQXMg
dGhpcyBjcmVhdGVzIGEgc29tZXdoYXQgaGFpcnkgY29uZmxpY3QgZm9yIGFtZGdwdSwgd291bGRu
J3QgaXQgYmUNCj4+IGEgYmV0dGVyIGlkZWEgdG8gd2FpdCBhIGJpdCBhbmQgYXBwbHkgaXQgZmly
c3QgdGhpbmcgZm9yIG5leHQgbWVyZ2UNCj4+IHdpbmRvdz8NCj4gTXkgdGhpbmtpbmcgaXMgdGhh
dCBBTUQgR1BVIGFscmVhZHkgaGFzIGEgbW9uc3RlciBjb25mbGljdCBmcm9tIHRoaXM6DQo+DQo+
ICAgaW50IGhtbV9yYW5nZV9yZWdpc3RlcihzdHJ1Y3QgaG1tX3JhbmdlICpyYW5nZSwNCj4gLSAg
ICAgICAgICAgICAgICAgICAgICBzdHJ1Y3QgbW1fc3RydWN0ICptbSwNCj4gKyAgICAgICAgICAg
ICAgICAgICAgICBzdHJ1Y3QgaG1tX21pcnJvciAqbWlycm9yLA0KPiAgICAgICAgICAgICAgICAg
ICAgICAgICB1bnNpZ25lZCBsb25nIHN0YXJ0LA0KPiAgICAgICAgICAgICAgICAgICAgICAgICB1
bnNpZ25lZCBsb25nIGVuZCwNCj4gICAgICAgICAgICAgICAgICAgICAgICAgdW5zaWduZWQgcGFn
ZV9zaGlmdCk7DQo+DQo+IFNvLCBkZXBlbmRpbmcgb24gaG93IHRoYXQgaXMgcmVzb2x2ZWQgd2Ug
bWlnaHQgd2FudCB0byBkbyBib3RoIEFQSQ0KPiBjaGFuZ2VzIGF0IG9uY2UuDQoNCkkganVzdCBz
ZW50IG91dCBhIGZpeCBmb3IgdGhlIGhtbV9taXJyb3IgQVBJIGNoYW5nZS4NCg0KDQo+DQo+IE9y
IHdlIG1heSBoYXZlIHRvIHJldmVydCB0aGUgYWJvdmUgY2hhbmdlIGF0IHRoaXMgbGF0ZSBkYXRl
Lg0KPg0KPiBXYWl0aW5nIGZvciBBTURHUFUgdGVhbSB0byBkaXNjdXNzIHdoYXQgcHJvY2VzcyB0
aGV5IHdhbnQgdG8gdXNlLg0KDQpZZWFoLCBJJ20gd29uZGVyaW5nIHdoYXQgdGhlIHByb2Nlc3Mg
aXMgbXlzZWxmLiBXaXRoIEhNTSBhbmQgZHJpdmVyIA0KZGV2ZWxvcG1lbnQgaGFwcGVuaW5nIG9u
IGRpZmZlcmVudCBicmFuY2hlcyB0aGVzZSBraW5kcyBvZiBBUEkgY2hhbmdlcyANCmFyZSBwYWlu
ZnVsLiBUaGVyZSBzZWVtcyB0byBiZSBhIGJ1aWx0LWluIGFzc3VtcHRpb24gaW4gdGhlIGN1cnJl
bnQgDQpwcm9jZXNzLCB0aGF0IGNvZGUgZmxvd3MgbW9zdGx5IGluIG9uZSBkaXJlY3Rpb24gYW1k
LXN0YWdpbmctZHJtLW5leHQgLT4gDQpkcm0tbmV4dCAtPiBsaW51eC1uZXh0IC0+IGxpbnV4LiBU
aGF0IGFzc3VtcHRpb24gaXMgYnJva2VuIHdpdGggSE1NIGNvZGUgDQpldm9sdmluZyByYXBpZGx5
IGluIGJvdGggYW1kZ3B1IGFuZCBtbS4NCg0KSWYgd2Ugd2FudCB0byBjb250aW51ZSBkZXZlbG9w
aW5nIEhNTSBkcml2ZXIgY2hhbmdlcyBpbiANCmFtZC1zdGFnaW5nLWRybS1uZXh0LCB3ZSdsbCBu
ZWVkIHRvIHN5bmNocm9uaXplIHdpdGggaG1tLmdpdCBtb3JlIA0KZnJlcXVlbnRseSwgYm90aCB3
YXlzLiBJIGJlbGlldmUgcGFydCBvZiB0aGUgcHJvYmxlbSBpcywgdGhhdCB0aGVyZSBpcyBhIA0K
ZmFpcmx5IGxvbmcgbGVhZC10aW1lIGZyb20gZ2V0dGluZyBjaGFuZ2VzIGZyb20gYW1kLXN0YWdp
bmctZHJtLW5leHQgDQppbnRvIGxpbnV4LW5leHQsIGFzIHRoZXkgYXJlIGhlbGQgZm9yIG9uZSBy
ZWxlYXNlIGN5Y2xlIGluIGRybS1uZXh0LiANClB1c2hpbmcgSE1NLXJlbGF0ZWQgY2hhbmdlcyB0
aHJvdWdoIGRybS1maXhlcyBtYXkgb2ZmZXIgYSBraW5kIG9mIA0Kc2hvcnRjdXQuIFBoaWxpcCBh
bmQgbXkgbGF0ZXN0IGZpeHVwIGlzIGp1c3QgYnlwYXNzaW5nIGRybS1uZXh0IA0KY29tcGxldGVs
eSBhbmQgZ29pbmcgc3RyYWlnaHQgaW50byBsaW51eC1uZXh0LCB0aG91Z2guDQoNClJlZ2FyZHMs
DQogwqAgRmVsaXgNCg0KDQo+DQo+IEphc29uDQo=

