Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC427C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53E8A217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:53:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="t1Ik0Emj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53E8A217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6763B6B0006; Fri, 10 May 2019 15:53:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FD116B0007; Fri, 10 May 2019 15:53:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 401226B0008; Fri, 10 May 2019 15:53:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3C06B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:53:27 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id g7so6519927qkb.7
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:53:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=r68dEYCklCFsZVBUW4IcTm6GYQl0JWxtn6eHLJELlhk=;
        b=F6CK377Dce27ZhuXKcyTWb/FJPB89uG4pdKuwmJyG5rV4TX5h1cqSw/SQbI9V4sX/g
         zi8h/rOQ0S8qj/ATPeSyRxVN4Yxf4BeDAc/UpDBnmmFUotQCrY6mVuhDfk2sjr+ut8JQ
         dp7tuW0Dh305kpTWNFk01ak3+PFLDNYXRctL1u4FEF02E8qnanYNdua1h3VndRsJrth6
         UGMNYw24Qe42F7mWn3KNBx3jD5EmF6caM4BPJnD+tAUz3R4gGufhQDwsKh7qFe7tr/4k
         h+HFa7pMsT/XeAlmh4fgDA0EDgVCvwBwi2vA4zO9RTFZ0uKRc+1ksb4tgxpGtMCd0r4q
         CiRA==
X-Gm-Message-State: APjAAAX5wH+R0IyeidEprqgRzpuKQ9GgBO1a/3VasPikB6LNNTM4Rw2U
	SiDedZnHlDqVnkk5VSeTNEuTK6EH7elxn68QjrPaJIQPtolf9tQBKNCqAYIJQssU8cKkjix/OtK
	ZWSpOVQjKd0g8GzSg8oVf/dPG0SoMJb0+4CFwjYfMWFGXoAdoAAprT370JnZjDac=
X-Received: by 2002:a37:8bc7:: with SMTP id n190mr10452759qkd.108.1557518006836;
        Fri, 10 May 2019 12:53:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXnd0Tnz7oB0FIM35W9bzTrKjZNdcMJjtXr9+C11BcwlwQ6DffojZwVoNfcVKfNAIh7X5l
X-Received: by 2002:a37:8bc7:: with SMTP id n190mr10452705qkd.108.1557518006014;
        Fri, 10 May 2019 12:53:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557518006; cv=none;
        d=google.com; s=arc-20160816;
        b=B1US887AoBakEonqFPsG0vGt7fES16wCKgq+wj/VsejuKSqVyciiEiHFPxT8WQEt9B
         u14vPofYCfPZQ1NtISbDbROvhpn25BAUyIAORYCavjxN2jsev8LRjCw6YYzqgFFJVdiZ
         Dk8oYlIPphZtpB4zczB673211Y+pN1LeHL5jmPcb1KPe+dWi2YV3D9siuBIwC/+Ltvvd
         EqQKWaTooFQHOHFTFQXx2YJmNnajuqM4wxSKOjRiRVdLf02EOCyBNbJr5L0W5mgUP0xx
         qgBkVoiPB/VP+KQqamdcTrJMpmloTEOQNEt4UoMLSdJ3Iu1uYJBLM9hJXhLOACGB1+C1
         lECg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=r68dEYCklCFsZVBUW4IcTm6GYQl0JWxtn6eHLJELlhk=;
        b=En6EjsaLHKqUY6Qg/u6V5mBMPXolAZTgk+TS9Z+ZR6f1jGRkbLzOFchxY/KtiQmLZB
         9fbvspcRQkUU6HZyKg1jfy5iNeCFV24SoI+QPl23Z+i98uPrGizfD6cplZR980Wp3duc
         3Gcaaj8yeJIWpMl91nMW4Y/eddOj0a+X5KpMDdoFNo1g6wnmq37uxZohqxp82t3funWT
         Y6/6rurh73gJ6W+EJxkCjyFRnSHP5VPTSpiHitxX8Zr9dtUS3/ylunvmnmUesyiyJv9k
         U1ZzLxwnJ/rraGB20VkQUp4ZB8fnUB8bAOWcarqa7w37hzOLs+5ZfPdw1fXPyzwWPVzY
         Qrvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=t1Ik0Emj;
       spf=neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680055.outbound.protection.outlook.com. [40.107.68.55])
        by mx.google.com with ESMTPS id d13si1447206qtb.405.2019.05.10.12.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 May 2019 12:53:26 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.68.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=t1Ik0Emj;
       spf=neutral (google.com: 40.107.68.55 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r68dEYCklCFsZVBUW4IcTm6GYQl0JWxtn6eHLJELlhk=;
 b=t1Ik0EmjrTAmXwn1tFrtBpXamK9ghiEQtvc3CvB3OUk+oFeW8Z4GtAt5wTAHW2NBWKuq36LEzUb8PjrwxMltovb/5DiiG6chGG6SzC4uchONNehmrVIP9CwQdw8HF5sU7p46uBvgKboRz0quHaAzwLHc5+KcxHYrHngtQYPtBR4=
Received: from BYAPR12MB3176.namprd12.prod.outlook.com (20.179.92.82) by
 BYAPR12MB3447.namprd12.prod.outlook.com (20.178.196.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.21; Fri, 10 May 2019 19:53:24 +0000
Received: from BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7]) by BYAPR12MB3176.namprd12.prod.outlook.com
 ([fe80::9118:73f2:809c:22c7%4]) with mapi id 15.20.1856.016; Fri, 10 May 2019
 19:53:24 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: "jglisse@redhat.com" <jglisse@redhat.com>, "alex.deucher@amd.com"
	<alex.deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
