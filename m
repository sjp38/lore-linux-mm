Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 857EFC282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:50:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CB2A21841
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 15:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB2A21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C55476B0010; Fri, 24 May 2019 11:50:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2D156B0266; Fri, 24 May 2019 11:50:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF4166B0269; Fri, 24 May 2019 11:50:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 768626B0010
	for <linux-mm@kvack.org>; Fri, 24 May 2019 11:50:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v125so3639066pgv.3
        for <linux-mm@kvack.org>; Fri, 24 May 2019 08:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=asU3vnEN/8icSIHV94km3rDKklvwXfLlXJdjQfg3ZWw=;
        b=cJBaYWogTmXF4iL2qUz8B6yf71ehf42a6kEJlOC6cwqu5x8u+yJNL3Am7KBfq0+QOf
         gNwbR9izESK5zhLqcl2hDSqPLopa4Z9TyUCXLC11QNWN2SO4HEWtVItRTjjGsD7zRPv7
         xxPhzSkZInMksn4e3mCaPEMz3HhuTY/GRNQrKnhDY4PqThJHt+OuA5NfQaYqAT/IvA2k
         2IGH1yW167/1ZajoOxDKcZv3trgKyRtHghKa5KEekFrXfAMyf2/qWnWmRnvrynk03ch4
         HJSw4KN18zOCo0bAISUf9MGx44QUipWL7fKIXPvlsFkmbdEb6yJB4sTVCUlqLX1zDRyJ
         2d8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVMwDRrjZ4xBLk1T2Rz2kOCMphAGR52ROX/8d4wY7pcPrpqDN9S
	Lsw3Wb1eWsE+neiCecKneXxvQ58ejFgwyDN8+bt2HYKd73u5dPUk1Y6bxYUbc9J9KZ0mlurwBDa
	Ab+blhMMWwPZnNf8KHGyl6G8AHORqe/omf0NkSxfMtzGu1RWtAxy4oAxZi27wurFlmA==
X-Received: by 2002:a63:2ac9:: with SMTP id q192mr35901973pgq.144.1558713052099;
        Fri, 24 May 2019 08:50:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrwmyHE8iHi65k+cYfidMm9n1mjybkbYe6fkxcWes8A3HdKaBMQWtMRIdo4WAnVLEVpCzZ
X-Received: by 2002:a63:2ac9:: with SMTP id q192mr35901889pgq.144.1558713051071;
        Fri, 24 May 2019 08:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558713051; cv=none;
        d=google.com; s=arc-20160816;
        b=eaeAxKKWYiFpiUTFDbQrcvkeAK3Xj6J075ETyI6ZveG1pCyFLbgfYfzwP9r1iuN/zo
         OBjfSeHgB0lpZTPlZUVfP1w9RK/kBFhEzWCY7ms/oH7ocwGmCPQ8pVmEmWGNI13DL32M
         jSDAtEgqJiHrqN4Dq06hQ/kHiM+SdaH1+n+pj7AaJ9qF3f5R2slrmLrw49rBKg/uO7Is
         qsWOX+aGjz0y2uRwchW7I5ZnSP6Qh18V1BDY5+fst7lh0Nm5pgaP6vuJo+KBtV3CLYgR
         cKybjHFC+0sVJ80oTuzV1cxvSdzvhIQpfFAY9cM79xIqxtN5xC0ijQj8Cu2HywJQaF+e
         RTcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=asU3vnEN/8icSIHV94km3rDKklvwXfLlXJdjQfg3ZWw=;
        b=1LO2FydqpjdHQzm+EL1iyxVbo/9YasMulqt9CFyu7c17X63zMmlMTvlSK9TsJSlZSB
         fuDv7v3ATteYUZUKheCrKeWjIgHTQMwMcs7LJgdcvis86Ub9RbAJUclue5LY5EddNhZS
         PYYwgTERoDKvP+rG6yDq3taMf3l1r1sfqAwAeGuLXmQVwq2mVxqsl8rO8kJIhLIHVam1
         daogMSKFIC8wG6+nfgCOrEhbMGCLW1z167oZEXy7C0Wy/XxT52/ttny341w3dJyvICV/
         ElBmU4/msy1n7dC5PTbPaf3UTzqur3Ik7VRPxgwWl6HD/k8K1A4UN4XEQyS1na7ozGjJ
         CRSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 5si4770872pgm.540.2019.05.24.08.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 08:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 May 2019 08:50:50 -0700
