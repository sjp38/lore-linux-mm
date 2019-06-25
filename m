Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5191FC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0664F20883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amperemail.onmicrosoft.com header.i=@amperemail.onmicrosoft.com header.b="hWuH37JS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0664F20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 012C16B0007; Tue, 25 Jun 2019 18:30:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE1948E0003; Tue, 25 Jun 2019 18:30:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE7948E0002; Tue, 25 Jun 2019 18:30:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 922E56B0007
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:29 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id e95so84692plb.9
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=euhzYvd1r7uvcEPyDcPjPn2ACbogTaQr3g8dE0atYmY=;
        b=im/CSEZltgidUMETAiQ6sKWKqyb/EVofOOdFzG95kSJK2fwlFnLK8s5QodwtmxFWFm
         kd29xlNUA3Y6mxKVvn0+QCtUWv06gpdSaku6KugCG+S8b7ZGqfUbmCkC/nrmw38Q/7Sy
         ij9+ZkeeZQwi0ppwp7IFuZjiQkMczCzHZYSM/u4HhzZLuaksdIZqoI1UtS6NJeXHe8+D
         Ljyjdf0vM/8SG8oLqiftEsUtitwLmcBSo2z19CYRJg16vQf8mXX1nHey2/bxXQRX0iVr
         0FNclhAQAyzoFeJMudaqrpbdZbVG6w/ELmfBxBEWNQ2BQTLodFtISQiOwHITnhl+5dKE
         J3Rw==
X-Gm-Message-State: APjAAAXyEgGi67DWmB2sn7TL7ZLVh2fxGyRl0M1CK9Z0b+w5KIS0tsvz
	N0dUK9Ryyuq1Xbo3dxgU6NxppI8g91sRYLHKGAHprg/7zCfAxjlv/QDGopCvUfXMwM6oxDJl8L5
	Dh0JvTom5glZp75Ez6B2YtSz4qy7HwzakyptuQJQnfk8MJAboj/w7PJ/atKspXs3jgA==
X-Received: by 2002:a63:e40a:: with SMTP id a10mr8004315pgi.277.1561501829152;
        Tue, 25 Jun 2019 15:30:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnDT7zCjCVhGCpHM7lq4Pv/26MPMEUJOHevOvq2VI+P+D83LP2kYQEfMVaBG6vnXjMfIyb
X-Received: by 2002:a63:e40a:: with SMTP id a10mr8004238pgi.277.1561501828059;
        Tue, 25 Jun 2019 15:30:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501828; cv=none;
        d=google.com; s=arc-20160816;
        b=L4vdnCtLFINng4yu9HgC73g74nFItSFXORhPO8YWjHy98vwJ42S24YoKPP2x0nDmGx
         bKwwS6SWmj6WegWsDYQBkWDAUUqdHPadc4e/O9w3vkUIKtz9zLjKWBCYG+ZszF0Wkz3S
         8ON+DhY4YP1x7PkqHNe4hQb1k2AByNYCSojSReS9z8CywiEIGS8aWG9NJ37ArlY8XDAj
         Wujfgaka3eDwmAOuo9AsiN9TEIkCHGKc38TlUOb+MwupeBucUOa2gCKv/tRxK8Ci/qcW
         sgFe8e7dJffVjLKYVsU3K/LK9J0qZ/6fVyYe+lmHhvublrqgLGOu9v0ym6eIgKUHyUXV
         aU5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=euhzYvd1r7uvcEPyDcPjPn2ACbogTaQr3g8dE0atYmY=;
        b=J/v3Sfhn+7GGsmz2ENGMKyx92AWCrja6eR0z5WulbD5JzwL8KHCufUATETY4urBq4a
         UI8k9si4ml86vr1IH2xJvCEUusKq7OVTa5suY4HFx/gALj6FWEgN2vNZoFforF3SJSwW
         blEc788VB30RW1tvgWDRwi+bkxlReVnH5ayJEE4/+j4ljKXxb7N+Yu/UtSqHRdAb99I3
         9XPxnd5c9bFz1lUuKl9+mqy6CRrezPKF6969wiOtD0X1KimfMte0CD71vdkW+LE36Gfl
         xyNncEMtah7iyabw+JASeJWMqtIx9H6bJwb3QlNo79tZSQlXC/akpTBorEWBcFRIB2A9
         UAjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=hWuH37JS;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.135 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720135.outbound.protection.outlook.com. [40.107.72.135])
        by mx.google.com with ESMTPS id x11si1294958pln.292.2019.06.25.15.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:30:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.135 as permitted sender) client-ip=40.107.72.135;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=hWuH37JS;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.135 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amperemail.onmicrosoft.com; s=selector2-amperemail-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=euhzYvd1r7uvcEPyDcPjPn2ACbogTaQr3g8dE0atYmY=;
 b=hWuH37JS6kJL6fDrNgkLUCqW2NN7+VxEL8btwNK6VAonyk13RrN+Kd/w66VaVxd50OT33F2oRKfXGVEDU1VphkC5196a8KzRP1JH3/Y2Z58hVisVKF667W0ho3bvXg0VwxD1RBbLg6Hg4OwymaBvG+Q7wkGyW6z8/VpODif2Si4=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.104.151) by
 DM6PR01MB5308.prod.exchangelabs.com (20.177.220.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 22:30:25 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3%7]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 22:30:25 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador
	<osalvador@suse.de>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike
 Rapoport <rppt@linux.ibm.com>, Alexander Duyck
	<alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin"
	<hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, Heiko Carstens
	<heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>
