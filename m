Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFD99C742D7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 13:53:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4004B2083B
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 13:53:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="mKKhnhB+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4004B2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3DD18E000A; Sat, 13 Jul 2019 09:53:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF0888E0003; Sat, 13 Jul 2019 09:53:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B6D98E000A; Sat, 13 Jul 2019 09:53:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 796508E0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 09:53:34 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x1so9957112qts.9
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 06:53:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:mime-version:precedence
         :content-transfer-encoding;
        bh=Oq1JDzuzw72gaVJ3N+aVYoxBMtRhT49QZunKSm9NVAA=;
        b=Tsqg8LDEbiONmgdLCuUNQEh/s57WkzrJGB03SChisbnSeM49/ZQbaUKoW3l5TO6dsM
         6unQ7alwOGc6TCOibhwf7kVg+8dLdlKZjX0CuDwEZuTzFlILXe7uwm0nlbFGRuM5A6Yk
         OwxVE4dyILFcX6auUumRrqpzvwpxpHAyRxA2DS09T4DxR6/9egVblqRn8QgIuft3Cdhk
         hAFiyUepgyhRKIUaD84hTxkg1QVN2TftUx0UGFkCY8ukZB46rfryw/oYSL/ZP2KGbxdJ
         FSP1090+L5iS6fzTqAQsMXuZdQJA77FlqnA3cw6Cz09za4FvGuZwJYEt/2a/pY3I5mVf
         vtTw==
X-Gm-Message-State: APjAAAUyKe7Log347cZ2hfYhyfnYFl5NQgtzcjFAwzGbwdcYSfwJHhJZ
	jS46NBt2Unr9qMVyL+RwBPrmkZQodOLxnkUUAS+vfqWnLkIPHowncPOUE8JeQ2j4+dHWUYLn5BK
	BZFxYX2ROZLNLm9cGCpRsp4s/FQcOVBuH8ZOQ8A/KViU+WMDbrOQHmq0zWeMlZBYAWg==
X-Received: by 2002:ac8:2834:: with SMTP id 49mr10494957qtq.326.1563026014213;
        Sat, 13 Jul 2019 06:53:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk7Fr0JEgt2gn7INqPbMmBen793e77wm5TQSGrlC31chY4FW24AOkxvckwRBHxZ2qvt8gB
X-Received: by 2002:ac8:2834:: with SMTP id 49mr10494913qtq.326.1563026013433;
        Sat, 13 Jul 2019 06:53:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563026013; cv=none;
        d=google.com; s=arc-20160816;
        b=KaPDmgY6VCKMESVKphKG1deodfguS9POISQvicDbNPMFjs75yfVvY/cwC02ulqZ2FX
         rhoPTd58PvDc1wiCE7DdtWAii3DNYMXJvvJXtD4YCBJ/Oq7Mwpd09UbzXnqAO1So+j6b
         4IUebDdiUhi4BFETe5g9HtLe5Uwhshc6Wuhgo2J8OGvmOiv+UxSXm+Oovfs331207EtU
         GEE9NZvgWiHo7kQ2rdxQFW/z2E3s/m9MqPu9tZnd9nZTCZrZ7AJ3UbWUUCeNYpflwal0
         l4GT+7SymLGdECs4h4OZxTJIGHaQuoPl7qxz8RStLm/40t85i1zETqWvXKzd2FCejewf
         O4fQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:precedence:mime-version:content-id
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=Oq1JDzuzw72gaVJ3N+aVYoxBMtRhT49QZunKSm9NVAA=;
        b=mH3z6ibnEx0kWhqy1eyaNm4m5Y+EuX9ZuWMn35XkyYa64cSi4Oo3oe8z2EAy3JzgQL
         cgQspjP1boHmcRcGGIb43n0oXhztWz4NP3Ih9JgAjbvCuZZOftvko1ah4a/p/Laa7hzB
         3ocIY7Ij3TVMBLuttnXVH/hRGntLClXv5BKwvQivAeu/AX/RUOqOmlSe50GW7bkJRxOT
         fRNN9PonZJej6mu81b6LA1mL5jtECArz0+z8FVQ7HD7Y9y1odMhnKjz7UVw0KhGIFpzc
         pVRRKyOV/DA885fr84w+FiG2xjwtCjskk7LWi9kbfqhx/etDVKo3TTMC5b9eI90PK7XO
         muRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=mKKhnhB+;
       spf=pass (google.com: domain of prvs=090069262=karahmed@amazon.de designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=090069262=karahmed@amazon.de";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-2101.amazon.com (smtp-fw-2101.amazon.com. [72.21.196.25])
        by mx.google.com with ESMTPS id 37si7956766qvq.206.2019.07.13.06.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jul 2019 06:53:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=090069262=karahmed@amazon.de designates 72.21.196.25 as permitted sender) client-ip=72.21.196.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=mKKhnhB+;
       spf=pass (google.com: domain of prvs=090069262=karahmed@amazon.de designates 72.21.196.25 as permitted sender) smtp.mailfrom="prvs=090069262=karahmed@amazon.de";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1563026013; x=1594562013;
  h=from:to:cc:subject:date:message-id:references:
   in-reply-to:content-id:mime-version:
   content-transfer-encoding;
  bh=Oq1JDzuzw72gaVJ3N+aVYoxBMtRhT49QZunKSm9NVAA=;
  b=mKKhnhB+/zd4fQbdxdoAAC3h8ig8RI//jseOFavALlD390KA9JLerOTi
   VxRbS7//DYkmLMP5B23VTbgQSC67u+Z7psbUfrHpNgob9ZfAsuJHQVENW
   tvKttRy0tQTqmBY6493YyQ7nSQwm775PK1k9M7Zb+Tf/04GncP1gYXzna
   o=;
