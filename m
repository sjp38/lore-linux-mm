Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12488C73C65
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 00:34:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4B0320645
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 00:34:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="XjQCg58D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4B0320645
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506198E005F; Tue,  9 Jul 2019 20:34:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B5598E0032; Tue,  9 Jul 2019 20:34:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37E068E005F; Tue,  9 Jul 2019 20:34:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDB048E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 20:34:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so313949eds.14
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 17:34:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=2DXeYGwDAu8XiBRuIFYeU35G8ERKcDs4TKxSlAcuhhQ=;
        b=k5u7ag0LijT2l4r4YdU8Hk7MiIgr57i5xEpTNcbO7QHm710N0cxgu+TfLOq/Mgyjoy
         Az15Uw5Akd0UfvAto8Z3/PV5aOQtAAXtM9gYAw/p4AlBQAx9ytYn0yeG4Xlzc7MCBwpv
         JCLJjpCwZZesFpYlIhcBjxQUWFxNst0G1YL4QND2VsGDH1oa52t1maTepzcr99yYM576
         L7bqdJVINlnwxCiNt1iivy3SKcQL8H82gvPZIEIi1NHHQF6WJtK6Ee4KhkLX6NgKy7c1
         b3TpKc4/DCaI0F1CsXM36qTKSPmd0N30gAIJnQaIgVgToCiFgNNIm7rxKeHO5kXSCd2B
         WcYQ==
X-Gm-Message-State: APjAAAU8xZODyabslpl5ZcJ20ThP9Y+3E40gQ8fmHq2mK5FdETdfQYe3
	3x7pmoXD/i5bjOKlWQra6oMLs81wiFF0MxTyPRyKNn9yP7ZFbqPPpJUNaPSF32cAjAM8YpTWQxq
	fhjzzXH5bz1k9UOP+xkbhWfa65JkJkepNKlv43Bc3tBIXhsefrwZrdB6ON08B3ZWwgg==
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr28546209edr.31.1562718863370;
        Tue, 09 Jul 2019 17:34:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxufSN2im6SYQW5MBn38LgI0AT1EjOmn7BcGYvKyMfrlBhle+bYO/kz6nRvW6qRtFDzLPcM
X-Received: by 2002:a50:eb8f:: with SMTP id y15mr28546168edr.31.1562718862624;
        Tue, 09 Jul 2019 17:34:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562718862; cv=none;
        d=google.com; s=arc-20160816;
        b=Gmx/bmbJGvOecyWw90bHItAAZuxQaLxmd2jkC7EcNgxqY7rqqdNMdGlZBT1pHUIri7
         s0CTNAANAEgg0QS/nJh6jqLYm5uQMLbVstgXObSeK3NWwwIRUHVm90U1DOp5NxHl7YPR
         KZd62ekUj5+DNU+1L45RcegSIkRP3xHgCnripGjMOOVTlYIDTx2W19Zcr7uXmiL4Uv93
         qNoFt6mSJGnlO37o6vngpgii3z5vC4l54RLVO6qfXxNSLzBgKoAqfllKMcpTsgvh/hFv
         W124Q5FB7RWM1TL6z63FV9KG4f0qIigWiFW9q5ftaiMF4ltWSYJMdO/CNApcm4qk9rq6
         Dbgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=2DXeYGwDAu8XiBRuIFYeU35G8ERKcDs4TKxSlAcuhhQ=;
        b=GLlxZ/dwamYgc7USeOAbdcy5dv1oMvpDe3Ppu0mn16fFBfy2OMax1Peln1xgW0XlBF
         sG7MADHnbkmZIXUz69a59XAkhAHBqUldFtVIhhONe8fXLy03mfPlCVx/Bahr4sMCtBQO
         zlDgufAfgN5msfVJeh/X3iqayl7/BQjsIBgdJIIrurrnmjPxyC86GhGVFE+2MzpTfnQ1
         Ts5P6HlHnbL15U3ynpVcIujI4ZvjW9uFIgPFSFKGf206Iw6sF3NtqNVRzjXfV8ab14+B
         /joRLHEAoXTUU2mPu8bq41Jw+kJxm7nERp8Ip7P5N1p2tk30MMaYN8RcGQCd4yGP9H/a
         9yng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=XjQCg58D;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.82.117 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820117.outbound.protection.outlook.com. [40.107.82.117])
        by mx.google.com with ESMTPS id o10si331233ejx.110.2019.07.09.17.34.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Jul 2019 17:34:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.82.117 as permitted sender) client-ip=40.107.82.117;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=XjQCg58D;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.82.117 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2DXeYGwDAu8XiBRuIFYeU35G8ERKcDs4TKxSlAcuhhQ=;
 b=XjQCg58DJh5OWvBF27jHXcjJdIs9et5RPAEB96GUpfBPzRiOvqRix5m2vwihDnxYPRuHYwHpSTSgym0Gi69ZOB1lZQf8TekQ7pemn07PYtvKlW87mISqtx/adYE+YrVW0oIo7oqtHdU2emat+85KTeXBzVtefhwY0aGA/TFXvfU=
