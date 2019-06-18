Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45EB2C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D410A2080C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:32:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="pC55jakD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D410A2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 310C18E0005; Mon, 17 Jun 2019 21:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C1938E0001; Mon, 17 Jun 2019 21:32:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B05B8E0005; Mon, 17 Jun 2019 21:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C0CCB8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:32:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s5so18852402eda.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:32:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=+7+vLfiIOUVtZheyGlMJIm14ipV+qzirqDVFokkBrdo=;
        b=sSZ5neZYV2uPcVoAgVtuT+U3lUEXxJ4vAZ10IXfTZBC+j4F2YHtR7pd+71RV2Bt9we
         Oe1uPX0cxFfiMm8DRo2Lv260tgGVdYKUxPgYYemU99wU6zkM3Y4bbY0C+5R29E+Q5xbr
         LXV4YpZ2iooC5nkTzowx5SmoS1Tkd9VYx3Cq+83HQQ6dciIlZwxI6ejof5BOu0yiZ7GC
         SsJSlddNCW98DcECbP4jDVotLXN9CmVwdBcxMhLaTmo7+nw1L1NlswVSBqGHU3PlRZ51
         50tQ8IjNwAIqZM5FII4t92eN9nlKFaxSbEMuEiEiatKGDt3wfs1SZ1RCAwJaYnewBfUV
         Z9OA==
X-Gm-Message-State: APjAAAVk6JK0mktWZVw0yrqHYhuJhsepHVYWtJ9O79hcY2OadQotj5xy
	60fQwj+y4s9s3x/S+b+2i29+GwJrxAfdxgRHPrFWlep+OTHXFNXsDi6bt9gDt890O/9npqHc1FO
	NWJOhOB17sHp7Doum/SxmQL6GfVEHC8sZoML+ap5LXMgRBYZ2FkR/BlIFqHh0iaLBhA==
X-Received: by 2002:a17:906:5042:: with SMTP id e2mr31098205ejk.220.1560821574235;
        Mon, 17 Jun 2019 18:32:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwOoY6m51QaAt4050ryQ71iS27hoTtCmTCzAhJM9nu46thZqFqsZZpsbLBomqBzhO0YDCI
