Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=CHARSET_FARAWAY_HEADER,
	FROM_EXCESS_BASE64,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E156BC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 12:36:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 892132339E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 12:36:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 892132339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tencent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E727F6B0006; Thu, 29 Aug 2019 08:36:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23166B000C; Thu, 29 Aug 2019 08:36:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D380A6B000D; Thu, 29 Aug 2019 08:36:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id B14FC6B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 08:36:35 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 49410824CA08
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:36:35 +0000 (UTC)
X-FDA: 75875413950.23.sack64_1c37225049157
X-HE-Tag: sack64_1c37225049157
X-Filterd-Recvd-Size: 4315
Received: from mail2.tencent.com (mail2.tencent.com [163.177.67.195])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:36:33 +0000 (UTC)
Received: from EXHUB-SZMail03.tencent.com (unknown [10.14.6.33])
	by mail2.tencent.com (Postfix) with ESMTP id 236128ED3B;
	Thu, 29 Aug 2019 20:36:30 +0800 (CST)
Received: from EX-SZ008.tencent.com (10.28.6.32) by EXHUB-SZMail03.tencent.com
 (10.14.6.33) with Microsoft SMTP Server (TLS) id 14.3.408.0; Thu, 29 Aug 2019
 20:36:30 +0800
Received: from EX-SZ013.tencent.com (10.28.6.37) by EX-SZ008.tencent.com
 (10.28.6.32) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5; Thu, 29 Aug
 2019 20:36:29 +0800
Received: from EX-SZ013.tencent.com ([fe80::ad97:241e:365:d21a]) by
 EX-SZ013.tencent.com ([fe80::ad97:241e:365:d21a%8]) with mapi id
 15.01.1713.004; Thu, 29 Aug 2019 20:36:29 +0800
From: =?gb2312?B?dG9ubnlsdSjCvda+uNUp?= <tonnylu@tencent.com>
To: Matthew Wilcox <willy@infradead.org>, zhigang lu <luzhigang001@gmail.com>
CC: "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, =?gb2312?B?aHpob25nemhhbmco1cXqu9bQKQ==?=
	<hzhongzhang@tencent.com>, =?gb2312?B?a25pZ2h0emhhbmco1cXX2sP3KQ==?=
	<knightzhang@tencent.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIXSBtbS9odWdldGxiOiBhdm9pZCBsb29waW5nIHRvIHRo?=
 =?gb2312?B?ZSBzYW1lIGh1Z2VwYWdlIGlmICFwYWdlcyBhbmQgIXZtYXMoSW50ZXJuZXQg?=
 =?gb2312?Q?mail)?=
Thread-Topic: [PATCH] mm/hugetlb: avoid looping to the same hugepage if !pages
 and !vmas(Internet mail)
Thread-Index: AQHVXl4rJSmKppaj5kmsIm45+JghiqcRfk+AgACO92A=
Date: Thu, 29 Aug 2019 12:36:29 +0000
Message-ID: <f5d5fd353d744ce2b267bfe27db26b1f@tencent.com>
References: <CABNBeK+6C9ToJcjhGBJQm5dDaddA0USOoRFmRckZ27PhLGUfQg@mail.gmail.com>
 <20190829115457.GC6590@bombadil.infradead.org>
