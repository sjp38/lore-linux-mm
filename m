Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E86C7C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9544021479
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 22:30:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amperemail.onmicrosoft.com header.i=@amperemail.onmicrosoft.com header.b="lZ8VSb+R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9544021479
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D4D36B0008; Tue, 25 Jun 2019 18:30:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2603A8E0003; Tue, 25 Jun 2019 18:30:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DB538E0002; Tue, 25 Jun 2019 18:30:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D803C6B0008
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 18:30:30 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v11so156769iop.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 15:30:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=HVMc1UvwzKEYE/uLj7StVif5ifxT2J9wxzTXdXD1F5g=;
        b=sGTUf9lg1URBDBfc9Di4NJI4+E1RL1qfrh9cazDYYXG01QV57grT7xJt1hQgz7O24X
         jVr8RBRLlGIhvElv/updNA6vFt394cBVRx+6ReOtRtdIoF5eGOMX/0nUgszYx9K0z0FZ
         oNOx92cTsxO4SpzfaINyQ3R05lkoYkLI/V1CiGXMWw9mf4XFOwsr8Gxql6aq2bqWdNHY
         31Uc1FAGEiwhRW6A+uqj9ouu+TgabsXkTUNVuIx54xBO6tCXuncr8FFCuciq5JiL7y59
         vSTKNUkvntQ6n4YHCVHtnz+K0wW3eqDZ8Bm2xSRiD4pujb+OLSJ63QGABAZqt3X1204y
         cIBw==
X-Gm-Message-State: APjAAAV6JxG46DHRRaLyAs0Tlu/ANYv6PoypgLDjJFfzdl7X7parFzHc
	jrEc7BHoyyUWbVuWyPFlHhf7NBCg76CMLreV91Q/OoFwzAf+4WijIz7dv23EFXrZKiwNCjaHp+f
	wYxAOCVvCDsASupbpomXBFh/Fx1lEOCrzkSO865HgnJff8nhDODVgck2VgDKNbJOKSA==
X-Received: by 2002:a02:6616:: with SMTP id k22mr855110jac.100.1561501830673;
        Tue, 25 Jun 2019 15:30:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAB1CFd24cTVjqApScP+c43jg0RdA1aUhDkmtzI3uJkWEDb72DxyJFbLy5T36MPZf4Gey4
X-Received: by 2002:a02:6616:: with SMTP id k22mr855002jac.100.1561501829524;
        Tue, 25 Jun 2019 15:30:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561501829; cv=none;
        d=google.com; s=arc-20160816;
        b=yU98SXvONRB3QaIWgLfTCmLtppiGeCEaI8XJeinNbgFqQtYJyEYSf8puuytu1PMM8F
         zkLJvbBuTruQUjqo1y1Nf6jROemWq6Ijixdjfl1eKy+rJtQZqi7TSBBHxj6vBlBR0D7K
         V21yOI/hvgJqwCbwdJDszSFbp3mSrekvYDuaksRRtKNX4Old09ofoBxwl09OmHMZ2rsl
         JAPl4qaEnIT1SBYtk/v9PHLz7MW6uv5x5uN7u1cVPVqPRwu/zHYzh7W6yITStG0Wllbi
         7cqPIV0V4zn7NpVv0hl7U32WzmDEVFlzxoyy6LPCGO3KuHzCGt3vmmJxIpeJ+8/cPCPV
         TwrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=HVMc1UvwzKEYE/uLj7StVif5ifxT2J9wxzTXdXD1F5g=;
        b=ToyxNDrN8Nqu/vq/ggKH3j51eUVufem9S+ZdkhEDSGLv3ZWHjCNxCtQlYjHKXZhPIB
         ad70gt0S+rZxdCDqloyCrY/ZYZyVpkG+sERvF6plp7LFJI5RjCzv4w48I0M7w+raegQj
         tjJJ00NfkvTGJfQQTmjsrS5xEfdnUMOi1IuMXOO8d74O4C+UX0tYmRnhRa1sR1CnN4Fo
         BI65Tw8mF02JjA7FMC6uSManArM1eBtVKRd1FbqpKnYDVGAB6SRAtqWzCU9iURZra/2S
         D9x9apvxx8zOxUctQ+24dbrq4OdjEsCfEK0f2BAUif4uW1CoQ8wxYpQZU1FT50DFQxwu
         IyAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=lZ8VSb+R;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.125 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720125.outbound.protection.outlook.com. [40.107.72.125])
        by mx.google.com with ESMTPS id k21si20437917ion.82.2019.06.25.15.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Jun 2019 15:30:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.125 as permitted sender) client-ip=40.107.72.125;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amperemail.onmicrosoft.com header.s=selector2-amperemail-onmicrosoft-com header.b=lZ8VSb+R;
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.72.125 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amperemail.onmicrosoft.com; s=selector2-amperemail-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HVMc1UvwzKEYE/uLj7StVif5ifxT2J9wxzTXdXD1F5g=;
 b=lZ8VSb+RlLhoQEdmcWBtzVpl91C+xJpmRZ3YnIFQy/Gg0/LqeoygD5tWE7fZYR5e0dJIhT1wJ8x72TAJeRFVlbuLa0BFbDaX4AOCo83OUZgdd83jIha2in5OTCZgaI7kYdkhk7S/j5sn5l8HgSG1poMGiWgw+/Nt0XgJDxOiZUU=
