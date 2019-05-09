Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D382AC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:21:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7298F21744
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:21:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="BayIfWjW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7298F21744
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F26A6B0007; Thu,  9 May 2019 17:21:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07C726B0008; Thu,  9 May 2019 17:21:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E85B86B000A; Thu,  9 May 2019 17:21:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92CC26B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 17:21:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c26so2440611eda.15
        for <linux-mm@kvack.org>; Thu, 09 May 2019 14:21:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=3uR7HRLZE1AAqz9VCIR4SL1BD4Igne+yoNtHXMu3t6s=;
        b=lKdQMgIKYnW0Wi6QZu7bB1xaOg3s1TkLKHyh+fiRRypBUi27vdloZMFtwC+L6eTtto
         S1lNvvKG8raXh7oObAkD7FIHgeH+NoCyYEM9bI2nhtN8NioyD96NhlgaXqk7w9wJiTaG
         VfN9xFlwwIamLebWE0T7/SOG5gYStJs8wsQ/faZkMxo5lYs+OBejEVFyTRkeoiG9LgLg
         Dc0BI7Su0DsOXWCu0MkMg7sV7i7QpLCHrzTfq5GjIYgmwaEAzd6Uhjag1ICJYic76BeK
         W1v64jBEuzb2jxF3bArEL5r6JTdr+DvqFvHSbe9ZdsHKwQArhmSBzgv6aGEkbaSEOiAw
         eInA==
X-Gm-Message-State: APjAAAX2B0JCG5GnOlb4KojPKoaKczts8Js6aNSDTC3bzd5yDS197Euk
	yvAbFv/v8D4d1Q92zC5aArNveWTI1uJsjtyKQN5h23BIVJtY+zVQGla5F/TFVQCe+WNjcNZ85kc
	Zr/Uo+GekzP1tMq5b0MRSTbhgi165ws+GUhirEi9OTInw0gdmltZOYN/vkNj+MYUoiQ==
X-Received: by 2002:a50:b1e3:: with SMTP id n32mr6549434edd.55.1557436901076;
        Thu, 09 May 2019 14:21:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiJuSF6npDyNO5J+/Wr8T15445SAyoJP9eAVCfee1J5mKftuXr6OWhswfEIAc/cgB7RQTn
