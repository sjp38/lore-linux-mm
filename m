Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD92AC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:17:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EC8521479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:17:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EC8521479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B9C16B0003; Mon, 20 May 2019 18:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46B036B0005; Mon, 20 May 2019 18:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 380DD6B0006; Mon, 20 May 2019 18:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 00B356B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 18:17:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o12so9941342pll.17
        for <linux-mm@kvack.org>; Mon, 20 May 2019 15:17:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=u9QDUc6HihL3wG62Y5BkY6u4n7G4tg7Ilo681OXyOYM=;
        b=Jd/6hsAX18TjP5M0xzJ6tKpO/QZxgTQtJ9D9ykH2ZhFyLtxFisvU1a4QA/nBwhp5uS
         2Xbh7m+AIJyNLAlKUQESpNBviEOrDD7ZR3s/shjy5QIPXplYU4dub1j+xAAPohxpufyC
         ZYPZfs9j6gDMzl+daguYvzHq8Ru0O5L/QmiOVsNZg3hvXTq3zY+J+8chQXiUovmZ0POP
         nF6Xoridw2tfIN7mDzqCx62MXVPCrU+oikQKq1IybRP2U/mNzTDTRYdPL702KrT0Folo
         nyGUdz/AX6zR8KEmxWICzy81RHV4eBYpjKPOxhoYSURbNVey5r9W9OGMzcXk9E2OeEXq
         ZLyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVwAcxv7+U22miMIahYEpqNgw2zcML6kIO5Z4Uz4Lx55FIaJ9Ls
	IaySZ65h4HBRroEY/vmCWvu3+qdUZ2fgWzYRJDyqztSpsznDbpYyDNlv4l+leb7i7VueyMTpYrK
	ilg7AwT1onugQgwikswpjpVnmbQPTmhekOdEuFUEsuyOS7BKjbzRmGfn4AMfoui4yQQ==
X-Received: by 2002:a17:902:7044:: with SMTP id h4mr17602548plt.219.1558390672540;
        Mon, 20 May 2019 15:17:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOYhOmG1Bm5Gb/BNpqljUbIdwLZI3LrtqoAUfXS+KuV8uuWTaL9+XFCVBdYqIMTzutO/U0
X-Received: by 2002:a17:902:7044:: with SMTP id h4mr17602489plt.219.1558390671790;
        Mon, 20 May 2019 15:17:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558390671; cv=none;
        d=google.com; s=arc-20160816;
        b=PmqOip0awFCIVXbuW8Xl6gsJkZu5VEunqlMzjU3nQLqcKwzNboyIl7qHxouOJLGmnZ
         KaOexebWDb4HLEgrnI4x2Qam2xIVYSCx+GNYwZmjpQ+iqu9dhT4ioupmBqIsBao68Zeb
         bzZuX+/rljrJTB3pECPyttUqLO3JcIULbf7937YqvrPEOiBsQsLUJz7OJBTPBbBBG4nt
         cKy3j9Hbmg6E1EV/kz1dmYuFQ1GEdj9u+AUGSnFUib9S8xtbJz4xu88Wa8Cgkml7bYwO
         j8qY1WOKyt5X+nFKUi+cnTCrdtYtueRj9APSe19AqqiYGhqcleq4yQ4Mv65nvzy3YoxX
         Mh8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=u9QDUc6HihL3wG62Y5BkY6u4n7G4tg7Ilo681OXyOYM=;
        b=DAttXv/RIbTg8yd9BEI8kMKx/1kSDd6d8uHRAYwlIv1xfH0qEtUXlauS5tjfGlB+eh
         YRnFme9IVIE6v40oG+AS4xu4L1J75y2N84jy8WUDSd5EXGKzLRaMJME51qEHLhEr+0Rk
         fox3Cr8g5wka9ejEkgNMXeHTZ9k1ziOk9GgRD2hcrnbleqHB9HHP7j/SDDdhj5ov1zV9
         6/CODMMC/450CCVxJ+pT3zOjvZ7qO2xWydzWdU+O7wHozaJMA439HARPm4g3c+MUe6mW
         FDpgrkKYQguqnMI25K8YJPNnovlWlEfuP8Jmczuto37dKmslZWzL6Sgqf22wHVM/eHDJ
         l5tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i23si1117238pgh.26.2019.05.20.15.17.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 15:17:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 15:17:49 -0700
X-ExtLoop1: 1
Received: from orsmsx102.amr.corp.intel.com ([10.22.225.129])
  by fmsmga006.fm.intel.com with ESMTP; 20 May 2019 15:17:50 -0700
