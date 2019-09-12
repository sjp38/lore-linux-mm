Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 735D3C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 01:39:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EE7D2085B
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 01:39:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EE7D2085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C17896B000C; Wed, 11 Sep 2019 21:39:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC7D66B000D; Wed, 11 Sep 2019 21:39:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADE376B000E; Wed, 11 Sep 2019 21:39:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 8819D6B000C
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 21:39:25 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0648D1F219
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 01:39:25 +0000 (UTC)
X-FDA: 75924561048.11.slope00_34f9a22791630
X-HE-Tag: slope00_34f9a22791630
X-Filterd-Recvd-Size: 3967
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 01:39:23 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8C1dI5o006280
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 12 Sep 2019 10:39:18 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8C1dI3S015606;
	Thu, 12 Sep 2019 10:39:18 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8C1dH8A007804;
	Thu, 12 Sep 2019 10:39:18 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.149] [10.38.151.149]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-8391413; Thu, 12 Sep 2019 10:38:01 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC21GP.gisp.nec.co.jp ([10.38.151.149]) with mapi id 14.03.0439.000; Thu,
 12 Sep 2019 10:38:00 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: David Hildenbrand <david@redhat.com>
CC: Oscar Salvador <osalvador@suse.de>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 02/10] mm,madvise: call soft_offline_page() without
 MF_COUNT_INCREASED
Thread-Topic: [PATCH 02/10] mm,madvise: call soft_offline_page() without
 MF_COUNT_INCREASED
Thread-Index: AQHVZ8LT5A97dnADeEaaRGKxuElT0aclsJgAgAD+bYA=
Date: Thu, 12 Sep 2019 01:37:59 +0000
Message-ID: <20190912013759.GA4614@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190910103016.14290-3-osalvador@suse.de>
 <a2ec3629-3671-cdb4-70e8-2c7e327444e9@redhat.com>
In-Reply-To: <a2ec3629-3671-cdb4-70e8-2c7e327444e9@redhat.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="utf-8"
Content-ID: <EA10468B73AF4A4EAAC8FF61D7BCB047@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCBTZXAgMTEsIDIwMTkgYXQgMTI6Mjc6MjJQTSArMDIwMCwgRGF2aWQgSGlsZGVuYnJh
bmQgd3JvdGU6DQo+IE9uIDEwLjA5LjE5IDEyOjMwLCBPc2NhciBTYWx2YWRvciB3cm90ZToNCj4g
PiBGcm9tOiBOYW95YSBIb3JpZ3VjaGkgPG4taG9yaWd1Y2hpQGFoLmpwLm5lYy5jb20+DQo+ID4g
DQo+ID4gQ3VycmVudGx5IG1hZHZpc2VfaW5qZWN0X2Vycm9yKCkgcGlucyB0aGUgdGFyZ2V0IHZp
YSBnZXRfdXNlcl9wYWdlc19mYXN0Lg0KPiA+IFRoZSBjYWxsIHRvIGdldF91c2VyX3BhZ2VzX2Zh
c3QgaXMgb25seSB0byBnZXQgdGhlIHJlc3BlY3RpdmUgcGFnZQ0KPiA+IG9mIGEgZ2l2ZW4gYWRk
cmVzcywgYnV0IGl0IGlzIHRoZSBqb2Igb2YgdGhlIG1lbW9yeS1wb2lzb25pbmcgaGFuZGxlcg0K
PiA+IHRvIGRlYWwgd2l0aCByYWNlcywgc28gZHJvcCB0aGUgcmVmY291bnQgZ3JhYmJlZCBieSBn
ZXRfdXNlcl9wYWdlc19mYXN0Lg0KPiA+IA0KPiANCj4gT2gsIGFuZCBhbm90aGVyIHF1ZXN0aW9u
ICJpdCBpcyB0aGUgam9iIG9mIHRoZSBtZW1vcnktcG9pc29uaW5nIGhhbmRsZXIiDQo+IC0gaXMg
dGhhdCBhbHJlYWR5IHByb3Blcmx5IGltcGxlbWVudGVkPyAobmV3YmVlIHF1ZXN0aW9uIMKvXF8o
44OEKV8vwq8pDQoNClRoZSBhYm92ZSBkZXNjcmlwdGlvbiBtaWdodCBiZSBjb25mdXNpbmcsIHNv
cnJ5LiBJdCdzIGludGVuZGVkIGxpa2VzDQoNCiAgVGhlIGNhbGwgdG8gZ2V0X3VzZXJfcGFnZXNf
ZmFzdCBpcyBvbmx5IHRvIGdldCB0aGUgcG9pbnRlciB0byBzdHJ1Y3QNCiAgcGFnZSBvZiBhIGdp
dmVuIGFkZHJlc3MsIHBpbm5pbmcgaXQgaXMgbWVtb3J5LXBvaXNvbmluZyBoYW5kbGVyJ3Mgam9i
LA0KICBzbyBkcm9wIHRoZSByZWZjb3VudCBncmFiYmVkIGJ5IGdldF91c2VyX3BhZ2VzX2Zhc3Qu
DQoNCkFuZCBwaW5uaW5nIGlzIGRvbmUgaW4gZ2V0X2h3cG9pc29uX3BhZ2UoKSBmb3IgaGFyZC1v
ZmZsaW5lIGFuZA0KZ2V0X2FueV9wYWdlKCkgZm9yIHNvZnQtb2ZmbGluZS4gIEZvciBzb2Z0LW9m
ZmxpbmUgY2FzZSwgdGhlIHNlbWFudGljcyBvZg0KcmVmY291bnQgb2YgcG9pc29uZWQgcGFnZXMg
aXMgd2hhdCB0aGlzIHBhdGNoc2V0IHRyaWVzIHRvIGNoYW5nZS9pbXByb3ZlLg0KDQpUaGFua3Ms
DQpOYW95YSBIb3JpZ3VjaGk=


