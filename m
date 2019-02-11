Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CFCCC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:04:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11D0F2082F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 23:04:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11D0F2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DED48E018C; Mon, 11 Feb 2019 18:04:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9689B8E0189; Mon, 11 Feb 2019 18:04:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 830DD8E018C; Mon, 11 Feb 2019 18:04:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4128E0189
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:04:53 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 59so502476plc.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:04:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=ZqUc4F5LXcMG1rENzk0pkIqmfylAPGGjcwpCzdj4sZw=;
        b=fnrdt1zgo6Zk6K9QncCbNroEF0pXJPwwMJ+D5HVTIymG7hxIkicZ4EB2Dl8Bm7FyPe
         akdvjpDP43TLRVTumnBb8HxCgQd6vNcWQTL/JB8gGcg/kol3yaNT6ZDDuJ36v7L3aaNA
         DYfcf2Xt8Nv5sQ8xn7IyTLsCA4cIUFW2rKpLYhcZakZmENg+NL9CChHOPKBy3f+IvbFc
         S+XDn3695/78E4shl6axCowRCtCOqzrNPn7d8w3EDm7DZlnFE9FE9ZkoBcVEdipvrbKU
         CsJW1J/dalVd0K9sUFR0w4p34HuxUv192jPhLGr9Z70LjJYhN8ZSFcG8AgyjZcPIfDO0
         bkCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ0OTsb70Zmb38Ot8jolV5LsxJVj7OLJl3qDNUk00uWwI/Sp9QX
	bdoP+elTq+ml4z/chlTjEZnvL5yhiRsIAc5EH/jxatJcuSkKLcgc1dRvFxlNIH28Msd/P1trgX1
	7yxOF4e/4o9S76Fk+imsAzhTTI/SjpZ0PTH+dw2BzDqrMdpSINg9OyoslOwZlAG4rrw==
X-Received: by 2002:a17:902:f091:: with SMTP id go17mr709945plb.235.1549926292874;
        Mon, 11 Feb 2019 15:04:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzHFOCY5A5hkA6f1P8afKSwKxQpJpjq7e1OlMCcu44Fvab9I+lxPZqtmJOKOwRgECqbijk
X-Received: by 2002:a17:902:f091:: with SMTP id go17mr709895plb.235.1549926292065;
        Mon, 11 Feb 2019 15:04:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549926292; cv=none;
        d=google.com; s=arc-20160816;
        b=DWQTAL+7nJxXvRF8dZzvZTb4ADhq8nk5faK7/5vojcGwdl1YwRroC0Sk+bS9Yhr4Ku
         fOzDMfI5KEjGyXVjQKp73Bv/mRfaVUMfjpwp9FNCCDZCrRnoKuUpFroUh882EWacvIXv
         SgllNSbU4V6D6H5KhsjFfrRIFHrnyZVwb4IgqAmgQJbbXejKxzOgJpp/LDWrWEj2/KRR
         oEr0AZCCs2mB9LIRlOCY62KCrkxfNI8b65A+xhQHr5gkpfYgR3t9JaIYrgiSA+N3UmKn
         5jLVm10Nbr6EOmrlrRPEFYcW7rXhdYJGTetMtA6Y3w66IschQzM/IB2ze9ZSIT0mQVkG
         airw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=ZqUc4F5LXcMG1rENzk0pkIqmfylAPGGjcwpCzdj4sZw=;
        b=gw+DUYLs2pdVHUlexL4UPujA2GrnPR3kRo9Ib9Ryqt9kaChBikuSmHuYL1Ny4V2pO/
         6wTnN6sBV53qyJJ3VLNMg6tdRbNtDhs0xCjUemmXW+q5cpobpmm8TXbh3SXFVUH67Vhc
         DihQ70ZCbx0KJzosTAdEQhQdxUD0C1TY2jt+Yhz3r8kOTT1jD9PsSWjQZBhxsRYp2VmV
         K2IMH0iJ4Ce2bqazXM/nY7oU1IVWB3oLTwGJqP9DYbk6dtVkA1IOs63UBms4cmeD1T+p
         r4Pon/D0ihaO6QgBwrIWr4NuXoPjhTk3ZMc9rwklw6awQ7lPawZ5/nRtG6zSDjyj4S6n
         pRhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j35si2732828pgl.223.2019.02.11.15.04.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 15:04:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 15:04:51 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="132811013"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Feb 2019 15:04:51 -0800
