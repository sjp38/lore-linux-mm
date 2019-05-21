Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25332C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0FA0213F2
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 00:20:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0FA0213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 745036B0003; Mon, 20 May 2019 20:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F5716B0005; Mon, 20 May 2019 20:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4686B0006; Mon, 20 May 2019 20:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B2C26B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 20:20:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t16so10851280pgv.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 17:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=jqUmOX73jBKqUQXqrYMgeUIJyD2MAUJs0t1X1EVYNpg=;
        b=Xa6FScg0cV3nnq+OxJ5ZdCetwNcCJFE2ayc+6Wm6XuzCxpVav0G+f6TbXhOYltnk5Q
         aZxqVlk2jJHgTLsqV+Skh0QRZjekhzMT43zhz5GIXhXcFbptbBuUGWXwUjewpj011RIC
         pxnhCRnfkwJJK8u+Rwkb7qqvK1Qvcipb8Km4uf3M5iKlb50bFaZ/3t05POCAgD0vdZKE
         LW0aF2zWuRZ0UqW9ZH610A5F9ig6TGctmkZujWTS7/hFS3MHz3k1xMpCDMlxtR4dV3ye
         UHatRyjVaz42iD9EACojTofIG81XL2sHFD60Jsa1k219fFs1vkuKh9u9lZBGojcRztZ7
         g3CQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXafVhHoqTohU2so0Gel1qo3+pqNjdexg87MknrtdRhLi67yc1s
	ooXRqyfijuZZKxiiJFul1IpQmd9TtjdhwD+9cKR8VkIjTXHCcr1dtHUlDcxcXGiq14vxtzJb4vH
	cl2KLh7FHO/seHqoRe+DflLK6BgPmEAgrNoxnGMza4uQ05mMODHHSr6gBVXL5+9DUdw==
X-Received: by 2002:a63:40b:: with SMTP id 11mr62166904pge.31.1558398015826;
        Mon, 20 May 2019 17:20:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpoguRBq/4R0o/uVOhFmXy4h6vG/ikimx4aY+I1KsYgN6fBgCqnlnI5rHkY3GSeMziJlI7
X-Received: by 2002:a63:40b:: with SMTP id 11mr62166818pge.31.1558398014920;
        Mon, 20 May 2019 17:20:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558398014; cv=none;
        d=google.com; s=arc-20160816;
        b=sNGCeEGVU3uQbn2OCJUu/YgXuI58FSiXzbpELquvYOtkAATDrr+VytTaLmfsyKzkyA
         bBk7QjYQ6ZM37SShYGArR9yQkA+JhCxbLNpwurY48phrKE+ll65zpMhVr4xByVvU3AHL
         TxA32WLsHWqeuNgNxha7nuH7iewprgJ3JibeL6gcPSolTyMbGlo/AiXUDlSqKGJhedmW
         XGMnZ5rlhiuI4HBfmFARQzEBibBg0OWJSUihHZ4JMbgQdBbU+CR4tZC6I97F3DTkwohi
         2c+l5r/t3vIGNeUUVgXIZeX39z5uCI8wEC0EMxt/9oRP23qCY1FVM+AUrmbj+yP2vXiI
         xNRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=jqUmOX73jBKqUQXqrYMgeUIJyD2MAUJs0t1X1EVYNpg=;
        b=fRhWMkucHNQyZSZBkjm4Pfwa/DptJ5h8Q3Hn0dnJujrmtKGkMUE7ch+YMa3nBKLfOo
         c/ll8ujDXzyNlzqEUD2MSIzMsatgRsjXbXE0gj+/zZTK9C48bh8laUKySHHPdqKzE3WH
         eCGBk/XIh9Ad0BAOBxZ1XGK7hLA8KikciKSoqt+7LLeR/V/2/bMxsw84FSZ3BSKpLkEw
         GtTceGHhxfZhOcjwmBfzliLvE9qOf/vDGh4VLuPWRahh4zw1Bj2Zy5xZb2Lkau8UIxcZ
         RPuUYl3Cv9YpBx34tYr9RVbyFf6d32jjsFB0xaKhnaDmoQLFtLV6hcnfl6FBK3FWBPrB
         uFyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f7si18907968pgd.155.2019.05.20.17.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 17:20:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 17:20:13 -0700
