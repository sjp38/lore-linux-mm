Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66B89C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:40:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07A8420863
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 05:40:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="KLugPSwK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07A8420863
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ABF48E0005; Tue, 18 Jun 2019 01:40:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9353A8E0001; Tue, 18 Jun 2019 01:40:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787688E0005; Tue, 18 Jun 2019 01:40:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 535E98E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:40:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id o4so11231406qko.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 22:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Nv/zcxHs3P231QVvyumvym/s1YBuiRl2VWYRhjotz80=;
        b=PX+JwVA9OfQbdO7RSgaEBc/Mtt6v47VAM0LEFTkLXcjgN+UJAyMd+kzO4RetL4UeMA
         jxAc38MYBX1+6o8DbejSD7uIWMCOj/RWcZS7CwJx1jNUHi5i92+YHbep56/399oW+UaE
         ay8DXGJ2XEA1lhzVXoVYxuZAmq2H76vX/gH0fLRNYekW6i4VlER62torHyRnD+M5fWW0
         sd7z106qBy+SfqIUjcXndh166HHaxgpFO8Q49nlL0ZzXvk14XOkoLKspTWm437VOOjKT
         6Q4FFt4i+MomBDWv7bVq8HFSDmpDu9d10XbcMEwtYCDrcF3nIH1GjOoF+bOqqosoOQvM
         FDKw==
X-Gm-Message-State: APjAAAX6MkA5q2+osZE3bDZLqvsR5xLNa+GjfRg7HgIsqQk3qzGFRoFR
	SD+v7ZO7J+t5dnfDpTnzKyOy3Dy+1oVlQkDo3QSvqn9TpXsFxOp5M5CY5Rfil9lWokX2yJr3O+z
	Em6jeZ20SJVoet4FoKNHTEaBkjuFUKVhyxHs2SyNDnFv9vFv6zI4A4YZibB8BgUfdkA==
X-Received: by 2002:ac8:3301:: with SMTP id t1mr92960298qta.209.1560836416056;
        Mon, 17 Jun 2019 22:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqsN/got8QRZCs/EdB3HT6AVWuFYY+GAws4MU4KOdZrIzUhh4B5o/Yaq5XbaCLyxQS0G4m
