Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1931AC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:34:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C527A2147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="iUpnm6J9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C527A2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A6AD8E0002; Thu, 13 Jun 2019 15:34:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457AB8E0001; Thu, 13 Jun 2019 15:34:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31FB78E0002; Thu, 13 Jun 2019 15:34:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D985D8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:34:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i9so207068edr.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:34:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=EHKRMNw9g2ihF+kxFu2QxbCGLLD+Dv1zpejuy8kLLZA=;
        b=Dl5scojszOZrvDL2hiPB+u+wQv55KH6qMBzdM/LCdSferQ+MH6Gz1gFtN+r1v5YojM
         qITsTj9cAZtwmE8WZtKtoou12Oudf135BVHJHHNjlRUuv3FUuM3RgYmqEXT3ecIZquMM
         bOo6YM/ilXWXSNn/7+940KQdG7nv7+6x+Dx9APwAgZ3Uo1oXX9GWbu9q+n55Kc4XNszX
         877Li2dONbD1WURLgcOkLonWa10kg1cmT9Cv/3ji1p6wFG+E8obgOFQ0VXqCb4rn/W1L
         0ULQaAHYgiTxUji5i4SYttT7ufBHglM2fuTJVNx6mBbn13ZxjTWaNlHqJykjokbt246C
         ZOMg==
X-Gm-Message-State: APjAAAUjhPweC/6i/z+EdtD+GlvysjECI0YtgPYx6jdlfbnqLu458hnx
	xOheH+Wej58UdBcLRgIMrfM1XocLfaQJKA3iBxi+16LpgYM5nA4YOPkl7S+7dsifm+0G/7wX7Fu
	+OR0hxym+LYN6ppSBYgDlmu/GRlKF8orLvYmZK2dmpYevaWFbKXNm6PNEN8BfkcQ4mQ==
X-Received: by 2002:a17:906:3385:: with SMTP id v5mr77212451eja.301.1560454474453;
        Thu, 13 Jun 2019 12:34:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5zMdY9shsjM7gdDwOvqNFvQ1ecSZBs32RwNyYWAOpkh9KZTQCj16RsJJtXYba9jS9UtxX
