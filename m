Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30528C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:14:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3FC420881
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:14:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="OgbI2k2I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3FC420881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 756606B0005; Tue, 14 May 2019 17:14:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 706916B0006; Tue, 14 May 2019 17:14:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 582096B0007; Tue, 14 May 2019 17:14:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB9F6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:14:45 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id f18so142258otf.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:14:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=xKwa8E3jh5+W/cbcaoZsR2eB0KxE0u7jRbZGOEH9u1Q=;
        b=iWhdYIZrTNPLFDIFXcxdZdxHIOGtMz/Uyb51aAHQ2BcQ3hoMs6OkoNcfBn1jY8EbW8
         0DzVHUWlbGHd6MnzwBk/IyM/mrfxF5SL1cb6rHtNuqYW3hKuTAswI5NnH/uE2VxWhzJ/
         pvSzOPEDAHkOl9srT/tuuHVykF4VOeFAD/9q95RShbLt+Bu2wxLEUEg0VtH36nwO+mS+
         VSFrnsRKGngj67AvP/DCn+ihnrNeWlEQCabfQsxue9MK76xJhH29hus1aJKOZfovx+CP
         +4pz/M5R2GjH8ihaSxCGW66qLUk1fKlWDJ9tuyg3I9ROoLgxIzJg+SnUh6D1Ef8K0xY0
         2tvw==
X-Gm-Message-State: APjAAAXV4n3rIEkgpdbyeXGZl5ciaQQEga4y2F505fXLifPkSnKLWDJT
	T43a+95/bOiMkBPwiubUrqHcFsXZNQNF6f6eoBQ2UAltUOXE/mPzNLL9VZl+9SQY/lpWCJFFv3e
	QvUWfe/X0rUhAJKFtPfML7PX+YtuzUgYxoC0+4KbGH7Q6xxYaAoBupPTAhQUZdxg=
X-Received: by 2002:a9d:7102:: with SMTP id n2mr23071124otj.206.1557868484790;
        Tue, 14 May 2019 14:14:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweP7zEL5gOkiM4rlHLR8UVoLkL+HDEE8t5Z4kH73gB0yrtu1+S0SlYkswzPAP0kOgKjU4Z
