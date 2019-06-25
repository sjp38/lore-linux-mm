Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E361C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325BD2085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amperemail.onmicrosoft.com header.i=@amperemail.onmicrosoft.com header.b="tmug3Ut7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325BD2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDA6C6B000A; Tue, 25 Jun 2019 18:30:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5DEC8E0003; Tue, 25 Jun 2019 18:30:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9AF078E0002; Tue, 25 Jun 2019 18:30:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0976B000A
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:32 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n8so113675ioo.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=jbppUUAYT2AfIAmhAET+jY1XsjbiX6rRh2UHg2M9od0=;
        b=bxeX/ACZ+uzVUylexsi6L9QNxRb28/QPctICo5ftUCiH5ptJq+VAiL1nQj7j2ja7jJ
         VqR1qUK7GVXInoSX848h5ezoQcD3rSG8D5QfXG40praiII7UpWRpIlJXIO2fkbAqtprq
         GcQVhZ9DnGzzgMcoyAmv/OsfRapg6nUkt4K4wViqmWdxUWyD74YbsBQqW6ZalYCvoB4x
         uFohPBz7gA15vrEsYJYYOLpu6M88dqGBwqPu4GEr8WgsDl8P5GNvAQXTEu1/s9/viP2l
         mM5ATcYDEGIqQ8l0SQ9X3bNW9jAfJOa54c/MxnRQ/47ZoPv0sTKkQCm5yEEP/IhMQ2oH
         jGJA==
X-Gm-Message-State: APjAAAWHvGUgaNkcpX+FYzjnSurvFEZS8MURx50Po9Glrjkkpzdfhryb
	WTHpWXc/Yu5lkqPsje9BECrRnK8aMefIIcfC0NP3Ig9pRTZq0th0zbXVrgFby3LOBfwPgizQ9za
	2cEZJWVdbXuE+mj1gEkQx31EdVf6KmgED+FXbCWGclFhetHR1dKLDprqWUT4OtuDA2g==
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr1288081iou.69.1561501832289;
        Tue, 25 Jun 2019 15:30:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyN+cJRnFDgB8UVU9D44aSA0BMWLGglp0qT6EQZ8CWUkxhVGtunYPSpnjdmbY3oENs9WvW
