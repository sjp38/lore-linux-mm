Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71258C468BD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:50:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BB7121537
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 11:50:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="qo1Xa4Sb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BB7121537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91D756B026D; Sat,  8 Jun 2019 07:50:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CE366B026F; Sat,  8 Jun 2019 07:50:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7958F6B0271; Sat,  8 Jun 2019 07:50:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27A5D6B026D
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 07:50:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y22so6667946eds.14
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 04:50:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=/FIZowsz6D/XhCq6y6QUaZfZqiox1Wi8qIhgTH/IWz8=;
        b=do7FIrbYgnYneQIuis6R9dzttZ32cJOb1I2zOoCk8OSjOUtbluiGQYGUfzdd2udD8Z
         ZrEjYamHsIukT4Jrkf9Oa0Vt/msT6MtHB2+dsz5swoOf/Tzo/iqYlVK7ryTcZCrIaRa1
         WIDz9G97IPtPgiNal874cviQKoZDRX044P6i1vkWcgXpEHNB7F1rx3NCfMyj+I+uhGxa
         ndoYv0El5P/Ch7ksfvzDlba3TkJVBXHyKWf40U2FVACo1Mu7zUEYghPAQXt0RFUiRlbH
         a/vSdLSlPQtdZ+eXX1AgBydyJVPEj73sDXQ7PvXEjhWTbLIzTpiizjCqd/u07sN9+WGc
         k6hg==
X-Gm-Message-State: APjAAAXCckEDHouhn4wJd092IwGei0/tf7fqLqG2xlKOrf5yb9A7v7z4
	ahovI+VSdRIsWJudjoK/WoH2qY5gvfwmZYF5ryOi/MJ8cAzcrqufx6gXbkvlUwsMsMi7+4rqLCU
	P8W09fPBNOmo1vlapXJhzZjxXo40dAVPbDTlZtddV2IhZia1tGG2UekMlCO/y6hX3hg==
X-Received: by 2002:a50:9762:: with SMTP id d31mr24433386edb.114.1559994620669;
        Sat, 08 Jun 2019 04:50:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEK8vQnfLNt+qAc4LN8vKGsi5UKC7u5UcAc80vlbPvfCeVcCxdjzIyY8m3ZBrUbZsu27TT
