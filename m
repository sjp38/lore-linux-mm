Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21CDAC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:55:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC27C2133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:55:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Jy1yI5/V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC27C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 693516B000A; Thu, 13 Jun 2019 15:55:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61D3B6B000C; Thu, 13 Jun 2019 15:55:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BF008E0001; Thu, 13 Jun 2019 15:55:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF0A26B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:55:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so280782edx.12
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:55:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=nEwJJyAiRP/kORjuK5/bDnzsGqocm4iUPsZxcYdbwzk=;
        b=dOZJGgyhYzyQ/n6W7PzLfABXoqDdH5yrsaHe/mwfkOw25YopwHai3sNoE71ToVqITb
         7yieouy3CQkS6dv14eGymH6kKTvOun3rruyNG5wnOo3DVTZQAb6wUz7rw3Q4F4qYgHyz
         7dbeptnfpr0k9ixf4WRGDF3+dTX/Z2eelpAB9mRf76q/9amQ0wNRhlqpBAEGaK37F3tx
         WRr2HQbpHL4CAQne5BUu0SXviS6Mz0XSrdYAyEdvtcOXfSkuprEJWUtV3sg2bGI39b1W
         Ify4O91u2ip+672OG2oiOTjK2hb5KOa/GatDT9HPPzUyWXG1xp94HYVOUsz5ZrXOBFy4
         nEKw==
X-Gm-Message-State: APjAAAU/cmergLbBjJa83weQcVgludC5bwp0r9G4NRLRLFVev444cVkw
	/eJ2tRcYHgbQFrigscAy5DzVgZM3zJ9ld/K+GqYyKAKnBf3prfStO2CBMsIeGd69RCpXOfvc3Es
	sS0IfCWGyRFWiuC2vHQdWgpF9AoYutJe7nZLGE9nJbSMjzacgSIyFLr3QWq+h+qUMSg==
X-Received: by 2002:a50:b66f:: with SMTP id c44mr30127571ede.171.1560455730531;
        Thu, 13 Jun 2019 12:55:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrIIZx68aFRy5aErXsqXRNn7LYx05/DW+QGA/ZeFMRY6y3dQhe/DIdKuAZPS0VcM95tfzy
X-Received: by 2002:a50:b66f:: with SMTP id c44mr30127500ede.171.1560455729723;
        Thu, 13 Jun 2019 12:55:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560455729; cv=none;
        d=google.com; s=arc-20160816;
        b=HcFsGjzatDpESrv+vI4LgDlFuRVNyzlTHy/QjKRaCTMTDCxynCXeLy1pFyoOeL814A
         ApY5quy9NwFpUgE26AWZ191Hh4TUgDQ6pJqZy4dDgTNuO9pKZ5L8lmjtOu3hnC47fyTi
         2em8lI2n1vuhpLUeh+YPHBjQ1YnaeKVF0/5solpPMgG9U0aqdmPAo7jx0MHO5GyG7sca
         bejxfWD95F3D1OHDdexvyM/0ixzqdRHSClU3mxTDnkR5lf954ujhnXw2qog5KNnPum8i
         11wSCR9LPP3CAbu5+aW7cO+ZUbUS0KnLDntFIxvy08SdvPsE6fLaGEA8UOFVAB2xNHD9
         3yyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=nEwJJyAiRP/kORjuK5/bDnzsGqocm4iUPsZxcYdbwzk=;
        b=XB3zbUci+uq0oMUKjbG/5ZuBUzHeSBzimzcLIbtNLcZuveXjs0zt7kf0XGl5mpiNh1
         hutaREFVTiVopOapXgKebkzcZ5KIODWohQcxxIbldaDM9AB272c0eZXx3N5oJxdnmJ4q
         KL0nVVR+Eat5LJJNsAf1xSdm0DzHbugFNnELJUddbrOkX1XNitLLGnat58Kk+EiYZ0OV
         qCZYpl3jXmC8f3epRefMAceQcnoE1NDmFRnC5FKa8In/8O2dVIC916lDoS9QgkyXk3UY
         b/+s9Kfy6Hbs3Ze1HavXPA/nZPi1GiRNU19tlds3+Yer1OUGAxrvSx2H2lhlvdbXswnE
         H0wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="Jy1yI5/V";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40082.outbound.protection.outlook.com. [40.107.4.82])
        by mx.google.com with ESMTPS id y27si399531edd.235.2019.06.13.12.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:55:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) client-ip=40.107.4.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="Jy1yI5/V";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.82 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nEwJJyAiRP/kORjuK5/bDnzsGqocm4iUPsZxcYdbwzk=;
 b=Jy1yI5/VKqd/VgdOmHrINnydsU/WCKDluPxkYA1Pz4noysXmRZKw3SBDPqzLK/yjwFybM9JGMxuWlsXvvtPro52Nns4TPcFNPIlc6XAW5nVbPvxGFz9fU3JFZ7ei9xPNVNSEbgsgZJkrkh2H6OChaMY3OIWUynUKKUpny8L6w4I=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6030.eurprd05.prod.outlook.com (20.178.127.208) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:55:27 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:55:27 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 20/22] mm: sort out the DEVICE_PRIVATE Kconfig mess
