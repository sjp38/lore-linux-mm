Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5249CC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:33:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04C9A2175B
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:33:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04C9A2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 723BC6B0003; Mon, 18 Mar 2019 05:33:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AD1F6B0006; Mon, 18 Mar 2019 05:33:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59C6B6B0007; Mon, 18 Mar 2019 05:33:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC6C56B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:33:24 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id g19so1491403lfb.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ptwxEo0Z5+QHHMSgaXZET7bq/uN1WA+n1cncfO/jtg0=;
        b=K0dqweU93hj7G7gNP3zSuGbohQ9+1OC6tHGkaBXIvbvoN5Nv+1pKwHukE0A0lEVZ09
         V7q+8CpIMPwu+64WmjwQxUDyt+8lO+68V7ZWUdTxoDmdKrDcPBCuqSGxlTqFO5EB0czO
         29/ysozYo5qJWHW+iV1BBHDpoK93mjZrlIDtwId7fYnSrCtRcBroFBo0FAtOzbkEjuFk
         jI7EJxCN+TQgvY4PpvERrmiyZwp5+Ea1ekgQOy60UAiFasC2eWHOtGNm/c/LpsSTS930
         XTXpDec9dEqvUV4sE0LLFWQv9GuDH2rCQsE6LSl62byZA45Buo2DvmLIo1aMQt3J1wFf
         F7YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUe/CgtpxgIk3knS/rUT5Wui+BcXv7GNwkyxDHwEpcpxSq8/HfR
	4HWeg0/v1nY1pJ0myZ8V1k/RfsTvY8k86gUthTi4ypbLDQx5UzaeHDdZo1aj3yaU6/AQIEn5cMG
	FtG9446y7YHyNCX6cpnprYC4ZCqrD29yYi4W+ZJvuwKL1dPGxLZ7qo5n05RQKPyAuOw==
X-Received: by 2002:ac2:5204:: with SMTP id a4mr7049988lfl.149.1552901604262;
        Mon, 18 Mar 2019 02:33:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5Bg5nsfHUkXRWT4s99VYChONE6OZ66bI1haxD9jWX1SMvc0WMLMZrXGm6umAn6OsjkJQA
X-Received: by 2002:ac2:5204:: with SMTP id a4mr7049959lfl.149.1552901603181;
        Mon, 18 Mar 2019 02:33:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552901603; cv=none;
        d=google.com; s=arc-20160816;
        b=lZR3++TXpFr2lCcYiKBi2TmeHqIfbJzxnJH+AGvbEqJLYToJBfMYt9J7EYX6zAck/7
         0rGFObVZr6PN+QGsajLe1o3Wxg+rTX8y8HVpIYCxlTvGfv3PXLp2vzfOZG9UWwksOUB1
         WCc+DXX6BtOfT9hGfZwov+1/sMKn+kkuxhsirGL/QAJmtQ8HrgKh49SIZ2qXwgnug4xh
         ATuXhvkWWshhmQg63TvnIXlc3aM/kwWA50HK49n5UuTfQVRozXh+g+NY5dpVm9Xt5cZb
         Ryc04HSRvPQVEf87HM5g0hy+eZTohC1MYqDBnhzdwTE6qMSFFDiYJMXNebRZfPVwUzqc
         MYmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ptwxEo0Z5+QHHMSgaXZET7bq/uN1WA+n1cncfO/jtg0=;
        b=GCfkmjKjJa9qrLD4OLmYNaU1UHLMPanlVKSFoCWSePttYJFDtQjmrbc/spasGVafoT
         PAZSxtfVMex2CA+9lKw2sbCraYeyOQvG46BrXaGlaV6uQVbuGSufFPI0EddRZuyly/IQ
         Oywld889J12I2POCvwyfYa/OiBT9jQsos6aaVqcBSbDxG5Z1vj+sTtKdUDyIKRLRC8rx
         Rf2dG5vbOj6h6jE7q7TXQUnMAsHbT8UG4jklMtXrSbL3tuhg4JxsPSy2/IIst3MqnfDq
         FK3Z37KgFHnwreJmm1f3Hj5XkjOOCSSp5ZLH/tHbUhJJ9L1MXTE8L+YdufECEX1QnXS5
         GrHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id x17si6320805ljh.59.2019.03.18.02.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 02:33:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h5odw-00056m-6P; Mon, 18 Mar 2019 12:33:16 +0300
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>,
 Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
 "aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "minchan@kernel.org" <minchan@kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>,
 "hillf.zj@alibaba-inc.com" <hillf.zj@alibaba-inc.com>