X-Received: by 2002:a9d:7102:: with SMTP id n2mr23071090otj.206.1557868484108;
        Tue, 14 May 2019 14:14:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557868484; cv=none;
        d=google.com; s=arc-20160816;
        b=CwFO3aiU8aJ7r8/iZlOjmIQsOjvuDG0ZMsLE3hsRw1cfcfkbxc8V8DjIiWKEqgVyJt
         X+jyTlVRTwmZnfl3sZSXdWfdbywx1+Tob90ErXPxZa9dSubuCT8lr2uDrziOLGUj8sqH
         Aij8SkcwS8J9kVgKtBBPbrw9dqiPJnwbzNKHK9oLA4kitmf6rOYaIIGKHJ2W+r0LYDLX
         TAg1i0e+vh4FLYKtl8lL1HHF/QlLfh+iG7QuZ/fhXX4nRw7MO0zieZYlqiZnvu4AFBkR
         ROblIpZIZgGEC52hRUl4t84e0h1YdTGgc3MFo7S+tCQZ3OiwWck1TOCtnVGOPsx35IuM
         6/0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=xKwa8E3jh5+W/cbcaoZsR2eB0KxE0u7jRbZGOEH9u1Q=;
        b=EVg5nmpTrEWhCEsyW/5fIIYZKbFAJ+sw8F+26QlRMY1bNuohZeP338R8f8jQMRG9mh
         ZWU/26y5NJ6tHjN8+hUL56omZeWoxaM2I2brbOb31pGea3PEW7C5nUVuKuY1cOyY7+Uz
         WCNP4N/B2OJlcUycMKEz8i3HUTtGIv3oSjBad9/AN9oQaNGx0E6x8nO+5GCB8YVPqnTS
         ++8DI/FjQcP9m8hALq+2ijuZ0NCtgdmeY58PT7PC/J6hd2gUM6Dt6VgH/lf3y63Swc/2
         AHGE9/kWBPRbbVxmF8+WXRSXIsktP0oGw3DGKTJDZawDWBBCcGHhw3CIPW31vjYQaG15
         +K/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=OgbI2k2I;
       spf=neutral (google.com: 40.107.70.81 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700081.outbound.protection.outlook.com. [40.107.70.81])
        by mx.google.com with ESMTPS id o22si50815otl.0.2019.05.14.14.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 May 2019 14:14:44 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.70.81 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.70.81;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amd-com header.b=OgbI2k2I;
       spf=neutral (google.com: 40.107.70.81 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amd-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xKwa8E3jh5+W/cbcaoZsR2eB0KxE0u7jRbZGOEH9u1Q=;
 b=OgbI2k2ICcIgK33ij62KLuzOm94yL+XouJDOOB8Ox0OoUALQBrgJRcUD7oR95D6VsW4QK7qTQZbMCl3bLzqWLWZmQmFJCRmuhFr+wMPXdLnqTMsGrb6uKx6yeLlJfVvKqZrL916/rtdMdJgfZXGXyfeXcmmetRSRqJAqfxzZdZA=
Received: from MN2PR12MB3949.namprd12.prod.outlook.com (10.255.238.150) by
 MN2PR12MB2989.namprd12.prod.outlook.com (20.178.241.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1878.25; Tue, 14 May 2019 21:14:42 +0000
Received: from MN2PR12MB3949.namprd12.prod.outlook.com
 ([fe80::b9af:29f1:fcab:6f6f]) by MN2PR12MB3949.namprd12.prod.outlook.com
 ([fe80::b9af:29f1:fcab:6f6f%4]) with mapi id 15.20.1878.024; Tue, 14 May 2019
 21:14:42 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: "jglisse@redhat.com" <jglisse@redhat.com>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>, "airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Thread-Topic: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Thread-Index: AQHVB2oGxdqwfWjT3keZMPNyIuFBZ6ZplnYAgAGOzIA=
Date: Tue, 14 May 2019 21:14:42 +0000
Message-ID: <180dbdaf-3ca4-07be-b549-08757e2ef105@amd.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-2-Felix.Kuehling@amd.com>
 <20190513142720.3334a98cbabaae67b4ffbb5a@linux-foundation.org>
In-Reply-To: <20190513142720.3334a98cbabaae67b4ffbb5a@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.55.251]
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
x-clientproxiedby: YTXPR0101CA0042.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::19) To MN2PR12MB3949.namprd12.prod.outlook.com
 (2603:10b6:208:16b::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7ead95ba-1d79-484c-ead8-08d6d8b12ecb
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:MN2PR12MB2989;
x-ms-traffictypediagnostic: MN2PR12MB2989:
x-microsoft-antispam-prvs:
 <MN2PR12MB2989011921D6100FB62179C392080@MN2PR12MB2989.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3044;
x-forefront-prvs: 0037FD6480
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(376002)(346002)(39860400002)(396003)(199004)(189003)(99286004)(66946007)(71190400001)(71200400001)(52116002)(6512007)(76176011)(31696002)(86362001)(66476007)(66556008)(73956011)(256004)(14444005)(64756008)(66446008)(26005)(446003)(478600001)(6436002)(72206003)(36756003)(25786009)(54906003)(58126008)(6116002)(3846002)(66066001)(4326008)(65956001)(65806001)(6506007)(386003)(53546011)(4744005)(102836004)(316002)(2906002)(64126003)(6486002)(31686004)(486006)(476003)(305945005)(14454004)(53936002)(81156014)(81166006)(229853002)(6916009)(186003)(2616005)(7736002)(11346002)(5660300002)(8936002)(6246003)(65826007)(8676002)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR12MB2989;H:MN2PR12MB3949.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 vZh2Laa8AtjRPNVAWHtiCkM6DX5wAO8Q40kRfgd1V70gP7KM67CE1PBNa7ox0dIChQvHRbz+wQtOF79Au89V/lZqej5uF3tk8MF6pL+kmjgReJZDmn55+VSdBBWX3uAj7SfeWewtFe1pJfHr3VfU9olGvjt8xC20E7wtpBKqxcrvsZk5G2GyDcCGS/IMWcqeEioEMtJsuVFf0MMOE4LhrJ4jPUaYD44Gq6l+qGeMusI1xRGm5nFwC7sHXoka+eTNQRmdE0yutx3xxEnvT9AJHCYuVW1I3cxzS1QKQgl7lc3wPWPCtS7g+QKZanLKIzSkO128Xfu8aXlrjmIVvgCqdeBXelDTWuhFWQ8NQR8IvGOGouHuZUs/W8IuiqohAHxcFWweWb2zOqOqhKmj02eLUCwhZzBPZyps2ZJ/ODlzHQU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <37BFBE354B9EE042991B3828B0383237@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7ead95ba-1d79-484c-ead8-08d6d8b12ecb
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 May 2019 21:14:42.8392
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR12MB2989
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNS0xMyA1OjI3IHAubS4sIEFuZHJldyBNb3J0b24gd3JvdGU6DQo+IFtDQVVUSU9O
OiBFeHRlcm5hbCBFbWFpbF0NCj4NCj4gT24gRnJpLCAxMCBNYXkgMjAxOSAxOTo1MzoyMyArMDAw
MCAiS3VlaGxpbmcsIEZlbGl4IiA8RmVsaXguS3VlaGxpbmdAYW1kLmNvbT4gd3JvdGU6DQo+DQo+
PiBGcm9tOiBQaGlsaXAgWWFuZyA8UGhpbGlwLllhbmdAYW1kLmNvbT4NCj4+DQo+PiBXaGlsZSB0
aGUgcGFnZSBpcyBtaWdyYXRpbmcgYnkgTlVNQSBiYWxhbmNpbmcsIEhNTSBmYWlsZWQgdG8gZGV0
ZWN0IHRoaXMNCj4+IGNvbmRpdGlvbiBhbmQgc3RpbGwgcmV0dXJuIHRoZSBvbGQgcGFnZS4gQXBw
bGljYXRpb24gd2lsbCB1c2UgdGhlIG5ldw0KPj4gcGFnZSBtaWdyYXRlZCwgYnV0IGRyaXZlciBw
YXNzIHRoZSBvbGQgcGFnZSBwaHlzaWNhbCBhZGRyZXNzIHRvIEdQVSwNCj4+IHRoaXMgY3Jhc2gg
dGhlIGFwcGxpY2F0aW9uIGxhdGVyLg0KPj4NCj4+IFVzZSBwdGVfcHJvdG5vbmUocHRlKSB0byBy
ZXR1cm4gdGhpcyBjb25kaXRpb24gYW5kIHRoZW4gaG1tX3ZtYV9kb19mYXVsdA0KPj4gd2lsbCBh
bGxvY2F0ZSBuZXcgcGFnZS4NCj4+DQo+PiBTaWduZWQtb2ZmLWJ5OiBQaGlsaXAgWWFuZyA8UGhp
bGlwLllhbmdAYW1kLmNvbT4NCj4gVGhpcyBzaG91bGQgaGF2ZSBpbmNsdWRlZCB5b3VyIHNpZ25l
ZC1vZmYtYnk6LCBzaW5jZSB5b3Ugd2VyZSBvbiB0aGUNCj4gcGF0Y2ggZGVsaXZlcnkgcGF0aC4g
IEknbGwgbWFrZSB0aGF0IGNoYW5nZSB0byBteSBjb3B5IG9mIHRoZSBwYXRjaCwNCj4gT0s/DQo+
DQpZZXMuIFRoYW5rcyENCg0KDQo=

