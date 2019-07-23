Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 409BEC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:39:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 024BA229EB
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 21:39:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 024BA229EB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 980E46B0005; Tue, 23 Jul 2019 17:39:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 933178E0003; Tue, 23 Jul 2019 17:39:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 820DD8E0002; Tue, 23 Jul 2019 17:39:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DDFD6B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:39:22 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g18so22746048plj.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 14:39:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=sywnubM35BLBgHmW5shTGU/Jcrzf9lvle04XJG8DioA=;
        b=FUYzgaVG0Ass4jfnf+NmSithcK9dPQS5FVxmhO+hAR+2qwPquYGfhLt3yn/vDp6mdD
         T9KZRSFw7+tmDCMn8Dx9Jjlw9jyWRipPxbInGm0Pk1M1OBIfuSZwne89WOMDikNY8701
         jbe8t/UxkFg30tQLazSJLJTWQtEXiGljfJWXqVmAh1FczWMSwoU6H8opCICZm4EyMOE0
         C9LoM6E0W00/ikDoN5GhQmq7rgzKvs6omwJ1dFAkZeSoQ9cMuJzJ8DvvnficsynmGhRE
         c3sOqa/dnd2szcryPl9o3ghWmsnyMWxvu8xjblw6aFEnCxv+4fOKA6znR/OLF/Y3S809
         vcIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXFD+M0+p1cZqezc/WzRUPzGe5GRjQ5kGlk7gAjldy+Ua84lm21
	GdjQVqfS3DGjx3PFapT+YrVHZzMrWA7ZYv3LmZUj+fo5BRBQFaTlqtnOKWsoRpsYdvXGb6i1EKu
	N0YCTsS9OJmrrITMIp9PYxUFZAN4+OGDuDCnezOmsNH+SR4khdcYGNLNpeXt1cQWRBg==
X-Received: by 2002:a62:303:: with SMTP id 3mr7764790pfd.118.1563917962009;
        Tue, 23 Jul 2019 14:39:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbOLcfE/LUMrP0o15RVt3j2vr2fXrzM8aAvBErB1sQZc+hBFOEW/0wVNW7ChBZCNXJzdhV
X-Received: by 2002:a62:303:: with SMTP id 3mr7764748pfd.118.1563917961429;
        Tue, 23 Jul 2019 14:39:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563917961; cv=none;
        d=google.com; s=arc-20160816;
        b=J2/7CiHRkzBpLfdgf7swvdu4GWpXpfiHXeNy0HAx9g3zBJcrO56KF/+5CYNQ1jBcGt
         1ssz+C0ytOYNrka9AXNDmnobmUodqn48ROxZwDaEnxASkb1lShs+ZO8IBehDLfTZQCmC
         0wLi2G0xY/hpHFMJ1L3Ly6o4xkqtr+yGM7XQ1Sg0UfiCi3HoISIF0LkoPvAwDqqOKT0F
         tD8h3w11d90MbNVsi6GOVhgJ2JWh7OeoSeHraO972BhXgYQkpRVJf65PulkiVYu09nHg
         T7F0i8WRC5fLgu5uvUXwtrPfvINLPA3+huNgehYvs3UYLgV+wsL+thtFuPt2rgDK5Jus
         cUqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=sywnubM35BLBgHmW5shTGU/Jcrzf9lvle04XJG8DioA=;
        b=EGHb1gAM0Z/rJNf7vgHIT/7fF3SPVpzjU/QubM3iOlj47U2tDr8A0laHoILJkwX532
         azfzYS4pfcvTUKM/ob4OOxncYwG0Oq3hx1LHeyveTGWYeZDWM538goJzvLYBeP7/AjM2
         68SPm8kpK/7JRDSJGKkIx1hXXRN7uRKTfcnV3wymJRfzD9tUYvQf8h8LyM8yQcSZbc7t
         lgAAPj/PZ5uQLcxIEPDOY6j8nzs/6qOVm78Q5aO77b1Qa57WmZ8CHwe9Bb8WbW+5Yp1S
         Etq6isKTsZlQpD5sg3uUbx+V0xJcp5jvHqCeMSZHXCpCPvS+IsTHfD03I7CzpY270rEh
         NTAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n21si14705988pgf.339.2019.07.23.14.39.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 14:39:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 14:39:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,300,1559545200"; 
   d="scan'208";a="193208522"
