Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3FE3C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:20:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C0B2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:20:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C0B2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C1D56B0005; Mon, 20 May 2019 21:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 173476B0006; Mon, 20 May 2019 21:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0897E6B0007; Mon, 20 May 2019 21:20:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C655F6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:20:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 94so10255453plc.19
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=CTKfJRqytx9E1+SSHTi8SkxkmZIs29KDiflWNiDOv6U=;
        b=PIPGRA6RGYYZvzNG95peGrvT4zvNWxmb6fNKD52BfzvsS5Dj1hl0k1JAIT2vi1nEOK
         2iNjZeDoGML/HlTvykDj3+h2Y8aKdZi5qXdSsZrYXpk+VFQCC2f6SCRPsD9K+o1uoI6h
         F4Il6Z/hkfhqUB02PhoxndscihKEYiB66b70sWzZqr4e9bqlZ4vKPSfupZip16bOgOrx
         qZjpguMztcTuQ16REzGWUC/drStkEA/6j+1k78JG+JRSL/wVk8V/KITZ2CMBLvjr3fZS
         548t9DXcPcVxr+TE0mlEmnnVKwDN4xVxM9S9B96WZbe+cfWW9YYUMGsCg5v1WJJeyVGe
         ubdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXukolJXhsxGDdmsNDNEoKgb/9ab5O4E2lt43+TVHS+X6g5Nc4o
	QzbGUAG+0GCrOuy0w1woIeCExwP/x2atgNCADobPV90/TlQ/buOrjAclDtmqnKFbrMp68ppZCFk
	iBrKj0HiyVUuk22p/zP1g+FxKze/ICc3V2ezHHZvPv/W70ZodUwj/E7TDvRrGLwBSsQ==
X-Received: by 2002:a62:6241:: with SMTP id w62mr23138739pfb.226.1558401635477;
        Mon, 20 May 2019 18:20:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4ozslfEih1yzRGHNDvKtH0BbdC5V4TzKC9DflaYM8pn1v8ZgjfiTPltO1oo61EkS4Yl9Q
X-Received: by 2002:a62:6241:: with SMTP id w62mr23138695pfb.226.1558401634859;
        Mon, 20 May 2019 18:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558401634; cv=none;
        d=google.com; s=arc-20160816;
        b=in/TIvOHZm15GMxzaklPWv2gtaTOtOL9BU/HpYYRvdEc9+WHrq9MShGW6dBl2D64t1
         iDGHsriwcXUI1deZ9zMUDbZcZCbN8KhE4cUJL1d4Ew38kOCbNegaNqbo2tRn6G6ACZ/O
         4wrLJwhD0ftrP9/J+J4ll8ZibTvnQXg1mFwW1DXRHXoKKc1J5AJJ81HtOSuTn9cJgyjz
         wLBjF7SnB0IYU7+iQQGbWy4nYYcpyq3fft3o0jD69nqNO8tNRG46Zd+nss4TLEO59kv/
         1D8ToCob5bgVtnooYqk8Ub2jJciDkYh1RWvIFff5XlNFXbB5k/zrhW0JI4pbEfK1vua4
         5W0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=CTKfJRqytx9E1+SSHTi8SkxkmZIs29KDiflWNiDOv6U=;
        b=Gl4e8d4e9X8igoFMV5XaOJOL67dHVYnBWeFUbqiWx2tKWSgbQ5RwXln6UkpK+/hmJB
         ucGTrx1rxm3DKAJRfRdRR86ZttoNvMO3Pp4Mo8wn5efkFzoI0gT5qRID81C/JzGO8LC9
         x/AAYnTDlWUKcfItau1xFSkIDtDbmbYxjPVjHOviRh22MIcn8m43SaHGHvTod15hfj8B
         ub09CoD1x6ldPRkajRXT7KLNdFKAa+GBLPPgt9fovaofYQO8IqJDFpKCcDehcaQG55Os
         ZA4dq/BhelqFZwhqsPvW+k/Iw+E1JdgjDcEiZo26HG3Lwe90HYdvlJaY6v2rgmYQ2h5F
         w3kA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c14si19595598pgh.367.2019.05.20.18.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 18:20:34 -0700