CC: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for non-blocking
Thread-Topic: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
 non-blocking
Thread-Index: AQHVB2oH3gumKK8uVkW/G1cJvzIbZg==
Date: Fri, 10 May 2019 19:53:24 +0000
Message-ID: <20190510195258.9930-3-Felix.Kuehling@amd.com>
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
x-ms-office365-filtering-correlation-id: 0bb65e5e-6543-480a-32a4-08d6d5812935
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:BYAPR12MB3447;
x-ms-traffictypediagnostic: BYAPR12MB3447:
x-microsoft-antispam-prvs:
 <BYAPR12MB34471B0FAC58B853D74E2938920C0@BYAPR12MB3447.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:1360;
x-forefront-prvs: 0033AAD26D
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(136003)(366004)(39860400002)(346002)(376002)(189003)(199004)(110136005)(102836004)(2501003)(6512007)(86362001)(6436002)(2906002)(76176011)(52116002)(2201001)(6506007)(386003)(99286004)(6486002)(66066001)(3846002)(478600001)(6116002)(14454004)(72206003)(316002)(305945005)(53936002)(66476007)(66556008)(186003)(8936002)(81166006)(7736002)(486006)(4326008)(64756008)(66446008)(14444005)(256004)(25786009)(26005)(66946007)(73956011)(476003)(2616005)(71200400001)(446003)(11346002)(71190400001)(8676002)(36756003)(81156014)(5660300002)(50226002)(4744005)(68736007)(1076003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR12MB3447;H:BYAPR12MB3176.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 rn/Ggjr1Nl/zRrTCRjOLymvE6YXZ1ceesRFPMg0pssZdDd7x2nsdvBY2xsJ3ZOvtNqnGWAw8l7NQ+n5lnJKDJ55ND1g+hRNTEGKb78y366B8p1HVRZ1MhjxLTMDvIsmIVO5IQtkX3avdH3Cw7QzcrUr5F5iYmNm0auaT6Fw5oVUGoOcluvaaqgyuIDiFmnPFpJKeIezp/9UVUv57G5FYf40FcpLur6sF7qUWNToXFGFaPsoV9JIdtIDWIX3SVV053p1J0fbxsT1CwIojY1gJo5mM0k+bkxx7t3oH31Uv6cD9FaTMKUXhFV3LgYXXxVFJbj0ZFLPSs/nNnpOMMd5GfhRTxbf2voNvzq2165Rj/E0yEGwAcLWKR3BY3Ps6nZ0dP0vKZbwaTzsrx1baAmwGYUX1mDfFUVJjrYNyuAce7HE=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0bb65e5e-6543-480a-32a4-08d6d5812935
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 May 2019 19:53:24.3777
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR12MB3447
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RG9uJ3Qgc2V0IHRoaXMgZmxhZyBieSBkZWZhdWx0IGluIGhtbV92bWFfZG9fZmF1bHQuIEl0IGlz
IHNldA0KY29uZGl0aW9uYWxseSBqdXN0IGEgZmV3IGxpbmVzIGJlbG93LiBTZXR0aW5nIGl0IHVu
Y29uZGl0aW9uYWxseQ0KY2FuIGxlYWQgdG8gaGFuZGxlX21tX2ZhdWx0IGRvaW5nIGEgbm9uLWJs
b2NraW5nIGZhdWx0LCByZXR1cm5pbmcNCi1FQlVTWSBhbmQgdW5sb2NraW5nIG1tYXBfc2VtIHVu
ZXhwZWN0ZWRseS4NCg0KU2lnbmVkLW9mZi1ieTogRmVsaXggS3VlaGxpbmcgPEZlbGl4Lkt1ZWhs
aW5nQGFtZC5jb20+DQotLS0NCiBtbS9obW0uYyB8IDIgKy0NCiAxIGZpbGUgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkNCg0KZGlmZiAtLWdpdCBhL21tL2htbS5jIGIvbW0v
aG1tLmMNCmluZGV4IGI2NWMyN2Q1YzExOS4uM2M0ZjFkNjIyMDJmIDEwMDY0NA0KLS0tIGEvbW0v
aG1tLmMNCisrKyBiL21tL2htbS5jDQpAQCAtMzM5LDcgKzMzOSw3IEBAIHN0cnVjdCBobW1fdm1h
X3dhbGsgew0KIHN0YXRpYyBpbnQgaG1tX3ZtYV9kb19mYXVsdChzdHJ1Y3QgbW1fd2FsayAqd2Fs
aywgdW5zaWduZWQgbG9uZyBhZGRyLA0KIAkJCSAgICBib29sIHdyaXRlX2ZhdWx0LCB1aW50NjRf
dCAqcGZuKQ0KIHsNCi0JdW5zaWduZWQgaW50IGZsYWdzID0gRkFVTFRfRkxBR19BTExPV19SRVRS
WSB8IEZBVUxUX0ZMQUdfUkVNT1RFOw0KKwl1bnNpZ25lZCBpbnQgZmxhZ3MgPSBGQVVMVF9GTEFH
X1JFTU9URTsNCiAJc3RydWN0IGhtbV92bWFfd2FsayAqaG1tX3ZtYV93YWxrID0gd2Fsay0+cHJp
dmF0ZTsNCiAJc3RydWN0IGhtbV9yYW5nZSAqcmFuZ2UgPSBobW1fdm1hX3dhbGstPnJhbmdlOw0K
IAlzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZtYSA9IHdhbGstPnZtYTsNCi0tIA0KMi4xNy4xDQoN
Cg==