X-Received: by 2002:a6b:14c2:: with SMTP id 185mr1288002iou.69.1561501831413;
        Tue, 25 Jun 2019 15:30:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501831; cv=none;
        d=google.com; s=arc-20160816;
        b=CjVHLG/lklIn/y8KXGmBgVDDqeAbsTkLRIDGqfMeFBsrvocDDTKhn9j0ixt8Q1EyRR
         drF1iYEDgCu0rqSl0Nk5u35CreAF+x0lD8OHFUGXdtbPWyoHRa2WcPPjSEUVZNkWsimE
         S1GaWw0IPkoHQKg7ILsjmEH2IPzxS+mmTDGu8dD3z+06JI28E32cr/XSzUe5wDLRbMkn
         tAaCOv1LupZ/51kT/A1FIZ1yJ84meztJVGbu+FbySngp+Wq26fHe7UP6X8W6olqVzzrC
         pE0nGg8GtUHkQGm/n1nSDj4wDHLHyu45NMW264n9z9KVD2BADRtQQon6fC49SXsEZ4CY
         oSiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=jbppUUAYT2AfIAmhAET+jY1XsjbiX6rRh2UHg2M9od0=;
        b=dBld8jXzbT9pF3gyyDw/zYfCxqD3I953k4LHPUzXFrWosPfba9Ci2nElgZdA9Z4OWN
         65Huo/KQ1DhszjFpYO/zaRQ89CzyDICO0JfzCRtUagiB7FS6i8StXpt9V/kdrL65sdFt
         Ah+Yod8Su+XI6s2l0c9DDhaHtaTuc7rY3u9fJoVQdqzoUNbtLQvfBEPsSr+uN3QsLvuC
         TmXGfhIEmKPv6416+ewngokZAgkmD2s7oPHkuR6ZMTDAskWMkh+CZ3W2MClytMdwu8gs
         FFOYDFTmraaolIEWLfd96RPJNAhUyhsUICibn56u2n2bxuojM0wx4q6LHT+RJkHH2lLD
         hLkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=tmug3Ut7;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.109 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720109.outbound.protection.outlook.com. [40.107.72.109])
        by mx.google.com with ESMTPS id p24si18741993ioj.51.2019.06.25.15.30.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:30:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.109 as permitted sender) client-ip=40.107.72.109;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=tmug3Ut7;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.109 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amperemail.onmicrosoft.com; s=selector2-amperemail-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jbppUUAYT2AfIAmhAET+jY1XsjbiX6rRh2UHg2M9od0=;
 b=tmug3Ut725wpACc8ydAqEn/tFctxP9ckcgxYgKTDsO92sz7FdLTiIDzgtbCIkboN/JZ3tJaaJ5yIDahgJjqnJHpGJS95sWIzdPoGaaD1tXTIRrhqIbrJ49W7BcCdKiaRuMZuzm02YGl3B3WmSTUfXpn2o2b1H6EAJNX558j1hDY=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.104.151) by
 DM6PR01MB5308.prod.exchangelabs.com (20.177.220.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 22:30:29 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3%7]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 22:30:29 +0000
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
Subject: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 3/5] x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WX71HRsQts10W3HaW79T6UPw==
Date: Tue, 25 Jun 2019 22:30:29 +0000
Message-ID: <1561501810-25163-4-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: 16a4bc1b-35a8-4854-ac90-08d6f9bcba32
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5308;
x-ms-traffictypediagnostic: DM6PR01MB5308:
x-microsoft-antispam-prvs:
 <DM6PR01MB530883287863A748E182FE2DF1E30@DM6PR01MB5308.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(39840400004)(346002)(396003)(199004)(189003)(256004)(4326008)(53936002)(14454004)(4744005)(7736002)(52116002)(107886003)(50226002)(6486002)(81156014)(81166006)(64756008)(8936002)(66446008)(8676002)(6436002)(110136005)(26005)(5660300002)(99286004)(66946007)(73956011)(6506007)(76176011)(186003)(386003)(102836004)(66066001)(2906002)(446003)(305945005)(54906003)(2616005)(66556008)(66476007)(11346002)(316002)(476003)(6512007)(1511001)(478600001)(71190400001)(3846002)(71200400001)(7416002)(6116002)(86362001)(25786009)(68736007)(486006)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5308;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 XGqFPyOpimu48tsAkwftSFmED4Px3bP5sV6qJN03m59v8RJn4jMS79/UnHNsZeW4EXKFHP9t9N+pO+r8hq1nOpwO+WsLfsVY6RolBd3Cpcn9CjAB4ohVNIM4ZlzUEtSrjp4K9fW+iSF2OgNm5h9iq2pmulMeD1GBeEcegNJMnJ6iGnz9byQWXpF+vOX358HRhwkj+yWXTeA/83kixGMdJK7ShMTo5eVkt0v6EdFm9PAnbnO8dtaVUBoOI3xYADSwKBqP7o0LCsH7fwuITmByyr0IXdx2VcNH49Qise8qi34VIhHl1acNnK0NR3WLMSQYAw50479HPnNcofF1HdIxTF3PSxhQgVrCRtXFYua39kh9rt6q4nzbW0cLdbS5aK8jcElQvH1KIs76zUukiOEf60CkY/O1mWJSvR17VGjDTF8=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 16a4bc1b-35a8-4854-ac90-08d6f9bcba32
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 22:30:29.6312
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
biA8SG9hbkBvcy5hbXBlcmVjb21wdXRpbmcuY29tPg0KLS0tDQogYXJjaC94ODYvS2NvbmZpZyB8
IDkgLS0tLS0tLS0tDQogMSBmaWxlIGNoYW5nZWQsIDkgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1n
aXQgYS9hcmNoL3g4Ni9LY29uZmlnIGIvYXJjaC94ODYvS2NvbmZpZw0KaW5kZXggMmJiYmQ0ZC4u
ZmE5MzE4YyAxMDA2NDQNCi0tLSBhL2FyY2gveDg2L0tjb25maWcNCisrKyBiL2FyY2gveDg2L0tj
b25maWcNCkBAIC0xNTY3LDE1ICsxNTY3LDYgQEAgY29uZmlnIFg4Nl82NF9BQ1BJX05VTUENCiAJ
LS0taGVscC0tLQ0KIAkgIEVuYWJsZSBBQ1BJIFNSQVQgYmFzZWQgbm9kZSB0b3BvbG9neSBkZXRl
Y3Rpb24uDQogDQotIyBTb21lIE5VTUEgbm9kZXMgaGF2ZSBtZW1vcnkgcmFuZ2VzIHRoYXQgc3Bh
bg0KLSMgb3RoZXIgbm9kZXMuICBFdmVuIHRob3VnaCBhIHBmbiBpcyB2YWxpZCBhbmQNCi0jIGJl
dHdlZW4gYSBub2RlJ3Mgc3RhcnQgYW5kIGVuZCBwZm5zLCBpdCBtYXkgbm90DQotIyByZXNpZGUg
b24gdGhhdCBub2RlLiAgU2VlIG1lbW1hcF9pbml0X3pvbmUoKQ0KLSMgZm9yIGRldGFpbHMuDQot
Y29uZmlnIE5PREVTX1NQQU5fT1RIRVJfTk9ERVMNCi0JZGVmX2Jvb2wgeQ0KLQlkZXBlbmRzIG9u
IFg4Nl82NF9BQ1BJX05VTUENCi0NCiBjb25maWcgTlVNQV9FTVUNCiAJYm9vbCAiTlVNQSBlbXVs
YXRpb24iDQogCWRlcGVuZHMgb24gTlVNQQ0KLS0gDQoyLjcuNA0KDQo=

