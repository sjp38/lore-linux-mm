Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42FCCC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:58:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2FC92133D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:58:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="NwrQy10/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2FC92133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8173D6B000A; Thu, 13 Jun 2019 15:58:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C9536B000C; Thu, 13 Jun 2019 15:58:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 690628E0001; Thu, 13 Jun 2019 15:58:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 158146B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:58:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l53so313261edc.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:58:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=D2htE/EYsrky4UH8MwG+WJWY3xDNbfvqPNXq0yl06kE=;
        b=Y5/Evyea0olr9P17WKdsxVANJWl+VSkBsDVOyTsOrBiPCSM7HWYRGBY4qHfypk3NvO
         5DlsWuIi5VpDEfcjlDvRaX7ObWAy5VG3JzVaiNdEXgWcRD2GQkk6X3Inv1ZK6dHCxcWQ
         2yTB9Erj4WdWDyUW7F5QE+CBbP4yeI+4lvF4ISFOU7r2UMUyKDRe060RtEXE97VsJAla
         J/0DJZeS303w8446WbrsXDBxMoqp+IGyA/+/4ufzIXRZaycVuy3zovjA302hPeGzysrs
         YZIypnI+N89pUJ2K1d52RIwR44e13eLGLYdsQva/CI0Cm/YZw+LJCAFRG8FqRQcpX+jR
         ZUuw==
X-Gm-Message-State: APjAAAWbOasS3XhiI0jJExfCzkqMGsuXryT4SlJbHGv3oCjOgNpDHELg
	dJsBH5JQZK4Ul1Djszg0Eaf5eLbUO2Mlr2NIqX7pkv2jBAUBNlqKbRTH1P6eZGhxcNjbhTI2FDi
	JXlINlGPeZO7oSi5kWEG2AVTi2LubaWbTlL0TMJ77VCSiMnmLdbOXOlQGilD1nAPxUQ==
X-Received: by 2002:a17:906:37c2:: with SMTP id o2mr49586750ejc.209.1560455912545;
        Thu, 13 Jun 2019 12:58:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvV75xocFYQ6oXDKz3MvzzVM7MMAPFdYwq72BBVwPIq2sq3b/aN9g0lLI54oixHZaWCRZu
X-Received: by 2002:a17:906:37c2:: with SMTP id o2mr49586711ejc.209.1560455911839;
        Thu, 13 Jun 2019 12:58:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560455911; cv=none;
        d=google.com; s=arc-20160816;
        b=UXAz7cN9nkK0lA1jZyGO/JzPsHcL4Iiu58ZFRawepfrukib+U03gvszU63LJXHcLya
         Z7KH6QRr7sBUR0yGbIGWOCU7E2AcTBcmqSRrmZf6uLZVbMF/XBaKlf5CN2aYGbNhIRib
         ixFPMOdGMNSm7ndXp80alYF0NkYHfDdoin04vRfuy6TLnTagBpOh/9SH35kuK/u/nv+a
         jaBZAawCVKSfld251i/5BUPKP8miTbc3lGmaXs73JtiGHjbBpDDTvK4/OA95mGwySBbd
         S1yIFAzRyDKVBxC9JFDFdiejh9lJLTJN/YIyj0ruMCYoGjwR5LDHV5iC91n/lWOHSgFo
         /tlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=D2htE/EYsrky4UH8MwG+WJWY3xDNbfvqPNXq0yl06kE=;
        b=mNvvnxPJpjJged3XhUT//6jxuzmXsBXJN8dijXR/IOM7XfjEovlw6FGIQojOEoKfTC
         bRKkSTphAg9+A3qI9uH5buO9SJrKyBzFHzTZ8gEUjtdQYJ03LZ059aozosfS/CdHwr9O
         qjf6ka2j8kwPGf6+iiTDTf8XJrgum9+DM86nMWfA6fHDpJ83FuKHlptdt0Fp+71nnTPf
         DuwgS/G/tyq6002LGzEBKHY1wPYArnzfBd/7PUMs8uhlmuRBSuLZJLSx7ViKXF8aLOQX
         haAGmrj7+QxxCXoluLHcs85Cv+jHFpsoGh+Oq14F8XMTX7IxG1ZJtld4ppRpIVGAwiew
         OM8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="NwrQy10/";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.63 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40063.outbound.protection.outlook.com. [40.107.4.63])
        by mx.google.com with ESMTPS id o26si374763edc.423.2019.06.13.12.58.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:58:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.4.63 as permitted sender) client-ip=40.107.4.63;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b="NwrQy10/";
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.4.63 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=D2htE/EYsrky4UH8MwG+WJWY3xDNbfvqPNXq0yl06kE=;
 b=NwrQy10/EB/7iKUzBwiP0xmPlH7ZtdAlNMflQH1hNbn4/r+oHD5CfsY9MXBj7FAnXVrVuSaY6GulI3Vah/8X2MrMbltvr3EEYzYKmGvnmP5JLdsfZXTlSxHbW/YL8LUsjhMibWBRxFD2oe6UOpY8Bog/vkEf6sFBQ0wUOe4qK6o=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6030.eurprd05.prod.outlook.com (20.178.127.208) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:58:29 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:58:29 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Topic: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Thread-Index: AQHVIcyVeqgMzBs0VkumwilsEzSkhqaZ/TwAgAACYgCAAAF6gA==
