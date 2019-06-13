Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FD0FC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:26:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36DBA2147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:26:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="HQ6f8qD3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36DBA2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C769E8E0002; Thu, 13 Jun 2019 15:26:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C25CC8E0001; Thu, 13 Jun 2019 15:26:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AED158E0002; Thu, 13 Jun 2019 15:26:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 60EEB8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:26:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n49so175321edd.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:26:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=QvcAsIkjFLYSdUniTF8G+sYHGSU4mYolhzc6717/V8I=;
        b=XmjHXlWAs3Rf0D0smrFfYxjT59c0x1AcnuJqIWYWy4havuCyPln8ZrTe78TFi4CIB5
         SmZ2WqGxMcmsLRjKYYiumzWWGv7W5Y0iua83K9ikPOgFaCtOXCb7W9Bfy5/Asko3x/ag
         PPgGd6Q0b+44ndXCQ24mwczgKXRHzZjgi9SOkWim1pEXsjJaUZ5NHKDLOcWQrwKEexVK
         wneDtU/uS+HFO91VrOslZY/4q1D4cOa4fwxwpyhSXS5hblYe8GRYwaRz+6OX2fmrUWAa
         JmdxsacnY0zUAeSMHaP3RqAWg3e2UujdWl70jvr062gRMYQPdURIn2XgsJ7+dd1LYzmi
         P54A==
X-Gm-Message-State: APjAAAU2KQsynx4+0q95nC43mVB3SxI+5GOYV8S9/rrsfzNPtOYKXz+T
	oUterSYehrSS+vDzuQk1UrU8PZ8NNMFAm2snXeMt9QoWlIMqr2VdUUiNN+fRDK4FMtBPqcl7o+b
	fx6gP2ckw6Dfh2YBcCOUINEPZx5sWOhsl4vm3i+RmnKD7Yu5y2iiYrLkWbWqnUMEC1g==
X-Received: by 2002:a50:ac68:: with SMTP id w37mr16435638edc.10.1560453982971;
        Thu, 13 Jun 2019 12:26:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoFIc6ic6QlRPdNdkfRG/2QG0pPlxlRSogfALtDLo8M/k6WQQiFBPOtg5etZBM/Xu0Tlt1
