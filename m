Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4620C742BE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:17:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65FF02080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:17:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="bICylbc6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65FF02080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF148E014A; Fri, 12 Jul 2019 09:17:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E57068E00DB; Fri, 12 Jul 2019 09:17:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA9CE8E014A; Fri, 12 Jul 2019 09:17:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7AE8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:17:49 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id i132so4130876oif.2
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:17:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=MWoXk/DXnocxMRQgklS74GS/rH7Jcy6cJDCrASOI9KM=;
        b=h5AAR9oUDVOzISjtudjWY/Whnvt+shm8ylcHpgqbuVUC6f3goEojxiJ4jo6jcw7rIT
         yYHLuYTUgsjTwjEGQbGxUhoY2o//3iH8N1uS+Mu/5TqIuppaFRd+4LeO8CWXQ5V5lkDe
         kW/MBLT7m0bcfQ0ekHPSnjS7pgs1ITfMqD7GQUuHb/hHCvd2vMr4vPGuESRNQPKv6ZZa
         Z8yR6mH9fjaPeXs8fJnhIKW9ngwZMonjYRjn9Ux+/uN3WIHty+OaRH9lHhh3aSYavQz/
         plm/FJ+aBM+LbV0aDHTRtUhPhs+RuUIPRh1WMD+glQKLKJIHJndDV+3jKqeFbdgJYwJ/
         0vYg==
X-Gm-Message-State: APjAAAVtiyi1Bjo6HAmlU1kxKZDSGZYCHrj0GkfnmlCqh+gXkrfsaNX8
	ObVlms7WF01Z//8BwuRhvykFGNbKuRQy5o7gRLqpwC4rSVGbdo/XOsVZdTZcNOC8kLZs/vg8Rpm
	8ebUKOJc3uJ0AAz2KMVkHMzAbWLWC0wYrvO5ix3gS4+dfymCY4ajZ9rwd12UFWhcNPQ==
X-Received: by 2002:a9d:4d05:: with SMTP id n5mr8018052otf.361.1562937469144;
        Fri, 12 Jul 2019 06:17:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/4r8QMyOX4UdiNwayzO9m/CD5SmTsOm9/83+CFKgKoLlhgRm4yGr0tk8zGGuaJl5M2Qko
X-Received: by 2002:a9d:4d05:: with SMTP id n5mr8018008otf.361.1562937468448;
        Fri, 12 Jul 2019 06:17:48 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562937468; cv=pass;
        d=google.com; s=arc-20160816;
        b=TluGzPl2V/B+p4gNUWi11GpVM+reCQtmNe6EnoUgAyTj++4//UKS9vfytndjtfn6HE
         b5ymQgvvl2v0xjb87cqO9lhin2Xt2r7oFm7l+Jrf5YwNVoqV6KJzL3RqRAXMgEZLGGtp
         7xKXfuV5J9leVNryiVdxSP5Wn+1iU595/EiLPIKpSNfx+GotmJXYjvqcp8JxVGGe0r6a
         uznfC4jKzeB4Itbzqw60hPxUe1C5nGCegY3pwcGWqaSM9aF1CEnMIfhzrRhI3Y3ISiTt
         j3Lp8eRHAuVKNn/02kJeXpbZbjxHla1XEbxoK82SVLueJIc9r9lZSYZuZoKtAIVU4jY+
         nYyg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=MWoXk/DXnocxMRQgklS74GS/rH7Jcy6cJDCrASOI9KM=;
        b=FJc22m9V/m3Av9o/bR0EIx+aB/pjMJobB4+Ko3VfhAWGN7h27aa3pzAZDUcSQJb/FJ
         mXgWo4wOzn/EfKnohKcRV7M6Pu8Kp73HLu0WZBoULvFxe9lkR37ujwUl5+D85f0Cos1c
         LdWsEsIKrqGDwN9A8jhOoqn8xMFYZiLgl5iVXPkGnPt9C75Mi6fQ0f14hyYoWX3+GWry
         t4C6pWPOGApQnsKdMLDx5UvHz1t2eCCqAHjW99zj/tZiFAioHKA2nW45mZXxhXAFXHv2
         /JV7zSJ5fl8pao3bnjIHJEmcmvFVWP3pWBXeGVeHMXyxcQGKZdx/D7fS3pk8EQ68SGaD
         UapA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=bICylbc6;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of akaher@vmware.com designates 40.107.73.44 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730044.outbound.protection.outlook.com. [40.107.73.44])
        by mx.google.com with ESMTPS id n204si5436659oig.89.2019.07.12.06.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:17:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 40.107.73.44 as permitted sender) client-ip=40.107.73.44;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=bICylbc6;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of akaher@vmware.com designates 40.107.73.44 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=nduMvQ4iCW8DZgimi7uQUcdOZLNvp59Bo6WRYDBHss/mDgCsM+QXJIvgu8btH0QF++GdYW84AI3XsjR06EcMGGUmOaFDl4Adhda+yEbxLelaH3FiMJh2dK9ONOKIUSRIytSyKiMa4QuaKEdV70yVJJi4IZy4G/NB7JitcJ3+/UlhsnvPUdwoFt8CUhDxosHRR72CR9sGmfzhdgLBzNLEDe2n2tiUqPGrOcDujnIOBOfvP4ycTSy8e9GP0wndpAdglXOCrjzkP6HjKOXOq4MTQ2iqi/ssiouqwW5F3g1yFUkB0Gv/USJ1PE++SUUGmmW7MmwpswDFdh+0+z334HIRGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MWoXk/DXnocxMRQgklS74GS/rH7Jcy6cJDCrASOI9KM=;
 b=P9mN67+GT3K53vkJeoinS1S/Jc/AhkKmmHY9iQIW/EG7851UovLnVPLeVmU+uqTajFphUyF3WgmtgPpjLRq9UzmMNLYhJhwHw6NbyQW3x77aOPVYP29MNpR/TzCR41R+yBz7DNbceYwciqav8dnqVGpPagYuRTBapP/TcsSynbvdlXiE7ljGBTrTLcbcfIo+YhldHHZkXIThz2TssdqQiLIIafQ/Ipw5cNJP82Ygh3tWuQXh5UiVbOhsDQW+ZKSF6A0BpYRz+ydY19TnhcPb09UEUGV8CHMFovOEa4tIrg9HLRRSkopNQxJc6i2vBfPFxLhl8bHM0cWTpWVGe1qQbg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=vmware.com;dmarc=pass action=none
 header.from=vmware.com;dkim=pass header.d=vmware.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MWoXk/DXnocxMRQgklS74GS/rH7Jcy6cJDCrASOI9KM=;
 b=bICylbc6pG5bUBIiaVbYT6xLPk6+narjw2FQqTL5VyTDUj50dLp1ipI8DMrK8oNu6c3qhOlUS5nR0kM5+4paWugZNOI6RbhmpGODe+VaOw88BaCinsFc+U84QFitiiTfjgJkqF+C2+SNXo98bT0Vj26dyuPS5ypmGCU/9fFwqFE=
