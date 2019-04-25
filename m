Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE352C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:22:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A40CB20717
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:22:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A40CB20717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16DF06B0003; Thu, 25 Apr 2019 17:22:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F4EA6B0005; Thu, 25 Apr 2019 17:22:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0A76B0006; Thu, 25 Apr 2019 17:22:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC5E76B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:22:40 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m9so543896pge.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:22:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=miFuSf1BaKbIKntZRJqHCdwf14aNNnW3wTye7+8rXnM=;
        b=bhKXgVwsG5ewJUhXkF/2qjIxk2sLteMVm5ItUtsJyGpTGiVwRPxCNNfOuTggarmcS3
         r4Owk2GO61vQkKGXbi5CBN+rBjM33+os2N+DCcY91BJmdtlnfHrExLvWg+jvgC4AH43j
         yxKiFmUOkXoEjMxeOgiNfsLa1l5Hoy0PTAxKU+DIlIrqLZMLKyBkrZrndrbFzXHcOaDI
         oJJrM6yKbalqK/zDnc+0nLbUJrOjwfnxhJ185qg9EpE8Z2g9xREj9lNqlPm7ENK6fDgi
         2zQUjAea+Mdeg4LVP+o8YTOWxLddtyTjiuCCVq7BdARagdQWRt1E0F+eoWOaCzIjfGny
         1P9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXd5y/nAvfREbXRPpnc/d3zPcozMxzWJP60BfmiMAmnaTXG9g9I
	9sEEuOlDERB3yzsMBVX293kKC8ueRXk9ksF4FE78XJ5cWCLoeTpbRrKHwHNsRUaDO90TFHnD7Dn
	08MJjhZhHBE2jsCGe288s4vRNvD1yA38b0QrZ5CeXP6hDUA6XnbCZkrBaQyEyRdKP9w==
X-Received: by 2002:a63:cc0b:: with SMTP id x11mr38733411pgf.35.1556227360331;
        Thu, 25 Apr 2019 14:22:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRI3UHHhpq6d8/YUM9nQoLr46lSILkCsjzUQMKIQcQdi6WbLKrzn3iRyJveYeyoDfXkp1q
X-Received: by 2002:a63:cc0b:: with SMTP id x11mr38733341pgf.35.1556227359544;
        Thu, 25 Apr 2019 14:22:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556227359; cv=none;
        d=google.com; s=arc-20160816;
        b=Q66zY9l/3DqAxC6AfF+9OaK0JDwvkZZGQR3r6jNGida3sz+rmg32slzrLVjw210V/1
         R8qxiULYZg0WiT0+DsD+b36T2yiM1DGJVtcZSkrweest92W5YQEbmLebqzCS0VJgZReZ
         UDQqwJR6iuX3oPjIvZs2+WFAsYlmUm44lBCdWN8p5z4M4rfhzMIwya/KD9n8+ne9Od6d
         Nk+BAZcixQ3+B8qLdGDhioMJ25GmpGU65zgV/AVP/nUgmSu5ZRMgsIUGUEKO438VPCZH
         pxVzgKYJxPrCYX8ca+0s4XYEHw6alqvExBLpdkpMiFievrCDfu7oVCbbruG86P7/jdHg
         9AHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=miFuSf1BaKbIKntZRJqHCdwf14aNNnW3wTye7+8rXnM=;
        b=DAKkUw6umV8IeJaqWXE3m7aXeaJe2POPZ0JwO8ewx9GGUJNhrkv2U+Gc3jXZAZ+F+N
         LOJpJUJIw0MhnVV+7g73afEoDI2pPTclPe4aXOd+WQbscFdCxb0qJ+sS6VLpeoqWwDxh
         9KP7OaXQMO+Z+P+bmo4hZjm1y/9rCr/ag6zMDi+K9ZDX0QYc72qPnvif3yye0LYEZUSN
         UODphHXjn1uH0+70L4K28ZoEoU8eRnGOHyk0NYfkcMSRSBU06Bc1BdWqeai6a3Z10qMm
         W7JaQn49Pl2FUyhC3ega2PYB+8IbBq7qFvK5ryHOlv34lNdmxv5S1kbks6f8V/6Fh6Pw
         f+Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d15si8957132pgk.246.2019.04.25.14.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:22:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 14:22:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="340827658"
Received: from orsmsx109.amr.corp.intel.com ([10.22.240.7])
  by fmsmga005.fm.intel.com with ESMTP; 25 Apr 2019 14:22:38 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.109]) by
 ORSMSX109.amr.corp.intel.com ([169.254.11.52]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 14:22:37 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "peterz@infradead.org" <peterz@infradead.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com"
	<nadav.amit@gmail.com>, "dave.hansen@linux.intel.com"
	<dave.hansen@linux.intel.com>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v4 16/23] vmalloc: Add flag for free of special
 permsissions
Thread-Topic: [PATCH v4 16/23] vmalloc: Add flag for free of special
 permsissions
