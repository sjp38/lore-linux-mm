Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 059D3C31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:42:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FF8E2147A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 17:42:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="rjW6qig6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF8E2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 172416B0003; Tue, 18 Jun 2019 13:42:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 123F08E0002; Tue, 18 Jun 2019 13:42:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 011668E0001; Tue, 18 Jun 2019 13:42:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A955F6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:42:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12so22249179eds.14
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:42:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=w6JzkPR9QDBk+QB3uy5PkkeQhwYX3KI/2LLcSwk5al0=;
        b=Mb3lh3gR6RM1mUpdxR/OEPSAqyIFzwJrLFxOsKgRy3IsyZUzeJ+VXy0g8sGR0bOsK/
         KZhXRFbzhD0i63gVcroPCtiOmUmYMfOT+OrxtZzYDgPoDlq8+470Av1r56Eo/fG0Lixz
         msueEN8W3VQjRm+KKesnNDl39BL9rkkbx5HsvPCo8fqFdKHGjfZD3gRhw+H/CQc+Q/Pb
         Eyb3vxSZU1Cq6cCT3IblzMUr9+5FDrjl3g9XOZFz9xCsWsw2ea706RoGz4F/MciLuEAm
         LSMwp8lw5M2XrhXSs22Esybppi+M0KRH6p7wcipAhA6tBM5ihJ/iBKrBQ4sTfHa+OwiO
         nnCA==
X-Gm-Message-State: APjAAAX/7F7Nlm3++ODs9blIJBP+NOYwqY1Pu+PxJgjf5TIXlGJjf1Rf
	lrNI3JletVTHWpxey/ZqJtFsA44Yk4o4wIJmCb/+n2H1zEZqjgY+phox5D8sZnzDMW6/wqfyU0E
	MSeitgn5ncRaO5ZKE/mXkbDeUU6Y7SfR6KHvmx1TNkA4eSN14Q3ZVx8lLAdVQvVK3TA==
X-Received: by 2002:a17:906:838a:: with SMTP id p10mr10148000ejx.237.1560879729940;
        Tue, 18 Jun 2019 10:42:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOpd4AUMoUUL1csL79QspRq0xHPTgBMcxvy/OtC728W93rvA/FBcDOk+3I313gDTHWG1er
X-Received: by 2002:a17:906:838a:: with SMTP id p10mr10147936ejx.237.1560879729005;
        Tue, 18 Jun 2019 10:42:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560879729; cv=none;
        d=google.com; s=arc-20160816;
        b=A2zXY38UBJYPbh6UYjLpUbPGJmW0JL76rNgQAEYIgTl2F0nPsUu+rCHid5GR88fCA/
         DUMa+nHprkC/Gd8IY6ikNYdkA3F6AiBUtUAol2v4eckpSVtyqgg4fBj7NFwQq+f7abIr
         1Z/jB/s02gJXKqY4kYU+X3XVxxi+WM1VWUd0AK2tGkOmqE4u0z6CjYYD8zupE2vnZhid
         w567GmO6g8kdfEii/BX+GojrO/7fyPKXjYEOuZjHXGmqX9MNs8xbVh/xXTj/qjQF5wio
         STDjN+PtPNjI6VjqogWWlcywIZnlgUsYBLaRdBcAjTX7Uc5Agfrn1fiW8HRWGDVrQBBy
         b1tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=w6JzkPR9QDBk+QB3uy5PkkeQhwYX3KI/2LLcSwk5al0=;
        b=DVUz8ybqBpJtECQiuVij4M8x9JnsP0tGoon+57NS56wkvaxinPOvjUGtO/TmQLUJcO
         +VdZN0yXgrSSHEOcxi3LllLxHJe8nYaiZEGOQcS/PjtWWJf6CWQenpz1JskWqWCOsY+Q
         7IJiQRnLcvSK6I2f1WKdELlZpmLXTOWv0jhfLpMSlevH8i71dtg9aIB1T4zbRYSpBR78
         hKE09MCRAnUhRQOG2NVqs7n9gZriekfmjxGSYJhA2q7akLpiSxbIrH5a89ytgDU9RHcH
         edPHbTT8z7+NbvRa22ZXDFMJ+FI0bHKuvHcza6GHLTVVjzKf6/ZC63rxVwqGXIXshqkC
         A5pQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=rjW6qig6;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.82 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800082.outbound.protection.outlook.com. [40.107.80.82])
        by mx.google.com with ESMTPS id l28si11061606edb.261.2019.06.18.10.42.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Jun 2019 10:42:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.80.82 as permitted sender) client-ip=40.107.80.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=rjW6qig6;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.82 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=w6JzkPR9QDBk+QB3uy5PkkeQhwYX3KI/2LLcSwk5al0=;
 b=rjW6qig6fjWShvsiuOghfkNOo5S+Jzgl7V3lNJRxl39QtR+8nlyjnPl+hjZ/u4UBpM5GVF+Nhvh+gXuZEiFT8KYB5D2NIcxk4ELRV5Pqx6aXq9QlEZiX0RiQP0hLFqSfOO5LMDNyEU7u4lwAU/cVH66tC5GyhQrNmb3dC+OO9yo=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6630.namprd05.prod.outlook.com (20.179.60.204) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.12; Tue, 18 Jun 2019 17:42:06 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Tue, 18 Jun 2019
 17:42:06 +0000
