Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0ED7AC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:48:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B89E12173E
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 21:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B89E12173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6236B000A; Mon, 20 May 2019 17:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6575D6B000C; Mon, 20 May 2019 17:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56CA56B000D; Mon, 20 May 2019 17:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC5F6B000A
	for <linux-mm@kvack.org>; Mon, 20 May 2019 17:48:36 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 61so9899779plr.21
        for <linux-mm@kvack.org>; Mon, 20 May 2019 14:48:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=7q+hySeiKsyBXjBYbhvgtTK0cMExic3Fv81xe5sApjw=;
        b=hVXUEqTYEdtHDyFzh2MY1mda5R43t+lGWuonSrpCSQZkjNtfjkN7EJHcAjUTre+iPD
         lu46PtevcIaKWxBetlrd2LYv//nm5zKh+sBfZvN2PXdL636G3VNxVesJIn4ByzVm9k9W
         MwjVMIayCGntsMxfPGNB6F6fCy8jGeugLSqy6QoSj7aoLrTvBc1wxFxO3nXL127GgYop
         FFbV5B/YX7/XJqlhRzq5tJnOlNzxIFApim0rwozndlr5rfOsCY1SqDn0JOETmb3VHKQ8
         tm3og6JAdzuzAHfnyhh7Si4OcEB+c1UIM5tuGlG5anOcv1HAgcfm/vYP0w/QyiflACb/
         C6rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWQcq8NS22aqdljqUMvYcaOO25TiX7QdS/bWHx2UzH1OtPgt0Ek
	LgQLhVWtqy6Lvt+OAu2vbKOj8+YVkmo/5jUIwJMkZCseQ8HRlNYsI6OrlkJaR0l60XN2tSidCGg
	ZUXI9FEAMDjEI5kFzbF6dCvpN6biJMwrPRPkxU+EGDZaxEGhcB+bpyy/LYTR2+uJnOQ==
X-Received: by 2002:a62:d286:: with SMTP id c128mr83698840pfg.159.1558388915726;
        Mon, 20 May 2019 14:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyL6we0vwQGRA47EvFtmOs010JAzGvJy1MND7KRe/QgQ2iGPfVa54y4nX02ioB3TDqde6wE
X-Received: by 2002:a62:d286:: with SMTP id c128mr83698775pfg.159.1558388914853;
        Mon, 20 May 2019 14:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558388914; cv=none;
        d=google.com; s=arc-20160816;
        b=dll/FpyAmEt44cfm1TNAxbY92+J9B6vWvUC9XIGg6rDhTAvyDT176pap6HPdsGg9/z
         hXFKUMisTX9uyI24DXY9dHpPyq8W8q1zJdf2m3G/iDUk1PN4E675KBpgw+XlBmRX+46F
         ZE7e812JjLnTJsO/dCCOG6KjBj4h3H7F6F/1hIHdjFJxBoPrasN0wiGLhGu4QV0nR76a
         nALsADVI+l0Wj5eFLlpGPYqtYiA8Qx77OEojtZm9Cdm98kz3OJvAF41MhnObY+e9szvm
         bZyzCLb6s5lvM8odkamYXAN6ch9fX0qpxUIZjfPJnKmpr4JUWbiLtbkjPIdUPCpnoGb6
         3odA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=7q+hySeiKsyBXjBYbhvgtTK0cMExic3Fv81xe5sApjw=;
        b=0QXEUAl+1CTYcue+2xbkJVxD2nz3NcSNuRQjJlrw+t5mm2Ug1OUHgF+NLUsX3qqisB
         irEAMmQaktfg1AXolNLiAC/SRMzvwr3zaX3VFtNYJWqzWiPCKGruJg7iQKwFRHM0J6Yn
         TOjXdp+SPvDYhTiuIyffWB2UHGOvv0oar86DykR8Ctzx1cJzKIpRXgtmKnYQUIH/oEvM
         ctZI9is+YwJ5c9TA+eC5aXpdLl5BWCjUQO3yUr+LWkBGonIkFt4gPtLiTLoGZkLvhsKB
         PRPD0iJFF5cUX8tVS19ZvcY9H+/GWlP0LjIxi5acXucmapi+4iJmRu9Xrj0gPmJ5vc1Z
         e51Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 9si16561334pfc.90.2019.05.20.14.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 14:48:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 14:48:34 -0700
