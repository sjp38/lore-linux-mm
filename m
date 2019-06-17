Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB8BEC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:13:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 803C32084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:13:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 803C32084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C69D8E0004; Mon, 17 Jun 2019 07:13:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 19E618E0001; Mon, 17 Jun 2019 07:13:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03E128E0004; Mon, 17 Jun 2019 07:13:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD4458E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:13:19 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b10so7518588pgb.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:13:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=euFiWztLyFeKayuqPlGOh5EsrF+vDziyG6Xxahr4W8Y=;
        b=B7/AdgzWtvgj//i8gRxCE2ZQIsrY4rYMB/EfksGfdCpOGTBnGcIT06L3jHTjFy+q2t
         2/vTPSyb6pgjsyxHEUKmNqrKG5n2Ym5jIGP73BjGNyqpi+r/0T6ebxeIKNAAFk9/XQX2
         lD3VT2SCCztra3/42/dqwfAUqJeRWhaJHdKYztxbycs5hKFqgy7nlQ8nZBEXIwcysxj8
         +WdWBsXo8W33VOn0O0LOUQ5K4j0zljqX4624j18ij4VwlZhJSXCI9i1YyhucWu4R9Rh1
         d/uqDu5dxU+qEUkPase7jeAHJSd9DAGwowbXuWfyinVqKCpn4oVuHSHqgtGUagQ9FefE
         2idw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kai.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUSwQhCozrkExLJ8tFA2boWrPxybv77aLJOd6PVOvT0TxFnceu0
	l90HCQNHkXQhoNYBC5plBlm3FViGeRPKrmdgmxeTPG6hSXaW4cKORm38SoYNblDaPsvXxeVMBtA
	wpRRHZhfZmPw3FhTW2WyW25k/oRvF/lDLMIdtMnR1XpoM2PiE1IngHnL3v2yXyYBBIg==
X-Received: by 2002:a62:ee17:: with SMTP id e23mr116195960pfi.130.1560769999420;
        Mon, 17 Jun 2019 04:13:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzER7V6WvZceWYxhg4hU/RPfgv3cGwwyYm4mgj2XS8QGaKmR3VsPQNy+lC61de9vkMnwxc3
X-Received: by 2002:a62:ee17:: with SMTP id e23mr116195918pfi.130.1560769998765;
        Mon, 17 Jun 2019 04:13:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560769998; cv=none;
        d=google.com; s=arc-20160816;
        b=LFgBTpnNj9RLBxp1etAjGDXErBFBIUnUh2F1jH71+dkubU1gvED2xaqvLyYH2Y4BFr
         rxmRNDchG5UgnWCS7GWIygw2aGxpK931fw0KsYzAWfIQTKnHyUOsTcDpk8VYgb3xUyyr
         o7koyhvY1DyNyMDyUXilB7o2o4Yv82yX+gcOhOOXlLUQlqK8EgbVaZgCipeVFFNelVPT
         1Pha7l+HjqPCaYSEDCggBNh8WhkAJuQ3xH0okpopesw3aIpYSzDeWh/MH6sH8sa+x+w+
         VhfMXV6g0WRgAZuKgDEMrinUuN3dyanOEyb2dvyKazviNXtPl2NU294xgz66EKAmqKZ2
         ZL4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=euFiWztLyFeKayuqPlGOh5EsrF+vDziyG6Xxahr4W8Y=;
        b=ScdiFM4daYGFOHR61xnp8RxNhqyk87C95TZNVfbU0lE3jvvfk/4aZaLCkUC8lI5LXL
         tvY2S9nSzvRSBO5MPJKLsmgpbdG8CptknWItGwj0kBDK4cy7mcxQZYeygALjeUNZsZgX
         JiKaxk1Jr4ufvTfiQlWzL1ZqjrZ2hClX4PXVrL3cjNYI05gxYsWiK6pCosGkXNufIu3A
         5CdR5WUpbfB8n1pElCe+dRCqG3RDmchUFDPwMlWNH72HWprh661Vwz+c5KF5cdew9KdO
         TjPCc2/X+SmPasaWzKk01fkbkvRMYDTmBCpw0D7c1XsP4ieW/oY2DHzekrtzYrPE8h9e
         sEpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kai.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id k2si9271644pjp.106.2019.06.17.04.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 04:13:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of kai.huang@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kai.huang@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kai.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 04:13:18 -0700
