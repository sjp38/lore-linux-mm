Return-Path: <SRS0=c8nW=TE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2985DC43219
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 01:25:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1C152075E
	for <linux-mm@archiver.kernel.org>; Sat,  4 May 2019 01:25:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="lEgevMdZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1C152075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7D7F6B0003; Fri,  3 May 2019 21:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D06C86B0006; Fri,  3 May 2019 21:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7C16B0007; Fri,  3 May 2019 21:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3AE6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 21:25:35 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id o13so3568223otk.12
        for <linux-mm@kvack.org>; Fri, 03 May 2019 18:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=mdKWZNWsC2QDZPr7BKiJhEirVBVPb9zk96COLc9DNXU=;
        b=pO68JxEd4Ma8IfgHl6xiL6Nxo6VepVvdz6TgFQnjxf26Q5VFgimZrPLfKqgs80IayP
         HdOSfYXb25lT6ZwIEhQ74iCAXheOIe5tZPMEROaZTc4bD2CnN7ttieK2OlfFBvJFWZ/y
         YAXbOJHEm3BbnKLYoCjIdldFGeAA886ZOC9zbzW1Sj64Hmq18PEBCke08PGkvZmsJHEm
         r1RVe3axn7X2DDDLXQuMLHvliqnPBtKTYSE2gOAayMpe61i3JFNGKfGHW76fJR3u/22E
         Buahlz01J9G0x2bgRqit9XtJABISqKdouyhF4LL7KpyI9nclfKKLI/6c0lfrpexU7/nu
         Z38A==
X-Gm-Message-State: APjAAAUDr7GvP1YF8MlEBap+tWJt4Tx6KJhpgjEospT6lN5rv5/gjRLx
	E7HelHuVMxUZl0IvM2scoCTSqoJu/zIm0wWecNo2H15T+QYAmqmGF8uWoNqQUchluUHGmPMj8X2
	NdMX0YSJKFaoSfdnieSYg0z3YAJW/tfncJQOUCSigGS5wGyYlvoEgwBmydGP7vFQ6OA==
X-Received: by 2002:aca:5b06:: with SMTP id p6mr1164223oib.129.1556933135100;
        Fri, 03 May 2019 18:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7+zlFcULII5gvuA+GUrg7MPY07ffrL8OMM+ps5iRRotE7VBnAWc5OSMUNwRRGvW+r/Nh4
