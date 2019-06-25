Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40B2FC48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECC382085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amperemail.onmicrosoft.com header.i=@amperemail.onmicrosoft.com header.b="PNJVSrq5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECC382085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B78C6B000D; Tue, 25 Jun 2019 18:30:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F20D8E0003; Tue, 25 Jun 2019 18:30:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CE1C8E0002; Tue, 25 Jun 2019 18:30:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12C1E6B000D
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y5so193767pfb.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=IR5atq9Kvn/HT6403Ciiera0O5RZONj4IbbxzbUzbhs=;
        b=GsWp4hEmD1Wb1tn//zxfCYJGkuRL8UbiuxumG6xkHVBWEqCchi+ryi71ki669q5wWq
         tjd9r8jmz0eBiJ8P/6pY8l28gUlJrUetEHS8ESLCEDSNFgTZg8wVtPt+S81T1p5TVK/S
         QeSSLie0IJBzCd6BtrAjxW5T055WsZMqCLFzY6WL/u0DrCcM4dkywyM8yi7GOY02vcQX
         PvA81lH3S0ob0UMP9XK88/3uVmkW0pILIBATff7sWOPdiBzZjq+lqISXhXqp6npegMn0
         Hv3vkA09aTGLzJLC4N34RVZ0pcwvf2+WA5V8tWOBJvvSK/jIjv/hEH4HbYV0f8GJfNvH
         m3+A==
X-Gm-Message-State: APjAAAW75J08r0YZ4JtuCBqfQxKvfgnMQ7YOAkjabouGdC7NPhBlkrTH
	rIEDhlGcJoObkg090/nfsWm8g2xJHeW+tOMMokTbYA6MEXn6bsTINDOLfOqZnSteHzod77OYTyn
	WOTyP8x/NxaFCU/n7l3KxrOVnVq8rIToWA3A2ljkKOnZkEI1frBlGU9ZHoLQS9/sGFQ==
X-Received: by 2002:a63:1d53:: with SMTP id d19mr41239256pgm.152.1561501838669;
        Tue, 25 Jun 2019 15:30:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuqA7hH7RTl3A8UFkRHBUJYQPSR8fswTbKDANkfL9nDopjcikBFc0+osRBrbbjkEzLb7EK
X-Received: by 2002:a63:1d53:: with SMTP id d19mr41239191pgm.152.1561501837692;
        Tue, 25 Jun 2019 15:30:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501837; cv=none;
        d=google.com; s=arc-20160816;
        b=iR9o+DQy9zk1h0UAXyUJSRtI+8y6KvLzPJMvBYVLtJh/eXhIkKs/gr3rxekkODRut1
         XhAhw8WN8yQPhsf5T48+x7eA/4vQlfVUUEZDjNAxWfGN95qIjXi0ny+rNoTuScDtD1C+
         wTa8rIhW5L9EqGKcqnuh1bkerRWF+yu0TPVtPpUS3Qk/ckA8/5/LtDOAdN8M02dHJo/T
         TKl9UxM9dEPS/cnH/q7WXQq0MeRODBN93OsncIuU0wfcvKkCJPON9pr1wZTenRQdPtzS
         X4PQTpIwJSZetZvIHK2M7cv/UImGujrSG70AmuYBWteNUrqgkMtRoyT3SaBrshalUx09
         +Z0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=IR5atq9Kvn/HT6403Ciiera0O5RZONj4IbbxzbUzbhs=;
        b=wBSDeStdwFgzSilJqFCMhZcfUXAe1KJiMKvc7lqiNOR0lNkw/UIwmoHt1wzTX5t+F9
         NTwh2UrfZOiUwsLn7iI2srNiS2G0qZPKs4AGEaqXZGDUICngkRxFLqcAjhzO3rDTAsOP
         Lt93O2TRGWlKyT279GWXhKMK4I8puUrorZfo0zk9cWnxj7ic0O8SIXhjECybq50cV2UT
         y7VN6DqacOummGecaEzCj4H51KZUkzTG2VgBwjqiG+OOit0nfvx7XIlZMM6wLAtzZ56j
         tjtmLBD3ZYI+Rs6bq56AobtqWnj94Iu5JNnnDkJbCuJg4fjRIPNA/gkxHtnQ/Q9Tkkjy
         MuRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=PNJVSrq5;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.126 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720126.outbound.protection.outlook.com. [40.107.72.126])
        by mx.google.com with ESMTPS id w12si1367988pld.301.2019.06.25.15.30.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:30:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.126 as permitted sender) client-ip=40.107.72.126;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=PNJVSrq5;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.126 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amperemail.onmicrosoft.com; s=selector2-amperemail-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=IR5atq9Kvn/HT6403Ciiera0O5RZONj4IbbxzbUzbhs=;
 b=PNJVSrq53wFMEcbUkb+rBKJMYatCrrSmj2MzNobtszUB5hj2Vth/b4FNoB7vT7FZwCR/QGZJTJqDVIN/tu/ioC3Ua+obMqdDp9pOyShXyQ5bA7vGx7jsqmuUW9KRCgdO9QL6kc5PuLHrhJAxoaHYc0xdCZaAFCsqHNF+JaAy+To=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.104.151) by
 DM6PR01MB5308.prod.exchangelabs.com (20.177.220.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 22:30:34 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3%7]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 22:30:34 +0000
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
Subject: [PATCH 5/5] s390: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 5/5] s390: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WaFJpFUz0LxkyiSb0RwDiB0g==
Date: Tue, 25 Jun 2019 22:30:34 +0000
Message-ID: <1561501810-25163-6-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: 94260bc5-6779-4195-4197-08d6f9bcbd01
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5308;
x-ms-traffictypediagnostic: DM6PR01MB5308:
x-microsoft-antispam-prvs:
 <DM6PR01MB5308BE2C2C64072EBD3A384FF1E30@DM6PR01MB5308.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:5797;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(1496009)(376002)(366004)(136003)(346002)(39850400004)(396003)(199004)(189003)(256004)(4326008)(53936002)(14454004)(4744005)(7736002)(52116002)(107886003)(50226002)(6486002)(81156014)(81166006)(64756008)(8936002)(66446008)(8676002)(6436002)(110136005)(26005)(5660300002)(99286004)(66946007)(73956011)(6506007)(76176011)(186003)(386003)(102836004)(66066001)(2906002)(446003)(305945005)(54906003)(2616005)(66556008)(66476007)(11346002)(316002)(476003)(6512007)(1511001)(478600001)(71190400001)(3846002)(71200400001)(7416002)(6116002)(86362001)(25786009)(68736007)(486006)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5308;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 GSuHyiAFzoB+d5Mz6ITaue+2ZU9Ek9+vBzZeNR8aJzm92J79Aq8uYHSjt3YK4GpsrdpH6z+4r8fVFt0I98L3jgZTKScoDtOsOg6fRsatO1urmA5ZhVV/CHZEnD/J2Y4HPRwZB1lN5GeqpU7AaKHT47kPa83tYp3sKjDFXZVGhPCPiFxElPGBqnEZy5gjFw3iR1KpjZCDheS6DvzS3ZIb6DbZSE0eZjkUwy01kWI9zGH8BHhIJ5zXs9TXqqsExXljs58PZjYm5Mo2ABlcyXIN1HdFSYTzbpvvhOYScbc6sbDvDvqiiST7uwKoy0tBO319wlKBg7mAndwf5UiaJojOe82qcZKkNqOYLs42MA21KRiYYdiCgxTRZ/O472EH7osVWXDxGKgGwsDLZpWJ10z43tiygTOQkQ0D/HLQ6OvbiAo=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 94260bc5-6779-4195-4197-08d6f9bcbd01
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 22:30:34.3305
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