Thread-Topic: [PATCH 20/22] mm: sort out the DEVICE_PRIVATE Kconfig mess
Thread-Index: AQHVIcyZrF37VPU7NkqyJQqyYg9vCKaaAEUA
Date: Thu, 13 Jun 2019 19:55:27 +0000
Message-ID: <20190613195522.GZ22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-21-hch@lst.de>
In-Reply-To: <20190613094326.24093-21-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTOPR0101CA0044.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:14::21) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bd28a2a7-5003-4b8d-267b-08d6f03914bd
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6030;
x-ms-traffictypediagnostic: VI1PR05MB6030:
x-microsoft-antispam-prvs:
 <VI1PR05MB6030B13E365564B4E5481A54CFEF0@VI1PR05MB6030.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(136003)(346002)(396003)(39860400002)(189003)(199004)(76176011)(256004)(99286004)(3846002)(4326008)(68736007)(66556008)(73956011)(2906002)(66946007)(6246003)(66446008)(64756008)(386003)(6116002)(6506007)(1076003)(52116002)(66476007)(86362001)(446003)(316002)(14454004)(6512007)(2616005)(53936002)(66066001)(81166006)(478600001)(7416002)(33656002)(8936002)(71200400001)(71190400001)(36756003)(11346002)(6916009)(476003)(8676002)(7736002)(102836004)(5660300002)(186003)(305945005)(26005)(54906003)(6486002)(6436002)(25786009)(229853002)(81156014)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6030;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 oI2gqlYWTW8WwdfpP4D/HtS9tiaNqRomendZIt6T1TP2oZFYff5e2998HL5tpSaK7cNH6gZd4/lIxSd+EKK2fTKqWmwLTlJVdXcuBjcWTkTz9KEQskxp20EE9U0BRqDMR0FwZHhN62AgCAbdERMl1RU1ZOROE8LZpdIQtD1C6ZNaPFsGVelIaENnV6EnaR8Pf7SCavVu4AUI2+feMWh3iKfRw8Dg5MrUSc6gXz87xbseLSalBRKCpQ6ofubmbZblPq8kvFYrJrHnIkB9v1Z93u1EN/fsLZoFW4Mxh6sIushFOBVLUW80QyyZ3b7UkDAlytgtUU9BwBLMCeH2gvd5j0JvApf9927RIC8KbY+9mbyg6p8OhGfLoFDD7psiLq5klX259sKQdGTi6P2zyV3peyWyYcTPqly0XRmsXFoHZNc=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9319F5409ED4434CA9F8E3BAE5D597B1@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bd28a2a7-5003-4b8d-267b-08d6f03914bd
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:55:27.4904
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6030
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:23AM +0200, Christoph Hellwig wrote:
> The ZONE_DEVICE support doesn't depend on anything HMM related, just on
> various bits of arch support as indicated by the architecture.  Also
> don't select the option from nouveau as it isn't present in many setups,
> and depend on it instead.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/gpu/drm/nouveau/Kconfig | 2 +-
>  mm/Kconfig                      | 5 ++---
>  2 files changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kc=
onfig
> index dba2613f7180..6303d203ab1d 100644
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -85,10 +85,10 @@ config DRM_NOUVEAU_BACKLIGHT
>  config DRM_NOUVEAU_SVM
>  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
>  	depends on ARCH_HAS_HMM
> +	depends on DEVICE_PRIVATE
>  	depends on DRM_NOUVEAU
>  	depends on STAGING
>  	select HMM_MIRROR
> -	select DEVICE_PRIVATE
>  	default n
>  	help
>  	  Say Y here if you want to enable experimental support for

Ben, I heard you might have a patch like this in your tree, but I
don't think I could find your tree??=20

Do you have any nouveau/Kconfig patches that might conflict? Thanks

Does this fix the randconfigs failures that have been reported?

> diff --git a/mm/Kconfig b/mm/Kconfig
> index 406fa45e9ecc..4dbd718c8cf4 100644
> +++ b/mm/Kconfig
> @@ -677,13 +677,13 @@ config ARCH_HAS_HMM_MIRROR
> =20
>  config ARCH_HAS_HMM
>  	bool
> -	default y
>  	depends on (X86_64 || PPC64)
>  	depends on ZONE_DEVICE
>  	depends on MMU && 64BIT
>  	depends on MEMORY_HOTPLUG
>  	depends on MEMORY_HOTREMOVE
>  	depends on SPARSEMEM_VMEMMAP
> +	default y

What is the reason we have this ARCH thing anyhow? Does hmm have arch
dependencies someplace?

Thanks
Jason