CC: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>, Hoan Tran OS
	<hoan@os.amperecomputing.com>
Subject: [PATCH 1/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for
 NUMA
Thread-Topic: [PATCH 1/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default
 for NUMA
Thread-Index: AQHVK6WVXavbpwRBlkOB7/lZ/263cg==
Date: Tue, 25 Jun 2019 22:30:24 +0000
Message-ID: <1561501810-25163-2-git-send-email-Hoan@os.amperecomputing.com>
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
In-Reply-To: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR22CA0052.namprd22.prod.outlook.com
 (2603:10b6:903:ae::14) To DM6PR01MB4090.prod.exchangelabs.com
 (2603:10b6:5:2a::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.7.4
x-originating-ip: [4.28.12.214]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 54d110de-2645-4945-6b5f-08d6f9bcb750
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5308;
x-ms-traffictypediagnostic: DM6PR01MB5308:
x-microsoft-antispam-prvs:
 <DM6PR01MB5308134E4F92AC83B9F41E0CF1E30@DM6PR01MB5308.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:4502;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(39840400004)(346002)(396003)(199004)(189003)(256004)(14444005)(4326008)(53936002)(14454004)(4744005)(7736002)(52116002)(107886003)(50226002)(6486002)(81156014)(81166006)(64756008)(8936002)(66446008)(8676002)(6436002)(110136005)(26005)(5660300002)(99286004)(66946007)(73956011)(6506007)(76176011)(186003)(386003)(102836004)(66066001)(2906002)(446003)(305945005)(54906003)(2616005)(66556008)(66476007)(11346002)(316002)(476003)(6512007)(1511001)(478600001)(71190400001)(3846002)(71200400001)(7416002)(6116002)(86362001)(25786009)(68736007)(486006)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5308;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 CEXZuBe95/lYRW5/9KlScxk8rGpPV293bD8Vi6Rh5tQlobN+G3BVpTMBkzIwLqZA3JnpW75P5jbhDcseEyaV4yQumftk8B4hwv9UnLNekXhEWoFpQuM69sMoA0BfDB16tqtN8FEcJ4PcaHSwBkwlYnSEnYUjIKeM031kkz9h1LtFXL0CL7cRcSpZ516oR3E862gIXjE5L2W6BAO3B9nvcTeqO2CqyOYm2JcOMmPIqcgWKlJcJ9Bhejmz3FyGkXfE9a5Z/hlRY3yCPNL6RrGvRY9INmmYGDJG9Mccl+HGbjtHkEhI/dBpJpOE39eflNG3de85pFPmdlgwoRPaMEYM586dCirgDs3L5jJ8uo9SX51LNFWysDoQ8HH+30UoMM1JQo3+JgEQEsjqQxM1O2ic9ZErXeDzueFsyIuXvfRrXR4=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 54d110de-2645-4945-6b5f-08d6f9bcb750
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 22:30:24.9479
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR01MB5308
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VGhpcyBwYXRjaCBlbmFibGVzIENPTkZJR19OT0RFU19TUEFOX09USEVSX05PREVTIGJ5IGRlZmF1
bHQNCmZvciBOVU1BLiBBcyBzb21lIE5VTUEgbm9kZXMgaGF2ZSBtZW1vcnkgcmFuZ2VzIHRoYXQg
c3BhbiBvdGhlcg0Kbm9kZXMuIEV2ZW4gdGhvdWdoIGEgcGZuIGlzIHZhbGlkIGFuZCBiZXR3ZWVu
IGEgbm9kZSdzIHN0YXJ0IGFuZA0KZW5kIHBmbnMsIGl0IG1heSBub3QgcmVzaWRlIG9uIHRoYXQg
bm9kZS4NCg0KU2lnbmVkLW9mZi1ieTogSG9hbiBUcmFuIDxIb2FuQG9zLmFtcGVyZWNvbXB1dGlu
Zy5jb20+DQotLS0NCiBtbS9wYWdlX2FsbG9jLmMgfCAyICstDQogMSBmaWxlIGNoYW5nZWQsIDEg
aW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQoNCmRpZmYgLS1naXQgYS9tbS9wYWdlX2FsbG9j
LmMgYi9tbS9wYWdlX2FsbG9jLmMNCmluZGV4IGQ2NmJjOGEuLjYzMzU1MDUgMTAwNjQ0DQotLS0g
YS9tbS9wYWdlX2FsbG9jLmMNCisrKyBiL21tL3BhZ2VfYWxsb2MuYw0KQEAgLTE0MTMsNyArMTQx
Myw3IEBAIGludCBfX21lbWluaXQgZWFybHlfcGZuX3RvX25pZCh1bnNpZ25lZCBsb25nIHBmbikN
CiB9DQogI2VuZGlmDQogDQotI2lmZGVmIENPTkZJR19OT0RFU19TUEFOX09USEVSX05PREVTDQor
I2lmZGVmIENPTkZJR19OVU1BDQogLyogT25seSBzYWZlIHRvIHVzZSBlYXJseSBpbiBib290IHdo
ZW4gaW5pdGlhbGlzYXRpb24gaXMgc2luZ2xlLXRocmVhZGVkICovDQogc3RhdGljIGlubGluZSBi
b29sIF9fbWVtaW5pdCBlYXJseV9wZm5faW5fbmlkKHVuc2lnbmVkIGxvbmcgcGZuLCBpbnQgbm9k
ZSkNCiB7DQotLSANCjIuNy40DQoNCg==