X-Received: by 2002:a17:906:5042:: with SMTP id e2mr31098154ejk.220.1560821573247;
        Mon, 17 Jun 2019 18:32:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560821573; cv=none;
        d=google.com; s=arc-20160816;
        b=K/0JKaEN1VFtrH7ZVfCnA8ziluckFtFPhlhj4St6w9Vo+RbK2WHGxBidLit43qLmrb
         tkmq9DWrczVs064y3Kq7WAGlvC5PzRYDZ/KrxufuePlqzt/vIoPCyj4gOacMkdTNoS1a
         4vYykxjBCj06soN+hdbGjPXyUYAMCZKN62BdBIyZVC1Z7BzeSx72TMqkRQ+ne4YT9Z1w
         SNpH+STLX3ZY3dnmy2hlXWU9UuQ7mAK6inrw5XqL9pFacNFEVrUeS4jg3s+QgcbNyHhU
         yn6pBwa0oUgIAvqdslVyVt3oQrLGiZYVYKcIo7mFdSpyvQObT7Dmu3gMO+t/q8M25zjY
         mhpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=+7+vLfiIOUVtZheyGlMJIm14ipV+qzirqDVFokkBrdo=;
        b=SpKNEqnpNPnFSpwx9AjWBjCYzhQ5TNXluFyxqo9vECpSSzh21QOma6BD9psWn4zuxW
         qhENpWqcEYAxzEvz9m9tuOrevEfYmL3vlY0j+qcTG93l8t8WZtWRdAEambgeNHffQxGt
         wQItN1rXzEYHg9YbR85GR8RNL051fiyDCrL7ItDbFpuJOzFhQLiDrJ99a7Rb975/b5du
         lJP1TpY3Y3YbYd3WYUSYcHRF4eA/UWNTlpoBsFYEH8y6fEFX1/lsCBB/ms5sNFLrkPyR
         WoKmL7kBZyJsSUu+dra3cIoiMHWPwZgkcyjXBfWBjuF1SYvsmeZ76Rf591Um5D0afXQ7
         9SXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=pC55jakD;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.49 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-eopbgr820049.outbound.protection.outlook.com. [40.107.82.49])
        by mx.google.com with ESMTPS id b38si10475360edb.341.2019.06.17.18.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Jun 2019 18:32:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.82.49 as permitted sender) client-ip=40.107.82.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=pC55jakD;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.82.49 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+7+vLfiIOUVtZheyGlMJIm14ipV+qzirqDVFokkBrdo=;
 b=pC55jakDovgZ2X1tqSApuA4FxlmbzuITRhcpYxNUvKnXc5MWekVGPas8K0UjNclBmz3lPCg+OmmmUan7XWSVjWeQyMyJUxL3wJsVKoK1EsxsdsYetDAJG2NFJpZYvfNum3peSJEO5yFie6/0F0oDYn0zB+fZYIKTQBmsrMBiR6A=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4214.namprd05.prod.outlook.com (52.135.200.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.12; Tue, 18 Jun 2019 01:32:50 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Tue, 18 Jun 2019
 01:32:50 +0000
From: Nadav Amit <namit@vmware.com>
To: Sasha Levin <sashal@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Borislav Petkov
	<bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Thread-Topic: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Thread-Index: AQHVJUDx0l46AfXW90KfYcnN1JLXWaaglnUAgAAKg4A=
Date: Tue, 18 Jun 2019 01:32:50 +0000
Message-ID: <239D9ACE-E365-41B2-B9EF-4CF3A7316D07@vmware.com>
References: <20190613045903.4922-2-namit@vmware.com>
 <20190615221557.CD1492183F@mail.kernel.org>
 <549284C3-6A1C-4434-B716-FF9B0C87EE45@vmware.com>
 <20190618005512.GC2226@sasha-vm>
In-Reply-To: <20190618005512.GC2226@sasha-vm>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1ad1e6b0-2d8f-45b5-9d39-08d6f38ce03f
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR05MB4214;
x-ms-traffictypediagnostic: BYAPR05MB4214:
x-microsoft-antispam-prvs:
 <BYAPR05MB4214837784FBD46BD22BD5E7D0EA0@BYAPR05MB4214.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3968;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(39860400002)(346002)(366004)(376002)(199004)(189003)(476003)(2616005)(3846002)(446003)(6116002)(305945005)(11346002)(186003)(33656002)(76176011)(25786009)(7736002)(71190400001)(71200400001)(229853002)(102836004)(6246003)(68736007)(6506007)(53546011)(66066001)(7416002)(53936002)(26005)(6512007)(81156014)(81166006)(8676002)(36756003)(316002)(14454004)(4326008)(6486002)(86362001)(64756008)(66556008)(66476007)(66946007)(76116006)(73956011)(54906003)(256004)(478600001)(99286004)(66446008)(110136005)(2906002)(8936002)(6436002)(5660300002)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4214;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 QvKKIZNNYDEuGUDU5J9eBzPer+mNcbH4q8YJyYItGCMT9QLbACaLNwMRFEeTkVX3gxXFuvTDUG9TZjvV6q4K3wv4Tv79gn0RW6b/o6H1Vz3KgJTp/Rl3qXgJCxHs/TYvOr3+zMLxZEugO1UXfYR8DPhiT7xnzneYGNZ95MJVZcwpDv2aftUzOPeQ83ONpiox/7vDGUiF20EWO4o+o3yExVSH+IkZZYIP5OIW7bCezQ3YTOQQt93v7My3xqu5xoE0N+DuEafncrDqEX1Br1zO8MBKgGqrUXk70v/rQIm5Gsx4HBqrC4SlR0BGFMq1yFTNurPvNj71K2yn5PZbWrMugBDaR/xiwiW85V4ABxN1LhrDjsTc86BO/JlyvvYmuKatdUUNXJ2vXX6nhvod7Mdcoir/wOQHwIaPGV6s2ptM8xo=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E719E12BB841DB439372546CDF4C10B5@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1ad1e6b0-2d8f-45b5-9d39-08d6f38ce03f
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 01:32:50.1820
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4214
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTcsIDIwMTksIGF0IDU6NTUgUE0sIFNhc2hhIExldmluIDxzYXNoYWxAa2VybmVs
Lm9yZz4gd3JvdGU6DQo+IA0KPiBPbiBNb24sIEp1biAxNywgMjAxOSBhdCAwNzoxNDo1M1BNICsw
MDAwLCBOYWRhdiBBbWl0IHdyb3RlOg0KPj4+IE9uIEp1biAxNSwgMjAxOSwgYXQgMzoxNSBQTSwg
U2FzaGEgTGV2aW4gPHNhc2hhbEBrZXJuZWwub3JnPiB3cm90ZToNCj4+PiANCj4+PiBIaSwNCj4+
PiANCj4+PiBbVGhpcyBpcyBhbiBhdXRvbWF0ZWQgZW1haWxdDQo+Pj4gDQo+Pj4gVGhpcyBjb21t
aXQgaGFzIGJlZW4gcHJvY2Vzc2VkIGJlY2F1c2UgaXQgY29udGFpbnMgYSAiRml4ZXM6IiB0YWcs
DQo+Pj4gZml4aW5nIGNvbW1pdDogZmYzY2M5NTJkM2YwIHJlc291cmNlOiBBZGQgcmVtb3ZlX3Jl
c291cmNlIGludGVyZmFjZS4NCj4+PiANCj4+PiBUaGUgYm90IGhhcyB0ZXN0ZWQgdGhlIGZvbGxv
d2luZyB0cmVlczogdjUuMS45LCB2NC4xOS41MCwgdjQuMTQuMTI1LCB2NC45LjE4MS4NCj4+PiAN
Cj4+PiB2NS4xLjk6IEJ1aWxkIE9LIQ0KPj4+IHY0LjE5LjUwOiBGYWlsZWQgdG8gYXBwbHkhIFBv
c3NpYmxlIGRlcGVuZGVuY2llczoNCj4+PiAgIDAxMGE5M2JmOTdjNyAoInJlc291cmNlOiBGaXgg
ZmluZF9uZXh0X2lvbWVtX3JlcygpIGl0ZXJhdGlvbiBpc3N1ZSIpDQo+Pj4gICBhOTg5NTlmZGJk
YTEgKCJyZXNvdXJjZTogSW5jbHVkZSByZXNvdXJjZSBlbmQgaW4gd2Fsa18qKCkgaW50ZXJmYWNl
cyIpDQo+Pj4gDQo+Pj4gdjQuMTQuMTI1OiBGYWlsZWQgdG8gYXBwbHkhIFBvc3NpYmxlIGRlcGVu
ZGVuY2llczoNCj4+PiAgIDAxMGE5M2JmOTdjNyAoInJlc291cmNlOiBGaXggZmluZF9uZXh0X2lv
bWVtX3JlcygpIGl0ZXJhdGlvbiBpc3N1ZSIpDQo+Pj4gICAwZTRjMTJiNDVhYTggKCJ4ODYvbW0s
IHJlc291cmNlOiBVc2UgUEFHRV9LRVJORUwgcHJvdGVjdGlvbiBmb3IgaW9yZW1hcCBvZiBtZW1v
cnkgcGFnZXMiKQ0KPj4+ICAgMWQyZTczM2IxM2I0ICgicmVzb3VyY2U6IFByb3ZpZGUgcmVzb3Vy
Y2Ugc3RydWN0IGluIHJlc291cmNlIHdhbGsgY2FsbGJhY2siKQ0KPj4+ICAgNGFjMmFlZDgzN2Ni
ICgicmVzb3VyY2U6IENvbnNvbGlkYXRlIHJlc291cmNlIHdhbGtpbmcgY29kZSIpDQo+Pj4gICBh
OTg5NTlmZGJkYTEgKCJyZXNvdXJjZTogSW5jbHVkZSByZXNvdXJjZSBlbmQgaW4gd2Fsa18qKCkg
aW50ZXJmYWNlcyIpDQo+Pj4gDQo+Pj4gdjQuOS4xODE6IEZhaWxlZCB0byBhcHBseSEgUG9zc2li
bGUgZGVwZW5kZW5jaWVzOg0KPj4+ICAgMDEwYTkzYmY5N2M3ICgicmVzb3VyY2U6IEZpeCBmaW5k
X25leHRfaW9tZW1fcmVzKCkgaXRlcmF0aW9uIGlzc3VlIikNCj4+PiAgIDBlNGMxMmI0NWFhOCAo
Ing4Ni9tbSwgcmVzb3VyY2U6IFVzZSBQQUdFX0tFUk5FTCBwcm90ZWN0aW9uIGZvciBpb3JlbWFw
IG9mIG1lbW9yeSBwYWdlcyIpDQo+Pj4gICAxZDJlNzMzYjEzYjQgKCJyZXNvdXJjZTogUHJvdmlk
ZSByZXNvdXJjZSBzdHJ1Y3QgaW4gcmVzb3VyY2Ugd2FsayBjYWxsYmFjayIpDQo+Pj4gICA0YWMy
YWVkODM3Y2IgKCJyZXNvdXJjZTogQ29uc29saWRhdGUgcmVzb3VyY2Ugd2Fsa2luZyBjb2RlIikN
Cj4+PiAgIDYwZmUzOTEwYmIwMiAoImtleGVjX2ZpbGU6IEFsbG93IGFyY2gtc3BlY2lmaWMgbWVt
b3J5IHdhbGtpbmcgZm9yIGtleGVjX2FkZF9idWZmZXIiKQ0KPj4+ICAgYTA0NTgyODRmMDYyICgi
cG93ZXJwYzogQWRkIHN1cHBvcnQgY29kZSBmb3Iga2V4ZWNfZmlsZV9sb2FkKCkiKQ0KPj4+ICAg
YTk4OTU5ZmRiZGExICgicmVzb3VyY2U6IEluY2x1ZGUgcmVzb3VyY2UgZW5kIGluIHdhbGtfKigp
IGludGVyZmFjZXMiKQ0KPj4+ICAgZGE2NjU4ODU5YjljICgicG93ZXJwYzogQ2hhbmdlIHBsYWNl
cyB1c2luZyBDT05GSUdfS0VYRUMgdG8gdXNlIENPTkZJR19LRVhFQ19DT1JFIGluc3RlYWQuIikN
Cj4+PiAgIGVjMmI5YmZhYWM0NCAoImtleGVjX2ZpbGU6IENoYW5nZSBrZXhlY19hZGRfYnVmZmVy
IHRvIHRha2Uga2V4ZWNfYnVmIGFzIGFyZ3VtZW50LiIpDQo+PiANCj4+IElzIHRoZXJlIGEgcmVh
c29uIDAxMGE5M2JmOTdjNyAoInJlc291cmNlOiBGaXggZmluZF9uZXh0X2lvbWVtX3JlcygpDQo+
PiBpdGVyYXRpb24gaXNzdWXigJ0pIHdhcyBub3QgYmFja3BvcnRlZD8NCj4gDQo+IE1vc3RseSBi
ZWNhdXNlIGl0J3Mgbm90IHRhZ2dlZCBmb3Igc3RhYmxlIDopDQoNCkdvb2QgcG9pbnQuIFVuZm9y
dHVuYXRlbHksIDAxMGE5M2JmOTdjNyBkb2VzIG5vdCBhcHBseSBjbGVhbmx5IGVpdGhlci4NCg0K
Qmpvcm4sIGRvIHlvdSB0aGluayB5b3VyIHBhdGNoIHNob3VsZCBiZSBiYWNrcG9ydGVkPw0KDQpJ
ZiBub3QsIEkgY2FuIGNyZWF0ZSBhIHZlcnNpb24gb2YgdGhlIHBhdGNoIHRoYXQgSSBzZW50IGZv
ciA0LjE0LzQuOS4NCg0K

