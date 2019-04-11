Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88FCAC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F8692083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F8692083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D51926B0005; Thu, 11 Apr 2019 11:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFF686B000D; Thu, 11 Apr 2019 11:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7BC06B000E; Thu, 11 Apr 2019 11:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76BD16B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:21:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f14so4589316pgf.12
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:21:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=mDfoE6wE+iHLLf4Ng64SszcGcnad8zY7Z2JToZcJlWM=;
        b=E+lOMrwqiW2XKu6Vho8uMWrpdq2MaNng/4qQKN3YkmTzCLGBzxUWbtVEMrcIL5Kc73
         3eWX4KEMAV27LnVC1sUpGkdL66QApoXRz00UBDKMW3oq6M8twL9UgQoAgORZGzqycFZk
         pCvSFXVJC4+zldq/HcYzlOCJRcLYwFDxy4bBHiIldIZ177HdTR413iIS8QSBe9M2pZy1
         rGIUQWAQUEuOPr6o+wLhH8g5BcrIbZ1LLheLRp5dES9EgYfYxF9rI/rfq8WOym1zECHn
         VOn4I5GiN7IO8jTrV9x4xVhOW7jCWt5JOZ8qZX/17qc5ttCuOQh/hJPtmUeSAzId6oZM
         CRHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUfGSJ+cgfv/SL49C3dkItjJAOkaiDVvjl6b9Jm1MujhFUuHOlG
	3PUFkm5+D+LTs29BGRXEhXOBsjC1gxoDkieC06pufbCYef+jMvQ9J0pZSSI0MdIAHZxQ/Fg+aPJ
	HuGQo1I5k34m9IEwsEcwoHJ8gUotWoA1sbZ/9RsGbdM8SQl4rITbZSKsv3tp8SWo5Gg==
X-Received: by 2002:a65:5106:: with SMTP id f6mr46838617pgq.253.1554996073020;
        Thu, 11 Apr 2019 08:21:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmULY2G5tMQchJQGWA5UGu7+ZgAcir5h1wlwQF7hQIa8BDGyhbBgZlUfK7wrBv3pE9xd9X
X-Received: by 2002:a65:5106:: with SMTP id f6mr46838524pgq.253.1554996072057;
        Thu, 11 Apr 2019 08:21:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996072; cv=none;
        d=google.com; s=arc-20160816;
        b=n4zm68Z7M98xmyMdl3WbM2bj8uAH9N8+gzXIW4an7V3UcQJJhWqDhM1xE2+yLZIDJO
         hY46xqmRwpzr1uITmOkyJ98oe5Z5PvmMZ+B5y5uHWoBWZSCs452s5eJiOqMWpfzAQMiJ
         AwxMT+LSYW3QNZzRrCIQUXbbfR1nR3C8IzpnXIvw7uCDsFF3ykfj01I039wuAlx+Z9lJ
         wel5V8Ao8uX+IchWBEkjfNizNN4v2gPrNUPs1vlrfBjmHtVAX77UHqfMfGNmlYXdQ9Oq
         8VXqEWZEd7EjRZusly55FNRduRu4+rH0xYvJt7IsWZ6dwh/GEdZXWPuEvEDj/aoA7a0x
         jhcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=mDfoE6wE+iHLLf4Ng64SszcGcnad8zY7Z2JToZcJlWM=;
        b=H4bVTOg+PCHWI/if0ZaXDqLY53D1ahYAWniKapQra3fTGnydpMeNgg+0qX15FGzANC
         6dkVhZjW2bIUxijVGydOtwJWOrkVD/YAto9hQNxlFa9rHYZM/uIsg8M4XvccI4vr3q9A
         hYoe/BLY5y3Rht0a7iBTJjFBquHD5NrH/q9TWA9j8NQ6ekmd1fRCwVyWcHVPWI0Fdlkt
         7rhFus12dHUH30FUHKhXP9fjtxCYyYSfKc7jAB0jCXOs2UHltiapb2hh2vX/lglqo2mZ
         2Ot0V5feA5WVjTfFMpO6S9ffXiyaslWxBsje5FTSZDBYr2I7H/wTHBzIH1nGeCfWio9y
         jtMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id cn16si36719923plb.174.2019.04.11.08.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:21:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Apr 2019 08:21:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,337,1549958400"; 
   d="scan'208";a="150001000"
