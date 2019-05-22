Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FE2CC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:26:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D6FA217D7
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 19:26:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D6FA217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C5C046B000A; Wed, 22 May 2019 15:26:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0BEF6B000C; Wed, 22 May 2019 15:26:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B21F86B000D; Wed, 22 May 2019 15:26:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 785C06B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 15:26:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so2246412pga.4
        for <linux-mm@kvack.org>; Wed, 22 May 2019 12:26:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=LMcD+MiyR5Go5Myn8jzAh8kN4gytsSqu0GsEtk+5NVc=;
        b=PXyFjzAPu19VaQSkViVi644tfz9tIYDNZ35fqhHzfy2YI1qPcSakfYsKps8nS9Rsw3
         RPelP44b23Ek7DfXAJCfhVT0d0hh4qz40TIwunyOUsogBwfJ2cmNN+b/VZ7eCoUy9qT7
         HX9v3czU8ZjnXieHMJqua1TX063C8H4MbW49nMRfU4E9fnrNlq6i7b0VPaHvoyNXDQPl
         EucDJvJcsXCe39IGlbAxPdPEhqlfOvqXJD8eV/tGkuMsuRijFLyrKQPDFBt+BFqp0kK1
         oeSJI4cTRZ5GwmUGMVnAIRs9oEdlI/4VLcUZLYXifqDoir+WMwLDX/tzLC5brp14yqid
         hcNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjeaPqoKHnzzvOHh20tnZJV91MoPiZ/nSzISqHolvs/IMBa3S+
	TDSybx1T0r3ZVy5lMYsBnTY7AbeqtFPh2dVE9ebbBILKwQiyTjd8bkHkTgH3H170TjHF21OHBfC
	MIhS8r1LrvvzSk50I3YNRJELKjOCO3ZxGP1R2GTQzE0FCTJT+Co/jJVsY4TN8RuJoHw==
X-Received: by 2002:a62:bd14:: with SMTP id a20mr96734430pff.107.1558553210128;
        Wed, 22 May 2019 12:26:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyc6kORHtc6xI1ApZzG4qHCv8rpLOt8fLdURJvM7QnQP8Pp9klLvBLuUhfJ2uhAeO1CK1kb
X-Received: by 2002:a62:bd14:: with SMTP id a20mr96734349pff.107.1558553209210;
        Wed, 22 May 2019 12:26:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558553209; cv=none;
        d=google.com; s=arc-20160816;
        b=vdLbowI6JePlOMEQW41zXG+XgWrFtr6S+XNdwRaYBnzsml1Gm6wvTiVYzMbtvzZTey
         UgnD6C9j+P/Fshclb9t4089dV1RbYsAtyU0Jqa3FlauiUaC3bnnk7nEgsEvbNyndr1Tg
         /Yf90Jae3GsxuFarjE7TVwGIn7eNeXVtkTPDXEN2sx+chz7bsPhTmDwn6+PdV8kxTiXX
         rvo1Y1hpYfwVCVte32SODGR7iAHc0tNY5HmGThVvDW08+oWeWupUmlZEdfqIT9DWxKI8
         l+OKIZG0ERn4RGkE6kOPAo7zoLLM4b8eaX8BBbqAAJaJ/d2HOIaDn/W16+rq8nCV/eLj
         Su3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=LMcD+MiyR5Go5Myn8jzAh8kN4gytsSqu0GsEtk+5NVc=;
        b=KDJ2+ZqsV1S927Vj4gNOqR6xcGv5Aa8iMdV8jCNLx80K4UBOKbSOb/NG16NT8Tg0De
         awdc6WNG3i9GKfMoXsDRg+uQYOC5pnjB5xLtp9/RZq2Xe+9Z3Zx89onIw9zCv0Yur30r
         rlQeKhuyFin8uBWotp2+lJ3J6I6W8Is3l9vfVR2kONZNkFirit9w11kZ72zkizSGacYi
         4NjkkTpcZexZ4qzmXbzUYs6iRB6Pvr4YonrBsWadMbgp+4Gl1bgEFAZXCxpjLtomwKiL
         rLBt4P01oZ8BBwI5yD2tlQFr1T0pqHQpw90CL7jamN904yN3IPzeze4iSmNCbY1fZJj8
         3apA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d191si24854100pgc.460.2019.05.22.12.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 12:26:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 May 2019 12:26:48 -0700