In-Reply-To: <20190829115457.GC6590@bombadil.infradead.org>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.14.87.252]
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCi0tLS0t08q8/tStvP4tLS0tLQ0Kt6K8/sjLOiBNYXR0aGV3IFdpbGNveCA8d2lsbHlAaW5m
cmFkZWFkLm9yZz4gDQq3osvNyrG85DogMjAxOcTqONTCMjnI1SAxOTo1NQ0KytW8/sjLOiB6aGln
YW5nIGx1IDxsdXpoaWdhbmcwMDFAZ21haWwuY29tPg0Ks63LzTogbWlrZS5rcmF2ZXR6QG9yYWNs
ZS5jb207IGxpbnV4LW1tQGt2YWNrLm9yZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsg
dG9ubnlsdSjCvda+uNUpIDx0b25ueWx1QHRlbmNlbnQuY29tPjsgaHpob25nemhhbmco1cXqu9bQ
KSA8aHpob25nemhhbmdAdGVuY2VudC5jb20+OyBrbmlnaHR6aGFuZyjVxdfaw/cpIDxrbmlnaHR6
aGFuZ0B0ZW5jZW50LmNvbT4NCtb3zOI6IFJlOiBbUEFUQ0hdIG1tL2h1Z2V0bGI6IGF2b2lkIGxv
b3BpbmcgdG8gdGhlIHNhbWUgaHVnZXBhZ2UgaWYgIXBhZ2VzIGFuZCAhdm1hcyhJbnRlcm5ldCBt
YWlsKQ0KDQpPbiBUaHUsIEF1ZyAyOSwgMjAxOSBhdCAwNzozNzoyMlBNICswODAwLCB6aGlnYW5n
IGx1IHdyb3RlOg0KPiBUaGlzIGNoYW5nZSBncmVhdGx5IGRlY3JlYXNlIHRoZSB0aW1lIG9mIG1t
YXBpbmcgYSBmaWxlIGluIGh1Z2V0bGJmcy4NCj4gV2l0aCBNQVBfUE9QVUxBVEUgZmxhZywgaXQg
dGFrZXMgYWJvdXQgNTAgbWlsbGlzZWNvbmRzIHRvIG1tYXAgYQ0KPiBleGlzdGluZyAxMjhHQiBm
aWxlIGluIGh1Z2V0bGJmcy4gV2l0aCB0aGlzIGNoYW5nZSwgaXQgdGFrZXMgbGVzcw0KPiB0aGVu
IDEgbWlsbGlzZWNvbmQuDQoNCllvdSdyZSBnb2luZyB0byBuZWVkIHRvIGZpbmQgYSBuZXcgd2F5
IG9mIHNlbmRpbmcgcGF0Y2hlczsgdGhpcyBwYXRjaCBpcw0KbWFuZ2xlZCBieSB5b3VyIG1haWwg
c3lzdGVtLg0KDQoNCj4gQEAgLTQzOTEsNiArNDM5MSwxNyBAQCBsb25nIGZvbGxvd19odWdldGxi
X3BhZ2Uoc3RydWN0IG1tX3N0cnVjdCAqbW0sDQo+IHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1h
LA0KPiAgIGJyZWFrOw0KPiAgIH0NCj4gICB9DQo+ICsNCj4gKyBpZiAoIXBhZ2VzICYmICF2bWFz
ICYmICFwZm5fb2Zmc2V0ICYmDQo+ICsgICAgICh2YWRkciArIGh1Z2VfcGFnZV9zaXplKGgpIDwg
dm1hLT52bV9lbmQpICYmDQo+ICsgICAgIChyZW1haW5kZXIgPj0gcGFnZXNfcGVyX2h1Z2VfcGFn
ZShoKSkpIHsNCj4gKyB2YWRkciArPSBodWdlX3BhZ2Vfc2l6ZShoKTsNCj4gKyByZW1haW5kZXIg
LT0gcGFnZXNfcGVyX2h1Z2VfcGFnZShoKTsNCj4gKyBpICs9IHBhZ2VzX3Blcl9odWdlX3BhZ2Uo
aCk7DQo+ICsgc3Bpbl91bmxvY2socHRsKTsNCj4gKyBjb250aW51ZTsNCj4gKyB9DQoNClRoZSBj
b25jZXB0IHNlZW1zIGdvb2QgdG8gbWUuICBUaGUgZGVzY3JpcHRpb24gYWJvdmUgY291bGQgZG8g
d2l0aCBzb21lDQpiZXR0ZXIgZXhwbGFuYXRpb24gdGhvdWdoLg0KDQpUaGFua3MsIFdpbGx5LiBJ
IHdpbGwgYWRkIG1vcmUgZXhwbGFuYXRpb24gYW5kIHJlc2VuZCB0aGUgcGF0Y2hlcyBpbiBwbGFp
biB0ZXh0IG1vZGUuDQo=

