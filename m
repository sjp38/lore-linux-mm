Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B06EBC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7775D2133F
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:29:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="gFFEYLwE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7775D2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1617E8E0006; Thu, 27 Jun 2019 12:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1398F8E0002; Thu, 27 Jun 2019 12:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0006B8E0006; Thu, 27 Jun 2019 12:29:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8DA58E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:29:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f19so6318999edv.16
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Acwz3hHPfD+Le/jb5+cmcROosiINY+hQq7uRwwksQzk=;
        b=KtLmIF+le9p2NyuGkRBxHc2AD24LG/bT6ZTtGO9oIHQsYTB3c3Isoio2B+QYkALrWK
         UtT8onyrNQTG0weopzKQ9p/Kse7qY7yy0ys7b9NycTczeoEGnkypWiNOvdL013ncCi1N
         VTvb05Dq8YNPC3deWY/JPMfiU8HRHbLKV0hkM1vR/fVHPNgyaXTTiP2w/1d2cOLmjv3L
         gnYqN+yZ28HRpNTF6fmWECGr+0KXWdddsy7qx22+872ZSdUBPhyvKqhUJeUiCJmROQuZ
         kXiENSbgs0CbVD2cU2DieRv7+R0qukzn0AzFEmn6JoX0NjeSaM/FF7c9uvjhHHKZ/oDv
         pPNQ==
X-Gm-Message-State: APjAAAVLiw9QBbEp2CjWOvm9eMXTx8S7wCIgg/sAFHjSJEDbyuA5MOuk
	oRrUlvwawqGZ9rxjjY99qQElQ9TlVD6Ael7BF/jZodmrv28EnpP1gH3XD76Z9I5YweUjLA/cWSM
	Y5kXbW8kVWZIKxa/L7JP2KhVIjsaFOBi4pZgp7GUwYqmHXR6TDwK2nCO6x/QwzFPayw==
X-Received: by 2002:a50:ec03:: with SMTP id g3mr5388218edr.233.1561652987280;
        Thu, 27 Jun 2019 09:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiWrM0TgK45T17ozTbiJqUqph/Dqyr6lsb4hi6s1dAvJSp+QgW5p7wep0ftMwen5Mc8NL0
X-Received: by 2002:a50:ec03:: with SMTP id g3mr5388165edr.233.1561652986680;
        Thu, 27 Jun 2019 09:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561652986; cv=none;
        d=google.com; s=arc-20160816;
        b=jGNBbxyI/3Ax2iURYSC2SgF2pdyLhh+DhDLkSOdbAQ9TCoXMyDhAB0gS0VQ4JV8mbo
         dti9ESrXdSRnzqKcdE08cdNT12jPx9M9Q6FYg0iu4tXVk09VxFlMOvKLgQjUtyY9Xkz/
         l/9qf7QrrleaLo5v8QPa6RSnPMf46Yk0M5il3oKfKbiL2xuO+8vnRqloH/mi4xscYJza
         6essEahFUM4LY52YKoXP3kC1Q2iFpmW2Q+hqqZalp7nrlNbcDi3Bo0zmQvryV8p4xTB5
         cAbNWmpGpSrMAv8dccx4PXHo3r2TD1Wh5AdQpK6fanHvD1tHeWNC1DGba48Vi/i7aGN/
         0gTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Acwz3hHPfD+Le/jb5+cmcROosiINY+hQq7uRwwksQzk=;
        b=MMR0gry9oe+Mi3Hlxc3zIrtf5zxwMB1n4yWq+GzqcN5xeUgKnAH/g8NZA3/ECf3KH5
         TAgO5zscx8HajeDC2mTSHw/MdHwqOejZdBbEL56bzz/itrjqksffglw279mKvMv/mwnn
         YFFApa2iVk7RUG1Z7SqJRVLkueC4WnYETUyELZRTDSRR8ZWbgtbmmaCzLwWzsOkIHdDr
         DPX6yWEobRaOxiK0R9xj2mkAIhAQzYHoGzz4G4m6C2UlzRahbcf0/Z2Wu7NwLsWBwhDM
         18BWKnllTRDae5Wbyl8u6vFH1jGnxd2b5eytjkQAV9WlLKPz/HnowwQCeAU8OdCtZKf9
         Twyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=gFFEYLwE;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.62 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40062.outbound.protection.outlook.com. [40.107.4.62])
        by mx.google.com with ESMTPS id z9si2370025edz.403.2019.06.27.09.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jun 2019 09:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.62 as permitted sender) client-ip=40.107.4.62;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=gFFEYLwE;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.62 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Acwz3hHPfD+Le/jb5+cmcROosiINY+hQq7uRwwksQzk=;
 b=gFFEYLwEZzcaYgGPwF102oxi9KMrRut1jd93LscZWuscZkJ7vz97pan3/8x2vEXXJM9WtbJlA14NR8UcJbAkHW9w3JeIedSKTFFPtORHMOvOGhoGZb7RAvRv/Y5BxudV1nlvg+ILuTvFuVVL0MF4CwUE0spAe6YVXUlUxB7bc6I=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6032.eurprd05.prod.outlook.com (20.178.127.217) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 16:29:45 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Thu, 27 Jun 2019
 16:29:45 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralph Campbell
	<rcampbell@nvidia.com>