X-Received: by 2002:a17:906:3385:: with SMTP id v5mr77212402eja.301.1560454473726;
        Thu, 13 Jun 2019 12:34:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560454473; cv=none;
        d=google.com; s=arc-20160816;
        b=eavTPEN6gaWyUFqJBTuRBqVSwIxORoaJMfYFAsXe7F+eIs2KeHKSZWWB2O4QSkDPUh
         +nKEmKhjNQsEIrUa/qnEkUAQEODDIJfZ08D9CU3Rz9qHG/sVNbRXq6TF8SPEvoTAvzo5
         F66kRfSquIxZkAFUyi/LW9BsWt63BxndqQJM4MGVC3UOgbEuQ8D1yrpWXlCk7d8ymHt1
         UfAt2ZLkvFgROCc6BQndvlbEuEKFnZvy/LYSaIB8rimVd6lOiOXonZsx0GbbktyWYQTk
         fPqecPj83Ggm44vgnFpmXYAFnP4FxnisUrs8xVN+NowtoSQTM/it7jThIAgERSutqB7a
         84BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=EHKRMNw9g2ihF+kxFu2QxbCGLLD+Dv1zpejuy8kLLZA=;
        b=tpMjzuIFw8ENa9rDG5IJaRL+Ow+I/Ag+oOSwMNdg+qIGBuoCQzKchZZs+uMIxeMISr
         RlI+p7xtP/jusZuoILzVHMoCMZ4OGL/YIeyjqCApqHl2YUatpvIn8Vm/BcIXfV0dQzHy
         +OFES9QMBTYpxjed24oIJIHvBi/ik463lbf1pnw9uPoUAPJBluSnCLlkhvIgUvEgbB2t
         a656gaFFRZ9EBP0G/7tOlF/jx+br5pmnCbJtKyXVwxpiSx0blBrwjRVOVY3ym0gzADtx
         QeOBaGOuO0k9DtG4jtoyt/OsHuVjdhY3v7S9dQEi0LU30pTJ/0O2f2HoSMxG0DxqsnEZ
         a6Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=iUpnm6J9;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.73 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50073.outbound.protection.outlook.com. [40.107.5.73])
        by mx.google.com with ESMTPS id b49si350418edb.204.2019.06.13.12.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Jun 2019 12:34:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.73 as permitted sender) client-ip=40.107.5.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=iUpnm6J9;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.73 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EHKRMNw9g2ihF+kxFu2QxbCGLLD+Dv1zpejuy8kLLZA=;
 b=iUpnm6J9uAc2yjehlZggxWFZYnKjETahRTv9czZSJmRWPzW0c51V9hOVdRyMTHee9htECLtgsjxbSbXXTMK9Qo8zztfp4DzvDNdvYkG9j5XEA3xndXD0rPc3xF4w+ErYDv17IJNFO1S+2JDvJIZa+4wCOKDxz2p2P1kLyObkgUk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4703.eurprd05.prod.outlook.com (20.176.4.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Thu, 13 Jun 2019 19:34:31 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:34:31 +0000
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
Subject: Re: [PATCH 09/22] memremap: lift the devmap_enable manipulation into
 devm_memremap_pages
Thread-Topic: [PATCH 09/22] memremap: lift the devmap_enable manipulation into
 devm_memremap_pages
Thread-Index: AQHVIcyGh+LZVhNi2EuUux9FsS41VqaZ+m2A
Date: Thu, 13 Jun 2019 19:34:31 +0000
Message-ID: <20190613193427.GU22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-10-hch@lst.de>
In-Reply-To: <20190613094326.24093-10-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BL0PR02CA0046.namprd02.prod.outlook.com
 (2603:10b6:207:3d::23) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2344bec2-d78c-4486-b0bc-08d6f0362814
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4703;
x-ms-traffictypediagnostic: VI1PR05MB4703:
x-microsoft-antispam-prvs:
 <VI1PR05MB4703615FBFE57552FC7A5F3ECFEF0@VI1PR05MB4703.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5236;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(979002)(136003)(366004)(376002)(346002)(39860400002)(396003)(189003)(199004)(43544003)(25786009)(71190400001)(2616005)(316002)(256004)(446003)(71200400001)(68736007)(476003)(11346002)(26005)(99286004)(76176011)(386003)(229853002)(52116002)(66066001)(6116002)(53936002)(3846002)(66946007)(2906002)(6916009)(6506007)(102836004)(6246003)(6436002)(54906003)(66446008)(66556008)(486006)(64756008)(66476007)(14454004)(6486002)(478600001)(73956011)(86362001)(81166006)(305945005)(81156014)(7736002)(8936002)(186003)(5660300002)(7416002)(1076003)(36756003)(4326008)(4744005)(6512007)(8676002)(33656002)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4703;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 2nSk9n4j3C4hJek/u+dZ6x7dV3tjTsGkUY3UXBXRkHKaWJqXhdg8ZS34cQZL7GwgyF5/MSzAJhv2aUAjjtk8CRvLzUVGNduiTuQkZy3Kv+MZPwfJIT90IFGBZ/ZsH3qZoh/CPWzTLkRl4wuE3WtmH20XC331wtkLzLWek4XEe0R+LNOkx+Hp/SCi2uxUbb7ts65BsfUxQNVpaOPGaYiTXZ2cklEw1b8NCzBt7dR1vWFs9sxDlNJ47eMYM+Bo+bdfGOd5g+9egoEaH5hhoSSUEnB25YzaoPWpks/1OJjOwTG1qouPEkgHuHQomu5+xxWhDy/fHuXrTHWkWiYva0Hxy3ILfkB1RQoRgbijiJvrA35MkyYBW3WSRajPXlSEBpJNXi4TzI+dMNkmRB5ftUjxHXdrJM09OJwhUKDw/JKjuRo=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <2494E1C39D43164DA0596E93A4038E37@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2344bec2-d78c-4486-b0bc-08d6f0362814
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:34:31.3397
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

On Thu, Jun 13, 2019 at 11:43:12AM +0200, Christoph Hellwig wrote:
> Just check if there is a ->page_free operation set and take care of the
> static key enable, as well as the put using device managed resources.
> diff --git a/mm/hmm.c b/mm/hmm.c
> index c76a1b5defda..6dc769feb2e1 100644
> +++ b/mm/hmm.c
> @@ -1378,8 +1378,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_=
devmem_ops *ops,
>  	void *result;
>  	int ret;
> =20
> -	dev_pagemap_get_ops();
> -

Where was the matching dev_pagemap_put_ops() for this hmm case? This
is a bug fix too?

The nouveau driver is the only one to actually call this hmm function
and it does it as part of a probe function.=20

Seems reasonable, however, in the unlikely event that it fails to init
'dmem' the driver will retain a dev_pagemap_get_ops until it unloads.
This imbalance doesn't seem worth worrying about.

Reviewed-by: Christoph Hellwig <hch@lst.de>

Jason