X-ExtLoop1: 1
Received: from pgsmsx101.gar.corp.intel.com ([10.221.44.78])
  by orsmga003.jf.intel.com with ESMTP; 17 Jun 2019 04:13:13 -0700
Received: from pgsmsx109.gar.corp.intel.com (10.221.44.109) by
 PGSMSX101.gar.corp.intel.com (10.221.44.78) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Mon, 17 Jun 2019 19:13:12 +0800
Received: from pgsmsx112.gar.corp.intel.com ([169.254.3.172]) by
 PGSMSX109.gar.corp.intel.com ([169.254.14.14]) with mapi id 14.03.0439.000;
 Mon, 17 Jun 2019 19:13:12 +0800
From: "Huang, Kai" <kai.huang@intel.com>
To: "kirill@shutemov.name" <kirill@shutemov.name>, "peterz@infradead.org"
	<peterz@infradead.org>
CC: "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"keyrings@vger.kernel.org" <keyrings@vger.kernel.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "dhowells@redhat.com" <dhowells@redhat.com>,
	"jacob.jun.pan@linux.intel.com" <jacob.jun.pan@linux.intel.com>,
	"x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>,
	"Hansen, Dave" <dave.hansen@intel.com>, "luto@amacapital.net"
	<luto@amacapital.net>, "Schofield, Alison" <alison.schofield@intel.com>
Subject: Re: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
Thread-Topic: [PATCH, RFC 20/62] mm/page_ext: Export lookup_page_ext() symbol
Thread-Index: AQHVBa0N2X60Ah6/l0yBtZ+vNYh62KaassmAgADBRICAA9k1AIAAGVkAgAADNwA=
Date: Mon, 17 Jun 2019 11:13:11 +0000
Message-ID: <1560769988.5187.20.camel@intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-21-kirill.shutemov@linux.intel.com>
	 <20190614111259.GA3436@hirez.programming.kicks-ass.net>
	 <20190614224443.qmqolaigu5wnf75p@box>
	 <20190617093054.GB3419@hirez.programming.kicks-ass.net>
	 <1560769298.5187.16.camel@linux.intel.com>
