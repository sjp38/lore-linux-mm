Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E791C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DC7F2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DC7F2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859EC6B0003; Mon, 20 May 2019 21:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80B7C6B0005; Mon, 20 May 2019 21:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FA0F6B0006; Mon, 20 May 2019 21:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3721B6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:59:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id cc5so10288614plb.12
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:59:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=oZPvwKt8zqXZbgzVGb7z6k5Yiv4U8kSsJ/iplWiQx70=;
        b=iyI4rHVzPtfNKQofnoz+iB49KXX9Pe16vcLtQkaXk438ti58z/EQ0if8fvmCCm/z/+
         8L62Yz+UKEvdTa1/yW0metEz5M+IPL5UfjK81wjRvWDgajVTIruwyGyPuVWyUpZVXC70
         8+YWe3et0SYJEHmR7vvhPlFfRiSb/E9XYlx0fo6B7Xg9TWAkBtdlamwvN9aMjojb1G/1
         OWvPSZh8wpXeIkvQqOK8aYclvmzpyxGbtzzLzL3DvtFhysX7RI7yltecVoaEu4R2X9v4
         m7Hs98TE8hN+LOZsByVql1WL/O0ISPAzCvRadm9lFFqHrgqgyypLDmx2NlU6tz1iPDM6
         Nr9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXqf8YbCtzXUmKcn+zfrJsGfp9KHks+7igLQQ492zWjN5BWkQWD
	4DHX8Mrfq3nzD9AhVd4H2DVOmDOzATRLOD+7LsegV9ufl11e6qausU214g2CwOgAXVOmussNTw7
	/001TBZ6MwMaRX/ar/xwU9MdczBUQBneqnUz+tqPB28stQ5jrv/KuhaSyPYIfvyql/g==
X-Received: by 2002:a63:dd4a:: with SMTP id g10mr25748032pgj.419.1558403996844;
        Mon, 20 May 2019 18:59:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtP0IoCZy1uqXKZh/CDLttagVCEosfN2FrJ5XHhTUWRpvqZhQlGdHLCl5JWJGvS15DJXT+
X-Received: by 2002:a63:dd4a:: with SMTP id g10mr25747991pgj.419.1558403996137;
        Mon, 20 May 2019 18:59:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403996; cv=none;
        d=google.com; s=arc-20160816;
        b=bi9jzFZgHbxhiJAqeuFXjtN+YNRCcSo7go4zDJFvdItQjuOTBMkg0ygML0OqK50pFR
         PICtUw8TXgEQQNI8F5OO0SYZPWqjIQ0bttxITdZnnXptWIP/qn5IHgzYRyf4dlWBQ8Of
         QbIJvnn/5utsbrhUe6GVapU+HTcfYJMVrduga/V/Xi1irJP+9MWdJmV0QCPHjpLtc4ZE
         5nCXMYgsAAehhRLFqIjwXigQ6H8u//Of36xZo+IwbpkMpZJDm1AlBLgtFpy28uJXgVaK
         GUo2AMWk/8BU5yhw7kEGHzT44rQVetLVaDVroxVp5Z8xiKGkDk0/CW4XIojgf+wJF2Kg
         B2Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=oZPvwKt8zqXZbgzVGb7z6k5Yiv4U8kSsJ/iplWiQx70=;
        b=Tj4Ar3idcukT+9VrMCrV9Ph4rhyg9MEWK4JPb58lc/B5dojWvODZj/SdREndv+Uwvp
         XSVUlEIlQ12HjkEV2XN6RlNzK6+/NhRvoXB46j2vLKSspmaYkQBN0czw2fYVIzEeQXT4
         TPRWV9kF41qw3LFF2CacMHNCgjvX3dGsFfpyjrl6HpSIeGgtmdNragcrZNOCiGPuMcjb
         4MJvujsTjCe8abRJbhQuAOFeyo0pp1kirwPp6Afv9HF7zcDwEE7tTB/lMj8eUB+qG9rK
         zT5k9WZPSs76rm1/AZ5RsrK3GlMkFGNFfuoxB42pzeHmjo+BEdeewX43WfTAtzm9lfne
         vMNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f65si21191799pfa.1.2019.05.20.18.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:59:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 18:59:55 -0700
