Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A849AC46460
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6750A2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:51:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6750A2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 129706B0003; Tue, 21 May 2019 12:51:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DDA56B0006; Tue, 21 May 2019 12:51:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0B766B0007; Tue, 21 May 2019 12:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB1576B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:51:55 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d21so12757863pfr.3
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=ABqNe2Yx0yX32ndwSlwpn/QIsiACao020YPgVAT+7a4=;
        b=qpplYstteW9mvXh5oK0CiZp+WPVCH3EEtoNUhXtWTryryOj4gxficQzsd2Pdg89MqI
         w5X7S8J9vAvik9O6htLN3dGEzLKRlFXkucfTxWYQm2Z6kKbp9ayJhMjLr9v3hQk2KQ8g
         4llE0BYAspEbOt+v2ZWUBOL/Y6Tw84rY6Xne52AEB9I+NnDx9eO4dsAizohApdARkcaK
         3vwQf5djVLxZs1CqeZ57WTVfnpztmqQJ0+C9y0R50iV//ZhY40Z90G9xDFLUSnC75tLj
         2gS01KafU22kKyPTesSvU3EJlWShvr2rxaFNQ+nl6iGYhTg50lBHa5IS+CUQGId94kAw
         5gHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVZp96eTXhDxmKKafp0UBing2/4cy0BNtbu6wUHn7aJoJOYkzSc
	fFDXC3u0lwPQNsEgYD4T6fXevz6eRO+H+V0tI+vudNVlU7wUVe8MrFKL8xKH2jMNfeMYJYuX8Jo
	JO+TmDaRh80GMpbRXY2r/f8YeofQp7dThcWYs/J5QJgS3l4IsK3rJvuVTM9lIQFY/MA==
X-Received: by 2002:a63:e24:: with SMTP id d36mr83704703pgl.80.1558457515438;
        Tue, 21 May 2019 09:51:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6L04/tvnj/IgC1vHf/5mqJqU6b/+hwL8COgEYQcTtiFs7Xng1pumYot1gFDuTo+vBRgMx
X-Received: by 2002:a63:e24:: with SMTP id d36mr83704575pgl.80.1558457514419;
        Tue, 21 May 2019 09:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558457514; cv=none;
        d=google.com; s=arc-20160816;
        b=tMUlt/ZEcmAZoNDcaZyJfwv5mj3b5sbNvL/Kp3iNLga0CZxfappOiVQ48b4lWoRBBy
         1wCdpxOERhUdc2uzpmt9qIuc1Y+p+5mKMGZrDyna2wGYkLDGgjHGFgklwdaCtsGZBtiD
         KRFwv2uO9sr/dAb0RVGOo9+ygNTQHZk9h0Hm9EWik1dKqinIYrp2Y02JNUGtU9QYyjHH
         5JLlaXzTNwHRLbDbl+eeuLu0m2E3sDZVoaWgLrNXXb5+JuO6gseLvQY3Dfvcn5GcFoW4
         vATEjhwh5UMr/HzelTeodIGjCC6Mefq2q6wkr1GfcWtvDJXjQc1ez5qTB2en68+V3hX2
         E9Ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=ABqNe2Yx0yX32ndwSlwpn/QIsiACao020YPgVAT+7a4=;
        b=kraYx7mFh/IGBHBWPrcVAR5GHo3idEEtL4dsPlhaXjUebUGenpzJRdqjOkAEQO6Ndb
         WWeelo5n2LI2jNeiDpk92A4/T7M8wlPVDqPd9t6pEYUB1IYrhrHdFtlLIV89eEUlBwmm
         PSSfHrL5P3qM3H6E+US3C8Vbet/3yNSuk7Xt9Ar2O/ZYrFLvgCSlLU0uHADyq1Hn4IRz
         V+L5DKi+yRmSQVkgfM8mv9vYzOFnXMUxvqFnXdBuB56yHwBAET0KoofQUVghrzAiOfDV
         qYQUBfJV64aop+540tH0q4/loXZn+uY4ZA1qfz+X51MHYzwU0Fi+4felH+l4blEhsi9b
         LXHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f16si22481349plr.340.2019.05.21.09.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:51:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 May 2019 09:51:53 -0700
X-ExtLoop1: 1
Received: from orsmsx103.amr.corp.intel.com ([10.22.225.130])
  by fmsmga004.fm.intel.com with ESMTP; 21 May 2019 09:51:53 -0700