Received: from fmsmsx108.amr.corp.intel.com ([10.18.124.206])
  by orsmga002.jf.intel.com with ESMTP; 11 Apr 2019 08:21:10 -0700
Received: from fmsmsx102.amr.corp.intel.com (10.18.124.200) by
 FMSMSX108.amr.corp.intel.com (10.18.124.206) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 11 Apr 2019 08:21:10 -0700
Received: from crsmsx152.amr.corp.intel.com (172.18.7.35) by
 FMSMSX102.amr.corp.intel.com (10.18.124.200) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 11 Apr 2019 08:21:10 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.94]) by
 CRSMSX152.amr.corp.intel.com ([169.254.5.30]) with mapi id 14.03.0415.000;
 Thu, 11 Apr 2019 09:21:08 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Jerome Glisse <jglisse@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Andrew
 Morton" <akpm@linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?=
	<christian.koenig@amd.com>, Joonas Lahtinen
	<joonas.lahtinen@linux.intel.com>, Jani Nikula <jani.nikula@linux.intel.com>,
	"Vivi, Rodrigo" <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>, "Andrea
 Arcangeli" <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, "Felix
 Kuehling" <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>, Ross
 Zwisler <zwisler@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>, =?utf-8?B?UmFkaW0gS3JjbcOhcg==?=
	<rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Arnd Bergmann
	<arnd@arndb.de>
Subject: RE: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why
 mmu notifier is happening v2
Thread-Topic: [PATCH v6 7/8] mm/mmu_notifier: pass down vma and reasons why
 mmu notifier is happening v2
Thread-Index: AQHU4/PFtHRclNkri06P8CLyl5padqY2FSUAgAFwOYD//6KRwA==
Date: Thu, 11 Apr 2019 15:21:08 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79CAEBED@CRSMSX101.amr.corp.intel.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190326164747.24405-8-jglisse@redhat.com>
 <20190410234124.GE22989@iweiny-DESK2.sc.intel.com>
 <20190411143918.GA4266@redhat.com>
In-Reply-To: <20190411143918.GA4266@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZTIzYTJjZWEtN2Y0Ny00ODRjLWI0NzMtN2NlZWUzYTMwMTkwIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiMlZwYlpvSEpNQUFhMktBbHZjV2hEcFFMUXEzNXF6K1RWUGRpeHRqNDZ3WUl3V2ZxM3lKSUp3YlZtZjI0eVBDYiJ9
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

