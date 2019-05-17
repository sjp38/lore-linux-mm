Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7B00C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36A1620848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:10:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="ZMKnlfWW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36A1620848
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9959B6B0003; Fri, 17 May 2019 13:10:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 946906B0005; Fri, 17 May 2019 13:10:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E62C6B0006; Fri, 17 May 2019 13:10:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5629D6B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:10:31 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id j9so3055284oih.19
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:10:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=PAKADOLlQH6OjaqNSsLfmaOHfMl+eoBy3jCe/k4AUVQ=;
        b=j3Zn4JGgSgUM/UDfWf0+8dZ/JOPtdL5H247ef7jdV4gAOaJEw1lcKOxbNTOIXnXSWT
         ubiLdHoMGNQj+NouhBE0P1uKS+1G0KELih1QQJB+Ubcd7iHld5BbchcWlCWc5Qng7auL
         ilVxSxiQ+va4cCvjQcKojxBvKxX1DgLVzGvEJzWme7GHyUbIVU/MOzQvg8FlDxaNiWwk
         6GZ5Pe+0SGfqXfQCgkSPsBKWnXlOYWy4JQn26zvhJgJZA0WpdgVPQOKh506/cFfFfM/j
         ZoVZ8Y/QZk/gpj6Zcz6byz+FU9FsldSKnBEOvD4bRSyYU7XB9QjNx8fEASflkOcXWize
         BjsA==
X-Gm-Message-State: APjAAAVB/KKLsFtOvB/g5TPEjeBbIsDewVOPFqsh+TGqSNE6in2/+E1e
	Hy77rVYV507GTIHrxUPcvfM+rMwkYxFSk48z8LHU+QNZZLWwZmj6w8ndZbWIxgcKn3B1Pq8391/
	sgES1UzuSC8YaLZ6q4ynOxOCTMsz2ObpoSxw4etCdFN8mzlJLWXe5lnLVKKYKe+3FnQ==
X-Received: by 2002:a9d:3b06:: with SMTP id z6mr34008202otb.140.1558113030893;
        Fri, 17 May 2019 10:10:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXScetQlAgp8ZgBC+3xcEFw3RLYv1SEGR/zL54X9nZj8PyRG8eFuB8tq2TdukOs/owE8zn
X-Received: by 2002:a9d:3b06:: with SMTP id z6mr34008153otb.140.1558113030221;
        Fri, 17 May 2019 10:10:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113030; cv=none;
        d=google.com; s=arc-20160816;
        b=ZLq/a0BO5eLbZ2aZQeOzSRLRQDxfGErhcdCGICrbALMIiDLgBZ1OKmEH2KrObAuLVm
         zf4Nh4QJQ+mK1ZSRk8MYyX2TJFRQPLXiglCBJkhV1ZrbcENI+Z+aCpJjX3lpANFJFro7
         8o4rUo2WTQrYraTWayU2FwDX9OYH9jC0KewXBI30MmpBse2J9R13fPs3uTU5cqWzzbdd
         gFBAn5KdCpbEdu8DINJg2tQ6Vxv/pm5ufyjFRmphsEcz/cKDIPfz7GAjj9S69thC0Xoq
         gorKMtgljR4Be75/VtDyOt5LhJFS6/9aYtIlrwe9VKjiwbOPlNV1CwSlPe/AWDvx0bD8
         tDyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=PAKADOLlQH6OjaqNSsLfmaOHfMl+eoBy3jCe/k4AUVQ=;
        b=nh9gHzFrHYWTpKiK7Rxh+jNFRRp0jUCqVe/MUCzq1tQJPp5MMRfQP1VGzXmpqqieoE
         m9XxgAf6DcGQVIPMFrQlb6pFgTiFjIKKw1gj9iqOZT3va4FrQJ/ergztIcEuWTxRMRXc
         HMzgsOZ2eltuFkrFxt9giaj/KrQCadGAkeils+cYXoDh5cOx7aPxK7vUE4ZejoAlL62a
         IfTHkfXFKDeqrHGSAfGLD7Ob/AzX0d7EUA9Z4kn5/GeLnPW6BtrsjxfQT2SHsf0sYPyH
         4H8kHZ2yH7LkkGqpr92WUHXUFAEc9X/rmcZI3sKNFFu35lwo0Pu94ZkXuBL/lZwmme2Y
         hSdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=ZMKnlfWW;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.77 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770077.outbound.protection.outlook.com. [40.107.77.77])
        by mx.google.com with ESMTPS id v7si4680134otj.181.2019.05.17.10.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 17 May 2019 10:10:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.77.77 as permitted sender) client-ip=40.107.77.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=ZMKnlfWW;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.77.77 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PAKADOLlQH6OjaqNSsLfmaOHfMl+eoBy3jCe/k4AUVQ=;
 b=ZMKnlfWW4C4OZ9xkPpnacmCTcU246SPs6c8uovlrFpv0MnajpCOqUaF8noYOaBp+TouOWBShfkmEbHFHwjtTA9ZreVWB4k2WFClMD1a6Ka3t739lfAuKYjHRZNOksMMxVoDBfz0zBX+GXbByQRZdeQ3MNwpE0KbLX/aqj377E18=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6696.namprd05.prod.outlook.com (20.178.235.206) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.10; Fri, 17 May 2019 17:10:23 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::b057:917a:f098:6098%7]) with mapi id 15.20.1922.002; Fri, 17 May 2019
 17:10:23 +0000