Received: from fmsmsx120.amr.corp.intel.com (10.18.124.208) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 15:04:51 -0800
Received: from crsmsx102.amr.corp.intel.com (172.18.63.137) by
 fmsmsx120.amr.corp.intel.com (10.18.124.208) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 11 Feb 2019 15:04:51 -0800
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.57]) by
 CRSMSX102.amr.corp.intel.com ([169.254.2.54]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 17:04:48 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>, Jason Gunthorpe
	<jgg@ziepe.ca>
CC: John Hubbard <jhubbard@nvidia.com>, linux-rdma
	<linux-rdma@vger.kernel.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Daniel
 Borkmann" <daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>, Netdev
	<netdev@vger.kernel.org>, "Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Thread-Topic: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Thread-Index: AQHUwkbKPZQIC0o+Ik+rfr1Js7w1daXbc70AgAAJrwD//32BAIAAiY8A//99pACAAIoeAIAADXcA//+bucA=
Date: Mon, 11 Feb 2019 23:04:48 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79BCF467@CRSMSX101.amr.corp.intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com> <20190211203916.GA2771@ziepe.ca>
 <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com>
 <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
 <20190211215238.GA23825@iweiny-DESK2.sc.intel.com>
 <20190211220658.GH24692@ziepe.ca>
 <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
In-Reply-To: <CAPcyv4htDHmH7PVm_=HOWwRKtpcKTPSjrHPLqhwp2vhBUWL4-w@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiOTY0ZWIwYzgtYjAyMy00Mzk5LWI1YTItNjA5MzNjMWExZjQ2IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiMGtueitJaVdKa0RGRUlHVUpneWIrTDdEajUxbmFwUnRjR2ViK205WVMxQ3pYT05XRTMrUXI3c21KbnhlNWxaVyJ9
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.400.15
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

PiANCj4gT24gTW9uLCBGZWIgMTEsIDIwMTkgYXQgMjowNyBQTSBKYXNvbiBHdW50aG9ycGUgPGpn
Z0B6aWVwZS5jYT4gd3JvdGU6DQo+ID4NCj4gPiBPbiBNb24sIEZlYiAxMSwgMjAxOSBhdCAwMTo1
MjozOFBNIC0wODAwLCBJcmEgV2Vpbnkgd3JvdGU6DQo+ID4gPiBPbiBNb24sIEZlYiAxMSwgMjAx
OSBhdCAwMTozOToxMlBNIC0wODAwLCBKb2huIEh1YmJhcmQgd3JvdGU6DQo+ID4gPiA+IE9uIDIv
MTEvMTkgMToyNiBQTSwgSXJhIFdlaW55IHdyb3RlOg0KPiA+ID4gPiA+IE9uIE1vbiwgRmViIDEx
LCAyMDE5IGF0IDAxOjEzOjU2UE0gLTA4MDAsIEpvaG4gSHViYmFyZCB3cm90ZToNCj4gPiA+ID4g
Pj4gT24gMi8xMS8xOSAxMjozOSBQTSwgSmFzb24gR3VudGhvcnBlIHdyb3RlOg0KPiA+ID4gPiA+
Pj4gT24gTW9uLCBGZWIgMTEsIDIwMTkgYXQgMTI6MTY6NDJQTSAtMDgwMCwgaXJhLndlaW55QGlu
dGVsLmNvbQ0KPiB3cm90ZToNCj4gPiA+ID4gPj4+PiBGcm9tOiBJcmEgV2VpbnkgPGlyYS53ZWlu
eUBpbnRlbC5jb20+DQo+ID4gPiA+ID4+IFsuLi5dDQo+ID4gPiA+ID4+IEl0IHNlZW1zIHRvIG1l
IHRoYXQgdGhlIGxvbmd0ZXJtIHZzLiBzaG9ydC10ZXJtIGlzIG9mIHF1ZXN0aW9uYWJsZQ0KPiB2
YWx1ZS4NCj4gPiA+ID4gPg0KPiA+ID4gPiA+IFRoaXMgaXMgZXhhY3RseSB3aHkgSSBkaWQgbm90
IHBvc3QgdGhpcyBiZWZvcmUuICBJJ3ZlIGJlZW4NCj4gPiA+ID4gPiB3YWl0aW5nIG91ciBvdGhl
ciBkaXNjdXNzaW9ucyBvbiBob3cgR1VQIHBpbnMgYXJlIGdvaW5nIHRvIGJlDQo+ID4gPiA+ID4g
aGFuZGxlZCB0byBwbGF5IG91dC4gIEJ1dCB3aXRoIHRoZSBuZXRkZXYgdGhyZWFkIHRvZGF5WzFd
IGl0DQo+ID4gPiA+ID4gc2VlbXMgbGlrZSB3ZSBuZWVkIHRvIG1ha2Ugc3VyZSB3ZSBoYXZlIGEg
InNhZmUiIGZhc3QgdmFyaWFudA0KPiA+ID4gPiA+IGZvciBhIHdoaWxlLiAgSW50cm9kdWNpbmcg
Rk9MTF9MT05HVEVSTSBzZWVtZWQgbGlrZSB0aGUgY2xlYW5lc3QNCj4gPiA+ID4gPiB3YXkgdG8g
ZG8gdGhhdCBldmVuIGlmIHdlIHdpbGwgbm90IG5lZWQgdGhlIGRpc3RpbmN0aW9uIGluIHRoZQ0K
PiA+ID4gPiA+IGZ1dHVyZS4uLiAgOi0oDQo+ID4gPiA+DQo+ID4gPiA+IFllcywgSSBhZ3JlZS4g
QmVsb3cuLi4NCj4gPiA+ID4NCj4gPiA+ID4gPiBbLi4uXQ0KPiA+ID4gPiA+IFRoaXMgaXMgYWxz
byB3aHkgSSBkaWQgbm90IGNoYW5nZSB0aGUgZ2V0X3VzZXJfcGFnZXNfbG9uZ3Rlcm0NCj4gPiA+
ID4gPiBiZWNhdXNlIHdlIGNvdWxkIGJlIHJpcHBpbmcgdGhpcyBhbGwgb3V0IGJ5IHRoZSBlbmQg
b2YgdGhlDQo+ID4gPiA+ID4geWVhci4uLiAgKEkgaG9wZS4gOi0pDQo+ID4gPiA+ID4NCj4gPiA+
ID4gPiBTbyB3aGlsZSB0aGlzIGRvZXMgInBvbGx1dGUiIHRoZSBHVVAgZmFtaWx5IG9mIGNhbGxz
IEknbSBob3BpbmcNCj4gPiA+ID4gPiBpdCBpcyBub3QgZm9yZXZlci4NCj4gPiA+ID4gPg0KPiA+
ID4gPiA+IElyYQ0KPiA+ID4gPiA+DQo+ID4gPiA+ID4gWzFdIGh0dHBzOi8vbGttbC5vcmcvbGtt
bC8yMDE5LzIvMTEvMTc4OQ0KPiA+ID4gPiA+DQo+ID4gPiA+DQo+ID4gPiA+IFllcywgYW5kIHRv
IGJlIGNsZWFyLCBJIHRoaW5rIHlvdXIgcGF0Y2hzZXQgaGVyZSBpcyBmaW5lLiBJdCBpcw0KPiA+
ID4gPiBlYXN5IHRvIGZpbmQgdGhlIEZPTExfTE9OR1RFUk0gY2FsbGVycyBpZiBhbmQgd2hlbiB3
ZSB3YW50IHRvDQo+ID4gPiA+IGNoYW5nZSBhbnl0aGluZy4gSSBqdXN0IHRoaW5rIGFsc28gaXQn
cyBhcHBvcHJpYXRlIHRvIGdvIGEgYml0IGZ1cnRoZXIsIGFuZA0KPiB1c2UgRk9MTF9MT05HVEVS
TSBhbGwgYnkgaXRzZWxmLg0KPiA+ID4gPg0KPiA+ID4gPiBUaGF0J3MgYmVjYXVzZSBpbiBlaXRo
ZXIgZGVzaWduIG91dGNvbWUsIGl0J3MgYmV0dGVyIHRoYXQgd2F5Og0KPiA+ID4gPg0KPiA+ID4g
PiBpcyBqdXN0IHJpZ2h0LiBUaGUgZ3VwIEFQSSBhbHJlYWR5IGhhcyBfZmFzdCBhbmQgbm9uLWZh
c3QNCj4gPiA+ID4gdmFyaWFudHMsIGFuZCBvbmNlIHlvdSBnZXQgcGFzdCBhIGNvdXBsZSwgeW91
IGVuZCB1cCB3aXRoIGENCj4gPiA+ID4gbXVsdGlwbGljYXRpb24gb2YgbmFtZXMgdGhhdCByZWFs
bHkgd29yayBiZXR0ZXIgYXMgZmxhZ3MuIFdlJ3JlIHRoZXJlLg0KPiA+ID4gPg0KPiA+ID4gPiB0
aGUgX2xvbmd0ZXJtIEFQSSB2YXJpYW50cy4NCj4gPiA+DQo+ID4gPiBGYWlyIGVub3VnaC4gICBC
dXQgdG8gZG8gdGhhdCBjb3JyZWN0bHkgSSB0aGluayB3ZSB3aWxsIG5lZWQgdG8gY29udmVydA0K
PiA+ID4gZ2V0X3VzZXJfcGFnZXNfZmFzdCgpIHRvIHVzZSBmbGFncyBhcyB3ZWxsLiAgSSBoYXZl
IGEgdmVyc2lvbiBvZg0KPiA+ID4gdGhpcyBzZXJpZXMgd2hpY2ggaW5jbHVkZXMgYSBwYXRjaCBk
b2VzIHRoaXMsIGJ1dCB0aGUgcGF0Y2ggdG91Y2hlZA0KPiA+ID4gYSBsb3Qgb2Ygc3Vic3lzdGVt
cyBhbmQgYSBjb3VwbGUgb2YgZGlmZmVyZW50IGFyY2hpdGVjdHVyZXMuLi5bMV0NCj4gPg0KPiA+
IEkgdGhpbmsgdGhpcyBzaG91bGQgYmUgZG9uZSBhbnlob3csIGl0IGlzIHRyb3VibGUgdGhlIHR3
byBiYXNpY2FsbHkNCj4gPiBpZGVudGljYWwgaW50ZXJmYWNlcyBoYXZlIGRpZmZlcmVudCBzaWdu
YXR1cmVzLiBUaGlzIGFscmVhZHkgY2F1c2VkIGENCj4gPiBidWcgaW4gdmZpby4uDQo+ID4NCj4g
PiBJIGFsc28gd29uZGVyIGlmIHNvbWVvbmUgc2hvdWxkIHRoaW5rIGFib3V0IG1ha2luZyBmYXN0
IGludG8gYSBmbGFnDQo+ID4gdG9vLi4NCj4gPg0KPiA+IEJ1dCBJJ20gbm90IHN1cmUgd2hlbiBm
YXN0IHNob3VsZCBiZSB1c2VkIHZzIHdoZW4gaXQgc2hvdWxkbid0IDooDQo+IA0KPiBFZmZlY3Rp
dmVseSBmYXN0IHNob3VsZCBhbHdheXMgYmUgdXNlZCBqdXN0IGluIGNhc2UgdGhlIHVzZXIgY2Fy
ZXMgYWJvdXQNCj4gcGVyZm9ybWFuY2UuIEl0J3MganVzdCB0aGF0IGl0IG1heSBmYWlsIGFuZCBu
ZWVkIHRvIGZhbGwgYmFjayB0byByZXF1aXJpbmcgdGhlDQo+IHZtYS4NCj4gDQo+IFBlcnNvbmFs
bHkgSSB0aG91Z2h0IFJETUEgbWVtb3J5IHJlZ2lzdHJhdGlvbiBpcyBhIG9uZS10aW1lIC8gdXBm
cm9udCBzbG93DQo+IHBhdGggc28gdGhhdCBub24tZmFzdC1HVVAgaXMgdG9sZXJhYmxlLg0KPiAN
Cj4gVGhlIHdvcmtsb2FkcyB0aGF0ICpuZWVkKiBpdCBhcmUgT19ESVJFQ1QgdXNlcnMgdGhhdCBj
YW4ndCB0b2xlcmF0ZSBhIHZtYQ0KPiBsb29rdXAgb24gZXZlcnkgSS9PLg0KDQpUaGVyZSBhcmUg
c29tZSB1c2VycyB3aG8gbmVlZCB0byBbdW5dcmVnaXN0ZXIgbWVtb3J5IG1vcmUgb2Z0ZW4uICBX
aGlsZSBub3QgaW4gdGhlIHN0cmljdCBmYXN0IHBhdGggdGhlc2UgdXNlcnMgd291bGQgbGlrZSB0
aGUgcmVnaXN0cmF0aW9ucyB0byBvY2N1ciBhcyBmYXN0IGFzIHBvc3NpYmxlLiAgSSBkb24ndCBw
ZXJzb25hbGx5IGhhdmUgdGhlIHJlc3VsdHMgYnV0IG91ciBPUEEgdGVhbSBkaWQgZG8gcGVyZm9y
bWFuY2UgdGVzdHMgb24gdGhlIEdVUCB2cyBHVVAgZmFzdCBhbmQgZm9yIHRoZSBoZmkxIGNhc2Ug
ZmFzdCB3YXMgYmV0dGVyLiAgSSBkb24ndCBoYXZlIGFueSByZWFzb24gdG8gYmVsaWV2ZSB0aGF0
IHJlZ3VsYXIgUkRNQSB1c2VycyB3b3VsZCBub3QgYWxzbyBiZW5lZml0Lg0KDQpJcmENCg0K

