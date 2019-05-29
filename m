Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49FE4C04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 05:11:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B98821721
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 05:11:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B98821721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 945326B026E; Wed, 29 May 2019 01:11:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F6836B0271; Wed, 29 May 2019 01:11:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E4326B0272; Wed, 29 May 2019 01:11:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4967F6B026E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 01:11:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so1004837pfb.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 22:11:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=jrP/H4JW9rhSgJFgB8Hc8upbtAIGEmy85amkLx4AnJo=;
        b=MPl/JPctrzB9IzRIXmHAEUU0sJCNyApMHKbSwnunP044c+Uk5wA5I54G3vyKv4yV1d
         64cW2u4jSqKz9ui+kSHdY+gPYeXHy0yKii0Znhgliz9ITObmConF6c8VFwPKZiutUcY6
         m70pxPl8ysOEyhO43oDu24ouJwKE5B/OjWowN5axCPOJ/vGlAxfISWGUf6DC9lW5Ls6F
         d/cgRT11bKuus8aXpnkpZ+5htRR+m+n9PcwnpPisQWyusnHVe/yizhhBMwvH5WEFJ/Me
         LGd7TjPATMsJJcsbFFUg19EZwLwOV6cxClbCD0iCNaK708Adp+tkjXy5r1ELt681gNq0
         ta6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW4kUY5tJiwIV8fFPZSeEWBbglQp5oFOZ0QdFkTRK+sFF9nOKEA
	nRX98rSpuFgqP7XKMd8OH2ARGZgkOksvC5pmPLdxGY4QuN5gWrZK+6y3V6Fx2G/PK/j7X8XZ+N9
	w4r8UBGslTY+KIzqcNTm/ZPhTWZjHZymjOiUiv9qZM2IZSGXMsc1nps1WvQaRRMvFnA==
X-Received: by 2002:a17:90a:658b:: with SMTP id k11mr10051587pjj.44.1559106715959;
        Tue, 28 May 2019 22:11:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZOA1U129743yWpkW5AZR0POnfi2knOnhtJfuwYFIe6GkYr/R/5CyZncflXFeEObJZKjH5
X-Received: by 2002:a17:90a:658b:: with SMTP id k11mr10051545pjj.44.1559106715125;
        Tue, 28 May 2019 22:11:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559106715; cv=none;
        d=google.com; s=arc-20160816;
        b=eS/HAeBrcvLqMijF7O8GzPDGp+Ub7eLe4tfPHASXYaLOzQwCDK8jFJjP2aO2JT3qzW
         Umnfv7Pf8rtVPSpJv+eJAK6Q9h35tuFqQTbfmoetGLhLoEIpviXEIFPf1CehGJmdL8Ls
         9406nDx5gH8Xc7oKmqDQ77jy8fGld9drfRiWitM6lPe21MnhdrG8IGsv2BeDbWf6yVYz
         DML1nYeRHmvsqRidffRH/FJht4lFQPtci3weqlnfUxQsS50128srOVtGUFKqvX+gwG2u
         IfCNdNAmo8qGffR2a/MknmWyVl65g+w25kj7ORlvVPNeEtgStCZlS3DYC8Y9N15wxs4p
         7sGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=jrP/H4JW9rhSgJFgB8Hc8upbtAIGEmy85amkLx4AnJo=;
        b=ORwhy2NJ92WbztHh0545OOSOwMIwq1yv89ryTMatuLpI3Y0TSPuy2w7emrf4E0Vi9k
         UaUzhkx8UteuhdsYAx/xgN1orjTSKeEnYHHrAA/6yDOXroMvJHKg9GVQcr99Dq7dWL+H
         c6K8yYZjpnB4BEjNWwJ/jEoVQdJP4qpkSwYGzWYpyNh6JwxeFJ7n4dmhgh8EgYCTOCBw
         seXGrkoKYgbNF5W/NaZeZkdHiAPKM1liW1ZHfDmKDk6Rzjrci4ziFQK2UOs4oniobFVX
         OEqRe/gjq1QJ4uqBL6I7JOM1SamABZu3qd/Wg4G84E2K9tF64NM3ZDE9dyBfG/u8nv26
         TkaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j1si22520553plt.9.2019.05.28.22.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 22:11:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 May 2019 22:11:54 -0700
X-ExtLoop1: 1
Received: from orsmsx110.amr.corp.intel.com ([10.22.240.8])
  by fmsmga005.fm.intel.com with ESMTP; 28 May 2019 22:11:54 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX110.amr.corp.intel.com ([169.254.10.7]) with mapi id 14.03.0415.000;
 Tue, 28 May 2019 22:11:53 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "davem@davemloft.net" <davem@davemloft.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "namit@vmware.com" <namit@vmware.com>,
	"luto@kernel.org" <luto@kernel.org>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
Subject: Re: [PATCH v5 0/2] Fix issues with vmalloc flush flag
Thread-Topic: [PATCH v5 0/2] Fix issues with vmalloc flush flag
Thread-Index: AQHVFNC+iT2yoslPq0S8A9En17xWb6aBtS+AgABQlQA=
Date: Wed, 29 May 2019 05:11:52 +0000
Message-ID: <abb649f0f076777346cbe6a8a0e5d9f8b3c26b41.camel@intel.com>
References: <20190527211058.2729-1-rick.p.edgecombe@intel.com>
	 <20190528.172327.2113097810388476996.davem@davemloft.net>
