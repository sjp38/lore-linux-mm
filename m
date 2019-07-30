Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34CD5C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 11:58:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE5AC20693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 11:58:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="pTAUOFHF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE5AC20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEF458E0003; Tue, 30 Jul 2019 07:58:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9EE58E0001; Tue, 30 Jul 2019 07:58:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D40858E0003; Tue, 30 Jul 2019 07:58:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 855B98E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:58:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so40240087eda.3
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 04:58:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :mime-version;
        bh=+33JPkMeNqyLpIkArR+07OT/1Uc18dPOVsUqjAcecF0=;
        b=tTdO8Id7dE3Tl2/BQt8ZmKe0dBUi8b118kPhhlFZGRmCDfjTx58oavDwvKi47MIJcH
         S1195aHicHrCybu/6qNITeITcIJEL7jGa+W2ikHmgzsGncxwc4krzcYDJq1v3u6xkLSZ
         /5MmIhXLDXpmLrjitIJ7AId2cKZJDoi2L+bSe6S5ltQZTBy7YaamtLG7aK5m2tpvYjJu
         d6/FsPd7fySBIGkYYoNcbElrUi9NzSRNougkXuhZ4CxqcVs2VxqGUpwUIgntYwQxh9oy
         J8A1roqaVI0WsAlZ+BdgZ3zq8CxOGwKQbzMTHlv/pe6FnKFLTwD5chUDUZjHbUEmwBPz
         37mA==
X-Gm-Message-State: APjAAAUF6U9NnFPrfyGgWVSEsp+lvKm8QomL4YmgH+hdS+HNCBf0HbyW
	XVvG1P/qebwNXtvAee+4WdLsMKQ0JZ48wHPjT39K0tGMLgaWaZfwV46PxKLfq32qI6QHKUl2JlX
	w8F2UOA/+fThijmSM+3AbVvnE4rYWYOUhXkUtu5Nr6nvXUB5gWRXYFx2ItcSquZSJGQ==
X-Received: by 2002:a50:9167:: with SMTP id f36mr101213410eda.297.1564487920111;
        Tue, 30 Jul 2019 04:58:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEDax+aPbkYEpzDTyskHns++rbEie5tzGVOthviLkxNQU8mUbOr7WIPq9/s8WVjpqpZtIT