Received: from MN2PR05MB6208.namprd05.prod.outlook.com (20.178.241.91) by
 MN2PR05MB6719.namprd05.prod.outlook.com (20.178.249.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.3; Fri, 12 Jul 2019 13:17:45 +0000
Received: from MN2PR05MB6208.namprd05.prod.outlook.com
 ([fe80::301b:150c:dc88:7d04]) by MN2PR05MB6208.namprd05.prod.outlook.com
 ([fe80::301b:150c:dc88:7d04%6]) with mapi id 15.20.2094.007; Fri, 12 Jul 2019
 13:17:45 +0000
From: Ajay Kaher <akaher@vmware.com>
To: "aarcange@redhat.com" <aarcange@redhat.com>, "jannh@google.com"
	<jannh@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "peterx@redhat.com"
	<peterx@redhat.com>, "rppt@linux.ibm.com" <rppt@linux.ibm.com>,
	"jgg@mellanox.com" <jgg@mellanox.com>, "mhocko@suse.com" <mhocko@suse.com>
CC: "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>, "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>, "viro@zeniv.linux.org.uk"
	<viro@zeniv.linux.org.uk>, "riandrews@android.com" <riandrews@android.com>,
	"arve@android.com" <arve@android.com>, "yishaih@mellanox.com"
	<yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>,
	"sean.hefty@intel.com" <sean.hefty@intel.com>, "hal.rosenstock@gmail.com"
	<hal.rosenstock@gmail.com>, "matanb@mellanox.com" <matanb@mellanox.com>,
	"leonro@mellanox.com" <leonro@mellanox.com>, "gregkh@linuxfoundation.org"
	<gregkh@linuxfoundation.org>, "torvalds@linux-foundation.org"
	<torvalds@linux-foundation.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Srivatsa Bhat
	<srivatsab@vmware.com>, Alexey Makhalov <amakhalov@vmware.com>, Vasavi
 Sirnapalli <vsirnapalli@vmware.com>, "srivatsa@csail.mit.edu"
	<srivatsa@csail.mit.edu>
Subject: Re: [PATCH v5 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Topic: [PATCH v5 0/3] [v4.9.y] coredump: fix race condition between
 mmget_not_zero()/get_task_mm() and core dumping
Thread-Index: AQHVL/h+GI4Pt8Sp2UWWD50ZJ8kpwqbHZHEA
Date: Fri, 12 Jul 2019 13:17:45 +0000
Message-ID: <77C72259-6378-4161-952D-D94D7412D85C@vmware.com>
References: <1562005928-1929-1-git-send-email-akaher@vmware.com>
 <1562005928-1929-4-git-send-email-akaher@vmware.com>
In-Reply-To: <1562005928-1929-4-git-send-email-akaher@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=akaher@vmware.com; 
x-originating-ip: [103.19.212.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e33fffbb-a3e4-4774-2bcd-08d706cb544f
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MN2PR05MB6719;
x-ms-traffictypediagnostic: MN2PR05MB6719:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB67190F364AA0312F75CC8ABABBF20@MN2PR05MB6719.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 00963989E5
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(136003)(39860400002)(366004)(396003)(376002)(199004)(189003)(2201001)(54906003)(6506007)(71200400001)(71190400001)(66446008)(64756008)(66556008)(66476007)(66946007)(7416002)(4744005)(4326008)(110136005)(6116002)(3846002)(76116006)(91956017)(5660300002)(2501003)(6246003)(486006)(53936002)(8676002)(102836004)(76176011)(66066001)(25786009)(6512007)(86362001)(36756003)(11346002)(68736007)(33656002)(2906002)(229853002)(476003)(446003)(2616005)(81156014)(8936002)(186003)(81166006)(26005)(6486002)(14454004)(6436002)(256004)(7736002)(316002)(305945005)(478600001)(99286004);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6719;H:MN2PR05MB6208.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 QdPkjnJdIhMnKYPyPqHJjX0qtSvUhVXY2PNr6QxoTVXr+COKCTyPNeV9aflYELRtHlgWVqzWQTlxPotmdbspj5wdVQq8AJQzwkVPOVpBa8ATN1/FgrLmpGcqKnWlVBBf5qWKaQPmNzFsEk1NJJx5iWClmpvH/Iyntbccv4Q16tyGuEwtLLybFFetksoV8MotR33nirXQ+A2Ch26gSx23eVw147Clpxlkb6QVqk7XWzOlxUWNc1YIzvRKbWQaKCzH+dKH00G9x3xCc4KlA6VdKo4wnxGn4+i/TxCV4t6cxq+Bkwo40qzT6rLDWdT+9uqoA8QqT62HS+UXCmM+OP4gADep20QDg/0Y7J0R0bOUU006Qq6hOUW/WpgUQQsOjIPHy4EqESY6GhIW9ZQBNrLkYSaN2W+rXrEkj7sQzVyiCGY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <4184F8DE6E30494DA75193C8ACF308A5@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e33fffbb-a3e4-4774-2bcd-08d706cb544f
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jul 2019 13:17:45.4689
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: akaher@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6719
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

R3JlZywgSSBob3BlIHlvdSB3b3VsZCBsaWtlIHRvIGluY2x1ZGUgdGhlc2UgcGF0Y2hlcyBpbiBu
ZXh0IHJlbGVhc2UuDQpJbiBjYXNlIGFueSByZXZpZXcgY29tbWVudCBwbGVhc2UgbGV0IG1lIGtu
b3cuDQoNCi0gQWpheQ0KDQoNCu+7v09uIDAxLzA3LzE5LCA0OjAzIFBNLCAiQWpheSBLYWhlciIg
PGFrYWhlckB2bXdhcmUuY29tPiB3cm90ZToNCg0KPiBjb3JlZHVtcDogZml4IHJhY2UgY29uZGl0
aW9uIGJldHdlZW4gbW1nZXRfbm90X3plcm8oKS9nZXRfdGFza19tbSgpDQo+IGFuZCBjb3JlIGR1
bXBpbmcNCiAgICANCj4gW1BBVENIIHY1IDEvM106DQo+IEJhY2twb3J0aW5nIG9mIGNvbW1pdCAw
NGY1ODY2ZTQxZmI3MDY5MGUyODM5NzQ4N2Q4YmQ4ZWVhN2Q3MTJhIHVwc3RyZWFtLg0KICAgIA0K
PiBbUEFUQ0ggdjUgMi8zXToNCj4gRXh0ZW5zaW9uIG9mIGNvbW1pdCAwNGY1ODY2ZTQxZmIgdG8g
Zml4IHRoZSByYWNlIGNvbmRpdGlvbiBiZXR3ZWVuDQo+IGdldF90YXNrX21tKCkgYW5kIGNvcmUg
ZHVtcGluZyBmb3IgSUItPm1seDQgYW5kIElCLT5tbHg1IGRyaXZlcnMuDQogICAgDQo+IFtQQVRD
SCB2NSAzLzNdDQo+IEJhY2twb3J0aW5nIG9mIGNvbW1pdCA1OWVhNmQwNmNmYTkyNDdiNTg2YTY5
NWMyMWY5NGFmYTcxODNhZjc0IHVwc3RyZWFtLg0KICAgIA0KPiBbZGlmZiBmcm9tIHY0XToNCj4g
LSBDb3JyZWN0ZWQgU3ViamVjdCBsaW5lIGZvciBbUEFUQ0ggdjUgMi8zXSwgW1BBVENIIHY1IDMv
M10NCiAgICANCg0K

