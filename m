Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE636C48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:18:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1B6220659
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:18:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="J2dMlcNP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1B6220659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A3B18E0005; Thu, 27 Jun 2019 12:18:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 252258E0002; Thu, 27 Jun 2019 12:18:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11AB18E0005; Thu, 27 Jun 2019 12:18:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7F4B8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:18:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b21so6345502edt.18
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:18:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=UQKJZidBThddtQhWQZohKcjkCp3iYRBt7c0S6siQ09M=;
        b=j2Q37yOGwB48qDAi2+33he6MfAsvc8n7rVivcxIf667eTSQOFvSaqdPMQ5UB6w6ejh
         5b8L+k3zSmWIhCqFFndDZzZh5b/BEaH7yACt+UryJ7r3nAsRKRFnve2tqZ0q4JgBFeC+
         N6Owr6pp9DBxfr04Ge1YAF9zcg0V4Z4zq2ctTSbwIm6RHbqGnbeIPibHneDG9li4WG8D
         8NRwO+GHRtwmkdG1sOEJvIsoI6v0ZmMao+d7z4bc/MeLOFn4/+MGq8ubZ1sKUuowjX5/
         K64XhzpEtHBVsenbD8n7/63OLolFRs7rfPycG0Y7i+7gTBsgU3+Tjbij26TRXznpKdZv
         VrMw==
X-Gm-Message-State: APjAAAXZpWsgMZxB4h80HW1wj07Z07XYvW1dOwz4XgaVRYQiGIgOqbK7
	KfBrCBN1eJ+I3NUyiaiQb6vQ7ELyQevkqcr4mgfcy45mVzwtkDDcYUVaXSvSooPjJGRTusoyrIg
	OEKNJS1jDOkMlYEPMO8NGMaaJfrwjNSPtvtuYx3z3Dm8XKnzEIWoEs/LGq3J9Tavh0Q==
X-Received: by 2002:aa7:da03:: with SMTP id r3mr5385237eds.130.1561652304223;
        Thu, 27 Jun 2019 09:18:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwI+imzDn3uJhhTCo6WTzUfpjym1dd4Bv+79FJOu7oF4cvgHPo3zbHzpzEnOewllQcKD3mV
X-Received: by 2002:aa7:da03:: with SMTP id r3mr5385171eds.130.1561652303596;
        Thu, 27 Jun 2019 09:18:23 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30058.outbound.protection.outlook.com. [40.107.3.58])
        by mx.google.com with ESMTPS id m20si1839286ejb.67.2019.06.27.09.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jun 2019 09:18:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@mellanox.com designates 40.107.3.58 as permitted sender) client-ip=40.107.3.58;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector2 header.b=J2dMlcNP;
       arc=fail (signature failed);
       spf=pass (google.com: domain of jgg@mellanox.com designates 40.107.3.58 as permitted sender) smtp.mailfrom=jgg@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=LBJCwUQhZNZ7JO6Lm19Nly1Wj8bCpXKqTCKdgBXsd6H55hzx7W1wAb6hUJJrD5FqcHqpTPQWmGOjeeJB8iX/pkbU1eeUm2bF+4gSiCpHD3NQDYjzq9HHS7zfgVocvCuAlQZQxkhvFkyt3jKqK1xJXCcqBX6vSIItewtdUWpzMPc=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UQKJZidBThddtQhWQZohKcjkCp3iYRBt7c0S6siQ09M=;
 b=UtnblwRey3svlmUCbu+2ebcVAuSz5M+zsn+H8ORaEAtxvjgk96dUT6WBtbwkfbuiBC3bcUK96/X+QfQh7GO/4zgdibmsu0eYLFCKZzvsQlth1qResb22s9dFROK5zbAkTX5ZOcpgmeXJbziLc3phdsi3SLaNm0i00WScr2FO9xE=