VGhpcyBwYXRjaCByZW1vdmVzIENPTkZJR19OT0RFU19TUEFOX09USEVSX05PREVTIGFzIGl0J3MN
CmVuYWJsZWQgYnkgZGVmYXVsdCB3aXRoIE5VTUEuDQoNClNpZ25lZC1vZmYtYnk6IEhvYW4gVHJh
biA8SG9hbkBvcy5hbXBlcmVjb21wdXRpbmcuY29tPg0KLS0tDQogYXJjaC9zMzkwL0tjb25maWcg
fCA4IC0tLS0tLS0tDQogMSBmaWxlIGNoYW5nZWQsIDggZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1n
aXQgYS9hcmNoL3MzOTAvS2NvbmZpZyBiL2FyY2gvczM5MC9LY29uZmlnDQppbmRleCAxMDkyNDNm
Li43ODhhOGU5IDEwMDY0NA0KLS0tIGEvYXJjaC9zMzkwL0tjb25maWcNCisrKyBiL2FyY2gvczM5
MC9LY29uZmlnDQpAQCAtNDM4LDE0ICs0MzgsNiBAQCBjb25maWcgSE9UUExVR19DUFUNCiAJICBj
YW4gYmUgY29udHJvbGxlZCB0aHJvdWdoIC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdSMuDQog
CSAgU2F5IE4gaWYgeW91IHdhbnQgdG8gZGlzYWJsZSBDUFUgaG90cGx1Zy4NCiANCi0jIFNvbWUg
TlVNQSBub2RlcyBoYXZlIG1lbW9yeSByYW5nZXMgdGhhdCBzcGFuDQotIyBvdGhlciBub2Rlcy4J
RXZlbiB0aG91Z2ggYSBwZm4gaXMgdmFsaWQgYW5kDQotIyBiZXR3ZWVuIGEgbm9kZSdzIHN0YXJ0
IGFuZCBlbmQgcGZucywgaXQgbWF5IG5vdA0KLSMgcmVzaWRlIG9uIHRoYXQgbm9kZS4JU2VlIG1l
bW1hcF9pbml0X3pvbmUoKQ0KLSMgZm9yIGRldGFpbHMuIDwtIFRoZXkgbWVhbnQgbWVtb3J5IGhv
bGVzIQ0KLWNvbmZpZyBOT0RFU19TUEFOX09USEVSX05PREVTDQotCWRlZl9ib29sIE5VTUENCi0N
CiBjb25maWcgTlVNQQ0KIAlib29sICJOVU1BIHN1cHBvcnQiDQogCWRlcGVuZHMgb24gU01QICYm
IFNDSEVEX1RPUE9MT0dZDQotLSANCjIuNy40DQoNCg==

