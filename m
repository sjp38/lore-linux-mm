Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AD8EC169C4
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:43:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C928217F9
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:43:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="GEkdLvOc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C928217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200198E000C; Wed,  6 Feb 2019 19:43:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B0138E0002; Wed,  6 Feb 2019 19:43:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 076928E000C; Wed,  6 Feb 2019 19:43:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5C758E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 19:43:55 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o8so7830905otp.16
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 16:43:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=JRlu5tFyktvP98pq28nzFSuXxZEVrV369hALB61iwiU=;
        b=qv7ni7CiWs/zI/gt74wx0bCSlJ2zVh7NyIoDGwZz04aKECB28vmYmWm1s90/ysbSDf
         aIafU9dr7XGJGsdDFcOrRm4H4uOU1fpMkbiS9Y+LWfivcJbE9c1kwqAuwivUCtkC+gsh
         F9FAy3y3thTFCeXsspw0e6Ole0vYYVhcwNKCZoue2++s6zYOQ4bltVNtIno9CX+OMV8j
         cJDVkASP93Q+ex+yVKHxB7eOEzkWMgPsgzuC23WjcZEKVjRXo7hqUPZ+gxcrNoP+/L1i
         GvmxxJagfY8WiLQwMxgrgHWTMnAqhClL1zjfEs30ZtsN7i1myDPZMoUVUoQvMLdYPwBH
         BUkw==
X-Gm-Message-State: AHQUAubbnDLn+o5YueAZLKjr0g4FebwA5q2x2kKV5DnepTYBt6C2L1p4
	MuXbUbNHdLa7TJzLfbNjUerUJLzHrAkVN236gbomaFW7+OB0UJqKZXetnbwDhDjthmJgm+30sbp
	RuqDI4V5Gj7bCLL/hoURaOiExqZEpTqo80nui2BMoWvlqhv5HlQ9gE7OihR6vbIZguQ==
X-Received: by 2002:a9d:60cf:: with SMTP id b15mr6935502otk.144.1549500235480;
        Wed, 06 Feb 2019 16:43:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbQ055skTg5H44t/vw8Yxg+dmRq0TPTwGtjXPBGXjO04ggbwXiIc86IItVgAY1JQOQeaH7H
X-Received: by 2002:a9d:60cf:: with SMTP id b15mr6935475otk.144.1549500234355;
        Wed, 06 Feb 2019 16:43:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549500234; cv=none;
        d=google.com; s=arc-20160816;
        b=kGv3UaYFNxY2gIhn4IPmfzvG3cT15FTYkc6+5LtOCacwWG4nGQcNuOAaDb6pIYxOya
         XlN9yTaF1U2LelCGhylMM/UCHbJkZzkixDP5nMRxfdqXldePyTr/L7GN2ddYn9FnmA5j
         xTcQywSrKX6AO5l638PJ/jmnv1Jhxx/TeqhPv7dlqBKyAZfmrMYBQJK6i7yGuO/sBIdE
         B/fScBn70fZQrJ6JvjVOa7RT+41tRfE2euKLvkyBoCf9wVNQddr3AUR/6d0lP9tYt7l4
         ZKGVovAztWDU/srXq0n13NOUz0Kp6UFG8l94oHubghrF4wQy2DQTdp3E5/Ko6wLZaC5J
         CCDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=JRlu5tFyktvP98pq28nzFSuXxZEVrV369hALB61iwiU=;
        b=xQWcQEBW4n5DaLIgils+JfuAMzHiw9Nzw9e/PSgRDqQxh0lAZ2f/aQPDt4ax4o+6cb
         iGL90kPWs5pxBdFDGdNqedbOP8qKj9BNtQeWu3yVw94qmhGllcyj7MRCoYZ0fdcq+K5O
         BNvpW2MIifRG0MuvAtCxgkLtOvwlDbG8EBBx36Al9XS0ZfdK51PM0hzNApJyuKZml/dl
         tdKZWx+ssX+BQluBEfDX2BDlWksa5JxfGPCr/Lzk78i5HNFiWJE6pp7iRgoTXULsMmtp
         6JAVbam1Ew1dpCTZp8dPT1qNKBRE6kkd/h/KWW2DOvqgzh3kRDr30gxgznQRV5LkMasS
         YSlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=GEkdLvOc;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.57 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710057.outbound.protection.outlook.com. [40.107.71.57])
        by mx.google.com with ESMTPS id d17si9463949oth.75.2019.02.06.16.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 16:43:54 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.71.57 as permitted sender) client-ip=40.107.71.57;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=GEkdLvOc;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.57 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=JRlu5tFyktvP98pq28nzFSuXxZEVrV369hALB61iwiU=;
 b=GEkdLvOcjvWg6vDxKPG1RcFsafTMjgIaKHymyfY3ywvbcdlRHNW7sMsRajYNJ3DD1oUbQabtvaPeBMCYdniOR9XcP57Y5QFgKcV91d0D4sirCIF7J4B3zIS66qG/X7jJXnO0ax7u4socDab1KADWILKHjisH6Fch9fjMcqAFVZg=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4390.namprd05.prod.outlook.com (52.135.202.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.11; Thu, 7 Feb 2019 00:43:51 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31%3]) with mapi id 15.20.1622.010; Thu, 7 Feb 2019
 00:43:51 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, Julien Freche <jfreche@vmware.com>, Jason
 Wang <jasowang@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