From: Nadav Amit <namit@vmware.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bjorn
 Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Topic: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Index: AQHVIaTGJ7ym4R/nDEy6A26DLGCJOaag/0oAgAC3tYA=
Date: Tue, 18 Jun 2019 17:42:06 +0000
Message-ID: <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
In-Reply-To:
 <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 583d96b3-9c55-4bb4-123d-08d6f414481e
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB6630;
x-ms-traffictypediagnostic: BYAPR05MB6630:
x-microsoft-antispam-prvs:
 <BYAPR05MB663062DBB97317948E0F9B9CD0EA0@BYAPR05MB6630.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 007271867D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(346002)(39860400002)(396003)(136003)(376002)(189003)(199004)(8676002)(7416002)(305945005)(8936002)(6512007)(68736007)(81156014)(7736002)(2906002)(3846002)(66066001)(6116002)(316002)(66946007)(5660300002)(64756008)(66556008)(66446008)(86362001)(66476007)(11346002)(446003)(14444005)(256004)(73956011)(76116006)(6916009)(36756003)(2616005)(33656002)(54906003)(14454004)(76176011)(102836004)(81166006)(6486002)(186003)(476003)(486006)(26005)(478600001)(6246003)(53936002)(25786009)(71190400001)(6506007)(99286004)(6436002)(71200400001)(4326008)(53546011)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6630;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 C5ILFoWOoBxqi0qVa1f/8QUZRdIyMIwIq52U7FNHhGS8q9gzPCjaGcbsp4fwMqBT4kYCv7Ynzk+a0KZ67XK/Etkz3xRIw6bgYqP3REIgILb2oXhlpgEdeU1pPlSB4GF2ySx8sxgjdeqSW9G5dthU1ATrb6QAe3NontDGBql73J7k8fCKPXPOtgop3mvdGc/85Fq/Y65EPK9ypTqf73QYaNhsPkmhg4WPY6IsWkjIZ/tsUhoiQPlea7w6pkjbk3NWBS6ooTA8rhwQKtXQ4ridrDW2nO8Kh9CziK3WfDWfgeI/EIMDyw13/xeNYt8TW9B8oZiBiKV4szSp5GV/mms+jfFf1GiGii7qffe+hb9hMYWa1j2NlbuqRUDNmEqkErbsnGGVEHxinSuMKYSaO5Ok3BU90+plULJPW/HlM6L0gbg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <8B3066CA312C354E921B3D0BA8A0EE0D@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 583d96b3-9c55-4bb4-123d-08d6f414481e
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Jun 2019 17:42:06.4138
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6630
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTcsIDIwMTksIGF0IDExOjQ0IFBNLCBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxp
YW1zQGludGVsLmNvbT4gd3JvdGU6DQo+IA0KPiBPbiBXZWQsIEp1biAxMiwgMjAxOSBhdCA5OjU5
IFBNIE5hZGF2IEFtaXQgPG5hbWl0QHZtd2FyZS5jb20+IHdyb3RlOg0KPj4gUnVubmluZyBzb21l
IG1pY3JvYmVuY2htYXJrcyBvbiBkYXgga2VlcHMgc2hvd2luZyBmaW5kX25leHRfaW9tZW1fcmVz
KCkNCj4+IGFzIGEgcGxhY2UgaW4gd2hpY2ggc2lnbmlmaWNhbnQgYW1vdW50IG9mIHRpbWUgaXMg
c3BlbnQuIEl0IGFwcGVhcnMgdGhhdA0KPj4gaW4gb3JkZXIgdG8gZGV0ZXJtaW5lIHRoZSBjYWNo
ZWFiaWxpdHkgdGhhdCBpcyByZXF1aXJlZCBmb3IgdGhlIFBURSwNCj4+IGxvb2t1cF9tZW10eXBl
KCkgaXMgY2FsbGVkLCBhbmQgdGhpcyBvbmUgdHJhdmVyc2VzIHRoZSByZXNvdXJjZXMgbGlzdCBp
bg0KPj4gYW4gaW5lZmZpY2llbnQgbWFubmVyLiBUaGlzIHBhdGNoLXNldCB0cmllcyB0byBpbXBy
b3ZlIHRoaXMgc2l0dWF0aW9uLg0KPiANCj4gTGV0J3MganVzdCBkbyB0aGlzIGxvb2t1cCBvbmNl
IHBlciBkZXZpY2UsIGNhY2hlIHRoYXQsIGFuZCByZXBsYXkgaXQNCj4gdG8gbW9kaWZpZWQgdm1m
X2luc2VydF8qIHJvdXRpbmVzIHRoYXQgdHJ1c3QgdGhlIGNhbGxlciB0byBhbHJlYWR5DQo+IGtu
b3cgdGhlIHBncHJvdF92YWx1ZXMuDQoNCklJVUMsIG9uZSBkZXZpY2UgY2FuIGhhdmUgbXVsdGlw
bGUgcmVnaW9ucyB3aXRoIGRpZmZlcmVudCBjaGFyYWN0ZXJpc3RpY3MsDQp3aGljaCByZXF1aXJl
IGRpZmZlcmVuY2UgY2FjaGFiaWxpdHkuIEFwcGFyZW50bHksIHRoYXQgaXMgdGhlIHJlYXNvbiB0
aGVyZQ0KaXMgYSB0cmVlIG9mIHJlc291cmNlcy4gUGxlYXNlIGJlIG1vcmUgc3BlY2lmaWMgYWJv
dXQgd2hlcmUgeW91IHdhbnQgdG8NCmNhY2hlIGl0LCBwbGVhc2UuDQoNClBlcmhhcHMgeW91IHdh
bnQgdG8gY2FjaGUgdGhlIGNhY2hhYmlsaXR5LW1vZGUgaW4gdm1hLT52bV9wYWdlX3Byb3QgKHdo
aWNoIEkNCnNlZSBiZWluZyBkb25lIGluIHF1aXRlIGEgZmV3IGNhc2VzKSwgYnV0IEkgZG9u4oCZ
dCBrbm93IHRoZSBjb2RlIHdlbGwgZW5vdWdoDQp0byBiZSBjZXJ0YWluIHRoYXQgZXZlcnkgdm1h
IHNob3VsZCBoYXZlIGEgc2luZ2xlIHByb3RlY3Rpb24gYW5kIHRoYXQgaXQNCnNob3VsZCBub3Qg
Y2hhbmdlIGFmdGVyd2FyZHMuDQoNCg==

