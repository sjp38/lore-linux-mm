Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E64E1C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:20:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B11C62087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 18:20:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B11C62087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D31F6B0003; Fri, 17 May 2019 14:20:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 283F36B0005; Fri, 17 May 2019 14:20:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 14E826B0006; Fri, 17 May 2019 14:20:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D1DCD6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 14:20:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h7so5013073pfq.22
        for <linux-mm@kvack.org>; Fri, 17 May 2019 11:20:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=xcZnTcW8gFOzxH4OMKvQfFL+hX2JVROoxe4NttBHMho=;
        b=BmlVmHAa/Xi1sTxxfbp9f6En5S6Zu9TucX8vqVOWQtx8kVboiawD/82jDt7AWVtzIM
         oVRq4cSurT4Ma3Dj2bPo0K+dFfoqf5uukAqSECtjSRJ0wROt7COxPyq4ayxXicUNLKF/
         EV9cJcKX+t8W+dXCJdUpWZ8chx6Ut1pGoYcBZBoSG48UXjWQYM8GMo09Bs5cE8g0HNXv
         e+ZP17e1XIbpnbBumDdPKCJEyYTLKcWQsNteur7eEbahmbVCfIADCkkPqaffCQBUHTZJ
         pEexTJgIcpiReYcicbWn9XXUpoaOBA2F80Mc1bn2nDfwtSb+zV2z7O1RQUvWguND6hnL
         TZVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUKJxfRcmbfS+XsSbQ7E1thxKRgZX+MLgAtaaPsWnbyvv7o329A
	8uJLceuwT3XZvrTCmSg2eWYh5EyuwBdXlB0PdBJo2ddQfD7iIHDvtoK808t1D211FJL9XBG9Fi5
	XV2FWn1kP8IpdXjeJQlI4IdjzVPZEG4gZwvvxwXXI3ibXZhOcKjNG1Gq/k+BN8UiGTA==
X-Received: by 2002:a17:902:b106:: with SMTP id q6mr4210626plr.215.1558117238517;
        Fri, 17 May 2019 11:20:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5sLEpZUC/YJIIdeNyk7Kd6TXZkRE2Cu6aS9yccRJf0jNds2ah5IdfPPhCdieiX0WoyKPp
X-Received: by 2002:a17:902:b106:: with SMTP id q6mr4210582plr.215.1558117237789;
        Fri, 17 May 2019 11:20:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558117237; cv=none;
        d=google.com; s=arc-20160816;
        b=Dr9oyUwEgI1rMDCiaCLlk8VZnaQ69ReGDC9UVnUd4kT2FogrKVLRMqNskal2I79qM0
         BBbCnCUROphsNW4mtrDgJyiowSw0RNmcBaFPx/Ma7eC6nPeK/fd8515b+C4RgbvbRZjZ
         Kd4pz0UxK1ZQ7EZqHUfy41Lz/w4/YybnE55vcxY3MXm47q5VxmYD/M5daDneK0GqX5vM
         VrEoGKnonT8X0HCTaGuKjMH0m88z2Hklz8vhqDVw8LgKMfEZvugGlnwlabamxuuqGT2i
         xVvWuAVypRtQQYMpG02QNNpjreZfyMyQiqUlItBoqg9q4dc0j4P9IWF6iwoOuILaY+Bo
         8GaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=xcZnTcW8gFOzxH4OMKvQfFL+hX2JVROoxe4NttBHMho=;
        b=RdNUwSRJ1JKVNH8LWki87T/GXVWmvjYUC2kWoGFwo+ceLEOUq1giy046Ysp4bHVJiq
         MCL2LobJOdafEZ/Oix6yyA+J+FbsLf8BCePMedpL0HhjXTMju3dmp9rXcTBP952poK/K
         b8JqEXdexzgTXJ2GZpZr1XV/iPUUEziP44FhUgGWPKWT46zANoPxPS4leX+/Y8tRS70I
         p0AVzjXLY8TIS2iyA06BHqV0AI8GLnDCwlgXf2ml6QAAobCkiATj53w2VroX7sf2GESI
         guEQEH6LknG3C45GAtmkvYUwqeBthpZq+w4syv2LrnKEDSlpPulI7+6QVPiBaxBqe1Zr
         2GtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id i1si8498837pgd.404.2019.05.17.11.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 11:20:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vishal.l.verma@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=vishal.l.verma@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 May 2019 11:20:37 -0700
