Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F899C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC1AA2133F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amperemail.onmicrosoft.com header.i=@amperemail.onmicrosoft.com header.b="tl5kLG+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC1AA2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A5C46B000C; Tue, 25 Jun 2019 18:30:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E2F88E0003; Tue, 25 Jun 2019 18:30:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 433EF8E0002; Tue, 25 Jun 2019 18:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E02D6B000C
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:35 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v4so307904qkj.10
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=Vt+HabkNi3oBlcwR9P0Dy5I9Fh4hEa8N26FlS1Wo8xA=;
        b=jpC0vNf8NVPbYfebvQtRLDn1iUpGtecOp/yR25g/SezIqTju1APPCGHvNIKEe9ETwu
         9Mt4vmhmPglZTpcgX4X2bN59/2YNvntfEupf1/+Crdyl6w9Yel0Y0zMWDZJPusYeOUpH
         4RDmnfkAis3lNq0Emms42Y2wrgukywioscRGyzaqhYLJGuTSTxuvLzTrydhfu8oZ/GwX
         AfPZu9q1KObawv3m0Bis2I00sgxjmxtAfuI+DIT33liid21yE+JPH8ocgOGeiGmhYlOD
         q9zWlpFQtnT+fG0qdoM8k2UNJk99I3k3Pc+WIRXN1tMfeWVFhxBi97LdcqPUp+bdTX91
         bRJA==
X-Gm-Message-State: APjAAAX9xjcz5sh7ypdGwLIjdJWrqjYSnyO/IUcv0E5ESpldQuTwBwbZ
	TO0Hod8gjBDV+RTyJEk24BHSRAae+xid0+N5uVZQvOXX3hLhrf9tQeUxBBi8d8Ud192Y7NpnO7+
	PfeaUMpbA57+i1I+oc1rSzMfyGFYf72s98I1YpVT56hNPnrh2N/vO1BWkRdsZisrxkA==
X-Received: by 2002:a0c:d295:: with SMTP id q21mr603293qvh.245.1561501834888;
        Tue, 25 Jun 2019 15:30:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyePZYDmIgqNCs0tjPO/MDEzfqx9+QM31dYEWZD4rYt+UqXFqMX+f2txZzAzX1gfXcI1QFI