X-Received: by 2002:a50:b1e3:: with SMTP id n32mr6549368edd.55.1557436900204;
        Thu, 09 May 2019 14:21:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557436900; cv=none;
        d=google.com; s=arc-20160816;
        b=ymA2I1/0D/DswxZZ0l5DaQeEy70WwjBPbfA31FqjTAN/459k/PfxAK65wFG1S2Z+Mi
         1aCMx8yGRrBCHCG4/wCMTV0MthIz2iAzROeKdWOOx+7Ok0+P6LhMpZc2Ug50uvC5oGZW
         iwKUvoZWpt1BICmcHUtnKC1ClWcHTKpaScQRDH4qilnCZLvYJEISu8/cmym1IKPoMlhH
         OJYWQhgqx2IpF4XOmvXZD+nkrbe70F9K0BlzR+Vil3EMMmumbKjBtpP/acxJ5HhHVtmn
         b7Nqsp2ezMdUp1yh4tLYEnlX/mFGNCaa6mDlwKD0lEDHvwube/QXTuBRrmoJxLOWoS2d
         v8iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=3uR7HRLZE1AAqz9VCIR4SL1BD4Igne+yoNtHXMu3t6s=;
        b=fjNztENsqy5N6brloEjat3ZPa9e23BmrOP/Z549jo6UlF2gIycQWAyR1eP1eKzPcpr
         TJS7ix2GediD3TOFf4il4xdaSRteAyS4gZuBXgwrYqU4cLCQ9FoMWC9mkE97vXVbyk0s
         xRr7uxpiP5qfVZ52Yncgq1gMb8xwEkB4ScFr+QH84tFBFwcyz7RbDLJRGKVFFTr2w6ID
         B0bzTM7p46FtCHZGXAEgkxtNRwFX1DQMjfmY7iuTiOnwGtfJfcK6K7yzQ0v+GiWPcyqp
         qQYabSEUC8rbU+3hrCx+8MwMiFIKInkyiJGPVdW17M29Kku3oHal8QiRZKi50OqSxwCH
         vMJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=BayIfWjW;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.51 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800051.outbound.protection.outlook.com. [40.107.80.51])
        by mx.google.com with ESMTPS id 56si2439968edu.170.2019.05.09.14.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 May 2019 14:21:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.80.51 as permitted sender) client-ip=40.107.80.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=BayIfWjW;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.51 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3uR7HRLZE1AAqz9VCIR4SL1BD4Igne+yoNtHXMu3t6s=;
 b=BayIfWjWGds+5ehDm+E3QNBMjkoaLsMHNzXjge6At0s+vUIcal9XTbXvJVxKZsxoLn4qGeN6WasRDP8O6kFQhWJO+sw09RKDaLE253t28XDUxEORMnpyENsNkvfydpQRFsYjwzaFy1evLFqyPanXXMeK81WaRTiu9TXBGOpeCeU=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4711.namprd05.prod.outlook.com (52.135.233.89) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.17; Thu, 9 May 2019 21:21:35 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1900.006; Thu, 9 May 2019
 21:21:35 +0000
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
CC: Yang Shi <yang.shi@linux.alibaba.com>, "jstancek@redhat.com"
	<jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Aneesh Kumar K .
 V" <aneesh.kumar@linux.vnet.ibm.com>, Nick Piggin <npiggin@gmail.com>, Nadav
 Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman
	<mgorman@suse.de>, Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Topic: [PATCH] mm: mmu_gather: remove __tlb_reset_range() for force
 flush
Thread-Index: AQHVBlNcdgyGQHvMg0ymTH6Y7O8srKZjDs8AgAANcoCAAAcZgIAABfcAgAAkYwA=
Date: Thu, 9 May 2019 21:21:35 +0000
Message-ID: <7DA60772-3EE3-4882-B26F-2A900690DA15@vmware.com>
References: <1557264889-109594-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190509083726.GA2209@brain-police>
 <20190509103813.GP2589@hirez.programming.kicks-ass.net>
 <F22533A7-016F-4506-809A-7E86BAF24D5A@vmware.com>
 <20190509182435.GA2623@hirez.programming.kicks-ass.net>
 <04668E51-FD87-4D53-A066-5A35ABC3A0D6@vmware.com>
 <20190509191120.GD2623@hirez.programming.kicks-ass.net>
In-Reply-To: <20190509191120.GD2623@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2810e6c4-675e-4fc1-1aa3-08d6d4c450db
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB4711;
x-ms-traffictypediagnostic: BYAPR05MB4711:
x-microsoft-antispam-prvs:
 <BYAPR05MB471114BC0825CCAB9BBD74BFD0330@BYAPR05MB4711.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 003245E729
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(396003)(366004)(376002)(346002)(51444003)(199004)(189003)(6916009)(2906002)(81166006)(81156014)(6512007)(82746002)(4326008)(8936002)(53936002)(478600001)(7416002)(6246003)(83716004)(7736002)(6436002)(305945005)(54906003)(6486002)(68736007)(229853002)(14454004)(14444005)(256004)(8676002)(6116002)(3846002)(33656002)(6506007)(102836004)(86362001)(25786009)(2616005)(316002)(476003)(66066001)(11346002)(486006)(53546011)(99286004)(36756003)(5660300002)(446003)(186003)(76176011)(66446008)(76116006)(73956011)(66946007)(26005)(66476007)(66556008)(64756008)(71190400001)(71200400001);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4711;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 c3R+O4MqUzDTikTMFffNmxOnPyDUZBlAn0A1vCHn35I1/OKLr9Wl3n+58PzRQUdQOwVmWrQReUS9j551U1BPA1tOWKszTSLbaoAahzoKBQjj2AJxhMxW2vi4CXi8d/uT6FmSdl3UohBfcFYE8C7lKnZDIh6pbpK5mh9FZSAcu8iOZ/2YU+EDrnWVKxpR83px8YXxzWa3pzKfMmhH+n/hTQnKSis5PoLD6WAAJlymiwTx/OhfFlLaB/GDaeLANg2dj4kmJE+yBCL+/MFa+JkJFlSwPKOfBUidU9rdSL405hFue5j5bqXS+TtUk8LUwqVUI1KmH2mPYKqOq/21nT2D1MlYjvsWFzZYWrVlnbebVIROgVk6wJfGLqFtni0rG4qse+f+BDMO6CzV9yQ++QvorbRKqGBNVGnCqTlVgRN+Bzg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <37B461CEAAF13447B2A08CEACA55FAE5@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2810e6c4-675e-4fc1-1aa3-08d6d4c450db
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 May 2019 21:21:35.3619
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4711
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