X-Received: by 2002:aca:5b06:: with SMTP id p6mr1164197oib.129.1556933134141;
        Fri, 03 May 2019 18:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556933134; cv=none;
        d=google.com; s=arc-20160816;
        b=Yi9DrKPU29CuYnXnRQx/RteOg7cFatcgqYliv0wgUVDtTL32Y8FMg32DzJBM0VIHwv
         uiaKWbqyIh3JliJZApT8dZTRtsyddShTg1PUlo07msdj9pg6QHizbqNT1gJVrpDhHO6G
         qgoXv/vwnRo5XG2nVy1SgmW0u5PBvIkmoti9CYIla3aDRvEq9n/zBX9I6wxURC4c2DOY
         kRufdjo1LbSkLYtgHNgsUgDGpSuK0FRo5E33OiAr4LKHQVOdBpkzY4hyZ7TNO4VA2/Gg
         7gb5ZG9NI5+xIUeuW/GhyEdKF6NZEN56AZFRuYy8S+zfAmmOzPay6YsK9IWcJEL+2gh5
         qbug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=mdKWZNWsC2QDZPr7BKiJhEirVBVPb9zk96COLc9DNXU=;
        b=zXN4dsknpluikO2E1AGppAG2GlZzOpUw78haJ5jLv2maQ5IjWmqs73u5LB6IE4hdTn
         wr5ruB5/gQptiooppewQ4dHGJiYlBUpBgETEuP/1yhu8ruiPVqtlRM7jxgo5yTxA1p6g
         zWq+3S08lDvV2A53unfd1TMMP46H4ULjJaW3sghiJB7v3kuFEKPA7ToVpQZ/6dxzSHpC
         Ux6tfapW+X0HCxdzbpdSAx35f49wMdsPW9uJXw+ZTih8dSqPPBK3VzFdfMD1UruPw75b
         Qvq8aQTrB/y8XbHGYhXrf5WJ85hhE7DpREX3wPknbm+X1utYIktCGml5YqmtqHEXWXS9
         J7dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=lEgevMdZ;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.41 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800041.outbound.protection.outlook.com. [40.107.80.41])
        by mx.google.com with ESMTPS id a21si2523373otk.244.2019.05.03.18.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 May 2019 18:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.80.41 as permitted sender) client-ip=40.107.80.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=lEgevMdZ;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.80.41 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=mdKWZNWsC2QDZPr7BKiJhEirVBVPb9zk96COLc9DNXU=;
 b=lEgevMdZZX+zU54N6kgdk2i69yRAMZ1RjdI734MtLBF+Afc95EpzNxORO0FD2WfvJutDMZ0kn2ymdhvZRhsQkp5e9pvW+q33KQiq9UCAA6F83BbIoHEfg7hRKOR+5pje7Z7uJ0sprgYZuotYI3k+6PTIAHzEnBZ+pkpsbZXj0rc=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6213.namprd05.prod.outlook.com (20.178.55.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.10; Sat, 4 May 2019 01:25:25 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1878.012; Sat, 4 May 2019
 01:25:24 +0000
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
CC: Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	Pv-drivers <Pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>, lkml
	<linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Topic: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Index: AQHU+5sfw4lXp6MJj0Ov0LaKSU1Rk6ZaOUgA
Date: Sat, 4 May 2019 01:25:24 +0000
Message-ID: <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
References: <20190425115445.20815-1-namit@vmware.com>
In-Reply-To: <20190425115445.20815-1-namit@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f4bafb9c-9199-422e-8764-08d6d02f623f
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB6213;
x-ms-traffictypediagnostic: BYAPR05MB6213:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB6213679830B52A78D4C2C711D0360@BYAPR05MB6213.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3276;
x-forefront-prvs: 0027ED21E7
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(346002)(376002)(39860400002)(366004)(136003)(189003)(199004)(2616005)(486006)(33656002)(68736007)(36756003)(6486002)(102836004)(186003)(6506007)(26005)(53546011)(8936002)(76176011)(73956011)(3846002)(6116002)(66946007)(66556008)(66446008)(446003)(54906003)(2906002)(7736002)(478600001)(66476007)(64756008)(11346002)(99286004)(14444005)(256004)(25786009)(229853002)(476003)(71200400001)(6916009)(66066001)(305945005)(316002)(76116006)(14454004)(82746002)(8676002)(5660300002)(83716004)(6512007)(4326008)(6246003)(53936002)(71190400001)(86362001)(81166006)(6436002)(81156014);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6213;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 qPo5D/F9hGET3k6Gq/zZ44ji2YXV45Kc7MgTWcwETlnHn+o1eeWnGSiDvUs5kAjzytfoSv+ws1n+fZs1J4v58hq39BFQ1JHzm2kUQJXg1M9q8oiJ4n9pAbEX2X1WCdbZabGpVu1hGH34rfhSC/y/UB3k7N0j2JSj0KikbzqDLe6yc5UrhqPy6u2uZ7VxIZc0Kk9H7IuA6CbB3+uARirVRAFFIlsjZnexzDMA/Qfi5Nq+n9FBc+rfZd54lDbYww6ErRqiudTH5yOS5CRgok602/Papr26lfeYFykWyOj5Ra6wEtA9l+IDEE7LjMlYvajvrZoAS7xGyCpSFfc1AIKZjxuzWV+Ek3NOZb+h7ntzVJkUAtm6KeYfzbz2x5NeWNFMVrj9iNJZsNex8ArbaRvy1gwGO/MK1vcnk0aVZFLa/ns=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <88829AE5ABEA6941919308A6A9557F98@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f4bafb9c-9199-422e-8764-08d6d02f623f
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 May 2019 01:25:24.8825
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6213
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 25, 2019, at 4:54 AM, Nadav Amit <namit@vmware.com> wrote:
>=20
> VMware balloon enhancements: adding support for memory compaction,
> memory shrinker (to prevent OOM) and splitting of refused pages to
> prevent recurring inflations.
>=20
> Patches 1-2: Support for compaction
> Patch 3: Support for memory shrinker - disabled by default
> Patch 4: Split refused pages to improve performance
>=20
> v3->v4:
> * "get around to" comment [Michael]
> * Put list_add under page lock [Michael]
>=20
> v2->v3:
> * Fixing wrong argument type (int->size_t) [Michael]
> * Fixing a comment (it) [Michael]
> * Reinstating the BUG_ON() when page is locked [Michael]=20
>=20
> v1->v2:
> * Return number of pages in list enqueue/dequeue interfaces [Michael]
> * Removed first two patches which were already merged
>=20
> Nadav Amit (4):
>  mm/balloon_compaction: List interfaces
>  vmw_balloon: Compaction support
>  vmw_balloon: Add memory shrinker
>  vmw_balloon: Split refused pages
>=20
> drivers/misc/Kconfig               |   1 +
> drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
> include/linux/balloon_compaction.h |   4 +
> mm/balloon_compaction.c            | 144 ++++++---
> 4 files changed, 553 insertions(+), 85 deletions(-)
>=20
> --=20
> 2.19.1

Ping.