Received: from SN6PR01MB4094.prod.exchangelabs.com (52.135.119.23) by
 SN6PR01MB3790.prod.exchangelabs.com (52.132.123.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2052.18; Wed, 10 Jul 2019 00:34:19 +0000
Received: from SN6PR01MB4094.prod.exchangelabs.com
 ([fe80::b958:7797:c21b:5725]) by SN6PR01MB4094.prod.exchangelabs.com
 ([fe80::b958:7797:c21b:5725%5]) with mapi id 15.20.2052.020; Wed, 10 Jul 2019
 00:34:19 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Thomas Gleixner <tglx@linutronix.de>
CC: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador
	<osalvador@suse.de>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike
 Rapoport <rppt@linux.ibm.com>, Alexander Duyck
	<alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Ingo Molnar <mingo@redhat.com>, Borislav
 Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, "David S . Miller"
	<davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily
 Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>
Subject: Re: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WX71HRsQts10W3HaW79T6UP6as+COAgBYe74A=
Date: Wed, 10 Jul 2019 00:34:19 +0000
Message-ID: <1c5bc3a8-0c6f-dce3-95a2-8aec765408a2@os.amperecomputing.com>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
 <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com>
 <alpine.DEB.2.21.1906260032250.32342@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1906260032250.32342@nanos.tec.linutronix.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR06CA0048.namprd06.prod.outlook.com
 (2603:10b6:903:77::34) To SN6PR01MB4094.prod.exchangelabs.com
 (2603:10b6:805:a4::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [27.68.67.201]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bb0fe928-c6f4-4bc5-9d58-08d704ce5894
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:SN6PR01MB3790;
x-ms-traffictypediagnostic: SN6PR01MB3790:
x-microsoft-antispam-prvs:
 <SN6PR01MB37900B4D5DBABBA819D47E45F1F00@SN6PR01MB3790.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0094E3478A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(366004)(376002)(39840400004)(136003)(396003)(189003)(199004)(54534003)(68736007)(66066001)(486006)(2616005)(186003)(6116002)(76176011)(54906003)(31696002)(11346002)(446003)(6246003)(3846002)(316002)(8676002)(107886003)(6916009)(25786009)(478600001)(14454004)(86362001)(6512007)(52116002)(476003)(81156014)(81166006)(66476007)(7736002)(64756008)(66946007)(66556008)(229853002)(256004)(6486002)(386003)(6506007)(26005)(7416002)(66446008)(5660300002)(305945005)(99286004)(53546011)(71200400001)(31686004)(4326008)(53936002)(71190400001)(102836004)(6436002)(2906002)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR01MB3790;H:SN6PR01MB4094.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 S5KyvRHNyHX690M0L8U8FPmcFEGo8JmEPvSX3mb2MAyMU4SIUy55UM7YxwWRYqXNW9DlK1BZeqtX15DF7S83MUVw8KM7/Yh5EwxXNAMZIm2aMteWKVBaiAblNLmqY1P+Hkp1/VBaD1dpfJQBUSIKQ9tNVy++Z/b/Eti+XW4HJiYpXWeynUnxFYbihmOwnJB6jMc+yn2lU3Ym5/qoXasQl2FoQqO7bpv7Cu16BR4XTsBO+m7zpf2IPIQYqM8UpuX3YtsLENYIZzML7TZck88G/vihyLzH7dtDC23Gyinj0Rg0I3m+KhkcOI+/UxigbgpXaMK6QgWdr+d0npL58N7rbE975vRD4m8DUElXDHHO2QwdAxt4oceP9lvtViM78BBUKdTsy/SoeH283AO3R8CevORbimUO56jsuo+6fLlJY6k=
Content-Type: text/plain; charset="utf-8"
Content-ID: <856DBE6A98D2C64F9203DA2E92E3CCD6@prod.exchangelabs.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bb0fe928-c6f4-4bc5-9d58-08d704ce5894
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Jul 2019 00:34:19.5061
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR01MB3790
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgVGhvbWFzLA0KDQpUaGFua3MgZm9yIHlvdSBjb21tZW50cw0KDQpPbiA2LzI1LzE5IDM6NDUg
UE0sIFRob21hcyBHbGVpeG5lciB3cm90ZToNCj4gSG9hbiwNCj4gDQo+IE9uIFR1ZSwgMjUgSnVu
IDIwMTksIEhvYW4gVHJhbiBPUyB3cm90ZToNCj4gDQo+IFBsZWFzZSB1c2UgJ3g4Ni9LY29uZmln
OiAnIGFzIHByZWZpeC4NCj4gDQo+PiBUaGlzIHBhdGNoIHJlbW92ZXMgQ09ORklHX05PREVTX1NQ
QU5fT1RIRVJfTk9ERVMgYXMgaXQncw0KPj4gZW5hYmxlZCBieSBkZWZhdWx0IHdpdGggTlVNQS4N
Cj4gDQo+IFBsZWFzZSBkbyBub3QgdXNlICdUaGlzIHBhdGNoJyBpbiBjaGFuZ2Vsb2dzLiBJdCdz
IHBvaW50bGVzcyBiZWNhdXNlIHdlDQo+IGFscmVhZHkga25vdyB0aGF0IHRoaXMgaXMgYSBwYXRj
aC4NCj4gDQo+IFNlZSBhbHNvIERvY3VtZW50YXRpb24vcHJvY2Vzcy9zdWJtaXR0aW5nLXBhdGNo
ZXMucnN0IGFuZCBzZWFyY2ggZm9yICdUaGlzDQo+IHBhdGNoJw0KPiANCj4gU2ltcGx5IHNheToN
Cj4gDQo+ICAgIFJlbW92ZSBDT05GSUdfTk9ERVNfU1BBTl9PVEhFUl9OT0RFUyBhcyBpdCdzIGVu
YWJsZWQgYnkgZGVmYXVsdCB3aXRoDQo+ICAgIE5VTUEuDQo+IA0KDQpHb3QgaXQsIHdpbGwgZml4
DQoNCj4gQnV0IC4uLi4uDQo+IA0KPj4gQEAgLTE1NjcsMTUgKzE1NjcsNiBAQCBjb25maWcgWDg2
XzY0X0FDUElfTlVNQQ0KPj4gICAJLS0taGVscC0tLQ0KPj4gICAJICBFbmFibGUgQUNQSSBTUkFU
IGJhc2VkIG5vZGUgdG9wb2xvZ3kgZGV0ZWN0aW9uLg0KPj4gICANCj4+IC0jIFNvbWUgTlVNQSBu
b2RlcyBoYXZlIG1lbW9yeSByYW5nZXMgdGhhdCBzcGFuDQo+PiAtIyBvdGhlciBub2Rlcy4gIEV2
ZW4gdGhvdWdoIGEgcGZuIGlzIHZhbGlkIGFuZA0KPj4gLSMgYmV0d2VlbiBhIG5vZGUncyBzdGFy
dCBhbmQgZW5kIHBmbnMsIGl0IG1heSBub3QNCj4+IC0jIHJlc2lkZSBvbiB0aGF0IG5vZGUuICBT
ZWUgbWVtbWFwX2luaXRfem9uZSgpDQo+PiAtIyBmb3IgZGV0YWlscy4NCj4+IC1jb25maWcgTk9E
RVNfU1BBTl9PVEhFUl9OT0RFUw0KPj4gLQlkZWZfYm9vbCB5DQo+PiAtCWRlcGVuZHMgb24gWDg2
XzY0X0FDUElfTlVNQQ0KPiANCj4gdGhlIGNoYW5nZWxvZyBkb2VzIG5vdCBtZW50aW9uIHRoYXQg
dGhpcyBsaWZ0cyB0aGUgZGVwZW5kZW5jeSBvbg0KPiBYODZfNjRfQUNQSV9OVU1BIGFuZCB0aGVy
ZWZvcmUgZW5hYmxlcyB0aGF0IGZ1bmN0aW9uYWxpdHkgZm9yIGFueXRoaW5nDQo+IHdoaWNoIGhh
cyBOVU1BIGVuYWJsZWQgaW5jbHVkaW5nIDMyYml0Lg0KPiANCg0KSSB0aGluayB0aGlzIGNvbmZp
ZyBpcyB1c2VkIGZvciBhIE5VTUEgbGF5b3V0IHdoaWNoIE5VTUEgbm9kZXMgYWRkcmVzc2VzIA0K
YXJlIHNwYW5uZWQgdG8gb3RoZXIgbm9kZXMuIEkgdGhpbmsgMzJiaXQgTlVNQSBhbHNvIGhhdmUg
dGhlIHNhbWUgaXNzdWUgDQp3aXRoIHRoYXQgbGF5b3V0LiBQbGVhc2UgY29ycmVjdCBtZSBpZiBJ
J20gd3JvbmcuDQoNCj4gVGhlIGNvcmUgbW0gY2hhbmdlIGdpdmVzIG5vIGhlbHBmdWwgaW5mb3Jt
YXRpb24gZWl0aGVyLiBZb3UganVzdCBjb3BpZWQgdGhlDQo+IGFib3ZlIGNvbW1lbnQgdGV4dCBm
cm9tIHNvbWUgcmFuZG9tIEtjb25maWcuDQoNClllcywgYXMgaXQncyBhIGNvcnJlY3QgY29tbWVu
dCBhbmQgaXMgdXNlZCBhdCBtdWx0aXBsZSBwbGFjZXMuDQoNClRoYW5rcw0KSG9hbg0KDQo+IA0K
PiBUaGlzIG5lZWRzIGEgYml0IG1vcmUgZGF0YSBpbiB0aGUgY2hhbmdlbG9ncyBhbmQgdGhlIGNv
dmVyIGxldHRlcjoNCj4gDQo+ICAgICAgIC0gV2h5IGlzIGl0IHVzZWZ1bCB0byBlbmFibGUgaXQg
dW5jb25kaXRpb25hbGx5DQo+IA0KPiAgICAgICAtIFdoeSBpcyBpdCBzYWZlIHRvIGRvIHNvLCBl
dmVuIGlmIHRoZSBhcmNoaXRlY3R1cmUgaGFkIGNvbnN0cmFpbnRzIG9uDQo+ICAgICAgICAgaXQN
Cj4gDQo+ICAgICAgIC0gV2hhdCdzIHRoZSBwb3RlbnRpYWwgaW1wYWN0DQo+IA0KPiBUaGFua3Ms
DQo+IA0KPiAJdGdseA0KPiANCg==

