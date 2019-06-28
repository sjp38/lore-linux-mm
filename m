Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39476C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:02:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC70E20645
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="EEFB2bfz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC70E20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6128C6B0003; Fri, 28 Jun 2019 13:02:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C1A88E0003; Fri, 28 Jun 2019 13:02:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 48A838E0002; Fri, 28 Jun 2019 13:02:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0A1B6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:02:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so9937138edb.1
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:02:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=4jwEvvXUPY88v4ZIhjZnxTRkKIFmTLxalBf1YgUdmjQ=;
        b=nkjpHnlGuGHLkjTkKiPJ3xKACVOAVz6y0bwiRMpQn0YGYvmfCaYo0UuFk1P1y8xtIY
         RPSxmwtKew+MJG1wJQxp9rUyq/XsQ4JICRBElOwRhjGJK7MY8E6bguTPCHmtY69bHwKw
         0nazX7isGkufUpiJdnQyqcjZI8RmSQRB/hc9/rjL8d35HHJhOo3HMAgDcVHyNdoEr+lR
         RWf1L4vDLzveQYjB9rNIvn8w1oJKSO2txiNJ3ZXBIfcHKpH81AuwmHZDEDK4y6Sfqxn4
         8FmgobVX5sXzcCJWHxmYtNf+RO4tyeZh/BogiVxe0aGSrVYOBcs6jCZBw0AkAlz+bGKa
         AO2w==
X-Gm-Message-State: APjAAAVy1bY4PYUIx4OsGT/5fqGimGfY9p9Y+O6p+S3Uj1QuTku5bEAz
	vicCQJfEITxLe5AFz+rweB8zbIEEdyk85tePWrb8wdCMLBK9cKc2J1BrlrQqc9mbni446xS3gub
	Kshw38OSz/q66lWRTjne4XMjwAmgvrRoYbtnZgVLMw9v74yvy9fHCWQPqeQRUb/rTMg==
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr12649262edq.251.1561741348576;
        Fri, 28 Jun 2019 10:02:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTqePNc+BYOusYKk3Njt2utaP6VfJGcgsJMrBXtQS0oY6Czkc4b22a/MdE4jEtOtA8fIYw
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr12649162edq.251.1561741347792;
        Fri, 28 Jun 2019 10:02:27 -0700 (PDT)
Received: from EUR04-DB3-obe.outbound.protection.outlook.com (mail-eopbgr60053.outbound.protection.outlook.com. [40.107.6.53])
        by mx.google.com with ESMTPS id 43si2732514edz.258.2019.06.28.10.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 28 Jun 2019 10:02:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.6.53 as permitted sender) client-ip=40.107.6.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=EEFB2bfz;
       arc=fail (signature failed);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.6.53 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=IxczjIUX47SlEfJYKoaREQQKFOfyym85joRLApmCR72W4WGLYtBNjfYt1kxQyub6qzLLShmH72FrtV23LqP3o8iX6ar3HpsJuMEiNoUowvo0XYBkV5LGx5T5w13p54XHvsXlDZPBmGU58fljMIHP63QztpW/l4QS5EeffMnUX9U=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4jwEvvXUPY88v4ZIhjZnxTRkKIFmTLxalBf1YgUdmjQ=;
 b=IL2dXY4OhYgLg4sz80I+UjCUNx0tbxM2db9p8Rj4GEi73Vbn2LoNrBd/QesM81z5Ewvi3FE100nrUYiPwNTMPiHPmekoSRVEviuvM7KW0NlnEllbySczlJfJn83hESXfDbtCK79uD9CqMfHEZwdIQ7KNOs6MSDDDZJEMfkTi0jo=