X-Received: by 2002:ac8:3301:: with SMTP id t1mr92960276qta.209.1560836415470;
        Mon, 17 Jun 2019 22:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560836415; cv=none;
        d=google.com; s=arc-20160816;
        b=gAGb0DcXekD5K5gawd0MTGiILk+UyggScGY8TkLrgvHC7Cc5RsdWWNSr13sWHbqVpt
         x7/H6sTBZ3TDf6tOo21OV2Nb3GQjF76uoRkeaID/5VgrmEUA+hUIAJZYntsniSW+ho5R
         guXRDk9EpxH84uM1+GybzK3y/k2b+7HTDxtcNVmRhCpXnuy3bKo6lzi9Mjmz36IrxN6w
         AfgV+LKS8adxjrQmWwMKQjEXI83PW8WmtP9J8401OcdbMPssdFwC0F5q8VdDlCJs0pX/
         KFqMa+vMKQolN2CvDk6aYlPHvgWxD2NuGsdz5GyCV1fDu5KWg/PfA7LvZXq2rF7Eztp2
         tJ/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Nv/zcxHs3P231QVvyumvym/s1YBuiRl2VWYRhjotz80=;
        b=LUz/ZSsftuLxYKBNUs0errjAKnYb8CxJ58xinjtu+GslgawFgfsVza8bFwHwC5Mhqo
         KY5rRj8HXA59ET6ilphhgU86LCSU+AWl3Dr+YF1Msu2Ra/mXptYQV/Hwq0jJMnz0TjCh
         c/Mti+8CPGVzkUprloy2TOIy8lnbLs8yMQNNHae7g4Qeq5niFJ31P+szENOnokeXHFwL
         +mMTZkzmuutkiH6AapZd76Y+f/Wn/hi/2YjsRCeiORRfVcds3BMCPcNUtiXIqw43XRZd
         /OdRPLQeqO2/LNzC+dN4HNhY8I+SFfyjlc6vzluazv8yOqsBf/n8HxCav57+LojZrnPu
         7eiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=KLugPSwK;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.79.41 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-eopbgr790041.outbound.protection.outlook.com. [40.107.79.41])
        by mx.google.com with ESMTPS id a43si2768857qta.351.2019.06.17.22.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 22:40:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.79.41 as permitted sender) client-ip=40.107.79.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=KLugPSwK;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.79.41 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Nv/zcxHs3P231QVvyumvym/s1YBuiRl2VWYRhjotz80=;
 b=KLugPSwKSuhFecU35KbXOQJy+CyhaE/SaTkoN0ZVpY+dbULOmqr5gh46qxHYysBfcCnqQNqg/Vj3j8dvDt3WgT2LUv0pbrwHc8fVZdQPCv2DoOlIhW76+vpW3NBlO5dvPOAss5vT2o8SKjpYJKEPCQRXRkWEh+/81WMdPjX/WUA=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB5303.namprd05.prod.outlook.com (20.177.127.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.12; Tue, 18 Jun 2019 05:40:11 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Tue, 18 Jun 2019
 05:40:11 +0000
From: Nadav Amit <namit@vmware.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 3/3] resource: Introduce resource cache
Thread-Topic: [PATCH 3/3] resource: Introduce resource cache
Thread-Index: AQHVIaTIgkJbYpRVG0mXAw73pWsOuqag4XgAgAAJ4gCAAAHyAA==
Date: Tue, 18 Jun 2019 05:40:11 +0000
Message-ID: <8072D878-BBF2-47E4-B4C9-190F379F6221@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <20190613045903.4922-4-namit@vmware.com>
 <20190617215750.8e46ae846c09cd5c1f22fdf9@linux-foundation.org>
 <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com>
