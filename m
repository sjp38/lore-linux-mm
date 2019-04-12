Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDEECC10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 674692073F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="BOcmlxMv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 674692073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E032F6B000C; Fri, 12 Apr 2019 12:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8B056B000D; Fri, 12 Apr 2019 12:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C06506B0010; Fri, 12 Apr 2019 12:04:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96BB26B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:04:18 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id y1so7219468ybg.1
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 09:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-id:content-transfer-encoding:mime-version;
        bh=vgnWArSxwQhLLgYkE2RoE/6LouYrZUwbM/RoLT+FWmY=;
        b=IvFJGhqkbny+6U15lGC4yBUTb5ThJmex0xdeIb/o4WvG0sxyfiCdlnJ5HhZkwxxA1v
         bq1NTJ/z6sRvat+WkfpAECUTVATbJUuJzoMAMsF/8TX7dAWcqw65ha9v8AoSzYufZI69
         wTIyQRio/V9qw0ciGehc+4HDCAN44qQrveNXpEThUOyWEUxDYV7Zxd9TqIDqivpU0sGE
         /kG0yC56wj9aqi9Gdq6e7dc5GRqtUSnIHxqsa5VlrUFIO9XenrIVEGbNHsd1nNBB1lYO
         2aa8nbnVzzaWyhhqqkwAnr/TTBxj67jZy1A6252ovn8s5GNYL79KpHhhcdys66xMq0b+
         vIzA==
X-Gm-Message-State: APjAAAUgKiBVUwpnrcyTe2rVXyOZzJWEzO6SOU6+54x1x2lEdUUqGLmt
	69bSb2AD4CZbSLfi05NmTnmGBwfTIz9h8OD18pkTHcOMZYeRhCkHJIumL43V6a+F9txPn0zKIR+
	/bOAabhwSWScv/hsw6sAHneJoBMHsBhFHHoPpgsAnudDwFdSdGOwpAsRfqUGYnb/X7w==
X-Received: by 2002:a25:2558:: with SMTP id l85mr46884677ybl.310.1555085058302;
        Fri, 12 Apr 2019 09:04:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8vCsW/yK89MNtuv9HLCAwomTlnNr0UnA4Gtt+BZvEKi17ac7dieJWtPXT6ECa8DDNikln
X-Received: by 2002:a25:2558:: with SMTP id l85mr46884552ybl.310.1555085056984;
        Fri, 12 Apr 2019 09:04:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555085056; cv=none;
        d=google.com; s=arc-20160816;
        b=0ggoG4nIBcz59jC4A5Ua1CpzrAbZKxvllibRMUjGQwi5RwrDnYL9aJCYM9O/WottWR
         DB39CQb0Ulk5XhjCrLMbZySr/nJ5riVomim48yGo74ZSVBV17kqWoz0vGHKxc82aCWO4
         NkizKwk+3blmJHjEQJIIiWZNwxuS8llSqYC6eeN2IXS7xCXSJCSPIxCKtDVQB7YZPYd2
         i6iqzkkGSz++2KecU3pfKaOJlLTnbkFTPMrtgFCzVE8d0Ri3N3CRjKObuBBpoD2XArsP
         sXE8I0O70SOONpNbmDNFcgcJXHuMexAm9hIcStrH4worXU4nKRWwsAHDidfPCDzFfO2j
         Yefg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=vgnWArSxwQhLLgYkE2RoE/6LouYrZUwbM/RoLT+FWmY=;
        b=ABHWa+V9NpJ2CXWGuQQjGsjnreDHe4HgqM0foOTCLlhLZHC0M29dKFJIfbsnjY/WHa
         2aYwj9Hpgk/+FnD3Qzy2sRorNwRb2rk8XKWPQVL1oJdwtUPamOcJdwcwdfDLE1lWnkoM
         m3rU6XPZFrnnyxP9K6bGZ9rxRisWnJry7+yqriRzs6XAvaC6h6YPCjdDe1og9r45QTj1
         yFRUTqQ4tXBb04XFC7z6uo6vEf1FAgSpzBLwVFatvu7c6ZpUUBx/DVzoZcI7T8AgLO6L
         aEcnOHSx/CVhTnppJt1fG1rq4A0vJmW9GQpgeLvVp/35hJ+wQt3vLllbNEw6f0pSi03+
         SzEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=BOcmlxMv;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.59 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800059.outbound.protection.outlook.com. [40.107.80.59])
        by mx.google.com with ESMTPS id u200si14805429ywe.278.2019.04.12.09.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Apr 2019 09:04:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.59 as permitted sender) client-ip=40.107.80.59;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=BOcmlxMv;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.59 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vgnWArSxwQhLLgYkE2RoE/6LouYrZUwbM/RoLT+FWmY=;
 b=BOcmlxMvep7RWImww0ecJCGq6dMNSdR5R7a/ZPTBw+r3PC+qnRw/UABwVB/K5bK2bw9m9JHAu+3TX9oq2bmmNTj9Ykm9l1RAsbqlP8snZEdu7VWdlCvZEyf+Eqeh/WJ2tolg83Q1bca8E0kqBxitdBVqj/uQtxF4FoE2sk3EBPY=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6030.namprd05.prod.outlook.com (20.178.241.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Fri, 12 Apr 2019 16:04:12 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%7]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 16:04:12 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?=
	<christian.koenig@amd.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: [PATCH 0/9] Emulated coherent graphics memory