X-ExtLoop1: 1
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga005.fm.intel.com with ESMTP; 17 May 2019 11:20:37 -0700
Received: from fmsmsx101.amr.corp.intel.com (10.18.124.199) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 17 May 2019 11:20:37 -0700
Received: from fmsmsx113.amr.corp.intel.com ([169.254.13.118]) by
 fmsmsx101.amr.corp.intel.com ([169.254.1.175]) with mapi id 14.03.0415.000;
 Fri, 17 May 2019 11:20:36 -0700
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
To: "jane.chu@oracle.com" <jane.chu@oracle.com>, "n-horiguchi@ah.jp.nec.com"
	<n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH] mm, memory-failure: clarify error message
Thread-Topic: [PATCH] mm, memory-failure: clarify error message
Thread-Index: AQHVDGYyA0CPmuStD0eYJ9uY1/4/yKZwFv2A
Date: Fri, 17 May 2019 18:20:35 +0000
Message-ID: <530f16a9207bd90b7752c8ea6bf38302a8cd7b4b.camel@intel.com>
References: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.5 (3.30.5-1.fc29) 
x-originating-ip: [10.254.87.144]
Content-Type: text/plain; charset="utf-8"
Content-ID: <B9903A53504C41478420F4FC21BBEA5A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA1LTE2IGF0IDIyOjA4IC0wNjAwLCBKYW5lIENodSB3cm90ZToNCj4gU29t
ZSB1c2VyIHdobyBpbnN0YWxsIFNJR0JVUyBoYW5kbGVyIHRoYXQgZG9lcyBsb25nam1wIG91dA0K
PiB0aGVyZWZvcmUga2VlcGluZyB0aGUgcHJvY2VzcyBhbGl2ZSBpcyBjb25mdXNlZCBieSB0aGUg
ZXJyb3INCj4gbWVzc2FnZQ0KPiAgICJbMTg4OTg4Ljc2NTg2Ml0gTWVtb3J5IGZhaWx1cmU6IDB4
MTg0MDIwMDogS2lsbGluZw0KPiAgICBjZWxsc3J2OjMzMzk1IGR1ZSB0byBoYXJkd2FyZSBtZW1v
cnkgY29ycnVwdGlvbiINCj4gU2xpZ2h0bHkgbW9kaWZ5IHRoZSBlcnJvciBtZXNzYWdlIHRvIGlt
cHJvdmUgY2xhcml0eS4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEphbmUgQ2h1IDxqYW5lLmNodUBv
cmFjbGUuY29tPg0KPiAtLS0NCj4gIG1tL21lbW9yeS1mYWlsdXJlLmMgfCA3ICsrKystLS0NCj4g
IDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pDQo+IA0KPiBk
aWZmIC0tZ2l0IGEvbW0vbWVtb3J5LWZhaWx1cmUuYyBiL21tL21lbW9yeS1mYWlsdXJlLmMNCj4g
aW5kZXggZmM4YjUxNy4uMTRkZTVlMiAxMDA2NDQNCj4gLS0tIGEvbW0vbWVtb3J5LWZhaWx1cmUu
Yw0KPiArKysgYi9tbS9tZW1vcnktZmFpbHVyZS5jDQo+IEBAIC0yMTYsMTAgKzIxNiw5IEBAIHN0
YXRpYyBpbnQga2lsbF9wcm9jKHN0cnVjdCB0b19raWxsICp0aywgdW5zaWduZWQgbG9uZyBwZm4s
IGludCBmbGFncykNCj4gIAlzaG9ydCBhZGRyX2xzYiA9IHRrLT5zaXplX3NoaWZ0Ow0KPiAgCWlu
dCByZXQ7DQo+ICANCj4gLQlwcl9lcnIoIk1lbW9yeSBmYWlsdXJlOiAlI2x4OiBLaWxsaW5nICVz
OiVkIGR1ZSB0byBoYXJkd2FyZSBtZW1vcnkgY29ycnVwdGlvblxuIiwNCj4gLQkJcGZuLCB0LT5j
b21tLCB0LT5waWQpOw0KPiAtDQo+ICAJaWYgKChmbGFncyAmIE1GX0FDVElPTl9SRVFVSVJFRCkg
JiYgdC0+bW0gPT0gY3VycmVudC0+bW0pIHsNCj4gKwkJcHJfZXJyKCJNZW1vcnkgZmFpbHVyZTog
JSNseDogS2lsbGluZyAlczolZCBkdWUgdG8gaGFyZHdhcmUgbWVtb3J5ICINCj4gKwkJCSJjb3Jy
dXB0aW9uXG4iLCBwZm4sIHQtPmNvbW0sIHQtPnBpZCk7DQoNCk1pbm9yIG5pdCwgYnV0IHRoZSBz
dHJpbmcgc2hvdWxkbid0IGJlIHNwbGl0IG92ZXIgbXVsdGlwbGUgbGluZXMgdG8NCnByZXNlcnZl
IGdyZXAtYWJpbGl0eS4gSW4gc3VjaCBhIGNhc2UgaXQgaXMgdXN1YWxseSBjb25zaWRlcmVkIE9L
IHRvDQpleGNlZWQgODAgY2hhcmFjdGVycyBmb3IgdGhlIGxpbmUgaWYgbmVlZGVkLg0KDQo+ICAJ
CXJldCA9IGZvcmNlX3NpZ19tY2VlcnIoQlVTX01DRUVSUl9BUiwgKHZvaWQgX191c2VyICopdGst
PmFkZHIsDQo+ICAJCQkJICAgICAgIGFkZHJfbHNiLCBjdXJyZW50KTsNCj4gIAl9IGVsc2Ugew0K
PiBAQCAtMjI5LDYgKzIyOCw4IEBAIHN0YXRpYyBpbnQga2lsbF9wcm9jKHN0cnVjdCB0b19raWxs
ICp0aywgdW5zaWduZWQgbG9uZyBwZm4sIGludCBmbGFncykNCj4gIAkJICogVGhpcyBjb3VsZCBj
YXVzZSBhIGxvb3Agd2hlbiB0aGUgdXNlciBzZXRzIFNJR0JVUw0KPiAgCQkgKiB0byBTSUdfSUdO
LCBidXQgaG9wZWZ1bGx5IG5vIG9uZSB3aWxsIGRvIHRoYXQ/DQo+ICAJCSAqLw0KPiArCQlwcl9l
cnIoIk1lbW9yeSBmYWlsdXJlOiAlI2x4OiBTZW5kaW5nIFNJR0JVUyB0byAlczolZCBkdWUgdG8g
aGFyZHdhcmUgIg0KPiArCQkJIm1lbW9yeSBjb3JydXB0aW9uXG4iLCBwZm4sIHQtPmNvbW0sIHQt
PnBpZCk7DQo+ICAJCXJldCA9IHNlbmRfc2lnX21jZWVycihCVVNfTUNFRVJSX0FPLCAodm9pZCBf
X3VzZXIgKil0ay0+YWRkciwNCj4gIAkJCQkgICAgICBhZGRyX2xzYiwgdCk7ICAvKiBzeW5jaHJv
bm91cz8gKi8NCj4gIAl9DQo=

