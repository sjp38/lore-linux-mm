Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFC2FC31E41
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FCE320862
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 16:03:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="kctyDxIf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FCE320862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 322AC6B026B; Mon, 10 Jun 2019 12:03:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F9E06B026D; Mon, 10 Jun 2019 12:03:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C29B6B026E; Mon, 10 Jun 2019 12:03:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C22E56B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 12:02:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so16038339eda.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=450d2MXVWodpENJheLwYn0Z7xWvqO7wr3qF4QWDO8sY=;
        b=OR8rdSmm8zMWgkwxwejCgODJ/vHCFrTDqyhX0FvOBwonagmHD1FEu/waZkcCK/8rTd
         HwtYcS5ekdOBGkIn2cqd1H8Ozkx6dTv2KXErmryRNZ45tNYiofxZtkBryrV7EfQJn4Yz
         Qek1sTyvcF57QBJjUBd5Zxhde6FrJtxrS3jS+3zb8rDGY71ExnMptrX5Gni78NhysSNH
         lT2TxLwXR3eV4NRDhC7327rsiz3CEuyQ0BEfOK6K87HgQPHyncuwAiKSyiZ9sW6NYbM+
         b8oNNHtHnfc8Aejq9semG+PuZhMj4xwObFH+wQHs0pnF55+6OpJRIgjxg/zWZsxwmYK3
         yXqA==
X-Gm-Message-State: APjAAAXDrVU6VEPNi3gJVhUuTlLa0+Ysei/s0yhg9X+LzqGNsf7Tci4K
	EJCDDRlOjbrUNbbRmYKKSBsg6kJ3NiVFyva+uSsqKRq+keJkAshkOinMojaYyhUcSDEfo4sYpcp
	YRZA7inzYvx20lhOQqcxvkkJHd8pDJo81BGR+BcOTevoNsqx2+jJbDkjZl3p7lxU1yA==
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr52396275edc.300.1560182579287;
        Mon, 10 Jun 2019 09:02:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbDtMvkyTxpSQSnnUMs44+bH+Dyk8pa5a6UNGYhZ8T90KaKbuWZRN8hdLUOAAmiP0CeDo9
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr52396190edc.300.1560182578517;
        Mon, 10 Jun 2019 09:02:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560182578; cv=none;
        d=google.com; s=arc-20160816;
        b=CT/45VPg7qbfGjwmBtWpzV3uWHXNENJDqOto6/yJF05tu/zQRZIz2bkDggk87cXc9s
         M5u86wjaSuF40tkONYlNYoyq5NxOQLIUQWIGo2NjgiKB6z+wmjQb/rCIL6AjJBYs19Uf
         Z/wOrPCrcmRJH8bRtKaxwbB/smrzOFomvd6WmCr0kzCQRV5vXnu4abuN56ioyacpeWSN
         iWFLkCNSvjvrw9vhkPXSvIFgPJln8gbFIM/RQ88E3jvrnCLKkcIDb1LsHSzX1nY3i9kZ
         l1kERCyjwV30u0UyRNuwnt0nie3GCnpl2l23Ep3nueEjdNBac03rfOJbA7SB7VyR0AZv
         phDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=450d2MXVWodpENJheLwYn0Z7xWvqO7wr3qF4QWDO8sY=;
        b=FA6vIxxdoCX0Rv1yiad1EtcENHTN4u8XstDFTNOSyjK15NGid6kkhyYvd6O2nNvuwW
         1qcnwffYdqH56W56YYmaZCRNi4DaoDNQ/W6D/F21GW0PKaYpc2dlDnheqIpRlxgI74Es
         9PCSzqXL1eazA1/QOsiOhb03U7JERW5Ce1ktfXK9J9VXaRxlERYNVDpOSIIZndk5/R2Y
         d6fYX6v1IJQFTD0T3LSDYsoGr8T6rQx2yJU1I+V4YyQTkT/GJOr4AEQX6U2+tYOcyxw0
         1/E4ed3OPiwTqujNCzquZr+rx3hsxiHlAvOVaF9Jb2BeTqG5KRgEivMBSVvPtBE2cmh7
         XgIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=kctyDxIf;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.51 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-eopbgr130051.outbound.protection.outlook.com. [40.107.13.51])
        by mx.google.com with ESMTPS id m11si3097444eje.369.2019.06.10.09.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 09:02:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.13.51 as permitted sender) client-ip=40.107.13.51;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=kctyDxIf;
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.13.51 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=450d2MXVWodpENJheLwYn0Z7xWvqO7wr3qF4QWDO8sY=;
 b=kctyDxIfUDvoSeIPOePSVT3oHbQ3/3dDtOXCbB4D4/GE+Nai0EpzR0b+7w2Lgude1EulJskY2cIwuXFF5tBkBX5EUAVcsM+IjNX+2gkqkFTUIYjaLSkHD08hPwPRVxDe/K2VxSMq0wfuqMKyZmCVusOGejBp6nJo+eIvS0Izl14=