X-ExtLoop1: 1
Received: from orsmsx106.amr.corp.intel.com ([10.22.225.133])
  by orsmga006.jf.intel.com with ESMTP; 20 May 2019 17:20:13 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX106.amr.corp.intel.com ([169.254.1.30]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 17:20:13 -0700
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
Thread-Index: AQHVD0ezpbXySuUS5EinefGl750kkaZ0/uwAgAALkwCAAAiygIAAGYEA
Date: Tue, 21 May 2019 00:20:13 +0000
Message-ID: <3e7e674c1fe094cd8dbe0c8933db18be1a37d76d.camel@intel.com>
References: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
	 <90f8a4e1-aa71-0c10-1a91-495ba0cb329b@linux.ee>
	 <c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
	 <20190520.154855.2207738976381931092.davem@davemloft.net>
In-Reply-To: <20190520.154855.2207738976381931092.davem@davemloft.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <52C20D2E84AF29499A3F743E3C4592D6@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA1LTIwIGF0IDE1OjQ4IC0wNzAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6DQo+
IEZyb206ICJFZGdlY29tYmUsIFJpY2sgUCIgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPg0K
PiBEYXRlOiBNb24sIDIwIE1heSAyMDE5IDIyOjE3OjQ5ICswMDAwDQo+IA0KPiA+IFRoYW5rcyBm
b3IgdGVzdGluZy4gU28gSSBndWVzcyB0aGF0IHN1Z2dlc3RzIGl0J3MgdGhlIFRMQiBmbHVzaA0K
PiA+IGNhdXNpbmcNCj4gPiB0aGUgcHJvYmxlbSBvbiBzcGFyYyBhbmQgbm90IGFueSBsYXp5IHB1
cmdlIGRlYWRsb2NrLiBJIGhhZCBzZW50DQo+ID4gTWVlbGlzDQo+ID4gYW5vdGhlciB0ZXN0IHBh
dGNoIHRoYXQganVzdCBmbHVzaGVkIHRoZSBlbnRpcmUgMCB0byBVTE9OR19NQVgNCj4gPiByYW5n
ZSB0bw0KPiA+IHRyeSB0byBhbHdheXMgdGhlIGdldCB0aGUgImZsdXNoIGFsbCIgbG9naWMgYW5k
IGFwcHJlbnRseSBpdCBkaWRuJ3QNCj4gPiBib290IG1vc3RseSBlaXRoZXIuIEl0IGFsc28gc2hv
d2VkIHRoYXQgaXQncyBub3QgZ2V0dGluZyBzdHVjaw0KPiA+IGFueXdoZXJlDQo+ID4gaW4gdGhl
IHZtX3JlbW92ZV9hbGlhcygpIGZ1bmN0aW9uLiBTb21ldGhpbmcganVzdCBoYW5ncyBsYXRlci4N
Cj4gDQo+IEkgd29uZGVyIGlmIGFuIGFkZHJlc3MgaXMgbWFraW5nIGl0IHRvIHRoZSBUTEIgZmx1
c2ggcm91dGluZXMgd2hpY2gNCj4gaXMNCj4gbm90IHBhZ2UgYWxpZ25lZC4NCkkgdGhpbmsgdm1h
bGxvYyBzaG91bGQgZm9yY2UgUEFHRV9TSVpFIGFsaWdubWVudCwgYnV0IHdpbGwgZG91YmxlIGNo
ZWNrDQpub3RoaW5nIGdvdCBzY3Jld2VkIHVwLg0KDQo+IE9yIGEgVExCIGZsdXNoIGlzIGJlaW5n
IGRvbmUgYmVmb3JlIHRoZSBjYWxsc2l0ZXMNCj4gYXJlIHBhdGNoZWQgcHJvcGVybHkgZm9yIHRo
ZSBnaXZlbiBjcHUgdHlwZS4NCkFueSBpZGVhIGhvdyBJIGNvdWxkIGxvZyB3aGVuIHRoaXMgaXMg
ZG9uZT8gSXQgbG9va3MgbGlrZSBpdCdzIGRvbmUNCnJlYWxseSBlYXJseSBpbiBib290IGFzc2Vt
Ymx5LiBUaGlzIGJlaGF2aW9yIHNob3VsZG4ndCBoYXBwZW4gdW50aWwNCm1vZHVsZXMgb3IgQlBG
IGFyZSBiZWluZyBmcmVlZC4NCg==