WyBSZXN0b3JpbmcgdGhlIHJlY2lwaWVudHMgYWZ0ZXIgbWlzdGFrZW5seSBwcmVzc2luZyByZXBs
eSBpbnN0ZWFkIG9mDQpyZXBseS1hbGwgXQ0KDQo+IE9uIE1heSA5LCAyMDE5LCBhdCAxMjoxMSBQ
TSwgUGV0ZXIgWmlqbHN0cmEgPHBldGVyekBpbmZyYWRlYWQub3JnPiB3cm90ZToNCj4gDQo+IE9u
IFRodSwgTWF5IDA5LCAyMDE5IGF0IDA2OjUwOjAwUE0gKzAwMDAsIE5hZGF2IEFtaXQgd3JvdGU6
DQo+Pj4gT24gTWF5IDksIDIwMTksIGF0IDExOjI0IEFNLCBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6
QGluZnJhZGVhZC5vcmc+IHdyb3RlOg0KPj4+IA0KPj4+IE9uIFRodSwgTWF5IDA5LCAyMDE5IGF0
IDA1OjM2OjI5UE0gKzAwMDAsIE5hZGF2IEFtaXQgd3JvdGU6DQo+IA0KPj4+PiBBcyBhIHNpbXBs
ZSBvcHRpbWl6YXRpb24sIEkgdGhpbmsgaXQgaXMgcG9zc2libGUgdG8gaG9sZCBtdWx0aXBsZSBu
ZXN0aW5nDQo+Pj4+IGNvdW50ZXJzIGluIHRoZSBtbSwgc2ltaWxhciB0byB0bGJfZmx1c2hfcGVu
ZGluZywgZm9yIGZyZWVkX3RhYmxlcywNCj4+Pj4gY2xlYXJlZF9wdGVzLCBldGMuDQo+Pj4+IA0K
Pj4+PiBUaGUgZmlyc3QgdGltZSB5b3Ugc2V0IHRsYi0+ZnJlZWRfdGFibGVzLCB5b3UgYWxzbyBh
dG9taWNhbGx5IGluY3JlYXNlDQo+Pj4+IG1tLT50bGJfZmx1c2hfZnJlZWRfdGFibGVzLiBUaGVu
LCBpbiB0bGJfZmx1c2hfbW11KCksIHlvdSBqdXN0IHVzZQ0KPj4+PiBtbS0+dGxiX2ZsdXNoX2Zy
ZWVkX3RhYmxlcyBpbnN0ZWFkIG9mIHRsYi0+ZnJlZWRfdGFibGVzLg0KPj4+IA0KPj4+IFRoYXQg
c291bmRzIGZyYXVnaHQgd2l0aCByYWNlcyBhbmQgZXhwZW5zaXZlOyBJIHdvdWxkIG11Y2ggcHJl
ZmVyIHRvIG5vdA0KPj4+IGdvIHRoZXJlIGZvciB0aGlzIGFyZ3VhYmx5IHJhcmUgY2FzZS4NCj4+
PiANCj4+PiBDb25zaWRlciBzdWNoIGZ1biBjYXNlcyBhcyB3aGVyZSBDUFUtMCBzZWVzIGFuZCBj
bGVhcnMgYSBQVEUsIENQVS0xDQo+Pj4gcmFjZXMgYW5kIGRvZXNuJ3Qgc2VlIHRoYXQgUFRFLiBU
aGVyZWZvcmUgQ1BVLTAgc2V0cyBhbmQgY291bnRzDQo+Pj4gY2xlYXJlZF9wdGVzLiBUaGVuIGlm
IENQVS0xIGZsdXNoZXMgd2hpbGUgQ1BVLTAgaXMgc3RpbGwgaW4gbW11X2dhdGhlciwNCj4+PiBp
dCB3aWxsIHNlZSBjbGVhcmVkX3B0ZXMgY291bnQgaW5jcmVhc2VkIGFuZCBmbHVzaCB0aGF0IGdy
YW51bGFyaXR5LA0KPj4+IE9UT0ggaWYgQ1BVLTEgZmx1c2hlcyBhZnRlciBDUFUtMCBjb21wbGV0
ZXMsIGl0IHdpbGwgbm90IGFuZCBwb3RlbnRpYWxsDQo+Pj4gbWlzcyBhbiBpbnZhbGlkYXRlIGl0
IHNob3VsZCBoYXZlIGhhZC4NCj4+IA0KPj4gQ1BVLTAgd291bGQgc2VuZCBhIFRMQiBzaG9vdGRv
d24gcmVxdWVzdCB0byBDUFUtMSB3aGVuIGl0IGlzIGRvbmUsIHNvIEkNCj4+IGRvbuKAmXQgc2Vl
IHRoZSBwcm9ibGVtLiBUaGUgVExCIHNob290ZG93biBtZWNoYW5pc20gaXMgaW5kZXBlbmRlbnQg
b2YgdGhlDQo+PiBtbXVfZ2F0aGVyIGZvciB0aGUgbWF0dGVyLg0KPiANCj4gRHVoLi4gSSBzdGls
bCBkb24ndCBsaWtlIHRob3NlIHVuY29uZGl0aW9uYWwgbW0gd2lkZSBhdG9taWMgY291bnRlcnMu
DQo+IA0KPj4+IFRoaXMgd2hvbGUgY29uY3VycmVudCBtbXVfZ2F0aGVyIHN0dWZmIGlzIGhvcnJp
YmxlLg0KPj4+IA0KPj4+IC9tZSBwb25kZXJzIG1vcmUuLi4uDQo+Pj4gDQo+Pj4gU28gSSB0aGlu
ayB0aGUgZnVuZGFtZW50YWwgcmFjZSBoZXJlIGlzIHRoaXM6DQo+Pj4gDQo+Pj4gCUNQVS0wCQkJ
CUNQVS0xDQo+Pj4gDQo+Pj4gCXRsYl9nYXRoZXJfbW11KC5zdGFydD0xLAl0bGJfZ2F0aGVyX21t
dSguc3RhcnQ9MiwNCj4+PiAJCSAgICAgICAuZW5kPTMpOwkJCSAgICAgICAuZW5kPTQpOw0KPj4+
IA0KPj4+IAlwdGVwX2dldF9hbmRfY2xlYXJfZnVsbCgyKQ0KPj4+IAl0bGJfcmVtb3ZlX3RsYl9l
bnRyeSgyKTsNCj4+PiAJX190bGJfcmVtb3ZlX3BhZ2UoKTsNCj4+PiAJCQkJCWlmIChwdGVfcHJl
c2VudCgyKSkgLy8gbm9wZQ0KPj4+IA0KPj4+IAkJCQkJdGxiX2ZpbmlzaF9tbXUoKTsNCj4+PiAN
Cj4+PiAJCQkJCS8vIGNvbnRpbnVlIHdpdGhvdXQgVExCSSgyKQ0KPj4+IAkJCQkJLy8gd2hvb3Bz
aWUNCj4+PiANCj4+PiAJdGxiX2ZpbmlzaF9tbXUoKTsNCj4+PiAJICB0bGJfZmx1c2goKQkJLT4J
VExCSSgyKQ0KPj4+IA0KPj4+IA0KPj4+IEFuZCB3ZSBjYW4gZml4IHRoYXQgYnkgaGF2aW5nIHRs
Yl9maW5pc2hfbW11KCkgc3luYyB1cC4gTmV2ZXIgbGV0IGENCj4+PiBjb25jdXJyZW50IHRsYl9m
aW5pc2hfbW11KCkgY29tcGxldGUgdW50aWwgYWxsIGNvbmN1cnJlbmN0IG1tdV9nYXRoZXJzDQo+
Pj4gaGF2ZSBjb21wbGV0ZWQuDQo+Pj4gDQo+Pj4gVGhpcyBzaG91bGQgbm90IGJlIHRvbyBoYXJk
IHRvIG1ha2UgaGFwcGVuLg0KPj4gDQo+PiBUaGlzIHN5bmNocm9uaXphdGlvbiBzb3VuZHMgbXVj
aCBtb3JlIGV4cGVuc2l2ZSB0aGFuIHdoYXQgSSBwcm9wb3NlZC4gQnV0IEkNCj4+IGFncmVlIHRo
YXQgY2FjaGUtbGluZXMgdGhhdCBtb3ZlIGZyb20gb25lIENQVSB0byBhbm90aGVyIG1pZ2h0IGJl
Y29tZSBhbg0KPj4gaXNzdWUuIEJ1dCBJIHRoaW5rIHRoYXQgdGhlIHNjaGVtZSBJIHN1Z2dlc3Rl
ZCB3b3VsZCBtaW5pbWl6ZSB0aGlzIG92ZXJoZWFkLg0KPiANCj4gV2VsbCwgaXQgd291bGQgaGF2
ZSBhIGxvdCBtb3JlIHVuY29uZGl0aW9uYWwgYXRvbWljIG9wcy4gTXkgc2NoZW1lIG9ubHkNCj4g
d2FpdHMgd2hlbiB0aGVyZSBpcyBhY3R1YWwgY29uY3VycmVuY3kuDQoNCldlbGwsIHNvbWV0aGlu
ZyBoYXMgdG8gZ2l2ZS4gSSBkaWRu4oCZdCB0aGluayB0aGF0IGlmIHRoZSBzYW1lIGNvcmUgZG9l
cyB0aGUNCmF0b21pYyBvcCBpdCB3b3VsZCBiZSB0b28gZXhwZW5zaXZlLg0KDQo+IEkgX3RoaW5r
XyBzb21ldGhpbmcgbGlrZSB0aGUgYmVsb3cgb3VnaHQgdG8gd29yaywgYnV0IGl0cyBub3QgZXZl
biBiZWVuDQo+IG5lYXIgYSBjb21waWxlci4gVGhlIG9ubHkgcHJvYmxlbSBpcyB0aGUgdW5jb25k
aXRpb25hbCB3YWtldXA7IHdlIGNhbg0KPiBwbGF5IGdhbWVzIHRvIGF2b2lkIHRoYXQgaWYgd2Ug
d2FudCB0byBjb250aW51ZSB3aXRoIHRoaXMuDQo+IA0KPiBJZGVhbGx5IHdlJ2Qgb25seSBkbyB0
aGlzIHdoZW4gdGhlcmUncyBiZWVuIGFjdHVhbCBvdmVybGFwLCBidXQgSSd2ZSBub3QNCj4gZm91
bmQgYSBzZW5zaWJsZSB3YXkgdG8gZGV0ZWN0IHRoYXQuDQo+IA0KPiBkaWZmIC0tZ2l0IGEvaW5j
bHVkZS9saW51eC9tbV90eXBlcy5oIGIvaW5jbHVkZS9saW51eC9tbV90eXBlcy5oDQo+IGluZGV4
IDRlZjRiYmU3OGExZC4uYjcwZTM1NzkyZDI5IDEwMDY0NA0KPiAtLS0gYS9pbmNsdWRlL2xpbnV4
L21tX3R5cGVzLmgNCj4gKysrIGIvaW5jbHVkZS9saW51eC9tbV90eXBlcy5oDQo+IEBAIC01OTAs
NyArNTkwLDEyIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCBkZWNfdGxiX2ZsdXNoX3BlbmRpbmcoc3Ry
dWN0IG1tX3N0cnVjdCAqbW0pDQo+IAkgKg0KPiAJICogVGhlcmVmb3JlIHdlIG11c3QgcmVseSBv
biB0bGJfZmx1c2hfKigpIHRvIGd1YXJhbnRlZSBvcmRlci4NCj4gCSAqLw0KPiAtCWF0b21pY19k
ZWMoJm1tLT50bGJfZmx1c2hfcGVuZGluZyk7DQo+ICsJaWYgKGF0b21pY19kZWNfYW5kX3Rlc3Qo
Jm1tLT50bGJfZmx1c2hfcGVuZGluZykpIHsNCj4gKwkJd2FrZV91cF92YXIoJm1tLT50bGJfZmx1
c2hfcGVuZGluZyk7DQo+ICsJfSBlbHNlIHsNCj4gKwkJd2FpdF9ldmVudF92YXIoJm1tLT50bGJf
Zmx1c2hfcGVuZGluZywNCj4gKwkJCSAgICAgICAhYXRvbWljX3JlYWRfYWNxdWlyZSgmbW0tPnRs
Yl9mbHVzaF9wZW5kaW5nKSk7DQo+ICsJfQ0KPiB9DQoNCkl0IHN0aWxsIHNlZW1zIHZlcnkgZXhw
ZW5zaXZlIHRvIG1lLCBhdCBsZWFzdCBmb3IgY2VydGFpbiB3b3JrbG9hZHMgKGUuZy4sDQpBcGFj
aGUgd2l0aCBtdWx0aXRocmVhZGVkIE1QTSkuDQoNCkl0IG1heSBiZSBwb3NzaWJsZSB0byBhdm9p
ZCBmYWxzZS1wb3NpdGl2ZSBuZXN0aW5nIGluZGljYXRpb25zICh3aGVuIHRoZQ0KZmx1c2hlcyBk
byBub3Qgb3ZlcmxhcCkgYnkgY3JlYXRpbmcgYSBuZXcgc3RydWN0IG1tdV9nYXRoZXJfcGVuZGlu
Zywgd2l0aA0Kc29tZXRoaW5nIGxpa2U6DQoNCiAgc3RydWN0IG1tdV9nYXRoZXJfcGVuZGluZyB7
DQogCXU2NCBzdGFydDsNCgl1NjQgZW5kOw0KCXN0cnVjdCBtbXVfZ2F0aGVyX3BlbmRpbmcgKm5l
eHQ7DQogIH0NCg0KdGxiX2ZpbmlzaF9tbXUoKSB3b3VsZCB0aGVuIGl0ZXJhdGUgb3ZlciB0aGUg
bW0tPm1tdV9nYXRoZXJfcGVuZGluZw0KKHBvaW50aW5nIHRvIHRoZSBsaW5rZWQgbGlzdCkgYW5k
IGZpbmQgd2hldGhlciB0aGVyZSBpcyBhbnkgb3ZlcmxhcC4gVGhpcw0Kd291bGQgc3RpbGwgcmVx
dWlyZSBzeW5jaHJvbml6YXRpb24gKGFjcXVpcmluZyBhIGxvY2sgd2hlbiBhbGxvY2F0aW5nIGFu
ZA0KZGVhbGxvY2F0aW5nIG9yIHNvbWV0aGluZyBmYW5jaWVyKS4NCg0K

