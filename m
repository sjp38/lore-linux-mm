Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CF1C43612
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:00:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E60218FF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 19:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E60218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3A088E0009; Thu, 20 Dec 2018 14:00:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEA298E0001; Thu, 20 Dec 2018 14:00:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB1638E0009; Thu, 20 Dec 2018 14:00:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C59A8E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 14:00:08 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id d18so2511923pfe.0
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 11:00:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=QyXExaiMxdhYh04whMVm3dzzxX0lBeK5lTPL74FqLzc=;
        b=V4Oe+f0m7BYtUzpVKpWfluVVolxFYUbBkygIHU3BZ7lHxCDjcsfL+UcMBFO5aBHIyi
         OjzJD2smmmaiAnpaKq+ZuM2AucMuhFcHdhHx3W0eDR371Zde53R95w+1a1d5E3IntfFO
         M5DdS0kfpzmOq+ngHXlF9DJ4eRVQ+Pb6qtyceSmFZUajoHd95ZPcA6N4n8MiX+RGEdZv
         hcBaMTEF28MmLYkXxgawgyVSBm83MDBfQaDZ3cLJXAalso1Ka2uvsl3btf4/3xcgoo7Q
         atZOgaLsGww/pr3ZkZKCEWo8i4fU9/lYWfHnBNXp59lpRthy1xaM6RcZCiXrF8H1EqBO
         XZFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of erik.schmauss@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=erik.schmauss@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWYhqm0REOPcH2TS5KlfG1TsB5UzppG+tR4ceTthAhm+mlZ4GwQP
	Ql3fqtnAEBQ6zC/SqYav5s8/mDEuHqaP+05Jg+J2e8BqXuTNh+vlYPRVvi2hAxyvupnueDa9wCI
	XXpkxR4+uENR/jTDXyOPqlj7iizrsUBfgy0trvKh60wWgAwcnIu6Ag2m7Zmh7vzbaYA==
X-Received: by 2002:a17:902:f44:: with SMTP id 62mr25546004ply.38.1545332408156;
        Thu, 20 Dec 2018 11:00:08 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XDZUbmEJfckICxsCiSzbFYkggOXhKmIjk4hFJyuOQqiBnoyeM3hR3RlCMPxiFcr2HbEbuB
X-Received: by 2002:a17:902:f44:: with SMTP id 62mr25545942ply.38.1545332407100;
        Thu, 20 Dec 2018 11:00:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545332407; cv=none;
        d=google.com; s=arc-20160816;
        b=oQOcHRHUQGyUMRCZVg5lom+Mk+R7+2uBWOAkZqskK8orxWLOHm3vCxBr1u9Vf+r8Rj
         OdDNlBZBd2jRg2FUWAbZ4KhRntDSEHQNyOHURh41XatgD0v4cqQO5Y2WQ8W6UwdhX2DM
         nwKtRom237kfu1P+fOgMZC1selrR7XTWolJzYsfRwtl/JJQ8qMgu4Dk1lqk8MVBBQgZY
         1vs5PCGCkuF1CyR3uFA2nnZkKF+aGgHZxoSjN//4iiFMAlY5YwBg9t/46lJLtuY7eDeS
         QzXMB7g7LQaxzx6CYxQMAoLUmoqkPsCgfbfwh42xzkigqHZtq74YDXa78ToI4jEzZ4/f
         CBcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=QyXExaiMxdhYh04whMVm3dzzxX0lBeK5lTPL74FqLzc=;
        b=LpJLR1c9qOYsW/yRFicVGN6TjLoUXiH+M57J4pBlguljeZWu73EC9oRlRk/AShdgWu
         sZUngWMVrEAwIVMFdXcswZsMYrU37xAAkIrKel8a6S2yEtFuUP1k5S1cInOFeevBLYdt
         IbG4Vf2RYQ7y5f9DYMrkB0AkQKh/ErLrhvTPyKlAFy/yHPW8m9OLQy6ynGUhscYpYoVn
         LudaH+LEep/bRK7NNv1Kx8LkHhjbnQz0FRQzUJjIhLUQNU12oPSAaKhBgkbfOjlVmgYP
         vNzofkW8dboDtpJ80fteXxWrbSbNdOvpU0xGRCn+hHuambRi/bYa5t3jI67WImogRu9j
         Rf9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of erik.schmauss@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=erik.schmauss@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b91si17778847plb.11.2018.12.20.11.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 11:00:07 -0800 (PST)