Thread-Topic: [PATCH 0/9] Emulated coherent graphics memory
Thread-Index: AQHU8UleNbKoVYDq/EerCSitVQ/anw==
Date: Fri, 12 Apr 2019 16:04:12 +0000
Message-ID: <20190412160338.64994-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: VE1PR03CA0023.eurprd03.prod.outlook.com
 (2603:10a6:802:a0::35) To MN2PR05MB6141.namprd05.prod.outlook.com
 (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.20.1
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 56bff8ba-beac-471d-b3bf-08d6bf608107
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:MN2PR05MB6030;
x-ms-traffictypediagnostic: MN2PR05MB6030:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB60309F6274375122A27035F6A1280@MN2PR05MB6030.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(376002)(39860400002)(396003)(199004)(189003)(110136005)(25786009)(476003)(2616005)(71190400001)(6512007)(2906002)(186003)(486006)(316002)(54906003)(68736007)(1076003)(6486002)(6436002)(478600001)(3846002)(71200400001)(6116002)(66574012)(99286004)(256004)(14454004)(2501003)(8676002)(66066001)(7736002)(4326008)(6506007)(81166006)(36756003)(81156014)(386003)(97736004)(102836004)(50226002)(106356001)(52116002)(5660300002)(53936002)(8936002)(7416002)(305945005)(26005)(86362001)(105586002);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6030;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 EbADsB/SZqrCxZVhJ+prczxvq9VaEMOGfN9utLbI4QmJK5cSVKg0LHFJzkw18/1mYWKNaddBwXvUP/9rbYMjsjOw0VBd3szW6GGQpnEHNEOvutDSEeqZYeS6RAgXejpFoMHgMVgejuzp/fg4iAneLDMD1MAbqLM5vY6OAMUTJhsP3a12YmhF/ON3HCz0EIg3k5aOD9enxO8dskYXRV+WiXWYuXOfWWGd0ns60AVsWcmwVe5jG37L5+CMD+cGw96H2JSix5/CfWtmpFYHRkfehNyoaP0JLIx5NrnV+0gqMYnm7ebepy+xNpLzpFxWRKnNFSAX7K7cKT4FcjYz40hefkf4dUAlK0gn2PYlOVrNCbJg9O3ceKu5uWDjh4USd5kOHI/pfgHIbHoKDYBXEb3E2QqRbKVxePFEm4cF0C9Mp7k=
Content-Type: text/plain; charset="utf-8"
Content-ID: <36272A3DAAB4FB4BBAF76EAF8F3EEC79@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 56bff8ba-beac-471d-b3bf-08d6bf608107
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 16:04:12.7999
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6030
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

R3JhcGhpY3MgQVBJcyBsaWtlIE9wZW5HTCA0LjQgYW5kIFZ1bGthbiByZXF1aXJlIHRoZSBncmFw
aGljcyBkcml2ZXINCnRvIHByb3ZpZGUgY29oZXJlbnQgZ3JhcGhpY3MgbWVtb3J5LCBtZWFuaW5n
IHRoYXQgdGhlIEdQVSBzZWVzIGFueQ0KY29udGVudCB3cml0dGVuIHRvIHRoZSBjb2hlcmVudCBt
ZW1vcnkgb24gdGhlIG5leHQgR1BVIG9wZXJhdGlvbiB0aGF0DQp0b3VjaGVzIHRoYXQgbWVtb3J5
LCBhbmQgdGhlIENQVSBzZWVzIGFueSBjb250ZW50IHdyaXR0ZW4gYnkgdGhlIEdQVQ0KdG8gdGhh
dCBtZW1vcnkgaW1tZWRpYXRlbHkgYWZ0ZXIgYW55IGZlbmNlIG9iamVjdCB0cmFpbGluZyB0aGUg
R1BVDQpvcGVyYXRpb24gaGFzIHNpZ25hbGVkLg0KDQpQYXJhdmlydHVhbCBkcml2ZXJzIHRoYXQg
b3RoZXJ3aXNlIHJlcXVpcmUgZXhwbGljaXQgc3luY2hyb25pemF0aW9uDQpuZWVkcyB0byBkbyB0
aGlzIGJ5IGhvb2tpbmcgdXAgZGlydHkgdHJhY2tpbmcgdG8gcGFnZWZhdWx0IGhhbmRsZXJzDQph
bmQgYnVmZmVyIG9iamVjdCB2YWxpZGF0aW9uLiBUaGlzIGlzIGEgZmlyc3QgYXR0ZW1wdCB0byBk
byB0aGF0IGZvcg0KdGhlIHZtd2dmeCBkcml2ZXIuDQoNClRoZSBtbSBwYXRjaGVzIGhhcyBiZWVu
IG91dCBmb3IgUkZDLiBJIHRoaW5rIEkgaGF2ZSBhZGRyZXNzZWQgYWxsIHRoZQ0KZmVlZGJhY2sg
SSBnb3QsIGV4Y2VwdCBhIHBvc3NpYmxlIHNvZnRkaXJ0eSBicmVha2FnZS4gQnV0IGFsdGhvdWdo
IHRoZQ0KZGlydHktdHJhY2tpbmcgYW5kIHNvZnRkaXJ0eSBtYXkgd3JpdGUtcHJvdGVjdCBQVEVz
IGJvdGggY2FyZSBhYm91dCwNCnRoYXQgc2hvdWxkbid0IHJlYWxseSBjYXVzZSBhbnkgb3BlcmF0
aW9uIGludGVyZmVyZW5jZS4gSW4gcGFydGljdWxhcg0Kc2luY2Ugd2UgdXNlIHRoZSBoYXJkd2Fy
ZSBkaXJ0eSBQVEUgYml0cyBhbmQgc29mdGRpcnR5IHVzZXMgb3RoZXIgUFRFIGJpdHMuDQoNCkZv
ciB0aGUgVFRNIGNoYW5nZXMgdGhleSBhcmUgaG9wZWZ1bGx5IGluIGxpbmUgd2l0aCB0aGUgbG9u
Zy10ZXJtDQpzdHJhdGVneSBvZiBtYWtpbmcgaGVscGVycyBvdXQgb2Ygd2hhdCdzIGxlZnQgb2Yg
VFRNLg0KDQpUaGUgY29kZSBoYXMgYmVlbiB0ZXN0ZWQgYW5kIGV4Y2VyY2lzZWQgYnkgYSB0YWls
b3JlZCB2ZXJzaW9uIG9mIG1lc2ENCndoZXJlIHdlIGRpc2FibGUgYWxsIGV4cGxpY2l0IHN5bmNo
cm9uaXphdGlvbiBhbmQgYXNzdW1lIGdyYXBoaWNzIG1lbW9yeQ0KaXMgY29oZXJlbnQuIFRoZSBw
ZXJmb3JtYW5jZSBsb3NzIHZhcmllcyBvZiBjb3Vyc2U7IGEgdHlwaWNhbCBudW1iZXIgaXMNCmFy
b3VuZCA1JS4NCg0KQW55IGZlZWRiYWNrIGdyZWF0bHkgYXBwcmVjaWF0ZWQuDQoNCkNjOiBBbmRy
ZXcgTW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KQ2M6IE1hdHRoZXcgV2lsY294
IDx3aWxseUBpbmZyYWRlYWQub3JnPg0KQ2M6IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0u
Y29tPg0KQ2M6IFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4NCkNjOiBSaWsg
dmFuIFJpZWwgPHJpZWxAc3VycmllbC5jb20+DQpDYzogTWluY2hhbiBLaW0gPG1pbmNoYW5Aa2Vy
bmVsLm9yZz4NCkNjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCkNjOiBIdWFuZyBZ
aW5nIDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCkNjOiBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxp
bnV4QGdtYWlsLmNvbT4NCkNjOiAiSsOpcsO0bWUgR2xpc3NlIiA8amdsaXNzZUByZWRoYXQuY29t
Pg0KQ2M6ICJDaHJpc3RpYW4gS8O2bmlnIiA8Y2hyaXN0aWFuLmtvZW5pZ0BhbWQuY29tPg0KQ2M6
IGxpbnV4LW1tQGt2YWNrLm9yZw0K