X-ExtLoop1: 1
Received: from orsmsx102.amr.corp.intel.com ([10.22.225.129])
  by fmsmga001.fm.intel.com with ESMTP; 24 May 2019 08:50:49 -0700
Received: from orsmsx126.amr.corp.intel.com (10.22.240.126) by
 ORSMSX102.amr.corp.intel.com (10.22.225.129) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 24 May 2019 08:50:49 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX126.amr.corp.intel.com ([169.254.4.35]) with mapi id 14.03.0415.000;
 Fri, 24 May 2019 08:50:49 -0700
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
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwCAAAiygIAAGYEAgAADqwCAAA0vgIAABnMAgAAEjYCAApkWgIAAHb0AgAA1/4CAArJUAA==
Date: Fri, 24 May 2019 15:50:48 +0000
Message-ID: <c9c96d83838beab6eb3a5309ad6b4b409fbce0f3.camel@intel.com>
References: <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
	 <20190520.184336.743103388474716249.davem@davemloft.net>
	 <339ef85d984f329aa66f29fa80781624e6e4aecc.camel@intel.com>
	 <20190522.104019.40493905027242516.davem@davemloft.net>
	 <01a23900329e605fcd41ad8962cfd8f2d9b1fa44.camel@intel.com>
	 <2d8c59be7e591a0d0ff17627ea34ea1eaa110a09.camel@intel.com>