Received: from DM6PR01MB4090.prod.exchangelabs.com (20.176.104.151) by
 DM6PR01MB5308.prod.exchangelabs.com (20.177.220.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 22:30:27 +0000
Received: from DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3]) by DM6PR01MB4090.prod.exchangelabs.com
 ([fe80::f0f2:16e1:1db7:ccb3%7]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 22:30:27 +0000
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
Subject: [PATCH 2/5] powerpc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
Thread-Topic: [PATCH 2/5] powerpc: Kconfig: Remove
 CONFIG_NODES_SPAN_OTHER_NODES
Thread-Index: AQHVK6WWTJnZANKxsE2KcscKAErIBA==
Date: Tue, 25 Jun 2019 22:30:27 +0000
Message-ID: <1561501810-25163-3-git-send-email-Hoan@os.amperecomputing.com>
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
x-ms-office365-filtering-correlation-id: 5ba6e1f1-3d1a-4307-0689-08d6f9bcb8d1
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM6PR01MB5308;
x-ms-traffictypediagnostic: DM6PR01MB5308:
x-microsoft-antispam-prvs:
 <DM6PR01MB53081BACDA24CE140BB588A7F1E30@DM6PR01MB5308.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0079056367
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(366004)(136003)(39840400004)(346002)(396003)(199004)(189003)(256004)(4326008)(53936002)(14454004)(4744005)(7736002)(52116002)(107886003)(50226002)(6486002)(81156014)(81166006)(64756008)(8936002)(66446008)(8676002)(6436002)(110136005)(26005)(5660300002)(99286004)(66946007)(73956011)(6506007)(76176011)(186003)(386003)(102836004)(66066001)(2906002)(446003)(305945005)(54906003)(2616005)(66556008)(66476007)(11346002)(316002)(476003)(6512007)(1511001)(478600001)(71190400001)(3846002)(71200400001)(7416002)(6116002)(86362001)(25786009)(68736007)(486006)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:DM6PR01MB5308;H:DM6PR01MB4090.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:0;MX:1;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sjRg2QAGNGTrgP8oiMR923tMhaplwfXVDB1SA44RzwpON4n9z07p4wuhQ/JA4QNhCUviGQrlU3GaqRNmshivxqx/fwDoWLjraFvXbtY2mhaj1v1I+HfSc286Cxx5Z703q8ZCdJe4CWzjFtQ9UZaEoWa/MuTBZmUdxlHhuYLxoA5PJsGj0YDh+vdmve4Y4EsL4POA6eqZpC/YbVy3yY7qn69FNbj/agNKXv0xPOUg4wjw8t/UULsy+TTeDzkG5oOv8B3Tt6Bd39lbp6kEpUVYQisS9p7eZb5kZ6eR+hEwt/MweqGR1ZLsEZ791VFk/4RDEUAqmfEjQD2j6lZF1esrkf5KVYpS10VIZVOe+zJ/OUWDP6NflXIzVeNthMn3rUct7wmA01TAHZ0syw/FHPrpHYv+ndgVXuKR/PQquZAQKGY=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5ba6e1f1-3d1a-4307-0689-08d6f9bcb8d1
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 22:30:27.2766
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
biA8SG9hbkBvcy5hbXBlcmVjb21wdXRpbmcuY29tPg0KLS0tDQogYXJjaC9wb3dlcnBjL0tjb25m
aWcgfCA5IC0tLS0tLS0tLQ0KIDEgZmlsZSBjaGFuZ2VkLCA5IGRlbGV0aW9ucygtKQ0KDQpkaWZm
IC0tZ2l0IGEvYXJjaC9wb3dlcnBjL0tjb25maWcgYi9hcmNoL3Bvd2VycGMvS2NvbmZpZw0KaW5k
ZXggOGMxYzYzNi4uYmRkZThiYyAxMDA2NDQNCi0tLSBhL2FyY2gvcG93ZXJwYy9LY29uZmlnDQor
KysgYi9hcmNoL3Bvd2VycGMvS2NvbmZpZw0KQEAgLTYyOSwxNSArNjI5LDYgQEAgY29uZmlnIEFS
Q0hfTUVNT1JZX1BST0JFDQogCWRlZl9ib29sIHkNCiAJZGVwZW5kcyBvbiBNRU1PUllfSE9UUExV
Rw0KIA0KLSMgU29tZSBOVU1BIG5vZGVzIGhhdmUgbWVtb3J5IHJhbmdlcyB0aGF0IHNwYW4NCi0j
IG90aGVyIG5vZGVzLiAgRXZlbiB0aG91Z2ggYSBwZm4gaXMgdmFsaWQgYW5kDQotIyBiZXR3ZWVu
IGEgbm9kZSdzIHN0YXJ0IGFuZCBlbmQgcGZucywgaXQgbWF5IG5vdA0KLSMgcmVzaWRlIG9uIHRo
YXQgbm9kZS4gIFNlZSBtZW1tYXBfaW5pdF96b25lKCkNCi0jIGZvciBkZXRhaWxzLg0KLWNvbmZp
ZyBOT0RFU19TUEFOX09USEVSX05PREVTDQotCWRlZl9ib29sIHkNCi0JZGVwZW5kcyBvbiBORUVE
X01VTFRJUExFX05PREVTDQotDQogY29uZmlnIFNUREJJTlVUSUxTDQogCWJvb2wgIlVzaW5nIHN0
YW5kYXJkIGJpbnV0aWxzIHNldHRpbmdzIg0KIAlkZXBlbmRzIG9uIDQ0eA0KLS0gDQoyLjcuNA0K
DQo=