X-Received: by 2002:a50:9167:: with SMTP id f36mr101213354eda.297.1564487919080;
        Tue, 30 Jul 2019 04:58:39 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564487919; cv=pass;
        d=google.com; s=arc-20160816;
        b=MeNx89RZipmnN6d5FdKs9+S+W2ahXA1BsEyILNYjE4L6DHNFxDfKH0ISW4D2Kkrvs5
         mkVTzB30Sg/FabtsCmilDjNnWIKr4TAR2Gw2pVwQQ24dSVAi/l5yxKZ1tB+i22Qmj3WV
         zxu5G6PPHBuOm9q9Q5bKSG819j7FmB3w7UThTcgnCGEPhjmTuHGwWni0zEumwE2PRyNa
         tjh8Xc9jYXfdP4mK5I7NGfYtF6QwTQW65P73Ncf+FxjLJsyYebhMqqmN5u+AUya3ydHR
         c0PZ8AQ5kecmMWPqb4qnuyAKT+hUuvcdTcRM+Xsl91mptqay/LmwwwHHX4VwseQw2UwU
         IO2g==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:message-id:date
         :thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=+33JPkMeNqyLpIkArR+07OT/1Uc18dPOVsUqjAcecF0=;
        b=l3dV6DwsQNzVixBTkPT5s4NlgFpI9rdQxWSaNrWYlu2SMYU3NRs4ey/wojiyrPhQS+
         Fg1TAF427+XB/VgC8C7BmNvkXBRP+1YVL7OEdDcRM/4UMRv6MW+bPnltKitoFuSsgSyG
         wtzTswjm9Q/uAz7tYJHc8QHxYBwfP/YU75s4BcWjy8cGuzRtqKbucBTNY+ywW/DWseQl
         vStN+d08O8ZGIqvOI6kIS0w+A8ED7Xi85auKASqzI7qw26xT+YzZM0czIngDhxLDSN+9
         VlQX6YfgHZFGkCmsa0HriA3OU4eQvmVXN7zY9WNq0KP1ylyw1mFOVNrpfN/1sIjwFwZP
         yFmg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=pTAUOFHF;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00085.outbound.protection.outlook.com. [40.107.0.85])
        by mx.google.com with ESMTPS id s41si8564691eda.207.2019.07.30.04.58.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 04:58:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.0.85 as permitted sender) client-ip=40.107.0.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=pTAUOFHF;
       arc=pass (i=1 spf=pass spfdomain=mellanox.com dkim=pass dkdomain=mellanox.com dmarc=pass fromdomain=mellanox.com);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.0.85 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Uc8o/Yooyf+Fy5LKnRl1Q0XcxHidnxtz+lMj2KtHxnjqhVsUr95WcbfWNVwhqnJf79bfhWflXFWoL8XG7qXJFtMuJ67f6mRH4gynMI6pbd2yMI+3kfqoLEJGRdgWffFsDRgK1Uzue56PoCOHq8EK3G+VYJyVOXTf/SmxvWJdLybhWQIO5gYCwwT8LKjbEIrKyqn87++TjyzkwFbaL3jJK3PeprU5YxSOqNqvGm01F3Z8LpudxrbHJA54pkSyIQ3T1O40adB0DhnKgfL+/R1n5DkUt/WsrjmN9n/iaGZiHpdmZ6kq9KN29PMEfY2qd9srciO+LYFnOjfw/bWg66Sr8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+33JPkMeNqyLpIkArR+07OT/1Uc18dPOVsUqjAcecF0=;
 b=iGk7bvIkg/GNugY0L0VxDrVeuuAamrfuGgpnx0hvCiMUdsWStVYn7Pwy+3jd3G3mep0LnT1Qaz6y0YsCKGR3LBe9+c6PNHOZKjdShaidgDXsIgPGFlYOM2JYmdN+epxZe7V+YWyeA2wbIl52BR06T7rOPktUQZsS+wIEJuP5UZb+rD9BmyS2uL3+1F+OnGNMMS1cQ5569/DBlInyxqYAtNn+QR9tM2na/O/ymR+oOkSllxoLI55iJdZFO2eCF4HSuSjlqkwVl+cRz/BwG9YR0waPI4J+jBWtLTHcvTSRl7OG1mRsm/vc3gBsZpYb6QeFCXa5jlzhxIqMxcXuXuW+6A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=mellanox.com;dmarc=pass action=none
 header.from=mellanox.com;dkim=pass header.d=mellanox.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+33JPkMeNqyLpIkArR+07OT/1Uc18dPOVsUqjAcecF0=;
 b=pTAUOFHFWfescS2ALdSMnHR93xaow9VsWlzsAk8JjASyGaYs4pWcwCVu6CuTbDVgQfBSypFOugHWALdYbxjv7Vxd/pSUo6emmDdLH8+vBD/Su7SlYf/6FeOJQ8mjNbb6PbQ5Qt+xmsYlY/wjA4Pewlm5aTiJo45RVexpLp6yyNo=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6063.eurprd05.prod.outlook.com (20.178.204.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Tue, 30 Jul 2019 11:58:37 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::5c6f:6120:45cd:2880%4]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 11:58:37 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton
	<akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@lst.de>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, "Kuehling,
 Felix" <Felix.Kuehling@amd.com>, "Deucher, Alexander"
	<Alexander.Deucher@amd.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull hmm changes
