Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD561C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 17:49:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53D3D2086D
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 17:49:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="UvWZvE8I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53D3D2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C06776B000C; Fri, 12 Apr 2019 13:49:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4C26B000D; Fri, 12 Apr 2019 13:49:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56AB6B0010; Fri, 12 Apr 2019 13:49:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7391B6B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 13:49:22 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id w3so5225133otg.11
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:49:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Trr0vVpt9xqr9A3VykiKdynjLhFoOpMDgqGfItpOwhk=;
        b=Ye4BMSwGUqrPV7nPlmDKCOA1dXYJDf3bFvYRm6nU+eH+GEmBkVJU6XnNbr+PCgh4HG
         6Tm5ss2v5y+0G2L6OFCYeYFAJhBgXp2glG6AaCuQD8f6RG05TgnceNnse7+KgvIv+O7p
         nOkGyqlXgBeunKok7rolaLCuBtJwRmS8ELCAC9pckgIXi/j+rfktpziD+o8WE9EC7Zpe
         Jb9aWNU2E2nSqNfDTYo06OXfHhUJQOTDW/HHV0BNsjERWcLVjXmRPgmfy8nPWVi3jk9K
         +hjCIPjC5gnUuPrc13dnzCboC/glqLWOHJOsGAIegs3pn/7XZWTLXIBe7oO4oyN0heSB
         2nNA==
X-Gm-Message-State: APjAAAXANQZK09evgU4QlkDmrzJzRi6u5WBdveClW1wtB1n5GMREWK9s
	8W5EbSx4YlQj786MN3pX3o2t+eUfCoB6HK0QYapCWjpdksgoo/yEe+I9T2lySdEcWzYnPgwfJLM
	3cQY5yMVdR+dMnOU62JoSS+yYFcOidTW5WJArmxeAIHLM7QPkuQbvmfjsDqAx0UvdZA==
X-Received: by 2002:a9d:5e15:: with SMTP id d21mr38004778oti.138.1555091361865;
        Fri, 12 Apr 2019 10:49:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzrX4FxbKAY0PH+NwL+Jndi9CuYGm0V48nkynCiIXyCEThILAre2JpfzgJaih9wcM99zI9
X-Received: by 2002:a9d:5e15:: with SMTP id d21mr38004697oti.138.1555091360520;
        Fri, 12 Apr 2019 10:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555091360; cv=none;
        d=google.com; s=arc-20160816;
        b=Z0W+0vkqrVzg3yi+Ah+xUEEFRebF424pno6ZrSLLvJU1adxRIqKbV1HxADVdZh/nDn
         +3E68InKeXzu4/NvssqxmracEb70xic68RpqE/O+yIqAzxzQQb52TBf9YWNUUEXfV4HP
         h5c8IGUtRjWTdDosTulKsKOwdHWToypPtp6yBo5oweXezWk6wCe0G1DyAJwpJ6rS9ezU
         h8J96CFJmhGGmWzFGfm/GAYTkQpQV93KoblWwyfm7UMFXZREPPotexzxgK9/J/lrxcq8
         QPawQp3kg/Bpr1waTwhfoKDiX4nKy3KDZ0ccm6I6BRoiFBe2kRiRSLGobBwcY11G7/XO
         UKKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Trr0vVpt9xqr9A3VykiKdynjLhFoOpMDgqGfItpOwhk=;
        b=Hv9cOaaNOrBN8ebKMzUIpfQVbDMAXwQuPZ36jzSalcd5ogkvdndlBNLFw1Ej562mQw
         XXbZM9OBIfTWQvnSULRsJA9QCiu7NQB+2Cfff6cnOmrVedeksiYhHMqhAigm1IvSetC9
         avTSmkIc9KZeCKHk6f4ghkSQ/XdDwaEHJxh2nLtGL+pSkjnYTkr418Rp5OJ5CULiRy9A
         Km63BaUpHazuzw0c54kGhDYU1J6VKeLAMB0n19MUMVcelo4ePa2wZLL1CBphEf/wSvyb
         ZwjmEY3Y7FlbMjWAZgl5ZhXHZg4azBDHG/KZNo8UGGkMVeBBgU1ULhqCUPEEBLG5w6ow
         Er4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=UvWZvE8I;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.81 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710081.outbound.protection.outlook.com. [40.107.71.81])
        by mx.google.com with ESMTPS id s8si19015593oia.247.2019.04.12.10.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 10:49:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.71.81 as permitted sender) client-ip=40.107.71.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=UvWZvE8I;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.71.81 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Trr0vVpt9xqr9A3VykiKdynjLhFoOpMDgqGfItpOwhk=;
 b=UvWZvE8IbxWHpVJtpebWHOdjL9kVSpoypnGd6HTNC0O2HfSNJPNQh0vRd54S5kEnbkykIcYa3aZYn15Fl7s5xRHbSqkroc+ayHyv9DUVsM0kqbY3IpU86xVn45G8MinZjrXcua+dPyxl38L4fSXbCVRgDl59nsUc1Vy4qxSvKJQ=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4741.namprd05.prod.outlook.com (52.135.233.95) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.11; Fri, 12 Apr 2019 17:49:16 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::4140:b8f2:8e3:f5fd%4]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 17:49:16 +0000