Subject: Re: [PATCH 12/25] memremap: add a migrate_to_ram method to struct
 dev_pagemap_ops
Thread-Topic: [PATCH 12/25] memremap: add a migrate_to_ram method to struct
 dev_pagemap_ops
Thread-Index: AQHVLBqZBQCOhXKkekmD+Za0eny3n6avsW2A
Date: Thu, 27 Jun 2019 16:29:45 +0000
Message-ID: <20190627162439.GD9499@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-13-hch@lst.de>
In-Reply-To: <20190626122724.13313-13-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR03CA0020.namprd03.prod.outlook.com
 (2603:10b6:a02:a8::33) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.199.206.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 910ae93e-1c98-4933-e059-08d6fb1caa3b
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6032;
x-ms-traffictypediagnostic: VI1PR05MB6032:
x-microsoft-antispam-prvs:
 <VI1PR05MB60323BDF1EC27F3D38D0D595CFFD0@VI1PR05MB6032.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 008184426E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(346002)(39860400002)(376002)(136003)(199004)(189003)(6512007)(102836004)(5660300002)(7736002)(305945005)(6116002)(486006)(478600001)(476003)(81156014)(256004)(386003)(11346002)(53936002)(76176011)(3846002)(2616005)(52116002)(446003)(81166006)(6436002)(8936002)(68736007)(66066001)(6246003)(316002)(2906002)(54906003)(229853002)(99286004)(36756003)(6486002)(26005)(6506007)(186003)(64756008)(6916009)(8676002)(7416002)(66946007)(1076003)(66476007)(14454004)(4326008)(86362001)(66556008)(66446008)(73956011)(71190400001)(71200400001)(25786009)(33656002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6032;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 FQumiSKh7GVdRl14hBXAy3T/ENWqYM4HWMyt/KiMQB3yuvYG+MOIrLUCPq4S72Bqu5H/LaAUqWhI7Tr8MmgAWraK9rbKVPCD7phnzfo27BCXksIEnr+JiI8gC8Dkz4BoJWEulCIXVdw0MTHsUNYkf4YaA37Jj+hVFrb/3EAHXH56uihx5XRp67A0kIrQyIzowuvy9TMI00/W3AAZlgs8xR6rTn2nfawvNYsN6H0PQmYbU+RUQ2+60Uw5GlYfhzxUkZUBXL3GTMM2930c4vcFAHzQj/BOGwGVL7BXrCUqVPtvAy7rIu5zFs0PBD4C/zDx2ySDvoXcIZjXKZZtgXHwP25hvbKI4+zkbxKJn/yyiRnclDN67c5oFNBFejLblul4zRdK/fFAbZIVtSb6UpmyMqIdIxc06082NQNUV3bmkIg=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <D936285C7F16454CABEEFE9D1BD77309@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 910ae93e-1c98-4933-e059-08d6fb1caa3b
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 16:29:45.6208
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:11PM +0200, Christoph Hellwig wrote:
> This replaces the hacky ->fault callback, which is currently directly
> called from common code through a hmm specific data structure as an
> exercise in layering violations.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> ---
>  include/linux/hmm.h      |  6 ------
>  include/linux/memremap.h |  6 ++++++
>  include/linux/swapops.h  | 15 ---------------
>  kernel/memremap.c        | 35 ++++-------------------------------
>  mm/hmm.c                 | 13 +++++--------
>  mm/memory.c              |  9 ++-------
>  6 files changed, 17 insertions(+), 67 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
=20
I'ver heard there are some other use models for fault() here beyond
migrate to ram, but we can rename it if we ever see them.

> +static vm_fault_t hmm_devmem_migrate_to_ram(struct vm_fault *vmf)
>  {
> -	struct hmm_devmem *devmem =3D page->pgmap->data;
> +	struct hmm_devmem *devmem =3D vmf->page->pgmap->data;
> =20
> -	return devmem->ops->fault(devmem, vma, addr, page, flags, pmdp);
> +	return devmem->ops->fault(devmem, vmf->vma, vmf->address, vmf->page,
> +			vmf->flags, vmf->pmd);
>  }

Next cycle we should probably rename this fault to migrate_to_ram as
well and pass in the vmf..

Jason