X-Received: by 2002:a50:ac68:: with SMTP id w37mr16435590edc.10.1560453982308;
        Thu, 13 Jun 2019 12:26:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560453982; cv=none;
        d=google.com; s=arc-20160816;
        b=wJbHKTi2QTOeV/LGo35rwgQxfPtR5RyGoWvjP2LFGfbZlW1Fv3xx7/Ya6SJphwCpAy
         BhjJtPvkZPPdF5Cdd9aAHMSyI3W9zQptEO3dI+/bLp4EUvXReUV31DxJrswe2bsCPHsi
         XyljMNwGZc6t7Oymn7PS6xQca+Cm741XG9Y9dlkqvHsO0ukMwmEysxSpPO2icI9rzYMO
         E3Je2e0yDwzcdXzp0cKAG+OLDA1TjamMV991WfC493i2q7jJZIY6MAQKGcdDWN9sZMoe
         JgjrN5c+R/y7YlxS04n4AO1icouYs0g99tjoxfE6Bi4LLh8QFgqIy9+H+QXsBYLzoTvM
         lBfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=QvcAsIkjFLYSdUniTF8G+sYHGSU4mYolhzc6717/V8I=;
        b=F3zfOi2kOufOkxMRNJfFkRQFuWCGgxgtInCSL6E1/chPOooPkigQSyfpdmAITNSIbf
         iRRoskeHTekkRcoVb8Y93JNM0BscdtfSeHOUyJHxAnwavP1iZnp/yfFf5e1RcqVa6RUv
         2CdFF5GqGcUXIEdmxauV+t04E+kzilRPfD2euY1bBhZPjgp6eC/lRpipNbiCSflE3XNJ
         bDwIzulvvvqWO2yI3cjXuwGJHbaflKUTmlo8cvGGQawfWYqpIeCq+NVAYSz/Y8TtqGbt
         609dbhQ434BP7fHaaA31gDz95plXsfVFLi2gYnoCGDhaUp6CWL0CCKvH25JxPTKdw/Rc
         AdQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HQ6f8qD3;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10056.outbound.protection.outlook.com. [40.107.1.56])
        by mx.google.com with ESMTPS id n29si341916edd.66.2019.06.13.12.26.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:26:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) client-ip=40.107.1.56;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=HQ6f8qD3;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.1.56 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=QvcAsIkjFLYSdUniTF8G+sYHGSU4mYolhzc6717/V8I=;
 b=HQ6f8qD3M80i6/HWhY9aAYXl2Zuf5Hxud/tSbgQeMPzAhqLte+GlCLBqketRtxRq5Um5H3ru99Joy0pT/kkAwJFTTC2ebmEeU5e5uMysOHDNyNoBXZSVkynlsUhzU+wDJf4mwRpkcrFAMKYOJBOCQdEhGEWapvrkVzJsfQKdaDY=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6431.eurprd05.prod.outlook.com (20.179.27.213) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Thu, 13 Jun 2019 19:26:20 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:26:20 +0000
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
Subject: Re: [PATCH 08/22] memremap: pass a struct dev_pagemap to ->kill
Thread-Topic: [PATCH 08/22] memremap: pass a struct dev_pagemap to ->kill
Thread-Index: AQHVIcyEEZgvAYVgakq3PD/MH8+2iKaZ+CKA
Date: Thu, 13 Jun 2019 19:26:20 +0000
Message-ID: <20190613192615.GT22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-9-hch@lst.de>
In-Reply-To: <20190613094326.24093-9-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0016.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00::29) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 993f786f-02ab-43f7-4dfa-08d6f0350384
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6431;
x-ms-traffictypediagnostic: VI1PR05MB6431:
x-microsoft-antispam-prvs:
 <VI1PR05MB6431317ADECB4131223AC21ACFEF0@VI1PR05MB6431.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2449;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(376002)(346002)(39860400002)(396003)(199004)(189003)(71190400001)(186003)(36756003)(11346002)(446003)(71200400001)(14454004)(305945005)(66066001)(6506007)(478600001)(76176011)(53936002)(52116002)(316002)(386003)(81166006)(54906003)(476003)(99286004)(2616005)(102836004)(8936002)(486006)(3846002)(86362001)(6116002)(1076003)(8676002)(4326008)(81156014)(66556008)(7736002)(7416002)(66476007)(6916009)(25786009)(2906002)(66946007)(73956011)(66446008)(5660300002)(229853002)(6486002)(26005)(6246003)(64756008)(33656002)(256004)(68736007)(6512007)(6436002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6431;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 xj4tjUkJSgoEYdWtNIdYqjdPPITUyLgZz9xkAp/QkS61G+3Qf+HJ/Jkb8hN5iNZDWnMXTupMfMPR4xLNGIqxjsZyKdvb9PaAd8lC9boN2H6VLJVikbaPfzHZE7ChOpRSXlkl/TfKfdeWSefSIQi2BWYWpwPbM9pX+m6KdVKozPtEgm5JdtFoEBhEz4SEkH35vlX6U0wOtlkhjvbPZTQHwwOOI6f9FzSCFapImSn7CY3o5DUpcOZNpjqpSVVZg/D50/UtF2W83/nPM5ysLrbkEw6W+FYmqCXCTcPOflzM2QHEzakE0cQkHoVl1bQhJGfCVsHxvjppsHJb5nV14f8gNjVdy+pAjTgr2rGERzznu2IDeULyx0a9TlgIIDb7OJ/mZxCRJicaf5H55lWSyxZ8YtFkW6pOotTj2qhrffICwbw=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <6555DEAFF3F4AF4A941D63DB429D69BC@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 993f786f-02ab-43f7-4dfa-08d6f0350384
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:26:20.5397
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6431
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:11AM +0200, Christoph Hellwig wrote:
> Passing the actual typed structure leads to more understandable code
> vs the actual references.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/dax/device.c              | 7 +++----
>  drivers/nvdimm/pmem.c             | 6 +++---
>  drivers/pci/p2pdma.c              | 6 +++---
>  include/linux/memremap.h          | 2 +-
>  kernel/memremap.c                 | 4 ++--
>  mm/hmm.c                          | 4 ++--
>  tools/testing/nvdimm/test/iomap.c | 6 ++----
>  7 files changed, 16 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index 4adab774dade..e23fa1bd8c97 100644
> +++ b/drivers/dax/device.c
> @@ -37,13 +37,12 @@ static void dev_dax_percpu_exit(void *data)
>  	percpu_ref_exit(ref);
>  }
> =20
> -static void dev_dax_percpu_kill(struct percpu_ref *data)
> +static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
>  {

Looks like it was always like this, but I also can't see a reason to
use the percpu as a handle for a dev_pagemap callback.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