X-ExtLoop1: 1
Received: from orsmsx102.amr.corp.intel.com ([10.22.225.129])
  by orsmga002.jf.intel.com with ESMTP; 22 May 2019 12:26:48 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX102.amr.corp.intel.com ([169.254.3.72]) with mapi id 14.03.0415.000;
 Wed, 22 May 2019 12:26:47 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "davem@davemloft.net" <davem@davemloft.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "mroos@linux.ee" <mroos@linux.ee>, "mingo@redhat.com"
	<mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, "luto@kernel.org"
	<luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwCAAAiygIAAGYEAgAADqwCAAA0vgIAABnMAgAAEjYCAApkWgIAAHb0A
Date: Wed, 22 May 2019 19:26:47 +0000
Message-ID: <01a23900329e605fcd41ad8962cfd8f2d9b1fa44.camel@intel.com>
References: <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
	 <20190520.184336.743103388474716249.davem@davemloft.net>
	 <339ef85d984f329aa66f29fa80781624e6e4aecc.camel@intel.com>
	 <20190522.104019.40493905027242516.davem@davemloft.net>
In-Reply-To: <20190522.104019.40493905027242516.davem@davemloft.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.91.116]
Content-Type: text/plain; charset="utf-8"
Content-ID: <8DA560705D778D4A9D23CAF3ED2AB2FC@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTIyIGF0IDEwOjQwIC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0K
PiBEYXRlOiBUdWUsIDIxIE1heSAyMDE5IDAxOjU5OjU0ICswMDAwDQo+IA0KPiA+IE9uIE1vbiwg
MjAxOS0wNS0yMCBhdCAxODo0MyAtMDcwMCwgRGF2aWQgTWlsbGVyIHdyb3RlOg0KPiA+ID4gRnJv
bTogIkVkZ2Vjb21iZSwgUmljayBQIiA8cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+DQo+ID4g
PiBEYXRlOiBUdWUsIDIxIE1heSAyMDE5IDAxOjIwOjMzICswMDAwDQo+ID4gPiANCj4gPiA+ID4g
U2hvdWxkIGl0IGhhbmRsZSBleGVjdXRpbmcgYW4gdW5tYXBwZWQgcGFnZSBncmFjZWZ1bGx5PyBC
ZWNhdXNlDQo+ID4gPiA+IHRoaXMNCj4gPiA+ID4gY2hhbmdlIGlzIGNhdXNpbmcgdGhhdCB0byBo
YXBwZW4gbXVjaCBlYXJsaWVyLiBJZiBzb21ldGhpbmcgd2FzDQo+ID4gPiA+IHJlbHlpbmcNCj4g
PiA+ID4gb24gYSBjYWNoZWQgdHJhbnNsYXRpb24gdG8gZXhlY3V0ZSBzb21ldGhpbmcgaXQgY291
bGQgZmluZCB0aGUNCj4gPiA+ID4gbWFwcGluZw0KPiA+ID4gPiBkaXNhcHBlYXIuDQo+ID4gPiAN
Cj4gPiA+IERvZXMgdGhpcyB3b3JrIGJ5IG5vdCBtYXBwaW5nIGFueSBrZXJuZWwgbWFwcGluZ3Mg
YXQgdGhlDQo+ID4gPiBiZWdpbm5pbmcsDQo+ID4gPiBhbmQgdGhlbiBmaWxsaW5nIGluIHRoZSBC
UEYgbWFwcGluZ3MgaW4gcmVzcG9uc2UgdG8gZmF1bHRzPw0KPiA+IE5vLCBub3RoaW5nIHRvbyBm
YW5jeS4gSXQganVzdCBmbHVzaGVzIHRoZSB2bSBtYXBwaW5nIGltbWVkaWF0bHkgaW4NCj4gPiB2
ZnJlZSBmb3IgZXhlY3V0ZSAoYW5kIFJPKSBtYXBwaW5ncy4gVGhlIG9ubHkgdGhpbmcgdGhhdCBo
YXBwZW5zDQo+ID4gYXJvdW5kDQo+ID4gYWxsb2NhdGlvbiB0aW1lIGlzIHNldHRpbmcgb2YgYSBu
ZXcgZmxhZyB0byB0ZWxsIHZtYWxsb2MgdG8gZG8gdGhlDQo+ID4gZmx1c2guDQo+ID4gDQo+ID4g
VGhlIHByb2JsZW0gYmVmb3JlIHdhcyB0aGF0IHRoZSBwYWdlcyB3b3VsZCBiZSBmcmVlZCBiZWZv
cmUgdGhlDQo+ID4gZXhlY3V0ZQ0KPiA+IG1hcHBpbmcgd2FzIGZsdXNoZWQuIFNvIHRoZW4gd2hl
biB0aGUgcGFnZXMgZ290IHJlY3ljbGVkLCByYW5kb20sDQo+ID4gc29tZXRpbWVzIGNvbWluZyBm
cm9tIHVzZXJzcGFjZSwgZGF0YSB3b3VsZCBiZSBtYXBwZWQgYXMgZXhlY3V0YWJsZQ0KPiA+IGlu
DQo+ID4gdGhlIGtlcm5lbCBieSB0aGUgdW4tZmx1c2hlZCB0bGIgZW50cmllcy4NCj4gDQo+IElm
IEkgYW0gdG8gdW5kZXJzdGFuZCB0aGluZ3MgY29ycmVjdGx5LCB0aGVyZSB3YXMgYSBjYXNlIHdo
ZXJlICdlbmQnDQo+IGNvdWxkIGJlIHNtYWxsZXIgdGhhbiAnc3RhcnQnIHdoZW4gZG9pbmcgYSBy
YW5nZSBmbHVzaC4gIFRoYXQgd291bGQNCj4gZGVmaW5pdGVseSBraWxsIHNvbWUgb2YgdGhlIHNw
YXJjNjQgVExCIGZsdXNoIHJvdXRpbmVzLg0KDQpPaywgdGhhbmtzLg0KDQpUaGUgcGF0Y2ggYXQg
dGhlIGJlZ2lubmluZyBvZiB0aGlzIHRocmVhZCBkb2Vzbid0IGhhdmUgdGhhdCBiZWhhdmlvcg0K
dGhvdWdoIGFuZCBpdCBhcHBhcmVudGx5IHN0aWxsIGh1bmcuIEkgYXNrZWQgaWYgTWVlbGlzIGNv
dWxkIHRlc3Qgd2l0aA0KdGhpcyBmZWF0dXJlIGRpc2FibGVkIGFuZCBERUJVR19QQUdFQUxMT0Mg
b24sIHNpbmNlIGl0IGZsdXNoZXMgb24gZXZlcnkNCnZmcmVlIGFuZCBpcyBub3QgbmV3IGxvZ2lj
LCBhbmQgYWxzbyB3aXRoIGEgcGF0Y2ggdGhhdCBsb2dzIGV4YWN0IFRMQg0KZmx1c2ggcmFuZ2Vz
IGFuZCBmYXVsdCBhZGRyZXNzZXMgb24gdG9wIG9mIHRoZSBrZXJuZWwgaGF2aW5nIHRoaXMNCmlz
c3VlLiBIb3BlZnVsbHkgdGhhdCB3aWxsIHNoZWQgc29tZSBsaWdodC4NCg0KU29ycnkgZm9yIGFs
bCB0aGUgbm9pc2UgYW5kIHNwZWN1bGF0aW9uIG9uIHRoaXMuIEl0IGhhcyBiZWVuIGRpZmZpY3Vs
dA0KdG8gZGVidWcgcmVtb3RlbHkgd2l0aCBhIHRlc3RlciBhbmQgZGV2ZWxvcGVyIGluIGRpZmZl
cmVudCB0aW1lIHpvbmVzLg0KDQoNCg==

