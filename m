Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E82E3C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:11:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A839320C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:11:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A839320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F53F6B0006; Tue,  6 Aug 2019 12:11:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A4B16B0008; Tue,  6 Aug 2019 12:11:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346606B000A; Tue,  6 Aug 2019 12:11:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F356E6B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:11:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n9so51741710pgq.4
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:11:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=jVOM5a6tEq3rSZS49Whn2xN+DBIoh2uWmRc7Y5fWTbI=;
        b=owRF0qvfhBAC61gtMgVlkrnWhJLnT17jEPxNKuNwc3FVpi7u2qdMYCY5xHOOuCUIi6
         w/iVNW8rbNSw9zVUaSqS90JLfwT/tISGhwLl+49IVry/bFAhcC/pmKfBxc38NrsGF0VP
         KEQQGjtUJnebLxhJXHRNw0W7w9wwSa5AldqU0+Yyj8J8EtBjmIc3cPQX0r0EnbspUmXM
         IZidhaqGPz3luD7YpMS6uB/ZZqeMKtWnFMn3wuItm+wffqX2rMV6PeBXdw0C051yAqKV
         Bi+hi6lxMOFnbPFDB6TeHvF9LgCZ81CyAGc2o+ROqvioVslnYT26JvTOjEuSHn+QPAKZ
         xRJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUJlBgvhmiyw2GNJYfdL9KfwF6Z7SOeQ9D1OrQ4A0/MNjQRGmVt
	LIr0jPWZ8r1wRs5fvE1JLQt/y+ei8g1pRYKuJEvNjyK1ibRKuLckiAWkxDeYwOyj9RYoEIJNx9t
	gSzlOuve0qJ5XmNfyMm9hafJYo1//1EWwAz9ERk/rDRb5D6k4ytGLBrOBJdfAQYCqsA==
X-Received: by 2002:a63:4562:: with SMTP id u34mr3674183pgk.288.1565107896598;
        Tue, 06 Aug 2019 09:11:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOwPmMshhz76IiCH5zooodqNEUnuU1CpUCsbLUTOigmDIK6+jDTw7njhT1GvKngSoBCkv2
X-Received: by 2002:a63:4562:: with SMTP id u34mr3674116pgk.288.1565107895621;
        Tue, 06 Aug 2019 09:11:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107895; cv=none;
        d=google.com; s=arc-20160816;
        b=YSQJGjIHPSMLPtWBdCNmR2jeX2HxmS5dTjg0TKQnrNaPG2/UJUuVOD9WL9uyMDFz2V
         AFqVoUq7kgSXaNyIXkxgsd11C0V4d6a3h7xQ3BR3q/IKRfsM4ugc9k/XzF8t9D36wCK6
         RnwuESXgCEOfGKg5hcLAW0WQh1GI69wATzm0imRfjneR5IEMiJfupgkPjIxE183uBJBQ
         CXlpATH5VVMZMnq22fbHgGyaAzGE8UQV6MUBi8c3qfKz9+VfcnjQTIAr2bMQTlNf5q5r
         KU9ZWSJdZkU0KM7upQXEKBKWf9iDfYCzu4dSw+RE/cqHH3hE7tzi6WCwaMW3echn1GyA
         Dg8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=jVOM5a6tEq3rSZS49Whn2xN+DBIoh2uWmRc7Y5fWTbI=;
        b=F2uhWKDULy0Ci1ae2L0TwHLvrZW/E0lHKryli119q5fwYTRaAmuZebLMT5YqkIZRDp
         Vl8daV6NmXJ7K0phYy3o0O0/Z/X5BStpksfXX/1Rppa/Aqz0vhdeWcKEPOzXoDZdaEw7
         J6WptRmA5qtsynZlattxd5TLWw+wUkv04wQzt2Ca0pghgKthxa6Zx7aDnOkqW12rtKkt
         hhJfjj8u3bjECFqw14J9kR8Dy8vjxQLrFuJWjy/yku3k+thfp8wXUyGi2KihtvOQd2Dj
         rmfEvJwekbXAOJW9+YNDe++VEqKADVMlkH9hc18RfVfLC+gxSGe1RUII276h6VzyZD84
         MgtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z124si29102308pfb.208.2019.08.06.09.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 09:11:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 09:11:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="175923145"