From: Nadav Amit <namit@vmware.com>
To: Andy Lutomirski <luto@amacapital.net>
CC: Peter Zijlstra <peterz@infradead.org>, kernel test robot <lkp@intel.com>,
	LKP <lkp@01.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Ingo
 Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon
	<will.deacon@arm.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds
	<torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>
Subject: Re: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Topic: 1808d65b55 ("asm-generic/tlb: Remove arch_tlb*_mmu()"):  BUG:
 KASAN: stack-out-of-bounds in __change_page_attr_set_clr
Thread-Index: AQHU8R5sUhi0mJ9uO0aA/EiVew3tvaY4YIQAgABBN4CAAB//AIAAAoCAgAAJn4A=
Date: Fri, 12 Apr 2019 17:49:16 +0000
Message-ID: <8E2904D6-F7DB-4183-A709-BAEE0C842D70@vmware.com>
References: <5cae03c4.iIPk2cWlfmzP0Zgy%lkp@intel.com>
 <20190411193906.GA12232@hirez.programming.kicks-ass.net>
 <20190411195424.GL14281@hirez.programming.kicks-ass.net>
 <20190411211348.GA8451@worktop.programming.kicks-ass.net>
 <20190412105633.GM14281@hirez.programming.kicks-ass.net>
 <20190412111756.GO14281@hirez.programming.kicks-ass.net>
 <F18AF0D5-D8B4-4F4B-8469-F9DEC49683C7@vmware.com>
 <E33FDED8-8B95-431D-9AC7-71D45AB49011@vmware.com>
 <43ACD9F9-6373-4325-A97A-B8E8588E24BD@amacapital.net>
