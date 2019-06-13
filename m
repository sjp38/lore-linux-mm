Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC9B8C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:37:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A51B920B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:37:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="Qt3C9kNs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A51B920B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A1A8E0002; Thu, 13 Jun 2019 15:37:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A3B88E0001; Thu, 13 Jun 2019 15:37:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 344548E0002; Thu, 13 Jun 2019 15:37:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D70798E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:37:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c27so231163edn.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:37:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=KqVMVbmuBMLCfrrJsLkvyOSYFtdu1jpJ2fCQlvBuFnA=;
        b=SjuYKjqWq/qsCvAdrt6m6nEuuJdqTKmrdCkKWWLHNHBuuAQjaonpnG8a+FGNgerq72
         DOe+h0V83uo/gsfBy2WFeCPJ68TnbY9SI2Mry0HnkrnhpM7Awq+QzLmt9M5o2w6SkLvI
         84U5luyhaI9vM+0hDsUfQltgtLbeHLXC2aMNCNIDJWODz/35tPectqsyatQ2n763jmYl
         sVWmFZbNcS6TCM0ekPmyjd73yYMD0I6iiJIBoMFDw5tqdfDw6pGIJB7OaEC28NQRoSqQ
         u/EZ5I16I5V0bsJH2NQYNOoxZXYbPU4xQhSzjJbmUiZCmPSs9dv7tBlIM7A0LvTbRSJr
         mSKg==
X-Gm-Message-State: APjAAAXNv3foGPTfq40r0s/29BS8gKQyw5KH58bl6X1Zz62A8tr6PEeU
	6z/2I/cCkEc2CEAxAKlmd6Uo9TIvpWnZBEplqTKoe3flALWYte74scrjJ4hXBF0VelngMLxvkhI
	5EfoYObwZxdTErmBZZQ4BC/fvCdjx+3OkvF9PFFkamIB5NRGpb37IXjnxu5DJSauvxw==
X-Received: by 2002:aa7:de06:: with SMTP id h6mr25958226edv.286.1560454650425;
        Thu, 13 Jun 2019 12:37:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwE2f+ohZHS5jV/SNsj7n5GRbRbwVcb3gzh4YxQ6cwJ635tpiaa+5LEcBIuqcgT7JeZaeSo