X-Received: by 2002:a0c:d295:: with SMTP id q21mr603255qvh.245.1561501834171;
        Tue, 25 Jun 2019 15:30:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501834; cv=none;
        d=google.com; s=arc-20160816;
        b=O0N9HsRKSybATHBcLsx3ELPbsy64lsj5CGl5GjqfMEsARzSvQJYwta2Si82qqXwc0T
         leIRrjH7XnXW6MuYlCSgSEq6K7wLy84MtRLovxrha+03cnsAS6gX52D/hlCwe2GR71B6
         qFP6FtYQNgL0yguOkPBuoZtqkm7X7gKy9xcb0rFXmRbYfeyiHAVJ7f2k+5B2V0GYye2T
         pSCCyG0AT2bQnz5amVvJQVpHx5naZrJbrO68d7YENyGro8soJFT40TowJN4DugWshfJQ
         7dgfkzFC8PoNCze2FB10ByOdmDvssM8o6eHMR7d1IITy2PVUcoD0JH5McKQb8jjZy7zR
         1OBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Vt+HabkNi3oBlcwR9P0Dy5I9Fh4hEa8N26FlS1Wo8xA=;
        b=ZFDHMI0E250rvm0yuuFNwCCIpSfAauLSp+tWXoGH0SKHOJKdWt7OSH/GfNABxidZ7Q
         boSp13B9KkohYz+g5rIJXpkW46uceiWM6zy5/imLau9gH9sEAB8t9HuPXLE1EZ1rOFCl
         fc2X0GdrAOA+c2BvnxvBYE/L6/abDzx61/2laAZpcRkO+GC/pl5pFJP82n1AmQeXJciY
         grxmFHiMrKO+M2YmMLm3VyHfddMp47N41fPxLWJ4AAQS9ZUkweBhOZSDnPWP6JmtexXA
         YnESEKxW3YqRb9vJsyR7tV5eVWDpMfenM1yXXZD9aJBaMaKmRd9/B1pujzvgb+JWNrtG
         4dLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=tl5kLG+F;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.71.120 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710120.outbound.protection.outlook.com. [40.107.71.120])
        by mx.google.com with ESMTPS id m38si10340986qtb.297.2019.06.25.15.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:30:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.71.120 as permitted sender) client-ip=40.107.71.120;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=tl5kLG+F;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.71.120 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amperemail.onmicrosoft.com; s=selector2-amperemail-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Vt+HabkNi3oBlcwR9P0Dy5I9Fh4hEa8N26FlS1Wo8xA=;
 b=tl5kLG+F/ZxeUncNApafR3A3hnieZCjtVi/r2CtMDWWD6Intf7mN7xpK1IbFnNVtPJKWLeD4x/s2qX1judL+pAK12YEoaZhKjyK5LvIs7ykvDRNNYWDHAzE3LcE+b82OaA2mameLRqNPDkPcPSGyexhDrpGK9x5b6ER51el9iDk=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.104.151) by
 DM6PR01MB5308.prod.exchangelabs.com (20.177.220.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 22:30:32 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3%7]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 22:30:32 +0000
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
Subject: [PATCH 4/5] sparc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 4/5] sparc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WZI7UguJlWOkuVRwnfzmC1hg==
Date: Tue, 25 Jun 2019 22:30:31 +0000
Message-ID: <1561501810-25163-5-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: aaa15bc7-af34-4434-1e22-08d6f9bcbb9a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5308;
x-ms-traffictypediagnostic: DM6PR01MB5308:
x-microsoft-antispam-prvs:
 <DM6PR01MB53087B96404675BB68A3EAC6F1E30@DM6PR01MB5308.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:6790;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(979002)(376002)(366004)(136003)(39840400004)(346002)(396003)(199004)(189003)(256004)(4326008)(53936002)(14454004)(4744005)(7736002)(52116002)(107886003)(50226002)(6486002)(81156014)(81166006)(64756008)(8936002)(66446008)(8676002)(6436002)(110136005)(26005)(5660300002)(99286004)(66946007)(73956011)(6506007)(76176011)(186003)(386003)(102836004)(66066001)(2906002)(446003)(305945005)(54906003)(2616005)(66556008)(66476007)(11346002)(316002)(476003)(6512007)(1511001)(478600001)(71190400001)(3846002)(71200400001)(7416002)(6116002)(86362001)(25786009)(68736007)(486006)(921003)(1121003)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5308;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xVN5X6GfoXI1AkvvztOtBh7q6qU8oXqwX6wXsFD1IQbj8Xwy1xEjVA4M3plf5iY3DguDYrwKS4Xcq79OZqyY9jJgMYAYDHziu82KSrPfw3Ey9B6F/Fghb8h8JPug+UTQyA+w+OnQj2SywtieJemv/ysVNDXTV6nggE/hZjCB8SWlInzpPjcwOQwTUbYnNmf6+bBUxZW5/fpvJzMDrE4przHy+UoJKKynh47q+imiV3KtL8YSm7ejcQgcTW4aIS7yOtZYEO/T97VLVi6Yy8LWBD9OiuEzpA7EM8SPy5unRNy+ARI0SuvxExAHJxjHiLhYMjZ7VDaOokWPgcqBc2UBceqNlx1Nc1xJRFlCtdyXQTuELtoRV4h0bpiRqN2J/6K9+tsoDLPlRIWpHQiuqByrZFV7DwHUMddAvXB7PMcw8y4=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aaa15bc7-af34-4434-1e22-08d6f9bcbb9a
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 22:30:31.9689
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
biA8SG9hbkBvcy5hbXBlcmVjb21wdXRpbmcuY29tPg0KLS0tDQogYXJjaC9zcGFyYy9LY29uZmln
IHwgOSAtLS0tLS0tLS0NCiAxIGZpbGUgY2hhbmdlZCwgOSBkZWxldGlvbnMoLSkNCg0KZGlmZiAt
LWdpdCBhL2FyY2gvc3BhcmMvS2NvbmZpZyBiL2FyY2gvc3BhcmMvS2NvbmZpZw0KaW5kZXggMjZh
YjZmNS4uMTM0NDllYSAxMDA2NDQNCi0tLSBhL2FyY2gvc3BhcmMvS2NvbmZpZw0KKysrIGIvYXJj
aC9zcGFyYy9LY29uZmlnDQpAQCAtMjkxLDE1ICsyOTEsNiBAQCBjb25maWcgTk9ERVNfU0hJRlQN
CiAJICBTcGVjaWZ5IHRoZSBtYXhpbXVtIG51bWJlciBvZiBOVU1BIE5vZGVzIGF2YWlsYWJsZSBv
biB0aGUgdGFyZ2V0DQogCSAgc3lzdGVtLiAgSW5jcmVhc2VzIG1lbW9yeSByZXNlcnZlZCB0byBh
Y2NvbW1vZGF0ZSB2YXJpb3VzIHRhYmxlcy4NCiANCi0jIFNvbWUgTlVNQSBub2RlcyBoYXZlIG1l
bW9yeSByYW5nZXMgdGhhdCBzcGFuDQotIyBvdGhlciBub2Rlcy4gIEV2ZW4gdGhvdWdoIGEgcGZu
IGlzIHZhbGlkIGFuZA0KLSMgYmV0d2VlbiBhIG5vZGUncyBzdGFydCBhbmQgZW5kIHBmbnMsIGl0
IG1heSBub3QNCi0jIHJlc2lkZSBvbiB0aGF0IG5vZGUuICBTZWUgbWVtbWFwX2luaXRfem9uZSgp
DQotIyBmb3IgZGV0YWlscy4NCi1jb25maWcgTk9ERVNfU1BBTl9PVEhFUl9OT0RFUw0KLQlkZWZf
Ym9vbCB5DQotCWRlcGVuZHMgb24gTkVFRF9NVUxUSVBMRV9OT0RFUw0KLQ0KIGNvbmZpZyBBUkNI
X1NFTEVDVF9NRU1PUllfTU9ERUwNCiAJZGVmX2Jvb2wgeSBpZiBTUEFSQzY0DQogDQotLSANCjIu
Ny40DQoNCg==

