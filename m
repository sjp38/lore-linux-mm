Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6D6DC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 23:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2554C206E0
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 23:28:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="hn6dY7g7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2554C206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 967D36B0005; Fri,  3 May 2019 19:28:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 918D66B0006; Fri,  3 May 2019 19:28:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B9396B0007; Fri,  3 May 2019 19:28:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA5D6B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 19:28:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 18so5277097eds.5
        for <linux-mm@kvack.org>; Fri, 03 May 2019 16:28:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=eMqWUI2G/ksOaJmStmpjJCrxAv/NkatFY6m2td/HHaE=;
        b=TpyRXD1Ptdil6r/LyUQXNFMVUw7hXmlKjQ3iPHFYTVfT/CjLdkufVzxauWpMtiQQVh
         9dgS5E5FT8dntnkGcw6+eZyhS0UrFZPsjtmU/GdHCI+UhBhd+x902PSuRj5vy3drMu0N
         d/I/r8RFHQYB5g8JpuYg+eNEIOYabUiGccZHPt5KCyJ2tOWnZ/rIs41qzmFh5ahfXxdd
         z2Ylx/quP2fpQY6iTW5Ze4xTLoPt0rKPeEylcDV9brIPVl1F/q4RS6klI+oDXCmC2XIY
         55h9zkMAiv5iI2+byqmHinVui5SHz340q6G/rwPDVWaIQ61QUbLC9cVFB4tSh1xvht7F
         qe8A==
X-Gm-Message-State: APjAAAXG8F+yjKQR/CMJm6dGitaMuTxo3R5rfXqZqhgfAcQvpDzFbUEO
	AY9FGyVz2a9swy4jMUwo/4dGafCFkTu0S56YNrY28EbuY+LeEzXfwa3CnOTmiVBYHjHcSpfgAp3
	lX4XNsbmPADXrCyXGEhlJZbBMdpgHBpogX1MwsDNIheoSIH+YxvEkOb0G6OMfR0FzYQ==
X-Received: by 2002:aa7:c645:: with SMTP id z5mr9197455edr.43.1556926107652;
        Fri, 03 May 2019 16:28:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylkuw7CfcuaQiSOapfrYgqA59I+zj7hw+iRHzgsuuQtvBlrQwycKY5iOS07sxnzHAlHbRX
X-Received: by 2002:aa7:c645:: with SMTP id z5mr9197405edr.43.1556926106807;
        Fri, 03 May 2019 16:28:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556926106; cv=none;
        d=google.com; s=arc-20160816;
        b=K2Yevp4L9wodQmVzWIhd0sn3gtNn/HDO2Kxb4ocd1MuBHc2SYx/UpyDKW3HFMT84cD
         6lFVXQ0ba3g306IxwCbvpqRUv8cB019/Cfu6ZbcXtPgVvXpc7xJToiVb9toHiZPOvpnh
         n3SUChRkBCB6ihJH0IHYlBHp3qM0SfDVbOiEhoOjzpmmlf145lNQj7j6+K7p7FnbKaBq
         fWmezyAm/8MjDAHknnUZcHIDVSzIIb6oApP6raJaxhTVVywXs0qBGGttwrNKOZQf7Hk5
         9xYyzoaDr9LA63Xo4sfTji9cjCSNayKwEP2GrnKSqE5tRgK9PJkR2WK9nujN0jYJIsj6
         QzFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=eMqWUI2G/ksOaJmStmpjJCrxAv/NkatFY6m2td/HHaE=;
        b=v6uJ9Ua8WNwJDwCdTj0mcS7L1stcdqWwjcpGzDvPU2PN3gMRWEFbTRohBG197HyUOK
         /AzayjMWHpKsRB3Fk9mHMS9Z9Lm++bjb8AIYQIkwzoS/0iV1fXHCwhEkV5bIRcqMYa2u
         l5/NlDI6R/r9v7uS/EwabGGrR0aToI/VZSE3y2nYWgDBVXMBF6/3MxKtsR33icSO8yKQ
         23R46mTl8xYsoBN2a7ozqQp3IF6yVC8T1L4LildjmRE5bz8UaiOs8g8FBJzgpoQ96ZcB
         ZM/GZ3VGmbEyxPA6BGOEgJwNYCW+h5U3LS4gq0y4pFUfuLYifq+QQuhsHNjnnilo9eVF
         ZpVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=hn6dY7g7;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70042.outbound.protection.outlook.com. [40.107.7.42])
        by mx.google.com with ESMTPS id fj23si2560308ejb.38.2019.05.03.16.28.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 May 2019 16:28:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) client-ip=40.107.7.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=hn6dY7g7;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.7.42 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=eMqWUI2G/ksOaJmStmpjJCrxAv/NkatFY6m2td/HHaE=;
 b=hn6dY7g7Ps9UCNFhsY1boaR3VUt/n7cy460xSr+3PAwdvL0zzHqQ1JbPNoK8xhKIV2fM+mF+b7Lq4bRKmrTmlqXa0MQKyc5mU59HdywJ4/6f5aKrNIC6S9GV+PucrqLLkRecvIbiXz3M3c+bGZSCH5Fym7aWjP0NVQ7utHKg1pk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB3357.eurprd05.prod.outlook.com (10.170.238.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.12; Fri, 3 May 2019 23:28:22 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::711b:c0d6:eece:f044]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::711b:c0d6:eece:f044%5]) with mapi id 15.20.1856.008; Fri, 3 May 2019
 23:28:22 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Alan Tull
	<atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Alex Williamson
	<alex.williamson@redhat.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Christoph Lameter <cl@linux.com>, Christophe
 Leroy <christophe.leroy@c-s.fr>, Davidlohr Bueso <dave@stgolabs.net>, Mark
 Rutland <mark.rutland@arm.com>, Michael Ellerman <mpe@ellerman.id.au>, Moritz
 Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>, Steve Sistare
	<steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"kvm-ppc@vger.kernel.org" <kvm-ppc@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-fpga@vger.kernel.org" <linux-fpga@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm: add account_locked_vm utility function