X-Received: by 2002:aa7:de06:: with SMTP id h6mr25958172edv.286.1560454649692;
        Thu, 13 Jun 2019 12:37:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560454649; cv=none;
        d=google.com; s=arc-20160816;
        b=aCNgE60QzbQ0TIfsBL5HWSi77KhfEfcDIGSSI36+LvqUVtyNOnkqG7LaCkpNSdYn7w
         EUbq8/q6aiPF65HGe2LNCVgJF1EVpAEIuyJqSjl97DibO5G3rmfeMB2RwddXoGrkr3He
         a3MgbJRdB318p+5525dxYv5SJa17/eVaylS7WOiHkD7EK7UQKbPB6wDHqxxmmd8EBvEg
         PDPIDXXcSBiT0YsqkkWknSbboGtvonPWQAzi64Nb65Jcy3MXNCwrQGZSU1GvoEEKJ2BV
         zUn9xOFHWc4Ukkdevrq9obKeDcwD/63g3rCOYbYkjrj3Z5IVduSN+kgPeCfpwd189hOO
         Kp6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=KqVMVbmuBMLCfrrJsLkvyOSYFtdu1jpJ2fCQlvBuFnA=;
        b=awW3kxf2lnnSqMDV0GPq6oHw6PkGX1yC0Un2jBmK8nQReWjcwcS+qjtDy2mGcayv3u
         m3S7WmvfR+sR5hqRaxFvwqMDgS78TDv8cuicoyvHKGrhpfnH2X99IG0vTEfs6Ss4ndDk
         vxotswbjVlNQX8SRHC74fMSbcAg3CDIhABuPFehqSJtFQ8bXiU/gqJeEPajoyq391BhX
         wBHicmBsIRc2EphKn8ChNZ02dN/xzrQiWlyEi1dDKCFl9dmbmZo2QBq+yseoMca6VVQn
         ieiiTfDQ2XDN664OtTeFoYDjWcF9RVMkzJzzII3JT0S51LJRSGsaySpMAceJHxzlC35s
         07Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Qt3C9kNs;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.79 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50079.outbound.protection.outlook.com. [40.107.5.79])
        by mx.google.com with ESMTPS id b38si376174edb.341.2019.06.13.12.37.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 12:37:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.79 as permitted sender) client-ip=40.107.5.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=Qt3C9kNs;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.79 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=KqVMVbmuBMLCfrrJsLkvyOSYFtdu1jpJ2fCQlvBuFnA=;
 b=Qt3C9kNsuyNWRihe9lrn0qa7iUaXO6uzsV2nd+cx8JBB3gZ8ywF0zBRH3FE4lXFypy0IjTL9mpTH1w68WFIFh+xz9C38mH757ZYFqq2/8D+NmDYALJr1cUVuFcAuMw385iVa4sGMFGLCpmliyoBT1GqpGsQQLsApOFG576vtKZc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4703.eurprd05.prod.outlook.com (20.176.4.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:37:28 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:37:28 +0000
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
Subject: Re: [PATCH 11/22] memremap: remove the data field in struct
 dev_pagemap
Thread-Topic: [PATCH 11/22] memremap: remove the data field in struct
 dev_pagemap
Thread-Index: AQHVIcyJQUnvCVRSIE2bb/Jw4XNupaaZ+z0A
Date: Thu, 13 Jun 2019 19:37:27 +0000
Message-ID: <20190613193722.GV22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-12-hch@lst.de>
In-Reply-To: <20190613094326.24093-12-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR0102CA0026.prod.exchangelabs.com
 (2603:10b6:207:18::39) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 907cdff8-e256-466c-f3e4-08d6f036912d
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4703;
x-ms-traffictypediagnostic: VI1PR05MB4703:
x-microsoft-antispam-prvs:
 <VI1PR05MB4703809C46130FB7F4861F17CFEF0@VI1PR05MB4703.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:281;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39860400002)(346002)(376002)(366004)(136003)(199004)(189003)(7736002)(81156014)(305945005)(8936002)(81166006)(478600001)(73956011)(6486002)(14454004)(86362001)(4744005)(4326008)(36756003)(6512007)(8676002)(33656002)(186003)(7416002)(5660300002)(1076003)(229853002)(99286004)(52116002)(386003)(76176011)(316002)(256004)(25786009)(2616005)(71190400001)(11346002)(476003)(26005)(446003)(68736007)(71200400001)(6436002)(66446008)(54906003)(66476007)(64756008)(486006)(66556008)(3846002)(53936002)(6116002)(66946007)(66066001)(6246003)(102836004)(6916009)(2906002)(6506007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4703;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Z4vP3UlC5xby6GoAzbIvFJnRyDvBvzto7/5u8I8QrQHRW7bdV+01Dd935kVu3GmRGelDhVwrMBg70UAGFS/gR5pOQFYjBuVg9zORQBnONNsY5Ed64myCE/K4zNNawxbPXaoR83hcA/qd5GfI/ddoc2pF66qJuOjG51b4kBZFlZxgM5Odjo6ThEfmyeJ3+cmXbeinYqi9sdVyHzfCSx2aESLdIhexmxRamCfh7QcCxb+5B99JEQ3uCfpuTFKJrX198C1qPTGkNdE41GmkK64PzqyRkbEDkQWbkEgIOdsT+EjY2wBdKBmM5u0MpztvNnpX0Ge2f1QdgEihksR3fcM2GkiTWOXSACyconHTTioeGVBx2vbReMo+Tarxm8YqRkbspisO33CqZRHJ9DW2ZYDScE4OFCrtlfnbbqtKm7AAg9M=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <9EE56540715B244EBE0C89B76768CFAF@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 907cdff8-e256-466c-f3e4-08d6f036912d
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:37:27.9159
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4703
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:14AM +0200, Christoph Hellwig wrote:
> struct dev_pagemap is always embedded into a containing structure, so
> there is no need to an additional private data field.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/nvdimm/pmem.c    | 2 +-
>  include/linux/memremap.h | 3 +--
>  kernel/memremap.c        | 2 +-
>  mm/hmm.c                 | 9 +++++----
>  4 files changed, 8 insertions(+), 8 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