X-ExtLoop1: 1
Received: from orsmsx107.amr.corp.intel.com ([10.22.240.5])
  by fmsmga001.fm.intel.com with ESMTP; 20 May 2019 18:59:55 -0700
Received: from orsmsx122.amr.corp.intel.com (10.22.225.227) by
 ORSMSX107.amr.corp.intel.com (10.22.240.5) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 20 May 2019 18:59:54 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX122.amr.corp.intel.com ([169.254.11.150]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 18:59:54 -0700
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
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwCAAAiygIAAGYEAgAADqwCAAA0vgIAABnMAgAAEjYA=
Date: Tue, 21 May 2019 01:59:54 +0000
Message-ID: <339ef85d984f329aa66f29fa80781624e6e4aecc.camel@intel.com>
References: <3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
	 <20190520.203320.621504228022195532.davem@davemloft.net>
	 <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
	 <20190520.184336.743103388474716249.davem@davemloft.net>
In-Reply-To: <20190520.184336.743103388474716249.davem@davemloft.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <8EBD949950AB8941B07DC53183E4B2A9@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA1LTIwIGF0IDE4OjQzIC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0K
PiBEYXRlOiBUdWUsIDIxIE1heSAyMDE5IDAxOjIwOjMzICswMDAwDQo+IA0KPiA+IFNob3VsZCBp
dCBoYW5kbGUgZXhlY3V0aW5nIGFuIHVubWFwcGVkIHBhZ2UgZ3JhY2VmdWxseT8gQmVjYXVzZQ0K
PiA+IHRoaXMNCj4gPiBjaGFuZ2UgaXMgY2F1c2luZyB0aGF0IHRvIGhhcHBlbiBtdWNoIGVhcmxp
ZXIuIElmIHNvbWV0aGluZyB3YXMNCj4gPiByZWx5aW5nDQo+ID4gb24gYSBjYWNoZWQgdHJhbnNs
YXRpb24gdG8gZXhlY3V0ZSBzb21ldGhpbmcgaXQgY291bGQgZmluZCB0aGUNCj4gPiBtYXBwaW5n
DQo+ID4gZGlzYXBwZWFyLg0KPiANCj4gRG9lcyB0aGlzIHdvcmsgYnkgbm90IG1hcHBpbmcgYW55
IGtlcm5lbCBtYXBwaW5ncyBhdCB0aGUgYmVnaW5uaW5nLA0KPiBhbmQgdGhlbiBmaWxsaW5nIGlu
IHRoZSBCUEYgbWFwcGluZ3MgaW4gcmVzcG9uc2UgdG8gZmF1bHRzPw0KTm8sIG5vdGhpbmcgdG9v
IGZhbmN5LiBJdCBqdXN0IGZsdXNoZXMgdGhlIHZtIG1hcHBpbmcgaW1tZWRpYXRseSBpbg0KdmZy
ZWUgZm9yIGV4ZWN1dGUgKGFuZCBSTykgbWFwcGluZ3MuIFRoZSBvbmx5IHRoaW5nIHRoYXQgaGFw
cGVucyBhcm91bmQNCmFsbG9jYXRpb24gdGltZSBpcyBzZXR0aW5nIG9mIGEgbmV3IGZsYWcgdG8g
dGVsbCB2bWFsbG9jIHRvIGRvIHRoZQ0KZmx1c2guDQoNClRoZSBwcm9ibGVtIGJlZm9yZSB3YXMg
dGhhdCB0aGUgcGFnZXMgd291bGQgYmUgZnJlZWQgYmVmb3JlIHRoZSBleGVjdXRlDQptYXBwaW5n
IHdhcyBmbHVzaGVkLiBTbyB0aGVuIHdoZW4gdGhlIHBhZ2VzIGdvdCByZWN5Y2xlZCwgcmFuZG9t
LA0Kc29tZXRpbWVzIGNvbWluZyBmcm9tIHVzZXJzcGFjZSwgZGF0YSB3b3VsZCBiZSBtYXBwZWQg
YXMgZXhlY3V0YWJsZSBpbg0KdGhlIGtlcm5lbCBieSB0aGUgdW4tZmx1c2hlZCB0bGIgZW50cmll
cy4NCg0KDQo=