Received: from fmsmsx104.amr.corp.intel.com ([10.18.124.202])
  by fmsmga004.fm.intel.com with ESMTP; 23 Jul 2019 14:39:20 -0700
Received: from fmsmsx122.amr.corp.intel.com (10.18.125.37) by
 fmsmsx104.amr.corp.intel.com (10.18.124.202) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 23 Jul 2019 14:39:20 -0700
Received: from crsmsx103.amr.corp.intel.com (172.18.63.31) by
 fmsmsx122.amr.corp.intel.com (10.18.125.37) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Tue, 23 Jul 2019 14:39:20 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.124]) by
 CRSMSX103.amr.corp.intel.com ([169.254.4.76]) with mapi id 14.03.0439.000;
 Tue, 23 Jul 2019 15:39:18 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Ralph Campbell <rcampbell@nvidia.com>, Matthew Wilcox
	<willy@infradead.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>,
	"Vlastimil Babka" <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe
	<jgg@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
	<torvalds@linux-foundation.org>
Subject: RE: [PATCH v2 1/3] mm: document zone device struct page field usage
Thread-Topic: [PATCH v2 1/3] mm: document zone device struct page field usage
Thread-Index: AQHVPmhqrWtcBDDhM0SqFmlAUI6ZYabVowsAgABn2YCAANhwgIACPs6A//+fIVA=
Date: Tue, 23 Jul 2019 21:39:17 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79E2E610@CRSMSX101.amr.corp.intel.com>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
 <20190721160204.GB363@bombadil.infradead.org>
 <20190722051345.GB6157@iweiny-DESK2.sc.intel.com>
 <20190722110825.GD363@bombadil.infradead.org>
 <80dbf7fc-5c13-f43f-7b87-8273126562e9@nvidia.com>
