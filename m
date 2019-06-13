Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF63DC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:05:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C9A220B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 19:05:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="YWGmvPnB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C9A220B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B16A8E0004; Thu, 13 Jun 2019 15:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 188208E0001; Thu, 13 Jun 2019 15:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04FE08E0004; Thu, 13 Jun 2019 15:05:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB2628E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 15:05:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so92465edc.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:05:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=5H89jYFJH+O3gOi+KgnHMurO79Cv4aZ07rELsB946Xc=;
        b=bAQDZ2s0+Dr63lNt6UsYyCA+2WNl31BxTJ8tHcrH9A6K96PIVa9TALDdBuegEJsOOn
         2/rDAVBK0wLRBUhGgNnXCW4WyKqg+23NkUP1XzdDBk6VEa8vLJVzIgHOCPtzA2hrZBzH
         xSlyPprd2TdtHbsr96OvfRopeazRGroB5VcaSjoKS+CcCVSqXGCKqMLj/OGGD6rThVzi
         Bt7zWAzN+UJ0TsQRZIpJj9lvscuOdSRrlrDYRnS4lhbEq4ktVeQ68vLaVJfWJtC+PRAk
         h71+CwXPtlM/98t8F/bixPT+ZeHolF588YoSAD7zqBkfhYEMRrZY8mMzSUiahJKP/Qks
         N2lg==
X-Gm-Message-State: APjAAAWczU6XWvRLkV6Fu47cU70HDjIOsZUV9Hq9RcE5vE969HA+pv53
	dUI04hPhV4NvvDBf8J81jc+WHQ4wqoVINGnloqtuI6WPNpyKcNMQ9aA2QNamUF3TgiiG3XwafpM
	UksTfpmAmMMV/MzSijplcpz+dggCwS4RDePRtJ0mrBmfUslmJpExZChl8VeXEzU/uJQ==
X-Received: by 2002:a50:b662:: with SMTP id c31mr95886848ede.252.1560452711275;
        Thu, 13 Jun 2019 12:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcrGS+D/9fg2h8HPj9hKe1NknjZKtWO5e7bQahBlOYGQx8i/pJg+HeezR4os2O5p9zRzsP