X-IronPort-AV: E=Sophos;i="5.62,486,1554768000"; 
   d="scan'208";a="741626702"
Received: from iad6-co-svc-p1-lb1-vlan2.amazon.com (HELO email-inbound-relay-1a-807d4a99.us-east-1.amazon.com) ([10.124.125.2])
  by smtp-border-fw-out-2101.iad2.amazon.com with ESMTP; 13 Jul 2019 13:53:32 +0000
Received: from EX13MTAUEA001.ant.amazon.com (iad55-ws-svc-p15-lb9-vlan2.iad.amazon.com [10.40.159.162])
	by email-inbound-relay-1a-807d4a99.us-east-1.amazon.com (Postfix) with ESMTPS id 065D6A1868;
	Sat, 13 Jul 2019 13:53:27 +0000 (UTC)
Received: from EX13D01EUB003.ant.amazon.com (10.43.166.248) by
 EX13MTAUEA001.ant.amazon.com (10.43.61.82) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Sat, 13 Jul 2019 13:53:27 +0000
Received: from EX13D01EUB003.ant.amazon.com (10.43.166.248) by
 EX13D01EUB003.ant.amazon.com (10.43.166.248) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Sat, 13 Jul 2019 13:53:26 +0000
Received: from EX13D01EUB003.ant.amazon.com ([10.43.166.248]) by
 EX13D01EUB003.ant.amazon.com ([10.43.166.248]) with mapi id 15.00.1367.000;
 Sat, 13 Jul 2019 13:53:25 +0000
From: "Raslan, KarimAllah" <karahmed@amazon.de>
To: "richard.weiyang@gmail.com" <richard.weiyang@gmail.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bhe@redhat.com" <bhe@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cai@lca.pw" <cai@lca.pw>, "logang@deltatee.com" <logang@deltatee.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "osalvador@suse.de"
	<osalvador@suse.de>, "rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"mhocko@suse.com" <mhocko@suse.com>, "pasha.tatashin@oracle.com"
	<pasha.tatashin@oracle.com>
Subject: Re: [PATCH] mm: sparse: Skip no-map regions in memblocks_present
Thread-Topic: [PATCH] mm: sparse: Skip no-map regions in memblocks_present
Thread-Index: AQHVOI8IlRiU8rBOJUewLnGIizLEO6bHnIWAgAD3C4A=
Date: Sat, 13 Jul 2019 13:53:25 +0000
Message-ID: <1563026005.19043.12.camel@amazon.de>
References: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
	 <20190712230913.l35zpdiqcqa4o32f@master>