ARC-Authentication-Results: i=1; test.office365.com
 1;spf=none;dmarc=none;dkim=none;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=4jwEvvXUPY88v4ZIhjZnxTRkKIFmTLxalBf1YgUdmjQ=;
 b=EEFB2bfzg7R35ekPU9Is2C89hjDR2HVzz4USps+O4m1NTKt+eYNlqIRj3E2ge6F/POzMOyUDha3b1hEf+LsigHTYKKrxng13GVQrHo6GM6Ax0e6+cdYdlpzyfuAMTKZ8Mfl0hly1OH3BuZGrWaCybS6QbzW/MMtLrT/8xaiY6rc=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6255.eurprd05.prod.outlook.com (20.178.205.93) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Fri, 28 Jun 2019 17:02:26 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Fri, 28 Jun 2019
 17:02:25 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Christoph Hellwig <hch@lst.de>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-nvdimm@lists.01.org"
	<linux-nvdimm@lists.01.org>, "linux-pci@vger.kernel.org"
	<linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Thread-Topic: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Thread-Index: AQHVLBqgvimki3zmIk2l4xtSxGbkyKaxNtmAgAANxQCAAAmqgA==
Date: Fri, 28 Jun 2019 17:02:25 +0000
Message-ID: <20190628170219.GA3608@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-17-hch@lst.de> <20190628153827.GA5373@mellanox.com>
 <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
In-Reply-To:
 <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR21CA0002.namprd21.prod.outlook.com
 (2603:10b6:a03:114::12) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [76.14.1.154]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: dca8a338-cacd-4cc5-0d77-08d6fbea6507
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6255;
x-ms-traffictypediagnostic: VI1PR05MB6255:
x-microsoft-antispam-prvs:
 <VI1PR05MB62553740A223896F85BB96E0CFFC0@VI1PR05MB6255.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 00826B6158
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(346002)(396003)(136003)(39860400002)(189003)(199004)(66446008)(8936002)(6916009)(6436002)(66556008)(33656002)(476003)(53546011)(305945005)(186003)(66066001)(64756008)(3846002)(54906003)(11346002)(26005)(6486002)(6116002)(2906002)(36756003)(68736007)(478600001)(7736002)(14454004)(316002)(486006)(2616005)(86362001)(53936002)(4326008)(5660300002)(71200400001)(52116002)(73956011)(6246003)(446003)(66476007)(1076003)(81156014)(99286004)(6512007)(81166006)(6506007)(76176011)(8676002)(25786009)(256004)(71190400001)(386003)(7416002)(66946007)(102836004)(229853002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6255;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 1/O3iWmC49vqkfTuIb6GxfWPtwbqlTXEwu/cBsHqgZFr2n42TM+T/WLayFGiGhm+ClF7k7H7WUE5ScOm5f7mNwpOaJ2m6+C/qIgtmbduzmKBWANaB4Y6zJk2MXtcp/2cDewi2NNgVZMcdqG+shOFEZviCpMTl8VgoJwlcdSKhcbH3SB44zT3BumCqIU+JKIVw/udzgLHzpk/eZIEwaRxWtsKiG4ZAXBrn/TKiIsN/R2nelXN904cX8vuCjLBox1h4WQpnKa9WZYuy0Mo3i5a1DTUxZ9YeAVXwwoc99ba/G4FOOLxcYGnK1rN22ApkFcP+1qbQMRlchBa3NqffF8YBZvd9af8O0rVEqn6WhFeIyMn2zFyJFtulrLXO6EmInoYzncEs54QmipsPRyLPFYFYGOGNuqU9O92ImK00scWKAY=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <F315CA51D2C30A40AD4C5447E0263858@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: dca8a338-cacd-4cc5-0d77-08d6fbea6507
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Jun 2019 17:02:25.8791
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6255
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 09:27:44AM -0700, Dan Williams wrote:
> On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
> >
> > On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> > > The functionality is identical to the one currently open coded in
> > > device-dax.
> > >
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > >  drivers/dax/dax-private.h |  4 ----
> > >  drivers/dax/device.c      | 43 -------------------------------------=
--
> > >  2 files changed, 47 deletions(-)
> >
> > DanW: I think this series has reached enough review, did you want
> > to ack/test any further?
> >
> > This needs to land in hmm.git soon to make the merge window.
>=20
> I was awaiting a decision about resolving the collision with Ira's
> patch before testing the final result again [1]. You can go ahead and
> add my reviewed-by for the series, but my tested-by should be on the
> final state of the series.

The conflict looks OK to me, I think we can let Andrew and Linus
resolve it.

Thanks,
Jason