In-Reply-To: <1560769298.5187.16.camel@linux.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.255.91.82]
Content-Type: text/plain; charset="utf-8"
Content-ID: <D614CA96D4DFB74A978CBD3CA2D29412@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA2LTE3IGF0IDIzOjAxICsxMjAwLCBLYWkgSHVhbmcgd3JvdGU6DQo+IE9u
IE1vbiwgMjAxOS0wNi0xNyBhdCAxMTozMCArMDIwMCwgUGV0ZXIgWmlqbHN0cmEgd3JvdGU6DQo+
ID4gT24gU2F0LCBKdW4gMTUsIDIwMTkgYXQgMDE6NDQ6NDNBTSArMDMwMCwgS2lyaWxsIEEuIFNo
dXRlbW92IHdyb3RlOg0KPiA+ID4gT24gRnJpLCBKdW4gMTQsIDIwMTkgYXQgMDE6MTI6NTlQTSAr
MDIwMCwgUGV0ZXIgWmlqbHN0cmEgd3JvdGU6DQo+ID4gPiA+IE9uIFdlZCwgTWF5IDA4LCAyMDE5
IGF0IDA1OjQzOjQwUE0gKzAzMDAsIEtpcmlsbCBBLiBTaHV0ZW1vdiB3cm90ZToNCj4gPiA+ID4g
PiBwYWdlX2tleWlkKCkgaXMgaW5saW5lIGZ1bmNhdGlvbiB0aGF0IHVzZXMgbG9va3VwX3BhZ2Vf
ZXh0KCkuIEtWTSBpcw0KPiA+ID4gPiA+IGdvaW5nIHRvIHVzZSBwYWdlX2tleWlkKCkgYW5kIHNp
bmNlIEtWTSBjYW4gYmUgYnVpbHQgYXMgYSBtb2R1bGUNCj4gPiA+ID4gPiBsb29rdXBfcGFnZV9l
eHQoKSBoYXMgdG8gYmUgZXhwb3J0ZWQuDQo+ID4gPiA+IA0KPiA+ID4gPiBJIF9yZWFsbHlfIGhh
dGUgaGF2aW5nIHRvIGV4cG9ydCB3b3JsZCtkb2cgZm9yIEtWTS4gVGhpcyBvbmUgbWlnaHQgbm90
DQo+ID4gPiA+IGJlIGEgcmVhbCBpc3N1ZSwgYnV0IEkgaXRjaCBldmVyeSB0aW1lIEkgc2VlIGFu
IGV4cG9ydCBmb3IgS1ZNIHRoZXNlDQo+ID4gPiA+IGRheXMuDQo+ID4gPiANCj4gPiA+IElzIHRo
ZXJlIGFueSBiZXR0ZXIgd2F5PyBEbyB3ZSBuZWVkIHRvIGludmVudCBFWFBPUlRfU1lNQk9MX0tW
TSgpPyA6UA0KPiA+IA0KPiA+IE9yIGRpc2FsbG93IEtWTSAob3IgcGFydHMgdGhlcmVvZikgZnJv
bSBiZWluZyBhIG1vZHVsZSBhbnltb3JlLg0KPiANCj4gRm9yIHRoaXMgcGFydGljdWxhciBzeW1i
b2wgZXhwb3NlLCBJIGRvbid0IHRoaW5rIGl0cyBmYWlyIHRvIGJsYW1lIEtWTSBzaW5jZSB0aGUg
ZnVuZGFtZW50YWwNCj4gcmVhc29uDQo+IGlzIGJlY2F1c2UgcGFnZV9rZXlpZCgpICh3aGljaCBj
YWxscyBsb29rdXBfcGFnZV9leHQoKSkgYmVpbmcgaW1wbGVtZW50ZWQgYXMgc3RhdGljIGlubGlu
ZQ0KPiBmdW5jdGlvbg0KPiBpbiBoZWFkZXIgZmlsZSwgc28gZXNzZW50aWFsbHkgaGF2aW5nIGFu
eSBvdGhlciBtb2R1bGUgd2hvIGNhbGxzIHBhZ2Vfa2V5aWQoKSB3aWxsIHRyaWdnZXIgdGhpcw0K
PiBwcm9ibGVtIC0tIGluIGZhY3QgSU9NTVUgZHJpdmVyIGNhbGxzIHBhZ2Vfa2V5aWQoKSB0b28g
c28gZXZlbiB3L28gS1ZNIGxvb2t1cF9wYWdlX2V4dCgpIG5lZWRzIHRvDQo+IGJlDQo+IGV4cG9z
ZWQuDQoNCk9vcHMgaXQgc2VlbXMgSW50ZWwgSU9NTVUgZHJpdmVyIGlzIG5vdCBhIG1vZHVsZSBi
dXQgYnVpbGRpbiBzbyB5ZXMgS1ZNIGlzIHRoZSBvbmx5IG1vZHVsZSB3aG8gY2FsbHMNCnBhZ2Vf
a2V5aWQoKSBub3cuIFNvcnJ5IG15IGJhZC4gQnV0IGlmIHRoZXJlJ3MgYW55IG90aGVyIG1vZHVs
ZSBjYWxscyBwYWdlX2tleWlkKCksIHRoaXMgcGF0Y2ggaXMNCnJlcXVpcmVkLg0KDQpUaGFua3Ms
DQotS2FpDQo+IA0KPiBUaGFua3MsDQo+IC1LYWkNCj4g