Thread-Index: AQHU+T1qDj30K9TIe0uwu0BdDCSPu6ZN0J6AgAAMKQA=
Date: Thu, 25 Apr 2019 21:22:37 +0000
Message-ID: <c6b37ed1b616386acfab4d4a8cbe972d9346a5fe.camel@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
	 <20190422185805.1169-17-rick.p.edgecombe@intel.com>
	 <20190425203845.GA12232@hirez.programming.kicks-ass.net>
In-Reply-To: <20190425203845.GA12232@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <0E199F7050ED404B9991A495937A8F97@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA0LTI1IGF0IDIyOjM4ICswMjAwLCBQZXRlciBaaWpsc3RyYSB3cm90ZToN
Cj4gT24gTW9uLCBBcHIgMjIsIDIwMTkgYXQgMTE6NTc6NThBTSAtMDcwMCwgUmljayBFZGdlY29t
YmUgd3JvdGU6DQo+ID4gQWRkIGEgbmV3IGZsYWcgVk1fRkxVU0hfUkVTRVRfUEVSTVMsIGZvciBl
bmFibGluZyB2ZnJlZSBvcGVyYXRpb25zIHRvDQo+ID4gaW1tZWRpYXRlbHkgY2xlYXIgZXhlY3V0
YWJsZSBUTEIgZW50cmllcyBiZWZvcmUgZnJlZWluZyBwYWdlcywgYW5kIGhhbmRsZQ0KPiA+IHJl
c2V0dGluZyBwZXJtaXNzaW9ucyBvbiB0aGUgZGlyZWN0bWFwLiBUaGlzIGZsYWcgaXMgdXNlZnVs
IGZvciBhbnkga2luZA0KPiA+IG9mIG1lbW9yeSB3aXRoIGVsZXZhdGVkIHBlcm1pc3Npb25zLCBv
ciB3aGVyZSB0aGVyZSBjYW4gYmUgcmVsYXRlZA0KPiA+IHBlcm1pc3Npb25zIGNoYW5nZXMgb24g
dGhlIGRpcmVjdG1hcC4gVG9kYXkgdGhpcyBpcyBSTytYIGFuZCBSTyBtZW1vcnkuDQo+ID4gDQo+
ID4gQWx0aG91Z2ggdGhpcyBlbmFibGVzIGRpcmVjdGx5IHZmcmVlaW5nIG5vbi13cml0ZWFibGUg
bWVtb3J5IG5vdywNCj4gPiBub24td3JpdGFibGUgbWVtb3J5IGNhbm5vdCBiZSBmcmVlZCBpbiBh
biBpbnRlcnJ1cHQgYmVjYXVzZSB0aGUgYWxsb2NhdGlvbg0KPiA+IGl0c2VsZiBpcyB1c2VkIGFz
IGEgbm9kZSBvbiBkZWZlcnJlZCBmcmVlIGxpc3QuIFNvIHdoZW4gUk8gbWVtb3J5IG5lZWRzIHRv
DQo+ID4gYmUgZnJlZWQgaW4gYW4gaW50ZXJydXB0IHRoZSBjb2RlIGRvaW5nIHRoZSB2ZnJlZSBu
ZWVkcyB0byBoYXZlIGl0cyBvd24NCj4gPiB3b3JrIHF1ZXVlLCBhcyB3YXMgdGhlIGNhc2UgYmVm
b3JlIHRoZSBkZWZlcnJlZCB2ZnJlZSBsaXN0IHdhcyBhZGRlZCB0bw0KPiA+IHZtYWxsb2MuDQo+
ID4gDQo+ID4gRm9yIGFyY2hpdGVjdHVyZXMgd2l0aCBzZXRfZGlyZWN0X21hcF8gaW1wbGVtZW50
YXRpb25zIHRoaXMgd2hvbGUgb3BlcmF0aW9uDQo+ID4gY2FuIGJlIGRvbmUgd2l0aCBvbmUgVExC
IGZsdXNoIHdoZW4gY2VudHJhbGl6ZWQgbGlrZSB0aGlzLiBGb3Igb3RoZXJzIHdpdGgNCj4gPiBk
aXJlY3RtYXAgcGVybWlzc2lvbnMsIGN1cnJlbnRseSBvbmx5IGFybTY0LCBhIGJhY2t1cCBtZXRo
b2QgdXNpbmcNCj4gPiBzZXRfbWVtb3J5IGZ1bmN0aW9ucyBpcyB1c2VkIHRvIHJlc2V0IHRoZSBk
aXJlY3RtYXAuIFdoZW4gYXJtNjQgYWRkcw0KPiA+IHNldF9kaXJlY3RfbWFwXyBmdW5jdGlvbnMs
IHRoaXMgYmFja3VwIGNhbiBiZSByZW1vdmVkLg0KPiA+IA0KPiA+IFdoZW4gdGhlIFRMQiBpcyBm
bHVzaGVkIHRvIGJvdGggcmVtb3ZlIFRMQiBlbnRyaWVzIGZvciB0aGUgdm1hbGxvYyByYW5nZQ0K
PiA+IG1hcHBpbmcgYW5kIHRoZSBkaXJlY3QgbWFwIHBlcm1pc3Npb25zLCB0aGUgbGF6eSBwdXJn
ZSBvcGVyYXRpb24gY291bGQgYmUNCj4gPiBkb25lIHRvIHRyeSB0byBzYXZlIGEgVExCIGZsdXNo
IGxhdGVyLiBIb3dldmVyIHRvZGF5IHZtX3VubWFwX2FsaWFzZXMNCj4gPiBjb3VsZCBmbHVzaCBh
IFRMQiByYW5nZSB0aGF0IGRvZXMgbm90IGluY2x1ZGUgdGhlIGRpcmVjdG1hcC4gU28gYSBoZWxw
ZXINCj4gPiBpcyBhZGRlZCB3aXRoIGV4dHJhIHBhcmFtZXRlcnMgdGhhdCBjYW4gYWxsb3cgYm90
aCB0aGUgdm1hbGxvYyBhZGRyZXNzIGFuZA0KPiA+IHRoZSBkaXJlY3QgbWFwcGluZyB0byBiZSBm
bHVzaGVkIGR1cmluZyB0aGlzIG9wZXJhdGlvbi4gVGhlIGJlaGF2aW9yIG9mIHRoZQ0KPiA+IG5v
cm1hbCB2bV91bm1hcF9hbGlhc2VzIGZ1bmN0aW9uIGlzIHVuY2hhbmdlZC4NCj4gPiArc3RhdGlj
IGlubGluZSB2b2lkIHNldF92bV9mbHVzaF9yZXNldF9wZXJtcyh2b2lkICphZGRyKQ0KPiA+ICt7
DQo+ID4gKwlzdHJ1Y3Qgdm1fc3RydWN0ICp2bSA9IGZpbmRfdm1fYXJlYShhZGRyKTsNCj4gPiAr
DQo+ID4gKwlpZiAodm0pDQo+ID4gKwkJdm0tPmZsYWdzIHw9IFZNX0ZMVVNIX1JFU0VUX1BFUk1T
Ow0KPiA+ICt9DQo+IA0KPiBTbywgcHJldmlvdXNseSBpbiB0aGUgc2VyaWVzIHdlIGFkZGVkIE5Y
IHRvIG1vZHVsZV9hbGxvYygpIGFuZCBmaXhlZCB1cA0KPiBhbGwgdGhlIHVzYWdlIHNpdGUuIEFu
ZCBub3cgd2UncmUgZ29pbmcgdGhyb3VnaCB0aG9zZSB2ZXJ5IHNhbWUgc2l0ZXMgdG8NCj4gYWRk
IHNldF92bV9mbHVzaF9yZXNldF9wZXJtcygpLg0KPiANCj4gV2h5IGlzbid0IG1vZHVsZV9hbGxv
YygpIGNhbGxpbmcgdGhlIGFib3ZlIGZ1bmN0aW9uIGFuZCBhdm9pZCBzcHJpbmtsaW5nDQo+IGl0
IGFsbCBvdmVyIHRoZSBwbGFjZSBhZ2Fpbj8NCg0KWWVhLCB0aGF0IGNvdWxkIG1ha2UgaXQgbW9y
ZSBhdXRvbWF0aWMsIGJ1dCB0aGVyZSBhcmUgc29tZSBhZHZhbnRhZ2VzIHRvIGhvdyBpdA0KaXMg
Y3VycmVudGx5Lg0KDQpPbmUgaXMgdGhhdCBtb3N0IGFyY2gncyBoYXZlIHRoZWlyIG93biBtb2R1
bGVfYWxsb2MoKSwgYW5kIHNvIGNhbGxpbmcNCnNldF92bV9mbHVzaF9yZXNldF9wZXJtcygpIGlu
IGtlcm5lbC9tb2R1bGUuYyBjYXRjaGVzIGFsbCBhcmNoaXRlY3R1cmVzLg0KT3RoZXJ3aXNlIGl0
IHdvdWxkIGJlIGFkZGVkIGluIGVhY2ggYXJjaCB3aGljaCB3b3VsZCBiZSBtb3JlIHNpdGVzLg0K
DQpUaGUgb3RoZXIgcmVhc29uIGlzIHRoYXQgdGhlIGZsdXNoIGlzbid0IGFjdHVhbGx5IG5lZWRl
ZCB1bnRpbCBhZnRlciB0aGUgbWVtb3J5DQppcyBtYWRlIGV4ZWN1dGFibGUsIHNvIHdlIGRvbid0
IGJvdGhlciBmbHVzaGluZyBpZiB0aGUgYWxsb2NhdGlvbiBuZXZlciBnZXRzIHNldA0KZXhlY3V0
YWJsZS4gV2hlbiB0aGF0IGhhcHBlbnMgaXMgb25seSBrbm93biBieSB0aGUgY2FsbGVycyBvZiBt
b2R1bGVfYWxsb2MoKS4NCg0KVGhhbmtzLA0KDQpSaWNrDQo=