Received: from orsmsx151.amr.corp.intel.com (10.22.226.38) by
 ORSMSX103.amr.corp.intel.com (10.22.225.130) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Tue, 21 May 2019 09:51:53 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX151.amr.corp.intel.com ([169.254.7.185]) with mapi id 14.03.0415.000;
 Tue, 21 May 2019 09:51:53 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "luto@kernel.org" <luto@kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "mroos@linux.ee" <mroos@linux.ee>,
	"redgecombe.lkml@gmail.com" <redgecombe.lkml@gmail.com>, "mingo@redhat.com"
	<mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave"
	<dave.hansen@intel.com>, "bp@alien8.de" <bp@alien8.de>, "davem@davemloft.net"
	<davem@davemloft.net>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>
Subject: Re: [PATCH v2 2/2] vmalloc: Remove work as from vfree path
Thread-Topic: [PATCH v2 2/2] vmalloc: Remove work as from vfree path
Thread-Index: AQHVD2U3KZTtLX0Fp0SruELxCLk0rqZ2N/EAgAAJloA=
Date: Tue, 21 May 2019 16:51:52 +0000
Message-ID: <4e353614f017c7c13a21d168992852dae1762aba.camel@intel.com>
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
	 <20190520233841.17194-3-rick.p.edgecombe@intel.com>
	 <CALCETrUdfBrTV3kMjdVHv2JDtEOGSkVvoV++96x4zjvue0GpZA@mail.gmail.com>