X-ExtLoop1: 1
Received: from orsmsx105.amr.corp.intel.com ([10.22.225.132])
  by orsmga004.jf.intel.com with ESMTP; 20 May 2019 14:48:33 -0700
Received: from orsmsx160.amr.corp.intel.com (10.22.226.43) by
 ORSMSX105.amr.corp.intel.com (10.22.225.132) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 20 May 2019 14:48:33 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX160.amr.corp.intel.com ([169.254.13.155]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 14:48:33 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "luto@amacapital.net" <luto@amacapital.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "mroos@linux.ee" <mroos@linux.ee>, "mingo@redhat.com"
	<mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, "luto@kernel.org"
	<luto@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>, "bp@alien8.de" <bp@alien8.de>,
	"davem@davemloft.net" <davem@davemloft.net>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0+9iAgAAGeYA=
Date: Mon, 20 May 2019 21:48:32 +0000
Message-ID: <19b6787ce974b07d0d32d2422d0feef557ab443e.camel@intel.com>
References: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
	 <28F28A46-C57B-483A-A5CB-8BEA06AF15F8@amacapital.net>
In-Reply-To: <28F28A46-C57B-483A-A5CB-8BEA06AF15F8@amacapital.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <C63C28FEAEA7894F9FC996666B7AE9BA@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA1LTIwIGF0IDE0OjI1IC0wNzAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IA0KPiANCj4gPiBPbiBNYXkgMjAsIDIwMTksIGF0IDE6MDcgUE0sIFJpY2sgRWRnZWNvbWJl
IDwNCj4gPiByaWNrLnAuZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gU3dp
dGNoIFZNX0ZMVVNIX1JFU0VUX1BFUk1TIHRvIHVzZSBhIHJlZ3VsYXIgVExCIGZsdXNoIGludGVh
ZCBvZg0KPiA+IHZtX3VubWFwX2FsaWFzZXMoKSBhbmQgZml4IGNhbGN1bGF0aW9uIG9mIHRoZSBk
aXJlY3QgbWFwIGZvciB0aGUNCj4gPiBDT05GSUdfQVJDSF9IQVNfU0VUX0RJUkVDVF9NQVAgY2Fz
ZS4NCj4gPiANCj4gPiBNZWVsaXMgUm9vcyByZXBvcnRlZCBpc3N1ZXMgd2l0aCB0aGUgbmV3IFZN
X0ZMVVNIX1JFU0VUX1BFUk1TIGZsYWcNCj4gPiBvbiBhDQo+ID4gc3BhcmMgbWFjaGluZS4gT24g
aW52ZXN0aWdhdGlvbiBzb21lIGlzc3VlcyB3ZXJlIG5vdGljZWQ6DQo+ID4gDQo+IA0KPiBDYW4g
eW91IHNwbGl0IHRoaXMgaW50byBhIGZldyAoMz8pIHBhdGNoZXMsIGVhY2ggZml4aW5nIG9uZSBp
c3N1ZT8NClN1cmUsIEkganVzdCBkaWQgb25lIGJlY2F1c2UgYmVjYXVzZSBpdCB3YXMgYWxsIGlu
IHRoZSBzYW1lIGZ1bmN0aW9uDQphbmQgdGhlIGFkZHJlc3MgcmFuZ2UgY2FsY3VsYXRpb24gbmVl
ZHMgdG8gYmUgZG9uZSBkaWZmZXJlbnRseSBmb3IgcHVyZQ0KVExCIGZsdXNoLCBzbyBpdHMga2lu
ZCBvZiBpbnRlcnR3aW5lZC4NCg0KPiA+IDEuIFRoZSBjYWxjdWxhdGlvbiBvZiB0aGUgZGlyZWN0
IG1hcCBhZGRyZXNzIHJhbmdlIHRvIGZsdXNoIHdhcw0KPiA+IHdyb25nLg0KPiA+IFRoaXMgY291
bGQgY2F1c2UgcHJvYmxlbXMgb24geDg2IGlmIGEgUk8gZGlyZWN0IG1hcCBhbGlhcyBldmVyIGdv
dA0KPiA+IGxvYWRlZA0KPiA+IGludG8gdGhlIFRMQi4gVGhpcyBzaG91bGRuJ3Qgbm9ybWFsbHkg
aGFwcGVuLCBidXQgaXQgY291bGQgY2F1c2UNCj4gPiB0aGUNCj4gPiBwZXJtaXNzaW9ucyB0byBy
ZW1haW4gUk8gb24gdGhlIGRpcmVjdCBtYXAgYWxpYXMsIGFuZCB0aGVuIHRoZSBwYWdlDQo+ID4g
d291bGQgcmV0dXJuIGZyb20gdGhlIHBhZ2UgYWxsb2NhdG9yIHRvIHNvbWUgb3RoZXIgY29tcG9u
ZW50IGFzIFJPDQo+ID4gYW5kDQo+ID4gY2F1c2UgYSBjcmFzaC4NCj4gPiANCj4gPiAyLiBDYWxs
aW5nIHZtX3VubWFwX2FsaWFzKCkgb24gdmZyZWUgY291bGQgcG90ZW50aWFsbHkgYmUgYSBsb3Qg
b2YNCj4gPiB3b3JrIHRvDQo+ID4gZG8gb24gYSBmcmVlIG9wZXJhdGlvbi4gU2ltcGx5IGZsdXNo
aW5nIHRoZSBUTEIgaW5zdGVhZCBvZiB0aGUNCj4gPiB3aG9sZQ0KPiA+IHZtX3VubWFwX2FsaWFz
KCkgb3BlcmF0aW9uIG1ha2VzIHRoZSBmcmVlcyBmYXN0ZXIgYW5kIHB1c2hlcyB0aGUNCj4gPiBo
ZWF2eQ0KPiA+IHdvcmsgdG8gaGFwcGVuIG9uIGFsbG9jYXRpb24gd2hlcmUgaXQgd291bGQgYmUg
bW9yZSBleHBlY3RlZC4NCj4gPiBJbiBhZGRpdGlvbiB0byB0aGUgZXh0cmEgd29yaywgdm1fdW5t
YXBfYWxpYXMoKSB0YWtlcyBzb21lIGxvY2tzDQo+ID4gaW5jbHVkaW5nDQo+ID4gYSBsb25nIGhv
bGQgb2Ygdm1hcF9wdXJnZV9sb2NrLCB3aGljaCB3aWxsIG1ha2UgYWxsIG90aGVyDQo+ID4gVk1f
RkxVU0hfUkVTRVRfUEVSTVMgdmZyZWVzIHdhaXQgd2hpbGUgdGhlIHB1cmdlIG9wZXJhdGlvbiBo
YXBwZW5zLg0KPiA+IA0KPiA+IDMuIHBhZ2VfYWRkcmVzcygpIGNhbiBoYXZlIGxvY2tpbmcgb24g
c29tZSBjb25maWd1cmF0aW9ucywgc28gc2tpcA0KPiA+IGNhbGxpbmcNCj4gPiB0aGlzIHdoZW4g
cG9zc2libGUgdG8gZnVydGhlciBzcGVlZCB0aGlzIHVwLg0KPiA+IA0KPiA+IEZpeGVzOiA4Njhi
MTA0ZDczNzkgKCJtbS92bWFsbG9jOiBBZGQgZmxhZyBmb3IgZnJlZWluZyBvZiBzcGVjaWFsDQo+
ID4gcGVybXNpc3Npb25zIikNCj4gPiBSZXBvcnRlZC1ieTogTWVlbGlzIFJvb3MgPG1yb29zQGxp
bnV4LmVlPg0KPiA+IENjOiBNZWVsaXMgUm9vcyA8bXJvb3NAbGludXguZWU+DQo+ID4gQ2M6IFBl
dGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4NCj4gPiBDYzogIkRhdmlkIFMuIE1p
bGxlciIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+ID4gQ2M6IERhdmUgSGFuc2VuIDxkYXZlLmhh
bnNlbkBpbnRlbC5jb20+DQo+ID4gQ2M6IEJvcmlzbGF2IFBldGtvdiA8YnBAYWxpZW44LmRlPg0K
PiA+IENjOiBBbmR5IEx1dG9taXJza2kgPGx1dG9Aa2VybmVsLm9yZz4NCj4gPiBDYzogSW5nbyBN
b2xuYXIgPG1pbmdvQHJlZGhhdC5jb20+DQo+ID4gQ2M6IE5hZGF2IEFtaXQgPG5hbWl0QHZtd2Fy
ZS5jb20+DQo+ID4gU2lnbmVkLW9mZi1ieTogUmljayBFZGdlY29tYmUgPHJpY2sucC5lZGdlY29t
YmVAaW50ZWwuY29tPg0KPiA+IC0tLQ0KPiA+IA0KPiA+IENoYW5nZXMgc2luY2UgdjE6DQo+ID4g
LSBVcGRhdGUgY29tbWl0IG1lc3NhZ2Ugd2l0aCBtb3JlIGRldGFpbA0KPiA+IC0gRml4IGZsdXNo
IGVuZCByYW5nZSBvbiAhQ09ORklHX0FSQ0hfSEFTX1NFVF9ESVJFQ1RfTUFQIGNhc2UNCj4gPiAN
Cj4gPiBtbS92bWFsbG9jLmMgfCAyMyArKysrKysrKysrKysrLS0tLS0tLS0tLQ0KPiA+IDEgZmls
ZSBjaGFuZ2VkLCAxMyBpbnNlcnRpb25zKCspLCAxMCBkZWxldGlvbnMoLSkNCj4gPiANCj4gPiBk
aWZmIC0tZ2l0IGEvbW0vdm1hbGxvYy5jIGIvbW0vdm1hbGxvYy5jDQo+ID4gaW5kZXggYzQyODcy
ZWQ4MmFjLi44ZDAzNDI3NjI2ZGMgMTAwNjQ0DQo+ID4gLS0tIGEvbW0vdm1hbGxvYy5jDQo+ID4g
KysrIGIvbW0vdm1hbGxvYy5jDQo+ID4gQEAgLTIxMjIsOSArMjEyMiwxMCBAQCBzdGF0aWMgaW5s
aW5lIHZvaWQgc2V0X2FyZWFfZGlyZWN0X21hcChjb25zdA0KPiA+IHN0cnVjdCB2bV9zdHJ1Y3Qg
KmFyZWEsDQo+ID4gLyogSGFuZGxlIHJlbW92aW5nIGFuZCByZXNldHRpbmcgdm0gbWFwcGluZ3Mg
cmVsYXRlZCB0byB0aGUNCj4gPiB2bV9zdHJ1Y3QuICovDQo+ID4gc3RhdGljIHZvaWQgdm1fcmVt
b3ZlX21hcHBpbmdzKHN0cnVjdCB2bV9zdHJ1Y3QgKmFyZWEsIGludA0KPiA+IGRlYWxsb2NhdGVf
cGFnZXMpDQo+ID4gew0KPiA+ICsgICAgY29uc3QgYm9vbCBoYXNfc2V0X2RpcmVjdCA9DQo+ID4g
SVNfRU5BQkxFRChDT05GSUdfQVJDSF9IQVNfU0VUX0RJUkVDVF9NQVApOw0KPiA+ICsgICAgY29u
c3QgYm9vbCBmbHVzaF9yZXNldCA9IGFyZWEtPmZsYWdzICYgVk1fRkxVU0hfUkVTRVRfUEVSTVM7
DQo+ID4gICAgdW5zaWduZWQgbG9uZyBhZGRyID0gKHVuc2lnbmVkIGxvbmcpYXJlYS0+YWRkcjsN
Cj4gPiAtICAgIHVuc2lnbmVkIGxvbmcgc3RhcnQgPSBVTE9OR19NQVgsIGVuZCA9IDA7DQo+ID4g
LSAgICBpbnQgZmx1c2hfcmVzZXQgPSBhcmVhLT5mbGFncyAmIFZNX0ZMVVNIX1JFU0VUX1BFUk1T
Ow0KPiA+ICsgICAgdW5zaWduZWQgbG9uZyBzdGFydCA9IGFkZHIsIGVuZCA9IGFkZHIgKyBhcmVh
LT5zaXplOw0KPiA+ICAgIGludCBpOw0KPiA+IA0KPiA+ICAgIC8qDQo+ID4gQEAgLTIxMzMsNyAr
MjEzNCw3IEBAIHN0YXRpYyB2b2lkIHZtX3JlbW92ZV9tYXBwaW5ncyhzdHJ1Y3QNCj4gPiB2bV9z
dHJ1Y3QgKmFyZWEsIGludCBkZWFsbG9jYXRlX3BhZ2VzKQ0KPiA+ICAgICAqIFRoaXMgaXMgY29u
Y2VybmVkIHdpdGggcmVzZXR0aW5nIHRoZSBkaXJlY3QgbWFwIGFueSBhbiB2bQ0KPiA+IGFsaWFz
IHdpdGgNCj4gPiAgICAgKiBleGVjdXRlIHBlcm1pc3Npb25zLCB3aXRob3V0IGxlYXZpbmcgYSBS
VytYIHdpbmRvdy4NCj4gPiAgICAgKi8NCj4gPiAtICAgIGlmIChmbHVzaF9yZXNldCAmJg0KPiA+
ICFJU19FTkFCTEVEKENPTkZJR19BUkNIX0hBU19TRVRfRElSRUNUX01BUCkpIHsNCj4gPiArICAg
IGlmIChmbHVzaF9yZXNldCAmJiAhaGFzX3NldF9kaXJlY3QpIHsNCj4gPiAgICAgICAgc2V0X21l
bW9yeV9ueChhZGRyLCBhcmVhLT5ucl9wYWdlcyk7DQo+ID4gICAgICAgIHNldF9tZW1vcnlfcnco
YWRkciwgYXJlYS0+bnJfcGFnZXMpOw0KPiA+ICAgIH0NCj4gPiBAQCAtMjE0NiwyMiArMjE0Nywy
NCBAQCBzdGF0aWMgdm9pZCB2bV9yZW1vdmVfbWFwcGluZ3Moc3RydWN0DQo+ID4gdm1fc3RydWN0
ICphcmVhLCBpbnQgZGVhbGxvY2F0ZV9wYWdlcykNCj4gPiANCj4gPiAgICAvKg0KPiA+ICAgICAq
IElmIG5vdCBkZWFsbG9jYXRpbmcgcGFnZXMsIGp1c3QgZG8gdGhlIGZsdXNoIG9mIHRoZSBWTSBh
cmVhDQo+ID4gYW5kDQo+ID4gLSAgICAgKiByZXR1cm4uDQo+ID4gKyAgICAgKiByZXR1cm4uIElm
IHRoZSBhcmNoIGRvZXNuJ3QgaGF2ZSBzZXRfZGlyZWN0X21hcF8oKSwgYWxzbw0KPiA+IHNraXAg
dGhlDQo+ID4gKyAgICAgKiBiZWxvdyB3b3JrLg0KPiA+ICAgICAqLw0KPiA+IC0gICAgaWYgKCFk
ZWFsbG9jYXRlX3BhZ2VzKSB7DQo+ID4gLSAgICAgICAgdm1fdW5tYXBfYWxpYXNlcygpOw0KPiA+
ICsgICAgaWYgKCFkZWFsbG9jYXRlX3BhZ2VzIHx8ICFoYXNfc2V0X2RpcmVjdCkgew0KPiA+ICsg
ICAgICAgIGZsdXNoX3RsYl9rZXJuZWxfcmFuZ2Uoc3RhcnQsIGVuZCk7DQo+ID4gICAgICAgIHJl
dHVybjsNCj4gPiAgICB9DQo+ID4gDQo+ID4gICAgLyoNCj4gPiAgICAgKiBJZiBleGVjdXRpb24g
Z2V0cyBoZXJlLCBmbHVzaCB0aGUgdm0gbWFwcGluZyBhbmQgcmVzZXQgdGhlDQo+ID4gZGlyZWN0
DQo+ID4gICAgICogbWFwLiBGaW5kIHRoZSBzdGFydCBhbmQgZW5kIHJhbmdlIG9mIHRoZSBkaXJl
Y3QgbWFwcGluZ3MgdG8NCj4gPiBtYWtlIHN1cmUNCj4gPiAtICAgICAqIHRoZSB2bV91bm1hcF9h
bGlhc2VzKCkgZmx1c2ggaW5jbHVkZXMgdGhlIGRpcmVjdCBtYXAuDQo+ID4gKyAgICAgKiB0aGUg
Zmx1c2hfdGxiX2tlcm5lbF9yYW5nZSgpIGluY2x1ZGVzIHRoZSBkaXJlY3QgbWFwLg0KPiA+ICAg
ICAqLw0KPiA+ICAgIGZvciAoaSA9IDA7IGkgPCBhcmVhLT5ucl9wYWdlczsgaSsrKSB7DQo+ID4g
LSAgICAgICAgaWYgKHBhZ2VfYWRkcmVzcyhhcmVhLT5wYWdlc1tpXSkpIHsNCj4gPiArICAgICAg
ICBhZGRyID0gKHVuc2lnbmVkIGxvbmcpcGFnZV9hZGRyZXNzKGFyZWEtPnBhZ2VzW2ldKTsNCj4g
PiArICAgICAgICBpZiAoYWRkcikgew0KPiA+ICAgICAgICAgICAgc3RhcnQgPSBtaW4oYWRkciwg
c3RhcnQpOw0KPiA+IC0gICAgICAgICAgICBlbmQgPSBtYXgoYWRkciwgZW5kKTsNCj4gPiArICAg
ICAgICAgICAgZW5kID0gbWF4KGFkZHIgKyBQQUdFX1NJWkUsIGVuZCk7DQo+ID4gICAgICAgIH0N
Cj4gPiAgICB9DQo+ID4gDQo+ID4gQEAgLTIxNzEsNyArMjE3NCw3IEBAIHN0YXRpYyB2b2lkIHZt
X3JlbW92ZV9tYXBwaW5ncyhzdHJ1Y3QNCj4gPiB2bV9zdHJ1Y3QgKmFyZWEsIGludCBkZWFsbG9j
YXRlX3BhZ2VzKQ0KPiA+ICAgICAqIHJlc2V0IHRoZSBkaXJlY3QgbWFwIHBlcm1pc3Npb25zIHRv
IHRoZSBkZWZhdWx0Lg0KPiA+ICAgICAqLw0KPiA+ICAgIHNldF9hcmVhX2RpcmVjdF9tYXAoYXJl
YSwgc2V0X2RpcmVjdF9tYXBfaW52YWxpZF9ub2ZsdXNoKTsNCj4gPiAtICAgIF92bV91bm1hcF9h
bGlhc2VzKHN0YXJ0LCBlbmQsIDEpOw0KPiA+ICsgICAgZmx1c2hfdGxiX2tlcm5lbF9yYW5nZShz
dGFydCwgZW5kKTsNCj4gPiAgICBzZXRfYXJlYV9kaXJlY3RfbWFwKGFyZWEsIHNldF9kaXJlY3Rf
bWFwX2RlZmF1bHRfbm9mbHVzaCk7DQo+ID4gfQ0KPiA+IA0KPiA+IC0tIA0KPiA+IDIuMjAuMQ0K
PiA+IA0K