Thread-Topic: [PATCH] mm: add account_locked_vm utility function
Thread-Index: AQHVAe2ZLngO8JYpNki+X4vS/Cz1vqZaC+sA
Date: Fri, 3 May 2019 23:28:22 +0000
Message-ID: <20190503232818.GA5182@mellanox.com>
References: <20190503201629.20512-1-daniel.m.jordan@oracle.com>
In-Reply-To: <20190503201629.20512-1-daniel.m.jordan@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR04CA0003.namprd04.prod.outlook.com
 (2603:10b6:208:d4::16) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [65.119.211.164]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cbafa94b-6447-4be8-56b3-08d6d01f0818
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB3357;
x-ms-traffictypediagnostic: VI1PR05MB3357:
x-microsoft-antispam-prvs:
 <VI1PR05MB33578A2BC54EF9B341D8F7FDCF350@VI1PR05MB3357.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0026334A56
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(346002)(39860400002)(376002)(366004)(189003)(199004)(186003)(8936002)(6916009)(53936002)(11346002)(446003)(316002)(2906002)(2616005)(6246003)(386003)(7736002)(305945005)(6506007)(26005)(66946007)(66446008)(1076003)(33656002)(5660300002)(66476007)(66556008)(64756008)(73956011)(15650500001)(4326008)(102836004)(81156014)(36756003)(25786009)(3846002)(6116002)(99286004)(6486002)(66066001)(86362001)(52116002)(7416002)(14454004)(6436002)(486006)(68736007)(71200400001)(54906003)(476003)(229853002)(71190400001)(6512007)(81166006)(76176011)(14444005)(478600001)(256004)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB3357;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 9MggK/iMBpnv+TQWX1Y6xFTS5HHusO1C0bnxQyn7vZkFZN8dPKUOJIgFo1LMg2KiSdlVm3+U697HF0tSDf0Y17UeKgOKYd8UFLsizzRP7FxW4JzMD7jl4Wnj7gtZHqG6M7RigUH1tIHPMa48M/V3ENKTCWYrrNqKODknwq2+en4Y44Cdn50yhM8stLsiKRDaE40HKhXlMlxzDgtgyJE0UgPHQ1oW2z2MlzBhdBQlLg54fr/TNvn8Z8xOOmjwVb9FYypHcfiKt83xiQO6SwqPhMK49lWiFmgh7561E55Wqv4nDpj7YIn6c9UxWwMI/dpwqVvXnsoKUfNRXxCGgj9ouQIm5UEH0rhZPqvhfHoOEyfqkLEXCCXuo+9/QYi7kmvytl85Kgih04VuzfSUJgFA/DQJYi2wupIPY1g136PN0ss=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6BC684B50DAD6D4A8D031B0B8F7E32C4@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: cbafa94b-6447-4be8-56b3-08d6d01f0818
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 May 2019 23:28:22.2133
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB3357
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2019 at 01:16:30PM -0700, Daniel Jordan wrote:
> locked_vm accounting is done roughly the same way in five places, so
> unify them in a helper.  Standardize the debug prints, which vary
> slightly.  Error codes stay the same, so user-visible behavior does too.
>=20
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Alan Tull <atull@kernel.org>
> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
> Cc: Alex Williamson <alex.williamson@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Christophe Leroy <christophe.leroy@c-s.fr>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Moritz Fischer <mdf@kernel.org>
> Cc: Paul Mackerras <paulus@ozlabs.org>
> Cc: Steve Sistare <steven.sistare@oracle.com>
> Cc: Wu Hao <hao.wu@intel.com>
> Cc: linux-mm@kvack.org
> Cc: kvm@vger.kernel.org
> Cc: kvm-ppc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-fpga@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
>=20
> Based on v5.1-rc7.  Tested with the vfio type1 driver.  Any feedback
> welcome.
>=20
> Andrew, this one patch replaces these six from [1]:
>=20
>     mm-change-locked_vms-type-from-unsigned-long-to-atomic64_t.patch
>     vfio-type1-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
>     vfio-spapr_tce-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
>     fpga-dlf-afu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
>     kvm-book3s-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
>     powerpc-mmu-drop-mmap_sem-now-that-locked_vm-is-atomic.patch
>=20
> That series converts locked_vm to an atomic, but on closer inspection cau=
ses at
> least one accounting race in mremap, and fixing it just for this type
> conversion came with too much ugly in the core mm to justify, especially =
when
> the right long-term fix is making these drivers use pinned_vm instead.

Did we ever decide what to do here? Should all these drivers be
switched to pinned_vm anyhow?

Jason