X-ExtLoop1: 1
Received: from orsmsx103.amr.corp.intel.com ([10.22.225.130])
  by orsmga006.jf.intel.com with ESMTP; 20 May 2019 18:20:34 -0700
Received: from orsmsx114.amr.corp.intel.com (10.22.240.10) by
 ORSMSX103.amr.corp.intel.com (10.22.225.130) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 20 May 2019 18:20:34 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX114.amr.corp.intel.com ([169.254.8.116]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 18:20:34 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "davem@davemloft.net" <davem@davemloft.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "mroos@linux.ee" <mroos@linux.ee>, "mingo@redhat.com"
	<mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, "luto@kernel.org"
	<luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwCAAAiygIAAGYEAgAADqwCAAA0vgA==
Date: Tue, 21 May 2019 01:20:33 +0000
Message-ID: <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
References: <c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
	 <20190520.154855.2207738976381931092.davem@davemloft.net>
	 <3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
	 <20190520.203320.621504228022195532.davem@davemloft.net>
In-Reply-To: <20190520.203320.621504228022195532.davem@davemloft.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <D49A9B049E5A1C4885E25064E440A746@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA1LTIwIGF0IDIwOjMzIC0wNDAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0K
PiBEYXRlOiBUdWUsIDIxIE1heSAyMDE5IDAwOjIwOjEzICswMDAwDQo+IA0KPiA+IFRoaXMgYmVo
YXZpb3Igc2hvdWxkbid0IGhhcHBlbiB1bnRpbCBtb2R1bGVzIG9yIEJQRiBhcmUgYmVpbmcNCj4g
PiBmcmVlZC4NCj4gDQo+IFRoZW4gdGhhdCB3b3VsZCBydWxlIG91dCBteSB0aGVvcnkuDQo+IA0K
PiBUaGUgb25seSB0aGluZyBsZWZ0IGlzIHdoZXRoZXIgdGhlIHBlcm1pc3Npb25zIGFyZSBhY3R1
YWxseSBzZXQNCj4gcHJvcGVybHkuICBJZiB0aGV5IGFyZW4ndCB3ZSdsbCB0YWtlIGFuIGV4Y2Vw
dGlvbiB3aGVuIHRoZSBCUEYNCj4gcHJvZ3JhbQ0KPiBpcyBydW4gYW5kIEknbSBub3QgJTEwMCBz
dXJlIHRoYXQga2VybmVsIGV4ZWN1dGUgcGVybWlzc2lvbg0KPiB2aW9sYXRpb25zDQo+IGFyZSB0
b3RhbGx5IGhhbmRsZWQgY2xlYW5seS4NClBlcm1pc3Npb25zIHNob3VsZG4ndCBiZSBhZmZlY3Rl
ZCB3aXRoIHRoaXMgZXhjZXB0IG9uIGZyZWUuIEJ1dCByZWFkaW5nDQp0aGUgY29kZSBpdCBsb29r
ZWQgbGlrZSBzcGFyYyBoYWQgYWxsIFBBR0VfS0VSTkVMIGFzIGV4ZWN1dGFibGUgYW5kIG5vDQpz
ZXRfbWVtb3J5XygpIGltcGxlbWVudGF0aW9ucy4gSXMgdGhlcmUgc29tZSBwbGFjZXMgd2hlcmUg
cGVybWlzc2lvbnMNCmFyZSBiZWluZyBzZXQ/DQoNClNob3VsZCBpdCBoYW5kbGUgZXhlY3V0aW5n
IGFuIHVubWFwcGVkIHBhZ2UgZ3JhY2VmdWxseT8gQmVjYXVzZSB0aGlzDQpjaGFuZ2UgaXMgY2F1
c2luZyB0aGF0IHRvIGhhcHBlbiBtdWNoIGVhcmxpZXIuIElmIHNvbWV0aGluZyB3YXMgcmVseWlu
Zw0Kb24gYSBjYWNoZWQgdHJhbnNsYXRpb24gdG8gZXhlY3V0ZSBzb21ldGhpbmcgaXQgY291bGQg
ZmluZCB0aGUgbWFwcGluZw0KZGlzYXBwZWFyLg0KDQoNCg0KDQoNCg0KDQoNCg0K