Thread-Topic: [GIT PULL] Please pull hmm changes
Thread-Index: AQHVRs4epyeD1jwmWUi/iXXZo7asug==
Date: Tue, 30 Jul 2019 11:58:37 +0000
Message-ID: <20190730115831.GA15720@ziepe.ca>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator:
x-clientproxiedby: YQXPR01CA0104.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:41::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b6f9997d-b133-407b-5779-08d714e5413a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(49563074)(7193020);SRVR:VI1PR05MB6063;
x-ms-traffictypediagnostic: VI1PR05MB6063:
x-microsoft-antispam-prvs:
 <VI1PR05MB6063117D58AB82D9BBD5CD20CFDC0@VI1PR05MB6063.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3173;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(136003)(376002)(366004)(396003)(39860400002)(199004)(189003)(66446008)(99286004)(4326008)(54906003)(8936002)(53936002)(33656002)(68736007)(81156014)(81166006)(2906002)(316002)(486006)(66066001)(110136005)(99936001)(186003)(386003)(6506007)(102836004)(71200400001)(71190400001)(26005)(8676002)(476003)(52116002)(7416002)(478600001)(256004)(14454004)(305945005)(6512007)(6486002)(14444005)(7736002)(36756003)(6436002)(9686003)(1076003)(25786009)(5660300002)(66946007)(6116002)(66476007)(66616009)(86362001)(66556008)(64756008)(3846002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6063;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 5lwbL/YVtpY1+D5llxcTNXTbawvmeQQKNRaFB7wOLtBFTVGXipPPkgJryzHiWHG/XZWScZv9oJYdOB3qYtDOHbWHDqRo8PWrd3Ev498c5T2DQEBKlamgQpSB905/FbcjUoj49aH/xVj5DrtIGh3ljuSdo8DIywKp+wn2saqRHoQOn3Qm847USGFdAZC+mQw9wbx+VQyKQQOo11AgcqeNaLt4C6EiYyHHM9zM4N0LOoMC5i6XUC8f5bo4nWiCchaoqkJz0b32ALq51NclJz1zWpgqdGSqgb6a386gTi8WHJF9u5KFzHdOkr439yGB7m5x5LvKlZL4doaItYPvle6GOAtpKoonSl3I23Tg7RwKSOxs8bXkieWDWyJiPdNFtoDdPlXkkOaxFJm3bRcce9f4aoKoYtiH8U14x2yZfwDBxfE=
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="pWyiEgJYm5f9v55/"
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: b6f9997d-b133-407b-5779-08d714e5413a
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 11:58:37.2602
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--pWyiEgJYm5f9v55/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Linus,

Locking fix for nouveau's use of HMM

This small series was posted by Christoph before the merge window, but didn't
make it in time for the PR. It fixes various locking errors in the nouveau
driver's use of the hmm_range_* functions.

The diffstat is a bit big as Christoph did a comprehensive job to move the
obsolete API from the core header and into the driver before fixing its flow,
but the risk of regression from this code motion is low.

I don't intend to often send -rc patches for hmm, but this is entangled with
other changes already, so it is simpler to keep it on the hmm git branch.

Thanks,
Jason

The following changes since commit 5f9e832c137075045d15cd6899ab0505cfb2ca4b:

  Linus 5.3-rc1 (2019-07-21 14:05:38 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git tags/for-linus-hmm

for you to fetch changes up to de4ee728465f7c0c29241550e083139b2ce9159c:

  nouveau: unlock mmap_sem on all errors from nouveau_range_fault (2019-07-25 16:14:40 -0300)

----------------------------------------------------------------
HMM patches for 5.3-rc

Fix the locking around nouveau's use of the hmm_range_* APIs. It works
correctly in the success case, but many of the the edge cases have missing
unlocks or double unlocks.

----------------------------------------------------------------
Christoph Hellwig (4):
      mm/hmm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
      mm/hmm: move hmm_vma_range_done and hmm_vma_fault to nouveau
      nouveau: remove the block parameter to nouveau_range_fault
      nouveau: unlock mmap_sem on all errors from nouveau_range_fault

 Documentation/vm/hmm.rst              |  2 +-
 drivers/gpu/drm/nouveau/nouveau_svm.c | 47 ++++++++++++++++++++++++++++--
 include/linux/hmm.h                   | 54 -----------------------------------
 mm/hmm.c                              | 10 +++----
 4 files changed, 49 insertions(+), 64 deletions(-)

--pWyiEgJYm5f9v55/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEfB7FMLh+8QxL+6i3OG33FX4gmxoFAl1AMOIACgkQOG33FX4g
mxoQ2g//RnLjfumNrH3tMwS8UkYgAoWVh6NGyQ7EjUPT2fvHlfo3dMqzUNK9h+wN
k2MKDTSZbFVhJQ5scU9KbhzGBXih4+DLnW1bpN1k/6nfZ6EXxRJakmcEz+LE53Pn
ylcuBXU9SLf733j+uwy42BQhkL7/Ykk+vt/aToWEyuTIXsR7zkTPVd7XH4JcHKi6
Lsf+zGtBCsIsh27T7uyyyOI52XwcY8Zm6LvfIKdOLczPRB8SzQ3yyMHjG42L7/ui
VGDvoU+4pMGQmBg2anE49/xsxDrGWeVYgkcsQcw2PhlthXw3VwmWBj83chLU9+qt
Vc1jofLj4Srgv+mXgFjmu0j1yJ84qoJaBb1YPzxDWoJGHpXyhLWKc7U55lvvotDD
EJCOV6nE+VMGo/Zu96O+LI4IW05afPxJstNj3XQg72lF4WaRGOS8q3OhmGqntaNh
ajQNYrcUDODmwepiOpDPf28K2cybwdINqrNKFw2e9eybnBxE4VEoF5vjUIlQmYoj
BNZAORxOyrnNHr8w3q46pK5OPinjXhNnKXJFrcqldZKKonhRCTIb+vu22CLD0QCC
DjmflIaGbHx8Q8yB+9B5pFt3j/a9lMzYgfN61Kh1qCOAiDWDXBjJ/c/mA6++iwgL
08F+Xltp9NoE46VUbpij+5xq6eaXrHWb7v8QyRZJt04KHziebmM=
=6E82
-----END PGP SIGNATURE-----

--pWyiEgJYm5f9v55/--