In-Reply-To: <20190712230913.l35zpdiqcqa4o32f@master>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.43.164.55]
Content-Type: text/plain; charset="utf-8"
Content-ID: <EFDECDBACA6C2447A4E251886434636E@amazon.com>
MIME-Version: 1.0
Content-Transfer-Encoding: base64
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA3LTEyIGF0IDIzOjA5ICswMDAwLCBXZWkgWWFuZyB3cm90ZToNCj4gT24g
RnJpLCBKdWwgMTIsIDIwMTkgYXQgMTA6NTE6MzFBTSArMDIwMCwgS2FyaW1BbGxhaCBBaG1lZCB3
cm90ZToNCj4gPiANCj4gPiBEbyBub3QgbWFyayByZWdpb25zIHRoYXQgYXJlIG1hcmtlZCB3aXRo
IG5vbWFwIHRvIGJlIHByZXNlbnQsIG90aGVyd2lzZQ0KPiA+IHRoZXNlIG1lbWJsb2NrIGNhdXNl
IHVubmVjZXNzYXJpbHkgYWxsb2NhdGlvbiBvZiBtZXRhZGF0YS4NCj4gPiANCj4gPiBDYzogQW5k
cmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gPiBDYzogUGF2ZWwgVGF0
YXNoaW4gPHBhc2hhLnRhdGFzaGluQG9yYWNsZS5jb20+DQo+ID4gQ2M6IE9zY2FyIFNhbHZhZG9y
IDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gPiBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5j
b20+DQo+ID4gQ2M6IE1pa2UgUmFwb3BvcnQgPHJwcHRAbGludXguaWJtLmNvbT4NCj4gPiBDYzog
QmFvcXVhbiBIZSA8YmhlQHJlZGhhdC5jb20+DQo+ID4gQ2M6IFFpYW4gQ2FpIDxjYWlAbGNhLnB3
Pg0KPiA+IENjOiBXZWkgWWFuZyA8cmljaGFyZC53ZWl5YW5nQGdtYWlsLmNvbT4NCj4gPiBDYzog
TG9nYW4gR3VudGhvcnBlIDxsb2dhbmdAZGVsdGF0ZWUuY29tPg0KPiA+IENjOiBsaW51eC1tbUBr
dmFjay5vcmcNCj4gPiBDYzogbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZw0KPiA+IFNpZ25l
ZC1vZmYtYnk6IEthcmltQWxsYWggQWhtZWQgPGthcmFobWVkQGFtYXpvbi5kZT4NCj4gPiAtLS0N
Cj4gPiBtbS9zcGFyc2UuYyB8IDQgKysrKw0KPiA+IDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlv
bnMoKykNCj4gPiANCj4gPiBkaWZmIC0tZ2l0IGEvbW0vc3BhcnNlLmMgYi9tbS9zcGFyc2UuYw0K
PiA+IGluZGV4IGZkMTMxNjYuLjMzODEwYjYgMTAwNjQ0DQo+ID4gLS0tIGEvbW0vc3BhcnNlLmMN
Cj4gPiArKysgYi9tbS9zcGFyc2UuYw0KPiA+IEBAIC0yNTYsNiArMjU2LDEwIEBAIHZvaWQgX19p
bml0IG1lbWJsb2Nrc19wcmVzZW50KHZvaWQpDQo+ID4gCXN0cnVjdCBtZW1ibG9ja19yZWdpb24g
KnJlZzsNCj4gPiANCj4gPiAJZm9yX2VhY2hfbWVtYmxvY2sobWVtb3J5LCByZWcpIHsNCj4gPiAr
DQo+ID4gKwkJaWYgKG1lbWJsb2NrX2lzX25vbWFwKHJlZykpDQo+ID4gKwkJCWNvbnRpbnVlOw0K
PiA+ICsNCj4gPiAJCW1lbW9yeV9wcmVzZW50KG1lbWJsb2NrX2dldF9yZWdpb25fbm9kZShyZWcp
LA0KPiA+IAkJCSAgICAgICBtZW1ibG9ja19yZWdpb25fbWVtb3J5X2Jhc2VfcGZuKHJlZyksDQo+
ID4gCQkJICAgICAgIG1lbWJsb2NrX3JlZ2lvbl9tZW1vcnlfZW5kX3BmbihyZWcpKTsNCj4gDQo+
IA0KPiBUaGUgbG9naWMgbG9va3MgZ29vZCwgd2hpbGUgSSBhbSBub3Qgc3VyZSB0aGlzIHdvdWxk
IHRha2UgZWZmZWN0LiBTaW5jZSB0aGUNCj4gbWV0YWRhdGEgaXMgU0VDVElPTiBzaXplIGFsaWdu
ZWQgd2hpbGUgbWVtYmxvY2sgaXMgbm90Lg0KPiANCj4gSWYgSSBhbSBjb3JyZWN0LCBvbiBhcm02
NCwgd2UgbWFyayBub21hcCBtZW1ibG9jayBpbiBtYXBfbWVtKCkNCj4gDQo+ICAgICBtZW1ibG9j
a19tYXJrX25vbWFwKGtlcm5lbF9zdGFydCwga2VybmVsX2VuZCAtIGtlcm5lbF9zdGFydCk7DQoN
ClRoZSBub21hcCBpcyBhbHNvIGRvbmUgYnkgRUZJIGNvZGUgaW4gJHtzcmN9L2RyaXZlcnMvZmly
bXdhcmUvZWZpL2FybS1pbml0LmMNCg0KLi4gYW5kIGhvcGVmdWxseSBpbiB0aGUgZnV0dXJlIGJ5
IHRoaXM6DQpodHRwczovL2xrbWwub3JnL2xrbWwvMjAxOS83LzEyLzEyNg0KDQpTbyBpdCBpcyBu
b3QgcmVhbGx5IHN0cmljbHR5IGFzc29jaWF0ZWQgd2l0aCB0aGUgbWFwX21lbSgpLg0KDQpTbyBp
dCBpcyBleHRyZW1lbHkgZGVwZW5kZW50IG9uIHRoZSBwbGF0Zm9ybSBob3cgbXVjaCBtZW1vcnkg
d2lsbCBlbmQgdXAgbWFwcGVkwqANCmFzIG5vbWFwLg0KDQo+IA0KPiBBbmQga2VybmVsIHRleHQg
YXJlYSBpcyBsZXNzIHRoYW4gNDBNLCBpZiBJIGFtIHJpZ2h0LiBUaGlzIG1lYW5zDQo+IG1lbWJs
b2Nrc19wcmVzZW50IHdvdWxkIHN0aWxsIG1hcmsgdGhlIHNlY3Rpb24gcHJlc2VudC4gDQo+IA0K
PiBXb3VsZCB5b3UgbWluZCBzaG93aW5nIGhvdyBtdWNoIG1lbW9yeSByYW5nZSBpdCBpcyBtYXJr
ZWQgbm9tYXA/DQoNCldlIGFjdHVhbGx5IGhhdmUgc29tZSBkb3duc3RyZWFtIHBhdGNoZXMgdGhh
dCBhcmUgdXNpbmcgdGhpcyBub21hcCBmbGFnIGZvcg0KbW9yZSB0aGFuIHRoZSB1c2UtY2FzZXMg
SSBkZXNjcmliZWQgYWJvdmUgd2hpY2ggd291bGQgZW5mbGF0ZSB0aGUgbm9tYXAgcmVnaW9uc8Kg
DQphIGJpdCA6KQ0KDQo+IA0KPiA+IA0KPiA+IC0tIA0KPiA+IDIuNy40DQo+IA0KCgoKQW1hem9u
IERldmVsb3BtZW50IENlbnRlciBHZXJtYW55IEdtYkgKS3JhdXNlbnN0ci4gMzgKMTAxMTcgQmVy
bGluCkdlc2NoYWVmdHNmdWVocnVuZzogQ2hyaXN0aWFuIFNjaGxhZWdlciwgUmFsZiBIZXJicmlj
aApFaW5nZXRyYWdlbiBhbSBBbXRzZ2VyaWNodCBDaGFybG90dGVuYnVyZyB1bnRlciBIUkIgMTQ5
MTczIEIKU2l0ejogQmVybGluClVzdC1JRDogREUgMjg5IDIzNyA4NzkKCgo=