From: Nadav Amit <namit@vmware.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>
CC: Julien Freche <jfreche@vmware.com>, Pv-drivers <Pv-drivers@vmware.com>,
	Jason Wang <jasowang@redhat.com>, lkml <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Topic: [PATCH v4 0/4] vmw_balloon: Compaction and shrinker support
Thread-Index: AQHU+5sfw4lXp6MJj0Ov0LaKSU1Rk6ZaOUgAgBV2VAA=
Date: Fri, 17 May 2019 17:10:23 +0000
Message-ID: <9AD9FE33-1825-4D1A-914F-9C29DF93DC8D@vmware.com>
References: <20190425115445.20815-1-namit@vmware.com>
 <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
In-Reply-To: <8A2D1D43-759A-4B09-B781-31E9002AE3DA@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3b7893ab-7413-4e4b-422e-08d6daea8cb2
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB6696;
x-ms-traffictypediagnostic: BYAPR05MB6696:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB66962251319BC5C7A6401005D00B0@BYAPR05MB6696.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3276;
x-forefront-prvs: 0040126723
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(136003)(396003)(376002)(346002)(189003)(199004)(53936002)(110136005)(99286004)(76176011)(53546011)(102836004)(33656002)(6506007)(66066001)(316002)(86362001)(82746002)(5660300002)(486006)(476003)(54906003)(76116006)(73956011)(2616005)(186003)(478600001)(26005)(6512007)(14454004)(6486002)(446003)(11346002)(229853002)(6436002)(6116002)(3846002)(14444005)(66556008)(71200400001)(71190400001)(4326008)(83716004)(68736007)(25786009)(6246003)(256004)(2906002)(8936002)(36756003)(66476007)(64756008)(66446008)(66946007)(305945005)(7736002)(8676002)(81156014)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6696;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 6Sp8TACZchpG8gzKBlId5O7YsGRXGaVhOPOjLkRuDx6bYt2bQsqNLwZlU1Ah08uvD157mq7fgd0NQxUTN7y4FskdJ54/Ol/Y18OMeC5gvBFgQLgjeUs5vsVaG2d6/Qs17tc5JFaTirnIZKtLt9aev8d/NN/7MXzM9G1AKyH+2uWt9u81WeIXUkdm6AyNxeF6XZYcg7TXrGWhYRz1UukNDnyQMAbZ+yjL44GwBuHUzo2VNW1iS7LpUlY+Y4DV2ZA+zvzFA6ybujpaRGAzzWMC9ALottnOBxc0zLssnLaD8WKpmfOkMYGd+NRy7yqAGiHGRh1FfIcqHVbSAQeIkCv8G7hh3NZ7YjZTUvK8yQz0JdwEjBYTkhXKtFR/jmgNJyQaR6cXpfE5zQ1+2JICEdMMRQhsnEDiHYoHPSxUFAGEUio=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D489544212C01046B2B5533DCF95669B@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3b7893ab-7413-4e4b-422e-08d6daea8cb2
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 May 2019 17:10:23.6289
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6696
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On May 3, 2019, at 6:25 PM, Nadav Amit <namit@vmware.com> wrote:
>=20
>> On Apr 25, 2019, at 4:54 AM, Nadav Amit <namit@vmware.com> wrote:
>>=20
>> VMware balloon enhancements: adding support for memory compaction,
>> memory shrinker (to prevent OOM) and splitting of refused pages to
>> prevent recurring inflations.
>>=20
>> Patches 1-2: Support for compaction
>> Patch 3: Support for memory shrinker - disabled by default
>> Patch 4: Split refused pages to improve performance
>>=20
>> v3->v4:
>> * "get around to" comment [Michael]
>> * Put list_add under page lock [Michael]
>>=20
>> v2->v3:
>> * Fixing wrong argument type (int->size_t) [Michael]
>> * Fixing a comment (it) [Michael]
>> * Reinstating the BUG_ON() when page is locked [Michael]=20
>>=20
>> v1->v2:
>> * Return number of pages in list enqueue/dequeue interfaces [Michael]
>> * Removed first two patches which were already merged
>>=20
>> Nadav Amit (4):
>> mm/balloon_compaction: List interfaces
>> vmw_balloon: Compaction support
>> vmw_balloon: Add memory shrinker
>> vmw_balloon: Split refused pages
>>=20
>> drivers/misc/Kconfig               |   1 +
>> drivers/misc/vmw_balloon.c         | 489 ++++++++++++++++++++++++++---
>> include/linux/balloon_compaction.h |   4 +
>> mm/balloon_compaction.c            | 144 ++++++---
>> 4 files changed, 553 insertions(+), 85 deletions(-)
>>=20
>> --=20
>> 2.19.1
>=20
> Ping.

Ping.

Greg, did it got lost again?