In-Reply-To: <98464609-8F5A-47B9-A64E-2F67809737AD@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 89928f49-5134-43d9-baa0-08d6f3af6e5b
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB5303;
x-ms-traffictypediagnostic: BYAPR05MB5303:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB5303070CD5B2A73A64CBD4D2D0EA0@BYAPR05MB5303.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(136003)(396003)(39860400002)(346002)(366004)(189003)(199004)(14454004)(6512007)(8676002)(11346002)(3846002)(6306002)(81156014)(86362001)(76176011)(14444005)(446003)(53376002)(486006)(2906002)(186003)(54906003)(6506007)(26005)(2616005)(6116002)(476003)(256004)(53546011)(53936002)(25786009)(229853002)(7416002)(6246003)(7736002)(66556008)(73956011)(66446008)(33656002)(76116006)(305945005)(71190400001)(71200400001)(36756003)(6916009)(66946007)(66476007)(64756008)(66066001)(68736007)(4326008)(5660300002)(6486002)(316002)(966005)(478600001)(81166006)(102836004)(99286004)(8936002)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB5303;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 0qTJE/RW3BxsCA1BFzX2wmx0pmuGX6WxVLS++EyYcaVc15USGWxFOvO5qEoFQTINrIFRLN8XJq1wNpVIBuGJD0qn3E8y++75EVkSWLG8O0Xd9Cihi46qmTNqgZxMFCTCzIm+sRB8ifEAb/za3N1P496dHtDzfviTxU1nmo4Z2INkRhQRH5A6RxU31itjO8AijlCM0ZRF8vttxFI5OZtDJLFc3IBEvyhlxjQCXKVRV8/C+S/mD3dUOtTmSWKbuwzFraMxjIl7SRjzSXMjuk/Hma6dnT9CYqHCN8kP0f0pP6Qz+TER98H5FC1KWgUVHA/NC4dR9ma1DOIDoHkyA6wYZV/NA5r7Pwf1rtwd6i1cnE9GTEzUvw9OYliCExEThmhqVi30BrFZaCy1BcsCoKbuG4st3CBZtUHSOIYdWP8Ean4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <32E999B6085D2041929989B8FECCAD54@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 89928f49-5134-43d9-baa0-08d6f3af6e5b
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 05:40:11.4316
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB5303
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTcsIDIwMTksIGF0IDEwOjMzIFBNLCBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUu
Y29tPiB3cm90ZToNCj4gDQo+PiBPbiBKdW4gMTcsIDIwMTksIGF0IDk6NTcgUE0sIEFuZHJldyBN
b3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+IHdyb3RlOg0KPj4gDQo+PiBPbiBXZWQs
IDEyIEp1biAyMDE5IDIxOjU5OjAzIC0wNzAwIE5hZGF2IEFtaXQgPG5hbWl0QHZtd2FyZS5jb20+
IHdyb3RlOg0KPj4gDQo+Pj4gRm9yIGVmZmljaWVudCBzZWFyY2ggb2YgcmVzb3VyY2VzLCBhcyBu
ZWVkZWQgdG8gZGV0ZXJtaW5lIHRoZSBtZW1vcnkNCj4+PiB0eXBlIGZvciBkYXggcGFnZS1mYXVs
dHMsIGludHJvZHVjZSBhIGNhY2hlIG9mIHRoZSBtb3N0IHJlY2VudGx5IHVzZWQNCj4+PiB0b3At
bGV2ZWwgcmVzb3VyY2UuIENhY2hpbmcgdGhlIHRvcC1sZXZlbCBzaG91bGQgYmUgc2FmZSBhcyBy
YW5nZXMgaW4NCj4+PiB0aGF0IGxldmVsIGRvIG5vdCBvdmVybGFwICh1bmxpa2UgdGhvc2Ugb2Yg
bG93ZXIgbGV2ZWxzKS4NCj4+PiANCj4+PiBLZWVwIHRoZSBjYWNoZSBwZXItY3B1IHRvIGF2b2lk
IHBvc3NpYmxlIGNvbnRlbnRpb24uIFdoZW5ldmVyIGEgcmVzb3VyY2UNCj4+PiBpcyBhZGRlZCwg
cmVtb3ZlZCBvciBjaGFuZ2VkLCBpbnZhbGlkYXRlIGFsbCB0aGUgcmVzb3VyY2VzLiBUaGUNCj4+
PiBpbnZhbGlkYXRpb24gdGFrZXMgcGxhY2Ugd2hlbiB0aGUgcmVzb3VyY2VfbG9jayBpcyB0YWtl
biBmb3Igd3JpdGUsDQo+Pj4gcHJldmVudGluZyBwb3NzaWJsZSByYWNlcy4NCj4+PiANCj4+PiBU
aGlzIHBhdGNoIHByb3ZpZGVzIHJlbGF0aXZlbHkgc21hbGwgcGVyZm9ybWFuY2UgaW1wcm92ZW1l
bnRzIG92ZXIgdGhlDQo+Pj4gcHJldmlvdXMgcGF0Y2ggKH4wLjUlIG9uIHN5c2JlbmNoKSwgYnV0
IGNhbiBiZW5lZml0IHN5c3RlbXMgd2l0aCBtYW55DQo+Pj4gcmVzb3VyY2VzLg0KPj4gDQo+Pj4g
LS0tIGEva2VybmVsL3Jlc291cmNlLmMNCj4+PiArKysgYi9rZXJuZWwvcmVzb3VyY2UuYw0KPj4+
IEBAIC01Myw2ICs1MywxMiBAQCBzdHJ1Y3QgcmVzb3VyY2VfY29uc3RyYWludCB7DQo+Pj4gDQo+
Pj4gc3RhdGljIERFRklORV9SV0xPQ0socmVzb3VyY2VfbG9jayk7DQo+Pj4gDQo+Pj4gKy8qDQo+
Pj4gKyAqIENhY2hlIG9mIHRoZSB0b3AtbGV2ZWwgcmVzb3VyY2UgdGhhdCB3YXMgbW9zdCByZWNl
bnRseSB1c2UgYnkNCj4+PiArICogZmluZF9uZXh0X2lvbWVtX3JlcygpLg0KPj4+ICsgKi8NCj4+
PiArc3RhdGljIERFRklORV9QRVJfQ1BVKHN0cnVjdCByZXNvdXJjZSAqLCByZXNvdXJjZV9jYWNo
ZSk7DQo+PiANCj4+IEEgcGVyLWNwdSBjYWNoZSB3aGljaCBpcyBhY2Nlc3NlZCB1bmRlciBhIGtl
cm5lbC13aWRlIHJlYWRfbG9jayBsb29rcyBhDQo+PiBiaXQgb2RkIC0gdGhlIGxhdGVuY3kgZ2V0
dGluZyBhdCB0aGF0IHJ3bG9jayB3aWxsIHN3YW1wIHRoZSBiZW5lZml0IG9mDQo+PiBpc29sYXRp
bmcgdGhlIENQVXMgZnJvbSBlYWNoIG90aGVyIHdoZW4gYWNjZXNzaW5nIHJlc291cmNlX2NhY2hl
Lg0KPj4gDQo+PiBPbiB0aGUgb3RoZXIgaGFuZCwgaWYgd2UgaGF2ZSBtdWx0aXBsZSBDUFVzIHJ1
bm5pbmcNCj4+IGZpbmRfbmV4dF9pb21lbV9yZXMoKSBjb25jdXJyZW50bHkgdGhlbiB5ZXMsIEkg
c2VlIHRoZSBiZW5lZml0LiAgSGFzDQo+PiB0aGUgYmVuZWZpdCBvZiB1c2luZyBhIHBlci1jcHUg
Y2FjaGUgKHJhdGhlciB0aGFuIGEga2VybmVsLXdpZGUgb25lKQ0KPj4gYmVlbiBxdWFudGlmaWVk
Pw0KPiANCj4gTm8uIEkgYW0gbm90IHN1cmUgaG93IGVhc3kgaXQgd291bGQgYmUgdG8gbWVhc3Vy
ZSBpdC4gT24gdGhlIG90aGVyIGhhbmRlcg0KPiB0aGUgbG9jayBpcyBub3Qgc3VwcG9zZWQgdG8g
YmUgY29udGVuZGVkIChhdCBtb3N0IGNhc2VzKS4gQXQgdGhlIHRpbWUgSSBzYXcNCj4gbnVtYmVy
cyB0aGF0IHNob3dlZCB0aGF0IHN0b3JlcyB0byDigJxleGNsdXNpdmUiIGNhY2hlIGxpbmVzIGNh
biBiZSBhcw0KPiBleHBlbnNpdmUgYXMgYXRvbWljIG9wZXJhdGlvbnMgWzFdLiBJIGFtIG5vdCBz
dXJlIGhvdyB1cCB0byBkYXRlIHRoZXNlDQo+IG51bWJlcnMgYXJlIHRob3VnaC4gSW4gdGhlIGJl
bmNobWFyayBJIHJhbiwgbXVsdGlwbGUgQ1BVcyByYW4NCj4gZmluZF9uZXh0X2lvbWVtX3Jlcygp
IGNvbmN1cnJlbnRseS4NCj4gDQo+IFsxXSBodHRwOi8vc2lnb3BzLm9yZy9zL2NvbmZlcmVuY2Vz
L3Nvc3AvMjAxMy9wYXBlcnMvcDMzLWRhdmlkLnBkZg0KDQpKdXN0IHRvIGNsYXJpZnkgLSB0aGUg
bWFpbiBtb3RpdmF0aW9uIGJlaGluZCB0aGUgcGVyLWNwdSB2YXJpYWJsZSBpcyBub3QNCmFib3V0
IGNvbnRlbnRpb24sIGJ1dCBhYm91dCB0aGUgZmFjdCB0aGUgZGlmZmVyZW50IHByb2Nlc3Nlcy90
aHJlYWRzIHRoYXQNCnJ1biBjb25jdXJyZW50bHkgbWlnaHQgdXNlIGRpZmZlcmVudCByZXNvdXJj
ZXMuDQoNCg==