Received: from AM0PR05MB4130.eurprd05.prod.outlook.com (52.134.90.143) by
 AM0PR05MB4387.eurprd05.prod.outlook.com (52.134.93.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.13; Mon, 10 Jun 2019 16:02:56 +0000
Received: from AM0PR05MB4130.eurprd05.prod.outlook.com
 ([fe80::4825:8958:8055:def7]) by AM0PR05MB4130.eurprd05.prod.outlook.com
 ([fe80::4825:8958:8055:def7%3]) with mapi id 15.20.1965.017; Mon, 10 Jun 2019
 16:02:56 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Ralph Campbell <rcampbell@nvidia.com>
CC: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	"Felix.Kuehling@amd.com" <Felix.Kuehling@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
Thread-Topic: [PATCH v2 hmm 11/11] mm/hmm: Remove confusing comment and logic
 from hmm_release
Thread-Index: AQHVHJft+otwZ8rUPEekfSi3CzR0ZqaQuR+AgARZmwA=
Date: Mon, 10 Jun 2019 16:02:56 +0000
Message-ID: <20190610160252.GH18446@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-12-jgg@ziepe.ca>
 <61ea869d-43d2-d1e5-dc00-cf5e3e139169@nvidia.com>
In-Reply-To: <61ea869d-43d2-d1e5-dc00-cf5e3e139169@nvidia.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: YTXPR0101CA0057.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::34) To AM0PR05MB4130.eurprd05.prod.outlook.com
 (2603:10a6:208:57::15)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [156.34.55.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e0456bf9-5aef-4511-cd81-08d6edbd19d8
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:AM0PR05MB4387;
x-ms-traffictypediagnostic: AM0PR05MB4387:
x-microsoft-antispam-prvs:
 <AM0PR05MB4387F54CE3B8303BBA27A817CF130@AM0PR05MB4387.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0064B3273C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(396003)(39860400002)(376002)(189003)(199004)(316002)(25786009)(2616005)(476003)(486006)(99286004)(76176011)(4326008)(66066001)(478600001)(52116002)(36756003)(11346002)(446003)(66946007)(186003)(6512007)(66476007)(26005)(6486002)(229853002)(66446008)(64756008)(386003)(6506007)(66556008)(53936002)(53546011)(102836004)(73956011)(68736007)(54906003)(6916009)(6436002)(305945005)(256004)(81166006)(7736002)(8936002)(2906002)(8676002)(81156014)(6246003)(71190400001)(71200400001)(6116002)(3846002)(86362001)(33656002)(1076003)(5660300002)(14454004);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR05MB4387;H:AM0PR05MB4130.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 /XoWWl7DXZHkqt6HlSb0h/i3876cDXvgZJD7FRjHmDVQJC4j32FplncqgEl42kFVAZ21UO5yMzo+9aUjSa9MzSgERb4OdeF6NABWEWh/jDwuKvVK5u/M4s5Jh9QycDt00d5E7+4den8XeFui3NEzowflwyR0J7EMuzZlxv5H9SmfVBxXX7y3lRhXvxpQn7DsMvL6VWpVEFYQW/btyyTiGbNTEtZaIh9f7hOdCPkcydvKezjQzAkH6VVR6f4JWrfhZYjFEUE+7O6hLsAscYlbEhtitIzT5oEE9f3RQY3LfF2dRIt1hw5pX2pz7fpHYZQHrCg+AKpe6DI+ZcMrc/SDd497dYSniuK4axUed942M+cEUsmmB90jlgxxYQus0vGmdJULi6YnrC0pX08C3xggWhmm2Ii4hZwucXEF5wcBoPg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8C3BE8F336B51E4C8608A9C4C971BE76@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e0456bf9-5aef-4511-cd81-08d6edbd19d8
X-MS-Exchange-CrossTenant-originalarrivaltime: 10 Jun 2019 16:02:56.0642
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR05MB4387
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 02:37:07PM -0700, Ralph Campbell wrote:
>=20
> On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> > From: Jason Gunthorpe <jgg@mellanox.com>
> >=20
> > hmm_release() is called exactly once per hmm. ops->release() cannot
> > accidentally trigger any action that would recurse back onto
> > hmm->mirrors_sem.
> >=20
> > This fixes a use after-free race of the form:
> >=20
> >         CPU0                                   CPU1
> >                                             hmm_release()
> >                                               up_write(&hmm->mirrors_se=
m);
> >   hmm_mirror_unregister(mirror)
> >    down_write(&hmm->mirrors_sem);
> >    up_write(&hmm->mirrors_sem);
> >    kfree(mirror)
> >                                               mirror->ops->release(mirr=
or)
> >=20
> > The only user we have today for ops->release is an empty function, so t=
his
> > is unambiguously safe.
> >=20
> > As a consequence of plugging this race drivers are not allowed to
> > register/unregister mirrors from within a release op.
> >=20
> > Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
>=20
> I agree with the analysis above but I'm not sure that release() will
> always be an empty function. It might be more efficient to write back
> all data migrated to a device "in one pass" instead of relying
> on unmap_vmas() calling hmm_start_range_invalidate() per VMA.

I think we have to focus on the *current* kernel - and we have two
users of release, nouveau_svm.c is empty and amdgpu_mn.c does
schedule_work() - so I believe we should go ahead with this simple
solution to the actual race today that both of those will suffer from.

If we find a need for a more complex version then it can be debated
and justified with proper context...

Ok?

Jason