In-Reply-To: <43ACD9F9-6373-4325-A97A-B8E8588E24BD@amacapital.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c9dd6471-f4d7-4af9-a020-08d6bf6f2eea
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB4741;
x-ms-traffictypediagnostic: BYAPR05MB4741:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <BYAPR05MB47415BC1DF472AA259CD1AEED0280@BYAPR05MB4741.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(376002)(346002)(136003)(366004)(39860400002)(189003)(199004)(5660300002)(186003)(7416002)(316002)(82746002)(105586002)(6916009)(478600001)(256004)(53546011)(106356001)(6436002)(6506007)(446003)(14454004)(102836004)(4326008)(229853002)(36756003)(4001150100001)(97736004)(6486002)(68736007)(54906003)(81156014)(99286004)(8936002)(76176011)(305945005)(2906002)(45080400002)(7736002)(14444005)(486006)(71200400001)(6246003)(53936002)(966005)(561944003)(6512007)(25786009)(81166006)(26005)(8676002)(83716004)(6306002)(11346002)(476003)(93886005)(6116002)(2616005)(66066001)(86362001)(71190400001)(33656002)(3846002)(41533002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4741;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 FBOvpRflQ2x5WXXX+CoM7zgijXZEEM93nXEJT57vBqeJFK55DMW/A7jY8UqjJxV8hIbdhCyp2Fl9EaAEMof7j6OzUl5FhqSWu6SjGTZ/ZhNNH0PoPA6pTdcsVLyto13RWwjdNH7f6T6uPgCc5usuoSROz32fkFKZ20O19eUAXU9lePPfrcZitz2+QG1SFk1jRyzNkFS/zUPzvTxekKHrexzNoZytM19kdWr8OObFwRg5GXoUlKQ2ODxKh/FSkQVcpc7DH3//G65JOcklNPQhPEkhWrag3fN4LmxJjsBQeVgJoGso3CH6UJZT6GxDns/JYrAcp7eecexiSDfecZQM6cui7IS/Cd2TJJlOKBAQiD03/Fyl65R5zraZPPVYZCmtjOARBY70V6zzBRgKFge0c4GLPxbmMq4wjfJei7At9yw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <034592D01EB2E24BB06EE3F3E97F7E20@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c9dd6471-f4d7-4af9-a020-08d6bf6f2eea
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 17:49:16.8026
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4741
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBBcHIgMTIsIDIwMTksIGF0IDEwOjE0IEFNLCBBbmR5IEx1dG9taXJza2kgPGx1dG9AYW1h
Y2FwaXRhbC5uZXQ+IHdyb3RlOg0KPiANCj4gDQo+IA0KPiBPbiBBcHIgMTIsIDIwMTksIGF0IDEw
OjA1IEFNLCBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4gDQo+Pj4gT24g
QXByIDEyLCAyMDE5LCBhdCA4OjExIEFNLCBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3
cm90ZToNCj4+PiANCj4+Pj4gT24gQXByIDEyLCAyMDE5LCBhdCA0OjE3IEFNLCBQZXRlciBaaWps
c3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+IHdyb3RlOg0KPj4+PiANCj4+Pj4gT24gRnJpLCBB
cHIgMTIsIDIwMTkgYXQgMTI6NTY6MzNQTSArMDIwMCwgUGV0ZXIgWmlqbHN0cmEgd3JvdGU6DQo+
Pj4+Pj4gT24gVGh1LCBBcHIgMTEsIDIwMTkgYXQgMTE6MTM6NDhQTSArMDIwMCwgUGV0ZXIgWmlq
bHN0cmEgd3JvdGU6DQo+Pj4+Pj4+IE9uIFRodSwgQXByIDExLCAyMDE5IGF0IDA5OjU0OjI0UE0g
KzAyMDAsIFBldGVyIFppamxzdHJhIHdyb3RlOg0KPj4+Pj4+Pj4gT24gVGh1LCBBcHIgMTEsIDIw
MTkgYXQgMDk6Mzk6MDZQTSArMDIwMCwgUGV0ZXIgWmlqbHN0cmEgd3JvdGU6DQo+Pj4+Pj4+PiBJ
IHRoaW5rIHRoaXMgYmlzZWN0IGlzIGJhZC4gSWYgeW91IGxvb2sgYXQgeW91ciBvd24gbG9ncyB0
aGlzIHBhdGNoDQo+Pj4+Pj4+PiBtZXJlbHkgY2hhbmdlcyB0aGUgZmFpbHVyZSwgYnV0IGRvZXNu
J3QgbWFrZSBpdCBnbyBhd2F5Lg0KPj4+Pj4+Pj4gDQo+Pj4+Pj4+PiBCZWZvcmUgdGhpcyBwYXRj
aCAoaW4gZmFjdCwgYmVmb3JlIHRpcC9jb3JlL21tIGVudGlyZWx5KSB0aGUgZXJycm9yDQo+Pj4+
Pj4+PiByZWFkcyBsaWtlIHRoZSBiZWxvdywgd2hpY2ggc3VnZ2VzdHMgdGhlcmUgaXMgbWVtb3J5
IGNvcnJ1cHRpb24NCj4+Pj4+Pj4+IHNvbWV3aGVyZSwgYW5kIHRoZSBmaW5nZXJlZCBwYXRjaCBq
dXN0IG1ha2VzIGl0IHRyaWdnZXIgZGlmZmVyZW50bHkuDQo+Pj4+Pj4+PiANCj4+Pj4+Pj4+IEl0
IHdvdWxkIGJlIHZlcnkgZ29vZCB0byBmaW5kIHRoZSBzb3VyY2Ugb2YgdGhpcyBjb3JydXB0aW9u
LCBidXQgSSdtDQo+Pj4+Pj4+PiBmYWlybHkgY2VydGFpbiBpdCBpcyBub3QgaGVyZS4NCj4+Pj4+
Pj4gDQo+Pj4+Pj4+IEkgd2VudCBiYWNrIHRvIHY0LjIwIHRvIHRyeSBhbmQgZmluZCBhIHRpbWUg
d2hlbiB0aGUgYmVsb3cgZXJyb3IgZGlkIG5vdA0KPj4+Pj4+PiBvY2N1ciwgYnV0IGV2ZW4gdGhh
dCByZWxpYWJseSB0cmlnZ2VycyB0aGUgd2FybmluZy4NCj4+Pj4+PiANCj4+Pj4+PiBTbyBJIGFs
c28gdGVzdGVkIHY0LjE5IGFuZCBmb3VuZCB0aGF0IHRoYXQgd2FzIGdvb2QsIHdoaWNoIG1hZGUg
bWUNCj4+Pj4+PiBiaXNlY3QgdjQuMTkuLnY0LjIwDQo+Pj4+Pj4gDQo+Pj4+Pj4gIyBiYWQ6IFs4
ZmUyOGNiNThiY2IyMzUwMzRiNjRjYmJiNzU1MGE4YTQzZmQ4OGJlXSBMaW51eCA0LjIwDQo+Pj4+
Pj4gIyBnb29kOiBbODRkZjk1MjViMGMyN2YzZWJjMmViYjE4NjRmYTYyYTk3ZmRlZGI3ZF0gTGlu
dXggNC4xOQ0KPj4+Pj4+IGdpdCBiaXNlY3Qgc3RhcnQgJ3Y0LjIwJyAndjQuMTknDQo+Pj4+Pj4g
IyBiYWQ6IFtlYzljMTY2NDM0NTk1MzgyYmUzYmFiZjI2NmZlYmY4NzYzMjc3NzRkXSBNZXJnZSB0
YWcgJ21pcHNfZml4ZXNfNC4yMF8xJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xp
bnV4L2tlcm5lbC9naXQvbWlwcy9saW51eA0KPj4+Pj4+IGdpdCBiaXNlY3QgYmFkIGVjOWMxNjY0
MzQ1OTUzODJiZTNiYWJmMjY2ZmViZjg3NjMyNzc3NGQNCj4+Pj4+PiAjIGJhZDogWzUwYjgyNWQ3
ZTg3ZjRjZmY3MDcwZGY2ZWIyNjM5MDE1MmJiMjk1MzddIE1lcmdlIGdpdDovL2dpdC5rZXJuZWwu
b3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC9kYXZlbS9uZXQtbmV4dA0KPj4+Pj4+IGdpdCBi
aXNlY3QgYmFkIDUwYjgyNWQ3ZTg3ZjRjZmY3MDcwZGY2ZWIyNjM5MDE1MmJiMjk1MzcNCj4+Pj4+
PiAjIGdvb2Q6IFs5OWU5YWNkODVjY2JkYzhmNTc4NWY5ZTk2MWQ0OTU2ZTk2YmQ2YWE1XSBNZXJn
ZSB0YWcgJ21seDUtdXBkYXRlcy0yMDE4LTEwLTE3JyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9w
dWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvc2FlZWQvbGludXgNCj4+Pj4+PiBnaXQgYmlzZWN0IGdv
b2QgOTllOWFjZDg1Y2NiZGM4ZjU3ODVmOWU5NjFkNDk1NmU5NmJkNmFhNQ0KPj4+Pj4+ICMgZ29v
ZDogW2M0MDM5OTNhNDFkNTBkYjFlN2Q5YmMyZDQzYzNjODQ5ODE2MjMxMmZdIE1lcmdlIHRhZyAn
Zm9yLWxpbnVzLTQuMjAnIG9mIGh0dHBzOi8vbmFtMDQuc2FmZWxpbmtzLnByb3RlY3Rpb24ub3V0
bG9vay5jb20vP3VybD1odHRwcyUzQSUyRiUyRmdpdGh1Yi5jb20lMkZjbWlueWFyZCUyRmxpbnV4
LWlwbWkmYW1wO2RhdGE9MDIlN0MwMSU3Q25hbWl0JTQwdm13YXJlLmNvbSU3Q2ExYzNlYTVkNGJj
MzRjZmM3ODU1MDhkNmJmMzg4ZmYzJTdDYjM5MTM4Y2EzY2VlNGI0YWE0ZDZjZDgzZDlkZDYyZjAl
N0MwJTdDMCU3QzYzNjkwNjY0NzAxMzc3NzU3MyZhbXA7c2RhdGE9M1ZTUjNWZEU1cnhPaXRBZGtx
Rk5QcEFuQXRMZ0RtWUx6SnRvVXJzNXY5WSUzRCZhbXA7cmVzZXJ2ZWQ9MA0KPj4+Pj4+IGdpdCBi
aXNlY3QgZ29vZCBjNDAzOTkzYTQxZDUwZGIxZTdkOWJjMmQ0M2MzYzg0OTgxNjIzMTJmDQo+Pj4+
Pj4gIyBnb29kOiBbYzA1ZjM2NDJmNDMwNGRkMDgxODc2ZTc3YTY4NTU1YjZhYmE0NDgzZl0gTWVy
Z2UgYnJhbmNoICdwZXJmLWNvcmUtZm9yLWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9w
dWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvdGlwL3RpcA0KPj4+Pj4+IGdpdCBiaXNlY3QgZ29vZCBj
MDVmMzY0MmY0MzA0ZGQwODE4NzZlNzdhNjg1NTViNmFiYTQ0ODNmDQo+Pj4+Pj4gIyBiYWQ6IFs0
NDc4Njg4MGRmMTk2YTQyMDBjMTc4OTQ1YzRkNDE2NzVmYWY5ZmI3XSBNZXJnZSBicmFuY2ggJ3Bh
cmlzYy00LjIwLTEnIG9mIGdpdDovL2dpdC5rZXJuZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVs
L2dpdC9kZWxsZXIvcGFyaXNjLWxpbnV4DQo+Pj4+Pj4gZ2l0IGJpc2VjdCBiYWQgNDQ3ODY4ODBk
ZjE5NmE0MjAwYzE3ODk0NWM0ZDQxNjc1ZmFmOWZiNw0KPj4+Pj4+ICMgYmFkOiBbOTk3OTJlMGNl
YTFlZDczM2NkYzhkMDc1ODY3Nzk4MWUwY2JlYmZlZF0gTWVyZ2UgYnJhbmNoICd4ODYtbW0tZm9y
LWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQv
dGlwL3RpcA0KPj4+Pj4+IGdpdCBiaXNlY3QgYmFkIDk5NzkyZTBjZWExZWQ3MzNjZGM4ZDA3NTg2
Nzc5ODFlMGNiZWJmZWQNCj4+Pj4+PiAjIGdvb2Q6IFtmZWM5ODA2OWZiNzJmYjY1NjMwNGEzZTUy
MjY1ZTBjMmZjOWFkZjg3XSBNZXJnZSBicmFuY2ggJ3g4Ni1jcHUtZm9yLWxpbnVzJyBvZiBnaXQ6
Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvdGlwL3RpcA0KPj4+Pj4+
IGdpdCBiaXNlY3QgZ29vZCBmZWM5ODA2OWZiNzJmYjY1NjMwNGEzZTUyMjY1ZTBjMmZjOWFkZjg3
DQo+Pj4+Pj4gIyBiYWQ6IFthMzFhY2QzZWU4ZjdkYmMwMzcwYmRmNGE0YmZlZjdhOGMxM2M3NTQy
XSB4ODYvbW06IFBhZ2Ugc2l6ZSBhd2FyZSBmbHVzaF90bGJfbW1fcmFuZ2UoKQ0KPj4+Pj4+IGdp
dCBiaXNlY3QgYmFkIGEzMWFjZDNlZThmN2RiYzAzNzBiZGY0YTRiZmVmN2E4YzEzYzc1NDINCj4+
Pj4+PiAjIGdvb2Q6IFthNzI5NWZkNTNjMzljZTc4MWE5NzkyYzlkZDJjODc0N2JmMjc0MTYwXSB4
ODYvbW0vY3BhOiBVc2UgZmx1c2hfdGxiX2tlcm5lbF9yYW5nZSgpDQo+Pj4+Pj4gZ2l0IGJpc2Vj
dCBnb29kIGE3Mjk1ZmQ1M2MzOWNlNzgxYTk3OTJjOWRkMmM4NzQ3YmYyNzQxNjANCj4+Pj4+PiAj
IGdvb2Q6IFs5Y2YzOGQ1NTU5ZTgxM2NjY2RiYThiNDRjODJjYzQ2YmE0OGQwODk2XSBrZXhlYzog
QWxsb2NhdGUgZGVjcnlwdGVkIGNvbnRyb2wgcGFnZXMgZm9yIGtkdW1wIGlmIFNNRSBpcyBlbmFi
bGVkDQo+Pj4+Pj4gZ2l0IGJpc2VjdCBnb29kIDljZjM4ZDU1NTllODEzY2NjZGJhOGI0NGM4MmNj
NDZiYTQ4ZDA4OTYNCj4+Pj4+PiAjIGdvb2Q6IFs1YjEyOTA0MDY1Nzk4ZmVlOGIxNTNhNTA2YWM3
YjcyZDVlYmJlMjZjXSB4ODYvbW0vZG9jOiBDbGVhbiB1cCB0aGUgeDg2LTY0IHZpcnR1YWwgbWVt
b3J5IGxheW91dCBkZXNjcmlwdGlvbnMNCj4+Pj4+PiBnaXQgYmlzZWN0IGdvb2QgNWIxMjkwNDA2
NTc5OGZlZThiMTUzYTUwNmFjN2I3MmQ1ZWJiZTI2Yw0KPj4+Pj4+ICMgZ29vZDogW2NmMDg5NjEx
ZjRjNDQ2Mjg1MDQ2ZmNkNDI2ZDkwYzE4ZjM3ZDI5MDVdIHByb2Mvdm1jb3JlOiBGaXggaTM4NiBi
dWlsZCBlcnJvciBvZiBtaXNzaW5nIGNvcHlfb2xkbWVtX3BhZ2VfZW5jcnlwdGVkKCkNCj4+Pj4+
PiBnaXQgYmlzZWN0IGdvb2QgY2YwODk2MTFmNGM0NDYyODUwNDZmY2Q0MjZkOTBjMThmMzdkMjkw
NQ0KPj4+Pj4+ICMgZ29vZDogW2E1Yjk2NmFlNDJhNzBiMTk0YjAzZWFhNWVhZWE3MGQ4YjM3OTBj
NDBdIE1lcmdlIGJyYW5jaCAndGxiL2FzbS1nZW5lcmljJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9y
Zy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvYXJtNjQvbGludXggaW50byB4ODYvbW0NCj4+Pj4+
PiBnaXQgYmlzZWN0IGdvb2QgYTViOTY2YWU0MmE3MGIxOTRiMDNlYWE1ZWFlYTcwZDhiMzc5MGM0
MA0KPj4+Pj4+ICMgZmlyc3QgYmFkIGNvbW1pdDogW2EzMWFjZDNlZThmN2RiYzAzNzBiZGY0YTRi
ZmVmN2E4YzEzYzc1NDJdIHg4Ni9tbTogUGFnZSBzaXplIGF3YXJlIGZsdXNoX3RsYl9tbV9yYW5n
ZSgpDQo+Pj4+Pj4gDQo+Pj4+Pj4gQW5kICdmdW5uaWx5JyB0aGUgYmFkIHBhdGNoIGlzIG9uZSBv
ZiBtaW5lIHRvbyA6Lw0KPj4+Pj4+IA0KPj4+Pj4+IEknbGwgZ28gaGF2ZSBhIGxvb2sgYXQgdGhh
dCB0b21vcnJvdywgYmVjYXVzZSBjdXJycmVudGx5IEknbSB3YXkgcGFzdA0KPj4+Pj4+IHRpcmVk
Lg0KPj4+Pj4gDQo+Pj4+PiBPSywgc28gdGhlIGJlbG93IHBhdGNobGV0IG1ha2VzIGl0IGFsbCBn
b29kLiBJdCB0dXJucyBvdXQgdGhhdCB0aGUNCj4+Pj4+IHByb3ZpZGVkIGNvbmZpZyBoYXM6DQo+
Pj4+PiANCj4+Pj4+IENPTkZJR19YODZfTDFfQ0FDSEVfU0hJRlQ9Nw0KPj4+Pj4gDQo+Pj4+PiB3
aGljaCB0aGVuLCBmb3Igc29tZSBvYnNjdXJlIHJhaXNpbiwgcmVzdWx0cyBpbiBmbHVzaF90bGJf
bW1fcmFuZ2UoKQ0KPj4+Pj4gY29tcGlsaW5nIHRvIHVzZSAzMjAgYnl0ZXMgb2Ygc3RhY2s6DQo+
Pj4+PiANCj4+Pj4+IHN1YiAgICAkMHgxNDAsJXJzcA0KPj4+Pj4gDQo+Pj4+PiBXaGVyZSBhICdk
ZWZjb25maWcnIGJ1aWxkIHJlc3VsdHMgaW46DQo+Pj4+PiANCj4+Pj4+IHN1YiAgICAkMHg1OCwl
cnNwDQo+Pj4+PiANCj4+Pj4+IFRoZSB0aGluZyB0aGF0IHB1c2hlcyBpdCBvdmVyIHRoZSBlZGdl
IGluIHRoZSBhYm92ZSBmaW5nZXJlZCBwYXRjaCBpcw0KPj4+Pj4gdGhlIGFkZGl0aW9uIG9mIGEg
ZmllbGQgdG8gc3RydWN0IGZsdXNoX3RsYl9pbmZvLCB3aGljaCBncm93cyBpZiBmcm9tIDMyDQo+
Pj4+PiB0byAzNiBieXRlcy4NCj4+Pj4+IA0KPj4+Pj4gU28gbXkgcHJvcG9zYWwgaXMgdG8gYmFz
aWNhbGx5IHJldmVydCB0aGF0LCB1bmxlc3Mgd2UgY2FuIGNvbWUgdXAgd2l0aA0KPj4+Pj4gc29t
ZXRoaW5nIHRoYXQgR0NDIGNhbid0IHNjcmV3IHVwLg0KPj4+PiANCj4+Pj4gVG8gY2xhcmlmeSwg
J3RoYXQnIGlzIE5hZGF2J3MgcGF0Y2g6DQo+Pj4+IA0KPj4+PiA1MTVhYjdjNDEzMDYgKCJ4ODYv
bW06IEFsaWduIFRMQiBpbnZhbGlkYXRpb24gaW5mbyIpDQo+Pj4+IA0KPj4+PiB3aGljaCB0dXJu
cyBvdXQgdG8gYmUgdGhlIHJlYWwgcHJvYmxlbS4NCj4+PiANCj4+PiBTb3JyeSBmb3IgdGhhdC4g
SSBzdGlsbCB0aGluayBpdCBzaG91bGQgYmUgYWxpZ25lZCwgZXNwZWNpYWxseSB3aXRoIGFsbCB0
aGUNCj4+PiBlZmZvcnQgdGhlIEludGVsIHB1dHMgYXJvdW5kIHRvIGF2b2lkIGJ1cy1sb2NraW5n
IG9uIHVuYWxpZ25lZCBhdG9taWMNCj4+PiBvcGVyYXRpb25zLg0KPj4+IA0KPj4+IFNvIHRoZSBy
aWdodCBzb2x1dGlvbiBzZWVtcyB0byBtZSBhcyBwdXR0aW5nIHRoaXMgZGF0YSBzdHJ1Y3R1cmUg
b2ZmIHN0YWNrLg0KPj4+IEl0IHdvdWxkIHByZXZlbnQgZmx1c2hfdGxiX21tX3JhbmdlKCkgZnJv
bSBiZWluZyByZWVudHJhbnQsIHNvIHdlIGNhbiBrZWVwIGENCj4+PiBmZXcgZW50cmllcyBmb3Ig
dGhpcyBtYXR0ZXIgYW5kIGF0b21pY2FsbHkgaW5jcmVhc2UgdGhlIGVudHJ5IG51bWJlciBldmVy
eQ0KPj4+IHRpbWUgd2UgZW50ZXIgZmx1c2hfdGxiX21tX3JhbmdlKCkuDQo+Pj4gDQo+Pj4gQnV0
IG15IHF1ZXN0aW9uIGlzIC0gc2hvdWxkIGZsdXNoX3RsYl9tbV9yYW5nZSgpIGJlIHJlZW50cmFu
dCwgb3IgY2FuIHdlDQo+Pj4gYXNzdW1lIG5vIFRMQiBzaG9vdGRvd25zIGFyZSBpbml0aWF0ZWQg
aW4gaW50ZXJydXB0IGhhbmRsZXJzIGFuZCAjTUMNCj4+PiBoYW5kbGVycz8NCj4+IA0KPj4gUGV0
ZXIsIHdoYXQgZG8geW91IHNheSBhYm91dCB0aGlzIG9uZT8gSSBhc3N1bWUgdGhlcmUgYXJlIG5v
IG5lc3RlZCBUTEINCj4+IGZsdXNoZXMsIGJ1dCB0aGUgY29kZSBjYW4gZWFzaWx5IGJlIGFkYXB0
ZWQgKGFzc3VtaW5nIHRoZXJlIGlzIGEgbGltaXQgb24NCj4+IHRoZSBuZXN0aW5nIGxldmVsKS4N
Cj4gDQo+IFlvdSBuZWVkIElSUXMgb24gdG8gZmx1c2gsIHJpZ2h0PyAgU28gYXMgbG9uZyBhcyBw
cmVlbXB0aW9uIGlzIG9mZiwgaXQgd29u4oCZdCBuZXN0Lg0KDQpZZXMuIEkgZmlndXJlZCwgYnV0
IGl0IHN0aWxsIGhhZCBhbGwga2luZCBvZiB0aGVvcmV0aWNhbCBzY2VuYXJpb3MgaW4gbXkgbWlu
ZA0KKElSUXMgYXJlIGNvbmRpdGlvbmFsbHkgZW5hYmxlZCBpbiAjTUMgaGFuZGxlciwgZXRjLikN
Cg0KPiBCdXQgaXMgdGhlcmUgcmVhbGx5IGFueSBtZWFzdXJhYmxlIHBlcmZvcm1hbmNlIGJlbmVm
aXQgdG8gYWxpZ25pbmcgaXQgbGlrZQ0KPiB0aGlzPyBUaGVyZSBzaG91bGRu4oCZdCBhY3R1YWxs
eSBiZSBhbnkgYXRvbWljYWxseSDigJQgaXTigJlzIGp1c3QgYSBsaXR0bGUgZGF0YQ0KPiBzdHJ1
Y3R1cmUgdGVsbGluZyBldmVyeW9uZSB3aGF0IHRvIGRvLg0KDQpBdCB0aGUgdGltZSBJIG1lYXN1
cmVkIChJIGhhY2tlZCB0aGUgY29kZSB0byBmb3JjZSBtaXNhbGlnbm1lbnQpLCBhbmQgaXQgd2Fz
DQptYXJnaW5hbCAoaS5lLiwgaGFyZCB0byBzYXkpLg0KDQpIYXZpbmcgc2FpZCB0aGF0LCBpdCBz
ZWVtcyB0byBtZSBhcyBhIG1vcmUgc2NhbGFibGUgZGVzaWduIGNob2ljZS4gRnJvbSBhDQpicmll
ZiBsb29rLCB0aGUgdmFzdCBtYWpvcml0eSBvZiBvbl9lYWNoX2NwdSgpIGFyZ3VtZW50cyBhcmUg
b2ZmIHRoZSBzdGFjay4NCg0KQ29ycmVjdCBtZSBpZiBJIGFtIHdyb25nLCBidXQga2VlcGluZyB0
aGVtIG9mZiB0aGUgc3RhY2sgc2hvdWxkIGhlbHAsIG5vdA0Kb25seSBieSBwcmV2ZW50aW5nIHVu
YWxpZ25tZW50LCBidXQgYWxzbyBieSBwcmV2ZW50aW5nIHNvbWUgVExCIG1pc3NlczoNCnJpZ2h0
IG5vdyB0bGJfZmx1c2hfaW5mbyBpbnN0YW5jZXMgb2YgZGlmZmVyZW50IHRocmVhZHMgYXJlIGlu
IGRpZmZlcmVudA0KdmlydHVhbCBhZGRyZXNzZXMgKGFuZCBiZWNhdXNlIHRoZSBrZXJuZWwgc3Rh
Y2sgaXMgdm1hbGxvY+KAmWQsIGtlcm5lbCBzdGFjaw0KdmlydHVhbC1hZGRyZXNzIG1hcHBpbmdz
IGRvIG5vdCBzaGFyZSB0aGUgc2FtZSBUTEItZW50cnkpLg0KDQo=

