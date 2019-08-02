Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B18AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:49:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F419A206A2
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 03:49:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F419A206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EB116B0266; Thu,  1 Aug 2019 23:49:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C1DA6B026B; Thu,  1 Aug 2019 23:49:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D7D76B026D; Thu,  1 Aug 2019 23:49:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 262976B0266
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 23:49:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so47277611pfv.18
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 20:49:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=lsJLnVEyRid7VtF4jRXBm1a5whjov0+uHEy7qC93gmE=;
        b=rX/378SDpM2tmniGz60vdmAkgpmor6VDhocRfWPFBylGrgqFICwmlVtYbeih4ugK2o
         +GrxP22pV5kaqlS0UqHgV+1rkJeD/sXYqUoKTVRqTYxM9kRWg4y1ko607HuJ80anUC/G
         QqfPR1nEKMTi/5DhAo/if6VjF37GE16czbQlYeHNx7mUhYbu63OOwNjXmmpQGX/1KZ9R
         mwMk4MChK69HTxhJYFDMT0lymBkLESojFHHZD1NptpIst4R38LMlGkiFFFE525wEI6aO
         2FUDc/+GbvkW86uW/pffVmZCmSTAY/yZ9jMFtzRn6FYERJ7ETfeRW0N+5LaqmV6hBeuS
         TaWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAWGp1v7E5HDvS+FajlolxX44/TmYikuvTNw8qA6lR8+yvBic3qx
	ZZs0IYMfueNPRuL9JXFPCULtv9j7PIJu2XWORYzDXWY1RwYURt9wCwQVQ0LyRgGPbWekjVFVJeL
	8rI28HVzbgxwi1AeIRmRCiQftH67AFXo8stvER0CIF6M0NuVeTnAt45FVbMrloibjbw==
X-Received: by 2002:a17:90a:2562:: with SMTP id j89mr2163672pje.123.1564717767806;
        Thu, 01 Aug 2019 20:49:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpT4le05hUXm2u8TTBVgrDEXu3ForGUk8HzRuv1dQtLDvlA/OWCJ0fF2Go+K8CUGUJfjA1
X-Received: by 2002:a17:90a:2562:: with SMTP id j89mr2163625pje.123.1564717766838;
        Thu, 01 Aug 2019 20:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564717766; cv=none;
        d=google.com; s=arc-20160816;
        b=VgthrNSQaMo+FobZiYrTpk2sVAVOCPjR8TZihoC7xUN+5a3OKbnrvY6V9e6DFLZkqd
         GFrCD98F+dmaKpdgpMejnNVUwnMuFrTkPRwscuv1eE9Q0HFjin0+fI1QeOr8WWYbtpiM
         g+rpx0rZYLj0gGiOybHCANu0QN7aIp99FhmbkOTnyxUjL76l7TgF9kuaETyNufbbKgBd
         ZDAnjoDvA2GyNHf0WbbCho1vR7ZH+knji8JgL7w5NKoelQvPQ7slprsDuPoYBb2FPxKT
         0zFBhDJlBXvL/+LBvFvRvTPjZXkV2L9gkk8z2K3XDn1hmAXTkbJjumQFYZp044NrVAS0
         qIxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=lsJLnVEyRid7VtF4jRXBm1a5whjov0+uHEy7qC93gmE=;
        b=EvXPdfuYvgjtEZX3UXtFLLYndnBHTnicxu3GVI7bLW4O96l+KTCuoUwPupmpK5Ebol
         GaTo5iJa1j/lKTbJ4LEKAO/Nq5rLkItqMMrUlnJe2D4pAG88CH1oM7uTiZtIixK4FG4F
         /7ZfbZw4DzTR+0o/aiAS71SGNudXMfWHpJZvSbR2gz6lcI7WUtRJYmU2ABC0+KBeM109
         BD+qOm4EV8t/vWbI1HZujAGOy6rc4D19fGdncZB3k5GeieDJ5TSeDKntgW+zA2Qja63M
         ErPEhj5FFmKN5HCM1MCAd2oqKW8yLx0HGqVYnEBbasil0O9j0k3JqtdujtUfYxJKzcZ8
         UIcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id v185si37521001pgd.340.2019.08.01.20.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 20:49:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x723nHRd021476
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Fri, 2 Aug 2019 12:49:17 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x723nHF8020504;
	Fri, 2 Aug 2019 12:49:17 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x723nHQm016586;
	Fri, 2 Aug 2019 12:49:17 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7341281; Fri, 2 Aug 2019 12:48:27 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Fri, 2
 Aug 2019 12:48:26 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Li Wang <liwang@redhat.com>