Subject: Re: [PATCH 3/6] mm/balloon_compaction: list interfaces
Thread-Topic: [PATCH 3/6] mm/balloon_compaction: list interfaces
Thread-Index: AQHUvne93vwnG+SDO0m1oDeHgENDvqXTfDGAgAADPwA=
Date: Thu, 7 Feb 2019 00:43:51 +0000
Message-ID: <0DFA5F3F-8358-4268-83C7-9937C5F0CFFF@vmware.com>
References: <20190206235706.4851-1-namit@vmware.com>
 <20190206235706.4851-4-namit@vmware.com>
 <20190206191936-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190206191936-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;BYAPR05MB4390;20:aJEs0M76oo4sEwFUXRnEiOA7s0cPafBPzqG5NMZgkeUoPPKRKXTAKUiFD7plVIhCFhgo8pdtUqcN5zSuhCMQfv8QzGQzJoSrd5dQDxr+0oTd4osjfMNkOcfMtYXgbkraj7vwcEvEokzb+S+KxQ5ZNoibny9TgcquaLLcKgSHDD8=
x-ms-office365-filtering-correlation-id: 08525ae4-bb16-43c6-4c02-08d68c95545b
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR05MB4390;
x-ms-traffictypediagnostic: BYAPR05MB4390:
x-microsoft-antispam-prvs:
 <BYAPR05MB4390AD7AB9484B39FEC98F61D0680@BYAPR05MB4390.namprd05.prod.outlook.com>