Received-SPF: pass (google.com: domain of erik.schmauss@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of erik.schmauss@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=erik.schmauss@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Dec 2018 11:00:06 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,378,1539673200"; 
   d="scan'208";a="120029870"
Received: from orsmsx101.amr.corp.intel.com ([10.22.225.128])
  by FMSMGA003.fm.intel.com with ESMTP; 20 Dec 2018 11:00:06 -0800
Received: from orsmsx153.amr.corp.intel.com (10.22.226.247) by
 ORSMSX101.amr.corp.intel.com (10.22.225.128) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 20 Dec 2018 11:00:06 -0800
Received: from orsmsx122.amr.corp.intel.com ([169.254.11.103]) by
 ORSMSX153.amr.corp.intel.com ([169.254.12.130]) with mapi id 14.03.0415.000;
 Thu, 20 Dec 2018 11:00:05 -0800
From: "Schmauss, Erik" <erik.schmauss@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
CC: "Williams, Dan J" <dan.j.williams@intel.com>, "Busch, Keith"
	<keith.busch@intel.com>, "Moore, Robert" <robert.moore@intel.com>, "Linux
 Kernel Mailing List" <linux-kernel@vger.kernel.org>, ACPI Devel Maling List
	<linux-acpi@vger.kernel.org>, Linux Memory Management List
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Hansen, Dave" <dave.hansen@intel.com>, "Box, David E"
	<david.e.box@intel.com>
Subject: RE: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Thread-Topic: [PATCHv2 01/12] acpi: Create subtable parsing infrastructure
Thread-Index: AQHUkO3XM2Ol/XZNM0q95bVci98IHqV50HwAgAzrutCAAJXiAP//iW7QgAEMt4CAACBaYA==
Date: Thu, 20 Dec 2018 19:00:05 +0000
Message-ID:
 <CF6A88132359CE47947DB4C6E1709ED53C557FBF@ORSMSX122.amr.corp.intel.com>
References: <20181211010310.8551-1-keith.busch@intel.com>
 <20181211010310.8551-2-keith.busch@intel.com>
 <CAJZ5v0iqC2CwR2nM7eF6pDcJe2Me-_fFekX=s16-1TGZ6f6gcA@mail.gmail.com>
 <CF6A88132359CE47947DB4C6E1709ED53C557D62@ORSMSX122.amr.corp.intel.com>
 <CAPcyv4jmGH0FS8iBP9=A-nicNfgHAmU+nBHsGgxyS3RNZ9tV5Q@mail.gmail.com>
 <CF6A88132359CE47947DB4C6E1709ED53C557DAB@ORSMSX122.amr.corp.intel.com>
 <CAJZ5v0iMf15tC6xLwCC8G2DuDazvznPe-BGJ7F+_r384wBRCCA@mail.gmail.com>
In-Reply-To: <CAJZ5v0iMf15tC6xLwCC8G2DuDazvznPe-BGJ7F+_r384wBRCCA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.22.254.139]
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220190005.QsfYULL58ZJ9Kibuq1bmsG1OhNe0U63gxDpslmJHR20@z>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUmFmYWVsIEouIFd5c29j
a2kgW21haWx0bzpyYWZhZWxAa2VybmVsLm9yZ10NCj4gU2VudDogVGh1cnNkYXksIERlY2VtYmVy
IDIwLCAyMDE4IDEyOjU3IEFNDQo+IFRvOiBTY2htYXVzcywgRXJpayA8ZXJpay5zY2htYXVzc0Bp
bnRlbC5jb20+DQo+IENjOiBXaWxsaWFtcywgRGFuIEogPGRhbi5qLndpbGxpYW1zQGludGVsLmNv
bT47IFJhZmFlbCBKLiBXeXNvY2tpDQo+IDxyYWZhZWxAa2VybmVsLm9yZz47IEJ1c2NoLCBLZWl0
aCA8a2VpdGguYnVzY2hAaW50ZWwuY29tPjsgTW9vcmUsDQo+IFJvYmVydCA8cm9iZXJ0Lm1vb3Jl
QGludGVsLmNvbT47IExpbnV4IEtlcm5lbCBNYWlsaW5nIExpc3QgPGxpbnV4LQ0KPiBrZXJuZWxA
dmdlci5rZXJuZWwub3JnPjsgQUNQSSBEZXZlbCBNYWxpbmcgTGlzdCA8bGludXgtDQo+IGFjcGlA
dmdlci5rZXJuZWwub3JnPjsgTGludXggTWVtb3J5IE1hbmFnZW1lbnQgTGlzdCA8bGludXgtDQo+
IG1tQGt2YWNrLm9yZz47IEdyZWcgS3JvYWgtSGFydG1hbg0KPiA8Z3JlZ2toQGxpbnV4Zm91bmRh
dGlvbi5vcmc+OyBIYW5zZW4sIERhdmUNCj4gPGRhdmUuaGFuc2VuQGludGVsLmNvbT4NCj4gU3Vi
amVjdDogUmU6IFtQQVRDSHYyIDAxLzEyXSBhY3BpOiBDcmVhdGUgc3VidGFibGUgcGFyc2luZw0K
PiBpbmZyYXN0cnVjdHVyZQ0KPiANCj4gT24gVGh1LCBEZWMgMjAsIDIwMTggYXQgMjoxNSBBTSBT
Y2htYXVzcywgRXJpaw0KPiA8ZXJpay5zY2htYXVzc0BpbnRlbC5jb20+IHdyb3RlOg0KPiA+DQo+
ID4NCj4gPg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gPiA+IEZyb206IGxp
bnV4LWFjcGktb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bGludXgtYWNwaS0NCj4gPiA+
IG93bmVyQHZnZXIua2VybmVsLm9yZ10gT24gQmVoYWxmIE9mIERhbiBXaWxsaWFtcw0KPiA+ID4g
U2VudDogV2VkbmVzZGF5LCBEZWNlbWJlciAxOSwgMjAxOCA0OjAwIFBNDQo+ID4gPiBUbzogU2No
bWF1c3MsIEVyaWsgPGVyaWsuc2NobWF1c3NAaW50ZWwuY29tPg0KPiA+ID4gQ2M6IFJhZmFlbCBK
LiBXeXNvY2tpIDxyYWZhZWxAa2VybmVsLm9yZz47IEJ1c2NoLCBLZWl0aA0KPiA+ID4gPGtlaXRo
LmJ1c2NoQGludGVsLmNvbT47IE1vb3JlLCBSb2JlcnQNCj4gPHJvYmVydC5tb29yZUBpbnRlbC5j
b20+Ow0KPiA+ID4gTGludXggS2VybmVsIE1haWxpbmcgTGlzdCA8bGludXgta2VybmVsQHZnZXIu
a2VybmVsLm9yZz47IEFDUEkNCj4gRGV2ZWwNCj4gPiA+IE1hbGluZyBMaXN0IDxsaW51eC1hY3Bp
QHZnZXIua2VybmVsLm9yZz47IExpbnV4IE1lbW9yeQ0KPiBNYW5hZ2VtZW50DQo+ID4gPiBMaXN0
IDxsaW51eC1tbUBrdmFjay5vcmc+OyBHcmVnIEtyb2FoLUhhcnRtYW4NCj4gPiA+IDxncmVna2hA
bGludXhmb3VuZGF0aW9uLm9yZz47IEhhbnNlbiwgRGF2ZQ0KPiA8ZGF2ZS5oYW5zZW5AaW50ZWwu
Y29tPg0KPiA+ID4gU3ViamVjdDogUmU6IFtQQVRDSHYyIDAxLzEyXSBhY3BpOiBDcmVhdGUgc3Vi
dGFibGUgcGFyc2luZw0KPiA+ID4gaW5mcmFzdHJ1Y3R1cmUNCj4gPiA+DQo+ID4gPiBPbiBXZWQs
IERlYyAxOSwgMjAxOCBhdCAzOjE5IFBNIFNjaG1hdXNzLCBFcmlrDQo+ID4gPiA8ZXJpay5zY2ht
YXVzc0BpbnRlbC5jb20+IHdyb3RlOg0KPiA+ID4gPg0KPiA+ID4gPg0KPiA+ID4gPg0KPiA+ID4g
PiA+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gPiA+ID4gRnJvbTogbGludXgtYWNw
aS1vd25lckB2Z2VyLmtlcm5lbC5vcmcgW21haWx0bzpsaW51eC1hY3BpLQ0KPiA+ID4gPiA+IG93
bmVyQHZnZXIua2VybmVsLm9yZ10gT24gQmVoYWxmIE9mIFJhZmFlbCBKLiBXeXNvY2tpDQo+ID4g
PiA+ID4gU2VudDogVHVlc2RheSwgRGVjZW1iZXIgMTEsIDIwMTggMTo0NSBBTQ0KPiA+ID4gPiA+
IFRvOiBCdXNjaCwgS2VpdGggPGtlaXRoLmJ1c2NoQGludGVsLmNvbT4NCj4gPiA+ID4gPiBDYzog
TGludXggS2VybmVsIE1haWxpbmcgTGlzdCA8bGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZz47
DQo+ID4gPiA+ID4gQUNQSSBEZXZlbCBNYWxpbmcgTGlzdCA8bGludXgtYWNwaUB2Z2VyLmtlcm5l
bC5vcmc+OyBMaW51eA0KPiA+ID4gPiA+IE1lbW9yeSBNYW5hZ2VtZW50IExpc3QgPGxpbnV4LW1t
QGt2YWNrLm9yZz47IEdyZWcNCj4gS3JvYWgtSGFydG1hbg0KPiA+ID4gPiA+IDxncmVna2hAbGlu
dXhmb3VuZGF0aW9uLm9yZz47IFJhZmFlbCBKLiBXeXNvY2tpDQo+ID4gPiA8cmFmYWVsQGtlcm5l
bC5vcmc+Ow0KPiA+ID4gPiA+IEhhbnNlbiwgRGF2ZSA8ZGF2ZS5oYW5zZW5AaW50ZWwuY29tPjsg
V2lsbGlhbXMsIERhbiBKDQo+ID4gPiA+ID4gPGRhbi5qLndpbGxpYW1zQGludGVsLmNvbT4NCj4g
PiA+ID4gPiBTdWJqZWN0OiBSZTogW1BBVENIdjIgMDEvMTJdIGFjcGk6IENyZWF0ZSBzdWJ0YWJs
ZSBwYXJzaW5nDQo+ID4gPiA+ID4gaW5mcmFzdHJ1Y3R1cmUNCj4gPiA+ID4gPg0KPiA+ID4gPiA+
IE9uIFR1ZSwgRGVjIDExLCAyMDE4IGF0IDI6MDUgQU0gS2VpdGggQnVzY2gNCj4gPiA+IDxrZWl0
aC5idXNjaEBpbnRlbC5jb20+DQo+ID4gPiA+ID4gd3JvdGU6DQo+ID4gPiA+ID4gPg0KPiA+ID4g
Pg0KPiA+ID4gPiBIaSBSYWZhZWwgYW5kIEJvYiwNCj4gPiA+ID4NCj4gPiA+ID4gPiA+IFBhcnNp
bmcgZW50cmllcyBpbiBhbiBBQ1BJIHRhYmxlIGhhZCBhc3N1bWVkIGEgZ2VuZXJpYyBoZWFkZXIN
Cj4gPiA+ID4gPiA+IHN0cnVjdHVyZSB0aGF0IGlzIG1vc3QgY29tbW9uLiBUaGVyZSBpcyBubyBz
dGFuZGFyZCBBQ1BJDQo+ID4gPiBoZWFkZXIsDQo+ID4gPiA+ID4gPiB0aG91Z2gsIHNvIGxlc3Mg
Y29tbW9uIHR5cGVzIHdvdWxkIG5lZWQgY3VzdG9tIHBhcnNlcnMgaWYNCj4gdGhleQ0KPiA+ID4g
PiA+ID4gd2FudCBnbyB0aHJvdWdoIHRoZWlyIHN1Yi10YWJsZSBlbnRyeSBsaXN0Lg0KPiA+ID4g
PiA+DQo+ID4gPiA+ID4gSXQgbG9va3MgbGlrZSB0aGUgcHJvYmxlbSBhdCBoYW5kIGlzIHRoYXQg
YWNwaV9obWF0X3N0cnVjdHVyZSBpcw0KPiA+ID4gPiA+IGluY29tcGF0aWJsZSB3aXRoIGFjcGlf
c3VidGFibGVfaGVhZGVyIGJlY2F1c2Ugb2YgdGhlDQo+IGRpZmZlcmVudA0KPiA+ID4gbGF5b3V0
IGFuZCBmaWVsZCBzaXplcy4NCj4gPiA+ID4NCj4gPiA+ID4gSnVzdCBvdXQgb2YgY3VyaW9zaXR5
LCB3aHkgZG9uJ3Qgd2UgdXNlIEFDUElDQSBjb2RlIHRvIHBhcnNlDQo+ID4gPiA+IHN0YXRpYyBB
Q1BJIHRhYmxlcyBpbiBMaW51eD8NCj4gPiA+ID4NCj4gPiA+ID4gV2UgaGF2ZSBhIGRpc2Fzc2Vt
YmxlciBmb3Igc3RhdGljIHRhYmxlcyB0aGF0IHBhcnNlcyBhbGwgc3VwcG9ydGVkDQo+ID4gPiA+
IHRhYmxlcy4gVGhpcyBzZWVtcyBsaWtlIGEgZHVwbGljYXRpb24gb2YgY29kZS9lZmZvcnQuLi4N
Cj4gPiA+DQo+ID4gSGkgRGFuLA0KPiA+DQo+ID4gPiBPaCwgSSB0aG91Z2h0IGFjcGlfdGFibGVf
cGFyc2VfZW50cmllcygpIHdhcyB0aGUgY29tbW9uIGNvZGUuDQo+ID4gPiBXaGF0J3MgdGhlIEFD
UElDQSBkdXBsaWNhdGU/DQo+ID4NCj4gPiBJIHdhcyB0aGlua2luZyBBY3BpRG1EdW1wVGFibGUo
KS4gQWZ0ZXIgbG9va2luZyBhdCB0aGlzIEFDUElDQQ0KPiBjb2RlLCBJDQo+ID4gcmVhbGl6ZWQg
dGhhdCB0aGUgdGhpcyBBQ1BJQ0EgZG9lc24ndCBhY3R1YWxseSBidWlsZCBhIHBhcnNlIHRyZWUg
b3INCj4gZGF0YSBzdHJ1Y3R1cmUuDQo+ID4gSXQgbG9vcHMgb3ZlciB0aGUgZGF0YSBzdHJ1Y3R1
cmUgdG8gZm9ybWF0IHRoZSBpbnB1dCBBQ1BJIHRhYmxlIHRvIGENCj4gZmlsZS4NCj4gPg0KPiA+
IFRvIG1lLCBpdCBzZWVtcyBsaWtlIGEgZ29vZCBpZGVhIGZvciBMaW51eCBhbmQgQUNQSUNBIHRv
IHNoYXJlIHRoZQ0KPiA+IHNhbWUgY29kZSB3aGVuIHBhcnNpbmcgYW5kIGFuYWx5emluZyB0aGVz
ZSBzdHJ1Y3R1cmVzLiBJIGtub3cgdGhhdA0KPiA+IExpbnV4IG1heSBlbWl0IHdhcm5pbmdzIHRo
YXQgYXJlIHNwZWNpZmljIHRvIExpbnV4IGJ1dCB0aGVyZSBhcmUNCj4gPiBzdHJ1Y3R1cmFsIGFu
YWx5c2VzIHRoYXQgc2hvdWxkIGJlIHRoZSBzYW1lIChzdWNoIGFzIGNoZWNraW5nIGxlbmd0aHMN
Cj4gb2YgdGFibGVzIGFuZCBzdWJ0YWJsZXMgc28gdGhhdCB3ZSBkb24ndCBoYXZlIG91dCBvZiBi
b3VuZHMgYWNjZXNzKS4NCj4gDQo+IEkgYWdyZWUuDQo+IA0KPiBJIGd1ZXNzIHRoZSByZWFzb24g
d2h5IGl0IGhhcyBub3QgYmVlbiBkb25lIHRoaXMgd2F5IHdhcyBiZWNhdXNlDQo+IG5vYm9keSB0
aG91Z2h0IGFib3V0IGl0LiA6LSkNCj4gDQo+IFNvIGEgcHJvamVjdCB0byBjb25zb2xpZGF0ZSB0
aGVzZSB0aGluZ3MgbWlnaHQgYmUgYSBnb29kIG9uZS4NCg0KT2ssIEknbGwgdGFsayB0byBCb2Ig
YWJvdXQgaXQgYW5kIHNlZSB3aGF0IHdlIGNhbiBkbw0K