CC: Linux-MM <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        Cyril Hrubis <chrubis@suse.cz>
Subject: =?utf-8?B?UmU6IFtNTSBCdWc/XSBtbWFwKCkgdHJpZ2dlcnMgU0lHQlVTIHdoaWxlIGRv?=
 =?utf-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQg?=
 =?utf-8?Q?hugepage_in_background?=
Thread-Topic: =?utf-8?B?W01NIEJ1Zz9dIG1tYXAoKSB0cmlnZ2VycyBTSUdCVVMgd2hpbGUgZG9pbmcg?=
 =?utf-8?B?dGhl4oCLIOKAi251bWFfbW92ZV9wYWdlcygpIGZvciBvZmZsaW5lZCBodWdl?=
 =?utf-8?Q?page_in_background?=
Thread-Index: AQHVRc0JEN0QZXp8lkC2QA8h/0i/bKbmp8yA
Date: Fri, 2 Aug 2019 03:48:26 +0000
Message-ID: <20190802034825.GA20130@hori.linux.bs1.fc.nec.co.jp>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
In-Reply-To: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="utf-8"
Content-ID: <2CC86BE40AAF934886BEF4A53FDE2B6F@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCBKdWwgMjksIDIwMTkgYXQgMDE6MTc6MjdQTSArMDgwMCwgTGkgV2FuZyB3cm90ZToN
Cj4gSGkgTmFveWEgYW5kIExpbnV4LU1NZXJzLA0KPiANCj4gVGhlIExUUC9tb3ZlX3BhZ2UxMiBW
MiB0cmlnZ2VycyBTSUdCVVMgaW4gdGhlIGtlcm5lbC12NS4yLjMgdGVzdGluZy4NCj4gaHR0cHM6
Ly9naXRodWIuY29tL3dhbmdsaTU2NjUvbHRwL2Jsb2IvbWFzdGVyL3Rlc3RjYXNlcy9rZXJuZWwv
c3lzY2FsbHMvDQo+IG1vdmVfcGFnZXMvbW92ZV9wYWdlczEyLmMNCj4gDQo+IEl0IHNlZW1zIGxp
a2UgdGhlIHJldHJ5IG1tYXAoKSB0cmlnZ2VycyBTSUdCVVMgd2hpbGUgZG9pbmcgdGhlIG51bWFf
bW92ZV9wYWdlcw0KPiAoKSBpbiBiYWNrZ3JvdW5kLiBUaGF0IGlzIHZlcnkgc2ltaWxhciB0byB0
aGUga2VybmVsIGJ1ZyB3aGljaCB3YXMgbWVudGlvbmVkIGJ5DQo+IGNvbW1pdCA2YmM5YjU2NDMz
Yjc2ZTQwZChtbTogZml4IHJhY2Ugb24gc29mdC1vZmZsaW5pbmcgKTogQSByYWNlIGNvbmRpdGlv
bg0KPiBiZXR3ZWVuIHNvZnQgb2ZmbGluZSBhbmQgaHVnZXRsYl9mYXVsdCB3aGljaCBjYXVzZXMg
dW5leHBlY3RlZCBwcm9jZXNzIFNJR0JVUw0KPiBraWxsaW5nLg0KPiANCj4gSSdtIG5vdCBzdXJl
IGlmIHRoYXQgYmVsb3cgcGF0Y2ggaXMgbWFraW5nIHNlbmUgdG8gbWVtb3J5LWZhaWx1cmVzLmMs
IGJ1dCBhZnRlcg0KPiBidWlsZGluZyBhIG5ldyBrZXJuZWwtNS4yLjMgd2l0aCB0aGlzIGNoYW5n
ZSwgdGhlIHByb2JsZW0gY2FuIE5PVCBiZSByZXByb2R1Y2VkDQo+IC4gDQo+IA0KPiBBbnkgY29t
bWVudHM/DQo+IA0KPiAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+IC0tLSBh
L21tL21lbW9yeS1mYWlsdXJlLmMNCj4gKysrIGIvbW0vbWVtb3J5LWZhaWx1cmUuYw0KPiBAQCAt
MTY5NSwxNSArMTY5NSwxNiBAQCBzdGF0aWMgaW50IHNvZnRfb2ZmbGluZV9odWdlX3BhZ2Uoc3Ry
dWN0IHBhZ2UgKnBhZ2UsDQo+IGludCBmbGFncykNCj4gICAgICAgICB1bmxvY2tfcGFnZShocGFn
ZSk7DQo+IA0KPiAgICAgICAgIHJldCA9IGlzb2xhdGVfaHVnZV9wYWdlKGhwYWdlLCAmcGFnZWxp
c3QpOw0KPiArICAgICAgIGlmICghcmV0KSB7DQo+ICsgICAgICAgICAgICAgICBwcl9pbmZvKCJz
b2Z0IG9mZmxpbmU6ICUjbHggaHVnZXBhZ2UgZmFpbGVkIHRvIGlzb2xhdGVcbiIsDQo+IHBmbik7
DQo+ICsgICAgICAgICAgICAgICByZXR1cm4gLUVCVVNZOw0KPiArICAgICAgIH0NCj4gKw0KPiAg
ICAgICAgIC8qDQo+ICAgICAgICAgICogZ2V0X2FueV9wYWdlKCkgYW5kIGlzb2xhdGVfaHVnZV9w
YWdlKCkgdGFrZXMgYSByZWZjb3VudCBlYWNoLA0KPiAgICAgICAgICAqIHNvIG5lZWQgdG8gZHJv
cCBvbmUgaGVyZS4NCj4gICAgICAgICAgKi8NCj4gICAgICAgICBwdXRfaHdwb2lzb25fcGFnZSho
cGFnZSk7DQo+IC0gICAgICAgaWYgKCFyZXQpIHsNCj4gLSAgICAgICAgICAgICAgIHByX2luZm8o
InNvZnQgb2ZmbGluZTogJSNseCBodWdlcGFnZSBmYWlsZWQgdG8gaXNvbGF0ZVxuIiwNCj4gcGZu
KTsNCj4gLSAgICAgICAgICAgICAgIHJldHVybiAtRUJVU1k7DQo+IC0gICAgICAgfQ0KDQpTb3Jy
eSBmb3IgbXkgbGF0ZSByZXNwb25zZS4NCg0KVGhpcyBjaGFuZ2Ugc2tpcHMgcHV0X2h3cG9pc29u
X3BhZ2UoKSBpbiBmYWlsdXJlIHBhdGgsIHNvIHNvZnRfb2ZmbGluZV9wYWdlKCkNCnNob3VsZCBy
ZXR1cm4gd2l0aG91dCByZWxlYXNpbmcgaHBhZ2UncyByZWZjb3VudCB0YWtlbiBieSBnZXRfYW55
X3BhZ2UoKSwNCm1heWJlIHdoaWNoIGlzIG5vdCB3aGF0IHdlIHdhbnQuDQoNCi0gTmFveWE=