ARC-Authentication-Results: i=1; test.office365.com
 1;spf=none;dmarc=none;dkim=none;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UQKJZidBThddtQhWQZohKcjkCp3iYRBt7c0S6siQ09M=;
 b=J2dMlcNPZlD5N3vpQW1JjZMZcMPSA86ZsmMs/EA5ArN364tGhM/lbJBxFeL8QjH9sUmtmFktOVRL7mywOKEaFOcd259xase/Xs5EwItur4p4WBEUMAcCj0JbdS9MN5foY/pEt0x+MnDGkFVMwyd7bcVx8mwkr8hnhSOMGkaySa4=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB5886.eurprd05.prod.outlook.com (20.178.125.203) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 16:18:22 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::f5d8:df9:731:682e%5]) with mapi id 15.20.2008.014; Thu, 27 Jun 2019
 16:18:22 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Christoph Hellwig <hch@lst.de>
CC: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, John Hubbard
	<jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 03/25] mm: remove hmm_devmem_add_resource
Thread-Topic: [PATCH 03/25] mm: remove hmm_devmem_add_resource
Thread-Index: AQHVLBqRvJE5RWoAFEuwP/I4qHQ7paavr6GA
Date: Thu, 27 Jun 2019 16:18:22 +0000
Message-ID: <20190627161813.GB9499@mellanox.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-4-hch@lst.de>
In-Reply-To: <20190626122724.13313-4-hch@lst.de>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR02CA0011.namprd02.prod.outlook.com
 (2603:10b6:a02:ee::24) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [12.199.206.50]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9c526e6d-f839-4214-2861-08d6fb1b12e9
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB5886;
x-ms-traffictypediagnostic: VI1PR05MB5886:
x-microsoft-antispam-prvs:
 <VI1PR05MB5886C35E617535FD2443239DCFFD0@VI1PR05MB5886.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 008184426E
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(396003)(376002)(39860400002)(199004)(189003)(6436002)(66556008)(81166006)(99286004)(2616005)(3846002)(8936002)(6512007)(33656002)(6246003)(68736007)(4326008)(102836004)(53936002)(4744005)(8676002)(6486002)(73956011)(86362001)(81156014)(66946007)(478600001)(5660300002)(36756003)(54906003)(1076003)(186003)(66446008)(25786009)(66066001)(316002)(229853002)(71190400001)(76176011)(6116002)(26005)(66476007)(476003)(2906002)(7736002)(446003)(386003)(52116002)(14454004)(6916009)(256004)(305945005)(486006)(64756008)(11346002)(6506007)(7416002)(71200400001);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB5886;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 MPZH6fxej22oS7mLYEZmxFyn20waja4eRFeHmir8gtV1hjF9WJIgHwtjY4C36d2npItR/CWyxfgPjCQ+e19S8i/WruQpqNIHjrH8CZ+IYxP/SAf5mBH7mWcVbuKjO5vst38yOem1FSeiQc+UM2HMfjmCGzZa1IsRZcLs0/bJZFvSDMd7v8/irZB5vT9QtJv1uBJ3h7xdhz/QMy1Uw26YL0jRvCcMQ/atQgGDIJsmelkfWdS/PbSyMm+AYLLH079WJ+KZtdpsYfSGGYocok7klunoms3nZiojM8Wl2c8TBBunzsbCb3Y4kJbM5C/sD1C0N8RqfQHigF8REGgBv/QvoepFXUnYnPM6uoUomO356Lzf/kFxS5R31l4fpw9RbxA78tBT/LQENWHD6dP3CjqH5nHlGfE0H/4aTEuIRyx7Vjo=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <0E26856B4495E64E8EFED3F814341B4B@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9c526e6d-f839-4214-2861-08d6fb1b12e9
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 16:18:22.2670
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jgg@mellanox.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB5886
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:27:02PM +0200, Christoph Hellwig wrote:
> This function has never been used since it was first added to the kernel
> more than a year and a half ago, and if we ever grow a consumer of the
> MEMORY_DEVICE_PUBLIC infrastructure it can easily use devm_memremap_pages
> directly.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/hmm.h |  3 ---
>  mm/hmm.c            | 50 ---------------------------------------------
>  2 files changed, 53 deletions(-)

This should be squashed to the new earlier patch?

Jason