Received: from orsmsx154.amr.corp.intel.com (10.22.226.12) by
 ORSMSX102.amr.corp.intel.com (10.22.225.129) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 20 May 2019 15:17:49 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX154.amr.corp.intel.com ([169.254.11.101]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 15:17:49 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "peterz@infradead.org"
	<peterz@infradead.org>, "mroos@linux.ee" <mroos@linux.ee>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
CC: "bp@alien8.de" <bp@alien8.de>, "davem@davemloft.net"
	<davem@davemloft.net>, "luto@kernel.org" <luto@kernel.org>,
	"mingo@redhat.com" <mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>,
	"Hansen, Dave" <dave.hansen@intel.com>
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH v2] vmalloc: Fix issues with flush flag
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwA=
Date: Mon, 20 May 2019 22:17:49 +0000
Message-ID: <c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
References: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
	 <90f8a4e1-aa71-0c10-1a91-495ba0cb329b@linux.ee>
In-Reply-To: <90f8a4e1-aa71-0c10-1a91-495ba0cb329b@linux.ee>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <2752FAF46305AF449FC03AABF0EBFDE7@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCAyMDE5LTA1LTIxIGF0IDAwOjM2ICswMzAwLCBNZWVsaXMgUm9vcyB3cm90ZToNCj4g
PiBTd2l0Y2ggVk1fRkxVU0hfUkVTRVRfUEVSTVMgdG8gdXNlIGEgcmVndWxhciBUTEIgZmx1c2gg
aW50ZWFkIG9mDQo+ID4gdm1fdW5tYXBfYWxpYXNlcygpIGFuZCBmaXggY2FsY3VsYXRpb24gb2Yg
dGhlIGRpcmVjdCBtYXAgZm9yIHRoZQ0KPiA+IENPTkZJR19BUkNIX0hBU19TRVRfRElSRUNUX01B
UCBjYXNlLg0KPiA+IA0KPiA+IE1lZWxpcyBSb29zIHJlcG9ydGVkIGlzc3VlcyB3aXRoIHRoZSBu
ZXcgVk1fRkxVU0hfUkVTRVRfUEVSTVMgZmxhZw0KPiA+IG9uIGENCj4gPiBzcGFyYyBtYWNoaW5l
LiBPbiBpbnZlc3RpZ2F0aW9uIHNvbWUgaXNzdWVzIHdlcmUgbm90aWNlZDoNCj4gPiANCj4gPiAx
LiBUaGUgY2FsY3VsYXRpb24gb2YgdGhlIGRpcmVjdCBtYXAgYWRkcmVzcyByYW5nZSB0byBmbHVz
aCB3YXMNCj4gPiB3cm9uZy4NCj4gPiBUaGlzIGNvdWxkIGNhdXNlIHByb2JsZW1zIG9uIHg4NiBp
ZiBhIFJPIGRpcmVjdCBtYXAgYWxpYXMgZXZlciBnb3QNCj4gPiBsb2FkZWQNCj4gPiBpbnRvIHRo
ZSBUTEIuIFRoaXMgc2hvdWxkbid0IG5vcm1hbGx5IGhhcHBlbiwgYnV0IGl0IGNvdWxkIGNhdXNl
DQo+ID4gdGhlDQo+ID4gcGVybWlzc2lvbnMgdG8gcmVtYWluIFJPIG9uIHRoZSBkaXJlY3QgbWFw
IGFsaWFzLCBhbmQgdGhlbiB0aGUgcGFnZQ0KPiA+IHdvdWxkIHJldHVybiBmcm9tIHRoZSBwYWdl
IGFsbG9jYXRvciB0byBzb21lIG90aGVyIGNvbXBvbmVudCBhcyBSTw0KPiA+IGFuZA0KPiA+IGNh
dXNlIGEgY3Jhc2guDQo+ID4gDQo+ID4gMi4gQ2FsbGluZyB2bV91bm1hcF9hbGlhcygpIG9uIHZm
cmVlIGNvdWxkIHBvdGVudGlhbGx5IGJlIGEgbG90IG9mDQo+ID4gd29yayB0bw0KPiA+IGRvIG9u
IGEgZnJlZSBvcGVyYXRpb24uIFNpbXBseSBmbHVzaGluZyB0aGUgVExCIGluc3RlYWQgb2YgdGhl
DQo+ID4gd2hvbGUNCj4gPiB2bV91bm1hcF9hbGlhcygpIG9wZXJhdGlvbiBtYWtlcyB0aGUgZnJl
ZXMgZmFzdGVyIGFuZCBwdXNoZXMgdGhlDQo+ID4gaGVhdnkNCj4gPiB3b3JrIHRvIGhhcHBlbiBv
biBhbGxvY2F0aW9uIHdoZXJlIGl0IHdvdWxkIGJlIG1vcmUgZXhwZWN0ZWQuDQo+ID4gSW4gYWRk
aXRpb24gdG8gdGhlIGV4dHJhIHdvcmssIHZtX3VubWFwX2FsaWFzKCkgdGFrZXMgc29tZSBsb2Nr
cw0KPiA+IGluY2x1ZGluZw0KPiA+IGEgbG9uZyBob2xkIG9mIHZtYXBfcHVyZ2VfbG9jaywgd2hp
Y2ggd2lsbCBtYWtlIGFsbCBvdGhlcg0KPiA+IFZNX0ZMVVNIX1JFU0VUX1BFUk1TIHZmcmVlcyB3
YWl0IHdoaWxlIHRoZSBwdXJnZSBvcGVyYXRpb24gaGFwcGVucy4NCj4gPiANCj4gPiAzLiBwYWdl
X2FkZHJlc3MoKSBjYW4gaGF2ZSBsb2NraW5nIG9uIHNvbWUgY29uZmlndXJhdGlvbnMsIHNvIHNr
aXANCj4gPiBjYWxsaW5nDQo+ID4gdGhpcyB3aGVuIHBvc3NpYmxlIHRvIGZ1cnRoZXIgc3BlZWQg
dGhpcyB1cC4NCj4gPiANCj4gPiBGaXhlczogODY4YjEwNGQ3Mzc5ICgibW0vdm1hbGxvYzogQWRk
IGZsYWcgZm9yIGZyZWVpbmcgb2Ygc3BlY2lhbA0KPiA+IHBlcm1zaXNzaW9ucyIpDQo+ID4gUmVw
b3J0ZWQtYnk6IE1lZWxpcyBSb29zPG1yb29zQGxpbnV4LmVlPg0KPiA+IENjOiBNZWVsaXMgUm9v
czxtcm9vc0BsaW51eC5lZT4NCj4gPiBDYzogUGV0ZXIgWmlqbHN0cmE8cGV0ZXJ6QGluZnJhZGVh
ZC5vcmc+DQo+ID4gQ2M6ICJEYXZpZCBTLiBNaWxsZXIiPGRhdmVtQGRhdmVtbG9mdC5uZXQ+DQo+
ID4gQ2M6IERhdmUgSGFuc2VuPGRhdmUuaGFuc2VuQGludGVsLmNvbT4NCj4gPiBDYzogQm9yaXNs
YXYgUGV0a292PGJwQGFsaWVuOC5kZT4NCj4gPiBDYzogQW5keSBMdXRvbWlyc2tpPGx1dG9Aa2Vy
bmVsLm9yZz4NCj4gPiBDYzogSW5nbyBNb2xuYXI8bWluZ29AcmVkaGF0LmNvbT4NCj4gPiBDYzog
TmFkYXYgQW1pdDxuYW1pdEB2bXdhcmUuY29tPg0KPiA+IFNpZ25lZC1vZmYtYnk6IFJpY2sgRWRn
ZWNvbWJlPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0KPiA+IC0tLQ0KPiA+IA0KPiA+IENo
YW5nZXMgc2luY2UgdjE6DQo+ID4gICAtIFVwZGF0ZSBjb21taXQgbWVzc2FnZSB3aXRoIG1vcmUg
ZGV0YWlsDQo+ID4gICAtIEZpeCBmbHVzaCBlbmQgcmFuZ2Ugb24gIUNPTkZJR19BUkNIX0hBU19T
RVRfRElSRUNUX01BUCBjYXNlDQo+IA0KPiBJdCBkb2VzIG5vdCB3b3JrIG9uIG15IFY0NDUgd2hl
cmUgdGhlIGluaXRpYWwgcHJvYmxlbSBoYXBwZW5lZC4NCj4gDQpUaGFua3MgZm9yIHRlc3Rpbmcu
IFNvIEkgZ3Vlc3MgdGhhdCBzdWdnZXN0cyBpdCdzIHRoZSBUTEIgZmx1c2ggY2F1c2luZw0KdGhl
IHByb2JsZW0gb24gc3BhcmMgYW5kIG5vdCBhbnkgbGF6eSBwdXJnZSBkZWFkbG9jay4gSSBoYWQg
c2VudCBNZWVsaXMNCmFub3RoZXIgdGVzdCBwYXRjaCB0aGF0IGp1c3QgZmx1c2hlZCB0aGUgZW50
aXJlIDAgdG8gVUxPTkdfTUFYIHJhbmdlIHRvDQp0cnkgdG8gYWx3YXlzIHRoZSBnZXQgdGhlICJm
bHVzaCBhbGwiIGxvZ2ljIGFuZCBhcHByZW50bHkgaXQgZGlkbid0DQpib290IG1vc3RseSBlaXRo
ZXIuIEl0IGFsc28gc2hvd2VkIHRoYXQgaXQncyBub3QgZ2V0dGluZyBzdHVjayBhbnl3aGVyZQ0K
aW4gdGhlIHZtX3JlbW92ZV9hbGlhcygpIGZ1bmN0aW9uLiBTb21ldGhpbmcganVzdCBoYW5ncyBs
YXRlci4NCg0KDQo=