PiBPbiBXZWQsIEFwciAxMCwgMjAxOSBhdCAwNDo0MTo1N1BNIC0wNzAwLCBJcmEgV2Vpbnkgd3Jv
dGU6DQo+ID4gT24gVHVlLCBNYXIgMjYsIDIwMTkgYXQgMTI6NDc6NDZQTSAtMDQwMCwgSmVyb21l
IEdsaXNzZSB3cm90ZToNCj4gPiA+IEZyb206IErDqXLDtG1lIEdsaXNzZSA8amdsaXNzZUByZWRo
YXQuY29tPg0KPiA+ID4NCj4gPiA+IENQVSBwYWdlIHRhYmxlIHVwZGF0ZSBjYW4gaGFwcGVucyBm
b3IgbWFueSByZWFzb25zLCBub3Qgb25seSBhcyBhDQo+ID4gPiByZXN1bHQgb2YgYSBzeXNjYWxs
IChtdW5tYXAoKSwgbXByb3RlY3QoKSwgbXJlbWFwKCksIG1hZHZpc2UoKSwgLi4uKQ0KPiA+ID4g
YnV0IGFsc28gYXMgYSByZXN1bHQgb2Yga2VybmVsIGFjdGl2aXRpZXMgKG1lbW9yeSBjb21wcmVz
c2lvbiwNCj4gPiA+IHJlY2xhaW0sIG1pZ3JhdGlvbiwgLi4uKS4NCj4gPiA+DQo+ID4gPiBVc2Vy
cyBvZiBtbXUgbm90aWZpZXIgQVBJIHRyYWNrIGNoYW5nZXMgdG8gdGhlIENQVSBwYWdlIHRhYmxl
IGFuZA0KPiA+ID4gdGFrZSBzcGVjaWZpYyBhY3Rpb24gZm9yIHRoZW0uIFdoaWxlIGN1cnJlbnQg
QVBJIG9ubHkgcHJvdmlkZSByYW5nZQ0KPiA+ID4gb2YgdmlydHVhbCBhZGRyZXNzIGFmZmVjdGVk
IGJ5IHRoZSBjaGFuZ2UsIG5vdCB3aHkgdGhlIGNoYW5nZXMgaXMNCj4gPiA+IGhhcHBlbmluZw0K
PiA+ID4NCj4gPiA+IFRoaXMgcGF0Y2ggaXMganVzdCBwYXNzaW5nIGRvd24gdGhlIG5ldyBpbmZv
cm1hdGlvbnMgYnkgYWRkaW5nIGl0IHRvDQo+ID4gPiB0aGUgbW11X25vdGlmaWVyX3JhbmdlIHN0
cnVjdHVyZS4NCj4gPiA+DQo+ID4gPiBDaGFuZ2VzIHNpbmNlIHYxOg0KPiA+ID4gICAgIC0gSW5p
dGlhbGl6ZSBmbGFncyBmaWVsZCBmcm9tIG1tdV9ub3RpZmllcl9yYW5nZV9pbml0KCkNCj4gPiA+
IGFyZ3VtZW50cw0KPiA+ID4NCj4gPiA+IFNpZ25lZC1vZmYtYnk6IErDqXLDtG1lIEdsaXNzZSA8
amdsaXNzZUByZWRoYXQuY29tPg0KPiA+ID4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgt
Zm91bmRhdGlvbi5vcmc+DQo+ID4gPiBDYzogbGludXgtbW1Aa3ZhY2sub3JnDQo+ID4gPiBDYzog
Q2hyaXN0aWFuIEvDtm5pZyA8Y2hyaXN0aWFuLmtvZW5pZ0BhbWQuY29tPg0KPiA+ID4gQ2M6IEpv
b25hcyBMYWh0aW5lbiA8am9vbmFzLmxhaHRpbmVuQGxpbnV4LmludGVsLmNvbT4NCj4gPiA+IENj
OiBKYW5pIE5pa3VsYSA8amFuaS5uaWt1bGFAbGludXguaW50ZWwuY29tPg0KPiA+ID4gQ2M6IFJv
ZHJpZ28gVml2aSA8cm9kcmlnby52aXZpQGludGVsLmNvbT4NCj4gPiA+IENjOiBKYW4gS2FyYSA8
amFja0BzdXNlLmN6Pg0KPiA+ID4gQ2M6IEFuZHJlYSBBcmNhbmdlbGkgPGFhcmNhbmdlQHJlZGhh
dC5jb20+DQo+ID4gPiBDYzogUGV0ZXIgWHUgPHBldGVyeEByZWRoYXQuY29tPg0KPiA+ID4gQ2M6
IEZlbGl4IEt1ZWhsaW5nIDxGZWxpeC5LdWVobGluZ0BhbWQuY29tPg0KPiA+ID4gQ2M6IEphc29u
IEd1bnRob3JwZSA8amdnQG1lbGxhbm94LmNvbT4NCj4gPiA+IENjOiBSb3NzIFp3aXNsZXIgPHp3
aXNsZXJAa2VybmVsLm9yZz4NCj4gPiA+IENjOiBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxpYW1z
QGludGVsLmNvbT4NCj4gPiA+IENjOiBQYW9sbyBCb256aW5pIDxwYm9uemluaUByZWRoYXQuY29t
Pg0KPiA+ID4gQ2M6IFJhZGltIEtyxI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29tPg0KPiA+ID4g
Q2M6IE1pY2hhbCBIb2NrbyA8bWhvY2tvQGtlcm5lbC5vcmc+DQo+ID4gPiBDYzogQ2hyaXN0aWFu
IEtvZW5pZyA8Y2hyaXN0aWFuLmtvZW5pZ0BhbWQuY29tPg0KPiA+ID4gQ2M6IFJhbHBoIENhbXBi
ZWxsIDxyY2FtcGJlbGxAbnZpZGlhLmNvbT4NCj4gPiA+IENjOiBKb2huIEh1YmJhcmQgPGpodWJi
YXJkQG52aWRpYS5jb20+DQo+ID4gPiBDYzoga3ZtQHZnZXIua2VybmVsLm9yZw0KPiA+ID4gQ2M6
IGRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcNCj4gPiA+IENjOiBsaW51eC1yZG1hQHZn
ZXIua2VybmVsLm9yZw0KPiA+ID4gQ2M6IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+DQo+
ID4gPiAtLS0NCj4gPiA+ICBpbmNsdWRlL2xpbnV4L21tdV9ub3RpZmllci5oIHwgNiArKysrKy0N
Cj4gPiA+ICAxIGZpbGUgY2hhbmdlZCwgNSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+
ID4gPg0KPiA+ID4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW11X25vdGlmaWVyLmgNCj4g
PiA+IGIvaW5jbHVkZS9saW51eC9tbXVfbm90aWZpZXIuaCBpbmRleCA2MmY5NGNkODU0NTUuLjAz
Nzk5NTZmZmYyMw0KPiA+ID4gMTAwNjQ0DQo+ID4gPiAtLS0gYS9pbmNsdWRlL2xpbnV4L21tdV9u
b3RpZmllci5oDQo+ID4gPiArKysgYi9pbmNsdWRlL2xpbnV4L21tdV9ub3RpZmllci5oDQo+ID4g
PiBAQCAtNTgsMTAgKzU4LDEyIEBAIHN0cnVjdCBtbXVfbm90aWZpZXJfbW0geyAgI2RlZmluZQ0K
PiA+ID4gTU1VX05PVElGSUVSX1JBTkdFX0JMT0NLQUJMRSAoMSA8PCAwKQ0KPiA+ID4NCj4gPiA+
ICBzdHJ1Y3QgbW11X25vdGlmaWVyX3JhbmdlIHsNCj4gPiA+ICsJc3RydWN0IHZtX2FyZWFfc3Ry
dWN0ICp2bWE7DQo+ID4gPiAgCXN0cnVjdCBtbV9zdHJ1Y3QgKm1tOw0KPiA+ID4gIAl1bnNpZ25l
ZCBsb25nIHN0YXJ0Ow0KPiA+ID4gIAl1bnNpZ25lZCBsb25nIGVuZDsNCj4gPiA+ICAJdW5zaWdu
ZWQgZmxhZ3M7DQo+ID4gPiArCWVudW0gbW11X25vdGlmaWVyX2V2ZW50IGV2ZW50Ow0KPiA+ID4g
IH07DQo+ID4gPg0KPiA+ID4gIHN0cnVjdCBtbXVfbm90aWZpZXJfb3BzIHsNCj4gPiA+IEBAIC0z
NjMsMTAgKzM2NSwxMiBAQCBzdGF0aWMgaW5saW5lIHZvaWQNCj4gbW11X25vdGlmaWVyX3Jhbmdl
X2luaXQgKHN0cnVjdCBtbXVfbm90aWZpZXJfcmFuZ2UgKnJhbmdlLA0KPiA+ID4gIAkJCQkJICAg
dW5zaWduZWQgbG9uZyBzdGFydCwNCj4gPiA+ICAJCQkJCSAgIHVuc2lnbmVkIGxvbmcgZW5kKQ0K
PiA+ID4gIHsNCj4gPiA+ICsJcmFuZ2UtPnZtYSA9IHZtYTsNCj4gPiA+ICsJcmFuZ2UtPmV2ZW50
ID0gZXZlbnQ7DQo+ID4gPiAgCXJhbmdlLT5tbSA9IG1tOw0KPiA+ID4gIAlyYW5nZS0+c3RhcnQg
PSBzdGFydDsNCj4gPiA+ICAJcmFuZ2UtPmVuZCA9IGVuZDsNCj4gPiA+IC0JcmFuZ2UtPmZsYWdz
ID0gMDsNCj4gPiA+ICsJcmFuZ2UtPmZsYWdzID0gZmxhZ3M7DQo+ID4NCj4gPiBXaGljaCBvZiB0
aGUgInVzZXIgcGF0Y2ggc2V0cyIgdXNlcyB0aGUgbmV3IGZsYWdzPw0KPiA+DQo+ID4gSSdtIG5v
dCBzZWVpbmcgdGhhdCB1c2VyIHlldC4gIEluIGdlbmVyYWwgSSBkb24ndCBzZWUgYW55dGhpbmcg
d3JvbmcNCj4gPiB3aXRoIHRoZSBzZXJpZXMgYW5kIEkgbGlrZSB0aGUgaWRlYSBvZiB0ZWxsaW5n
IGRyaXZlcnMgd2h5IHRoZSBpbnZhbGlkYXRlIGhhcw0KPiBmaXJlZC4NCj4gPg0KPiA+IEJ1dCBp
cyB0aGUgZmxhZ3MgYSBmdXR1cmUgZmVhdHVyZT8NCj4gPg0KPiANCj4gSSBiZWxpZXZlIHRoZSBs
aW5rIHdlcmUgaW4gdGhlIGNvdmVyOg0KPiANCj4gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTkv
MS8yMy84MzMNCj4gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTkvMS8yMy84MzQNCj4gaHR0cHM6
Ly9sa21sLm9yZy9sa21sLzIwMTkvMS8yMy84MzINCj4gaHR0cHM6Ly9sa21sLm9yZy9sa21sLzIw
MTkvMS8yMy84MzENCj4gDQo+IEkgaGF2ZSBtb3JlIGNvbWluZyBmb3IgSE1NIGJ1dCBpIGFtIHdh
aXRpbmcgYWZ0ZXIgNS4yIG9uY2UgYW1kZ3B1IEhNTQ0KPiBwYXRjaCBhcmUgbWVyZ2UgdXBzdHJl
YW0gYXMgaXQgd2lsbCBjaGFuZ2Ugd2hhdCBpcyBwYXNzZWQgZG93biB0byBkcml2ZXINCj4gYW5k
IGl0IHdvdWxkIGNvbmZsaWN0IHdpdGggbm9uIG1lcmdlZCBITU0gZHJpdmVyIChsaWtlIGFtZGdw
dSB0b2RheSkuDQo+IA0KDQpVbmZvcnR1bmF0ZWx5IHRoaXMgZG9lcyBub3QgYW5zd2VyIG15IHF1
ZXN0aW9uLiAgWWVzIEkgc2F3IHRoZSBsaW5rcyB0byB0aGUgcGF0Y2hlcyB3aGljaCB1c2UgdGhp
cyBpbiB0aGUgaGVhZGVyLiAgRnVydGhlcm1vcmUsIEkgY2hlY2tlZCB0aGUgbGlua3MgYWdhaW4s
IEkgc3RpbGwgZG8gbm90IHNlZSBhIHVzZSBvZiByYW5nZS0+ZmxhZ3Mgbm9yIGEgdXNlIG9mIHRo
ZSBuZXcgZmxhZ3MgcGFyYW1ldGVyIHRvIG1tdV9ub3RpZmllcl9yYW5nZV9pbml0KCkuDQoNCkkg
c3RpbGwgZ2F2ZSBhIHJldmlld2VkIGJ5IGJlY2F1c2UgSSdtIG5vdCBzYXlpbmcgaXQgaXMgd3Jv
bmcgSSdtIGp1c3QgdHJ5aW5nIHRvIHVuZGVyc3RhbmQgd2hhdCB1c2UgZHJpdmVycyBoYXZlIG9m
IHRoaXMgZmxhZy4NCg0KU28gYWdhaW4gSSdtIGN1cmlvdXMgd2hhdCBpcyB0aGUgdXNlIGNhc2Ug
b2YgdGhlc2UgZmxhZ3MgYW5kIHRoZSB1c2UgY2FzZSBvZiBleHBvc2luZyBpdCB0byB0aGUgdXNl
cnMgb2YgTU1VIG5vdGlmaWVycz8NCg0KSXJhDQoNCj4gQ2hlZXJzLA0KPiBKw6lyw7RtZQ0K