Received: from orsmsx103.amr.corp.intel.com ([10.22.225.130])
  by fmsmga007.fm.intel.com with ESMTP; 06 Aug 2019 09:11:34 -0700
Received: from orsmsx114.amr.corp.intel.com ([169.254.8.96]) by
 ORSMSX103.amr.corp.intel.com ([169.254.5.108]) with mapi id 14.03.0439.000;
 Tue, 6 Aug 2019 09:11:34 -0700
From: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Vlastimil Babka
	<vbabka@suse.cz>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "Hansen, Dave" <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: RE: [PATCH V2] fork: Improve error message for corrupted page tables
Thread-Topic: [PATCH V2] fork: Improve error message for corrupted page
 tables
Thread-Index: AQHVTARBoUI2WxhjVEayaDrB3An0D6buNXYAgAAKzgCAAAqoYA==
Date: Tue, 6 Aug 2019 16:11:34 +0000
Message-ID: <FFF73D592F13FD46B8700F0A279B802F4FA16F3E@ORSMSX114.amr.corp.intel.com>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
 <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
 <926d50ce-4742-0ae7-474c-ef561fe23cdd@arm.com>
In-Reply-To: <926d50ce-4742-0ae7-474c-ef561fe23cdd@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMWMwZTViNDQtZTY2NS00ZGIyLWJiNDEtNDA0MWUzNGJlZjAyIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoibnVsc2VlbWpRSkdYTzJjVEloM0swVisrYVVFRTBWWWc0TDJYdjV0blVWblowQ0lVRmNKbmJHa29ZWWNqZmdkZCJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: request-justification,no-action
x-originating-ip: [10.22.254.138]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiA+PiBXaXRob3V0IHBhdGNoOg0KPiA+PiAtLS0tLS0tLS0tLS0tLQ0KPiA+PiBbICAyMDQuODM2
NDI1XSBtbS9wZ3RhYmxlLWdlbmVyaWMuYzoyOTogYmFkIHA0ZA0KPiA+PiAwMDAwMDAwMDg5ZWI0
ZTkyKDgwMDAwMDAyNWY5NDE0NjcpDQo+ID4+IFsgIDIwNC44MzY1NDRdIEJVRzogQmFkIHJzcy1j
b3VudGVyIHN0YXRlIG1tOjAwMDAwMDAwZjc1ODk1ZWEgaWR4OjANCj4gPj4gdmFsOjIgWyAgMjA0
LjgzNjYxNV0gQlVHOiBCYWQgcnNzLWNvdW50ZXIgc3RhdGUgbW06MDAwMDAwMDBmNzU4OTVlYQ0K
PiA+PiBpZHg6MSB2YWw6NSBbICAyMDQuODM2Njg1XSBCVUc6IG5vbi16ZXJvIHBndGFibGVzX2J5
dGVzIG9uIGZyZWVpbmcNCj4gPj4gbW06IDIwNDgwDQo+ID4+DQo+ID4+IFdpdGggcGF0Y2g6DQo+
ID4+IC0tLS0tLS0tLS0tDQo+ID4+IFsgICA2OS44MTU0NTNdIG1tL3BndGFibGUtZ2VuZXJpYy5j
OjI5OiBiYWQgcDRkDQo+IDAwMDAwMDAwODQ2NTM2NDIoODAwMDAwMDI1Y2EzNzQ2NykNCj4gPj4g
WyAgIDY5LjgxNTg3Ml0gQlVHOiBCYWQgcnNzLWNvdW50ZXIgc3RhdGUgbW06MDAwMDAwMDAwMTRh
NmMwMw0KPiB0eXBlOk1NX0ZJTEVQQUdFUyB2YWw6Mg0KPiA+PiBbICAgNjkuODE1OTYyXSBCVUc6
IEJhZCByc3MtY291bnRlciBzdGF0ZSBtbTowMDAwMDAwMDAxNGE2YzAzDQo+IHR5cGU6TU1fQU5P
TlBBR0VTIHZhbDo1DQo+ID4+IFsgICA2OS44MTYwNTBdIEJVRzogbm9uLXplcm8gcGd0YWJsZXNf
Ynl0ZXMgb24gZnJlZWluZyBtbTogMjA0ODANCj4gPj4NCj4gPj4gQWxzbywgY2hhbmdlIHByaW50
IGZ1bmN0aW9uIChmcm9tIHByaW50ayhLRVJOX0FMRVJULCAuLikgdG8NCj4gPj4gcHJfYWxlcnQo
KSkgc28gdGhhdCBpdCBtYXRjaGVzIHRoZSBvdGhlciBwcmludCBzdGF0ZW1lbnQuDQo+ID4+DQo+
ID4+IENjOiBJbmdvIE1vbG5hciA8bWluZ29Aa2VybmVsLm9yZz4NCj4gPj4gQ2M6IFZsYXN0aW1p
bCBCYWJrYSA8dmJhYmthQHN1c2UuY3o+DQo+ID4+IENjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6
QGluZnJhZGVhZC5vcmc+DQo+ID4+IENjOiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5k
YXRpb24ub3JnPg0KPiA+PiBDYzogQW5zaHVtYW4gS2hhbmR1YWwgPGFuc2h1bWFuLmtoYW5kdWFs
QGFybS5jb20+DQo+ID4+IEFja2VkLWJ5OiBEYXZlIEhhbnNlbiA8ZGF2ZS5oYW5zZW5AaW50ZWwu
Y29tPg0KPiA+PiBTdWdnZXN0ZWQtYnk6IERhdmUgSGFuc2VuIDxkYXZlLmhhbnNlbkBpbnRlbC5j
b20+DQo+ID4+IFNpZ25lZC1vZmYtYnk6IFNhaSBQcmFuZWV0aCBQcmFraHlhIDxzYWkucHJhbmVl
dGgucHJha2h5YUBpbnRlbC5jb20+DQo+ID4NCj4gPiBBY2tlZC1ieTogVmxhc3RpbWlsIEJhYmth
IDx2YmFia2FAc3VzZS5jej4NCj4gPg0KPiA+IEkgd291bGQgYWxzbyBhZGQgc29tZXRoaW5nIGxp
a2UgdGhpcyB0byByZWR1Y2UgcmlzayBvZiBicmVha2luZyBpdCBpbg0KPiA+IHRoZQ0KPiA+IGZ1
dHVyZToNCj4gPg0KPiA+IC0tLS04PC0tLS0NCj4gPiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51
eC9tbV90eXBlc190YXNrLmgNCj4gPiBiL2luY2x1ZGUvbGludXgvbW1fdHlwZXNfdGFzay5oIGlu
ZGV4IGQ3MDE2ZGNiMjQ1ZS4uYTZmODNjYmU0NjAzDQo+ID4gMTAwNjQ0DQo+ID4gLS0tIGEvaW5j
bHVkZS9saW51eC9tbV90eXBlc190YXNrLmgNCj4gPiArKysgYi9pbmNsdWRlL2xpbnV4L21tX3R5
cGVzX3Rhc2suaA0KPiA+IEBAIC0zNiw2ICszNiw5IEBAIHN0cnVjdCB2bWFjYWNoZSB7DQo+ID4g
IAlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYXNbVk1BQ0FDSEVfU0laRV07ICB9Ow0KPiA+DQo+
ID4gKy8qDQo+ID4gKyAqIFdoZW4gdG91Y2hpbmcgdGhpcywgdXBkYXRlIGFsc28gcmVzaWRlbnRf
cGFnZV90eXBlcyBpbg0KPiA+ICtrZXJuZWwvZm9yay5jICAqLw0KPiA+ICBlbnVtIHsNCj4gPiAg
CU1NX0ZJTEVQQUdFUywJLyogUmVzaWRlbnQgZmlsZSBtYXBwaW5nIHBhZ2VzICovDQo+ID4gIAlN
TV9BTk9OUEFHRVMsCS8qIFJlc2lkZW50IGFub255bW91cyBwYWdlcyAqLw0KPiA+DQo+IA0KPiBB
Z3JlZWQgYW5kIHdpdGggdGhhdA0KPiANCj4gUmV2aWV3ZWQtYnk6IEFuc2h1bWFuIEtoYW5kdWFs
IDxhbnNodW1hbi5raGFuZHVhbEBhcm0uY29tPg0KDQpUaGFua3MgZm9yIHRoZSByZXZpZXcgYW5k
IGhlbHBpbmcgbWUgaW4gaW1wcm92aW5nIHRoZSBwYXRjaCA6KQ0KDQpSZWdhcmRzLA0KU2FpDQo=