References: <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>
 <SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
Date: Mon, 18 Mar 2019 12:33:15 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: base64
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksIFBhbmthaiwNCg0KT24gMTguMDMuMjAxOSAxMjowOSwgUGFua2FqIFN1cnlhd2Fuc2hp
IHdyb3RlOg0KPiANCj4gSGVsbG8NCj4gDQo+IHNocmlua19wYWdlX2xpc3QoKSByZXR1cm5z
ICwgbnVtYmVyIG9mIHBhZ2VzIHJlY2xhaW1lZCwgd2hlbiBwYWdlcyBpcyB1bmV2aWN0YWJs
ZSBpdCByZXR1cm5zIFZNX0JVR19PTl9QQUdFKFBhZ2VMUlUocGFnZSkgfHwgUGFnZVVuZXZp
Y2F0YmxlKHBhZ2UpLHBhZ2UpOw0KDQp0aGUgZ2VuZXJhbCBpZGVhIGlzIHNocmlua19wYWdl
X2xpc3QoKSBjYW4ndCBpdGVyYXRlIFBhZ2VVbmV2aWN0YWJsZSgpIHBhZ2VzLg0KUGFnZVVu
ZXZpY3RhYmxlKCkgcGFnZXMgYXJlIG5ldmVyIGJlaW5nIGFkZGVkIHRvIGxpc3RzLCB3aGlj
aCBzaHJpbmtfcGFnZV9saXN0KCkNCnVzZXMgZm9yIGl0ZXJhdGlvbi4gQWxzbywgYSBwYWdl
IGNhbid0IGJlIG1hcmtlZCBhcyBQYWdlVW5ldmljdGFibGUoKSwgd2hlbg0KaXQncyBhdHRh
Y2hlZCB0byBhIHNocmlua2FibGUgbGlzdC4NCg0KU28sIHRoZSBwcm9ibGVtIHNob3VsZCBi
ZSBzb21ld2hlcmUgb3V0c2lkZSBzaHJpbmtfcGFnZV9saXN0KCkuDQoNCkkgd29uJ3Qgc3Vn
Z2VzdCB5b3Ugc29tZXRoaW5nIGFib3V0IENNQSwgc2luY2UgSSBoYXZlbid0IGRpdmVkIGlu
IHRoYXQgY29kZS4NCg0KPiBXZSBjYW4gYWRkIHRoZSB1bmV2aWN0YWJsZSBwYWdlcyBpbiBy
ZWNsYWltIGxpc3QgaW4gc2hyaW5rX3BhZ2VfbGlzdCgpLCByZXR1cm4gdG90YWwgbnVtYmVy
IG9mIHJlY2xhaW0gcGFnZXMgaW5jbHVkaW5nIHVuZXZpY3RhYmxlIHBhZ2VzLCBsZXQgdGhl
IGNhbGxlciBoYW5kbGUgdW5ldmljdGFibGUgcGFnZXMuDQo+IA0KPiBJIHRoaW5rIHRoZSBw
cm9ibGVtIGlzIHNocmlua19wYWdlX2xpc3QgaXMgYXdrYXJkLiBJZiBwYWdlIGlzIHVuZXZp
Y3RhYmxlIGl0IGdvdG8gYWN0aXZhdGVfbG9ja2VkLT5rZWVwX2xvY2tlZC0+a2VlcCBsYWJs
ZXMsIGtlZXAgbGFibGUgbGlzdF9hZGQgdGhlIHVuZXZpY3RhYmxlIHBhZ2VzIGFuZCB0aHJv
dyB0aGUgVk1fQlVHIGluc3RlYWQgb2YgcGFzc2luZyBpdCB0byBjYWxsZXIgd2hpbGUgaXQg
cmVsaWVzIG9uIGNhbGxlciBmb3Igbm9uLXJlY2xhaW1lZC1ub24tdW5ldmljdGFibGUgIHBh
Z2UncyBwdXRiYWNrLg0KPiBJIHRoaW5rIHdlIGNhbiBtYWtlIGl0IGNvbnNpc3RlbnQgc28g
dGhhdCBzaHJpbmtfcGFnZV9saXN0IGNvdWxkIHJldHVybiBub24tcmVjbGFpbWVkIHBhZ2Vz
IHZpYSBwYWdlX2xpc3QgYW5kIGNhbGxlciBjYW4gaGFuZGxlIGl0LiBBcyBhbiBhZHZhbmNl
LCBpdCBjb3VsZCB0cnkgdG8gbWlncmF0ZSBtbG9ja2VkIHBhZ2VzIHdpdGhvdXQgcmV0cmlh
bC4NCj4gDQo+IA0KPiBCZWxvdyBpcyB0aGUgaXNzdWUgb2YgQ01BX0FMTE9DIG9mIGxhcmdl
IHNpemUgYnVmZmVyIDogKEtlcm5lbCB2ZXJzaW9uIC0gNC4xNC42NSAoT24gQW5kcm9pZCBw
aWUgW0FSTV0pKS4NCj4gDQo+IFugoCAyNC43MTg3OTJdIHBhZ2UgZHVtcGVkIGJlY2F1c2U6
IFZNX0JVR19PTl9QQUdFKFBhZ2VMUlUocGFnZSkgfHwgUGFnZVVuZXZpY3RhYmxlKHBhZ2Up
KQ0KPiBboKAgMjQuNzI2OTQ5XSBwYWdlLT5tZW1fY2dyb3VwOmJkMDA4YzAwDQo+IFugoCAy
NC43MzA2OTNdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQ0KPiBboKAg
MjQuNzM1MzA0XSBrZXJuZWwgQlVHIGF0IG1tL3Ztc2Nhbi5jOjEzNTAhDQo+IFugoCAyNC43
Mzk0NzhdIEludGVybmFsIGVycm9yOiBPb3BzIC0gQlVHOiAwIFsjMV0gUFJFRU1QVCBTTVAg
QVJNDQo+IA0KPiANCj4gQmVsb3cgaXMgdGhlIHBhdGNoIHdoaWNoIHNvbHZlZCB0aGlzIGlz
c3VlIDoNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS92bXNjYW4uYyBiL21tL3Ztc2Nhbi5jDQo+
IGluZGV4IGJlNTZlMmUuLjEyYWMzNTMgMTAwNjQ0DQo+IC0tLSBhL21tL3Ztc2Nhbi5jDQo+
ICsrKyBiL21tL3Ztc2Nhbi5jDQo+IEBAIC05OTgsNyArOTk4LDcgQEAgc3RhdGljIHVuc2ln
bmVkIGxvbmcgc2hyaW5rX3BhZ2VfbGlzdChzdHJ1Y3QgbGlzdF9oZWFkICpwYWdlX2xpc3Qs
DQo+IKCgoKCgoKCgoKCgoKCgoCBzYy0+bnJfc2Nhbm5lZCsrOw0KPiCgDQo+IKCgoKCgoKCg
oKCgoKCgoCBpZiAodW5saWtlbHkoIXBhZ2VfZXZpY3RhYmxlKHBhZ2UpKSkNCj4gLaCgoKCg
oKCgoKCgoKCgoKCgoKCgoKAgZ290byBhY3RpdmF0ZV9sb2NrZWQ7DQo+ICugoKCgoKCgoKCg
oKCgoKCgoKCgoKAgZ290byBjdWxsX21sb2NrZWQ7DQo+IKANCj4goKCgoKCgoKCgoKCgoKCg
IGlmICghc2MtPm1heV91bm1hcCAmJiBwYWdlX21hcHBlZChwYWdlKSkNCj4goKCgoKCgoKCg
oKCgoKCgoKCgoKCgoKAgZ290byBrZWVwX2xvY2tlZDsNCj4gQEAgLTEzMzEsNyArMTMzMSwx
MiBAQCBzdGF0aWMgdW5zaWduZWQgbG9uZyBzaHJpbmtfcGFnZV9saXN0KHN0cnVjdCBsaXN0
X2hlYWQgKnBhZ2VfbGlzdCwNCj4goKCgoKCgoKCgoKCgoKCgIH0gZWxzZQ0KPiCgoKCgoKCg
oKCgoKCgoKCgoKCgoKCgoCBsaXN0X2FkZCgmcGFnZS0+bHJ1LCAmZnJlZV9wYWdlcyk7DQo+
IKCgoKCgoKCgoKCgoKCgoCBjb250aW51ZTsNCj4gLQ0KPiArY3VsbF9tbG9ja2VkOg0KPiAr
oKCgoKCgoKCgoKCgoKCgIGlmIChQYWdlU3dhcENhY2hlKHBhZ2UpKQ0KPiAroKCgoKCgoKCg
oKCgoKCgoKCgoKCgoKAgdHJ5X3RvX2ZyZWVfc3dhcChwYWdlKTsNCj4gK6CgoKCgoKCgoKCg
oKCgoCB1bmxvY2tfcGFnZShwYWdlKTsNCj4gK6CgoKCgoKCgoKCgoKCgoCBsaXN0X2FkZCgm
cGFnZS0+bHJ1LCAmcmV0X3BhZ2VzKTsNCj4gK6CgoKCgoKCgoKCgoKCgoCBjb250aW51ZTsN
Cj4goGFjdGl2YXRlX2xvY2tlZDoNCj4goKCgoKCgoKCgoKCgoKCgIC8qIE5vdCBhIGNhbmRp
ZGF0ZSBmb3Igc3dhcHBpbmcsIHNvIHJlY2xhaW0gc3dhcCBzcGFjZS4gKi8NCj4goKCgoKCg
oKCgoKCgoKCgIGlmIChQYWdlU3dhcENhY2hlKHBhZ2UpICYmIChtZW1fY2dyb3VwX3N3YXBf
ZnVsbChwYWdlKSB8fA0KPiANCj4gDQo+IA0KPiANCj4gSXQgZml4ZXMgdGhlIGJlbG93IGlz
c3VlLg0KPiANCj4gMS4gTGFyZ2Ugc2l6ZSBidWZmZXIgYWxsb2NhdGlvbiB1c2luZyBjbWFf
YWxsb2Mgc3VjY2Vzc2Z1bCB3aXRoIHVuZXZpY3RhYmxlIHBhZ2VzLg0KPiANCj4gY21hX2Fs
bG9jIG9mIGN1cnJlbnQga2VybmVsIHdpbGwgZmFpbCBkdWUgdG8gdW5ldmljdGFibGUgcGFn
ZQ0KPiANCj4gUGxlYXNlIGxldCBtZSBrbm93IGlmIGFueXRoaW5nIGkgYW0gbWlzc2luZy4N
Cj4gDQo+IFJlZ2FyZHMsDQo+IFBhbmthag0KPiAgIA0KPiBGcm9tOiBWbGFzdGltaWwgQmFi
a2EgPHZiYWJrYUBzdXNlLmN6Pg0KPiBTZW50OiAxOCBNYXJjaCAyMDE5IDE0OjEyOjUwDQo+
IFRvOiBQYW5rYWogU3VyeWF3YW5zaGk7IEtpcmlsbCBUa2hhaTsgTWljaGFsIEhvY2tvOyBh
bmVlc2gua3VtYXJAbGludXguaWJtLmNvbQ0KPiBDYzogbGludXgta2VybmVsQHZnZXIua2Vy
bmVsLm9yZzsgbWluY2hhbkBrZXJuZWwub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7IGtoYW5k
dWFsQGxpbnV4LnZuZXQuaWJtLmNvbTsgaGlsbGYuempAYWxpYmFiYS1pbmMuY29tDQo+IFN1
YmplY3Q6IFJlOiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xhaW0gdW5ldmljdGFibGUg
cGFnZXMNCj4goCANCj4gDQo+IE9uIDMvMTUvMTkgMTE6MTEgQU0sIFBhbmthaiBTdXJ5YXdh
bnNoaSB3cm90ZToNCj4+DQo+PiBbIGNjIEFuZWVzaCBrdW1hciwgQW5zaHVtYW4sIEhpbGxm
LCBWbGFzdGltaWxdDQo+IA0KPiBDYW4geW91IHNlbmQgYSBwcm9wZXIgcGF0Y2ggd2l0aCBj
aGFuZ2Vsb2cgZXhwbGFpbmluZyB0aGUgY2hhbmdlPyBJDQo+IGRvbid0IGtub3cgdGhlIGNv
bnRleHQgb2YgdGhpcyB0aHJlYWQuDQo+IA0KPj4gRnJvbTogUGFua2FqIFN1cnlhd2Fuc2hp
DQo+PiBTZW50OiAxNSBNYXJjaCAyMDE5IDExOjM1OjA1DQo+PiBUbzogS2lyaWxsIFRraGFp
OyBNaWNoYWwgSG9ja28NCj4+IENjOiBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBt
aW5jaGFuQGtlcm5lbC5vcmc7IGxpbnV4LW1tQGt2YWNrLm9yZw0KPj4gU3ViamVjdDogUmU6
IFJlOiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xhaW0gdW5ldmljdGFibGUgcGFnZXMN
Cj4+DQo+Pg0KPj4NCj4+IFsgY2MgbGludXgtbW0gXQ0KPj4NCj4+DQo+PiBGcm9tOiBQYW5r
YWogU3VyeWF3YW5zaGkNCj4+IFNlbnQ6IDE0IE1hcmNoIDIwMTkgMTk6MTQ6NDANCj4+IFRv
OiBLaXJpbGwgVGtoYWk7IE1pY2hhbCBIb2Nrbw0KPj4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2Vy
Lmtlcm5lbC5vcmc7IG1pbmNoYW5Aa2VybmVsLm9yZw0KPj4gU3ViamVjdDogUmU6IFJlOiBb
RXh0ZXJuYWxdIFJlOiB2bXNjYW46IFJlY2xhaW0gdW5ldmljdGFibGUgcGFnZXMNCj4+DQo+
Pg0KPj4NCj4+IEhlbGxvICwNCj4+DQo+PiBQbGVhc2UgaWdub3JlIHRoZSBjdXJseSBicmFj
ZXMsIHRoZXkgYXJlIGp1c3QgZm9yIGRlYnVnZ2luZy4NCj4+DQo+PiBCZWxvdyBpcyB0aGUg
dXBkYXRlZCBwYXRjaC4NCj4+DQo+Pg0KPj4gZGlmZiAtLWdpdCBhL21tL3Ztc2Nhbi5jIGIv
bW0vdm1zY2FuLmMNCj4+IGluZGV4IGJlNTZlMmUuLjEyYWMzNTMgMTAwNjQ0DQo+PiAtLS0g
YS9tbS92bXNjYW4uYw0KPj4gKysrIGIvbW0vdm1zY2FuLmMNCj4+IEBAIC05OTgsNyArOTk4
LDcgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgc2hyaW5rX3BhZ2VfbGlzdChzdHJ1Y3QgbGlz
dF9oZWFkICpwYWdlX2xpc3QsDQo+PiCgoKCgoKCgoKCgoKCgoKCgIHNjLT5ucl9zY2FubmVk
Kys7DQo+Pg0KPj4goKCgoKCgoKCgoKCgoKCgoCBpZiAodW5saWtlbHkoIXBhZ2VfZXZpY3Rh
YmxlKHBhZ2UpKSkNCj4+IC2goKCgoKCgoKCgoKCgoKCgoKCgoKCgIGdvdG8gYWN0aXZhdGVf
bG9ja2VkOw0KPj4gK6CgoKCgoKCgoKCgoKCgoKCgoKCgoCBnb3RvIGN1bGxfbWxvY2tlZDsN
Cj4+DQo+PiCgoKCgoKCgoKCgoKCgoKCgIGlmICghc2MtPm1heV91bm1hcCAmJiBwYWdlX21h
cHBlZChwYWdlKSkNCj4+IKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoCBnb3RvIGtlZXBfbG9j
a2VkOw0KPj4gQEAgLTEzMzEsNyArMTMzMSwxMiBAQCBzdGF0aWMgdW5zaWduZWQgbG9uZyBz
aHJpbmtfcGFnZV9saXN0KHN0cnVjdCBsaXN0X2hlYWQgKnBhZ2VfbGlzdCwNCj4+IKCgoKCg
oKCgoKCgoKCgoKAgfSBlbHNlDQo+PiCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKAgbGlzdF9h
ZGQoJnBhZ2UtPmxydSwgJmZyZWVfcGFnZXMpOw0KPj4goKCgoKCgoKCgoKCgoKCgoCBjb250
aW51ZTsNCj4+IC0NCj4+ICtjdWxsX21sb2NrZWQ6DQo+PiAroKCgoKCgoKCgoKCgoKCgIGlm
IChQYWdlU3dhcENhY2hlKHBhZ2UpKQ0KPj4gK6CgoKCgoKCgoKCgoKCgoKCgoKCgoKCgIHRy
eV90b19mcmVlX3N3YXAocGFnZSk7DQo+PiAroKCgoKCgoKCgoKCgoKCgIHVubG9ja19wYWdl
KHBhZ2UpOw0KPj4gK6CgoKCgoKCgoKCgoKCgoCBsaXN0X2FkZCgmcGFnZS0+bHJ1LCAmcmV0
X3BhZ2VzKTsNCj4+ICugoKCgoKCgoKCgoKCgoKAgY29udGludWU7DQo+PiCgIGFjdGl2YXRl
X2xvY2tlZDoNCj4+IKCgoKCgoKCgoKCgoKCgoKAgLyogTm90IGEgY2FuZGlkYXRlIGZvciBz
d2FwcGluZywgc28gcmVjbGFpbSBzd2FwIHNwYWNlLiAqLw0KPj4goKCgoKCgoKCgoKCgoKCg
oCBpZiAoUGFnZVN3YXBDYWNoZShwYWdlKSAmJiAobWVtX2Nncm91cF9zd2FwX2Z1bGwocGFn
ZSkgfHwNCj4+DQo+Pg0KPj4NCj4+IFJlZ2FyZHMsDQo+PiBQYW5rYWoNCj4+DQo+Pg0KPj4g
RnJvbTogS2lyaWxsIFRraGFpIDxrdGtoYWlAdmlydHVvenpvLmNvbT4NCj4+IFNlbnQ6IDE0
IE1hcmNoIDIwMTkgMTQ6NTU6MzQNCj4+IFRvOiBQYW5rYWogU3VyeWF3YW5zaGk7IE1pY2hh
bCBIb2Nrbw0KPj4gQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IG1pbmNoYW5A
a2VybmVsLm9yZw0KPj4gU3ViamVjdDogUmU6IFJlOiBbRXh0ZXJuYWxdIFJlOiB2bXNjYW46
IFJlY2xhaW0gdW5ldmljdGFibGUgcGFnZXMNCj4+DQo+Pg0KPj4gT24gMTQuMDMuMjAxOSAx
MTo1MiwgUGFua2FqIFN1cnlhd2Fuc2hpIHdyb3RlOg0KPj4+DQo+Pj4gSSBhbSB1c2luZyBr
ZXJuZWwgdmVyc2lvbiA0LjE0LjY1IChvbiBBbmRyb2lkIHBpZSBbQVJNXSkuDQo+Pj4NCj4+
PiBObyBhZGRpdGlvbmFsIHBhdGNoZXMgYXBwbGllZCBvbiB0b3Agb2YgdmFuaWxsYS4oQ29y
ZSBNTSkuDQo+Pj4NCj4+PiBJZqAgSSBjaGFuZ2UgaW4gdGhlIHZtc2Nhbi5jIGFzIGJlbG93
IHBhdGNoLCBpdCB3aWxsIHdvcmsuDQo+Pg0KPj4gU29ycnksIGJ1dCA0LjE0LjY1IGRvZXMg
bm90IGhhdmUgYnJhY2VzIGFyb3VuZCB0cnlsb2NrX3BhZ2UoKSwNCj4+IGxpa2UgaW4geW91
ciBwYXRjaCBiZWxvdy4NCj4+DQo+PiBTZWWgoKCgICBodHRwczovL2dpdC5rZXJuZWwub3Jn
L3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9zdGFibGUvbGludXguZ2l0L3RyZWUvbW0vdm1z
Y2FuLmM/aD12NC4xNC42NQ0KPj4NCj4+IFsuLi5dDQo+Pg0KPj4+PiBkaWZmIC0tZ2l0IGEv
bW0vdm1zY2FuLmMgYi9tbS92bXNjYW4uYw0KPj4+PiBpbmRleCBiZTU2ZTJlLi4yZTUxZWRj
IDEwMDY0NA0KPj4+PiAtLS0gYS9tbS92bXNjYW4uYw0KPj4+PiArKysgYi9tbS92bXNjYW4u
Yw0KPj4+PiBAQCAtOTkwLDE1ICs5OTAsMTcgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgc2hy
aW5rX3BhZ2VfbGlzdChzdHJ1Y3QgbGlzdF9oZWFkICpwYWdlX2xpc3QsDQo+Pj4+IKCgoKCg
oKCgoKCgoKCgoKCgIHBhZ2UgPSBscnVfdG9fcGFnZShwYWdlX2xpc3QpOw0KPj4+PiCgoKCg
oKCgoKCgoKCgoKCgoCBsaXN0X2RlbCgmcGFnZS0+bHJ1KTsNCj4+Pj4NCj4+Pj4goKCgoKCg
oKCgoKCgoKCgoCBpZiAoIXRyeWxvY2tfcGFnZShwYWdlKSkgew0KPj4+PiCgoKCgoKCgoKCg
oKCgoKCgoKCgoKCgoKCgIGdvdG8ga2VlcDsNCj4+Pj4goKCgoKCgoKCgoKCgoKCgoCB9DQo+
Pg0KPj4gKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KiBlSW5mb2NoaXBzIEJ1c2luZXNzIERpc2NsYWltZXI6IFRoaXMgZS1tYWlsIG1lc3NhZ2Ug
YW5kIGFsbCBhdHRhY2htZW50cyB0cmFuc21pdHRlZCB3aXRoIGl0IGFyZSBpbnRlbmRlZCAg
c29sZWx5IGZvciB0aGUgdXNlIG9mIHRoZSBhZGRyZXNzZWUgYW5kIG1heSBjb250YWluIGxl
Z2FsbHkgcHJpdmlsZWdlZCBhbmQgY29uZmlkZW50aWFsIGluZm9ybWF0aW9uLiBJZiB0aGUg
cmVhZGVyIG9mIHRoaXMgbWVzc2FnZSBpcyBub3QgdGhlIGludGVuZGVkIHJlY2lwaWVudCwg
b3IgYW4gZW1wbG95ZWUgb3IgYWdlbnQgcmVzcG9uc2libGUgZm9yIGRlbGl2ZXJpbmcgdGhp
cyBtZXNzYWdlIHRvIHRoZSBpbnRlbmRlZCByZWNpcGllbnQsIHlvdSAgYXJlIGhlcmVieSBu
b3RpZmllZCB0aGF0IGFueSBkaXNzZW1pbmF0aW9uLCBkaXN0cmlidXRpb24sIGNvcHlpbmcs
IG9yIG90aGVyIHVzZSBvZiB0aGlzIG1lc3NhZ2Ugb3IgaXRzIGF0dGFjaG1lbnRzIGlzIHN0
cmljdGx5IHByb2hpYml0ZWQuIElmIHlvdSBoYXZlIHJlY2VpdmVkIHRoaXMgbWVzc2FnZSBp
biBlcnJvciwgcGxlYXNlIG5vdGlmeSB0aGUgc2VuZGVyIGltbWVkaWF0ZWx5IGJ5IHJlcGx5
aW5nIHRvIHRoaXMgbWVzc2FnZSBhbmQgcGxlYXNlICBkZWxldGUgaXQgZnJvbSB5b3VyIGNv
bXB1dGVyLiBBbnkgdmlld3MgZXhwcmVzc2VkIGluIHRoaXMgbWVzc2FnZSBhcmUgdGhvc2Ug
b2YgdGhlIGluZGl2aWR1YWwgc2VuZGVyIHVubGVzcyBvdGhlcndpc2Ugc3RhdGVkLiBDb21w
YW55IGhhcyB0YWtlbiBlbm91Z2ggcHJlY2F1dGlvbnMgdG8gcHJldmVudCB0aGUgc3ByZWFk
IG9mIHZpcnVzZXMuIEhvd2V2ZXIgdGhlIGNvbXBhbnkgYWNjZXB0cyBubyBsaWFiaWxpdHkg
Zm9yIGFueSBkYW1hZ2UgY2F1c2VkICBieSBhbnkgdmlydXMgdHJhbnNtaXR0ZWQgYnkgdGhp
cyBlbWFpbC4gKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKg0KPj4NCj4gDQo+ICAgICANCj4gDQo=