In-Reply-To: <80dbf7fc-5c13-f43f-7b87-8273126562e9@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYTYwNWJiNTUtMWZkZC00OGYyLThhNTktMGQ0MTJiNGFiMzJlIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiU0Irc3ZON2x4MWJQNUFZY1ZCcEh2SUxaRndzcFZBSnBkSHp0TGVyVWtQcllVXC9BUHU4dHBVdWFRU2ZTUlY0NG0ifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiANCj4gT24gNy8yMi8xOSA0OjA4IEFNLCBNYXR0aGV3IFdpbGNveCB3cm90ZToNCj4gPiBPbiBT
dW4sIEp1bCAyMSwgMjAxOSBhdCAxMDoxMzo0NVBNIC0wNzAwLCBJcmEgV2Vpbnkgd3JvdGU6DQo+
ID4+IE9uIFN1biwgSnVsIDIxLCAyMDE5IGF0IDA5OjAyOjA0QU0gLTA3MDAsIE1hdHRoZXcgV2ls
Y294IHdyb3RlOg0KPiA+Pj4gT24gRnJpLCBKdWwgMTksIDIwMTkgYXQgMTI6Mjk6NTNQTSAtMDcw
MCwgUmFscGggQ2FtcGJlbGwgd3JvdGU6DQo+ID4+Pj4gU3RydWN0IHBhZ2UgZm9yIFpPTkVfREVW
SUNFIHByaXZhdGUgcGFnZXMgdXNlcyB0aGUgcGFnZS0+bWFwcGluZw0KPiA+Pj4+IGFuZCBhbmQg
cGFnZS0+aW5kZXggZmllbGRzIHdoaWxlIHRoZSBzb3VyY2UgYW5vbnltb3VzIHBhZ2VzIGFyZQ0K
PiA+Pj4+IG1pZ3JhdGVkIHRvIGRldmljZSBwcml2YXRlIG1lbW9yeS4gVGhpcyBpcyBzbyBybWFw
X3dhbGsoKSBjYW4gZmluZA0KPiA+Pj4+IHRoZSBwYWdlIHdoZW4gbWlncmF0aW5nIHRoZSBaT05F
X0RFVklDRSBwcml2YXRlIHBhZ2UgYmFjayB0byBzeXN0ZW0NCj4gbWVtb3J5Lg0KPiA+Pj4+IFpP
TkVfREVWSUNFIHBtZW0gYmFja2VkIGZzZGF4IHBhZ2VzIGFsc28gdXNlIHRoZSBwYWdlLT5tYXBw
aW5nDQo+IGFuZA0KPiA+Pj4+IHBhZ2UtPmluZGV4IGZpZWxkcyB3aGVuIGZpbGVzIGFyZSBtYXBw
ZWQgaW50byBhIHByb2Nlc3MgYWRkcmVzcyBzcGFjZS4NCj4gPj4+Pg0KPiA+Pj4+IFJlc3RydWN0
dXJlIHN0cnVjdCBwYWdlIGFuZCBhZGQgY29tbWVudHMgdG8gbWFrZSB0aGlzIG1vcmUgY2xlYXIu
DQo+ID4+Pg0KPiA+Pj4gTkFLLiAgSSBqdXN0IGdvdCByaWQgb2YgdGhpcyBraW5kIG9mIGZvb2xp
c2huZXNzIGZyb20gc3RydWN0IHBhZ2UsDQo+ID4+PiBhbmQgeW91J3JlIG1ha2luZyBpdCBoYXJk
ZXIgdG8gdW5kZXJzdGFuZCwgbm90IGVhc2llci4gIFRoZSBjb21tZW50cw0KPiA+Pj4gY291bGQg
YmUgaW1wcm92ZWQsIGJ1dCBkb24ndCBsYXkgaXQgb3V0IGxpa2UgdGhpcyBhZ2Fpbi4NCj4gPj4N
Cj4gPj4gV2FzIFYxIG9mIFJhbHBocyBwYXRjaCBvaz8gIEl0IHNlZW1lZCBvayB0byBtZS4NCj4g
Pg0KPiA+IFllcywgdjEgd2FzIGZpbmUuICBUaGlzIHNlZW1zIGxpa2UgYSByZWdyZXNzaW9uLg0K
PiA+DQo+IA0KPiBUaGlzIGlzIGFib3V0IHdoYXQgcGVvcGxlIGZpbmQgImVhc2llc3QgdG8gdW5k
ZXJzdGFuZCIgYW5kIHNvIEknbSBub3QNCj4gc3VycHJpc2VkIHRoYXQgb3BpbmlvbnMgZGlmZmVy
Lg0KPiBXaGF0IGlmIEkgcG9zdCBhIHYzIGJhc2VkIG9uIHYxIGJ1dCByZW1vdmUgdGhlIF96ZF9w
YWRfKiB2YXJpYWJsZXMgdGhhdA0KPiBDaHJpc3RvcGggZm91bmQgbWlzbGVhZGluZyBhbmQgYWRk
IHNvbWUgbW9yZSBjb21tZW50cyBhYm91dCBob3cgdGhlDQo+IGRpZmZlcmVudCBaT05FX0RFVklD
RSB0eXBlcyB1c2UgdGhlIDMgcmVtYWluaW5nIHdvcmRzIChiYXNpY2FsbHkgdGhlDQo+IGNvbW1l
bnQgZnJvbSB2Mik/DQoNCkknbSBvayB3aXRoIHRoYXQuLi4NCg0KSXJhDQoNCg==