X-Received: by 2002:a50:b662:: with SMTP id c31mr95886761ede.252.1560452710466;
        Thu, 13 Jun 2019 12:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560452710; cv=none;
        d=google.com; s=arc-20160816;
        b=T+hyBBS5wKsFGK6cNU9H5/mi7R2G0wLByGojNil0CfuPcGQe1oD6dYV2yc9No+8Xmg
         wxM0ECeXXSIky9xWxcpaPBMYz2Y4Up4nc12S3qQHdy65tGba00kOKWyiACpGgMPuQatd
         IyYxJ69j1Spt3VQXXSiU71UBFOhKdKhRyr4RmVONPgW3J92yh0wO31VxoVOVhzwJGh19
         gRM88CzYNQ84tOzpZX9kxCr5q9mDu7uQJpMtg2vY0IztSK5Zt9jkXfA0VmyHa/KY0L/6
         uOfAS8LtnfRIPTmljUXTjIgOL7MkjpfBRhG+zkhgwJEvPKlUGZkyqE4nLpr/dYsn5pUE
         nsXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=5H89jYFJH+O3gOi+KgnHMurO79Cv4aZ07rELsB946Xc=;
        b=ExcS22o1eBsxlhsz0NHSdsHdSu/hvR1IhfCQxZRSttmM4Gs/2bDYdVsqyVtMTJX0Fq
         +kUoINYChH8lSlM1BGyKMAsncepnVUBWjttTeAou768NZioi8VGxNN8NZriIuiNbBCGJ
         2B0Vxp7T+ROX5dFIgBlTzMDT0+f69Hi7wj29l8YyfCno3IpJToaYwT8taKwIYYQ4LAbH
         7whMW9XLcFnfNRPqI99NsfFKsYZe8CsQ4Wmf0bsL3Jm/wjnKr2pVv2xbwViiZ6fOS8LC
         rU6hxaZtCCUuvmP7x3ZN8nbnCHbUb7WQ91h2neNlBAZ6BrlT9GjBgY3+epyVhk8S5y/9
         Or+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YWGmvPnB;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50074.outbound.protection.outlook.com. [40.107.5.74])
        by mx.google.com with ESMTPS id z7si290963edd.406.2019.06.13.12.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 12:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.5.74 as permitted sender) client-ip=40.107.5.74;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=YWGmvPnB;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.5.74 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5H89jYFJH+O3gOi+KgnHMurO79Cv4aZ07rELsB946Xc=;
 b=YWGmvPnBhCruH1hC4ENOlDT/9NFEkEL0a4q9Qa4NpxuZS5nl20d1v1o2AyB8KY0mRuUpO8MBZVt3w70ES3mNbWfW9rSrolUHDrlUOb11mpH1sv6dZFgWg/bmYjRlTeKxzVQizkp6CPOcq2N0Zz+3+5aKzaCjOTaUlVQ+9iGoHDk=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB4928.eurprd05.prod.outlook.com (20.177.51.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 13 Jun 2019 19:05:09 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::c16d:129:4a40:9ba1%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 19:05:08 +0000
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
Subject: Re: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
Thread-Topic: [PATCH 04/22] mm: don't clear ->mapping in hmm_devmem_free
Thread-Index: AQHVIcx9tYJr+8Mn7kqAMQYMKR1ZDqaZ8jSA
Date: Thu, 13 Jun 2019 19:05:07 +0000
Message-ID: <20190613190501.GQ22062@mellanox.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-5-hch@lst.de>
In-Reply-To: <20190613094326.24093-5-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTBPR01CA0021.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b01:14::34) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bbf803f6-efcc-4d94-d47b-08d6f0320cfc
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB4928;
x-ms-traffictypediagnostic: VI1PR05MB4928:
x-microsoft-antispam-prvs:
 <VI1PR05MB4928F4B1BDE805C1E9FF8777CFEF0@VI1PR05MB4928.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(39860400002)(346002)(376002)(396003)(366004)(189003)(199004)(7736002)(81156014)(36756003)(14444005)(476003)(2616005)(6486002)(6436002)(256004)(486006)(33656002)(446003)(99286004)(54906003)(11346002)(305945005)(66446008)(66066001)(6246003)(26005)(66476007)(8676002)(229853002)(73956011)(6916009)(66556008)(7416002)(186003)(53936002)(81166006)(316002)(66946007)(64756008)(6512007)(3846002)(102836004)(5660300002)(8936002)(1076003)(76176011)(14454004)(386003)(52116002)(6506007)(4326008)(71200400001)(71190400001)(478600001)(86362001)(2906002)(25786009)(6116002)(68736007);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB4928;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 6FABMmmx3sbXSt/4QuBhcr7/YtvHD9s/olWKQHhWI0mA8kSlXMrWKF0QZilfQlXKDGbNvyqHgaxtSNIRDHWheLvlaQg7ETFB5Cjnsj3e6AzZTE/LzV1r/NXF4RPFKajt7Lf0Zt3MLCVPMv6Py9/mIUvHGARY4lqJVy9Ty8iRrJAEPZH0ZBM9D1K5rtlvMnz+WJYUeaF4YLccPfAELIPq0IFDLQouavshf+v9LfjaFE4GF5kD2gQSIkznPLEr5clvmds52YnLYX7mLmyaXddlqJBiuppL2rqQ4yHc0l15YlH27wU+91x31a2e5aTrSJ20Jta1x+D2p7zY9S4bBcgIW15iFdf19CgvOtpiNVk+iUV7/GLUbJt6PuRULdtVYopy1ZL0GfFk9W9ORII8qhp1t7aYrw6saeClZmC8MzyF26Q=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <7BF6B23DFB21B24C9129FD14A4ED8C15@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bbf803f6-efcc-4d94-d47b-08d6f0320cfc
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 19:05:07.9878
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB4928
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:07AM +0200, Christoph Hellwig wrote:
> ->mapping isn't even used by HMM users, and the field at the same offset
> in the zone_device part of the union is declared as pad.  (Which btw is
> rather confusing, as DAX uses ->pgmap and ->mapping from two different
> sides of the union, but DAX doesn't use hmm_devmem_free).
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/hmm.c | 2 --
>  1 file changed, 2 deletions(-)

Hurm, is hmm following this comment from mm_types.h?

 * If you allocate the page using alloc_pages(), you can use some of the
 * space in struct page for your own purposes.  The five words in the main
 * union are available, except for bit 0 of the first word which must be
 * kept clear.  Many users use this word to store a pointer to an object
 * which is guaranteed to be aligned.  If you use the same storage as
 * page->mapping, you must restore it to NULL before freeing the page.

Maybe the assumption was that a driver is using ->mapping ?

However, nouveau is the only driver that uses this path, and it never
touches page->mapping either (nor in -next).

It looks like if a driver were to start using mapping then the driver
should be responsible to set it back to NULL before being done with
the page.

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