X-Received: by 2002:a50:9762:: with SMTP id d31mr24433359edb.114.1559994620080;
        Sat, 08 Jun 2019 04:50:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559994620; cv=none;
        d=google.com; s=arc-20160816;
        b=AKdxLYFeo3Xg726bzFMMYMh3cSAkJ+EiS3oWU6XYiGLszgbDu3xj2m9/f1fvxa5bjL
         8Xa7pCh20FhngYC4l41B7vdFkoIDx8oTmDFTl8kbke5VtITuO0M5VTBN0+uPAHfo67CU
         Qa+4nSU0duNjlRNEdIkEkpbGdkcCoxNUJ6BMYvpzZ3xZ6OnGaqPZBe/aT3IphcPlVqwu
         vuvCZxHmOgSAHqQphQ5sZi5KKSWQbTrZJQ1rf6vTTfBzrHmN91plA5erHKehR9f4g8fb
         QrxOa92DLrsM17GoLnw7oRMeB14ApALL6bLa0sdtXS+lKAYPGr9H7JkkFexYBgU6F6XF
         4BNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=/FIZowsz6D/XhCq6y6QUaZfZqiox1Wi8qIhgTH/IWz8=;
        b=HAHlD9TzEGCgAWtLP7kAe/dGHTUYEzGcNP3NljZuzHQdhBGqUmOkQ8mgpwG0YJAVXf
         V9gAM7nj+/lxilljpOW5UefFPY5j59bXDLY8FPqjamhYKs80zVFOcvhGeUnO66igMGDW
         w//ivjEvUygFhraQ6mIS+mAQBOTcpHCk1mGd03Kb97Ay5sUXSazhotj8nkbeGhvHuJ0d
         budTiKYMCBHNkpBdktr9Hg8MECrvuoh0RdewRv6oGFgEKpVDTDgH/Hm+87Krx3bh9X6U
         Wrq9yhiU5SXDAu2iGl01JSLo3YO/j/hzLuE5h8rr4hpWhMFxUuCvsEbhAQLFDo7xz7qS
         O1Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qo1Xa4Sb;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130040.outbound.protection.outlook.com. [40.107.13.40])
        by mx.google.com with ESMTPS id e4si2863977ejj.37.2019.06.08.04.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 08 Jun 2019 04:50:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.13.40 as permitted sender) client-ip=40.107.13.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=qo1Xa4Sb;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.40 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/FIZowsz6D/XhCq6y6QUaZfZqiox1Wi8qIhgTH/IWz8=;
 b=qo1Xa4SbtqdIDnb8uGBzY0sK3lMcd8McYgqlAZyQLVmp3wEaURKAxgatSJ3ScriFrwwV1WxLdUaoHMN8BJ/NaHGi+VTTWxrfW99yyNc6H0zh94KTVnqo9cvQ4Jp6JK8vNc3OIskl5hx5cFrz/Kd0zwZ0qfW33j1bo2fNvByFL4o=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4640.eurprd05.prod.outlook.com (20.176.3.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.12; Sat, 8 Jun 2019 11:50:16 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1965.017; Sat, 8 Jun 2019
 11:50:16 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Topic: [RFC] mm/hmm: pass mmu_notifier_range to
 sync_cpu_device_pagetables
Thread-Index: AQHVHY87cnj6rYaF00uB6DOqwK5J5aaRpYiA
Date: Sat, 8 Jun 2019 11:50:16 +0000
Message-ID: <20190608115011.GB14873@mellanox.com>
References: <20190608001452.7922-1-rcampbell@nvidia.com>
In-Reply-To: <20190608001452.7922-1-rcampbell@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR05CA0031.namprd05.prod.outlook.com
 (2603:10b6:208:c0::44) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: edc48025-f763-4577-de12-08d6ec07794d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4640;
x-ms-traffictypediagnostic: VI1PR05MB4640:
x-microsoft-antispam-prvs:
 <VI1PR05MB4640E6E5C556BD7AC7C67023CF110@VI1PR05MB4640.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0062BDD52C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(346002)(396003)(136003)(39850400004)(189003)(199004)(54906003)(8936002)(14444005)(256004)(4326008)(81166006)(33656002)(81156014)(8676002)(66476007)(66556008)(64756008)(66446008)(66946007)(14454004)(53936002)(478600001)(73956011)(68736007)(71190400001)(71200400001)(305945005)(1076003)(5660300002)(7736002)(6246003)(6916009)(6486002)(26005)(102836004)(86362001)(6506007)(486006)(386003)(6436002)(476003)(66066001)(2906002)(76176011)(6116002)(316002)(36756003)(446003)(3846002)(2616005)(186003)(99286004)(25786009)(6512007)(11346002)(52116002)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4640;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 +VwPesywDgHRN0jdIeuczqBIXBOd/OVuRFCqrqEpoCSMFT+51CERrYGw/Z9+8904LsVFQ8qZXMju0Ks+gcnYjDu6YtXebt8hfL44RSKkP/BZvaFUxq2E2EhHz5pVmYjk4SSGNhBEXw+cJJa6N9C9hLYmlgTsPN7outySzS3RvouRPaB1H3XhV5Z6ssO3Cqx+ips+EVtP+ha86ldjHbpVojFMWlelATanBNEN40qPWivu34aCYmgHNbH141IlOciv5Z78ek6HIABubWiNN618yhnb5rbcK4BtT+KXak7+l6ogfjLCWWoVanrU8UHa6n9sG0XLqN/R0ZdYIULjZv55qJ7ShLucOn73fqSb0ZqBJr8ZCB2c4ZHbHp+whIDa7TTolGX0CJ0UjZIqmf138994PeTmJOUR8hYzB08wkmvSJSk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FFF05C274A0A8E44B62AD3BAF4C55A80@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: edc48025-f763-4577-de12-08d6ec07794d
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Jun 2019 11:50:16.6934
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4640
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 05:14:52PM -0700, Ralph Campbell wrote:
> HMM defines its own struct hmm_update which is passed to the
> sync_cpu_device_pagetables() callback function. This is
> sufficient when the only action is to invalidate. However,
> a device may want to know the reason for the invalidation and
> be able to see the new permissions on a range, update device access
> rights or range statistics. Since sync_cpu_device_pagetables()
> can be called from try_to_unmap(), the mmap_sem may not be held
> and find_vma() is not safe to be called.
> Pass the struct mmu_notifier_range to sync_cpu_device_pagetables()
> to allow the full invalidation information to be used.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
>=20
> I'm sending this out now since we are updating many of the HMM APIs
> and I think it will be useful.

I agree with CH that struct hmm_update seems particularly pointless
and we really should just use mmu_notifier_range directly.

We need to find out from the DRM folks if we can merge this kind of
stuff through hmm.git and then resolve any conflicts that might arise
in DRM tree or in nouveau tree?

But I would like to see this patch go in this cycle, thanks

Jason