In-Reply-To: <CALCETrUdfBrTV3kMjdVHv2JDtEOGSkVvoV++96x4zjvue0GpZA@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <DACEB64281EDB048B2BD8C11B17A6282@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCAyMDE5LTA1LTIxIGF0IDA5OjE3IC0wNzAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IE9uIE1vbiwgTWF5IDIwLCAyMDE5IGF0IDQ6MzkgUE0gUmljayBFZGdlY29tYmUNCj4gPHJp
Y2sucC5lZGdlY29tYmVAaW50ZWwuY29tPiB3cm90ZToNCj4gPiBGcm9tOiBSaWNrIEVkZ2Vjb21i
ZSA8cmVkZ2Vjb21iZS5sa21sQGdtYWlsLmNvbT4NCj4gPiANCj4gPiBDYWxsaW5nIHZtX3VubWFw
X2FsaWFzKCkgaW4gdm1fcmVtb3ZlX21hcHBpbmdzKCkgY291bGQgcG90ZW50aWFsbHkNCj4gPiBi
ZSBhDQo+ID4gbG90IG9mIHdvcmsgdG8gZG8gb24gYSBmcmVlIG9wZXJhdGlvbi4gU2ltcGx5IGZs
dXNoaW5nIHRoZSBUTEINCj4gPiBpbnN0ZWFkIG9mDQo+ID4gdGhlIHdob2xlIHZtX3VubWFwX2Fs
aWFzKCkgb3BlcmF0aW9uIG1ha2VzIHRoZSBmcmVlcyBmYXN0ZXIgYW5kDQo+ID4gcHVzaGVzDQo+
ID4gdGhlIGhlYXZ5IHdvcmsgdG8gaGFwcGVuIG9uIGFsbG9jYXRpb24gd2hlcmUgaXQgd291bGQg
YmUgbW9yZQ0KPiA+IGV4cGVjdGVkLg0KPiA+IEluIGFkZGl0aW9uIHRvIHRoZSBleHRyYSB3b3Jr
LCB2bV91bm1hcF9hbGlhcygpIHRha2VzIHNvbWUgbG9ja3MNCj4gPiBpbmNsdWRpbmcNCj4gPiBh
IGxvbmcgaG9sZCBvZiB2bWFwX3B1cmdlX2xvY2ssIHdoaWNoIHdpbGwgbWFrZSBhbGwgb3RoZXIN
Cj4gPiBWTV9GTFVTSF9SRVNFVF9QRVJNUyB2ZnJlZXMgd2FpdCB3aGlsZSB0aGUgcHVyZ2Ugb3Bl
cmF0aW9uIGhhcHBlbnMuDQo+ID4gDQo+ID4gTGFzdGx5LCBwYWdlX2FkZHJlc3MoKSBjYW4gaW52
b2x2ZSBsb2NraW5nIGFuZCBsb29rdXBzIG9uIHNvbWUNCj4gPiBjb25maWd1cmF0aW9ucywgc28g
c2tpcCBjYWxsaW5nIHRoaXMgYnkgZXhpdGluZyBvdXQgZWFybHkgd2hlbg0KPiA+ICFDT05GSUdf
QVJDSF9IQVNfU0VUX0RJUkVDVF9NQVAuDQo+IA0KPiBIbW0uICBJIHdvdWxkIGhhdmUgZXhwZWN0
ZWQgdGhhdCB0aGUgbWFqb3IgY29zdCBvZiB2bV91bm1hcF9hbGlhc2VzKCkNCj4gd291bGQgYmUg
dGhlIGZsdXNoLCBhbmQgYXQgbGVhc3QgaW5mb3JtaW5nIHRoZSBjb2RlIHRoYXQgdGhlIGZsdXNo
DQo+IGhhcHBlbmVkIHNlZW1zIHZhbHVhYmxlLiAgU28gd291bGQgZ3Vlc3MgdGhhdCB0aGlzIHBh
dGNoIGlzIGFjdHVhbGx5DQo+IGENCj4gbG9zcyBpbiB0aHJvdWdocHV0Lg0KPiANCllvdSBhcmUg
cHJvYmFibHkgcmlnaHQgYWJvdXQgdGhlIGZsdXNoIHRha2luZyB0aGUgbG9uZ2VzdC4gVGhlIG9y
aWdpbmFsDQppZGVhIG9mIHVzaW5nIGl0IHdhcyBleGFjdGx5IHRvIGltcHJvdmUgdGhyb3VnaHB1
dCBieSBzYXZpbmcgYSBmbHVzaC4NCkhvd2V2ZXIgd2l0aCB2bV91bm1hcF9hbGlhc2VzKCkgdGhl
IGZsdXNoIHdpbGwgYmUgb3ZlciBhIGxhcmdlciByYW5nZQ0KdGhhbiBiZWZvcmUgZm9yIG1vc3Qg
YXJjaCdzIHNpbmNlIGl0IHdpbGwgbGlrbGV5IHNwYW4gZnJvbSB0aGUgbW9kdWxlDQpzcGFjZSB0
byB2bWFsbG9jLiBGcm9tIHBva2luZyBhcm91bmQgdGhlIHNwYXJjIHRsYiBmbHVzaCBoaXN0b3J5
LCBJDQpndWVzcyB0aGUgbGF6eSBwdXJnZXMgdXNlZCB0byBiZSAoc3RpbGwgYXJlPykgYSBwcm9i
bGVtIGZvciB0aGVtDQpiZWNhdXNlIGl0IHdvdWxkIHRyeSB0byBmbHVzaCBlYWNoIHBhZ2UgaW5k
aXZpZHVhbGx5IGZvciBzb21lIENQVXMuIE5vdA0Kc3VyZSBhYm91dCBhbGwgb2YgdGhlIG90aGVy
IGFyY2hpdGVjdHVyZXMsIGJ1dCBmb3IgYW55IGltcGxlbWVudGF0aW9uDQpsaWtlIHRoYXQsIHVz
aW5nIHZtX3VubWFwX2FsaWFzKCkgd291bGQgdHVybiBhbiBvY2Nhc2lvbmFsIGxvbmcNCm9wZXJh
dGlvbiBpbnRvIGEgbW9yZSBmcmVxdWVudCBvbmUuDQoNCk9uIHg4NiwgaXQgc2hvdWxkbid0IGJl
IGEgcHJvYmxlbSB0byB1c2UgaXQuIFdlIGFscmVhZHkgdXNlZCB0byBjYWxsDQp0aGlzIGZ1bmN0
aW9uIHNldmVyYWwgdGltZXMgYXJvdW5kIGEgZXhlYyBwZXJtaXNzaW9uIHZmcmVlLiANCg0KSSBn
dWVzcyBpdHMgYSB0cmFkZW9mZiB0aGF0IGRlcGVuZHMgb24gaG93IGZhc3QgbGFyZ2UgcmFuZ2Ug
VExCIGZsdXNoZXMNCnVzdWFsbHkgYXJlIGNvbXBhcmVkIHRvIHNtYWxsIG9uZXMuIEkgYW0gb2sg
ZHJvcHBpbmcgaXQsIGlmIGl0IGRvZXNuJ3QNCnNlZW0gd29ydGggaXQuDQo=