In-Reply-To: <20190528.172327.2113097810388476996.davem@davemloft.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.252.134.167]
Content-Type: text/plain; charset="utf-8"
Content-ID: <63D338040718464F89739E472722ADD9@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCAyMDE5LTA1LTI4IGF0IDE3OjIzIC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206IFJpY2sgRWRnZWNvbWJlIDxyaWNrLnAuZWRnZWNvbWJlQGludGVsLmNvbT4NCj4gRGF0
ZTogTW9uLCAyNyBNYXkgMjAxOSAxNDoxMDo1NiAtMDcwMA0KPiANCj4gPiBUaGVzZSB0d28gcGF0
Y2hlcyBhZGRyZXNzIGlzc3VlcyB3aXRoIHRoZSByZWNlbnRseSBhZGRlZA0KPiA+IFZNX0ZMVVNI
X1JFU0VUX1BFUk1TIHZtYWxsb2MgZmxhZy4NCj4gPiANCj4gPiBQYXRjaCAxIGFkZHJlc3NlcyBh
biBpc3N1ZSB0aGF0IGNvdWxkIGNhdXNlIGEgY3Jhc2ggYWZ0ZXIgb3RoZXINCj4gPiBhcmNoaXRl
Y3R1cmVzIGJlc2lkZXMgeDg2IHJlbHkgb24gdGhpcyBwYXRoLg0KPiA+IA0KPiA+IFBhdGNoIDIg
YWRkcmVzc2VzIGFuIGlzc3VlIHdoZXJlIGluIGEgcmFyZSBjYXNlIHN0cmFuZ2UgYXJndW1lbnRz
DQo+ID4gY291bGQgYmUgcHJvdmlkZWQgdG8gZmx1c2hfdGxiX2tlcm5lbF9yYW5nZSgpLiANCj4g
DQo+IEl0IGp1c3Qgb2NjdXJyZWQgdG8gbWUgYW5vdGhlciBzaXR1YXRpb24gdGhhdCB3b3VsZCBj
YXVzZSB0cm91YmxlIG9uDQo+IHNwYXJjNjQsIGFuZCB0aGF0J3MgaWYgc29tZW9uZSB0aGUgYWRk
cmVzcyByYW5nZSBvZiB0aGUgbWFpbiBrZXJuZWwNCj4gaW1hZ2UgZW5kZWQgdXAgYmVpbmcgcGFz
c2VkIHRvIGZsdXNoX3RsYl9rZXJuZWxfcmFuZ2UoKS4NCj4gDQo+IFRoYXQgd291bGQgZmx1c2gg
dGhlIGxvY2tlZCBrZXJuZWwgbWFwcGluZyBhbmQgY3Jhc2ggdGhlIGtlcm5lbA0KPiBpbnN0YW50
bHkgaW4gYSBjb21wbGV0ZWx5IG5vbi1yZWNvdmVyYWJsZSB3YXkuDQoNCkhtbSwgSSBoYXZlbid0
IHJlY2VpdmVkIHRoZSBsb2dzIGZyb20gTWVlbGlzIHRoYXQgd2lsbCBzaG93IHRoZSByZWFsDQpy
YW5nZXMgYmVpbmcgcGFzc2VkIGludG8gZmx1c2hfdGxiX2tlcm5lbF9yYW5nZSgpIG9uIHNwYXJj
LCBidXQgaXQNCnNob3VsZCBiZSBmbHVzaGluZyBhIHJhbmdlIHNwYW5uaW5nIGZyb20gdGhlIG1v
ZHVsZXMgdG8gdGhlIGRpcmVjdCBtYXAuDQpJdCBsb29rcyBsaWtlIHRoZSBrZXJuZWwgaXMgYXQg
dGhlIHZlcnkgYm90dG9tIG9mIHRoZSBhZGRyZXNzIHNwYWNlLCBzbw0Kbm90IGluY2x1ZGVkLiBP
ciBkbyB5b3UgbWVhbiB0aGUgcGFnZXMgdGhhdCBob2xkIHRoZSBrZXJuZWwgdGV4dCBvbiB0aGUN
CmRpcmVjdCBtYXA/DQoNCkJ1dCByZWdhcmRsZXNzIG9mIHRoaXMgbmV3IGNvZGUsIERFQlVHX1BB
R0VBTExPQyBoYW5ncyB3aXRoIHRoZSBmaXJzdA0Kdm1hbGxvYyBmcmVlL3VubWFwLiBUaGF0IHNo
b3VsZCBiZSBqdXN0IGZsdXNoaW5nIGEgc2luZ2xlIGFsbG9jYXRpb24gaW4NCnRoZSB2bWFsbG9j
IHJhbmdlLg0KDQpJZiBpdCBpcyBzb21laG93IGNhdGNoaW5nIGEgbG9ja2VkIGVudHJ5IHRob3Vn
aC4uLiBBcmUgdGhlcmUgYW55IHNwYXJjDQpmbHVzaCBtZWNoYW5pc21zIHRoYXQgY291bGQgYmUg
dXNlZCBpbiB2bWFsbG9jIHRoYXQgd29uJ3QgdG91Y2ggbG9ja2VkDQplbnRyaWVzPyBQZXRlciBa
IHdhcyBwb2ludGluZyBvdXQgdGhhdCBmbHVzaF90bGJfYWxsKCkgbWlnaHQgYmUgbW9yZQ0KYXBw
cm9yaWF0ZSBmb3Igdm1hbGxvYyBhbnl3YXkuDQoNCg==