In-Reply-To: <2d8c59be7e591a0d0ff17627ea34ea1eaa110a09.camel@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.251.0.167]
Content-Type: text/plain; charset="utf-8"
Content-ID: <3FAE5003E9627F419617E9DC8A2441C1@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA1LTIyIGF0IDE1OjQwIC0wNzAwLCBSaWNrIEVkZ2Vjb21iZSB3cm90ZToN
Cj4gT24gV2VkLCAyMDE5LTA1LTIyIGF0IDEyOjI2IC0wNzAwLCBSaWNrIEVkZ2Vjb21iZSB3cm90
ZToNCj4gPiBPbiBXZWQsIDIwMTktMDUtMjIgYXQgMTA6NDAgLTA3MDAsIERhdmlkIE1pbGxlciB3
cm90ZToNCj4gPiA+IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2sucC5lZGdlY29tYmVA
aW50ZWwuY29tPg0KPiA+ID4gRGF0ZTogVHVlLCAyMSBNYXkgMjAxOSAwMTo1OTo1NCArMDAwMA0K
PiA+ID4gDQo+ID4gPiA+IE9uIE1vbiwgMjAxOS0wNS0yMCBhdCAxODo0MyAtMDcwMCwgRGF2aWQg
TWlsbGVyIHdyb3RlOg0KPiA+ID4gPiA+IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2su
cC5lZGdlY29tYmVAaW50ZWwuY29tPg0KPiA+ID4gPiA+IERhdGU6IFR1ZSwgMjEgTWF5IDIwMTkg
MDE6MjA6MzMgKzAwMDANCj4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IFNob3VsZCBpdCBoYW5kbGUg
ZXhlY3V0aW5nIGFuIHVubWFwcGVkIHBhZ2UgZ3JhY2VmdWxseT8NCj4gPiA+ID4gPiA+IEJlY2F1
c2UNCj4gPiA+ID4gPiA+IHRoaXMNCj4gPiA+ID4gPiA+IGNoYW5nZSBpcyBjYXVzaW5nIHRoYXQg
dG8gaGFwcGVuIG11Y2ggZWFybGllci4gSWYgc29tZXRoaW5nDQo+ID4gPiA+ID4gPiB3YXMNCj4g
PiA+ID4gPiA+IHJlbHlpbmcNCj4gPiA+ID4gPiA+IG9uIGEgY2FjaGVkIHRyYW5zbGF0aW9uIHRv
IGV4ZWN1dGUgc29tZXRoaW5nIGl0IGNvdWxkIGZpbmQNCj4gPiA+ID4gPiA+IHRoZQ0KPiA+ID4g
PiA+ID4gbWFwcGluZw0KPiA+ID4gPiA+ID4gZGlzYXBwZWFyLg0KPiA+ID4gPiA+IA0KPiA+ID4g
PiA+IERvZXMgdGhpcyB3b3JrIGJ5IG5vdCBtYXBwaW5nIGFueSBrZXJuZWwgbWFwcGluZ3MgYXQg
dGhlDQo+ID4gPiA+ID4gYmVnaW5uaW5nLA0KPiA+ID4gPiA+IGFuZCB0aGVuIGZpbGxpbmcgaW4g
dGhlIEJQRiBtYXBwaW5ncyBpbiByZXNwb25zZSB0byBmYXVsdHM/DQo+ID4gPiA+IE5vLCBub3Ro
aW5nIHRvbyBmYW5jeS4gSXQganVzdCBmbHVzaGVzIHRoZSB2bSBtYXBwaW5nDQo+ID4gPiA+IGlt
bWVkaWF0bHkNCj4gPiA+ID4gaW4NCj4gPiA+ID4gdmZyZWUgZm9yIGV4ZWN1dGUgKGFuZCBSTykg
bWFwcGluZ3MuIFRoZSBvbmx5IHRoaW5nIHRoYXQNCj4gPiA+ID4gaGFwcGVucw0KPiA+ID4gPiBh
cm91bmQNCj4gPiA+ID4gYWxsb2NhdGlvbiB0aW1lIGlzIHNldHRpbmcgb2YgYSBuZXcgZmxhZyB0
byB0ZWxsIHZtYWxsb2MgdG8gZG8NCj4gPiA+ID4gdGhlDQo+ID4gPiA+IGZsdXNoLg0KPiA+ID4g
PiANCj4gPiA+ID4gVGhlIHByb2JsZW0gYmVmb3JlIHdhcyB0aGF0IHRoZSBwYWdlcyB3b3VsZCBi
ZSBmcmVlZCBiZWZvcmUgdGhlDQo+ID4gPiA+IGV4ZWN1dGUNCj4gPiA+ID4gbWFwcGluZyB3YXMg
Zmx1c2hlZC4gU28gdGhlbiB3aGVuIHRoZSBwYWdlcyBnb3QgcmVjeWNsZWQsDQo+ID4gPiA+IHJh
bmRvbSwNCj4gPiA+ID4gc29tZXRpbWVzIGNvbWluZyBmcm9tIHVzZXJzcGFjZSwgZGF0YSB3b3Vs
ZCBiZSBtYXBwZWQgYXMNCj4gPiA+ID4gZXhlY3V0YWJsZQ0KPiA+ID4gPiBpbg0KPiA+ID4gPiB0
aGUga2VybmVsIGJ5IHRoZSB1bi1mbHVzaGVkIHRsYiBlbnRyaWVzLg0KPiA+ID4gDQo+ID4gPiBJ
ZiBJIGFtIHRvIHVuZGVyc3RhbmQgdGhpbmdzIGNvcnJlY3RseSwgdGhlcmUgd2FzIGEgY2FzZSB3
aGVyZQ0KPiA+ID4gJ2VuZCcNCj4gPiA+IGNvdWxkIGJlIHNtYWxsZXIgdGhhbiAnc3RhcnQnIHdo
ZW4gZG9pbmcgYSByYW5nZSBmbHVzaC4gIFRoYXQNCj4gPiA+IHdvdWxkDQo+ID4gPiBkZWZpbml0
ZWx5IGtpbGwgc29tZSBvZiB0aGUgc3BhcmM2NCBUTEIgZmx1c2ggcm91dGluZXMuDQo+ID4gDQo+
ID4gT2ssIHRoYW5rcy4NCj4gPiANCj4gPiBUaGUgcGF0Y2ggYXQgdGhlIGJlZ2lubmluZyBvZiB0
aGlzIHRocmVhZCBkb2Vzbid0IGhhdmUgdGhhdA0KPiA+IGJlaGF2aW9yDQo+ID4gdGhvdWdoIGFu
ZCBpdCBhcHBhcmVudGx5IHN0aWxsIGh1bmcuIEkgYXNrZWQgaWYgTWVlbGlzIGNvdWxkIHRlc3QN
Cj4gPiB3aXRoDQo+ID4gdGhpcyBmZWF0dXJlIGRpc2FibGVkIGFuZCBERUJVR19QQUdFQUxMT0Mg
b24sIHNpbmNlIGl0IGZsdXNoZXMgb24NCj4gPiBldmVyeQ0KPiA+IHZmcmVlIGFuZCBpcyBub3Qg
bmV3IGxvZ2ljLCBhbmQgYWxzbyB3aXRoIGEgcGF0Y2ggdGhhdCBsb2dzIGV4YWN0DQo+ID4gVExC
DQo+ID4gZmx1c2ggcmFuZ2VzIGFuZCBmYXVsdCBhZGRyZXNzZXMgb24gdG9wIG9mIHRoZSBrZXJu
ZWwgaGF2aW5nIHRoaXMNCj4gPiBpc3N1ZS4gSG9wZWZ1bGx5IHRoYXQgd2lsbCBzaGVkIHNvbWUg
bGlnaHQuDQo+ID4gDQo+ID4gU29ycnkgZm9yIGFsbCB0aGUgbm9pc2UgYW5kIHNwZWN1bGF0aW9u
IG9uIHRoaXMuIEl0IGhhcyBiZWVuDQo+ID4gZGlmZmljdWx0DQo+ID4gdG8gZGVidWcgcmVtb3Rl
bHkgd2l0aCBhIHRlc3RlciBhbmQgZGV2ZWxvcGVyIGluIGRpZmZlcmVudCB0aW1lDQo+ID4gem9u
ZXMuDQo+ID4gDQo+ID4gDQo+IE9rLCBzbyB3aXRoIGEgcGF0Y2ggdG8gZGlzYWJsZSBzZXR0aW5n
IHRoZSBuZXcgdm1hbGxvYyBmbHVzaCBmbGFnIG9uDQo+IGFyY2hpdGVjdHVyZXMgdGhhdCBoYXZl
IG5vcm1hbCBtZW1vcnkgYXMgZXhlY3V0YWJsZSAoaW5jbHVkZXMgc3BhcmMpLA0KPiBib290IHN1
Y2NlZWRzLg0KPiANCj4gV2l0aCB0aGlzIGRpc2FibGUgcGF0Y2ggYW5kIERFQlVHX1BBR0VBTExP
QyBvbiwgaXQgaGFuZ3MgZWFybGllciB0aGFuDQo+IGJlZm9yZS4gR29pbmcgZnJvbSBjbHVlcyBp
biBvdGhlciBsb2dzLCBpdCBsb29rcyBsaWtlIGl0IGhhbmdzIHJpZ2h0DQo+IGF0DQo+IHRoZSBm
aXJzdCBub3JtYWwgdmZyZWUuDQo+IA0KPiBUaGFua3MgZm9yIGFsbCB0aGUgdGVzdGluZyBNZWVs
aXMhDQo+IA0KPiBTbyBpdCBzZWVtcyBsaWtlIG90aGVyLCBub3QgbmV3LCBUTEIgZmx1c2hlcyBh
bHNvIHRyaWdnZXIgdGhlIGhhbmcuDQo+IA0KPiBGcm9tIGVhcmxpZXIgbG9ncyBwcm92aWRlZCwg
dGhpcyB2ZnJlZSB3b3VsZCBiZSB0aGUgZmlyc3QgY2FsbCB0bw0KPiBmbHVzaF90bGJfa2VybmVs
X3JhbmdlKCksIGFuZCBiZWZvcmUgYW55IEJQRiBhbGxvY2F0aW9ucyBhcHBlYXIgaW4NCj4gdGhl
DQo+IGxvZ3MuIFNvIEkgYW0gc3VzcGVjdGluZyBzb21lIG90aGVyIGNhdXNlIHRoYW4gdGhlIGJp
c2VjdGVkIHBhdGNoIGF0DQo+IHRoaXMgcG9pbnQsIGJ1dCBJIGd1ZXNzIGl0J3Mgbm90IGZ1bGx5
IGNvbmNsdXNpdmUuDQo+IA0KPiBJdCBjb3VsZCBiZSBpbmZvcm1hdGl2ZSB0byBiaXNlY3QgdXBz
dHJlYW0gYWdhaW4gd2l0aCB0aGUNCj4gREVCVUdfUEFHRUFMTE9DIGNvbmZpZ3Mgb24sIHRvIHNl
ZSBpZiBpdCBpbmRlZWQgcG9pbnRzIHRvIGFuIGVhcmxpZXINCj4gY29tbWl0Lg0KDQpTbyBub3cg
TWVlbGlzIGhhcyBmb3VuZCB0aGF0IHRoZSBjb21taXQgYmVmb3JlIGFueSBvZiBteSB2bWFsbG9j
DQpjaGFuZ2VzIGFsc28gaGFuZ3MgZHVyaW5nIGJvb3Qgd2l0aCBERUJVR19QQUdFQUxMT0Mgb24u
IEl0IGRvZXMgdGhpcw0Kc2hvcnRseSBhZnRlciB0aGUgZmlyc3QgdmZyZWUsIHdoaWNoIERFQlVH
X1BBR0VBTExPQyB3b3VsZCBvZiBjb3Vyc2UNCm1ha2UgdHJpZ2dlciBhIGZsdXNoX3RsYl9rZXJu
ZWxfcmFuZ2UoKSBvbiB0aGUgYWxsb2NhdGlvbiBqdXN0IGxpa2UgbXkNCnZtYWxsb2MgY2hhbmdl
cyBkbyBvbiBjZXJ0YWluIHZtYWxsb2NzLiBUaGUgdXBzdHJlYW0gY29kZSBjYWxscw0Kdm1fdW5t
YXBfYWxpYXNlcygpIGluc3RlYWQgb2YgdGhlIGZsdXNoX3RsYl9rZXJuZWxfcmFuZ2UoKSBkaXJl
Y3RseSwNCmJ1dCB3ZSBhbHNvIHRlc3RlZCBhIHZlcnNpb24gdGhhdCBjYWxsZWQgdGhlIGZsdXNo
IGRpcmVjdGx5IG9uIGp1c3QgdGhlDQphbGxvY2F0aW9uIGFuZCBpdCBhbHNvIGh1bmcuIFNvIGl0
IHNlZW1zIGxpa2UgaXNzdWVzIGZsdXNoaW5nIHZtYWxsb2NzDQpvbiB0aGlzIHBsYXRmb3JtIGV4
aXN0IG91dHNpZGUgbXkgY29tbWl0cy4NCg0KSG93IGRvIHBlb3BsZSBmZWVsIGFib3V0IGNhbGxp
bmcgdGhpcyBhIHNwYXJjIHNwZWNpZmljIGlzc3VlIHVuY292ZXJlZA0KYnkgbXkgcGF0Y2ggaW5z
dGVhZCBvZiBjYXVzZWQgYnkgaXQgYXQgdGhpcyBwb2ludD8NCg0KSWYgcGVvcGxlIGFncmVlIHdp
dGggdGhpcyBhc3Nlc21lbnQsIGl0IG9mIGNvdXJzZSBzdGlsbCBzZWVtcyBsaWtlIHRoZQ0KbmV3
IGNoYW5nZXMgdHVybiB0aGUgcm9vdCBjYXVzZSBpbnRvIGEgbW9yZSBpbXBhY3RmdWwgaXNzdWUg
Zm9yIHRoaXMNCnNwZWNpZmljIGNvbWJpbmF0aW9uLiBPbiB0aGUgb3RoZXIgaGFuZCBJIGFtIG5v
dCB0aGUgcmlnaHQgcGVyc29uIHRvDQpmaXggdGhlIHJvb3QgY2F1c2UgZm9yIHNldmVyYWwgcmVh
c29ucyBpbmNsdWRpbmcgbm8gaGFyZHdhcmUgYWNjZXNzLiANCg0KT3RoZXJ3aXNlIEkgY291bGQg
c3VibWl0IGEgcGF0Y2ggdG8gZGlzYWJsZSB0aGlzIGZvciBzcGFyYyBzaW5jZSBpdA0KZG9lc24n
dCByZWFsbHkgZ2V0IGEgc2VjdXJpdHkgYmVuZWZpdCBmcm9tIGl0IGFueXdheS4gV2hhdCBkbyBw
ZW9wbGUNCnRoaW5rPw0K

