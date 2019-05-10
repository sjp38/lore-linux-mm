Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DA40C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06FAE217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="koIJQSAK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06FAE217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABA146B0005; Fri, 10 May 2019 15:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A42876B0006; Fri, 10 May 2019 15:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E2FA6B0007; Fri, 10 May 2019 15:53:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8626B0005
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:53:26 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q1so6135624itc.3
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:53:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=01TE663c8WMujIC20jubp91UV3+DQFkGrM3bWrl8IbU=;
        b=pFkqp4QztyOWKtp2pLhGiOI9VxZNCEEcADnIZWDeB7207N2IhruEeldlzx4XtrOl31
         Hg/E4jq+N1RLq91isN8+PxabefZ+ZYH8FcakLq5hqoA5eMgacwYuO+uc48s92ookmsuY
         17bF0P+RGykj7ew9wrLs+eFNtO4kPa0K7TUdTDOBkQ8KRY1mnIV0uVNdDsDtd23WrFv1
         iUmonG/WKYEpz4hN43u5pJpdMqB79AyV+qn/qkirE5MoNfN1ZleuUSdEBBL1wkZZrJJj
         YOvJ/BhpMPeDzKpF/GlibrA6jyvVSySi3ZlY58eemG1yGKhUch1cH/U3OWgPER8s7s94
         H1BQ==
X-Gm-Message-State: APjAAAWvhJCekgwESufmgmeXyw1ZKSzIkfWJ9PgUuPCa8/3CBeKkLz+8
	1hGqLUan7iR6APJVl++McvejB25dFmSPVLDWu0vjbc24wGOzyd0CCPPxROmu83wXnTw/mxRzZ6X
	aW7LJcug4xUoplxmddF1ATqqaPa3WJU81n3zpzHqpEcX6Ey90z1DUPfuXUy/tBH8=
X-Received: by 2002:a02:a890:: with SMTP id l16mr9732404jam.137.1557518006214;
        Fri, 10 May 2019 12:53:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfTbT434/xMd7s9GswdmGPAjbQJjF4TsVMdlbA/Sl/8t8PY17dZp+uoNi+IKmIpFeB7VAB
X-Received: by 2002:a02:a890:: with SMTP id l16mr9732264jam.137.1557518004867;
        Fri, 10 May 2019 12:53:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557518004; cv=none;
        d=google.com; s=arc-20160816;
        b=umWzoLxhfGI+HITpEGFSbYV9OZDpIZBg41azPXit64pXKgdM8zqqoU7Jj9pGJtlGi6
         IP/o5Hh08CPfJjuXiX/aESlVinkzvu2yHIS644SlsZoZHK57SSadWC8N0h6Rf48hG4mT
         fIJBh9zVgvMmDnkZpqF43+E/Q5iChaAvf/Kj9MUmg40lNyhcW8En5xLDoe2FP6Go9Gt3
         oD+FiCJ6jCafESFxkRYQB4s6589F93cxTF9i4gTES9v9VI0lmCiAqvPL0PyPpCAM7fGQ
         PFVzSLw0qTpo+lJ2P+zlKd0toyZ4dWzRyKcx2RRusubmkwsVCl6ecZU62zVenNCMpEx4
         A7+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=01TE663c8WMujIC20jubp91UV3+DQFkGrM3bWrl8IbU=;
        b=VhrZRqafnyLjrsoirrZbAH3moGWY8IgT32jSGFSrJ0OWhcVVBhLTy91SqHvk3ySEpL
         wR0gMb0onczTuHXqPr+1z25B4Zatxv5pCVMbgKCCsHeOIRmbRmODZcBAPw5I3s0sZA+h
         mI1ro7Uc7VVDxxtUQ6h1NBByZb44vyUZ3En1DNqU+L0gnmnZyAfIA8+OQ/SH0zCb6jcf
         MdaHBea0T+jyMpgd/YzelzindgwQygRqMCntgFe6u4sXeKf36eWXfE9R6o83HAkqGaTv
         xw48rrU4yc+uGoV0Ht0vmIn/bnUXHGiqXh64++pRjav9p+9lkcAbOH3sRg7IvxEeIDHS
         F0Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=koIJQSAK;
       spf=neutral (google.com: 40.107.68.53 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680053.outbound.protection.outlook.com. [40.107.68.53])
        by mx.google.com with ESMTPS id 129si3959864jai.75.2019.05.10.12.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 12:53:24 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.53 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.68.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=koIJQSAK;
       spf=neutral (google.com: 40.107.68.53 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=01TE663c8WMujIC20jubp91UV3+DQFkGrM3bWrl8IbU=;
 b=koIJQSAKV4tSIdDeGAsJ8r8laUsSJeUbvwAIUPRqgRBW90AEy4QvL6qmIhh01au+Rld330cHy0FRXsvrj9s6FIwgDda/e4oypHixsOHBNXRwR0bI/whVVGVVxKLqhrPFnJ8zARmsy/dUIfBAmDYc/Pi3O+glwgMEZbLy2J2Zhvo=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3447.namprd12.prod.outlook.com (20.178.196.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.21; Fri, 10 May 2019 19:53:23 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7%4]) with mapi id 15.20.1856.016; Fri, 10 May 2019
 19:53:23 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