Date: Thu, 13 Jun 2019 19:58:29 +0000
Message-ID: <20190613195819.GA22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de> <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
In-Reply-To: <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: MN2PR05CA0003.namprd05.prod.outlook.com
 (2603:10b6:208:c0::16) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c5c3b5b4-9397-4985-fe76-08d6f039811e
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6030;
x-ms-traffictypediagnostic: VI1PR05MB6030:
x-microsoft-antispam-prvs:
 <VI1PR05MB60308FFB6145E73B56AB9897CFEF0@VI1PR05MB6030.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(136003)(346002)(396003)(39860400002)(189003)(199004)(76176011)(256004)(99286004)(3846002)(4326008)(68736007)(66556008)(73956011)(2906002)(66946007)(6246003)(66446008)(64756008)(386003)(6116002)(53546011)(6506007)(1076003)(52116002)(66476007)(86362001)(446003)(316002)(14454004)(6512007)(2616005)(53936002)(66066001)(81166006)(478600001)(7416002)(33656002)(8936002)(71200400001)(71190400001)(36756003)(11346002)(6916009)(476003)(8676002)(7736002)(102836004)(5660300002)(186003)(305945005)(26005)(54906003)(6486002)(6436002)(25786009)(229853002)(81156014)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6030;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 +rHR4yNz2DiEAD3ZeK5Nywni7ynWym3Tv9AxgXTqs7Di54gyzHpnC7Sn53lpHimljqLCvlTHL5Fm2/whl2TetvZ99ChjzU5mbuPPtL02FmKHU0zbx+B+i4VSgdXjvGlXUqLbyM9ksoeaCT4y33yEK7ojwFJrCQWUD5yA00jKpXGEaxzkkJfYcOvllHmFWMfbP97VK3sdwn5bJiA1Gi+5jjKe5YOB/LWKqIcalEy9+SrI1xvBifgZfk6LMrnkLUl/lTQch+pO3n7OU3C/W678nu4HzLwKoqMocAI1GDI49RnhIkfUskKgPu2eiPme7cdk44FpI1AqD6Gd8axVEOSp8Q/0BEPaBRrMkvpp+K5DHbQLwcnmK1Dank3QkGM0Ju/kXiG19aAalZiYdRGuEXKVftwFo07S6QPKvYhDO0klfyw=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <E2A7F637FAC6984B88734C89A688CD72@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c5c3b5b4-9397-4985-fe76-08d6f039811e
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:58:29.4725
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

On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
>=20
> On 6/13/19 12:44 PM, Jason Gunthorpe wrote:
> > On Thu, Jun 13, 2019 at 11:43:21AM +0200, Christoph Hellwig wrote:
> > > The code hasn't been used since it was added to the tree, and doesn't
> > > appear to actually be usable.  Mark it as BROKEN until either a user
> > > comes along or we finally give up on it.
> > >=20
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > >   mm/Kconfig | 1 +
> > >   1 file changed, 1 insertion(+)
> > >=20
> > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > index 0d2ba7e1f43e..406fa45e9ecc 100644
> > > +++ b/mm/Kconfig
> > > @@ -721,6 +721,7 @@ config DEVICE_PRIVATE
> > >   config DEVICE_PUBLIC
> > >   	bool "Addressable device memory (like GPU memory)"
> > >   	depends on ARCH_HAS_HMM
> > > +	depends on BROKEN
> > >   	select HMM
> > >   	select DEV_PAGEMAP_OPS
> >=20
> > This seems a bit harsh, we do have another kconfig that selects this
> > one today:
> >=20
> > config DRM_NOUVEAU_SVM
> >          bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) suppor=
t"
> >          depends on ARCH_HAS_HMM
> >          depends on DRM_NOUVEAU
> >          depends on STAGING
> >          select HMM_MIRROR
> >          select DEVICE_PRIVATE
> >          default n
> >          help
> >            Say Y here if you want to enable experimental support for
> >            Shared Virtual Memory (SVM).
> >=20
> > Maybe it should be depends on STAGING not broken?
> >=20
> > or maybe nouveau_svm doesn't actually need DEVICE_PRIVATE?
> >=20
> > Jason
>=20
> I think you are confusing DEVICE_PRIVATE for DEVICE_PUBLIC.
> DRM_NOUVEAU_SVM does use DEVICE_PRIVATE but not DEVICE_PUBLIC.

Indeed you are correct, never mind

Hum, so the only thing this config does is short circuit here:

static inline bool is_device_public_page(const struct page *page)
{
        return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
                IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
                is_zone_device_page(page) &&
                page->pgmap->type =3D=3D MEMORY_DEVICE_PUBLIC;
}

Which is called all over the place..=20

So, yes, we really don't want any distro or something to turn this on
until it has a use.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