x-forefront-prvs: 0941B96580
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(366004)(376002)(346002)(136003)(39860400002)(51914003)(52314003)(199004)(189003)(305945005)(2616005)(446003)(476003)(11346002)(14454004)(478600001)(186003)(486006)(36756003)(68736007)(106356001)(6916009)(71190400001)(229853002)(6486002)(82746002)(71200400001)(83716004)(6116002)(3846002)(2906002)(6246003)(14444005)(53936002)(256004)(105586002)(54906003)(25786009)(4326008)(86362001)(8936002)(66066001)(316002)(7736002)(33656002)(6506007)(81156014)(102836004)(81166006)(26005)(53546011)(76176011)(6436002)(8676002)(99286004)(97736004)(6512007);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4390;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zXunqZEYQnBkMnQAktAJFOogeajmdP+xTA1zNX2Gv29ExFP1G8FYc0GzJ/YhaquLetkYBmafsp6QHw6Wqc4m/1EUuvwNPJZmMiCNd2sbX8HJu3KwBmNjL6z8uIIKfkByZooZwuolMe/j6ZDavYfp1VYF9tlZHYvcAsbZeiT1YXoGB1F7SvuEWSWnM+gUgKb3b9sCyLL8csQa7JtCx7wijlsXAdBayzEXMmO0L6573SUBsg7Cnt6XTekZwQSRBYJKiSqCekj0LlPwgOtmssdNpchnGaBlEv6B0znHv2Rd66/SyEpYpbA54QIdZl0bQgNa/UG9NmSdoDBsHy2BgnvfYC8qGgFiguYe1OrHG2yN4/ZRxBe6vHs8nDeBiHAXCqAAQmPDSUKMA8p3cjTM0qqvGcttEyyglelQ+x24jYW8tEA=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B129CE5743807F4BA9EB367F67D58F11@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 08525ae4-bb16-43c6-4c02-08d68c95545b
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Feb 2019 00:43:51.0627
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4390
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBGZWIgNiwgMjAxOSwgYXQgNDozMiBQTSwgTWljaGFlbCBTLiBUc2lya2luIDxtc3RAcmVk
aGF0LmNvbT4gd3JvdGU6DQo+IA0KPiBPbiBXZWQsIEZlYiAwNiwgMjAxOSBhdCAwMzo1NzowM1BN
IC0wODAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPj4gSW50cm9kdWNlIGludGVyZmFjZXMgZm9yIGJh
bGxvb25pbmcgZW5xdWV1ZWluZyBhbmQgZGVxdWV1ZWluZyBvZiBhIGxpc3QNCj4+IG9mIHBhZ2Vz
LiBUaGVzZSBpbnRlcmZhY2VzIHJlZHVjZSB0aGUgb3ZlcmhlYWQgb2Ygc3RvcmluZyBhbmQgcmVz
dG9yaW5nDQo+PiBJUlFzIGJ5IGJhdGNoaW5nIHRoZSBvcGVyYXRpb25zLiBJbiBhZGRpdGlvbiB0
aGV5IGRvIG5vdCBwYW5pYyBpZiB0aGUNCj4+IGxpc3Qgb2YgcGFnZXMgaXMgZW1wdHkuDQo+PiAN
Cg0KW1NuaXBdDQoNCkZpcnN0LCB0aGFua3MgZm9yIHRoZSBxdWljayBmZWVkYmFjay4NCg0KPj4g
Kw0KPj4gKy8qKg0KPj4gKyAqIGJhbGxvb25fcGFnZV9saXN0X2VucXVldWUoKSAtIGluc2VydHMg
YSBsaXN0IG9mIHBhZ2VzIGludG8gdGhlIGJhbGxvb24gcGFnZQ0KPj4gKyAqCQkJCSBsaXN0Lg0K
Pj4gKyAqIEBiX2Rldl9pbmZvOiBiYWxsb29uIGRldmljZSBkZXNjcmlwdG9yIHdoZXJlIHdlIHdp
bGwgaW5zZXJ0IGEgbmV3IHBhZ2UgdG8NCj4+ICsgKiBAcGFnZXM6IHBhZ2VzIHRvIGVucXVldWUg
LSBhbGxvY2F0ZWQgdXNpbmcgYmFsbG9vbl9wYWdlX2FsbG9jLg0KPj4gKyAqDQo+PiArICogRHJp
dmVyIG11c3QgY2FsbCBpdCB0byBwcm9wZXJseSBlbnF1ZXVlIGEgYmFsbG9vbiBwYWdlcyBiZWZv
cmUgZGVmaW5pdGl2ZWx5DQo+PiArICogcmVtb3ZpbmcgaXQgZnJvbSB0aGUgZ3Vlc3Qgc3lzdGVt
Lg0KPj4gKyAqLw0KPj4gK3ZvaWQgYmFsbG9vbl9wYWdlX2xpc3RfZW5xdWV1ZShzdHJ1Y3QgYmFs
bG9vbl9kZXZfaW5mbyAqYl9kZXZfaW5mbywNCj4+ICsJCQkgICAgICAgc3RydWN0IGxpc3RfaGVh
ZCAqcGFnZXMpDQo+PiArew0KPj4gKwlzdHJ1Y3QgcGFnZSAqcGFnZSwgKnRtcDsNCj4+ICsJdW5z
aWduZWQgbG9uZyBmbGFnczsNCj4+ICsNCj4+ICsJc3Bpbl9sb2NrX2lycXNhdmUoJmJfZGV2X2lu
Zm8tPnBhZ2VzX2xvY2ssIGZsYWdzKTsNCj4+ICsJbGlzdF9mb3JfZWFjaF9lbnRyeV9zYWZlKHBh
Z2UsIHRtcCwgcGFnZXMsIGxydSkNCj4+ICsJCWJhbGxvb25fcGFnZV9lbnF1ZXVlX29uZShiX2Rl
dl9pbmZvLCBwYWdlKTsNCj4+ICsJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmYl9kZXZfaW5mby0+
cGFnZXNfbG9jaywgZmxhZ3MpOw0KPiANCj4gQXMgdGhpcyBpcyBzY2FubmluZyBwYWdlcyBvbmUg
Ynkgb25lIGFueXdheSwgaXQgd2lsbCBiZSB1c2VmdWwNCj4gdG8gaGF2ZSB0aGlzIHJldHVybiB0
aGUgIyBvZiBwYWdlcyBlbnF1ZXVlZC4NCg0KU3VyZS4NCg0KPiANCj4+ICt9DQo+PiArRVhQT1JU
X1NZTUJPTF9HUEwoYmFsbG9vbl9wYWdlX2xpc3RfZW5xdWV1ZSk7DQo+PiArDQo+PiArLyoqDQo+
PiArICogYmFsbG9vbl9wYWdlX2xpc3RfZGVxdWV1ZSgpIC0gcmVtb3ZlcyBwYWdlcyBmcm9tIGJh
bGxvb24ncyBwYWdlIGxpc3QgYW5kDQo+PiArICoJCQkJIHJldHVybnMgYSBsaXN0IG9mIHRoZSBw
YWdlcy4NCj4+ICsgKiBAYl9kZXZfaW5mbzogYmFsbG9vbiBkZXZpY2UgZGVjcmlwdG9yIHdoZXJl
IHdlIHdpbGwgZ3JhYiBhIHBhZ2UgZnJvbS4NCj4+ICsgKiBAcGFnZXM6IHBvaW50ZXIgdG8gdGhl
IGxpc3Qgb2YgcGFnZXMgdGhhdCB3b3VsZCBiZSByZXR1cm5lZCB0byB0aGUgY2FsbGVyLg0KPj4g
KyAqIEBuX3JlcV9wYWdlczogbnVtYmVyIG9mIHJlcXVlc3RlZCBwYWdlcy4NCj4+ICsgKg0KPj4g
KyAqIERyaXZlciBtdXN0IGNhbGwgaXQgdG8gcHJvcGVybHkgZGUtYWxsb2NhdGUgYSBwcmV2aW91
cyBlbmxpc3RlZCBiYWxsb29uIHBhZ2VzDQo+PiArICogYmVmb3JlIGRlZmluZXRpdmVseSByZWxl
YXNpbmcgaXQgYmFjayB0byB0aGUgZ3Vlc3Qgc3lzdGVtLiBUaGlzIGZ1bmN0aW9uDQo+PiArICog
dHJpZXMgdG8gcmVtb3ZlIEBuX3JlcV9wYWdlcyBmcm9tIHRoZSBiYWxsb29uZWQgcGFnZXMgYW5k
IHJldHVybiBpdCB0byB0aGUNCj4+ICsgKiBjYWxsZXIgaW4gdGhlIEBwYWdlcyBsaXN0Lg0KPj4g
KyAqDQo+PiArICogTm90ZSB0aGF0IHRoaXMgZnVuY3Rpb24gbWF5IGZhaWwgdG8gZGVxdWV1ZSBz
b21lIHBhZ2VzIHRlbXBvcmFyaWx5IGVtcHR5IGR1ZQ0KPj4gKyAqIHRvIGNvbXBhY3Rpb24gaXNv
bGF0ZWQgcGFnZXMuDQo+PiArICoNCj4+ICsgKiBSZXR1cm46IG51bWJlciBvZiBwYWdlcyB0aGF0
IHdlcmUgYWRkZWQgdG8gdGhlIEBwYWdlcyBsaXN0Lg0KPj4gKyAqLw0KPj4gK2ludCBiYWxsb29u
X3BhZ2VfbGlzdF9kZXF1ZXVlKHN0cnVjdCBiYWxsb29uX2Rldl9pbmZvICpiX2Rldl9pbmZvLA0K
Pj4gKwkJCSAgICAgICBzdHJ1Y3QgbGlzdF9oZWFkICpwYWdlcywgaW50IG5fcmVxX3BhZ2VzKQ0K
PiANCj4gQXJlIHdlIHN1cmUgdGhpcyBpbnQgbmV2ZXIgb3ZlcmZsb3dzPyBXaHkgbm90IGp1c3Qg
dXNlIHU2NA0KPiBvciBzaXplX3Qgc3RyYWlnaHQgYXdheT8NCg0Kc2l6ZV90IGl0IGlzLg0KDQo+
IA0KPj4gK3sNCj4+ICsJc3RydWN0IHBhZ2UgKnBhZ2UsICp0bXA7DQo+PiArCXVuc2lnbmVkIGxv
bmcgZmxhZ3M7DQo+PiArCWludCBuX3BhZ2VzID0gMDsNCj4+ICsNCj4+ICsJc3Bpbl9sb2NrX2ly
cXNhdmUoJmJfZGV2X2luZm8tPnBhZ2VzX2xvY2ssIGZsYWdzKTsNCj4+ICsJbGlzdF9mb3JfZWFj
aF9lbnRyeV9zYWZlKHBhZ2UsIHRtcCwgJmJfZGV2X2luZm8tPnBhZ2VzLCBscnUpIHsNCj4+ICsJ
CS8qDQo+PiArCQkgKiBCbG9jayBvdGhlcnMgZnJvbSBhY2Nlc3NpbmcgdGhlICdwYWdlJyB3aGls
ZSB3ZSBnZXQgYXJvdW5kDQo+PiArCQkgKiBlc3RhYmxpc2hpbmcgYWRkaXRpb25hbCByZWZlcmVu
Y2VzIGFuZCBwcmVwYXJpbmcgdGhlICdwYWdlJw0KPj4gKwkJICogdG8gYmUgcmVsZWFzZWQgYnkg
dGhlIGJhbGxvb24gZHJpdmVyLg0KPj4gKwkJICovDQo+PiArCQlpZiAoIXRyeWxvY2tfcGFnZShw
YWdlKSkNCj4+ICsJCQljb250aW51ZTsNCj4+ICsNCj4+ICsJCWlmIChJU19FTkFCTEVEKENPTkZJ
R19CQUxMT09OX0NPTVBBQ1RJT04pICYmDQo+PiArCQkgICAgUGFnZUlzb2xhdGVkKHBhZ2UpKSB7
DQo+PiArCQkJLyogcmFjZWQgd2l0aCBpc29sYXRpb24gKi8NCj4+ICsJCQl1bmxvY2tfcGFnZShw
YWdlKTsNCj4+ICsJCQljb250aW51ZTsNCj4+ICsJCX0NCj4+ICsJCWJhbGxvb25fcGFnZV9kZWxl
dGUocGFnZSk7DQo+PiArCQlfX2NvdW50X3ZtX2V2ZW50KEJBTExPT05fREVGTEFURSk7DQo+PiAr
CQl1bmxvY2tfcGFnZShwYWdlKTsNCj4+ICsJCWxpc3RfYWRkKCZwYWdlLT5scnUsIHBhZ2VzKTsN
Cj4+ICsJCWlmICgrK25fcGFnZXMgPj0gbl9yZXFfcGFnZXMpDQo+PiArCQkJYnJlYWs7DQo+PiAr
CX0NCj4+ICsJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmYl9kZXZfaW5mby0+cGFnZXNfbG9jaywg
ZmxhZ3MpOw0KPj4gKw0KPj4gKwlyZXR1cm4gbl9wYWdlczsNCj4+ICt9DQo+PiArRVhQT1JUX1NZ
TUJPTF9HUEwoYmFsbG9vbl9wYWdlX2xpc3RfZGVxdWV1ZSk7DQo+PiArDQo+IA0KPiBUaGlzIGxv
b2tzIHF1aXRlIHJlYXNvbmFibGUuIEluIGZhY3QgdmlydGlvIGNhbiBiZSByZXdvcmtlZCB0byB1
c2UNCj4gdGhpcyB0b28gYW5kIHRoZW4gdGhlIG9yaWdpbmFsIG9uZSBjYW4gYmUgZHJvcHBlZC4N
Cj4gDQo+IEhhdmUgdGhlIHRpbWU/DQoNCk9idmlvdXNseSBub3QsIGJ1dCBJIGFtIHdpbGxpbmcg
dG8gbWFrZSB0aGUgdGltZS4gV2hhdCBJIGNhbm5vdCDigJxtYWtlIiBpcyBhbg0KYXBwcm92YWwg
dG8gc2VuZCBwYXRjaGVzIGZvciBvdGhlciBoeXBlcnZpc29ycy4gTGV0IG1lIHJ1biBhIHF1aWNr
IGNoZWNrDQp3aXRoIG91ciBGT1NTIHBlb3BsZSBoZXJlLg0KDQpBbnlob3csIEkgaG9wZSBpdCB3
b3VsZCBub3QgcHJldmVudCB0aGUgcGF0Y2hlcyBmcm9tIGdldHRpbmcgdG8gdGhlIG5leHQNCnJl
bGVhc2UuDQoNCg==