CC: "Yang, Philip" <Philip.Yang@amd.com>
Subject: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Thread-Topic: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Thread-Index: AQHVB2oGxdqwfWjT3keZMPNyIuFBZw==
Date: Fri, 10 May 2019 19:53:23 +0000
Message-ID: <20190510195258.9930-2-Felix.Kuehling@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
In-Reply-To: <20190510195258.9930-1-Felix.Kuehling@amd.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
x-mailer: git-send-email 2.17.1
x-clientproxiedby: YTXPR0101CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::34) To BYAPR12MB3176.namprd12.prod.outlook.com
 (2603:10b6:a03:133::18)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2aa8c48f-0427-4877-df74-08d6d5812861
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR12MB3447;
x-ms-traffictypediagnostic: BYAPR12MB3447:
x-microsoft-antispam-prvs:
 <BYAPR12MB34475F0513AC9B90A3082C3F920C0@BYAPR12MB3447.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3383;
x-forefront-prvs: 0033AAD26D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(366004)(39860400002)(346002)(376002)(189003)(199004)(110136005)(102836004)(2501003)(6512007)(86362001)(6436002)(2906002)(76176011)(52116002)(2201001)(6506007)(386003)(99286004)(6486002)(66066001)(3846002)(478600001)(6116002)(14454004)(72206003)(316002)(305945005)(53936002)(66476007)(66556008)(186003)(8936002)(81166006)(7736002)(486006)(4326008)(64756008)(66446008)(14444005)(256004)(25786009)(26005)(66946007)(73956011)(476003)(2616005)(71200400001)(446003)(11346002)(71190400001)(8676002)(36756003)(81156014)(5660300002)(50226002)(4744005)(68736007)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3447;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 SozOdyCbVyWhsZucRi1nkqT89QpXVuUElrx98H8kPsylK1EJGgawzrDEfe+cLr9wWnjrZeIcUc3MUfZKpWVDNq4lxttKtLb76kVvErHyGKMW2uYrpXLCCWQxSDrQN8FXK+S0tpW3vwsN0PjeyMFqCdz7Y2PiCWzUB2apxyHa0u1IveEB3cL04d5Xv5QU1gs050l4HMDXT03dKi6YX8pMsLVMjOfgmsxxmc8KdYEqdK2gvPdep+9eTV6eT+wVQuQiJWR9JalT0jkPAx+dLEYbRbcq3BnJ/yxuxJ0xdc+pWrwswyhXnAxF1211TpUujkZZzAxbalvVEfUYea1v85bUJV7j/w9XT5WfU55bU77takcZrv/PpIiv2gIyvXKOrI/1ax3JS06iUNJ/492tp9GosdDHhv+Kjhh3bL/oMsVGWBI=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2aa8c48f-0427-4877-df74-08d6d5812861
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 May 2019 19:53:23.0778
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3447
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000121, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RnJvbTogUGhpbGlwIFlhbmcgPFBoaWxpcC5ZYW5nQGFtZC5jb20+DQoNCldoaWxlIHRoZSBwYWdl
IGlzIG1pZ3JhdGluZyBieSBOVU1BIGJhbGFuY2luZywgSE1NIGZhaWxlZCB0byBkZXRlY3QgdGhp
cw0KY29uZGl0aW9uIGFuZCBzdGlsbCByZXR1cm4gdGhlIG9sZCBwYWdlLiBBcHBsaWNhdGlvbiB3
aWxsIHVzZSB0aGUgbmV3DQpwYWdlIG1pZ3JhdGVkLCBidXQgZHJpdmVyIHBhc3MgdGhlIG9sZCBw
YWdlIHBoeXNpY2FsIGFkZHJlc3MgdG8gR1BVLA0KdGhpcyBjcmFzaCB0aGUgYXBwbGljYXRpb24g
bGF0ZXIuDQoNClVzZSBwdGVfcHJvdG5vbmUocHRlKSB0byByZXR1cm4gdGhpcyBjb25kaXRpb24g
YW5kIHRoZW4gaG1tX3ZtYV9kb19mYXVsdA0Kd2lsbCBhbGxvY2F0ZSBuZXcgcGFnZS4NCg0KU2ln
bmVkLW9mZi1ieTogUGhpbGlwIFlhbmcgPFBoaWxpcC5ZYW5nQGFtZC5jb20+DQotLS0NCiBtbS9o
bW0uYyB8IDIgKy0NCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24o
LSkNCg0KZGlmZiAtLWdpdCBhL21tL2htbS5jIGIvbW0vaG1tLmMNCmluZGV4IDc1ZDJlYTkwNmVm
Yi4uYjY1YzI3ZDVjMTE5IDEwMDY0NA0KLS0tIGEvbW0vaG1tLmMNCisrKyBiL21tL2htbS5jDQpA
QCAtNTU0LDcgKzU1NCw3IEBAIHN0YXRpYyBpbnQgaG1tX3ZtYV9oYW5kbGVfcG1kKHN0cnVjdCBt
bV93YWxrICp3YWxrLA0KIA0KIHN0YXRpYyBpbmxpbmUgdWludDY0X3QgcHRlX3RvX2htbV9wZm5f
ZmxhZ3Moc3RydWN0IGhtbV9yYW5nZSAqcmFuZ2UsIHB0ZV90IHB0ZSkNCiB7DQotCWlmIChwdGVf
bm9uZShwdGUpIHx8ICFwdGVfcHJlc2VudChwdGUpKQ0KKwlpZiAocHRlX25vbmUocHRlKSB8fCAh
cHRlX3ByZXNlbnQocHRlKSB8fCBwdGVfcHJvdG5vbmUocHRlKSkNCiAJCXJldHVybiAwOw0KIAly
ZXR1cm4gcHRlX3dyaXRlKHB0ZSkgPyByYW5nZS0+ZmxhZ3NbSE1NX1BGTl9WQUxJRF0gfA0KIAkJ
CQlyYW5nZS0+ZmxhZ3NbSE1NX1BGTl9XUklURV0gOg0KLS0gDQoyLjE3LjENCg0K

